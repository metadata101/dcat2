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
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:locn="http://www.w3.org/ns/locn#"
                xmlns:java="java:org.fao.geonet.util.XslUtil"
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-dcat2="http://geonetwork-opensource.org/xsl/functions/profiles/dcat2"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                extension-element-prefixes="saxon"
                version="2.0"
                exclude-result-prefixes="#all">

  <xsl:template mode="mode-dcat2" priority="4000"
                match="dcat:keyword"/>

  <xsl:template mode="mode-dcat2" priority="4000"
                match="gn:child[@name = 'keyword']">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="isoType" select="''"/>
    <xsl:variable name="thesaurusTitleEl"
                  select="''"/>

    <xsl:call-template name="addAllThesaurus">
      <xsl:with-param name="ref"
                      select="concat('_P', ../gn:element/@ref, '_',
                                replace('dcat:keyword', ':', 'COLON'))"/>
      <xsl:with-param name="transformation" select="'to-dcat2-concept'"/>
      <xsl:with-param name="xpath" select="'./*/dcat:keyword'"/>
      <xsl:with-param name="keywordList"
                      select="string-join(
                          if ($lang and ../dcat:keyword//skos:prefLabel[@xml:lang = $lang])
                          then
                          ../dcat:keyword//skos:prefLabel[@xml:lang = $lang]/replace(text(), ',', ',,')
                          else ../dcat:keyword//skos:prefLabel[not(@xml:lang)]/replace(text(), ',', ',,'), ',')"/>
    </xsl:call-template>

  </xsl:template>
</xsl:stylesheet>
