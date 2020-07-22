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
                xmlns:gn-fn-index="http://geonetwork-opensource.org/xsl/functions/index"
                xmlns:index="java:org.fao.geonet.kernel.search.EsSearchManager"
                xmlns:saxon="http://saxon.sf.net/"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:import href="common/index-utils.xsl"/>

  <xsl:output method="xml" indent="yes"/>

  <xsl:output name="default-serialize-mode"
              indent="no"
              omit-xml-declaration="yes"
              encoding="utf-8"
              escape-uri-attributes="yes"/>


  <xsl:variable name="allLanguages">
    <lang id="default" value="eng"/>
    <!--<xsl:for-each select="$otherLanguages">
      <lang id="{../../../@id}" value="{.}"/>
    </xsl:for-each>-->
  </xsl:variable>

  <xsl:template match="/">
    <xsl:for-each select=".//(dcat:Dataset|dcat:DataService|dcat:Catalog)">
      <doc>
        <xsl:copy-of select="gn-fn-index:add-field('docType', 'metadata')"/>
        <xsl:copy-of select="gn-fn-index:add-field('documentStandard', 'dcat2')"/>
        <metadataIdentifier>
          <xsl:value-of select="@rdf:about"/>
        </metadataIdentifier>

        <xsl:copy-of select="gn-fn-index:add-multilingual-field('resourceTitle', dct:title, $allLanguages)"/>

        <xsl:for-each select="dct:language">
          <mainLanguage>
            <xsl:value-of select="string(.)"/>
          </mainLanguage>
        </xsl:for-each>

        <xsl:for-each select="dct:description">
          <resourceAbstract>
            <xsl:value-of select="string(.)"/>
          </resourceAbstract>
        </xsl:for-each>
      </doc>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
