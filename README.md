# gc3-vuln-reporting-iac

Government Cyber Coordination Centre - Vulnerability Reporting - Infrastructure as Code

![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform Version v1.0.11](https://img.shields.io/badge/Terraform-v1.0.11-blueviolet?style=for-the-badge&logo=terraform)
![Last commit image](https://img.shields.io/github/last-commit/co-cddo/gc3-vuln-reporting-iac?style=for-the-badge&logo=github)

Infrastructure as code (Terraform) for VRS running on AWS.

- Pre-production/staging: <https://vulnerability-reporting.nonprod-service.security.gov.uk>
- Production: <https://vulnerability-reporting.service.security.gov.uk>

## security.txt

The `security.txt` file is generated from [security.txt.tmpl](https://github.com/co-cddo/gccc-vrs-iac/blob/main/cdn/s3_bucket/.well-known/security.txt.tmpl) and takes variables from [cdn/s3.tf](https://github.com/co-cddo/gccc-vrs-iac/blob/main/cdn/s3.tf#L38) - it is updated on every change and deploy or every Wednesday at 9am.

## Acknowledgements

Acknowledgements can be added in the [cdn/variables.tf](https://github.com/co-cddo/gccc-vrs-iac/blob/main/cdn/variables.tf#L2) file.

## Infrastructure

### CloudFront CDN

[cdn](cdn/) is for CloudFront where S3 is the backend origin, [Functions](https://aws.amazon.com/blogs/aws/introducing-cloudfront-functions-run-your-code-at-the-edge-with-low-latency-at-any-scale/) are used to handle traffic dynamically and in a scalable way.

The [router JavaScript function](cdn/functions/router/router.js) has several endpoints.

The router function has a test suite that can be ran by doing:
``` bash
cd cdn/functions/router/
npm install
npm test
```
cd
#### Deployment

In order to make changes to the CDN contents, for instance front-end changes to the VRS service, you need to:

- make changes locally
- push them to the nonprod environment using terraform. The nonprod environment is behind http basic auth, and you
  need to set up credentials as part of the deployment. Choose a username and a password and deploy:

  If you're on MacOS:
  ```bash
  export BASICAUTHSTRING = printf '%s:%s' "USERNAME" "PASSWORD" | base64 | tr -d '\n'
  ```

  on Linux:
  ```bash
  export BASICAUTHSTRING = printf '%s:%s' "user" "pass" | base64 -w 0
  ```

  then, change to the `cdn` directory then:

  ```bash
  terraform apply -var="basicauthstring=$BASICAUTGHSTRING
  ```

Deployment to the live environment is done manually in Github Actions.

### Route53 DNS

[dns](dns/) is the management of the Route53 zone and records.

Utilises the [aws-route53-parked-govuk-domain](https://github.com/co-cddo/aws-route53-parked-govuk-domain) Terraform module for _parking_ the email records.
