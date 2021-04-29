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

  <xsl:variable name="dcatKeywordConfig">
    <xsl:for-each select="$editorConfig/editor/fields/for[@use='thesaurus-list-picker']">
      <element>
        <xsl:attribute name="name" select="./@name"/>
        <thesaurus>
          <xsl:value-of select="./directiveAttributes/@thesaurus"/>
        </thesaurus>
        <xpath>
          <xsl:value-of select="./directiveAttributes/@xpath"/>
        </xpath>
        <max>
          <xsl:value-of select="./directiveAttributes/@max"/>
        </max>
        <labelKey>
          <xsl:value-of select="./directiveAttributes/@labelKey"/>
        </labelKey>
      </element>
    </xsl:for-each>
  </xsl:variable>

  <!-- Theme can only be set by thesaurus eu.europa.data-theme.

  Catch all elements first.
  On gn:child, build the keyword picker directive using XPath mode.

  TODO: Get thesaurus from config (if not thesaurus, render as text ?)
  TODO: How to deal with value not in the thesaurus ?
  -->
  <xsl:template mode="mode-dcat2" priority="4000" match="*[name() = $dcatKeywordConfig//@name]">
    <xsl:variable name="name" select="name()"/>
    <xsl:variable name="hasGnChild" select="count(../gn:child[concat(@prefix, ':', @name) = $name]) > 0"/>

    <xsl:if test="not($hasGnChild)">
      <xsl:variable name="isFirst" select="count(preceding-sibling::*[name() = $name]) &lt; 1"/>
      <xsl:if test="$isFirst">
        <xsl:call-template name="thesaurus-picker-list">
          <xsl:with-param name="config" select="$dcatKeywordConfig/*[@name = $name]"/>
          <xsl:with-param name="ref" select="../gn:element/@ref"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="mode-dcat2" priority="4000"
                match="gn:child[concat(@prefix, ':', @name) = $dcatKeywordConfig//@name]">
    <xsl:variable name="name" select="concat(@prefix, ':', @name)"/>
    <xsl:call-template name="thesaurus-picker-list">
      <xsl:with-param name="config" select="$dcatKeywordConfig/*[@name = $name]"/>
      <xsl:with-param name="ref" select="../gn:element/@ref"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="thesaurus-picker-list">
    <xsl:param name="config" as="node()"/>
    <xsl:param name="ref" as="xs:string"/>
    <div
      data-gn-keyword-selector="tagsinput"
      data-metadata-id=""
      data-element-ref="{concat('_P', $ref, '_', replace($config/@name, ':', 'COLON'))}"
      data-element-xpath="{concat(if ($isDcatService) then './dcat:DataService' else './dcat:Dataset', $config/xpath)}"
      data-wrapper="{$config/@name}"
      data-thesaurus-title="{{{{'{$config/labelKey}' | translate}}}}"
      data-thesaurus-key="{$config/thesaurus}"
      data-keywords="{string-join(
                          if ($lang and ../*[name() = $config/@name]//skos:prefLabel[@xml:lang = $lang])
                          then
                          ../*[name() = $config/@name]//skos:prefLabel[@xml:lang = $lang]/replace(text(), ',', ',,')
                          else ../*[name() = $config/@name]//skos:prefLabel[not(@xml:lang)]/replace(text(), ',', ',,'), ',')}"
      data-transformations="to-dcat2-concept"
      data-current-transformation="to-dcat2-concept"
      data-max-tags="{$config/max}"
      data-lang="{$metadataOtherLanguagesAsJson}"
      data-textgroup-only="false"
      class="">
    </div>
  </xsl:template>

</xsl:stylesheet>
