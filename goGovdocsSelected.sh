#!/bin/bash

validateCommand=/usr/local/SCAPE/tools/pdfPolicyValidationDemo/pdfPolicyValidate.sh
dataDir=/usr/local/SCAPE/data/govdocs_selected/
schema=/usr/local/SCAPE/tools/pdfPolicyValidationDemo/schemas/pdf_policy_preflight_test.sch

$validateCommand $dataDir $schema