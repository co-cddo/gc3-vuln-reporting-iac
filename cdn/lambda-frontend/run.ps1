#!/usr/bin/env pwsh

$env:ENVIRONMENT="development"
$env:FLASK_ENV="development"
$env:FLASK_APP="main.py"
$env:PHASE_BANNER="dev"

python -m flask run --host 0.0.0.0 --port 5005
