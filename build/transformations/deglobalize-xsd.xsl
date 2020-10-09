<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:eac="https://archivists.org/ns/eac/v2"
    exclude-result-prefixes="xs eac"
    version="3.0">
    <xsl:output method="xml" encoding="UTF-8" indent="true"/>
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:param name="schema" select="'eac'"/> <!-- for EAD, will need to pass the param of 'schema', until we change the namespace not to end in 'schema'. this is due to how Trang selects the ns prefix -->
    
    <xsl:variable name="schema-ns-uri" select="../namespace::*[$schema]"/>
    
    <xsl:param name="trang-ns-prefix" select="tokenize($schema-ns-uri, '/')[last()] || ':'"/>
    
    <!-- if we want the XSD schema to require a start element, we need to change all of the top-level elements (aside from the document node) to complexType -->
    <xsl:template match="xs:element[not(@name eq $schema)][parent::xs:schema]">
        <xs:complexType name="{@name}">
            <xsl:if test='xs:complexType[@mixed = "true"]'>
                <xsl:attribute name="mixed">true</xsl:attribute>
            </xsl:if>
            <!-- just in case we have empty elements, with no attributes -->
            <xsl:if test="@type eq 'xs:string'">
                <xs:simpleContent>
                    <xs:extension base="xs:string">
                        <xs:attribute name="value" type="xs:string" />
                    </xs:extension>
                </xs:simpleContent>
            </xsl:if>
            <xsl:if test="@type[starts-with(., $schema)]">
                <xs:complexContent>
                    <xs:extension base="{@type}" />          
                </xs:complexContent>
            </xsl:if>
            <!-- and now we copy over all the children of complexType -->
            <xsl:apply-templates select="xs:complexType/*"/>
        </xs:complexType>
    </xsl:template>
    
    <xsl:template match="xs:element[@ref][not(parent::xs:schema)]">
        <xsl:copy>
            <xsl:attribute name="type" select="@ref"/>
            <xsl:attribute name="name" select="substring-after(@ref, $trang-ns-prefix)"/>
            <xsl:apply-templates select="@* except @ref | node()"/>    
        </xsl:copy> 
    </xsl:template>
    
        
</xsl:stylesheet>