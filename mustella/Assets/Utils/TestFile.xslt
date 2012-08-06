<?xml version="1.0" encoding="iso-8859-1"?>
<!--

  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

-->
<xsl:stylesheet 
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mx="http://www.adobe.com/2006/mxml"
    >
    
    <xsl:template match="/">
        <html>
            <head>
                <title>Mustella Test File Viewer</title>
                <script type="text/javascript">
                    function toggle_visibility(contentTarget, imageTarget)
                    {
                        var target = document.getElementById(contentTarget);

                        if(imageTarget != null)
                        {
                            var image = document.getElementById(imageTarget);

                            if(target.style.display == 'block')
                            {
                                image.src = 'plus.jpg'
                            }
                            else
                            {
                                image.src = 'minus.jpg'
                            }
                        }
                        
                        if(target.style.display == 'block')
                        {
                            target.style.display = 'none';
                        }
                        else
                        {
                            target.style.display = 'block';
                        }
                    }
                </script>
                <style>
                    <!-- Override layout -->
                    body
                    {
                        font-family:Verdana;
                        font-size:10px;
                        color:#7788FF;
                    }
                    
                    
                    <!-- Custom layout -->
                    .sectionTitle
                    {
                        color:Red; 
                        font-weight:bold;
                    }
                    
                    .testCaseIndexHeader
                    {
                        cursor: pointer;
                    }

                    .testCaseIndex
                    {
                        font-size:10px;
                    }
                    
                    .testCaseHeader
                    {
                        color: #000000;
                        padding-left: 10px;
                        width: 100%;
                        font-size:10px;
                        cursor: pointer;
                        height: 19px;
                    }
                    
                    .actionScriptHeader
                    {
                        cursor: pointer;
                    }
                    
                    .actionScript
                    {
                        color: Green;
                        font-size: 14px;
                    }
                    
                    .metaDataHeader
                    {
                        cursor: pointer;
                    }
                    
                    .metaData
                    {
                        color: DarkOrange;
                        font-size: 14px;
                    }
                    
                   
                    <!-- Test regions -->
                    .testSetup
                    {
                        font-size: 14px;
                        font-weight:bold; 
                        padding-left:20px; 
                        color:#005500;
                    }
                    
                    .testBody
                    {
                        font-size: 14px;
                        font-weight:bold; 
                        padding-left:20px; 
                        color:#005500;
                    }
                    
                    .testCleanup
                    {
                    }
                    

                    <!-- Test commands -->
                    .runCode
                    {
                        color: Green;
                        text-decoration: underline;
                        font-size: 12px;
                        cursor: pointer;
                    }
                    
                    .resetComponent
                    {
                        color: Green;
                        text-decoration: underline;
                        font-size: 12px;
                        cursor: pointer;
                    }
                    
                    .assertPropertyValue
                    {
                        color: Green;
                        text-decoration: underline;
                        font-size: 12px;
                        cursor: pointer;
                    }
                    
                    .assertPixelValue
                    {
                        color: Green;
                        text-decoration: underline;
                        font-size: 12px;
                        cursor: pointer;
                    }
                </style>
            </head>
            <body>
                <!-- Page header -->
                <div class="sectionTitle">
                    Test File Viewer - (Loaded From: 
                    <a>
                        <xsl:attribute name="href"><xsl:value-of select="UnitTester/@testSWF"/></xsl:attribute>
                        <xsl:value-of select="UnitTester/@testSWF"/>
                    </a>)
                </div> 
                <hr/>
                <br/>
                <br/>

                <!-- Test case index -->
                <!-- Default script-->
                <a name="testCaseIndex" />
                <div class="testCaseIndexHeader" onclick="toggle_visibility('div_TestCaseIndex', 'img_TestCaseIndex');">
                    <img id="img_TestCaseIndex" src="minus.jpg" border="0" alt="0"/> - <b>Test Case Index</b>
                </div>
                <div id="div_TestCaseIndex">
                    <br/>
                    <xsl:for-each select="UnitTester/testCases/TestCase">
                        <xsl:sort select="@testID"/>
                        <tr>
                            <td class="testCaseIndex" style="padding-left: 23px">
                                <a onclick="toggle_visibility('div_{generate-id()}', 'img_{generate-id()}');">
                                    <xsl:attribute name="href">
                                        #<xsl:value-of select="@testID"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="@testID"/>
                                </a>
                            </td>
                        </tr>
                    </xsl:for-each>
                </div>
                <br/>
                <br/>

                <!-- Default script-->
                <div class="actionScriptHeader" onclick="toggle_visibility('div_Actionscript', 'img_Actionscript');">
                    <img id="img_Actionscript" src="plus.jpg" border="0" alt="0"/> - <b>ActionScript</b>
                </div>
                <div id="div_Actionscript" style="display: none;">
                    <pre class="actionScript">
                    <xsl:value-of select="UnitTester/mx:Script"/>
                    </pre>
                </div>
                <br/>
                <br/>

                <!-- Default mixin-->
                <div class="metaDataHeader" onclick="toggle_visibility('div_Metadata', 'img_Metadata');">
                    <img id="img_Metadata" src="plus.jpg" border="0" alt="0"/> - <b>Metadata</b>
                </div>
                <div id="div_Metadata" style="display: none;">
                    <pre class="metaData">
                        <xsl:value-of select="UnitTester/mx:Metadata"/>
                    </pre>
                </div>
                <br/>
                <br/>

                <div class="sectionTitle">Test Cases</div>
                <hr/>

                <!-- Testcases -->
                <xsl:for-each select="UnitTester/testCases/TestCase">
                    <xsl:sort select="@testID"/>

                    <div class="testCaseHeader" onclick="toggle_visibility('div_{generate-id()}', 'img_{generate-id()}');">
                        <xsl:if test="(position() mod 2) = 1">
                            <xsl:attribute name="style">background-color: #EEEEFF;</xsl:attribute>
                        </xsl:if>
                        <a>
                            <xsl:attribute name="name">
                                <xsl:value-of select="@testID"/>
                            </xsl:attribute>
                        </a>
                        <table width="100%" height="100%" cellpadding="0" cellspacing="0">
                            <tr>
                                <td>
                                    <img id="img_{generate-id()}" src="plus.jpg" border="0" alt="0"/>
                                    - <xsl:value-of select="@testID"/>                                    
                                </td>
                                <td style="text-align: right;">
                                    <a href="#testCaseIndex" style="font-weight: normal">Back To Top</a>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div id="div_{generate-id()}" style="display: none;">
                        <br/>
                        <xsl:for-each select="*">
                            <xsl:choose>
                                <xsl:when test="name() = 'setup'">
                                    <div class="testSetup">
                                        Setup:
                                    </div>
                                    <ol>
                                        <xsl:apply-templates/>
                                    </ol>
                                </xsl:when>
                                <xsl:when test="name() = 'body'">
                                    <div class="testBody">
                                        Body:
                                    </div>
                                    <ol>
                                        <xsl:apply-templates/>
                                    </ol>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                    </div>
                </xsl:for-each>

            </body>
        </html>
    </xsl:template>

    
    <!--
        TEST CASE COMMAND TEMPLATES
    -->
    
    <!-- RunCode -->
    <xsl:template match="RunCode">
        <li>
            <div>
                <div onclick="toggle_visibility('tag_{generate-id()}');">
                    <font class="assertPixelValue">RunCode</font> - 
                    <font style="color:Red;"><xsl:value-of select="@code"/></font>
                </div>
                <div id="tag_{generate-id()}" style="display: none;">
                    <xsl:if test="@waitTarget">
                        Wait Target: - <xsl:value-of select="@waitTarget"/><br/>
                    </xsl:if>
                    <xsl:if test="@waitEvent">
                        Wait Event: - <xsl:value-of select="@waitEvent"/>
                    </xsl:if>
                </div>
            </div>
        </li>
        <br/>
    </xsl:template>

    <!-- ResetComponent -->
    <xsl:template match="ResetComponent">
        <li>
            <div>
                <font class="assertPixelValue">Reset Component</font> -
                <font style="color:Red;"><xsl:value-of select="@target"/></font>
                <br/>
                <div style="padding-left:15px; display: none;">
                    Type: <xsl:value-of select="@className"/><br/>
                    Wait Target: - <xsl:value-of select="@waitTarget"/><br/>
                    Wait Event: - <xsl:value-of select="@waitEvent"/>
                </div>
            </div>
        </li>
        <br/>
    </xsl:template>

    <!-- AssertPropertyValue -->
    <xsl:template match="AssertPropertyValue">
        <li>
            <div>
                <font class="assertPixelValue">Assert Property Value</font> -
                <font style="color:Red;">
                    (<xsl:value-of select="@target"/>.<xsl:value-of select="@propertyName"/> == <xsl:value-of select="@value"/>)
                </font>
                <br/>
            </div>
        </li>
        <br/>
    </xsl:template>

    <!-- AssertPixelValue -->
    <xsl:template match="AssertPixelValue">
        <li>
            <div>
                <font class="assertPixelValue">Assert Pixel Value</font>:
                <font style="color:Red;">(x:<xsl:value-of select="@x"/>, y:<xsl:value-of select="@y"/>) == <xsl:value-of select="@value"/></font>
            </div>
        </li>
        <br/>
    </xsl:template>

</xsl:stylesheet>