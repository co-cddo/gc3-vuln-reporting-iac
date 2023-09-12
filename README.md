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

### Route53 DNS

[dns](dns/) is the management of the Route53 zone and records.

Utilises the [aws-route53-parked-govuk-domain](https://github.com/co-cddo/aws-route53-parked-govuk-domain) Terraform module for _parking_ the email records.
