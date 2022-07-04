<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
    xmlns:rng="http://relaxng.org/ns/structure/1.0"
    exclude-result-prefixes="#all"
    version="3.0">
    <!-- during the build process, this file is ran against xml-schemas/{$schema} files to embed an intro, release notes, etc. -->
    <!-- to do: consider adding something like a metadata.json file, instead -->
    
    <xsl:output method="xml" encoding="UTF-8" indent="true"/>
    <xsl:mode on-no-match="deep-copy"/>
    
    <xsl:param name='schema' select="'eac'"/>
    <xsl:param name='preambles' select="document('../../source/release-info/intro.xml')/preambles" as="node()"/>
    <xsl:variable name="intro-comment" as="node()">
        <xsl:evaluate xpath="concat($schema, '/comment()')" as="node()" context-item="$preambles"/>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:if test="not(comment())">
            <xsl:copy-of select="$intro-comment"/>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>
    
</xsl:stylesheet>
