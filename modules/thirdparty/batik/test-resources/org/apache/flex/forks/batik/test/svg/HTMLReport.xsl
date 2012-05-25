<?xml version="1.0" standalone='no'?>
<!-- ====================================================================== 
     Copyright 2001,2003 The Apache Software Foundation
     
     Licensed under the Apache License, Version 2.0 (the "License");
     you may not use this file except in compliance with the License.
     You may obtain a copy of the License at
     
         http://www.apache.org/licenses/LICENSE-2.0
     
     Unless required by applicable law or agreed to in writing, software
     distributed under the License is distributed on an "AS IS" BASIS,
     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.     
     See the License for the specific language governing permissions and
     limitations under the License.
     ====================================================================== -->

<!-- ========================================================================= -->
<!-- @author vincent.hardy@eng.sun.com                                         -->
<!-- @version $Id: HTMLReport.xsl,v 1.14 2004/08/18 07:16:32 vhardy Exp $ -->
<!-- ========================================================================= -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xlink="http://www.w3.org/2000/xlink/namespace/" >

    <!-- ================================================ -->
    <!-- Top leve template. Produces the overall document -->
    <!-- structure.                                       -->
    <!-- ================================================ -->
    <xsl:template match="/">
        <html>

            <!-- ========= -->
            <!-- HTML head -->
            <!-- ========= -->
            <head>
                <link rel="stylesheet" type="text/css" media="screen" href="../../style/style.css" />
            </head>

            
            <!-- ========== -->
            <!--   BODY     -->
            <!-- ========== -->
            <body style="background-image: url(../../images/background.png);">

                <!-- Report Date information -->
                <table class="reportDate" width="600" border="0" cellpadding="0" cellspacing="0" hspace="0" vspace="0" bgcolor="white">
                    <tr><td class="reportDate"><xsl:value-of select="/testSuiteReport[position()=1]/@date" /></td></tr></table>

                <!-- Report Title containing the ratio of count(success) / count(tests) -->
                <h1>Regard Test Report -- 
                    <xsl:value-of select="count(/descendant::testReport[@status='passed'])" />/<xsl:value-of select="count(/descendant::testReport)" />
                </h1>

                <!-- Only report summary and details if there are failed tests -->
                <xsl:choose>
                    <xsl:when test="count(/descendant::testReport[@status='failed']) &gt; 0">

                        <hr noshade="noshade" size="1" width="600" align="left"/>

                        <!-- ======= -->
                        <!-- Summary -->
                        <!-- ======= -->
                        <xsl:call-template name="summary" />
                        &#160;<br />

                        <!-- ======= -->
                        <!-- Details -->
                        <!-- ======= -->
                        <xsl:call-template name="details" />
                    </xsl:when>
                </xsl:choose>
            </body>

        </html>

    </xsl:template>

    <!-- ============================================= -->
    <!-- Produces the "Details" section of the report  -->
    <!-- ============================================= -->
    <xsl:template name="details">
        <!-- Header -->
        <h2>Report Details</h2>

        <!-- Will produce one table per failed test -->
        <xsl:apply-templates/>

    </xsl:template>

    <!-- ============================================== -->
    <!-- Produces the "Summary" section of the report   -->
    <!-- ============================================== -->
    <xsl:template name="summary">
        <!-- Header -->
        <h2>Failed Leaf Tests</h2>

        <!-- Produces a list with links to the failed tests details -->
        <xsl:call-template name="failedTestsLinks">
            <xsl:with-param name="failedNodes" select="/descendant::testReport[@status='failed']" />
        </xsl:call-template>

        <hr noshade="noshade" size="1" width="600" align="left" />

    </xsl:template>


    <!-- ====================================================== -->
    <!-- Produces a list with links to the failed tests details -->
    <!-- ====================================================== -->
    <xsl:template name="failedTestsLinks">
        <xsl:param name="failedNodes" />
        <ol>
        <xsl:for-each select="$failedNodes">
            <li>
                <a>
                    <xsl:attribute name="href">#<xsl:value-of select="@id" /></xsl:attribute>
                    <xsl:value-of select="@testName" />
                </a>  

            </li>
        </xsl:for-each>
        </ol>                   
    </xsl:template>

    <!-- ======================================================= -->
    <!-- Processes testReport and testSuiteReport elements.      -->
    <!-- For testSuiteReports, the template simply recursively   -->
    <!-- scans the children. For testReports which are failed    -->
    <!-- the template creates a table with the test name, the    -->
    <!-- failure reason and the description entries.             -->
    <!-- ======================================================= -->
    <xsl:template match="testReport | testSuiteReport">
        <xsl:variable name="childrenTests" select="description/testReport" />  
        <xsl:variable name="childrenTestSuites" select="description/testSuiteReport" />
        <xsl:variable name="childrenTestsCount" select="count($childrenTests) + count($childrenTestSuites)" />
        
        <xsl:choose>
            <!-- Process leaf tests which have failed -->
            <xsl:when test="$childrenTestsCount = 0 and @status='failed'">
                <!-- Anchor so that the test can be linked to -->
                <a>
                    <xsl:attribute name="name">
                        <xsl:value-of select="@id" />
                    </xsl:attribute>
                </a>

                <table bgcolor="black" vspace="0" hspace="0" cellspacing="0" cellpadding="0" border="0" width="600"><tr><td>
                    <table bgcolor="black" vspace="0" hspace="0" cellspacing="1" cellpadding="2" border="0" width="600">
                        <tr bgcolor="#eeeeee">     
                            <td colspan="2"><img align="bottom" src="../../images/deco.png" width="16" height="16" />&#160;

                                <font><xsl:attribute name="class">title<xsl:value-of select="@status"/></xsl:attribute>&#160;<xsl:value-of select="@testName" /></font>

                                <xsl:choose>
                                    <xsl:when test="@status='failed'">
                                     &#160;(<xsl:value-of select="@errorCode" />)
                                     &#160;(<xsl:value-of select="@class" />)
                                    </xsl:when>
                                </xsl:choose>

                                <!-- If this is a composite report, add counts of success/failures -->
                                <xsl:choose> 


                                    <xsl:when test="$childrenTestsCount &gt; 0" >
                                    <xsl:variable name="passedChildrenTests" 
                                          select="description/testReport[attribute::status='passed']" />
                                    <xsl:variable name="passedChildrenTestSuites" 
                                          select="description/testSuiteReport[attribute::status='passed']" />

                                    -- &#160;<xsl:value-of select=" count($passedChildrenTests) + count($passedChildrenTestSuites)" /> / 
                                    <xsl:value-of select="$childrenTestsCount" />
                                    </xsl:when>
                                </xsl:choose>

                            </td>
                        </tr>
                        <xsl:apply-templates />
                    </table>
                </td></tr></table>
               <br />

            </xsl:when>

            <!-- Process children reports -->
            <xsl:otherwise>
                <xsl:apply-templates />
            </xsl:otherwise>

        </xsl:choose>
    </xsl:template>

    <!-- =============================== -->
    <!-- Processes a description element -->
    <!-- =============================== -->
    <xsl:template match="description">
        <xsl:apply-templates select="genericEntry | uriEntry | fileEntry" />

        <xsl:apply-templates select="testReport | testSuiteReport">
        </xsl:apply-templates>
    </xsl:template>

    <!-- ================================ -->
    <!-- Processes a genericEntry element -->
    <!-- ================================ -->
    <xsl:template match="genericEntry">
        <tr bgcolor="white">
            <td><xsl:value-of select="@key" /></td>
            <td><xsl:value-of select="@value" /></td>
        </tr>
    </xsl:template>

    <!-- ================================ -->
    <!-- Processes a uriEntry element     -->
    <!-- ================================ -->
    <xsl:template match="uriEntry">
        <tr bgcolor="white" margin-left="50pt">
            <td><xsl:value-of select="@key" /></td>
            <xsl:variable name="value" select="@value" />
            <td><a target="image" href="{$value}"><img height="150" src="{$value}" /></a></td>
        </tr>
    </xsl:template>

    <!-- ================================ -->
    <!-- Processes a fileEntry element    -->
    <!-- Assumes the file is an image.    -->
    <!-- ================================ -->
    <xsl:template match="fileEntry">
        <tr bgcolor="white">
            <td><xsl:value-of select="@key" /></td>
            <xsl:variable name="value" select="@value" />
            <td><a target="image" href="{$value}"><img height="150" src="{$value}" /></a></td>
        </tr>
    </xsl:template>
</xsl:stylesheet>