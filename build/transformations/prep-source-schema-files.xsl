<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
    xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
    xmlns:rng="http://relaxng.org/ns/structure/1.0"
    version="3.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="true"/>
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:param name="schema" select="'eac'"/>

    <xsl:variable name="module-xml-files" select="collection('../../source/modules?select=*.rng')" as="document-node()*"/>
    
    <xsl:variable name="source-file" select="if ($schema eq 'eac') then document('../../source/eac-source.rng')
        else if ($schema eq 'ead') then document('../../source/ead-source.rng')
        else null"/>
    
    <xsl:template name="xsl:initial-template">
        <xsl:if test="$source-file">
            <xsl:result-document href="../source/modules/extensible-version/{$schema}/eac-source.rng">
                <xsl:copy-of select="$source-file"/>
            </xsl:result-document>
            <xsl:for-each select="$module-xml-files">
                <xsl:variable name="filename" select="tokenize(document-uri(.), '/')[last()]"/>
                <xsl:choose>
                    <xsl:when test="$schema eq 'eac' and starts-with($filename, 'ead-')"/>
                    <xsl:when test="$schema eq 'ead' and starts-with($filename, 'eac-')"/>
                    <xsl:otherwise>
                        <xsl:result-document href="../source/modules/extensible-version/{$schema}/modules/{$filename}">
                            <xsl:copy>
                                <xsl:apply-templates select="@*|node()"/>
                            </xsl:copy>
                        </xsl:result-document>
                    </xsl:otherwise>  
                </xsl:choose>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="rng:*[contains(@a:exclude-from, $schema)]"/>
  
</xsl:stylesheet>
    
