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

-- **errorcounts.py**: post-processing script that produces counts of unique (per analysed PDF) error codes and failed Schematron assertions 

## Command line use

#### Usage
    pdfPolicyValidate.sh rootDirectory policy

#### Positional arguments

`rootDirectory` : input directory tree

`policy` : schematron file that defines the policy (see example in the *schemas* directory)


### Output 
The script produces the following output files:

- **index.txt**: comma-delimited text file with for each analysed PDF the paths to the corresponding Preflight and Schematron output files
- **success.txt**: comma-delimited text file with for each analysed PDF the outcome of the policy-based validation (pass/fail)
- **failed.txt**:  text file with all tests that failed for PDFs that failed the policy-based validation

In addition, the raw output files of *Preflight* and the Schematron validation are written to directory *outRaw*.

#### Example

`pdfPolicyValidate.sh govdocs_selected pdf_policy_preflight_test.sch`
