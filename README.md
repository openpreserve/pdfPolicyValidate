#PDF policy-based validation demo

## About

Simple shell script that demonstrates policy-based validation of PDF documents using [Apache Preflight](http://pdfbox.apache.org/) and Schematron. Each file with a .pdf extension in a user-defined directory tree is analysed with Apache Preflight, and the Preflight output is subsequently validated against a  user-specified schema (which represents a policy). Schematron validation is done using the [ISO Schematron "unofficial" reference implementation](http://code.google.com/p/schematron/) (included here in directory *iso-schematron-xslt1*) and the [xsltproc](http://xmlsoft.org/XSLT/xsltproc2.html) tool.

Development partially supported by the [SCAPE](http://www.scape-project.eu/) Project. The SCAPE project is co-funded by the European Union under FP7 ICT-2009.4.1 (Grant Agreement number 270137).

## Author
Johan van der Knijff, KB/National Library of the Netherlands

## Dependencies
 - java (version?)
 - JAR of Apache Preflight (2.0), get it from: [https://builds.apache.org/job/PDFBox-trunk/lastBuild/org.apache.pdfbox$preflight/](https://builds.apache.org/job/PDFBox-trunk/lastBuild/org.apache.pdfbox$preflight/)
- xsltproc tool (part of [libxslt](http://xmlsoft.org/XSLT/EXSLT/index.html) library)
 - If you're using Windows you can run this shell script within a [Cygwin](http://www.cygwin.com/) terminal.

##Contents of this repo

- **pdfPolicyValidate.sh**: demo script

- **iso-schematron-xslt1**: "unofficial" reference implementation of ISO Schematron, taken from [http://code.google.com/p/schematron/](http://code.google.com/p/schematron/)

- **schemas**: example schemas (currently only one)

## Command line use

#### Usage
    pdfPolicyValidate.sh rootDirectory policy

#### Positional arguments

`rootDirectory` : input directory tree

`policy` : schematron file that defines the policy (see example in the *schemas* directory)


### Output 
For now both *Preflight* output and the output of the *Schematron* validation are written to the directory from which the script is executed, using a naming scheme based on an incremental numerical counter. This will obviously change with upcoming versions.


#### Example

`pdfPolicyValidate.sh govdocs_selected pdf_policy_preflight_test.sch`
