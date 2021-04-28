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
    <element name="dcat:theme">
      <thesaurus>external.theme.eu.europa.data-theme</thesaurus>
      <xpath>/dcat:theme</xpath>
      <max></max>
      <labelKey>dcat.addThemes</labelKey>
    </element>
    <element name="dct:type">
      <thesaurus>external.theme.dcat-type</thesaurus>
      <xpath>/dct:type</xpath>
      <max>1</max>
      <labelKey>dcat.addType</labelKey>
    </element>
    <element name="dcat:keyword">
      <thesaurus>external.none.allThesaurus</thesaurus>
      <xpath>/dcat:keyword</xpath>
      <max></max>
      <labelKey>dcat.addTags</labelKey>
    </element>
    <element name="dct:format">
      <thesaurus>external.theme.eu.europa.file-type</thesaurus>
      <xpath>//dcat:Distribution/dct:format</xpath>
      <max>1</max>
      <labelKey>dcat.addFormat</labelKey>
    </element>
    <element name="dcat:packageFormat">
      <thesaurus>external.theme.eu.europa.file-type</thesaurus>
      <xpath>//dcat:Distribution/dcat:packageFormat</xpath>
      <max>1</max>
      <labelKey>dcat.addPackageFormat</labelKey>
    </element>
    <element name="dcat:compressFormat">
      <thesaurus>external.theme.eu.europa.file-type</thesaurus>
      <xpath>//dcat:Distribution/dcat:compressFormat</xpath>
      <max>1</max>
      <labelKey>dcat.addCompressFormat</labelKey>
    </element>
    <element name="dcat:mediaType">
      <thesaurus>external.theme.org.iana.media-type</thesaurus>
      <xpath>//dcat:Distribution/dcat:mediaType</xpath>
      <max>1</max>
      <labelKey>dcat.addMediaType</labelKey>
    </element>
  </xsl:variable>

  <!-- Theme can only be set by thesaurus eu.europa.data-theme.

  Catch all elements first.
  On gn:child, build the keyword picker directive using XPath mode.

  TODO: Get thesaurus from config (if not thesaurus, render as text ?)
  TODO: How to deal with value not in the thesaurus ?
  -->
  <xsl:template mode="mode-dcat2" priority="4000"
                match="*[name() = $dcatKeywordConfig//@name]"/>
  <xsl:template mode="mode-dcat2" priority="4000"
                match="gn:child[concat(@prefix, ':', @name) = $dcatKeywordConfig//@name]">
    <xsl:variable name="name" select="concat(@prefix, ':', @name)"/>
    <xsl:variable name="config" select="$dcatKeywordConfig/*[@name = $name]"/>
    <div
      data-gn-keyword-selector="tagsinput"
      data-metadata-id=""
      data-element-ref="{concat('_P', ../gn:element/@ref, '_',
                                replace($config/@name, ':', 'COLON'))}"
      data-element-xpath="{concat(
        if ($isDcatService) then './dcat:DataService' else './dcat:Dataset', $config/xpath)}"
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
