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
                xmlns:adms="http://www.w3.org/ns/adms#" xmlns:dct="http://purl.org/dc/terms/"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
                xmlns:locn="http://www.w3.org/ns/locn#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:schema="http://schema.org/"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-dcat2="http://geonetwork-opensource.org/xsl/functions/profiles/dcat2"
                version="2.0"
                exclude-result-prefixes="#all">

  <xsl:strip-space elements="*"/>

  <!-- Load the editor configuration to be able to render the different views -->
  <xsl:variable name="configuration"
                select="document('../../layout/config-editor.xml')"/>

  <!-- Some utility -->
  <xsl:include href="common/functions-metadata.xsl"/>
  <xsl:include href="../../convert/functions.xsl"/>
  <xsl:include href="../../layout/evaluate.xsl"/>

  <!-- The core formatter XSL layout based on the editor configuration -->
  <xsl:include href="sharedFormatterDir/xslt/render-layout.xsl"/>

  <!-- The stylesheet 'common/functions-metadata.xsl' relies on two variables
    'iso19139labels' and 'defaultFieldType' -->
  <xsl:variable name="iso19139labels" select="dummy"/>
  <xsl:variable name="defaultFieldType" select="'text'"/>


  <!-- Define the metadata to be loaded for this schema plugin -->
  <xsl:variable name="metadata" select="/root/rdf:RDF"/>
  <xsl:variable name="langId" select="/root/gui/language"/>
  <xsl:variable name="nodeUrl" select="/root/gui/nodeUrl"/>
  <xsl:variable name="langId-2char">
    <xsl:call-template name="langId3to2">
      <xsl:with-param name="langId-3char" select="$langId"/>
    </xsl:call-template>
  </xsl:variable>
  <!-- Create a SchemaLocalizations object to look up nodeLabels with function
    tr:node-label($schemaLocalizations, name(), name(..)). This is no longer
    used -->
  <!-- xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations" -->
  <!-- <xsl:variable name="schemaLocalizations" select="tr:create($schema)"
    /> -->

  <!-- The labels and their translations -->
  <xsl:variable name="schemaInfo" select="/root/schemas/*[name(.)=$schema]"/>
  <xsl:variable name="labels" select="$schemaInfo/labels"/>


  <!-- Specific schema rendering -->
  <xsl:template mode="getMetadataTitle" match="rdf:RDF">
    <!--
     Language priority order:
       1) Field in the language of the interface
       2) Field in default language ($defaultLang-2char)
       3) First field of the list
     -->
    <xsl:choose>
      <xsl:when test="//dcat:Dataset/dct:title[@xml:lang = $langId-2char]">
        <xsl:value-of select="//dcat:Dataset/dct:title[@xml:lang = $langId-2char][1]"/>
      </xsl:when>
      <xsl:when test="//dcat:Dataset/dct:title[@xml:lang = $defaultLang-2char]">
        <xsl:value-of
          select="concat(//dcat:Dataset/dct:title[@xml:lang = $defaultLang-2char][1], ' (', normalize-space(//dcat:Dataset/dct:title[@xml:lang = $defaultLang-2char][1]/@xml:lang), ')')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="//dcat:Dataset/dct:title[1]"/>
        <xsl:if
          test="//dcat:Dataset/dct:title[1]/@xml:lang and normalize-space(//dcat:Dataset/dct:title[1]/@xml:lang) != '' ">
          <xsl:value-of select="concat(' (',//dcat:Dataset/dct:title[1]/@xml:lang,')')"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="getMetadataAbstract" match="rdf:RDF">
    <xsl:value-of select="//dcat:Dataset/dct:description"/>
  </xsl:template>

  <xsl:template mode="getMetadataHeader" match="rdf:RDF">
  </xsl:template>

  <xsl:template mode="getMetadataThumbnail" match="rdf:RDF">
  </xsl:template>


  <xsl:template mode="render-view" match="field[template]"
                priority="3">
    <xsl:param name="base" select="$metadata"/>

    <xsl:variable name="fieldXpath" select="@xpath"/>
    <xsl:variable name="fields" select="template/values/key"/>
    <!-- Get all elements that are within a dcat2 namespace -->
    <xsl:variable name="elements">
      <xsl:call-template name="evaluate-dcat2">
        <xsl:with-param name="base" select="$base"/>
        <xsl:with-param name="in" select="concat('/../', $fieldXpath)"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Render fields for each dcat2 element -->
    <xsl:for-each select="$elements/*">
      <xsl:variable name="element" select="."/>
      <xsl:apply-templates mode="render-field" select="$element">
        <xsl:with-param name="xpath" select="$fieldXpath"/>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>


  <!-- ########################## -->
  <!-- Render Section... -->

  <xsl:template mode="render-view" match="section[@xpath]">
    <xsl:variable name="sectionContent">
      <xsl:apply-templates mode="render-view" select="@xpath"/>
    </xsl:variable>
    <!-- Hide sections if empty -->
    <xsl:if test="normalize-space($sectionContent)">
      <div id="gn-view-{generate-id()}" class="gn-tab-content">
        <xsl:copy-of select="$sectionContent"/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="render-view" match="section[not(@xpath)]">
    <xsl:variable name="sectionContent">
      <xsl:apply-templates mode="render-view" select="section|field"/>
    </xsl:variable>
    <!-- Hide sections if empty -->
    <xsl:if test="normalize-space($sectionContent)">
      <div id="gn-section-{generate-id()}" class="gn-tab-content">
        <xsl:if test="@name">
          <xsl:variable name="title" select="gn-fn-render:get-schema-strings($schemaStrings, @name)"/>
          <xsl:element name="h{2 + count(ancestor-or-self::*[name(.) = 'section'])}">
            <xsl:attribute name="class" select="'view-header'"/>
            <xsl:attribute name="style"
                           select="'border-bottom: 2px solid rgb(229, 229, 229); margin-top: 30px;font-size: 16px;color: rgb(40, 96, 144); position: relative;'"/>
            <xsl:value-of select="$title"/>
          </xsl:element>
        </xsl:if>
        <table
          style="box-sizing: border-box; width: 100%; max-width: 100%; margin-bottom: 20px; background-color: transparent; border-collapse: collapse; border-spacing: 0;"
          class="table table-striped">
          <!--<xsl:apply-templates mode="render-view" select="section|field"/>-->
          <xsl:copy-of select="$sectionContent"/>&#160;
        </table>
      </div>
    </xsl:if>
  </xsl:template>


  <!-- ########################## -->
  <!-- Render fields... -->

  <xsl:template mode="render-field" match="dcat:Dataset">
    <xsl:param name="xpath"/>
    <xsl:apply-templates mode="render-field" select="@*|*">
      <xsl:with-param name="xpath" select="$xpath"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- Field with lang : display only field of current lang or first one if not exist -->
  <xsl:template mode="render-field"
                match="dct:title|dct:description|foaf:name|adms:versionNotes">
    <xsl:param name="xpath"/>
    <xsl:variable name="stringValue" select="string()"/>
    <xsl:variable name="name" select="name()"/>
    <!--
    Shown label:
      if label is in current interface language
      else if no labels in current interface language, show labels in default language
      else if no labels in default language, show first one only
    -->
    <xsl:if test="normalize-space($stringValue) != '' and
                    (@xml:lang = $langId-2char or
                    (not(../node()[name() = $name]/@xml:lang = $langId-2char) and @xml:lang = $defaultLang-2char) or
                    (not(../node()[name() = $name]/@xml:lang = $defaultLang-2char) and count(preceding-sibling::node()[name() = $name]) &lt; 1))">
      <tr>
        <th
          style="border-style: solid; border-color: #ddd; border-width: 1px 0 1px 1px; width: 20%; padding: 8px; line-height: 1.428571429; vertical-align: top; box-sizing: border-box; text-align: left;">
          <xsl:value-of
            select="gn-fn-metadata:getLabel($schema, name(.), $labels, name(..), '', gn-fn-dcat2:concatXPaths($xpath, gn-fn-metadata:getXPath(.), name(.)))/label"/>
          <xsl:if
            test="@xml:lang and normalize-space(@xml:lang) != $langId-2char and normalize-space(@xml:lang) != '' ">
            <xsl:value-of select="concat(' (',@xml:lang,')')"/>
          </xsl:if>
        </th>
        <td
          style="border-style: solid; border-color: #ddd; border-width: 1px 1px 1px 0; padding-left: 0; width: 80%; word-break: break-word; padding: 8px; line-height: 1.428571429; vertical-align: top; box-sizing: border-box;">
          <xsl:apply-templates mode="render-value" select="."/>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <!-- Field with no lang : display all -->
  <xsl:template mode="render-field"
                match="dct:created|dct:issued|dct:modified|dct:identifier|skos:notation|schema:startDate|schema:endDate|vcard:street-address|vcard:locality|vcard:postal-code|vcard:country-name|vcard:hasTelephone|vcard:fn|vcard:organization-name|skos:prefLabel|owl:versionInfo|adms:versionNotes|dcat:byteSize">
    <xsl:param name="xpath"/>
    <xsl:variable name="stringValue" select="string()"/>
    <xsl:if test="normalize-space($stringValue) != ''">
      <tr>
        <th
          style="border-style: solid; border-color: #ddd; border-width: 1px 0 1px 1px; width: 20%; padding: 8px; line-height: 1.428571429; vertical-align: top; box-sizing: border-box; text-align: left;">
          <xsl:value-of
            select="gn-fn-metadata:getLabel($schema, name(.), $labels, name(..), '', gn-fn-dcat2:concatXPaths($xpath, gn-fn-metadata:getXPath(.), name(.)))/label"/>
        </th>
        <td
          style="border-style: solid; border-color: #ddd; border-width: 1px 1px 1px 0; padding-left: 0; width: 80%; word-break: break-word; padding: 8px; line-height: 1.428571429; vertical-align: top; box-sizing: border-box;">
          <xsl:apply-templates mode="render-value" select="."/>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="render-field" match="@rdf:about|@rdf:resource">
    <xsl:param name="xpath"/>
    <!-- Fields entering in this template must have their name equal to "rdf:about" or "rdf:resource" in labels.xml -->
    <xsl:variable name="stringValue" select="string()"/>
    <xsl:if test="normalize-space($stringValue) != ''">
      <tr>
        <th
          style="border-style: solid; border-color: #ddd; border-width: 1px 0 1px 1px; border-style: solid; border-color: #ddd; border-width: 1px 0 1px 1px; width: 20%; padding: 8px; line-height: 1.428571429; vertical-align: top; box-sizing: border-box; text-align: left;">
          <xsl:value-of
            select="gn-fn-metadata:getLabel($schema, name(.), $labels, name(..), '', gn-fn-dcat2:concatXPaths($xpath, gn-fn-metadata:getXPath(.), name(.)))/label"/>
        </th>
        <td
          style="border-style: solid; border-color: #ddd; border-width: 1px 1px 1px 0; padding-left: 0; width: 80%; word-break: break-word; padding: 8px; line-height: 1.428571429; vertical-align: top; box-sizing: border-box;">
          <xsl:apply-templates mode="render-url" select="."/>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="render-field" match="dcat:keyword[not(preceding-sibling::dcat:keyword[position()=1])]">
    <xsl:param name="xpath"/>
    <tr>
      <th
        style="border-style: solid; border-color: #ddd; border-width: 1px 0 1px 1px; width: 20%; padding: 8px; line-height: 1.428571429; vertical-align: top; box-sizing: border-box; text-align: left;"
        class="gn-keyword">
        <xsl:value-of
          select="gn-fn-metadata:getLabel($schema, name(.), $labels, name(..), '', gn-fn-dcat2:concatXPaths($xpath, gn-fn-metadata:getXPath(.), name(.)))/label"/>
      </th>
      <td
        style="border-style: solid; border-color: #ddd; border-width: 1px 1px 1px 0; padding-left: 0; width: 80%; word-break: break-word; padding: 8px; line-height: 1.428571429; vertical-align: top; box-sizing: border-box;">
        <xsl:for-each select="../dcat:keyword">
          <div style="display:inline-block">
            <a
              href="{concat($nodeUrl,$langId,'/catalog.search#/search?resultType=details&amp;sortBy=relevance&amp;from=1&amp;to=20&amp;fast=index&amp;_content_type=json&amp;any=',.)}">
              <xsl:apply-templates mode="render-value" select="."/>
            </a>
            <xsl:if test="position() != last()">
              |
            </xsl:if>
          </div>
        </xsl:for-each>
      </td>
    </tr>
  </xsl:template>

  <xsl:template mode="render-field"
                match="dcat:accessURL|dcat:downloadURL|dcat:landingPage">
    <xsl:param name="xpath"/>
    <xsl:variable name="stringValue" select="string(@rdf:resource)"/>
    <xsl:if test="normalize-space($stringValue) != ''">
      <tr>
        <th
          style="border-style: solid; border-color: #ddd; border-width: 1px 0 1px 1px; width: 20%; padding: 8px; line-height: 1.428571429; vertical-align: top; box-sizing: border-box; text-align: left;">
          <xsl:value-of
            select="gn-fn-metadata:getLabel($schema, 'rdf:resource', $labels, name(..), '', concat(gn-fn-dcat2:concatXPaths($xpath, gn-fn-metadata:getXPath(.), name(.)), '/@rdf:resource'))/label"/>
        </th>
        <td
          style="border-style: solid; border-color: #ddd; border-width: 1px 1px 1px 0; padding-left: 0; width: 80%; word-break: break-word; padding: 8px; line-height: 1.428571429; vertical-align: top; box-sizing: border-box;">
          <xsl:apply-templates mode="render-url" select="@rdf:resource"/>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="render-field"
                match="foaf:Agent/dct:type|dcat:theme|dct:accrualPeriodicity|dct:language|dcat:Dataset/dct:type|dct:format|dcat:mediaType|adms:status|dct:LicenseDocument/dct:type|dct:accessRights">
    <xsl:param name="xpath"/>
    <xsl:variable name="usedLang">
      <xsl:value-of select="
        if (normalize-space(skos:Concept/skos:prefLabel[@xml:lang=$langId-2char]) != '')
        then $langId-2char
        else $defaultLang-2char
      "/>
    </xsl:variable>
    <tr>
      <th
        style="border-style: solid; border-color: #ddd; border-width: 1px 0 1px 1px; width: 20%; padding: 8px; line-height: 1.428571429; vertical-align: top; box-sizing: border-box; text-align: left;">
        <xsl:value-of
          select="gn-fn-metadata:getLabel($schema, name(.), $labels, name(..), '', gn-fn-dcat2:concatXPaths($xpath, gn-fn-metadata:getXPath(.), name(.)))/label"/>
      </th>
      <td
        style="border-style: solid; border-color: #ddd; border-width: 1px 1px 1px 0; padding-left: 0; width: 80%; word-break: break-word; padding: 8px; line-height: 1.428571429; vertical-align: top; box-sizing: border-box;">
        <xsl:choose>
          <xsl:when test="count(skos:Concept/skos:prefLabel[@xml:lang=$usedLang]) > 0">
            <xsl:for-each select="skos:Concept/skos:prefLabel[@xml:lang=$usedLang]">
              <a
                href="{concat($nodeUrl,$langId,'/catalog.search#/search?resultType=details&amp;sortBy=relevance&amp;from=1&amp;to=20&amp;fast=index&amp;_content_type=json&amp;any=',.)}">
                <xsl:apply-templates mode="render-value" select="."/>
                <xsl:if test="($usedLang = $defaultLang-2char) and ($defaultLang-2char != $langId-2char)">
                  <xsl:value-of select="concat(' (', $usedLang, ')')"/>
                </xsl:if>
              </a>
              <xsl:if test="position() != last()">
                ,
              </xsl:if>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when
                test="starts-with(skos:Concept/@rdf:about, 'http://') or starts-with(skos:Concept/@rdf:about, 'https://')">
                <xsl:apply-templates mode="render-url" select="skos:Concept/@rdf:about"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="skos:Concept/@rdf:about"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
  </xsl:template>

  <!-- Bbox is displayed with an overview and the geom displayed on it and
    the coordinates displayed around -->
  <xsl:template mode="render-field" match="dct:Location">
    <xsl:param name="xpath"/>

    <xsl:variable name="geometry" as="node()">
      <xsl:choose>
        <xsl:when test="count(locn:geometry[ends-with(@rdf:datatype,'#wktLiteral')])>0">
          <xsl:copy-of select="node()[name(.)='locn:geometry' and ends-with(@rdf:datatype,'#wktLiteral')][1]"/>
        </xsl:when>
        <xsl:when test="count(locn:geometry[ends-with(@rdf:datatype,'#gmlLiteral')])>0">
          <xsl:copy-of select="node()[name(.)='locn:geometry' and ends-with(@rdf:datatype,'#gmlLiteral')][1]"/>
        </xsl:when>
        <xsl:when test="locn:geometry">
          <xsl:copy-of select="locn:geometry[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="bbox" select="gn-fn-dcat2:getBboxCoordinates($geometry)"/>
    <xsl:variable name="bboxCoordinates" select="tokenize(replace($bbox,',','.'), '\|')"/>
    <tr>
      <th
        style="border-style: solid; border-color: #ddd; border-width: 1px 0 1px 1px; width: 20%; padding: 8px; line-height: 1.428571429; vertical-align: top; box-sizing: border-box; text-align: left;">
        <xsl:value-of
          select="gn-fn-metadata:getLabel($schema, name(.), $labels, name(..), '', gn-fn-dcat2:concatXPaths($xpath, gn-fn-metadata:getXPath(.), name(.)))/label"/>
      </th>
      <td
        style="border-style: solid; border-color: #ddd; border-width: 1px 1px 1px 0; padding-left: 0; width: 80%; word-break: break-word; padding: 8px; line-height: 1.428571429; vertical-align: top; box-sizing: border-box;">
        <table
          style="background-color: rgba(0, 0, 0, 0.035); margin-bottom: 0; box-sizing: border-box; width: 100%; max-width: 100%; border-collapse: collapse; border-spacing: 0;"
          class="table nested-table">
          <xsl:if test="locn:geometry">
            <tr>
              <td colspan="2">
                <xsl:if test="count($bboxCoordinates)=4">
                  <xsl:copy-of
                    select="gn-fn-render:bbox(
                      xs:double($bboxCoordinates[1]),
                      xs:double($bboxCoordinates[2]),
                      xs:double($bboxCoordinates[3]),
                      xs:double($bboxCoordinates[4]))"/>
                </xsl:if>
              </td>
            </tr>
          </xsl:if>

          <xsl:apply-templates mode="render-field" select="@rdf:about">
            <xsl:with-param name="xpath" select="$xpath"/>
          </xsl:apply-templates>

          <xsl:apply-templates mode="render-field" select="skos:prefLabel[1]">
            <xsl:with-param name="xpath" select="$xpath"/>
          </xsl:apply-templates>
        </table>
      </td>
    </tr>
  </xsl:template>

  <xsl:template mode="render-field"
                match="dcat:contactPoint|dct:publisher|dct:provenance|foaf:page|dct:temporal|dct:license|dct:rights|dct:conformsTo|dcat:distribution|adms:sample|vcard:hasAddress|adms:identifier">
    <xsl:param name="xpath"/>
    <xsl:variable name="stringValue" select="string()"/>

    <!-- Special case for dct:license with an empty dct:LicenseDocument with only @rdf:about or for dcat:contactPoint with only vcard:hasEmail and vcard:hasURL-->
    <xsl:if
      test="normalize-space($stringValue) != '' or (name() = 'dct:license' and ./dct:LicenseDocument/@rdf:about) or (name() = 'dcat:contactPoint' and ./vcard:Organization/*/@rdf:resource)">
      <tr>
        <th
          style="border-style: solid; border-color: #ddd; border-width: 1px 0 1px 1px; width: 20%; padding: 8px; line-height: 1.428571429; vertical-align: top; box-sizing: border-box; text-align: left;">
          <xsl:value-of
            select="gn-fn-metadata:getLabel($schema, name(.), $labels, name(..), '', gn-fn-dcat2:concatXPaths($xpath, gn-fn-metadata:getXPath(.), name(.)))/label"/>
          <xsl:if test="@xml:lang">
            (
            <xsl:value-of select="."/> )
          </xsl:if>
        </th>
        <td
          style="border-style: solid; border-color: #ddd; border-width: 1px 1px 1px 0; padding-left: 0; width: 80%; word-break: break-word; padding: 8px; line-height: 1.428571429; vertical-align: top; box-sizing: border-box;">
          <table
            style="background-color: rgba(0, 0, 0, 0.035); margin-bottom: 0; box-sizing: border-box; width: 100%; max-width: 100%; border-collapse: collapse; border-spacing: 0;"
            class="table nested-table">
            <xsl:apply-templates mode="render-field" select="@*|*">
              <xsl:with-param name="xpath" select="$xpath"/>
            </xsl:apply-templates>
          </table>
        </td>
      </tr>
    </xsl:if>
  </xsl:template>

  <!-- Traverse the tree -->
  <xsl:template mode="render-field" match="*">
    <xsl:param name="xpath"/>
    <xsl:apply-templates mode="render-field" select="@*|*">
      <xsl:with-param name="xpath" select="$xpath"/>
    </xsl:apply-templates>
  </xsl:template>


  <!-- ########################## -->
  <!-- Render values for text with clickable URL ... -->
  <xsl:template mode="render-value"
                match="dct:title|dct:description|owl:versionInfo|adms:versionNotes|dct:LicenseDocument/dct:identifier">
    <xsl:call-template name="linkify">
      <xsl:with-param name="txt" select="."/>
    </xsl:call-template>
  </xsl:template>

  <!-- Render values for text -->
  <xsl:template mode="render-value" match="*">
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- Render values for URL -->
  <xsl:template mode="render-url" match="*|@*">
    <a href="{.}" style="color=#06c; text-decoration: underline;">
      <xsl:value-of select="."/>
    </a>
  </xsl:template>

  <!-- ... Dates -->
  <xsl:template mode="render-value"
                match="*[matches(., '^[0-9]{4}-[0-1][0-9]-[0-3][0-9](Z|(\+|-)[0-1][0-9]:[0-6][0-9])?$')]">
    <span data-gn-humanize-time="{.}" data-format="DD MMM YYYY">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="*[matches(., '^[0-9]{4}-[0-1][0-9]-[0-3][0-9]T[0-2][0-9]:[0-6][0-9]:[0-6][0-9](Z|(\+|-)[0-1][0-9]:[0-6][0-9])?$')]">
    <span data-gn-humanize-time="{.}" data-format="DD MMM YYYY HH:mm">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template mode="render-url" match="*[../name() = 'vcard:hasEmail']|@*[../name() = 'vcard:hasEmail']">
    <xsl:choose>
      <xsl:when test="starts-with(normalize-space(.), 'mailto:')">
        <a href="{normalize-space(.)}" style="color=#06c; text-decoration: underline;">
          <xsl:value-of select="substring-after(normalize-space(.), 'mailto:')"/>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <a href="{concat('mailto:', normalize-space(.))}" style="color=#06c; text-decoration: underline;">
          <xsl:value-of select="."/>
        </a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="render-url"
                match="*[name(..) = 'dct:relation' or name(..) = 'dct:source' or name(..) = 'dct:isVersionOf' or name(..) = 'dct:hasVersion']|
                       @*[name(..) = 'dct:relation' or name(..) = 'dct:source' or name(..) = 'dct:isVersionOf' or name(..) = 'dct:hasVersion']">
    <a
      href="{concat($nodeUrl,$langId,'/catalog.search#/search?resultType=details&amp;sortBy=relevance&amp;from=1&amp;to=20&amp;fast=index&amp;_content_type=json&amp;any=',.)}"
      style="color=#06c; text-decoration: underline;">
      <xsl:value-of select="."/>
    </a>
  </xsl:template>
</xsl:stylesheet>
