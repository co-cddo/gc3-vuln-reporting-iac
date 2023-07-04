# Copyright 2010-2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# This file is licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License. A copy of the
# License is located at
#
# http://aws.amazon.com/apache2.0/
#
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
# OF ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

import os
import boto3
import email
import re
import json
import base64
import time
import random

from botocore.exceptions import ClientError
from botocore.client import Config

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication

region = os.environ["Region"]
incoming_email_bucket = os.environ["MailS3Bucket"]

# Create a new S3 client.
client_s3 = boto3.client("s3", config=Config(signature_version="s3v4"))


def get_message_from_s3(object_path):
    object_http_path = (
        f"https://s3.{region}.amazonaws.com/{incoming_email_bucket}/{object_path}"
    )

    # Get the email object from the S3 bucket.
    object_s3 = client_s3.get_object(Bucket=incoming_email_bucket, Key=object_path)
    # Read the content of the message.
    file = object_s3["Body"].read()

    file_dict = {"file": file, "path": object_http_path}
    print(json.dumps(file_dict, default=str))

    return file_dict


def create_message(file_dict, destinations):
    system_recipient = ""
    group = None
    destination_override = None

    system_domain = os.environ["MailSenderDomain"]
    no_reply_address = f"no-reply@{system_domain}"

    if "contact@" in destinations:
        system_recipient = f"contact@{system_domain}"
        group = "10979637972369"
    elif "report@" in destinations:
        system_recipient = f"report@{system_domain}"
        group = "10980471236113"
    elif "ollie@" in destinations:
        destination_override = os.environ["OllieOverrideEmail"]

    # Parse the email body.
    mailobject = email.message_from_bytes(file_dict["file"])

    sender = mailobject.get("X-Original-Sender")
    if sender is None:
        sender = mailobject.get("From")
    if sender is None:
        sender = mailobject.get("Reply-To")
    if sender is None:
        sender = mailobject.get("Return-Path")
    if sender is None:
        sender = no_reply_address

    sender_email = sender
    if "<" in sender_email:
        sender_email = sender_email.split("<", 1)[1].strip(">")

    zendesk_reply = False

    new_headers = []
    for x in mailobject._headers:
        if x[0] in ["Received-SPF", "Authentication-Results"]:
            new_headers.append((f"X-SES-{x[0]}", x[1]))
        if not zendesk_reply and x[0] in ["References", "In-Reply-To"]:
            if "zendesk.com" in x[1]:
                zendesk_reply = True
        if x[0] not in [
            "Received-SPF",
            "Authentication-Results",
            "DKIM-Signature",
            "From",
            "Reply-To",
            "Return-Path",
            "To",
        ]:
            new_headers.append(x)

    mailobject._headers = new_headers

    if not zendesk_reply:
        for x in mailobject.get_payload():
            if x.get_content_type().startswith("text/plain"):
                cte = x["Content-Transfer-Encoding"] if "Content-Transfer-Encoding" in x else None
                if cte and cte == "base64":
                    continue
                original_body = x.get_payload()
                inc_group = f"#group {group}\n" if group else ""
                x.set_payload(
                    f"#requester {sender_email}\n{inc_group}\n{original_body}"
                )

    mailobject.add_header("From", no_reply_address)
    mailobject.add_header("Reply-To", sender)
    mailobject.add_header("To", system_recipient)

    b64 = base64.standard_b64encode(mailobject.as_bytes())
    print("b64:", b64)

    message = {
        "Source": no_reply_address,
        "Destinations": destination_override if destination_override != None else os.environ["MailRecipient"],
        "Data": mailobject.as_string(),
    }

    return message


def send_email(message):
    aws_region = os.environ["Region"]

    # Create a new SES client.
    client_ses = boto3.client("ses", region)

    # Send the email.
    try:
        # Provide the contents of the email.
        response = client_ses.send_raw_email(
            Source=message["Source"],
            Destinations=[message["Destinations"]],
            RawMessage={"Data": message["Data"]},
        )

    # Display an error if something goes wrong.
    except ClientError as e:
        output = e.response["Error"]["Message"]
    else:
        output = "Email sent! Message ID: " + response["MessageId"]

    return output


def lambda_handler(event, context):
    # initial delay waiting for s3
    time.sleep(2)
    
    # Get the unique ID of the message. This corresponds to the name of the file
    # in S3.
    message_id = event["Records"][0]["ses"]["mail"]["messageId"]
    destinations = ",".join(event["Records"][0]["ses"]["receipt"]["recipients"]).lower()
    # print(f"Received message ID {message_id}")

    print(json.dumps(event, default=str))

    # Retrieve the file from the S3 bucket.
    incoming_email_prefix = ""
    if "contact@" in destinations:
        incoming_email_prefix = "contact"
    elif "report@" in destinations:
        incoming_email_prefix = "report"

    if incoming_email_prefix:
        object_path = incoming_email_prefix + "/" + message_id
    else:
        object_path = message_id

    print(json.dumps({
        "incoming_email_prefix": incoming_email_prefix, 
        "incoming_email_bucket": incoming_email_bucket, 
        "object_path": object_path
    }, default=str))

    file_dict = get_message_from_s3(object_path)
    
    # Check for tag
    time.sleep(float(random.randrange(50, 501)/100))
    tag_resp = client_s3.get_object_tagging(
        Bucket=incoming_email_bucket,
        Key=object_path
    )
    email_processed = False
    if "TagSet" in tag_resp:
        for kv in tag_resp["TagSet"]:
            if kv["Key"] == "processed":
                email_processed = True
                break

    if not email_processed:
        tag_proc_resp = client_s3.put_object_tagging(
            Bucket=incoming_email_bucket,
            Key=object_path,
            Tagging={
                'TagSet': [
                    {
                        'Key': 'processed',
                        'Value': 'true'
                    },
                ]
            },
        )

        # Create the message.
        message = create_message(file_dict, destinations)

        # Send the email and print the result.
        result = send_email(message)
        print(result)
