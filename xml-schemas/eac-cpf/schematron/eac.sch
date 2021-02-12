<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:eac="https://archivists.org/ns/eac/v2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    
    <!-- ID UNIQUENESS / IDREF CONSTRAINTS, for RNG -->
    <sch:pattern>
        <sch:rule context="*[@id]">
            <sch:assert test="count(//*/@id[. = current()/@id]) = 1">This element does not have a unique value for its 'id' attribute.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
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
    
    <!-- do we need to enforce the inverse, as well? -->
    <!-- commenting this rule out for now since it makes all of the connverted documents invalid, which isn't fair :) 
    <sch:pattern id="localType-containts">
        <sch:rule context="*[@localType]">
            <sch:assert test="@localTypeDeclarationReference">Whenever @localType is used, then the @localTypeDeclarationReference attribute should also be used to point to the localTypeDeclaration section within control.</sch:assert>
        </sch:rule>
    </sch:pattern>
    -->
    
    <sch:pattern id="eventDateTime">
        <sch:rule context="/*/*:control/*:maintenanceHistory/*:maintenanceEvent/*:eventDateTime[not(@standardDateTime)]">
            <sch:assert test="normalize-space()">The eventDateTime element requires either a standardDateTime attribute or text.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    
    <!-- DATES -->
    <sch:pattern>
        <sch:rule context="*:date[@era] | *:toDate[@era] | *:fromDate[@era]">
            <sch:assert test="@era = ('ce', 'bce')"> Suggested values for the era attribute are 'ce' or 'bce'</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- will need to update this to work with some varition of the newer ISO8601, which supports some levels of EDTF -->
    <!-- e.g.  https://digital2.library.unt.edu/edtf/ -->
    <!-- also, this needs to change, since it doesn't support valid iso8601 dates, like -33241, etc. (nor does the UNT service) -->
    <!--
    <sch:pattern id="dates">
        <sch:let name="isoYYYY" value="'\-?(0|1|2)([0-9]{3})'"/>
        <sch:let name="isoMM" value="'\-?(01|02|03|04|05|06|07|08|09|10|11|12)'"/>
        <sch:let name="isoDD" value="'\-?((0[1-9])|((1|2)[0-9])|(3[0-1]))'"/>
        <sch:let name="isoRangePattern" value="concat('^', '(\-?(0|1|2)([0-9]{3})(((01|02|03|04|05|06|07|08|09|10|11|12)((0[1-9])|((1|2)[0-9])|(3[0-1])))|\-((01|02|03|04|05|06|07|08|09|10|11|12)(\-((0[1-9])|((1|2)[0-9])|(3[0-1])))?))?)(/\-?(0|1|2)([0-9]{3})(((01|02|03|04|05|06|07|08|09|10|11|12)((0[1-9])|((1|2)[0-9])|(3[0-1])))|\-((01|02|03|04|05|06|07|08|09|10|11|12)(\-((0[1-9])|((1|2)[0-9])|(3[0-1])))?))?)?', '$')"/>
        <sch:let name="isoPattern" value="concat('^', $isoYYYY, '$','|', '^', $isoYYYY, $isoMM,'$', '|', '^', $isoYYYY, $isoMM, $isoDD,'$')"/>

        <sch:rule context="*:date[(@notBefore | @notAfter | @standardDate)] | *:toDate[(@notBefore | @notAfter | @standardDate)] | *:fromDate[(@notBefore | @notAfter | @standardDate)]">
            <sch:assert test="every $d in (@notBefore | @notAfter | @standardDate) satisfies matches($d, $isoPattern)"> The <sch:emph>notBefore</sch:emph>, <sch:emph>notAfter</sch:emph>, and <sch:emph>standardDate</sch:emph> attributes of <sch:name/> must be a iso8601 date.</sch:assert>
        </sch:rule>
    
    </sch:pattern>
    -->
    
</sch:schema>