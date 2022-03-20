<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:eac="https://archivists.org/ns/eac/v2"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    
    <sch:ns uri="http://www.loc.gov/mads/rdf/v1#" prefix="madsrdf"/>
    
    <!-- consider adding something for namespace switching, between EAD and EAC -->
    
    <xsl:variable name="supported-language-codes" as="element()*">
        <language value="iso639-1" filename="iso639-1.rdf"/>
        <language value="iso639-2b" filename="iso639-2.rdf"/>
        <language value="iso639-3" filename="iso639-3.xml"/>
        <!-- ietf-bcp-47 -->
    </xsl:variable>
    
    <!-- VARIABLE $language-code-key: the EAD3 document's /ead:ead/ead:control/@langencoding, with iso639-2b as a default value. -->
    <sch:let name="active-language-code-key" value="(*/*:control/@languageEncoding[.=$supported-language-codes/@value], 'iso639-2b')[1]"/>
    
    <!-- still need to add something here to distinguish between active and deprecated codes -->
    <!-- and will also need a functional way, or ability to hit an API endpoint, to test for ietf-bcp-47 codes, most likely -->
    <sch:let name="valid-language-codes" value="document($supported-language-codes[@value = $active-language-code-key]/@filename)//(madsrdf:code | iso_639_3_entries/iso_639_3_entry/@id)"/>
    
    <!-- until we have a better way with dealing with "other" as a value, etc.-->
    <sch:let name="check-language-codes" value="if (*/*:control/@languageEncoding = ('otherLanguageEncoding', 'ietf-bcp-47')) then false() else true()"/>
    <sch:let name="check-ietf-codes" value="if (*/*:control[@languageEncoding eq 'ietf-bcp-47']) then true() else false()"/>
    <sch:let name="check-country-codes" value="if (*/*:control/@countryEncoding eq 'otherCountryEncoding') then false() else true()"/>
    <sch:let name="check-script-codes" value="if (*/*:control/@scriptEncoding eq 'otherScriptEncoding') then false() else true()"/>
    <sch:let name="check-repository-codes" value="if (*/*:control/@repositoryEncoding eq 'otherRepositoryEncoding') then false() else true()"/>
    
    <!-- VARIABLE iso15511Pattern -->
    <sch:let name="iso15511Pattern" value="'(^([A-Z]{2})|([a-zA-Z]{1})|([a-zA-Z]{3,4}))(-[a-zA-Z0-9:/\-]{1,11})$'"/>
    
    <sch:let name="ietfPattern" value="'^[A-Za-z]{2,4}([_-][A-Za-z]{4})?([_-]([A-Za-z]{2}|[0-9]{3}))?$'"/>
    
    
    <!-- LANGUAGE CODE TESTS (in process) -->
    <sch:pattern>
        <sch:rule context="*[exists(@languageCode | @languageOfElement)][$check-language-codes]">
            <!-- for every @lang or @langcode attribute, test that it is equal to a value in the relevant language code list -->
            <sch:assert test="every $l in (@languageCode | @languageOfElement) satisfies normalize-space($l) = $valid-language-codes">The <sch:name/> element's lang or langcode attribute should contain a value from the <xsl:value-of select="$active-language-code-key"/> codelist.</sch:assert>
        </sch:rule>
        
        <sch:rule context="*[exists(@languageCode | @languageOfElement)][$check-ietf-codes]">
            <!-- for every @lang or @langcode attribute, test that it is equal to a value in the relevant language code list -->
            <sch:assert test="every $l in (@languageCode | @languageOfElement) satisfies matches(normalize-space($l), $ietfPattern)">The <sch:name/> element's lang or langcode attribute should contain a value from the 'ietf-bcp-47' codelist.</sch:assert>
        </sch:rule>
    </sch:pattern>
     
    <!-- COUNTRY CODES (in process) -->
    <sch:pattern>
        <sch:let name="countryCodes" value="document('iso_3166.xml')"/>
        <sch:rule context="*[exists(@countryCode)][$check-country-codes]">
            <sch:let name="code" value="normalize-space(@countryCode)"/>
            <sch:assert test="$countryCodes//iso_3166_entry/@alpha_2_code = $code">The countrycode attribute should contain a code from the ISO 3166-1 codelist.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- SCRIPT CODES (in process) -->
    <sch:pattern>
        <sch:let name="scriptCodes" value="document('iso_15924.xml')"/>
        <sch:rule context="*[exists(@scriptCode | @scriptOfElement)][$check-script-codes]">
            <sch:let name="code" value="normalize-space(.)"/>
            <sch:assert test="every $s in (@scriptCode | @scriptOfElement) satisfies $scriptCodes//iso_15924_entry/@alpha_4_code = $s"> The script or scriptcode attribute should contain a code from the iso_15924 codelist.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- REPOSITORY CODES (in process; also need a test for agency codes and ISIL?) -->
    <sch:pattern>
        <sch:rule context="*[@repositoryCode][$check-repository-codes]">
            <sch:assert test="matches(@repositoryCode, $iso15511Pattern)">If the repositoryencoding is set to iso15511, the format of the value of the <sch:emph>repositorycode</sch:emph> attribute of <sch:name/> is constrained to that of the International Standard Identifier for Libraries and Related Organizations (ISIL: ISO 15511): a prefix, a dash, and an identifier.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    
    <!-- ID UNIQUENESS / IDREF CONSTRAINTS, for RNG -->
    <sch:pattern>
        <sch:rule context="*[@id]">
            <sch:assert test="count(//*/@id[. = current()/@id]) = 1">This element does not have a unique value for its 'id' attribute.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- REFERENCE + TARGET ATTRIBUTE TESTS -->
    <sch:pattern>
        <sch:rule context="*[@conventionDeclarationReference]">
            <sch:assert test="every $ref in tokenize(@conventionDeclarationReference, ' ') satisfies $ref = (/*/*:control[1]/*:conventionDeclaration/@id)">
                When you use the conventionDeclarationReference attribute, it must be linked to a conventionDeclaration element.
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern>
        <sch:rule context="*[@localTypeDeclarationReference]">
            <sch:assert test="every $ref in tokenize(@localTypeDeclarationReference, ' ') satisfies $ref = (/*/*:control[1]/*:localTypeDeclaration/@id)">
                When you use the localTypeDeclarationReference attribute, it must be linked to a localTypeDeclaration element.
            </sch:assert>
        </sch:rule>  
    </sch:pattern>
    
    <sch:pattern>
        <sch:rule context="*[@maintenanceEventReference]">
            <sch:assert test="every $ref in tokenize(@maintenanceEventReference, ' ') satisfies $ref = (/*/*:control[1]/*:maintenanceHistory[1]/*:maintenanceEvent/@id)">
                When you use the maintenanceEventReference attribute, it must be linked to a maintenanceEvent element.
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern>
        <sch:rule context="*[@sourceReference]">
            <sch:assert test="every $ref in tokenize(@sourceReference, ' ') satisfies $ref = (/*/*:control[1]/*:sources[1]/*:source/@id, /*/*:control[1]/*:sources[1]/*:source/*:citedRange/@id)">
                When you use the sourceReference attribute, it must be linked to a source or citedRange element.
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern>
        <sch:rule context="*[@target]">
            <sch:assert test="every $target in tokenize(@target, ' ') satisfies $target = (//*/@id)">
                When you use the target attribute, it must be linked to another element by means of the id attribute.
            </sch:assert>
        </sch:rule>
    </sch:pattern>
       
    <!-- CO-OCCURENCE CONSTRAINTS -->
    <sch:pattern id="maintenanceAgency-constraints">
        <sch:rule context="*:maintenanceAgency[*:agencyCode[not(normalize-space())]] | *:maintenanceAgency[not(*:agencyCode)]">
            <sch:assert test="*:agencyName[normalize-space()]">The maintenanceAgency element requires either an agencyCode or agencyName element that cannot be empty.</sch:assert>
        </sch:rule>
        <sch:rule context="*:maintenanceAgency[*:agencyName[not(normalize-space())]] | *:maintenanceAgency[not(*:agencyName)]">
            <sch:assert test="*:agencyCode[normalize-space()]">The maintenanceAgency element requires either an agencyCode or agencyName element that cannot be empty.</sch:assert>
        </sch:rule>
    </sch:pattern>
  
    <sch:pattern id="eventDateTime">
        <sch:rule context="/*/*:control/*:maintenanceHistory/*:maintenanceEvent/*:eventDateTime[not(@standardDateTime)]">
            <sch:assert test="normalize-space()">The eventDateTime element requires either a standardDateTime attribute or text.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- DATES -->
    <sch:pattern>
        <sch:rule context="*:date[@era] | *:toDate[@era] | *:fromDate[@era]">
            <sch:assert test="@era = ('ce', 'bce')">Suggested values for the era attribute are 'ce' or 'bce'</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- DATE NORMALIZATION -->
    <!-- will need to update considerably, still.  iso 8601 2019 possiblities are quite different...
        also, we will need to be clear that we don't support all values of iso 8601.  
        -->
    <sch:pattern id="dates">
        <!-- without using the ETDF parts of ISO 8601 2019, years are capped as such, it looks like...-->
        <sch:let name="isoYYYY" value="'\-?(0|1|2)([0-9]{3})'"/>
        <sch:let name="isoMM" value="'\-?(01|02|03|04|05|06|07|08|09|10|11|12)'"/>
        <sch:let name="isoDD" value="'\-?((0[1-9])|((1|2)[0-9])|(3[0-1]))'"/>
        <sch:let name="isoPattern" value="concat('^', $isoYYYY, '$','|', '^', $isoYYYY, $isoMM,'$', '|', '^', $isoYYYY, $isoMM, $isoDD,'$')"/>
        <sch:rule context="*:date[exists(@notBefore | @notAfter | @standardDate)] | *:toDate[exists(@notBefore | @notAfter | @standardDate)] | *:fromDate[exists(@notBefore | @notAfter | @standardDate)]">
            <sch:assert test="every $d in (@notBefore, @notAfter, @standardDate) satisfies matches($d, $isoPattern)">The <sch:emph>notBefore</sch:emph>, <sch:emph>notAfter</sch:emph>, and <sch:emph>standardDate</sch:emph> attributes of <sch:name/> must be a iso8601 date.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
</sch:schema>
