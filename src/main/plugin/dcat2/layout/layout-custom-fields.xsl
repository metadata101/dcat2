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
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-dcat2="http://geonetwork-opensource.org/xsl/functions/profiles/dcat2"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                extension-element-prefixes="saxon"
                version="2.0"
                exclude-result-prefixes="#all">

  <xsl:include href="layout-custom-fields-concepts.xsl"/>

  <xsl:template mode="mode-dcat2" match="dct:spatial" priority="2000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="refToDelete" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', $xpath)"/>

    <xsl:call-template name="render-boxed-element">
      <xsl:with-param name="label" select="$labelConfig/label"/>
      <xsl:with-param name="editInfo" select="$refToDelete"/>
      <xsl:with-param name="cls" select="local-name()"/>
      <xsl:with-param name="subTreeSnippet">

        <xsl:variable name="identifier"
                      select="./dct:Location/@rdf:about"/>
        <xsl:variable name="description"
                      select="./dct:Location/skos:prefLabel[1]"/>
        <xsl:variable name="readonly" select="false()"/>
        <xsl:variable name="geometry" as="node()">
          <xsl:choose>
            <xsl:when
              test="count(./dct:Location/locn:geometry[ends-with(./dct:Location/@rdf:datatype,'#wktLiteral')])>0">
              <xsl:copy-of
                select="node()[name(./dct:Location)='locn:geometry' and ends-with(./dct:Location/@rdf:datatype,'#wktLiteral')][1]"/>
            </xsl:when>
            <xsl:when
              test="count(./dct:Location/locn:geometry[ends-with(./dct:Location/@rdf:datatype,'#gmlLiteral')])>0">
              <xsl:copy-of
                select="node()[name(./dct:Location)='locn:geometry' and ends-with(./dct:Location/@rdf:datatype,'#gmlLiteral')][1]"/>
            </xsl:when>
            <xsl:when test="dct:Location and dct:Location/locn:geometry">
              <xsl:copy-of select="./dct:Location/locn:geometry[1]"/>
            </xsl:when>
            <xsl:otherwise>
              <!-- Return empty nodes to trigger error later -->
              <xsl:copy-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="cleanedGeometry" as="node()">
          <xsl:apply-templates select="$geometry" mode="gn-element-cleaner"/>
        </xsl:variable>
        <xsl:variable name="bbox" select="gn-fn-dcat2:getBboxCoordinates($cleanedGeometry)"/>
        <xsl:variable name="bboxCoordinates" select="tokenize(replace($bbox,',','.'), '\|')"/>
        <xsl:if test="count($bboxCoordinates)>4">
          <div class="alert alert-danger">
            <p data-translate="invalidGeometryValue"/>
          </div>
        </xsl:if>
        <div gn-draw-bbox=""
             data-dc-ref="{concat('_',$geometry/gn:element/@ref)}"
             data-lang="lang"
             data-read-only="{$readonly}">
          <xsl:if test="$bbox != ''">
            <xsl:attribute name="data-hleft"
                           select="$bboxCoordinates[1]"/>
            <xsl:attribute name="data-hright"
                           select="$bboxCoordinates[3]"/>
            <xsl:attribute name="data-hbottom"
                           select="$bboxCoordinates[2]"/>
            <xsl:attribute name="data-htop"
                           select="$bboxCoordinates[4]"/>
          </xsl:if>
          <xsl:variable name="identifier">
            <xsl:choose>
              <xsl:when test="count($bboxCoordinates)>5">
                <xsl:value-of select="$bboxCoordinates[6]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="./dct:Location/@rdf:about"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="description">
            <xsl:choose>
              <xsl:when test="count($bboxCoordinates)>4">
                <xsl:value-of select="$bboxCoordinates[5]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="./dct:Location/skos:prefLabel[1]"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="data-identifier" select="$identifier"/>
          <xsl:attribute name="data-identifier-ref"
                         select="concat('_', ./dct:Location/gn:element/@ref,'_rdfCOLONabout')"/>
          <xsl:attribute name="data-identifier-tooltip"
                         select="concat($schema, '|rdf:about|dct:Location|', $xpath, '/dct:Location/@rdf:about')"/>
          <xsl:attribute name="data-description" select="$description"/>
          <xsl:attribute name="data-description-ref"
                         select="concat('_', ./dct:Location/skos:prefLabel[1]/gn:element/@ref)"/>
          <xsl:attribute name="data-description-tooltip"
                         select="concat($schema, '|', 'skos:prefLabel|dcat:Dataset|', $xpath, '/dct:Location/skos:prefLabel')"/>
        </div>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <!-- Date fields -->
  <xsl:template mode="mode-dcat2" match="dct:issued|dct:modified|dcat:startDate|dcat:endDate" priority="2000">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="refToDelete" required="no"/>
    <xsl:param name="editInfo" required="no"/>
    <xsl:param name="parentEditInfo" required="no"/>

    <xsl:variable name="isRequired" as="xs:boolean">
      <xsl:choose>
        <xsl:when
          test="($parentEditInfo and $parentEditInfo/@min = 1 and $parentEditInfo/@max = 1) or
            (not($parentEditInfo) and $editInfo and $editInfo/@min = 1 and $editInfo/@max = 1)">
          <xsl:value-of select="true()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="labelConfig" select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', $xpath)"/>


    <div data-gn-date-picker="{.}"
         data-label="{$labelConfig/label}"
         data-element-name="{name()}"
         data-element-ref="{concat('_X', gn:element/@ref)}"
         data-required="{$isRequired}"
         data-tag-name="{name()}"
         data-hide-time="{if ($viewConfig/@hideTimeInCalendar = 'true') then 'true' else 'false'}">
    </div>
  </xsl:template>

</xsl:stylesheet>
