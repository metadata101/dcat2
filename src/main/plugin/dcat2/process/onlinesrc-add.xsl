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
<xsl:stylesheet xmlns:dct="http://purl.org/dc/terms/"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0"
                exclude-result-prefixes="#all">

  <xsl:param name="protocol"/>
  <xsl:param name="url"/>
  <xsl:param name="name"/>
  <xsl:param name="desc"/>
  <xsl:param name="function"/>
  <xsl:param name="applicationProfile"/>
  <xsl:param name="catalogUrl"/>

  <!-- Do a copy of every nodes and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="dcat:Dataset">
    <xsl:copy>
      <xsl:apply-templates select="@*|*"/>

      <!-- If the distribution(s) are accessible only through a landing page (i.e. direct download URLs are not known), then the landing page URL associated with the dcat:Dataset SHOULD be duplicated as access URL on a distribution (see § 5.7 Dataset available only behind some Web page).-->
      <dcat:distribution>
        <dcat:Distribution>
          <!-- dcat:accessURL SHOULD be used for the URL of a service or location that can provide access to this distribution, typically through a Web form, query or API call. -->
          <xsl:variable name="isDirectDownload"
                        select="$function = 'download'"/>
          <xsl:if test="not($isDirectDownload)">
            <dcat:accessURL>
              <xsl:value-of select="$url"/>
            </dcat:accessURL>
          </xsl:if>

          <!--          <dcat:byteSize></dcat:byteSize>-->
          <!--          <dcat:compressFormat></dcat:compressFormat>-->
          <!-- dcat:downloadURL is preferred for direct links to downloadable resources. -->
          <xsl:if test="$isDirectDownload">
            <dcat:downloadURL>
              <xsl:value-of select="$url"/>
            </dcat:downloadURL>
          </xsl:if>


          <xsl:if test="$protocol">
            <!--            TODO: https://www.w3.org/TR/vocab-dcat-2/#Property:distribution_media_type-->
            <!--            <dcat:mediaType><xsl:value-of select="$protocol"/></dcat:mediaType>-->
          </xsl:if>
          <!--          <dcat:packageFormat></dcat:packageFormat>-->
          <!--          <dcat:spatialResolutionInMeters></dcat:spatialResolutionInMeters>-->
          <!--          <dcat:temporalResolution></dcat:temporalResolution>-->
          <!--          <dct:accessRights>-->
          <!--            <skos:Concept></skos:Concept>-->
          <!--          </dct:accessRights>-->
          <xsl:if test="$name">
            <dct:description>
              <xsl:value-of select="$name"/>
            </dct:description>
          </xsl:if>

          <xsl:if test="$protocol">
            <dct:format>
              <xsl:value-of select="$protocol"/>
            </dct:format>
          </xsl:if>
          <!--          <dct:license>-->
          <!--            <dct:LicenseDocument></dct:LicenseDocument>-->
          <!--          </dct:license>-->
        </dcat:Distribution>
      </dcat:distribution>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
