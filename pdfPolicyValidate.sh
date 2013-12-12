#!/bin/bash

# Simple demo script that demonstrates policy-based validation of PDF documents using Apache Preflight
# and Schematron. Each file with a .pdf extension in the directory tree is analysed with Apache Preflight, 
# and the Preflight output is subsequently validated against a  user-specified schema (which represents a policy)
#
# Author: Johan van der Knijff, KB/National Library of the Netherlands
#
# Dependencies and requirements:
#
# - java
# - JAR of Apache Preflight (2.0) - get it from:
#        https://builds.apache.org/job/PDFBox-trunk/lastBuild/org.apache.pdfbox$preflight/
# - xsltproc (part of libxslt library)
# - If you're using Windows you can run this shell script within a Cygwin terminal: http://www.cygwin.com/

# **************
# CONFIGURATION
# **************

# Location of  Preflight jar -- update according to your local installation!
preflightJar=C:/preflight/preflight-app.jar

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
# MAIN PROCESSING LOOP
# **************

counter=0

# Select all files with extension .pdf
for i in $(find $pdfRoot -type f -name *.pdf)
do
    counter=$((counter+1))
    
    outputPreflight="$counter"_preflight.xml
    fileOut="$counter".xml
    
    # Run Preflight
    java -jar $preflightJar xml "$i" >$outputPreflight
    
    # Validate output using Schematron reference application
    if [ $counter == "1" ]; then
        # We only need to generate xx1.sch, xx2.sch and xxx.xsl once
        xsltproc --path $xslPath $xslPath/iso_dsdl_include.xsl $schema > xxx1.sch
        xsltproc --path $xslPath $xslPath/iso_abstract_expand.xsl xxx1.sch > xxx2.sch
        xsltproc --path $xslPath $xslPath/iso_svrl_for_xslt1.xsl xxx2.sch > xxx.xsl
    fi
    
    xsltproc --path $xslPath xxx.xsl $outputPreflight > $fileOut
        
done

# **************
# CLEAN-UP
# **************
rm xxx1.sch
rm xxx2.sch
rm xxx.xsl