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
    
</sch:schema>
