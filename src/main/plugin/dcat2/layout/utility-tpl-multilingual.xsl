<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:xslutil="java:org.fao.geonet.util.XslUtil"
                version="2.0"
                exclude-result-prefixes="#all">

  <!-- Get the main metadata languages -->
  <xsl:template name="get-dcat2-language">
    <xsl:variable name="authorityLanguage"
                  select="$metadata/descendant::node()/dcat:Dataset/dct:language[1]/skos:Concept/@rdf:about"/>
    <xsl:choose>
      <xsl:when test="ends-with($authorityLanguage,'NLD')">dut</xsl:when>
      <xsl:when test="ends-with($authorityLanguage,'FRA')">fre</xsl:when>
      <xsl:when test="ends-with($authorityLanguage,'ENG')">eng</xsl:when>
      <xsl:when test="ends-with($authorityLanguage,'DEU')">ger</xsl:when>
      <xsl:otherwise>dut</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Get the list of other languages in JSON -->
  <xsl:template name="get-dcat2-other-languages-as-json">
    <xsl:variable name="langs">
      <xsl:variable name="mainLanguage">
        <xsl:call-template name="get-dcat2-language"/>
      </xsl:variable>
      <lang>
        <xsl:value-of select="concat('&quot;', $mainLanguage, '&quot;:&quot;#', upper-case($mainLanguage), '&quot;')"/>
      </lang>
      <xsl:if test="count($metadata/descendant::node()/*[@xml:lang!=''])>0">
        <xsl:for-each select="distinct-values($metadata/descendant::node()/*/@xml:lang)">
          <xsl:variable name="langId" select="normalize-space(xslutil:threeCharLangCode(string(.)))"/>
          <xsl:if test="string-length($langId)>0 and $langId!=$mainLanguage">
            <lang>
              <xsl:value-of select="concat('&quot;', $langId, '&quot;:&quot;#', upper-case($langId), '&quot;')"/>
            </lang>
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:variable>
    <xsl:text>{</xsl:text><xsl:value-of select="string-join($langs/lang, ',')"/><xsl:text>}</xsl:text>
  </xsl:template>

  <!-- Get the list of other languages -->
  <xsl:template name="get-dcat2-other-languages">
    <xsl:choose>
      <xsl:when test="count($metadata/descendant::node()/*[@xml:lang!=''])>1">
        <xsl:for-each select="distinct-values($metadata/descendant::node()/*/@xml:lang)">
          <xsl:variable name="langId" select="xslutil:threeCharLangCode(string(.))"/>
          <lang id="{upper-case($langId)}" code="{$langId}"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="mainLanguage">
          <xsl:call-template name="get-dcat2-language"/>
        </xsl:variable>
        <lang id="{upper-case($mainLanguage)}" code="{$mainLanguage}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
