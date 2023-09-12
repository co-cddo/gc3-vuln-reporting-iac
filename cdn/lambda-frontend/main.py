import os
import json
import traceback
import jinja2
import werkzeug
import markdown
import re

from operator import itemgetter
from markupsafe import Markup
from datetime import datetime, timedelta
from flask import (
    Flask,
    request,
    session,
    Response,
    redirect,
    send_from_directory,
    make_response,
)
from apig_wsgi import make_lambda_handler

from vrs_csrf import CheckCSRFSession, get_csrf_session
from vrs_vdps import get_vdps, get_default_vdp, get_vdp_by_domain, get_vdp_by_id

ENVIRONMENT = os.getenv("ENVIRONMENT", "development")
IS_HTTPS = os.getenv("IS_HTTPS", "false").lower().startswith("t")
URL_PREFIX = os.getenv("URL_PREFIX", "http://localhost:5005")
COOKIE_PREFIX = "__Host-" if IS_HTTPS else ""
COOKIE_NAME_SESSION = f"{COOKIE_PREFIX}Session-GC3-VRS"

assets = werkzeug.utils.safe_join(os.path.dirname(__file__), "assets")
app = Flask(__name__)

app.config.update(
    ENV=ENVIRONMENT,
    SESSION_COOKIE_NAME=COOKIE_NAME_SESSION,
    SESSION_COOKIE_DOMAIN=None,
    SESSION_COOKIE_PATH="/",
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SECURE=IS_HTTPS,
    SESSION_COOKIE_SAMESITE="Lax",
    PERMANENT_SESSION_LIFETIME=timedelta(hours=12),
    SECRET_KEY=os.getenv("FLASK_SECRET_KEY", "123"),
    MAX_CONTENT_LENGTH=120 * 1024 * 1024,
)

md = markdown.Markdown(extensions=["meta"])
alb_lambda_handler = make_lambda_handler(app, binary_support=True)


def jprint(obj):
    if type(obj) == str:
        obj = {"message": obj}
    if type(obj) == dict:
        if "_time" not in obj:
            new_obj = {"_time": datetime.now()}
            new_obj.update(obj)
            obj = new_obj
    print(json.dumps(obj, default=str))


jprint(
    {
        "application": "loaded",
        "ENVIRONMENT": ENVIRONMENT,
        "IS_HTTPS": IS_HTTPS,
    }
)


def render(filename: str, params: dict = {}, status_code: int = 200) -> str:
    params.update({"url_prefix": os.getenv("URL_PREFIX", "http://localhost:5005")})
    params.update({"environment": ENVIRONMENT})

    pbe = os.getenv("PHASE_BANNER", "PRIVATE-ALPHA")
    params.update({"phase_banner": pbe})
    params.update(
        {
            "phase_banner_class": (
                "red_phase"
                if any(
                    m in pbe.upper()
                    for m in ["NONPROD", "LOCALHOST", "TEST", "DEV", "STAGING"]
                )
                else ""
            )
        }
    )

    params.update({"domain": os.getenv("DOMAIN")})

    templateLoader = jinja2.FileSystemLoader(searchpath="./templates")
    templateEnv = jinja2.Environment(
        loader=templateLoader, extensions=["jinja2.ext.do", "jinja2.ext.loopcontrols"]
    )
    templateEnv.filters["markdown"] = markup
    template = templateEnv.get_template(filename)
    return template.render(params), status_code


def markup(text: str, no_paragraph: bool = False):
    # == markdown ==
    mdc = Markup(md.convert(text))
    # == post ==
    if no_paragraph:
        if mdc.startswith("<p>"):
            mdc = mdc[3:]
        if mdc.endswith("</p>"):
            mdc = mdc[:-4]
    # print(mdc)
    mdc = '<a class="govuk-link" href'.join(mdc.split("<a href"))
    return mdc


def lambda_handler(event, context):
    try:
        response = alb_lambda_handler(event, context)
        if "headers" in response:
            if "cache-control" not in response["headers"]:
                response["headers"][
                    "cache-control"
                ] = "private, no-cache, no-store, max-age=0"
                response["headers"]["pragma"] = "no-cache"

        if "multiValueHeaders" in response:
            if "Cache-Control" not in response["multiValueHeaders"]:
                response["multiValueHeaders"]["Cache-Control"] = [
                    "private, no-cache, no-store, max-age=0"
                ]
                response["multiValueHeaders"]["pragma"] = ["no-cache"]

        print_obj = {
            "Request": event,
            "Response": {
                "statusCode": response["statusCode"],
                "headers": response["headers"]
                if "headers" in response
                else (
                    response["multiValueHeaders"]
                    if "multiValueHeaders" in response
                    else None
                ),
                "body_length": len(response["body"]),
            },
        }
        jprint(print_obj)
        return response
    except Exception as e:
        jprint({"Request": event, "Response": None, "Error": traceback.format_exc()})
        return {"statusCode": 500}


@app.route("/.well-known/hosting-provider")
@app.route("/.well-known/hosting-provider.txt")
@app.route("/hosting-provider.txt")
def route_hosting_provider():
    txt = f"""https://github.com/co-cddo/gccc-vrs-iac
https://aws.amazon.com/cloudfront/
https://www.hackerone.com/
"""

    resp = Response(txt, mimetype="text/plain")
    resp.headers["Cache-Control"] = "max-age=3600, public"

    return resp


@app.route("/.well-known/security.txt")
@app.route("/security.txt")
def security_txt():
    contact_url = f"{URL_PREFIX}/submit"
    ack_url = f"{URL_PREFIX}/acknowledgements"
    last_updated = datetime.utcnow().isoformat().split(".")[0] + "Z"
    expiry_date = (datetime.utcnow() + timedelta(days=93)).isoformat().split(".")[
        0
    ] + "Z"

    txt = f"""Policy: {URL_PREFIX}

Contact: {contact_url}

Acknowledgments: {ack_url}

Hiring: https://www.civilservicejobs.service.gov.uk/

Last-Updated: {last_updated}
Expires: {expiry_date}

# Generated using: https://github.com/co-cddo/gccc-vrs-iac
"""

    resp = Response(txt, mimetype="text/plain")
    resp.headers["Cache-Control"] = "max-age=604800, public"

    return resp


@app.route("/.well-known/lambda-status")
def health_check():
    return "IMOK"


@app.route("/submit", methods=["GET", "POST"])
@CheckCSRFSession
def route_submit():
    step = 1
    domain_sent = False
    vdp = None

    if request.method == "POST":
        button = request.form.get("button", "")
        if button == "continue":
            vdp = get_vdp_by_domain(request.form.get("domain", ""))
            if not vdp:
                step = 2
                domain_sent = True
        elif button == "skip":
            step = 2
            domain_sent = False
        elif button == "continue-org":
            vdp = get_vdp_by_id(
                id=request.form.get("organisation", ""), with_default=True
            )

        if vdp:
            step = 3

    return render(
        "submit.html",
        {
            "csrf_form": get_csrf_session(),
            "title": "Submit a report",
            "nav_item": "",
            "vdps": sorted(get_vdps(), key=itemgetter("organisation"))
            if step == 2
            else [],
            "vdp": vdp,
            "step": step,
            "domain_sent": domain_sent,
        },
    )


@app.route("/policy/<policy_raw>")
def route_policy(policy_raw: str):
    if policy_raw:
        policy = re.sub(r"[^A-Za-z0-9\-\_]+", "", policy_raw).lower()
        print("policy:", policy)
        fn = f"policy_{policy}.html"
        print("fn:", fn)
        print("exists:", os.path.exists(f"/templates/{fn}"))
        if os.path.exists(f"templates/{fn}"):
            return render(
                fn,
                {
                    "title": "Policy",
                    "nav_item": "",
                },
            )
    return redirect("/")


@app.route("/acknowledgements")
def route_acknowledgements():
    acknowledgements = []
    with open("acknowledgements.json") as af:
        for a in sorted(json.load(af), key=lambda kv: kv["date"], reverse=True):
            a["id"] = (
                a["date"] + "-" + re.sub(r"[^A-Za-z0-9\-]+", "", a["name"]).lower()[:10]
            )
            acknowledgements.append(a)

    return render(
        "acknowledgements.html",
        {
            "title": "Acknowledgements",
            "acknowledgements": acknowledgements,
            "nav_item": "",
        },
    )


@app.route("/government-organisations")
def route_gov_orgs():
    return render(
        "gov_orgs.html",
        {
            "title": "Government Organisations",
            "nav_item": "",
        },
    )


@app.route("/")
def route_root():
    return render(
        "index.html",
        {
            "title": "",
            "nav_item": "",
        },
    )


@app.route("/assets/<path:path>")
def route_assets(path):
    if os.path.isdir(werkzeug.utils.safe_join(assets, path)):
        path = os.path.join(path, "index.html")
    resp = make_response(send_from_directory(assets, path))
    resp.headers["Cache-Control"] = "max-age=604800, public"
    return resp


@app.route("/robots.txt")
def robot():
    txt = f"""User-agent: Googlebot
User-agent: AdsBot-Google
User-agent: AdsBot-Google-Mobile
{"Disallow: /" if ENVIRONMENT != 'PRODUCTION' else "Allow: /"}

User-agent: *
{"Disallow: /" if ENVIRONMENT != 'PRODUCTION' else "Allow: /"}
"""
    resp = Response(txt, mimetype="text/plain")
    resp.headers["Cache-Control"] = "max-age=604800, public"
    return resp
