#PDF policy-based validation demo

## About

Simple shell script that demonstrates policy-based validation of PDF documents using [Apache Preflight](http://pdfbox.apache.org/) and Schematron. Each file with a .pdf extension in a user-defined directory tree is analysed with Apache Preflight, and the Preflight output is subsequently validated against a  user-specified schema (which represents a policy). Schematron validation is done using the [ISO Schematron "unofficial" reference implementation](http://code.google.com/p/schematron/) (included here in directory *iso-schematron-xslt1*) and the [xsltproc](http://xmlsoft.org/XSLT/xsltproc2.html) tool.

Development partially supported by the [SCAPE](http://www.scape-project.eu/) Project. The SCAPE project is co-funded by the European Union under FP7 ICT-2009.4.1 (Grant Agreement number 270137).

## Author
Johan van der Knijff, KB/National Library of the Netherlands

## Dependencies
- *java* (version?)
- JAR of *Apache Preflight* (2.0), get it from: [https://builds.apache.org/job/PDFBox-trunk/lastBuild/org.apache.pdfbox$preflight/](https://builds.apache.org/job/PDFBox-trunk/lastBuild/org.apache.pdfbox$preflight/)
- *xsltproc* tool (part of [libxslt](http://xmlsoft.org/XSLT/EXSLT/index.html) library)
- *xmllint* tool (part of [libxml](http://www.xmlsoft.org/)library)
- *realpath* tool

Depending on the Linux distribution you're using you may already have some (or all) of these tools on your system.

If you're using Windows you can run this shell script within a [Cygwin](http://www.cygwin.com/) terminal.

##Contents of this repo

- **pdfPolicyValidate.sh**: demo script

- **iso-schematron-xslt1**: "unofficial" reference implementation of ISO Schematron, taken from [http://code.google.com/p/schematron/](http://code.google.com/p/schematron/)

- **schemas**: example schemas (currently only one)

- **errorcounts.py**: post-processing script that produces counts of unique (per analysed PDF) error codes and failed Schematron assertions

- **goGovdocsSelected.sh**: demonstrates combined use of *pdfPolicyValidate.sh* and *errorcounts.py*

## Command line use

#### Usage
    pdfPolicyValidate.sh rootDirectory policy

#### Positional arguments

`rootDirectory` : input directory tree

`policy` : schematron file that defines the policy (see example in the *schemas* directory)

### Output 
The script produces the following output files:

- **index.csv**: comma-delimited text file with for each analysed PDF the paths to the corresponding Preflight and Schematron output files
- **success.csv**: comma-delimited text file with for each analysed PDF the outcome of the policy-based validation (pass/fail)
- **failed.csv**:  text file with all tests that failed for PDFs that failed the policy-based validation

In addition, the raw output files of *Preflight* and the Schematron validation are written to directory *outRaw*. You should use *index.csv* to link each of these files to their corresponding *PDF*. 

#### Example

`pdfPolicyValidate.sh govdocs_selected pdf_policy_preflight_test.sch`

## Post-processing
The *errorcounts.py* script analyses the output of the above script, and calculates counts of reported Preflight errors and failed Schematron assertions.

### Usage
     python errorcounts.py fileIn

where *fileIn* is the index file (*index.csv*). 

### Example
     python errorcounts.py index.csv

### Output
The script writes its results to two comma-separated files:

- **preflightErrorCounts.csv**: counts of each error code reported by Preflight (ascending order). Example:

<pre>
2.4.3,10309
7.1,6901
1.2.1,5932
2.4.1,5018
1.4.6,4311
1.2.5,4172
3.1.2,4096
7.11,4075
3.1.3,3773
</pre>

- **failedAssertCounts.csv**: counts of each failed Schematron assertion (ascending order). Example:

<pre>
"Mandatory fields missing from font descriptor dictionary",4096
"Error in font descriptor",3773
"Mandatory fields missing from font dictionary",3558
"Missing CIDSet entry in subset of composite font",960
"Encoding inconsistent with font",894
"Preflight exception",871
"Invalid CIDToGID",709
"Charset declaration missing in Type 1 subset",695
</pre>

Note that for both files the counts are based on *unique* error codes / failed assertions per *PDF*. This means that if, for example, a *PDF* results in 8 occurrences of error *3.1.2*, it only increases the error count in *preflightErrorCounts.csv* by 1.

##Funding
This work was partially supported by the [SCAPE](http://www.scape-project.eu/) Project. The SCAPE project is co-funded by the European Union under FP7 ICT-2009.4.1 (Grant Agreement number 270137).

 