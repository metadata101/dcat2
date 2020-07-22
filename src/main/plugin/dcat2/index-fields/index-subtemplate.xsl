<?xml version="1.0" encoding="UTF-8" ?>
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

<xsl:stylesheet xmlns:dct="http://purl.org/dc/terms/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0"
>
  <xsl:include href="../convert/functions.xsl"/>

  <xsl:param name="id"/>
  <xsl:param name="uuid"/>
  <xsl:param name="title"/>


  <xsl:variable name="isMultilingual" select="count(distinct-values(*//@xml:lang)) > 0"/>

  <!-- Subtemplate indexing -->
  <xsl:template match="/">
    <xsl:variable name="root" select="/"/>
    <xsl:variable name="isoDocLangId">
      <xsl:call-template name="langId-dcat2"/>
    </xsl:variable>

    <Documents>

      <xsl:choose>
        <xsl:when test="$isMultilingual">
          <xsl:for-each select="distinct-values(distinct-values(*//@xml:lang))">
            <xsl:variable name="locale" select="string(.)"/>
            <xsl:variable name="langId">
              <xsl:call-template name="langId3to2">
                <xsl:with-param name="langId-3char" select="$isoDocLangId"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="isoLangId">
              <xsl:call-template name="langId2to3">
                <xsl:with-param name="langId-2char" select="."/>
              </xsl:call-template>
            </xsl:variable>

            <Document locale="{$isoLangId}">
              <Field name="_locale" string="{$isoLangId}" store="true" index="true"/>
              <Field name="_docLocale" string="{$isoDocLangId}" store="true" index="true"/>
              <xsl:apply-templates mode="index" select="$root">
                <xsl:with-param name="locale" select="$locale"/>
                <xsl:with-param name="isoLangId" select="$isoLangId"/>
                <xsl:with-param name="langId" select="$langId"></xsl:with-param>
              </xsl:apply-templates>
            </Document>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <Document locale="">
            <xsl:apply-templates mode="index" select="$root">
            </xsl:apply-templates>
          </Document>
        </xsl:otherwise>
      </xsl:choose>
    </Documents>
  </xsl:template>

  <xsl:template mode="index" match="dct:LicenseDocument">
    <xsl:param name="isoLangId"/>
    <xsl:param name="langId"/>
    <xsl:param name="locale"/>
    <xsl:variable name="title">
      <xsl:call-template name="index-lang-tag-oneval">
        <xsl:with-param name="tag" select="dct:title"/>
        <xsl:with-param name="langId" select="$isoLangId"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$title!=''">
      <xsl:value-of select="concat($title, ' ')"/>
    </xsl:if>
    <Field name="_title"
           string="{if ($title != '') then $title else dct:identifier}"
           store="true" index="true"/>

    <xsl:call-template name="subtemplate-common-fields"/>
  </xsl:template>

  <xsl:template name="subtemplate-common-fields">
    <Field name="any" string="{normalize-space(string(.))}" store="false" index="true"/>
    <Field name="_root" string="{name(.)}" store="true" index="true"/>
  </xsl:template>

</xsl:stylesheet>
