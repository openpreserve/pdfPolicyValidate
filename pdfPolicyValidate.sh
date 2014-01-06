#!/bin/bash

# Simple demo script that demonstrates minimal workflow for policy-based validation of PDF documents 
# using Apache Preflight and Schematron.
#
# Each file with a .pdf extension in the directory tree is analysed with Apache Preflight, 
# and the Preflight output is subsequently validated against a  user-specified schema (which represents a policy).
#
# Author: Johan van der Knijff, KB/National Library of the Netherlands
#
# Dependencies and requirements:
#
# - java
# - JAR of Apache Preflight (2.0) - get it from:
#        https://builds.apache.org/job/PDFBox-trunk/lastBuild/org.apache.pdfbox$preflight/
# - xsltproc (part of libxslt library)
# - xmllint (part of libxml library)
# - realpath tool
# - If you're using Windows you can run this shell script within a Cygwin terminal: http://www.cygwin.com/

# **************
# CONFIGURATION
# **************

# Location of  Preflight jar -- update according to your local installation!
preflightJar=C:/preflight/preflight-app-2.0.0-20140105.170147-103.jar

# Do not edit anything below this line (unless you know what you're doing) 

# Installation directory
instDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Location of Schematron XSL files
xslPath=$instDir/iso-schematron-xslt1

# **************
# USER I/O
# **************

# Check command line args
if [ "$#" -ne 2 ] ; then
  echo "Usage: pdfPolicyValidate.sh rootDirectory policy" >&2
  exit 1
fi

if ! [ -d "$1" ] ; then
  echo "rootDirectory must be a directory" >&2
  exit 1
fi

if ! [ -f "$2" ] ; then
  echo "policy must be a file" >&2
  exit 1
fi

# PDF root directory
pdfRoot="$1"

# Schema
schema="$2"

# **************
# CREATE OUTPUT DIRECTORY FOR RAW PREFLIGHT / SCHEMATRON FILES
# **************
rawDir="outRaw"
if ! [ -d $rawDir ] ; then
    mkdir $rawDir
fi

# Normalise to absolute path
rawDir=$(realpath ./$rawDir)

# **************
# OUTPUT FILES
# **************

# Links each PDF to corresponding Preflight / Schematron output file
indexFile="index.txt"

# File with results (pass/fail) of policy-based validation for each PDF 
successFile="success.txt"

# File that summarises failed tests for PDFs that didn't pass policy-based validation
failedTestsFile="failed.txt" 

# Remove these files if they exist already (writing to them will be done in append mode!)

if [ -f $indexFile ] ; then
    rm $indexFile
fi

if [ -f $successFile ] ; then
    rm $successFile
fi

if [ -f $failedTestsFile ] ; then
    rm $failedTestsFile
fi

# **************
# MAIN PROCESSING LOOP
# **************

counter=0

# Select all files with extension .pdf
for i in $(find $pdfRoot -type f -name *.pdf)
do
    pdfName="$i"
    counter=$((counter+1))
    
    # Generate names for output files, based on counter
    outputPreflight=$rawDir/"$counter"_preflight.xml
    outputSchematron=$rawDir/"$counter"_schematron.xml
    
    # Run Preflight
    java -jar $preflightJar xml $pdfName >$outputPreflight 2>tmp.stderr
    
    # Validate output using Schematron reference application
    if [ $counter == "1" ]; then
        # We only need to generate xx1.sch, xx2.sch and xxx.xsl once
        xsltproc --path $xslPath $xslPath/iso_dsdl_include.xsl $schema > xxx1.sch
        xsltproc --path $xslPath $xslPath/iso_abstract_expand.xsl xxx1.sch > xxx2.sch
        xsltproc --path $xslPath $xslPath/iso_svrl_for_xslt1.xsl xxx2.sch > xxx.xsl
    fi
    
    xsltproc --path $xslPath xxx.xsl $outputPreflight > $outputSchematron
    
    # Extract failed tests from Schematron output
    
    # Line below extracts literal test
    #failedTests=$(xmllint --xpath "//*[local-name()='schematron-output']/*[local-name()='failed-assert']/@test" $outputSchematron)
    
    # Line below extracts text description of failed tests (each wrapped in <svrl:text> element)
    failedTests=$(xmllint --xpath "//*[local-name()='schematron-output']/*[local-name()='failed-assert']/*[local-name()='text']" $outputSchematron)
    
    # PDF passed policy-based validation if failedTests is empty 
    if [ ! "$failedTests" ]
    then
        success="Pass"
    else
        success="Fail"
        # Failed tests to output file
        echo $pdfName,$failedTests >> $failedTestsFile
    fi
    
    # Write index file (links Preflight and Schematron outputs to each PDF)
    echo $pdfName,$outputPreflight,$outputSchematron >> $indexFile
    
    # Write success file (lists validation outcome for each PDF)
    echo $pdfName,$success >> $successFile
    
done

# **************
# CLEAN-UP
# **************
rm xxx1.sch
rm xxx2.sch
rm xxx.xsl
rm tmp.stderr