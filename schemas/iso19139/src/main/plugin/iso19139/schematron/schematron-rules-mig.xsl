<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is
      the preferred method for meta-stylesheets to use where possible.
    -->
<xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


<!--PROLOG-->
<xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>
   <xsl:include xmlns:svrl="http://purl.oclc.org/dsdl/svrl" href="../../../xsl/utils-fn.xsl"/>
   <xsl:param xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="lang"/>
   <xsl:param xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="thesaurusDir"/>
   <xsl:param xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="rule"/>
   <xsl:variable xmlns:svrl="http://purl.oclc.org/dsdl/svrl" name="loc"
                 select="document(concat('../loc/', $lang, '/', $rule, '.xml'))"/>

   <!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators
    -->
<xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators
    -->
<xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                      and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@
              <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@
        <xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans
      (Top-level element has index)
    -->
<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@
        <xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH-->
<xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2-->
<xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters--><xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
<xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="MIG validation"
                              schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>
         
        <xsl:value-of select="$archiveNameParameter"/>
         
        <xsl:value-of select="$fileNameParameter"/>
         
        <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="http://www.opengis.net/gml" prefix="gml"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gmd" prefix="gmd"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gmx" prefix="gmx"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/srv" prefix="srv"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.isotc211.org/2005/gco" prefix="gco"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.fao.org/geonetwork" prefix="geonet"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2004/02/skos/core#" prefix="skos"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/1999/xlink" prefix="xlink"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/MIG12"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/MIG13"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/MIG16"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/MIG17"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/MIG17"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M13"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/MIG18"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/MIG24"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M15"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/MIG25"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M16"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/MIG41"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M17"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/MIG42"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M18"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/MIG51"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M19"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/MIG52"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M20"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/MIG62"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M21"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/MIG65"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/MIG66"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/MIG70"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M24"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="name">
               <xsl:value-of select="$loc/strings/MIG80"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M25"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">MIG validation</svrl:text>

   <!--PATTERN
        $loc/strings/MIG12-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/MIG12"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gmd:MD_DataIdentification|//*[contains(@gco:isoType, 'MD_DataIdentification')]"
                 priority="1000"
                 mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_DataIdentification|//*[contains(@gco:isoType, 'MD_DataIdentification')]"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/normalize-space(.)!=''"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/normalize-space(.)!=''">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG12A"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/string(@codeListValue)  = ('creation', 'publication', 'revision')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/string(@codeListValue) = ('creation', 'publication', 'revision')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG12B"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="*" mode="M9"/>
   </xsl:template>

   <!--PATTERN
        $loc/strings/MIG13-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/MIG13"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gmd:MD_DataIdentification|    //*[@gco:isoType='gmd:MD_DataIdentification']|    //srv:SV_ServiceIdentification|    //*[@gco:isoType='srv:SV_ServiceIdentification']"
                 priority="1000"
                 mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_DataIdentification|    //*[@gco:isoType='gmd:MD_DataIdentification']|    //srv:SV_ServiceIdentification|    //*[@gco:isoType='srv:SV_ServiceIdentification']"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="(//gmd:identificationInfo/srv:SV_ServiceIdentification|//gmd:identificationInfo/gmd:MD_DataIdentification)//gmd:identifier/*/gmd:code/gco:CharacterString/normalize-space(.)!=''"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="(//gmd:identificationInfo/srv:SV_ServiceIdentification|//gmd:identificationInfo/gmd:MD_DataIdentification)//gmd:identifier/*/gmd:code/gco:CharacterString/normalize-space(.)!=''">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG13A"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>

   <!--PATTERN
        $loc/strings/MIG16-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/MIG16"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gmd:MD_DataIdentification|//srv:SV_ServiceIdentification    |//*[contains(@gco:isoType, 'MD_DataIdentification')]    |//*[contains(@gco:isoType, 'SV_ServiceIdentification')]"
                 priority="1001"
                 mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_DataIdentification|//srv:SV_ServiceIdentification    |//*[contains(@gco:isoType, 'MD_DataIdentification')]    |//*[contains(@gco:isoType, 'SV_ServiceIdentification')]"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="count(gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='pointOfContact'])&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="count(gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='pointOfContact'])&gt;0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG16A"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>

  <!--RULE
      -->
<xsl:template match="//gmd:identificationInfo/*/gmd:pointOfContact    |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:pointOfContact    |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:pointOfContact"
                 priority="1000"
                 mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:identificationInfo/*/gmd:pointOfContact    |//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:pointOfContact    |//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:pointOfContact"/>
      <xsl:variable name="missing"
                    select="not(*/gmd:organisationName)     or (*/gmd:organisationName/@gco:nilReason)     or not(*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress)     or (*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/@gco:nilReason)"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="not($missing)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="not($missing)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:copy-of select="$loc/strings/alert.MIG16B"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>

   <!--PATTERN
        $loc/strings/MIG17-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/MIG17"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gmd:MD_DataIdentification|    //*[@gco:isoType='gmd:MD_DataIdentification']|    //srv:SV_ServiceIdentification|    //*[@gco:isoType='srv:SV_ServiceIdentification']"
                 priority="1000"
                 mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_DataIdentification|    //*[@gco:isoType='gmd:MD_DataIdentification']|    //srv:SV_ServiceIdentification|    //*[@gco:isoType='srv:SV_ServiceIdentification']"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString/normalize-space(.)!=''"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString/normalize-space(.)!=''">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:copy-of select="$loc/strings/alert.MIG17A"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>

   <!--PATTERN
        $loc/strings/MIG17-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/MIG17"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//srv:SV_ServiceIdentification|//*[@gco:isoType='srv:SV_ServiceIdentification']"
                 priority="1000"
                 mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//srv:SV_ServiceIdentification|//*[@gco:isoType='srv:SV_ServiceIdentification']"/>
      <xsl:variable name="inspire-thesaurus"
                    select="document(concat('file:///', $thesaurusDir, '/external/thesauri/theme/httpinspireeceuropaeumetadatacodelistSpatialDataServiceCategory-SpatialDataServiceCategory.rdf'))"/>
      <xsl:variable name="inspire-st" select="$inspire-thesaurus//skos:Concept"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="count($inspire-st) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="count($inspire-st) &gt; 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                INSPIRE service taxonomy thesaurus not found. Check installation in codelist/external/thesauri/theme.
                Download thesaurus from https://geonetwork.svn.sourceforge.net/svnroot/geonetwork/utilities/gemet/thesauri/.
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="keyword"
                    select="gmd:descriptiveKeywords/*/gmd:keyword/gco:CharacterString | gmd:descriptiveKeywords/*/gmd:keyword//gmd:LocalisedCharacterString |     gmd:descriptiveKeywords/*/gmd:keyword/gmx:Anchor"/>
      <xsl:variable name="inspire-theme-found"
                    select="count($inspire-thesaurus//skos:Concept[skos:prefLabel = $keyword])"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$inspire-theme-found &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$inspire-theme-found &gt; 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:copy-of select="$loc/strings/alert.MIG17B"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>

   <!--PATTERN
        $loc/strings/MIG18-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/MIG18"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gmd:MD_DataIdentification|    //*[@gco:isoType='gmd:MD_DataIdentification']|    //srv:SV_ServiceIdentification|    //*[@gco:isoType='srv:SV_ServiceIdentification']"
                 priority="1000"
                 mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_DataIdentification|    //*[@gco:isoType='gmd:MD_DataIdentification']|    //srv:SV_ServiceIdentification|    //*[@gco:isoType='srv:SV_ServiceIdentification']"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="count(gmd:resourceConstraints/gmd:MD_LegalConstraints) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="count(gmd:resourceConstraints/gmd:MD_LegalConstraints) &gt; 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:copy-of select="$loc/strings/alert.MIG18A"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>

   <!--PATTERN
        $loc/strings/MIG24-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/MIG24"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gmd:MD_DataIdentification[../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue=('dataset', 'series')]|//*[contains(@gco:isoType, 'MD_DataIdentification')][../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue=('dataset', 'series')]"
                 priority="1000"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_DataIdentification[../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue=('dataset', 'series')]|//*[contains(@gco:isoType, 'MD_DataIdentification')][../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue=('dataset', 'series')]"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="count(gmd:spatialResolution/gmd:MD_Resolution) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="count(gmd:spatialResolution/gmd:MD_Resolution) &gt; 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG24"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="not(count(gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale) &gt; 0 and       count(gmd:spatialResolution/gmd:MD_Resolution/gmd:distance) &gt; 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="not(count(gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale) &gt; 0 and count(gmd:spatialResolution/gmd:MD_Resolution/gmd:distance) &gt; 0)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG24A"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>

   <!--PATTERN
        $loc/strings/MIG25-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/MIG25"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gmd:MD_DataIdentification|//*[contains(@gco:isoType, 'MD_DataIdentification')]"
                 priority="1000"
                 mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_DataIdentification|//*[contains(@gco:isoType, 'MD_DataIdentification')]"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode/@codeListValue != ''"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode/@codeListValue != ''">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG25"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="@*|node()" priority="-2" mode="M16">
      <xsl:apply-templates select="*" mode="M16"/>
   </xsl:template>

   <!--PATTERN
        $loc/strings/MIG41-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/MIG41"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gmd:MD_DataIdentification[../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue=('dataset', 'series')]|//*[contains(@gco:isoType, 'MD_DataIdentification')][../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue=('dataset', 'series')]"
                 priority="1000"
                 mode="M17">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_DataIdentification[../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue=('dataset', 'series')]|//*[contains(@gco:isoType, 'MD_DataIdentification')][../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue=('dataset', 'series')]"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="count(../../gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="count(../../gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat) &gt; 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG41"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="@*|node()" priority="-2" mode="M17">
      <xsl:apply-templates select="*" mode="M17"/>
   </xsl:template>

   <!--PATTERN
        $loc/strings/MIG42-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/MIG42"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//srv:SV_ServiceIdentification|//*[contains(@gco:isoType, 'SV_ServiceIdentification')]"
                 priority="1000"
                 mode="M18">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//srv:SV_ServiceIdentification|//*[contains(@gco:isoType, 'SV_ServiceIdentification')]"/>
      <xsl:variable name="onlineResource"
                    select="count(../../gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource) &gt; 0"/>
      <xsl:variable name="onlineFunctionCode"
                    select="count(../../gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:function/gmd:CI_OnLineFunctionCode[@codeListValue != '']) &gt; 0"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$onlineResource = true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$onlineResource = true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG42"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$onlineFunctionCode = false()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$onlineFunctionCode = false()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG42A"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="*" mode="M18"/>
   </xsl:template>

   <!--PATTERN
        $loc/strings/MIG51-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/MIG51"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gmd:MD_DataIdentification|//*[contains(@gco:isoType, 'MD_DataIdentification')]"
                 priority="1000"
                 mode="M19">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_DataIdentification|//*[contains(@gco:isoType, 'MD_DataIdentification')]"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="not(count(gmd:extent/*/gmd:verticalElement) &gt; 1)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="not(count(gmd:extent/*/gmd:verticalElement) &gt; 1)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG51"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="@*|node()" priority="-2" mode="M19">
      <xsl:apply-templates select="*" mode="M19"/>
   </xsl:template>

   <!--PATTERN
        $loc/strings/MIG52-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/MIG52"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gmd:MD_DataIdentification|//*[contains(@gco:isoType, 'MD_DataIdentification')]"
                 priority="1000"
                 mode="M20">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:MD_DataIdentification|//*[contains(@gco:isoType, 'MD_DataIdentification')]"/>
      <xsl:variable name="extent"
                    select="(not(../../gmd:hierarchyLevel)      or ../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset'      or ../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='series')      and (count(gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox))=0"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$extent = false()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$extent = false()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG52"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="@*|node()" priority="-2" mode="M20">
      <xsl:apply-templates select="*" mode="M20"/>
   </xsl:template>

   <!--PATTERN
        $loc/strings/MIG62-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/MIG62"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gmd:MD_Metadata" priority="1000" mode="M21">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_Metadata"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="count(gmd:metadataStandardName/gco:CharacterString)&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="count(gmd:metadataStandardName/gco:CharacterString)&gt;0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG62"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="*" mode="M21"/>
   </xsl:template>

   <!--PATTERN
        $loc/strings/MIG65-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/MIG65"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gmd:MD_Metadata" priority="1000" mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_Metadata"/>
      <xsl:variable name="language"
                    select="gmd:language/gco:CharacterString|gmd:language/gmd:LanguageCode/@codeListValue"/>
      <xsl:variable name="language_present"
                    select="geonet:contains-any-of($language,     ('eng', 'fre', 'ger', 'spa', 'dut', 'ita', 'cze', 'lav', 'dan', 'lit', 'mlt',     'pol', 'est', 'por', 'fin', 'rum', 'slo', 'slv', 'gre', 'bul',     'hun', 'swe', 'gle'))"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="$language_present"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="$language_present">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:copy-of select="$loc/strings/alert.MIG65A"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*" mode="M22"/>
   </xsl:template>

   <!--PATTERN
        $loc/strings/MIG66-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/MIG66"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gmd:MD_Metadata" priority="1001" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_Metadata"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="count(gmd:contact/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='pointOfContact'])&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="count(gmd:contact/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='pointOfContact'])&gt;0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG66A"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>

  <!--RULE
      -->
<xsl:template match="gmd:contact" priority="1000" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="gmd:contact"/>
      <xsl:variable name="missing"
                    select="not(*/gmd:organisationName)     or (*/gmd:organisationName/@gco:nilReason)     or not(*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress)     or (*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/@gco:nilReason)"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="not($missing)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="not($missing)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:copy-of select="$loc/strings/alert.MIG66B"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*" mode="M23"/>
   </xsl:template>

   <!--PATTERN
        $loc/strings/MIG70-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/MIG70"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gmd:MD_Metadata" priority="1001" mode="M24">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_Metadata"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="(gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='service') or count(gmd:dataQualityInfo/gmd:DQ_DataQuality) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="(gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='service') or count(gmd:dataQualityInfo/gmd:DQ_DataQuality) &gt; 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG70"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue=gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue=gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG71"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>

  <!--RULE
      -->
<xsl:template match="//gmd:DQ_DataQuality[../../gmd:identificationInfo/gmd:MD_DataIdentification    or ../../gmd:identificationInfo/*/@gco:isoType = 'gmd:MD_DataIdentification']"
                 priority="1000"
                 mode="M24">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//gmd:DQ_DataQuality[../../gmd:identificationInfo/gmd:MD_DataIdentification    or ../../gmd:identificationInfo/*/@gco:isoType = 'gmd:MD_DataIdentification']"/>
      <xsl:variable name="lineage"
                    select="not(gmd:lineage/gmd:LI_Lineage/gmd:statement) or (gmd:lineage//gmd:statement/@gco:nilReason)"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="not($lineage)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="not($lineage)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.M72/div"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*" mode="M24"/>
   </xsl:template>

   <!--PATTERN
        $loc/strings/MIG80-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">
      <xsl:copy-of select="$loc/strings/MIG80"/>
   </svrl:text>

  <!--RULE
      -->
<xsl:template match="//gmd:MD_Metadata" priority="1000" mode="M25">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="//gmd:MD_Metadata"/>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="count(gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code)&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="count(gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code)&gt;0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG80"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

      <!--ASSERT
      -->
<xsl:choose>
         <xsl:when test="count(gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier[gmd:code!='' and gmd:codeSpace!=''])&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" ref="#_{geonet:element/@ref}"
                                test="count(gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier[gmd:code!='' and gmd:codeSpace!=''])&gt;0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:copy-of select="$loc/strings/alert.MIG81"/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*" mode="M25"/>
   </xsl:template>
</xsl:stylesheet>