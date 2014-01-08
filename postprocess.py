#! /usr/bin/env python3

# Analyse user-defined set of PDF documents with Apache Preflight and return results
# as formatted table in Markdown (PHP Extra) or Atlassian Confluence Wiki format
# Johan van der Knijff, KB/ National Library of the Netherlands
#

import imp
import os
import sys
import xml.etree.ElementTree as ET
import subprocess as sub
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
    
    errorsDictionary = defaultdict(list)
    exceptionsDictionary=defaultdict(list)
       
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

    
def main():

    # Get input from command line
    args=parseCommandLine()
    fileIn=args.fileIn

    # Configuration

    # What is the location of this script/executable
    appPath=os.path.abspath(get_main_dir())
            
    # Check if fileIn exists, and exit if not
    checkFileExists(fileIn)
   
    # This list will contain all reported *unique* errors for each file
    errorsListAllFiles=[]
    
    noFiles=0
   
    try:
        tree=ET.parse(fileIn)
        root = tree.getroot()
        
        # Loop over 'file' elements
        for element in root:
            #Initialise list that will hold all errors for this file
            errorsListOneFile=[]
            noFiles +=1
            # Loop over 'text' elements
            for subelement in element:
                if subelement.tag == '{http://purl.oclc.org/dsdl/svrl}text':
                    errorMessage = subelement.text
                    errorsListOneFile.append(errorMessage)
                
            # Remove duplicates
            errorsListOneFileCleaned = list(set(errorsListOneFile))
                
            #print(errorsListOneFileCleaned)
                
            # Append errors to errorsListAllFiles
                
            for item in errorsListOneFileCleaned:
                errorsListAllFiles.append(item)
                        
        # Count occurrences for each error
        errorOccurrences=collections.Counter(errorsListAllFiles)
        occurencesCounts=errorOccurrences.most_common()
        
        # Print output
        
        # Header
        print("Error,count")
        
        for item in occurencesCounts:
            print('"' + item[0] + '",'  + str(item[1]))
         
    except:
        print "Unexpected error:", sys.exc_info()[0]
        pass      
main()