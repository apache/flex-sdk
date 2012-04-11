/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flex2.compiler.asdoc;

import java.io.File;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;

/**
 * This class reads the toplevel.xml and passes the Dom tree to classes
 * responsible for generating
 * dita based xml files.
 * 
 * @author gauravj
 */
public class AsDocHelper
{
    private String topLevelXmlPath = "toplevel.xml";
    private String ditaOutputDir = "tempdita";
    private String outputDir = "";
    private String asDocConfigPath = "ASDoc_Config.xml";

    /**
     * Constructor
     * 
     * @param topLevelXmlPath path to toplevel.xml
     * @param outputDir output location for xml files
     * @param asDocConfigPath location of ASDoc_Config.xml
     */
    public AsDocHelper(String topLevelXmlPath, String ditaOutputDir,
            String outputDir, String asDocConfigPath)
    {
        this.topLevelXmlPath = topLevelXmlPath;
        this.ditaOutputDir = ditaOutputDir;
        this.outputDir = outputDir;
        this.asDocConfigPath = asDocConfigPath;
    }

    /**
     * Create xml files for each package using toplevel.xml and ASDoc_Config.xml
     * 
     * @param lenient
     * @throws Exception
     */
    public void createTopLevelClasses(boolean lenient) throws Exception
    {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder parser = factory.newDocumentBuilder();

        // get all the asdoc config options.
        Document asDocConfig = parser.parse(new File(asDocConfigPath));

        // read in the toplevel.xml
        Document domObject = parser.parse(new File(topLevelXmlPath));

        TopLevelClassesGenerator topLevelClassesGenerator = new TopLevelClassesGenerator(asDocConfig, domObject);
        topLevelClassesGenerator.initialize();
        topLevelClassesGenerator.generate();

        topLevelClassesGenerator.writeOutputFiles(ditaOutputDir, outputDir, lenient);
    }
}
