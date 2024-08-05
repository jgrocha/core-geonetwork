<?xml version="1.0" encoding="UTF-8" standalone="yes"?>

<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    queryBinding="xslt2">

    <sch:title xmlns="http://www.w3.org/2001/XMLSchema">MIG validation</sch:title>
    <sch:ns prefix="gml" uri="http://www.opengis.net/gml"/>
    <sch:ns prefix="gmd" uri="http://www.isotc211.org/2005/gmd"/>
    <sch:ns prefix="gmx" uri="http://www.isotc211.org/2005/gmx"/>
    <sch:ns prefix="srv" uri="http://www.isotc211.org/2005/srv"/>
    <sch:ns prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
    <sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
    <sch:ns prefix="skos" uri="http://www.w3.org/2004/02/skos/core#"/>
    <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>

	<sch:pattern>
		<sch:title>$loc/strings/MIG12</sch:title>
		<sch:rule context="//gmd:MD_DataIdentification|//*[contains(@gco:isoType, 'MD_DataIdentification')]">
			<sch:assert
				test="gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:date/normalize-space(.)!=''"
				>$loc/strings/alert.MIG12A</sch:assert>
			<sch:assert
				test="gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode/string(@codeListValue)  = ('creation', 'publication', 'revision')"
				>$loc/strings/alert.MIG12B</sch:assert>				
		</sch:rule>
	</sch:pattern>
	
    <sch:pattern>
        <sch:title>$loc/strings/MIG13</sch:title>
        <sch:rule context="//gmd:MD_DataIdentification|
			//*[@gco:isoType='gmd:MD_DataIdentification']|
			//srv:SV_ServiceIdentification|
			//*[@gco:isoType='srv:SV_ServiceIdentification']">

            <sch:assert test="(//gmd:identificationInfo/srv:SV_ServiceIdentification|//gmd:identificationInfo/gmd:MD_DataIdentification)//gmd:identifier/*/gmd:code/gco:CharacterString/normalize-space(.)!=''">$loc/strings/alert.MIG13A</sch:assert>
       </sch:rule>
	</sch:pattern>	
	
	<sch:pattern>
		<sch:title>$loc/strings/MIG16</sch:title>
		<!--
		<sch:rule context="//gmd:MD_DataIdentification|//*[contains(@gco:isoType, 'MD_DataIdentification')]">
			<sch:assert
				test="count(gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='pointOfContact'])>0"
				>$loc/strings/alert.MIG16A</sch:assert>
		</sch:rule>
		-->
		<sch:rule context="//gmd:MD_DataIdentification|//srv:SV_ServiceIdentification
			|//*[contains(@gco:isoType, 'MD_DataIdentification')]
			|//*[contains(@gco:isoType, 'SV_ServiceIdentification')]">
			<sch:assert
				test="count(gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='pointOfContact'])>0"
				>$loc/strings/alert.MIG16A</sch:assert>
		</sch:rule>	
        <sch:rule context="//gmd:identificationInfo/*/gmd:pointOfContact
			|//*[@gco:isoType='gmd:MD_DataIdentification']/gmd:pointOfContact
			|//*[@gco:isoType='srv:SV_ServiceIdentification']/gmd:pointOfContact">		
            <sch:let name="missing" value="not(*/gmd:organisationName)
				or (*/gmd:organisationName/@gco:nilReason)
				or not(*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress)
				or (*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/@gco:nilReason)"/>			
            <sch:assert
                test="not($missing)"
				><sch:value-of select="$loc/strings/alert.MIG16B"/></sch:assert>
        </sch:rule>		
	</sch:pattern>
	
	
    <sch:pattern>
        <sch:title>$loc/strings/MIG17</sch:title>
        <sch:rule context="//gmd:MD_DataIdentification|
			//*[@gco:isoType='gmd:MD_DataIdentification']|
			//srv:SV_ServiceIdentification|
			//*[@gco:isoType='srv:SV_ServiceIdentification']">
            <sch:assert test="gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/gco:CharacterString/normalize-space(.)!=''">
                <sch:value-of select="$loc/strings/alert.MIG17A"/>
            </sch:assert>
       </sch:rule>
	</sch:pattern>	
		
    
	<sch:pattern>
        <sch:title>$loc/strings/MIG17</sch:title>

        <sch:rule context="//srv:SV_ServiceIdentification|//*[@gco:isoType='srv:SV_ServiceIdentification']">
            <!-- Check that INSPIRE service taxonomy is available.
                Use INSPIRE thesaurus available on SVN to check keywords in all EU languages.
            -->
            <!--
            httpinspireeceuropaeumetadatacodelistSpatialDataServiceCategory-SpatialDataServiceCategory.rdf
            -->
            <sch:let name="inspire-thesaurus" value="document(concat('file:///', $thesaurusDir, '/external/thesauri/theme/httpinspireeceuropaeumetadatacodelistSpatialDataServiceCategory-SpatialDataServiceCategory.rdf'))"/>
            <sch:let name="inspire-st" value="$inspire-thesaurus//skos:Concept"/>

            <!-- Display error if INSPIRE thesaurus is not available. -->
            <sch:assert test="count($inspire-st) > 0">
                INSPIRE service taxonomy thesaurus not found. Check installation in codelist/external/thesauri/theme.
                Download thesaurus from https://geonetwork.svn.sourceforge.net/svnroot/geonetwork/utilities/gemet/thesauri/.
            </sch:assert>


            <sch:let name="keyword"
                value="gmd:descriptiveKeywords/*/gmd:keyword/gco:CharacterString | gmd:descriptiveKeywords/*/gmd:keyword//gmd:LocalisedCharacterString |
				gmd:descriptiveKeywords/*/gmd:keyword/gmx:Anchor"/>
            <sch:let name="inspire-theme-found"
                value="count($inspire-thesaurus//skos:Concept[skos:prefLabel = $keyword])"/>
            <sch:assert test="$inspire-theme-found > 0">
                <sch:value-of select="$loc/strings/alert.MIG17B"/>
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    
        
    <sch:pattern>
        <sch:title>$loc/strings/MIG18</sch:title>
        <sch:rule context="//gmd:MD_DataIdentification|
			//*[@gco:isoType='gmd:MD_DataIdentification']|
			//srv:SV_ServiceIdentification|
			//*[@gco:isoType='srv:SV_ServiceIdentification']">
            <sch:assert test="count(gmd:resourceConstraints/gmd:MD_LegalConstraints) > 0">
                <sch:value-of select="$loc/strings/alert.MIG18A"/>
            </sch:assert>
       </sch:rule>
	</sch:pattern>
    

	<sch:pattern>
		<sch:title>$loc/strings/MIG24</sch:title>
		<sch:rule context="//gmd:MD_DataIdentification[../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue=('dataset', 'series')]|//*[contains(@gco:isoType, 'MD_DataIdentification')][../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue=('dataset', 'series')]">
			<sch:assert
				test="count(gmd:spatialResolution/gmd:MD_Resolution) > 0"
				>$loc/strings/alert.MIG24</sch:assert>
			<sch:assert
				test="not(count(gmd:spatialResolution/gmd:MD_Resolution/gmd:equivalentScale) > 0 and 
					count(gmd:spatialResolution/gmd:MD_Resolution/gmd:distance) > 0)"
				>$loc/strings/alert.MIG24A</sch:assert>				
		</sch:rule>
	</sch:pattern>
	
	<sch:pattern>
		<sch:title>$loc/strings/MIG25</sch:title>
		<sch:rule context="//gmd:MD_DataIdentification|//*[contains(@gco:isoType, 'MD_DataIdentification')]">
			<sch:assert
				test="gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode/@codeListValue != ''"
				>$loc/strings/alert.MIG25</sch:assert>			
		</sch:rule>
	</sch:pattern>
	
	
	<sch:pattern>
		<sch:title>$loc/strings/MIG41</sch:title>
		<sch:rule context="//gmd:MD_DataIdentification[../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue=('dataset', 'series')]|//*[contains(@gco:isoType, 'MD_DataIdentification')][../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue=('dataset', 'series')]">
			<sch:assert
				test="count(../../gmd:distributionInfo/gmd:MD_Distribution/gmd:distributionFormat) > 0"
				>$loc/strings/alert.MIG41</sch:assert>			
		</sch:rule>
	</sch:pattern>	
		
	<sch:pattern>
		<sch:title>$loc/strings/MIG42</sch:title>
		<sch:rule context="//srv:SV_ServiceIdentification|//*[contains(@gco:isoType, 'SV_ServiceIdentification')]">
			<sch:let name="onlineResource" value="count(../../gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource) > 0"/> 
			<sch:let name="onlineFunctionCode" value="count(../../gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:function/gmd:CI_OnLineFunctionCode[@codeListValue != '']) > 0"/>
		
			<sch:assert
				test="$onlineResource = true()"
				>$loc/strings/alert.MIG42</sch:assert>
				
			<sch:assert
				test="$onlineFunctionCode = false()"
				>$loc/strings/alert.MIG42A</sch:assert>
		</sch:rule>
	</sch:pattern>		


	<sch:pattern>
		<sch:title>$loc/strings/MIG51</sch:title>
		<sch:rule context="//gmd:MD_DataIdentification|//*[contains(@gco:isoType, 'MD_DataIdentification')]">
			<sch:assert
				test="not(count(gmd:extent/*/gmd:verticalElement) > 1)"
				>$loc/strings/alert.MIG51</sch:assert>			
		</sch:rule>
	</sch:pattern>	

	<sch:pattern>
		<sch:title>$loc/strings/MIG52</sch:title>
		<sch:rule context="//gmd:MD_DataIdentification|//*[contains(@gco:isoType, 'MD_DataIdentification')]">
			<sch:let name="extent" value="(not(../../gmd:hierarchyLevel) 
				or ../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='dataset' 
				or ../../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='series') 
				and (count(gmd:extent/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox))=0"/>
			<sch:assert
				test="$extent = false()"
				>$loc/strings/alert.MIG52</sch:assert>
		</sch:rule>
	</sch:pattern>
	
	<sch:pattern>
		<sch:title>$loc/strings/MIG62</sch:title>		
		<sch:rule context="//gmd:MD_Metadata">
			<sch:assert
				test="count(gmd:metadataStandardName/gco:CharacterString)>0"
				>$loc/strings/alert.MIG62</sch:assert>
		</sch:rule>
	</sch:pattern>

	<sch:pattern>
		<sch:title>$loc/strings/MIG65</sch:title>
		<sch:rule context="//gmd:MD_Metadata">
            <!--  Language -->
            <sch:let name="language" value="gmd:language/gco:CharacterString|gmd:language/gmd:LanguageCode/@codeListValue"/>
            <sch:let name="language_present" value="geonet:contains-any-of($language,
				('eng', 'fre', 'ger', 'spa', 'dut', 'ita', 'cze', 'lav', 'dan', 'lit', 'mlt',
				'pol', 'est', 'por', 'fin', 'rum', 'slo', 'slv', 'gre', 'bul',
				'hun', 'swe', 'gle'))"/>

            <sch:assert test="$language_present">
                <sch:value-of select="$loc/strings/alert.MIG65A"/>
            </sch:assert>
		</sch:rule>		
	</sch:pattern>

	<sch:pattern>
		<sch:title>$loc/strings/MIG66</sch:title>
		<sch:rule context="//gmd:MD_Metadata">
			<sch:assert
				test="count(gmd:contact/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue='pointOfContact'])>0"
				>$loc/strings/alert.MIG66A</sch:assert>
		</sch:rule>
        <sch:rule context="gmd:contact">		
            <sch:let name="missing" value="not(*/gmd:organisationName)
				or (*/gmd:organisationName/@gco:nilReason)
				or not(*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress)
				or (*/gmd:contactInfo/*/gmd:address/*/gmd:electronicMailAddress/@gco:nilReason)"/>			
            <sch:assert
                test="not($missing)"
				><sch:value-of select="$loc/strings/alert.MIG66B"/></sch:assert>
        </sch:rule>			
	</sch:pattern>
		
	
	<sch:pattern>
		<sch:title>$loc/strings/MIG70</sch:title>
		<sch:rule context="//gmd:MD_Metadata">
			<sch:assert
				test="(gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue='service') or count(gmd:dataQualityInfo/gmd:DQ_DataQuality) > 0"
				>$loc/strings/alert.MIG70</sch:assert>

			<sch:assert
				test="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue=gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue"
				>$loc/strings/alert.MIG71</sch:assert>								
		</sch:rule>
		
        <sch:rule context="//gmd:DQ_DataQuality[../../gmd:identificationInfo/gmd:MD_DataIdentification
			or ../../gmd:identificationInfo/*/@gco:isoType = 'gmd:MD_DataIdentification']">
            <sch:let name="lineage" value="not(gmd:lineage/gmd:LI_Lineage/gmd:statement) or (gmd:lineage//gmd:statement/@gco:nilReason)"/>
            <sch:assert test="not($lineage)"
                >$loc/strings/alert.M72/div</sch:assert>
        </sch:rule>		
	</sch:pattern>			
	
	<sch:pattern>
		<sch:title>$loc/strings/MIG80</sch:title>
		<sch:rule context="//gmd:MD_Metadata">
			<sch:assert
				test="count(gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code)>0"
				>$loc/strings/alert.MIG80</sch:assert>
				
			<sch:assert
				test="count(gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier[gmd:code!='' and gmd:codeSpace!=''])>0"
				>$loc/strings/alert.MIG81</sch:assert>
		</sch:rule>
	</sch:pattern>	
	
</sch:schema>
