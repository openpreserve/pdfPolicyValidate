<?xml version="1.0"?>
<!--
Schematron rules for policy-based  validation of PDF, based on output of Apache Preflight.
   
The current set of rules represents the following policy:
   * No encryption / password protection
   * All fonts are embedded and complete
   * No JavaScript
   * No embedded files (i.e. file attachments)
   * No multimedia content (audio, video, 3-D objects)
   * No PDFs that raise exception or result in processing error in Preflight (PDF validity proxy) 
   
All Preflight error codes are documented here:
   http://svn.apache.org/repos/asf/pdfbox/trunk/preflight/src/main/java/org/apache/pdfbox/preflight/PreflightConstants.java
   
See also:
   http://wiki.opf-labs.org/display/TR/Portable+Document+Format 
   
-->
<s:schema xmlns:s="http://purl.oclc.org/dsdl/schematron">
  <s:pattern name="Check for existence of Preflight element">
    <s:rule context="/">
      <s:assert test="preflight">No preflight element found</s:assert>
    </s:rule>
  </s:pattern>
   
  <s:pattern name="Check for Preflight exceptions">    
    <s:rule context="/preflight">
      <s:assert test="not(exceptionThrown)">Preflight raised an exception</s:assert>
    </s:rule>
  </s:pattern>

  <s:pattern name="Check for malformed PDF and general processing errors">    
    <s:rule context="/preflight/errors/error">
      <s:assert test="code != '8'">Processing error (possibly malformed PDF)</s:assert>
      <s:assert test="code != '8.1'">Missing mandatory element (possibly malformed PDF)</s:assert>
    </s:rule>
  </s:pattern>
  
  <s:pattern name="Checks for encryption">        
    <s:rule context="/preflight/errors/error">
      <s:assert test="code != '1.0' and not(contains(details,'password'))">Document is password-protected, requires open password </s:assert>
      <s:assert test="code != '1.4.2'">Document uses encryption</s:assert>
    </s:rule>
  </s:pattern>

  <s:pattern name="Check for font error, unspecified">   
    <s:rule context="/preflight/errors/error">  
      <s:assert test="code != '3'">Document contains fonts that resulted in unspecified font error</s:assert>
    </s:rule>
  </s:pattern>
  
  <s:pattern name="Checks for invalid or incomplete font dictionaries">   
    <s:rule context="/preflight/errors/error">  
      <s:assert test="code != '3.1'">Invalid data in font dictionary</s:assert>
      <s:assert test="code != '3.1.1'">Some mandatory fields are missing from the FONT Dictionary</s:assert>
      <s:assert test="code != '3.1.2'">Some mandatory fields are missing from the FONT Descriptor Dictionary</s:assert>
      <s:assert test="code != '3.1.3'">Error on the "Font File x" in the Font Descriptor</s:assert>
      <!-- Errors 4, 5 and 6 are common and apparently not serious, so you may want to comment them out -->
      <s:assert test="code != '3.1.4'">Charset declaration is missing in a Type 1 Subset</s:assert>
      <s:assert test="code != '3.1.5'">Encoding is inconsistent with the Font</s:assert>
      <s:assert test="code != '3.1.6'">Width array and Font program Width are inconsistent</s:assert>
      <!-- -->
      <s:assert test="code != '3.1.7'">Required entry in a Composite Font dictionary is missing</s:assert>
      <s:assert test="code != '3.1.8'">The CIDSystemInfo dictionary is invalid</s:assert>
      <s:assert test="code != '3.1.9'">The CIDToGID is invalid</s:assert>
      <s:assert test="code != '3.1.10'">The CMap of the Composite Font is missing or invalid</s:assert>
      <s:assert test="code != '3.1.11'">The CIDSet entry i mandatory from a subset of composite font</s:assert>
      <s:assert test="code != '3.1.12'">The CMap of the Composite Font is missing or invalid</s:assert>
      <s:assert test="code != '3.1.13'">Encoding entry can't be read due to IOException</s:assert>
      <s:assert test="code != '3.1.14'">The font type is unknown</s:assert>
    </s:rule>
  </s:pattern>

  <s:pattern name="Checks for damaged embedded fonts">   
    <s:rule context="/preflight/errors/error">  
      <s:assert test="code != '3.2'">The embedded font is damaged</s:assert>
      <s:assert test="code != '3.2.1'">The embedded Type1 font is damaged</s:assert>
      <s:assert test="code != '3.2.2'">The embedded TrueType font is damaged</s:assert>
      <s:assert test="code != '3.2.3'">The embedded composite font is damaged</s:assert>
      <s:assert test="code != '3.2.4'">The embedded type 3 font is damaged</s:assert>
      <s:assert test="code != '3.2.5'">The embedded CID Map is damaged</s:assert>
    </s:rule>
  </s:pattern>

  <s:pattern name="Checks for glyph errors">   
    <s:rule context="/preflight/errors/error">  
      <s:assert test="code != '3.3'">Common error for a Glyph problem</s:assert>
      <s:assert test="code != '3.3.1'">a glyph is missing</s:assert>
      <s:assert test="code != '3.3.2'">a glyph is missing</s:assert>
    </s:rule>
  </s:pattern>

  <s:pattern name="Check for JavaScript">   
    <s:rule context="/preflight/errors/error">   
      <s:assert test="code != '6.2.5' and not(contains(details,'JavaScript'))">Document contains JavaScript</s:assert>
    </s:rule>
  </s:pattern>

  <s:pattern name="Checks for embedded files and file attachments">   
    <s:rule context="/preflight/errors/error">    
      <s:assert test="code != '1.4.7'">Document contains embedded file(s)</s:assert>
      <s:assert test="code != '1.2.9'">Document contains embedded file(s)</s:assert>
    </s:rule>
  </s:pattern>
  
  <s:pattern name="Checks for multimedia content">   
    <s:rule context="/preflight/errors/error"> 
      <s:assert test="code != '5.2.1' and not(contains(details, 'Screen'))">Document contains Screen annotation</s:assert>
      <s:assert test="code != '5.2.1' and not(contains(details, 'Movie'))">Document contains Movie annotation</s:assert>
      <s:assert test="code != '5.2.1' and not(contains(details, 'Sound'))">Document contains Sound annotation</s:assert>
      <s:assert test="code != '5.2.1' and not(contains(details, '3D'))">Document contains 3D annotation</s:assert>
      <s:assert test="code != '6.2.5' and not(contains(details, 'Movie'))">Document contains Movie action</s:assert>
      <s:assert test="code != '6.2.5' and not(contains(details, 'Sound'))">Document contains Sound action</s:assert>
      <s:assert test="code != '6.2.6' and not(contains(details, 'undefined'))">Document contains action that is undefined in PDF/A-1 (e.g. Rendition)</s:assert>
    </s:rule>
  </s:pattern>     
  
  <!-- Optional: report any other Preflight errors as warnings, disabled for now (also this partially overlaps with above)
  <s:pattern name="Miscellaneous warnings">   
    <s:rule context="/preflight/errors/error">  
      <s:report test="starts-with(code,'1')">Syntax error(s)</s:report>
      <s:report test="starts-with(code,'2')">Graphics error(s)</s:report>
      <s:report test="starts-with(code,'3')">Font error(s)</s:report>
      <s:report test="starts-with(code,'4')">Transparency error(s)</s:report>
      <s:report test="starts-with(code,'5')">Annotation error(s)</s:report>
      <s:report test="starts-with(code,'6')">Action error(s)</s:report>
      <s:report test="starts-with(code,'7')">Metadata error(s)</s:report>     
    </s:rule>
  </s:pattern>
  -->
</s:schema>
