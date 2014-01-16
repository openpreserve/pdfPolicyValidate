#!/bin/bash

validateCommand=/usr/local/SCAPE/tools/pdfPolicyValidationDemo/pdfPolicyValidate.sh
countCommand=/usr/local/SCAPE/tools/pdfPolicyValidationDemo/errorcounts.py

dataDir=/usr/local/SCAPE/data/govdocs_selected/
schema=/usr/local/SCAPE/tools/pdfPolicyValidationDemo/schemas/pdf_policy_preflight_test.sch

$validateCommand $dataDir $schema >validation.stdout 2>validation.stderr

indexFile=./index.csv

$countCommand $indexFile >count.stdout 2> count.stderr
