<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:adms="http://www.w3.org/ns/adms#"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:xslutil="java:org.fao.geonet.util.XslUtil"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-dcat2="http://geonetwork-opensource.org/xsl/functions/profiles/dcat2"
                version="2.0"
                exclude-result-prefixes="#all">

  <!--
  Template to prepare data-gn-keyword component
   for xml elements based on a thesaurus -->
  <xsl:template mode="mode-dcat2" priority="2000"
                match="foaf:Agent/dct:type[not($isFlatMode)]|dcat:theme|dct:accrualPeriodicity|dct:language|dcat:Dataset/dct:type|dct:format|dcat:mediaType|adms:status|dct:LicenseDocument/dct:type|dct:accessRights">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="existingInScheme" select="normalize-space(skos:Concept/skos:inScheme/@rdf:resource)"/>
    <xsl:variable name="createdInSchemeByParentElementName"
                  select="gn-fn-dcat2:getInSchemeURIByElementName(name(.),name(..))"/>

    <xsl:variable name="inScheme">
      <xsl:choose>
        <xsl:when test="$existingInScheme!=''">
          <xsl:value-of select="$existingInScheme"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$createdInSchemeByParentElementName"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="thesaurusTitle" select="gn-fn-dcat2:getThesaurusTitle($inScheme)"/>
    <xsl:variable name="thesaurusIdentifier" select="gn-fn-dcat2:getThesaurusIdentifier($inScheme)"/>
    <xsl:variable name="attributes">
      <xsl:if test="$isEditing">
        <!-- Create form for all existing attribute (not in gn namespace)
        and all non existing attributes not already present. -->
        <xsl:apply-templates mode="render-for-field-for-attribute-dcat2"
                             select="
          @*|
          gn:attribute[not(@name = parent::node()/@*/name())]">
          <xsl:with-param name="ref" select="gn:element/@ref"/>
          <xsl:with-param name="insertRef" select="gn:element/@ref"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:variable>


    <xsl:variable name="thesaurusConfig"
                  as="element()?"
                  select="if ($thesaurusList/thesaurus[@key=substring-after($thesaurusIdentifier, 'geonetwork.thesaurus.')])
                          then $thesaurusList/thesaurus[@key=substring-after($thesaurusIdentifier, 'geonetwork.thesaurus.')]
                          else $listOfThesaurus/thesaurus[title=$thesaurusTitle]"/>
    <xsl:choose>
      <xsl:when test="$thesaurusConfig/@fieldset = 'false'">
        <!--         <xsl:apply-templates mode="mode-dcat2" select="*">
                  <xsl:with-param name="schema" select="$schema"/>
                  <xsl:with-param name="labels" select="$labels"/>
                </xsl:apply-templates>-->
        <xsl:call-template name="render-transparent-boxed-element">
          <xsl:with-param name="label"
                          select="if ($thesaurusTitle)
	                then $thesaurusTitle
	                else gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', $xpath)/label"/>
          <xsl:with-param name="editInfo" select="gn:element"/>
          <xsl:with-param name="cls" select="local-name()"/>
          <xsl:with-param name="xpath" select="$xpath"/>
          <xsl:with-param name="attributesSnippet" select="$attributes"/>
          <xsl:with-param name="subTreeSnippet">
            <xsl:apply-templates mode="mode-dcat2" select="*">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="labels" select="$labels"/>
            </xsl:apply-templates>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="render-boxed-element">
          <xsl:with-param name="label"
                          select="if ($thesaurusTitle)
	                then $thesaurusTitle
	                else gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', $xpath)/label"/>
          <xsl:with-param name="editInfo" select="gn:element"/>
          <xsl:with-param name="cls" select="local-name()"/>
          <xsl:with-param name="xpath" select="$xpath"/>
          <xsl:with-param name="attributesSnippet" select="$attributes"/>
          <xsl:with-param name="subTreeSnippet">
            <xsl:apply-templates mode="mode-dcat2" select="*">
              <xsl:with-param name="schema" select="$schema"/>
              <xsl:with-param name="labels" select="$labels"/>
            </xsl:apply-templates>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template mode="mode-dcat2" match="skos:Concept" priority="2000">


    <xsl:variable name="existingInScheme" select="normalize-space(skos:inScheme/@rdf:resource)"/>
    <xsl:variable name="createdInSchemeByParentElementName"
                  select="gn-fn-dcat2:getInSchemeURIByElementName(name(..),name(../..))"/>

    <xsl:variable name="inScheme">
      <xsl:choose>
        <xsl:when test="$existingInScheme!=''">
          <xsl:value-of select="$existingInScheme"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$createdInSchemeByParentElementName"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="thesaurusTitle" select="gn-fn-dcat2:getThesaurusTitle($inScheme)"/>

    <xsl:variable name="thesaurusIdentifier" select="gn-fn-dcat2:getThesaurusIdentifier($inScheme)"/>
    <xsl:choose>
      <xsl:when test="$inScheme!=''">
        <xsl:variable name="thesaurusConfig"
                      as="element()?"
                      select="if ($thesaurusList/thesaurus[@key=substring-after($thesaurusIdentifier, 'geonetwork.thesaurus.')])
	                          then $thesaurusList/thesaurus[@key=substring-after($thesaurusIdentifier, 'geonetwork.thesaurus.')]
	                          else $listOfThesaurus/thesaurus[title=$thesaurusTitle]"/>

        <!-- The thesaurus key may be contained in the MD_Identifier field or
          get it from the list of thesaurus based on its title.
          -->
        <xsl:choose>
          <xsl:when test="$thesaurusConfig">
            <xsl:variable name="thesaurusInternalKey"
                          select="if ($thesaurusConfig/@key!='')
		                      then $thesaurusConfig/@key
		                      else $thesaurusConfig/key"/>
            <xsl:variable name="thesaurusKey"
                          select="if (starts-with($thesaurusInternalKey, 'geonetwork.thesaurus.'))
		                      then substring-after($thesaurusInternalKey, 'geonetwork.thesaurus.')
		                      else $thesaurusInternalKey"/>

            <!-- if gui lang eng > #EN -->
            <xsl:variable name="guiLangId"
                          select="
                      if (count(skos:prefLabel[@xml:lang=lower-case(xslutil:twoCharLangCode($lang))]) = 1)
                        then $lang
                        else $metadataLanguage"/>
            <!-- if gui lang eng > #EN -->
            <xsl:variable name="prefLabelLangId" select="lower-case(xslutil:twoCharLangCode($guiLangId))"/>
            <!--
            get keyword in gui lang
            in default language
            -->
            <xsl:variable name="keywords"
                          select="string-join(replace(skos:prefLabel[@xml:lang=$prefLabelLangId], ',', ',,'), ',')"/>

            <!-- Define the list of transformation mode available. -->
            <xsl:variable name="transformations"
                          as="xs:string"
                          select="if ($thesaurusConfig/@transformations != '')
		                              then $thesaurusConfig/@transformations
		                              else 'to-dcat2-concept'"/>

            <!-- Get current transformation mode based on XML fragment analysis -->
            <xsl:variable name="transformation"
                          select="'to-dcat2-concept'"/>

            <xsl:variable name="parentName" select="name(..)"/>

            <!-- Create custom widget:
                  * '' for item selector,
                  * 'tagsinput' for tags
                  * 'tagsinput' and maxTags = 1 for only one tag
                  * 'multiplelist' for multiple selection list
            -->
            <xsl:variable name="widgetMode" select="'tagsinput'"/>
            <!--		        <xsl:variable name="widgetMode" select="'multiplelist'"/>-->
            <xsl:variable name="maxTags"
                          select="if ($thesaurusConfig/@maxtags)
		                              then $thesaurusConfig/@maxtags
		                              else 1"/>
            <!--  				<xsl:variable name="maxTags"
                        select="if ($thesaurusKey = 'external.theme.language') then '1' else ''"/>-->
            <!-- Create a div with the directive configuration
                * elementRef: the element ref to edit
                * elementName: the element name
                * thesaurusName: the thesaurus title to use
                * thesaurusKey: the thesaurus identifier
                * keywords: list of keywords in the element
                * transformations: list of transformations
                * transformation: current transformation
              -->
            <xsl:variable name="allLanguages"
                          select="$metadataLanguage"></xsl:variable>
            <div data-gn-keyword-selector="{$widgetMode}"
                 data-metadata-id="{$metadataId}"
                 data-element-ref="{concat('_X', ../gn:element/@ref, '_replace')}"
                 data-thesaurus-title="{gn-fn-metadata:getLabel($schema, name(), $labels, name(..), '', gn-fn-metadata:getXPath(.))/label}"
                 data-thesaurus-key="{$thesaurusKey}"
                 data-keywords="{$keywords}" data-transformations="{$transformations}"
                 data-current-transformation="{$transformation}"
                 data-max-tags="{$maxTags}"
                 data-lang="{$metadataOtherLanguagesAsJson}"
                 data-textgroup-only="false">
            </div>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="mode-dcat2" select="*"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="mode-dcat2" select="*"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
