<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:eac="https://archivists.org/ns/eac/v2"
    xmlns:ead3="http://ead3.archivists.org/schema/"
    xmlns:ead="http://archivists.org/ns/ead/v4"
    exclude-result-prefixes="#all"
    version="3.0">
    <xsl:output method="xml" encoding="UTF-8" indent="true"/>
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:param name="schema" select="'eac'"/> <!-- for EAD, will need to pass the param of 'schema', until we change the namespace not to end in 'schema'. this is due to how Trang selects the ns prefix -->
    
    <!-- for eac, this gets us 'https://archivists.org/ns/eac/v2' -->
    <xsl:variable name="schema-ns-uri" select="document('')/*/namespace::*[local-name() eq $schema]"/>
    
    <!-- and to get the "v2" prefix from the namespace URI, we do this -->
    <xsl:param name="trang-ns-prefix" select="tokenize($schema-ns-uri, '/')[last()]"/>
    
    <!-- if we want the XSD schema to require a start element, we need to change all of the top-level elements (aside from the document node) to complexType -->
    <xsl:template match="xs:element[not(@name eq $schema)][parent::xs:schema]">
        <xs:complexType name="{@name}">
            <xsl:if test='xs:complexType[@mixed = "true"]'>
                <xsl:attribute name="mixed">true</xsl:attribute>
            </xsl:if>
            <!-- just in case we have empty elements, with no attributes, during the promotion to complexType process -->
            <xsl:if test="@type eq 'xs:string'">
                <xs:simpleContent>
                    <xs:extension base="xs:string">
                        <xs:attribute name="value" type="xs:string" />
                    </xs:extension>
                </xs:simpleContent>
            </xsl:if>
            <!-- this handles elements like objectXMLWrap, and ead's c12 -->
            <xsl:apply-templates select="@type[starts-with(., $trang-ns-prefix)]" mode="convert-type-to-extension-element"/>
            <!-- and now we copy over all the children of complexType -->
            <xsl:apply-templates select="xs:complexType/*"/>
        </xs:complexType>
    </xsl:template>
    
    <xsl:template match="xs:element[@ref][not(parent::xs:schema)]">
        <xsl:copy>
            <xsl:attribute name="type" select="@ref"/>
            <xsl:attribute name="name" select="substring-after(@ref, ':')"/>
            <xsl:apply-templates select="@* except @ref | node()"/>    
        </xsl:copy> 
    </xsl:template>
    
    <xsl:template match="@type" mode="convert-type-to-extension-element">
        <xs:complexContent>
            <xs:extension base="{.}"/>          
        </xs:complexContent>
    </xsl:template>
        
</xsl:stylesheet>