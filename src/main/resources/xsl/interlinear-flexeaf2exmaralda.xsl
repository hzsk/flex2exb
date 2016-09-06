<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:my="http://www.philol.msu.ru/~languedoc/xml"
    exclude-result-prefixes="#all"
    version="2.0">

    <xsl:output method="xml" indent="yes" encoding="utf-8" omit-xml-declaration="no"/>
    <xsl:namespace-alias stylesheet-prefix="#default" result-prefix=""/>

    <xsl:param name="timestart" as="xs:decimal" select="4.0"/> <!-- Time offset for first word -->
    <xsl:param name="timestep" as="xs:decimal" select="0.5"/> <!-- Mean word length in sec -->
    
    <xsl:param name="language" required="no" />
    
    <!-- This stylesheet was downloaded from GitHub and based upon this file:
    
    https://github.com/sarkipo/xsl4interlinear/blob/master/interlinear-flexeaf2exmaralda.xsl
    
    Modifications have been done by Niko Partanen. There are comments below, but I summarize here
    the main issues:
    
    - Utterances are now stripped from their punctuations
    - The tokens have the punctuation attached into them
    
    However, I think decisions with these things are also very much related to the exact format
    we want to have in the final files.
    
    -->
    <xsl:template match="/">
        <basic-transcription>
            <head>
                <meta-information>
                    <!-- The project name doesn't seem to be present in the .flextext export. 
                         Other meta information comes nicely through. -->
                    <project-name>Niko's test</project-name>
                    <transcription-name><xsl:value-of select="/*/*/item[@type='title'][1]"/></transcription-name>
                    <referenced-file url="{concat(/*/*/item[@type='title'][1],'.wav')}"/>
                    <ud-meta-information/>
                    <comment><xsl:value-of select="/*/*/item[@type='comment']"/></comment>
                    <transcription-convention/>
                </meta-information>
                <!-- Something should be done with this. Is it possible this data is not present in
                     the FLEx file? In this case it should be inserted to .exb file from elsewhere?
                     Or should the metadata be stored entirely outside the .exb files i.e. in Coma? -->
                <speakertable>
                    <speaker id="SPK_unknown">
                        <abbreviation>SPK</abbreviation>
                        <sex value="m"/>
                        <languages-used/>
                        <l1/>
                        <l2/>
                        <ud-speaker-information><xsl:text> </xsl:text></ud-speaker-information>
                        <comment/>
                    </speaker>
                </speakertable>
            </head>
            <basic-body>
                <!-- This works well. -->
                <common-timeline>
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="tsnumber" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <tli id="{concat('T',$tsnumber)}" time="{format-number($timestart + $timestep*$tsnumber, '#0.0##')}" type="appl"/>
                        <xsl:for-each select="current()//word[item/@type!='punct']">
                            <tli id="{concat('T',$tsnumber+position())}" time="{format-number($timestart + $timestep*($tsnumber+position()),'#0.0##')}" type="appl"/>
                        </xsl:for-each>
                    </xsl:for-each>
                </common-timeline>
                
                <!-- SEGNUM - PHRASE NUMBERS -->
                <!-- This works well. -->
                <tier  id="segnum-en" speaker="SPK_unknown" category="ref" type="d" display-name="ref">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:variable name="ts-end" select="$ts-start+count(.//word[item/@type!='punct'])"/>
                        <event start="{concat('T',$ts-start)}" end="{concat('T',$ts-end)}">
                            <xsl:value-of select="./item[@type='segnum' and @lang='en']"></xsl:value-of>
                        </event>
                    </xsl:for-each>
                </tier>
                
                <!-- FULL SENTENCE TEXT in LATIN transcription -->
                <!-- This needed some tweaking, it seems that in the other version the word units were stored
                     in a slightly different XML node. I leave here for now the tiers for both Cyrillic and Latin
                     transcriptions, though I guess we don't know yet how we will have it in future ourselves.
                
                -->

                <tier id="phrase-txt-lat" speaker="SPK_unknown" category="txt" type="t" display-name="txt-lat">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./words/preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:variable name="ts-end" select="$ts-start+count(.//word[item/@type!='punct'])"/>
                        <event start="{concat('T',$ts-start)}" end="{concat('T',$ts-end)}">
                            <xsl:value-of select="./words/word/item[@type='txt' and @lang=$language]"></xsl:value-of>
                        </event>
                    </xsl:for-each>
                </tier>

		<!-- I commented out the Cyrillic text, as it doesn't exist in the export. -->
                <!-- FULL SENTENCE TEXT in CYRILLIC transcription 
                <tier id="phrase-txt-nio-cyr" speaker="SPK_unknown" category="txt" type="t" display-name="txt-nio-cyr">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:variable name="ts-end" select="$ts-start+count(.//word[item/@type!='punct'])"/>
                        <event start="{concat('T',$ts-start)}" end="{concat('T',$ts-end)}">
                            <xsl:value-of select="./item[@type='txt' and @lang='nio-x-cyr']"></xsl:value-of>
                        </event>
                    </xsl:for-each>
                </tier>
                -->
                
                <!-- SENTENCE FREE TRANSLATION in ENGLISH -->
                <!-- Here one had to change the language id. -->
                <tier id="phrase-ft-en" speaker="SPK_unknown" category="ft" type="d" display-name="ft-en">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:variable name="ts-end" select="$ts-start+count(.//word[item/@type!='punct'])"/>
                        <event start="{concat('T',$ts-start)}" end="{concat('T',$ts-end)}">
                            <xsl:value-of select="./item[@type='gls' and @lang='en']"></xsl:value-of>
                        </event>
                    </xsl:for-each>
                </tier>
                
                <!-- SENTENCE FREE TRANSLATION in RUSSIAN -->
                <!-- In the demo file there is only Portuguese translation, but I guess in our case we'll have some
                     others too. -->
                <tier id="phrase-ft-ru" speaker="SPK_unknown" category="ft" type="d" display-name="ft-ru">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:variable name="ts-end" select="$ts-start+count(.//word[item/@type!='punct'])"/>
                        <event start="{concat('T',$ts-start)}" end="{concat('T',$ts-end)}">
                            <xsl:value-of select="./item[@type='gls' and @lang='ru']"></xsl:value-of>
                        </event>
                    </xsl:for-each>
                </tier>
                
                <!-- SENTENCE NOTES -->
                
                <tier id="phrase-note" speaker="SPK_unknown" category="nt" type="d" display-name="nt">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:variable name="ts-end" select="$ts-start+count(.//word[item/@type!='punct'])"/>
                        <xsl:if test="./item[@type='note']">
                            <event start="{concat('T',$ts-start)}" end="{concat('T',$ts-end)}">
                                <xsl:value-of select="./item[@type='note']" separator=" || "></xsl:value-of>
                            </event>
                        </xsl:if>
                    </xsl:for-each>
                </tier>
                
                <!-- NOW WORD-LEVEL -->                
                <!-- WORD TRANSCRIPTION (~TX) -->
                <!-- I think the punctuation here is not treated exactly as it should?
                     Now the result is such that the token, when followed by punctuation, is sticked together with the following
                     punctuation character, so we have strings like "uxu,", whereas I guess we should have "uxu" and ",".
                     The punctuation characters do not have have any information about themselves in the export file,
                     they are just like this: 
                
                     <word>
                     <item type="punct" lang="seh">?</item>
                     </word>
                     
                     I guess in this case one could take the punctuation characters and generate for them some glosses
                     and POS tags, just marking that they are punctuation characters. I think this structure may become
                     problematic later? However, in this case we would also need to count the punctuation characters
                     differently while creating the timeslots upper.
                -->
                
                <tier id="word-txt" speaker="SPK_unknown" category="txt" type="t" display-name="tx">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:for-each-group select=".//word" group-starting-with="word[item/@type!='punct' and preceding-sibling::word/item/@type!='punct']">
                            <!-- WHEN SENTENCE STARTS WITH PUNCTUATION, IT IS STICKED TO THE FIRST WORD -->
                            <event start="{concat('T',$ts-start+position()-1)}" end="{concat('T',$ts-start+position())}">
                                <xsl:variable name="value"><xsl:value-of select="current-group()/item[@type='txt' or @type='punct']" separator=""/></xsl:variable>
                                <xsl:value-of select="my:cleanup-tx($value)"/>
                            </event>
                        </xsl:for-each-group>
                    </xsl:for-each>
                </tier>
                
                <!-- FIRST MORPH-LEVEL -->                
                <!-- MORPH SURFACE FORM (~MD) -->
		<!-- This has to be done once for English -->
                <tier id="morph-txt-stem" speaker="SPK_unknown" category="txt" type="a" display-name="md-en-stem">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:for-each-group select=".//word" group-starting-with="word[item/@type!='punct' and preceding-sibling::word/item/@type!='punct']">
                            <!-- WHEN SENTENCE STARTS WITH PUNCTUATION, IT IS STICKED TO THE FIRST WORD -->
                            <event start="{concat('T',$ts-start+position()-1)}" end="{concat('T',$ts-start+position())}">
                                <xsl:variable name="value"><xsl:value-of select="current-group()//item[@type='gls' and @lang='en'][../@type='stem']" separator=""/></xsl:variable>
                                <xsl:value-of select="my:cleanup-morph($value)"/>
                            </event>
                        </xsl:for-each-group>
                    </xsl:for-each>
                </tier>

                <!-- MORPH SURFACE FORM (~MD) -->
		<!-- And repeated for Russian -->
                <tier id="morph-ru-stem" speaker="SPK_unknown" category="txt" type="a" display-name="md-ru-stem">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:for-each-group select=".//word" group-starting-with="word[item/@type!='punct' and preceding-sibling::word/item/@type!='punct']">
                            <!-- WHEN SENTENCE STARTS WITH PUNCTUATION, IT IS STICKED TO THE FIRST WORD -->
                            <event start="{concat('T',$ts-start+position()-1)}" end="{concat('T',$ts-start+position())}">
                                <xsl:variable name="value"><xsl:value-of select="current-group()//item[@type='gls' and @lang='ru'][../@type='stem']" separator=""/></xsl:variable>
                                <xsl:value-of select="my:cleanup-morph($value)"/>
                            </event>
                        </xsl:for-each-group>
                    </xsl:for-each>
                </tier>


                <!-- Here we have the stems and suffixes placed together into one string. -->

		    <tier id="morph-string" speaker="SPK_unknown" category="txt" type="a" display-name="md-string-surf">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:for-each-group select=".//word" group-starting-with="word[item/@type!='punct' and preceding-sibling::word/item/@type!='punct']">
                            <!-- WHEN SENTENCE STARTS WITH PUNCTUATION, IT IS STICKED TO THE FIRST WORD -->
                            <event start="{concat('T',$ts-start+position()-1)}" end="{concat('T',$ts-start+position())}">
                                <xsl:variable name="value"><xsl:value-of select="current-group()//morphemes/morph/item[@type='txt']" separator=""/></xsl:variable>
                                <xsl:value-of select="my:cleanup-morph($value)"/>
                            </event>
                        </xsl:for-each-group>
                    </xsl:for-each>
                </tier>

		    <tier id="morph-string-abstr" speaker="SPK_unknown" category="txt" type="a" display-name="md-string-abstr">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:for-each-group select=".//word" group-starting-with="word[item/@type!='punct' and preceding-sibling::word/item/@type!='punct']">
                            <!-- WHEN SENTENCE STARTS WITH PUNCTUATION, IT IS STICKED TO THE FIRST WORD -->
                            <event start="{concat('T',$ts-start+position()-1)}" end="{concat('T',$ts-start+position())}">
                                <xsl:variable name="value"><xsl:value-of select="current-group()//morphemes/morph/item[@type='cf']" separator=""/></xsl:variable>
                                <xsl:value-of select="my:cleanup-morph($value)"/>
                            </event>
                        </xsl:for-each-group>
                    </xsl:for-each>
                </tier>

		<!-- Here we take the glossed elements, both stems and suffixes, and put them together. If we want to use Leipzig glossing standards, 
		     then this has to be set up in a more complicated way -->

		    <tier id="morph" speaker="SPK_unknown" category="txt" type="a" display-name="md">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:for-each-group select=".//word" group-starting-with="word[item/@type!='punct' and preceding-sibling::word/item/@type!='punct']">
                            <!-- WHEN SENTENCE STARTS WITH PUNCTUATION, IT IS STICKED TO THE FIRST WORD -->
                            <event start="{concat('T',$ts-start+position()-1)}" end="{concat('T',$ts-start+position())}">
                                <xsl:variable name="value"><xsl:value-of select="current-group()//morphemes/morph/item[@type='gls' and @lang='en']" separator="-"/></xsl:variable>
                                <xsl:value-of select="my:cleanup-morph($value)"/>
                            </event>
                        </xsl:for-each-group>
                    </xsl:for-each>
                </tier>
		
		<!-- The same is done for the pos-tagging as well -->

		    <tier id="pos" speaker="SPK_unknown" category="txt" type="a" display-name="pos">
                    <xsl:for-each select="//phrase">
                        <xsl:variable name="ts-start" select="count(./preceding::word[item/@type!='punct'])+position()-1"/>
                        <xsl:for-each-group select=".//word" group-starting-with="word[item/@type!='punct' and preceding-sibling::word/item/@type!='punct']">
                            <!-- WHEN SENTENCE STARTS WITH PUNCTUATION, IT IS STICKED TO THE FIRST WORD -->
                            <event start="{concat('T',$ts-start+position()-1)}" end="{concat('T',$ts-start+position())}">
                                <xsl:variable name="value"><xsl:value-of select="current-group()//morphemes/morph/item[@type='msa' and @lang='en']" separator="-"/></xsl:variable>
                                <xsl:value-of select="my:cleanup-morph($value)"/>
                            </event>
                        </xsl:for-each-group>
                    </xsl:for-each>
                </tier>
                
            </basic-body>
        </basic-transcription>
    </xsl:template> 
    
    <xsl:function name="my:cleanup-tx" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of select="concat($in,' ')"/>
        <!-- attach one space -->
    </xsl:function>

    <xsl:function name="my:cleanup-morph" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of select="replace($in,'(-\^0$| )','')"/>
        <!-- strip final -^0 and remove the spaces-->
    </xsl:function>
    
    <xsl:function name="my:cleanup-gloss" as="xs:string">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of select="replace($in,'-(\[.+\])','.$1')"/>
        <!-- put . instead of - before [...] -->
    </xsl:function>
   
        <!-- insert the tierformat-table (copied a formatting template) -->
    <xsl:variable name="format-table">
        <tierformat-table>
            <timeline-item-format show-every-nth-numbering="1" show-every-nth-absolute="1" absolute-time-format="time"
                miliseconds-digits="1"/>
            <tier-format tierref="ref">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="st">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Bold</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="ts">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">#R00G99B33</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="tx">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">#R00G00B99</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="mb">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="mp">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="gr">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="ge">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="go">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="mc">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="ps">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="SeR">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="SyF">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="IST">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="#">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="fe">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="fr">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">#RccG00B00</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="nt">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="EMPTY">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">white</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">2</property>
                <property name="font-name">Charis</property>
            </tier-format>
            <tier-format tierref="ROW-LABEL">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Bold</property>
                <property name="font-color">blue</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Times New Roman</property>
            </tier-format>
            <tier-format tierref="SUB-ROW-LABEL">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Right</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">8</property>
                <property name="font-name">Times New Roman</property>
            </tier-format>
            <tier-format tierref="EMPTY-EDITOR">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">white</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">lightGray</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">2</property>
                <property name="font-name">Charis</property>
            </tier-format>
            <tier-format tierref="COLUMN-LABEL">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">blue</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis</property>
            </tier-format>
            <tier-format tierref="TIE0">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="TIE4">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="TIE3">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="TIE2">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
            <tier-format tierref="TIE1">
                <property name="row-height-calculation">Generous</property>
                <property name="fixed-row-height">10</property>
                <property name="font-face">Plain</property>
                <property name="font-color">black</property>
                <property name="chunk-border-style">solid</property>
                <property name="bg-color">white</property>
                <property name="text-alignment">Left</property>
                <property name="chunk-border-color">#R00G00B00</property>
                <property name="chunk-border"/>
                <property name="font-size">12</property>
                <property name="font-name">Charis SIL</property>
            </tier-format>
        </tierformat-table>
    </xsl:variable>
 
</xsl:stylesheet>
