#! /usr/bin/env python

# This script computes counts of both errors reported by Apache Preflight, as well as
# failed Schematron assertions. 
# Johan van der Knijff, KB/ National Library of the Netherlands
#

import imp
import os
import sys
import xml.etree.ElementTree as ET
import argparse
import collections


def main_is_frozen():
    return (hasattr(sys, "frozen") or # new py2exe
            hasattr(sys, "importers") # old py2exe
            or imp.is_frozen("__main__")) # tools/freeze
    
def get_main_dir():
    if main_is_frozen():
        return os.path.dirname(sys.executable)
    return os.path.dirname(sys.argv[0])

def errorExit(msg):
    msgString=("ERROR: " +msg + "\n")
    sys.stderr.write(msgString)
    sys.exit()
    
def checkFileExists(fileIn):
    # Check if file exists and exit if not
    if os.path.isfile(fileIn)==False:
        msg=fileIn + " does not exist!"
        errorExit(msg)

def addPath(pathIn,fileIn):
    result=os.path.normpath(pathIn+ "/" + fileIn)
    return(result)

def parseCommandLine():
    # Create parser
    parser = argparse.ArgumentParser(description="Post-process failure file of PDF policy-based validation demo script ")
 
    # Add arguments
    parser.add_argument('fileIn', action="store", help="input file")
    
    # Parse arguments
    args=parser.parse_args()
    
    # Normalise all file paths
    args.fileIn=os.path.normpath(args.fileIn)
    
    return(args)
    
def getErrorsExceptions(preflightXML):
    
    # Parse Preflight's output and return all errors and exceptions as a dictionary
       
    errorsDictionary = collections.defaultdict(list)
    exceptionsDictionary=collections.defaultdict(list)
       
    # Parse preflight XML output and extract error messages
    try:
        tree=ET.parse(preflightXML)
        root = tree.getroot()
        errorsElt = root.find('errors')
        exceptionsElt = root.find('exceptionThrown')
        
        if exceptionsElt != None:
            # Loops over 'exceptionThrown' element
            for element in exceptionsElt:
                if element.tag == 'message':
                    message = element.text
                    exceptionsDictionary["Exception"].append(message)
        
        if errorsElt != None:
            # Loops over 'error' elements
            for element in errorsElt:
                # Loop over items within each 'error' element
                for subelement in element:
                    if subelement.tag == 'code':
                        code = subelement.text
                    elif subelement.tag == 'details':
                        details = subelement.text
                        
                # Error codes + details go to dictionary, so we can sort them later
                # Each item is a list, because each error code can have multiple occurrences with
                # different reported details
                               
                errorsDictionary[code].append(details)
                                        
    except:
        errorExit("Unexpected error: " + str(sys.exc_info()[0]))
      
    # Merge exceptions and errors dictionaries
    errorsExceptions = dict(list( errorsDictionary.items()) + list(exceptionsDictionary.items()))
    
    return(errorsExceptions)    

def getFailedAssertions(schematronXML):
    
    # Parse Schematron output and return list with text descriptions of all failed assertions
    
    failedAssertions=[]
    
    try:
        tree=ET.parse(schematronXML)
        root = tree.getroot()
        
        # Loop over all elements in root and collect all text in 'failed-assert/text' elements
        for element in root:
            if element.tag == '{http://purl.oclc.org/dsdl/svrl}failed-assert':
                for subelement in element:
                    if subelement.tag == '{http://purl.oclc.org/dsdl/svrl}text':
                        failedAssertText = subelement.text
                        failedAssertions.append(failedAssertText)
    
    except:
        pass
    
    return(failedAssertions)

    
def main():

    # What is the location of this script/executable
    appPath=os.path.abspath(get_main_dir())

    # Get input from command line 
    args=parseCommandLine()
    fileIn=args.fileIn
            
    # Check if fileIn exists, and exit if not
    checkFileExists(fileIn)
    
    # Input file is CSV file with for each line:
    #  Item 1: full path to PDF file
    #  Item 2: full path to Apache Preflight output
    #  Item 3: full path to Schematron output
    f = open(fileIn, 'r')
    lines=f.readlines()
    f.close()
   
    # Below lists will contain all reported *unique* Prelight validation errors and failed assertions for each file
    preflightErrorsAllFiles=[] 
    failedAssertionsAllFiles=[]
        
    # Main processing loop; each line represents one analysed PDF
    
    for line in lines:
        line = line.strip()
        lineItems = line.split(',')
        pathPdf = lineItems[0]
        pathPreflightFile = lineItems[1]
        pathSchematronFile = lineItems[2]
        
        # Preflight errors
        
        try:
        
            # Dictionary with all Preflight error codes, exceptions and error descriptions
            preflightErrorsExceptions = getErrorsExceptions(pathPreflightFile)
      
            # Extract error *codes* (incl. "Exception" keyword) to a list 
            preflightErrorCodesExceptions = [k for k, v in preflightErrorsExceptions.items()]
        
            # Remove duplicates
            preflightErrorCodesExceptions = list(set(preflightErrorCodesExceptions))
        
            # Append to preflightErrorsAllFiles    
            for item in preflightErrorCodesExceptions:
                preflightErrorsAllFiles.append(item)
        
        except:
            pass
        
        # Failed Schematron assertions
        
        try:
           
            # List with all failed Schematron assertions
            failedAssertions = getFailedAssertions(pathSchematronFile)
            
            # Remove duplicates
            failedAssertions = list(set(failedAssertions))
            
            # Append to failedAssertionsAllFiles
            for item in failedAssertions:
                failedAssertionsAllFiles.append(item)
        except:
            pass
    
    # Count occurrences for each error/exception
    errorOccurrences=collections.Counter(preflightErrorsAllFiles)
    errorOccurencesCounts=errorOccurrences.most_common()
    
    # Same for failed assertions
    failedAssertionOccurrences=collections.Counter(failedAssertionsAllFiles)
    failedAssertionOccurrencesCounts=failedAssertionOccurrences.most_common()
    
    # Write results to file    
    f = open("preflightErrorCounts.csv", 'w')
    for item in errorOccurencesCounts:
        f.write(item[0] + ','  + str(item[1]) + "\n")
    f.close()
    
    f = open("failedAssertCounts.csv", 'w')
    for item in failedAssertionOccurrencesCounts:
        f.write('"' + item[0] + '",'  + str(item[1]) + "\n")
    f.close()
    
main()