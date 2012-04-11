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

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.CDATASection;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import flex2.compiler.io.FileUtil;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.tools.ASDoc.ValidationMessage;

/**
 * This class converts the toplevel.xml to dita based xml files. It create one
 * file per package and one additional file (packages.dita) containing the list
 * of packages.
 * 
 * @author gauravj
 */
public class TopLevelClassesGenerator
{
    private final String GLOBAL = "$$Global$$";
    private Document asDocConfig;
    private Document domObject;
    private Document outputObject;
    private Element root;
    private String errorFile = "validation_errors.log";

    private String namespaces = ":";
    private String hiddenPackages = ":";

    private boolean verbose = false;
    private boolean includePrivate;

    private AsDocUtil asDocUtil;

    private HashMap<String, String> oldNewNamesMap;

    /**
     * quick lookup of AClass record for a fullname (aka qualifiedName) of a
     * class
     */
    private HashMap<String, AsClass> classTable = null;

    /**
     * table of packages, indexable by package name. each table element holds an
     * array of all classes in that package
     */
    private HashMap<String, HashMap<String, AsClass>> packageContentsTable = null;

    /**
     * table of package records, indexable by package name. This holds all the
     * asDoc comments encountered for a package.
     */
    private HashMap<String, Element> packageTable = null;

    /**
     * table of bindable metadata which wasn't handled in processFields and
     * should be handled in processMethods
     */
    private HashMap<String, String> bindableTable = null;

    private DocumentBuilderFactory factory;
    private DocumentBuilder parser;

    /**
     * Constructor
     * 
     * @param asDocConfig
     * @param domObject
     */
    public TopLevelClassesGenerator(Document asDocConfig, Document domObject)
    {
        this.asDocConfig = asDocConfig;
        this.domObject = domObject;

        classTable = new HashMap<String, AsClass>();
        packageContentsTable = new HashMap<String, HashMap<String, AsClass>>();
        packageTable = new HashMap<String, Element>();
        bindableTable = new HashMap<String, String>();
    }

    /** 
     * Bunch of objects are initialized here after reading the ASDoc_Config.xml
     * 
     * @throws Exception
     */
    public void initialize() throws Exception
    {
        factory = DocumentBuilderFactory.newInstance();
        parser = factory.newDocumentBuilder();
        outputObject = parser.newDocument();

        oldNewNamesMap = new HashMap<String, String>();
        oldNewNamesMap.put("em", "i");
        oldNewNamesMap.put("strong", "b");
        oldNewNamesMap.put("bold", "b");

        root = outputObject.createElement("asdoc");
        NodeList options = asDocConfig.getElementsByTagName("options");
        String buildnum = ((Element)options.item(0)).getAttribute("buildNum");
        if (buildnum != null)
        {
            root.setAttribute("build", buildnum);
        }
        else
        {
            root.setAttribute("build", "0");
        }

        if (((Element)options.item(0)).getAttribute("verbose").equals("true"))
        {
            verbose = true;
        }

        asDocUtil = new AsDocUtil(verbose);
        String includePrivateStr = ((Element)options.item(0)).getAttribute("includePrivate");
        if ("true".equals(includePrivateStr))
        {
            includePrivate = true;
        }

        Element link = outputObject.createElement("link");
        link.setAttribute("rel", "stylesheet");
        link.setAttribute("href", "style.css");
        link.setAttribute("type", "text/css");
        root.appendChild(link);
        outputObject.appendChild(root);

        NodeList namespaceNodeList = asDocConfig.getElementsByTagName("namespace");
        if (namespaceNodeList != null)
        {
            for (int ix = 0; ix < namespaceNodeList.getLength(); ix++)
            {
                Element nameSpaceElement = (Element)namespaceNodeList.item(ix);
                String hide = nameSpaceElement.getAttribute("hide");
                if (hide != null)
                {
                    namespaces += (nameSpaceElement.getTextContent() + ":" + hide + ":");
                }
            }
        }

        NodeList asPackageNodeList = asDocConfig.getElementsByTagName("asPackage");
        if (asPackageNodeList != null)
        {
            for (int ix = 0; ix < asPackageNodeList.getLength(); ix++)
            {
                Element asPackageElement = (Element)asPackageNodeList.item(ix);
                String hide = asPackageElement.getAttribute("hide");
                if (hide != null)
                {
                    hiddenPackages += (asPackageElement.getTextContent() + ":" + hide + ":");
                }
            }
        }

        // create fake "global" class to hold global methods/props
        AsClass tempAsClass = new AsClass();
        tempAsClass.setName(GLOBAL);
        tempAsClass.setFullName(GLOBAL);
        tempAsClass.setBaseName("Object");

        tempAsClass.setDecompName(asDocUtil.decomposeFullClassName("Object"));

        Element aClass = outputObject.createElement("aClass");
        tempAsClass.setNode(aClass);

        classTable.put(GLOBAL, tempAsClass);

        HashMap<String, AsClass> packageContents = new HashMap<String, AsClass>();
        packageContents.put(GLOBAL, tempAsClass);
        packageContentsTable.put(GLOBAL, packageContents);
    }
    
    /**
     * This calls various helper methods to generate various DITA xmls files from toplevel.xml
     */
    public void generate()
    {
        preprocessClasses();
        processClasses();
        processExcludes();
        processFields();
        processMethods();
        processMetadata();
        processClassInheritance();
        // build xml subtrees for all classeses
        assembleClassXML();
        // put inner class nodes inside their parent classes, put classes (and
        // top level methods/vars) inside their packages.
        assembleClassPackageHierarchy();
    }

    /**
     * Writes DITA output. Creates one xml file for each package and finally one
     * xml file for the TOC.
     */
    public void writeOutputFiles(String ditaOutputDir, String outputDir, boolean lenient)
    {
        if (asDocUtil.isErrors())
        {
            if (outputDir.endsWith(File.separator))
            {
                errorFile = outputDir + errorFile;
            }
            else
            {
                errorFile = outputDir + File.separator + errorFile;
            }
            try
            {
                FileUtil.writeFile(errorFile, asDocUtil.getValidationErrors());
            }
            catch (IOException ex)
            {
                System.out.println("Error in writing error file " + ex.getMessage());
            }

            ThreadLocalToolkit.log(new ValidationMessage(errorFile));

            if (!lenient)
            {
                return;
            }
        }

        String ditaDTDLoc = "";
        NodeList ditaDTDDirList = asDocConfig.getElementsByTagName("ditaDTDDir");
        if (ditaDTDDirList != null && ditaDTDDirList.getLength() != 0)
        {
            ditaDTDLoc = ditaDTDDirList.item(0).getTextContent();
        }
        
        TreeSet<String> packageNames = new TreeSet<String>(new SortComparator());
        TransformerFactory transfac = TransformerFactory.newInstance();
        Transformer trans = null;
        try
        {
            trans = transfac.newTransformer();
            trans.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
            trans.setOutputProperty(OutputKeys.INDENT, "no");

            if (!ditaDTDLoc.equals(""))
            {
                trans.setOutputProperty(OutputKeys.DOCTYPE_SYSTEM, ditaDTDLoc + "/" + "adobeAPIPackage.dtd");
            }
        }
        catch (Exception ex)
        {
            ex.printStackTrace(System.err);
        }

        StringWriter sw = null;
        // create string from xml tree
        StreamResult result = null;
        DOMSource source = null;
        String fileName = null;

        Element packages = asDocUtil.getElementByTagName(root, "packages");
        if (packages != null)
        {
            NodeList apiPackageList = packages.getElementsByTagName("apiPackage");

            OutputStreamWriter osw = null;
            if (apiPackageList != null && apiPackageList.getLength() != 0)
            {
                for (int packageCount = 0; packageCount < apiPackageList.getLength(); packageCount++)
                {
                    Element apiPackage = (Element)apiPackageList.item(packageCount);
                    String id = apiPackage.getAttribute("id");
                    fileName = ditaOutputDir + File.separator + id + ".xml";

                    source = new DOMSource(apiPackage);
                    try
                    {
                        sw = new StringWriter();

                        result = new StreamResult(sw);
                        trans.transform(source, result);
                        String xmlString = sw.toString();

                        Pattern pattern = Pattern.compile("\r");
                        Matcher match = pattern.matcher(xmlString);
                        xmlString = match.replaceAll("");

                        pattern = Pattern.compile("\n\n");
                        match = pattern.matcher(xmlString);
                        xmlString = match.replaceAll("\n");

                        // we don't want to strip out the <![CDATA[ if it is
                        // under <mxml>
                        xmlString = xmlString.replaceAll("<!\\[CDATA\\[", "");
                        xmlString = xmlString.replaceAll("\\]\\]>", "");
                        xmlString = xmlString.replaceAll("<mxml>", "<mxml><!\\[CDATA\\[");
                        xmlString = xmlString.replaceAll("</mxml>", "\\]\\]></mxml>");
                        osw = new OutputStreamWriter(new BufferedOutputStream(new FileOutputStream(fileName)), "UTF-8");

                        osw.write(xmlString, 0, xmlString.length());
                    }
                    catch (Exception ex)
                    {
                        ex.printStackTrace(System.err);
                    }
                    finally
                    {
                        try
                        {
                            if (osw != null)
                            {
                                osw.close();
                            }
                        }
                        catch (IOException ex)
                        {
                            ex.printStackTrace();
                        }
                    }

                    packageNames.add(id);
                }
            }

            Element apiMap = asDocUtil.createApiMap(packageNames, outputObject);

            String ditaTOC = "packages.dita";

            try
            {
                fileName = ditaOutputDir + File.separator + ditaTOC;

                result = new StreamResult(new BufferedOutputStream(new FileOutputStream(fileName)));
                source = new DOMSource(apiMap);
                trans.transform(source, result);

            }
            catch (Exception ex)
            {
                ex.printStackTrace(System.err);
            }
        }
    }

    private void preprocessClasses()
    {
        NodeList recordList = domObject.getElementsByTagName("classRec");

        for (int ix = 0; ix < recordList.getLength(); ix++)
        {
            Element classRec = (Element)recordList.item(ix);

            if (classRec.getAttribute("access").equals("private") && !includePrivate)
            {
                continue;
            }

            // ignore if private
            NodeList children = classRec.getElementsByTagName("private");
            if ((children != null && children.getLength() != 0) && !includePrivate)
            {
                boolean flag = false;
                for (int iChild = 0; iChild < children.getLength(); iChild++)
                {
                    if (children.item(iChild).getParentNode().equals(classRec))
                    {
                        flag = true;
                        break;
                    }
                }

                if (flag)
                {
                    continue;
                }
            }

            // ignore if excluded
            children = classRec.getElementsByTagName("ExcludeClass");
            if (children != null && children.getLength() != 0)
            {
                continue;
            }

            // ignore if internal
            if (classRec.getAttribute("access").equals("internal"))
            {
                continue;
            }

            preprocessClass(classRec, false);
        }

        recordList = domObject.getElementsByTagName("interfaceRec");

        for (int ix = 0; ix < recordList.getLength(); ix++)
        {
            Element interfaceRec = (Element)recordList.item(ix);

            if (interfaceRec.getAttribute("access").equals("private") && !includePrivate)
            {
                continue;
            }

            // ignore if private
            NodeList children = interfaceRec.getElementsByTagName("private");
            if ((children != null && children.getLength() != 0) && !includePrivate)
            {
                boolean flag = false;
                for (int iChild = 0; iChild < children.getLength(); iChild++)
                {
                    if (children.item(iChild).getParentNode().equals(interfaceRec))
                    {
                        flag = true;
                        break;
                    }
                }

                if (flag)
                {
                    continue;
                }
            }

            children = interfaceRec.getElementsByTagName("ExcludeClass");
            if (children != null && children.getLength() != 0)
            {
                continue;
            }

            if (interfaceRec.getAttribute("access").equals("internal"))
            {
                continue;
            }

            preprocessClass(interfaceRec, true);
        }

        recordList = domObject.getElementsByTagName("packageRec");

        for (int ix = 0; ix < recordList.getLength(); ix++)
        {
            Element packageRec = (Element)recordList.item(ix);
            String packageName = packageRec.getAttribute("fullname");

            Element apiPackageElement = packageTable.get(packageName);
            if (apiPackageElement == null)
            {
                apiPackageElement = outputObject.createElement("apiPackage");
                Element apiNameElement = outputObject.createElement("apiName");
                apiNameElement.setTextContent(packageName);

                apiPackageElement.appendChild(apiNameElement);
                apiPackageElement.setAttribute("id", packageName);

                packageTable.put(packageName, apiPackageElement);
            }

            String description = ((Element)packageRec.getElementsByTagName("description").item(0)).getTextContent();
            Element shortDescElement = outputObject.createElement("shortdesc");
            String textContent = asDocUtil.descToShortDesc(description);
            shortDescElement.setTextContent(textContent);
            apiPackageElement.appendChild(shortDescElement);

            Element apiDetailElement = outputObject.createElement("apiDetail");
            Element apiDescElement = outputObject.createElement("apiDesc");

            CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(description, "description", packageName));
            apiDescElement.appendChild(cdata);

            apiDetailElement.appendChild(apiDescElement);
            apiPackageElement.appendChild(apiDetailElement);

            asDocUtil.convertDescToDITA(apiDescElement, oldNewNamesMap);

            NodeList privateChilds = packageRec.getElementsByTagName("private");
            if ((privateChilds != null && privateChilds.getLength() != 0))
            {
                boolean flag = false;
                for (int iChild = 0; iChild < privateChilds.getLength(); iChild++)
                {
                    if (privateChilds.item(iChild).getParentNode().equals(packageRec))
                    {
                        flag = true;
                        break;
                    }
                }

                if (flag)
                {
                    Element apiAccessElement = outputObject.createElement("apiAccess");
                    apiAccessElement.setAttribute("value", "private");
                    apiPackageElement.appendChild(apiAccessElement);
                }
            }

            processCustoms(packageRec, apiPackageElement, false, "", "", "");
        }
    }

    private void preprocessClass(Element record, boolean isInterface)
    {
        String fullName = record.getAttribute("fullname");
        if (verbose)
        {
            System.out.println("preprocessing " + fullName);
        }

        AsClass thisClass = new AsClass();
        thisClass.setDecompName(asDocUtil.decomposeFullClassName(fullName));
        String packageName = thisClass.getDecompName().getPackageName();
        if (asDocUtil.hidePackage(packageName, hiddenPackages))
        {
            return;
        }

        String name = record.getAttribute("name");
        thisClass.setName(name);
        thisClass.setFullName(fullName);

        thisClass.setBaseName(record.getAttribute("baseclass"));
        thisClass.setInterfaceFlag(isInterface);
        thisClass.setSourceFile(record.getAttribute("sourcefile"));

        classTable.put(fullName, thisClass);

        if (packageName == null || packageName.equals(""))
        {
            packageName = GLOBAL;
        }

        if (verbose)
        {
            System.out.println("  adding class " + name + " to package: " + packageName);
        }

        HashMap<String, AsClass> packageContents = packageContentsTable.get(packageName);

        if (packageContents == null)
        {
            packageContents = new HashMap<String, AsClass>();
            packageContentsTable.put(packageName, packageContents);
        }

        packageContents.put(name, thisClass);

        // now create xml node for this class. Don't process custom tags like
        // <see> yet because we can't handle
        // cross class references until all classes have been pre-processed.
        // Fields and methods will be added
        // to this xml node individually when we process those elements. Inner
        // classes will have their node's added
        // to this node during processClass() as well.
        String accessLevel = record.getAttribute("access");

        String href = "";

        Element hrefElement = asDocUtil.getElementByTagName(record, "href");
        if (hrefElement != null)
        {
            href = hrefElement.getTextContent();
        }

        thisClass.setHref(href);

        String author = "";
        Element authorElement = asDocUtil.getElementByTagName(record, "author");
        if (authorElement != null)
        {
            author = authorElement.getTextContent();
        }

        String isFinal = record.getAttribute("isFinal");
        if (isFinal.equals(""))
        {
            isFinal = "false";
        }

        String isDynamic = record.getAttribute("isDynamic");
        if (isDynamic.equals(""))
        {
            isDynamic = "false";
        }

        // <!ELEMENT object
        // (description,(short-description)?,(subclasses)*,(prototypes)?,(customs)*,(sees)*,
        // (methods)*,(fields)*,(events)*,(inherited)?,(constructors)?,(example)*,(private)*,(version)*)>
        Element nuClass = outputObject.createElement("apiClassifier");
        nuClass.setAttribute("id", asDocUtil.formatId(fullName));

        Element apiName = outputObject.createElement("apiName");
        apiName.setTextContent(name);
        nuClass.appendChild(apiName);

        Element shortdesc = outputObject.createElement("shortdesc");
        nuClass.appendChild(shortdesc);

        Element prolog = outputObject.createElement("prolog");
        nuClass.appendChild(prolog);

        Element apiClassifierDetail = outputObject.createElement("apiClassifierDetail");
        Element apiClassifierDef = outputObject.createElement("apiClassifierDef");
        apiClassifierDetail.appendChild(apiClassifierDef);

        nuClass.appendChild(apiClassifierDetail);

        String interfaceStr = "";
        if (isInterface)
        {
            Element apiInterface = outputObject.createElement("apiInterface");
            apiClassifierDef.appendChild(apiInterface);

            interfaceStr = record.getAttribute("baseClasses");
        }
        else
        {
            interfaceStr = record.getAttribute("interfaces");
        }

        if (!interfaceStr.equals(""))
        {
            thisClass.setInterfaceStr(interfaceStr);
        }

        Element descriptionElement = asDocUtil.getElementByTagName(record, "description");
        if (descriptionElement != null && descriptionElement.getParentNode().equals(record))
        {
            String fullDesc = descriptionElement.getTextContent();

            shortdesc.setTextContent(asDocUtil.descToShortDesc(fullDesc));

            Element apiDesc = outputObject.createElement("apiDesc");

            CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(fullDesc, "description", fullName));
            apiDesc.appendChild(cdata);

            apiClassifierDetail.appendChild(apiDesc);

            asDocUtil.convertDescToDITA(apiDesc, oldNewNamesMap);
        }

        Element apiAccess = outputObject.createElement("apiAccess");
        apiAccess.setAttribute("value", accessLevel);
        apiClassifierDef.appendChild(apiAccess);

        if (isDynamic.equals("true"))
        {
            Element apiDynamic = outputObject.createElement("apiDynamic");
            apiClassifierDef.appendChild(apiDynamic);
        }
        else
        {
            Element apiStatic = outputObject.createElement("apiStatic");
            apiClassifierDef.appendChild(apiStatic);
        }

        if (isFinal.equals("true"))
        {
            Element apiFinal = outputObject.createElement("apiFinal");
            apiClassifierDef.appendChild(apiFinal);
        }

        if (!author.equals(""))
        {
            Element tempAuthorElement = outputObject.createElement("author");
            tempAuthorElement.setTextContent(author);
            prolog.appendChild(tempAuthorElement);
        }

        Element asMetadata = outputObject.createElement("asMetadata");
        prolog.appendChild(asMetadata);

        processVersions(record, nuClass);

        NodeList nodeList = record.getElementsByTagName("example");
        if (nodeList != null)
        {
            for (int ix = 0; ix < nodeList.getLength(); ix++)
            {
                Element inputExampleElement = (Element)nodeList.item(ix);

                Element exampleElement = outputObject.createElement("example");
                CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(inputExampleElement.getTextContent(), "example", fullName));
                exampleElement.appendChild(cdata);

                apiClassifierDetail.appendChild(exampleElement);

                asDocUtil.convertDescToDITA(exampleElement, oldNewNamesMap);
            }
        }

        thisClass.setNode(nuClass);

        if (verbose)
        {
            System.out.println("done preprocessing " + fullName);
        }
    }

    private void processClasses()
    {
        NodeList recordList = domObject.getElementsByTagName("classRec");

        for (int ix = 0; ix < recordList.getLength(); ix++)
        {
            Element classRec = (Element)recordList.item(ix);

            if (classRec.getAttribute("access").equals("private") && !includePrivate)
            {
                continue;
            }

            // ignore if private
            NodeList children = classRec.getElementsByTagName("private");
            if ((children != null && children.getLength() != 0) && !includePrivate)
            {
                boolean flag = false;
                for (int iChild = 0; iChild < children.getLength(); iChild++)
                {
                    if (children.item(iChild).getParentNode().equals(classRec))
                    {
                        flag = true;
                        break;
                    }
                }

                if (flag)
                {
                    continue;
                }
            }

            children = classRec.getElementsByTagName("ExcludeClass");
            if (children != null && children.getLength() != 0)
            {
                continue;
            }

            processClass(classRec, false);
        }

        recordList = domObject.getElementsByTagName("interfaceRec");

        for (int ix = 0; ix < recordList.getLength(); ix++)
        {
            Element interfaceRec = (Element)recordList.item(ix);

            if (interfaceRec.getAttribute("access").equals("private") && !includePrivate)
            {
                continue;
            }

            // ignore if private
            NodeList children = interfaceRec.getElementsByTagName("private");
            if ((children != null && children.getLength() != 0) && !includePrivate)
            {
                boolean flag = false;
                for (int iChild = 0; iChild < children.getLength(); iChild++)
                {
                    if (children.item(iChild).getParentNode().equals(interfaceRec))
                    {
                        flag = true;
                        break;
                    }
                }

                if (flag)
                {
                    continue;
                }
            }

            children = interfaceRec.getElementsByTagName("ExcludeClass");
            if (children != null && children.getLength() != 0)
            {
                continue;
            }

            processClass(interfaceRec, true);
        }
    }

    /**
     * process all custom elements for the class xml node and resolve
     * 
     * @see references now that we have AClass records for every class name
     * record inner class relationship.
     * @param record
     * @param isInterface
     */
    private void processClass(Element record, boolean isInterface)
    {
        String name = record.getAttribute("name");
        if (verbose)
        {
            System.out.println("  processing class: " + name);
        }

        String fullName = record.getAttribute("fullname");

        QualifiedNameInfo qualifiedFullName = asDocUtil.decomposeFullClassName(fullName);
        if (asDocUtil.hidePackage(qualifiedFullName.getPackageName(), hiddenPackages))
        {
            return;
        }

        if (asDocUtil.hideNamespace(record.getAttribute("access"), namespaces))
        {
            return;
        }

        AsClass thisClass = classTable.get(fullName);

        processCustoms(record, thisClass.getNode(), false, "", "", "");

        if (thisClass.getDecompName().getClassNames().size() > 1)
        {
            thisClass.setInnerClass(true);
            String tempFullName = thisClass.getDecompName().getFullClassName();
            String classScopName = tempFullName.substring(0, tempFullName.indexOf("/"));
            AsClass outerClass = classTable.get(classScopName);

            if (outerClass != null)
            {
                if (outerClass.getInnerClassCount() == 0)
                {
                    ArrayList<AsClass> innerClasses = outerClass.getInnerClasses();
                    if (innerClasses == null)
                    {
                        innerClasses = new ArrayList<AsClass>();
                    }
                    innerClasses.add(thisClass);
                }
            }
            else
            {
                if (verbose)
                {
                    System.out.println("Didn't find outer class for " + thisClass.getDecompName().getFullClassName());
                }
            }
        }

        if (verbose)
        {
            System.out.println("  done processing class: ");
        }
    }

    private void processVersions(Element record, Element target)
    {
        String langVersion = "";
        boolean versionFound = false;

        Element langVersionElement = asDocUtil.getElementByTagName(record, "langversion");
        if (langVersionElement != null)
        {
            versionFound = true;
            langVersion = langVersionElement.getTextContent().replaceAll("\n", "").replaceAll("\r", "");
        }

        ArrayList<String[]> playerVersion = new ArrayList<String[]>();

        NodeList playerVersionList = record.getElementsByTagName("playerversion");
        if (playerVersionList != null && playerVersionList.getLength() != 0)
        {
            versionFound = true;
            for (int ix = 0; ix < playerVersionList.getLength(); ix++)
            {
                if (!playerVersionList.item(ix).getParentNode().equals(record))
                {
                    continue;
                }

                String playerVersionStr = playerVersionList.item(ix).getTextContent();
                playerVersionStr = playerVersionStr.replaceAll("\\A\\s+", "");
                playerVersionStr = playerVersionStr.replaceAll("\\Z\\s+", "");
                playerVersionStr = playerVersionStr.replaceAll("\\s+", " ");
                String[] playerVersionArr = playerVersionStr.split(" ");
                playerVersion.add(playerVersionArr);
            }
        }

        ArrayList<String[]> productVersion = new ArrayList<String[]>();

        NodeList productVersionList = record.getElementsByTagName("productversion");
        if (productVersionList != null && productVersionList.getLength() != 0)
        {
            versionFound = true;
            for (int ix = 0; ix < productVersionList.getLength(); ix++)
            {
                if (!productVersionList.item(ix).getParentNode().equals(record))
                {
                    continue;
                }

                String productVersionStr = productVersionList.item(ix).getTextContent();
                productVersionStr = productVersionStr.replaceAll("\\A\\s+", "");
                productVersionStr = productVersionStr.replaceAll("\\Z\\s+", "");
                productVersionStr = productVersionStr.replaceAll("\\s+", " ");
                String[] productVersionArr = productVersionStr.split(" ");
                productVersion.add(productVersionArr);
            }
        }

        ArrayList<String[]> toolVersion = new ArrayList<String[]>();

        NodeList toolVersionList = record.getElementsByTagName("toolversion");
        if (toolVersionList != null && toolVersionList.getLength() != 0)
        {
            versionFound = true;
            for (int ix = 0; ix < toolVersionList.getLength(); ix++)
            {
                if (!toolVersionList.item(ix).getParentNode().equals(record))
                {
                    continue;
                }

                String toolVersionStr = toolVersionList.item(ix).getTextContent();
                toolVersionStr = toolVersionStr.replaceAll("\\A\\s+", "");
                toolVersionStr = toolVersionStr.replaceAll("\\Z\\s+", "");
                toolVersionStr = toolVersionStr.replaceAll("\\s+", " ");
                String[] toolVersionArr = toolVersionStr.split(" ");
                toolVersion.add(toolVersionArr);
            }
        }

        String sinceVersion = null;

        NodeList sinceList = record.getElementsByTagName("since");
        if (sinceList != null && sinceList.getLength() != 0)
        {
            versionFound = true;
            for (int ix = 0; ix < sinceList.getLength(); ix++)
            {
                if (!sinceList.item(ix).getParentNode().equals(record))
                {
                    continue;
                }

                sinceVersion = sinceList.item(ix).getTextContent();
                sinceVersion = sinceVersion.trim();
            }
        }

        // if version info not found.. then don't bother.
        if (!versionFound)
        {
            return;
        }

        Element asMetadata = null;
        Element apiVersion = null;

        // we need to get to the apiVersion Node. if not present then create
        // it.. it should go to prolog.asMetadata.apiVersion.
        // if prolog or asMetadata are not present then create them and add
        // apiVersion.
        Element prolog = asDocUtil.getElementByTagName(target, "prolog");
        if (prolog != null)
        {
            asMetadata = asDocUtil.getElementByTagName(prolog, "asMetadata");
            if (asMetadata != null)
            {
                apiVersion = asDocUtil.getElementByTagName(asMetadata, "apiVersion");
                if (apiVersion == null)
                {
                    apiVersion = outputObject.createElement("apiVersion");
                    asMetadata.appendChild(apiVersion);
                }
            }
            else
            {
                asMetadata = outputObject.createElement("asMetadata");
                apiVersion = outputObject.createElement("apiVersion");
                asMetadata.appendChild(apiVersion);
                prolog.appendChild(asMetadata);
            }
        }
        else
        {
            asMetadata = outputObject.createElement("asMetadata");
            apiVersion = outputObject.createElement("apiVersion");
            asMetadata.appendChild(apiVersion);

            prolog = outputObject.createElement("prolog");
            prolog.appendChild(asMetadata);

            target.appendChild(prolog);
        }

        if (langVersion.length() > 0)
        {
            Element apiLanguage = outputObject.createElement("apiLanguage");

            langVersion = langVersion.replaceAll("^\\s+", "");
            langVersion = langVersion.replaceAll("^\\s+$", "");
            langVersion = langVersion.replaceAll("\\s+", " ");

            String[] langVersionArr = langVersion.split(" ");

            if (langVersionArr.length > 1)
            {
                apiLanguage.setAttribute("name", langVersionArr[0]);
                apiLanguage.setAttribute("version", langVersionArr[1]);
            }
            else
            {
                apiLanguage.setAttribute("version", langVersionArr[0]);
            }
            apiVersion.appendChild(apiLanguage);
        }

        for (int ix = 0; ix < playerVersion.size(); ix++)
        {
            String[] playerVersionArr = playerVersion.get(ix);
            StringBuilder versionDescription = new StringBuilder();

            if (playerVersionArr.length > 2)
            {
                for (int iy = 2; iy < playerVersionArr.length; iy++)
                {
                    if (!"".equals(playerVersionArr[iy]) && !"\n".equals(playerVersionArr[iy]))
                    {
                        if ((iy != playerVersionArr.length - 1) && !playerVersionArr[iy].matches("\\s"))
                        {
                            versionDescription.append(playerVersionArr[iy].replaceAll("\\s", ""));
                            versionDescription.append(" ");
                        }
                        else
                        {
                            versionDescription.append(playerVersionArr[iy].replaceAll("\\s", ""));
                        }
                    }
                }
            }

            if (playerVersionArr.length > 1)
            {
                Element apiPlatform = outputObject.createElement("apiPlatform");
                apiPlatform.setAttribute("name", playerVersionArr[0]);
                apiPlatform.setAttribute("version", playerVersionArr[1].replaceAll("\\s", ""));
                apiPlatform.setAttribute("description", versionDescription.toString());
                apiVersion.appendChild(apiPlatform);
            }
        }

        for (int ix = 0; ix < productVersion.size(); ix++)
        {
            String[] productVersionArr = productVersion.get(ix);
            StringBuilder versionDescription = new StringBuilder();

            if (productVersionArr.length > 2)
            {
                for (int iy = 2; iy < productVersionArr.length; iy++)
                {
                    if (!"".equals(productVersionArr[iy]) && !"\n".equals(productVersionArr[iy]))
                    {
                        if ((iy != productVersionArr.length - 1) && !productVersionArr[iy].matches("\\s"))
                        {
                            versionDescription.append(productVersionArr[iy].replaceAll("\\s", ""));
                            versionDescription.append(" ");
                        }
                        else
                        {
                            versionDescription.append(productVersionArr[iy].replaceAll("\\s", ""));
                        }
                    }
                }
            }
            
            if (productVersionArr.length > 1)
            {
                Element apiTool = outputObject.createElement("apiTool");
                apiTool.setAttribute("name", productVersionArr[0]);
                apiTool.setAttribute("version", productVersionArr[1].replaceAll("\\s", ""));
                apiTool.setAttribute("description", versionDescription.toString());
                apiVersion.appendChild(apiTool);
            }
        }

        for (int ix = 0; ix < toolVersion.size(); ix++)
        {
            String[] toolVersionArr = toolVersion.get(ix);
            if (toolVersionArr.length > 1)
            {
                Element apiTool = outputObject.createElement("apiTool");
                apiTool.setAttribute("name", toolVersionArr[0]);
                apiTool.setAttribute("version", toolVersionArr[1].replaceAll("\\s", ""));
                apiVersion.appendChild(apiTool);
            }
        }

        if (sinceVersion != null)
        {
            Element apiSince = outputObject.createElement("apiSince");
            apiSince.setAttribute("version", sinceVersion);
            apiVersion.appendChild(apiSince);
        }
    }

    private void processCustoms(Element record, Element target, boolean useParams, String paramNames, String paramTypes, String paramDefaults)
    {
        processCustoms(record, target, useParams, paramNames, paramTypes, paramDefaults, null);
    }

    private void processCustoms(Element record, Element target, boolean useParams, String paramNames, String paramTypes, String paramDefaults, AsClass fromClass)
    {
        NodeList childNodes = record.getChildNodes();
        if (childNodes != null && childNodes.getLength() != 0)
        {
            ArrayList<String> handledTags = new ArrayList<String>();
            handledTags.add("path");
            handledTags.add("relativePath");
            handledTags.add("href");
            handledTags.add("author");
            handledTags.add("langversion");
            handledTags.add("playerversion");
            handledTags.add("productversion");
            handledTags.add("toolversion");
            handledTags.add("taghref");
            handledTags.add("description");
            handledTags.add("result");
            handledTags.add("return");
            handledTags.add("example");
            handledTags.add("throws");
            handledTags.add("canThrow");
            handledTags.add("event");
            handledTags.add("eventType");
            handledTags.add("metadata");
            handledTags.add("since");

            boolean customsFound = false;
            boolean seeFound = false;
            boolean paramFound = false;
            boolean includeExamplesFound = false;
            boolean tipTextFound = false;

            Element customData = null;

            Element relatedLinks = outputObject.createElement("related-links");
            ArrayList<Element> includeExamples = new ArrayList<Element>();
            Element params = outputObject.createElement("params");
            Element apiTipTexts = outputObject.createElement("apiTipTexts");

            int lastParamName = 0;
            int lastParamType = 0;
            int lastParamDefault = 0;

            for (int ix = 0; ix < childNodes.getLength(); ix++)
            {
                Node elementNode = childNodes.item(ix);
                if (elementNode.getNodeType() != Node.ELEMENT_NODE)
                {
                    continue;
                }

                Element child = (Element)elementNode;
                String tagName = child.getNodeName();

                if (handledTags.contains(tagName))
                {
                    continue;
                }

                if (tagName.equals("see"))
                {
                    seeFound = true;
                    relatedLinks.appendChild(processSeeTag(record.getAttribute("fullname"), child.getTextContent()));
                }
                else if (useParams && tagName.equals("param"))
                {
                    if (!child.getTextContent().equals("none"))
                    {
                        int nextParam = paramNames.indexOf(";", lastParamName);
                        if (nextParam == -1)
                        {
                            nextParam = paramNames.length();
                        }
                        if (lastParamName > nextParam)
                        {
                            lastParamName = nextParam;
                        }

                        String nextName = paramNames.substring(lastParamName, nextParam);
                        lastParamName = nextParam + 1;

                        nextParam = paramTypes.indexOf(";", lastParamType);
                        if (nextParam == -1)
                        {
                            nextParam = paramTypes.length();
                        }

                        if (lastParamType > nextParam)
                        {
                            lastParamType = nextParam;
                        }

                        String nextType = paramTypes.substring(lastParamType, nextParam);
                        lastParamType = nextParam + 1;

                        nextParam = paramDefaults.indexOf(";", lastParamDefault);
                        if (nextParam == -1)
                        {
                            nextParam = paramDefaults.length();
                        }

                        if (lastParamDefault > nextParam)
                        {
                            lastParamDefault = nextParam;
                        }

                        String nextDefault = paramDefaults.substring(lastParamDefault, nextParam);
                        lastParamDefault = nextParam + 1;

                        if (nextName.equals(""))
                        {
                            continue;
                        }

                        Element apiParam = outputObject.createElement("apiParam");
                        Element apiItemName = outputObject.createElement("apiItemName");
                        apiItemName.setTextContent(nextName);
                        apiParam.appendChild(apiItemName);

                        AsClass paramClass = classTable.get(nextType);
                        if (paramClass != null)
                        {
                            Element apiOperationClassifier = outputObject.createElement("apiOperationClassifier");
                            apiOperationClassifier.setTextContent(paramClass.getFullName());
                            apiParam.appendChild(apiOperationClassifier);
                        }
                        else
                        {
                            Element apiType = outputObject.createElement("apiType");

                            if (nextType.equals("*"))
                            {
                                apiType.setAttribute("value", "any");
                            }
                            else
                            {
                                apiType.setAttribute("value", nextType);
                            }

                            apiParam.appendChild(apiType);
                        }

                        if (nextDefault != null && !nextDefault.equals("undefined"))
                        {
                            Element apiData = outputObject.createElement("apiData");
                            apiData.setTextContent(nextDefault);
                            apiParam.appendChild(apiData);
                        }

                        String desc = child.getTextContent();

                        int tabIndex = desc.indexOf('\t');
                        int spaceIndex = desc.indexOf(" ");

                        if (tabIndex != -1 && tabIndex < spaceIndex)
                        {
                            spaceIndex = tabIndex;
                        }

                        if (spaceIndex != -1)
                        {
                            desc = desc.substring(spaceIndex + 1);
                        }
                        Element apiDesc = outputObject.createElement("apiDesc");
                        CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(desc, "param", record.getAttribute("fullname")));
                        apiDesc.appendChild(cdata);
                        apiParam.appendChild(apiDesc);

                        asDocUtil.convertDescToDITA(apiDesc, oldNewNamesMap);

                        params.appendChild(apiParam);
                        paramFound = true;
                    }
                }
                else if (tagName.equals("param"))
                {
                }
                else if (tagName.equals("includeExample"))
                {
                    includeExamplesFound = true;

                    // get the <example> element after reading the file and
                    // creating a <codeblock>
                    // add the <example> to the detail node..
                    includeExamples.add(processIncludeExampleTag(record.getAttribute("fullname"), child.getTextContent()));
                }
                else if (tagName.equals("tiptext"))
                {
                    tipTextFound = true;

                    Element apiTipText = outputObject.createElement("apiTipText");
                    CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(child.getTextContent(), "tiptext", record.getAttribute("fullname")));
                    apiTipText.appendChild(cdata);
                    asDocUtil.convertDescToDITA(apiTipText, oldNewNamesMap);
                    apiTipTexts.appendChild(apiTipText);
                }
                else if (tagName.equals("copy"))
                {
                    String copyRef = child.getTextContent();
                    copyRef = copyRef.replaceAll("[\\n\\s]", "");

                    if (copyRef.equals(""))
                    {
                        continue;
                    }

                    Element shortDescElement = asDocUtil.getElementByTagName(target, "shortdesc");
                    if (shortDescElement == null)
                    {
                        shortDescElement = outputObject.createElement("shortdesc");
                        target.appendChild(shortDescElement);
                    }

                    shortDescElement.setAttribute("conref", copyRef);
                    Element detailNode = asDocUtil.getDetailNode(target);

                    if (detailNode == null)
                    {
                        continue;
                    }

                    Element apiDesc = asDocUtil.getElementImmediateChildByTagName(detailNode, "apiDesc");

                    if (apiDesc != null)
                    {
                        apiDesc.setAttribute("conref", copyRef);
                    }
                }
                else if (tagName.equals("default"))
                {

                    Element apiDefaultValue = outputObject.createElement("apiDefaultValue");
                    apiDefaultValue.setTextContent(child.getTextContent());
                    Element defNode = asDocUtil.getDefNode(target);
                    defNode.appendChild(apiDefaultValue);
                }
                else if (tagName.equals("inheritDoc"))
                {

                    Element apiInheritDoc = outputObject.createElement("apiInheritDoc");
                    target.appendChild(apiInheritDoc);
                }
                else
                {
                    customsFound = true;
                    customData = outputObject.createElement(child.getNodeName());
                    NodeList customsChildren = child.getChildNodes();
                    if (customsChildren != null && customsChildren.getLength() != 0)
                    {
                        if (customsChildren.item(0).getNodeType() == Node.CDATA_SECTION_NODE)
                        {
                            CDATASection cdata = outputObject.createCDATASection(child.getTextContent());
                            cdata.setData(((CDATASection)customsChildren.item(0)).getData());
                            customData.appendChild(cdata);
                        }
                        else
                        {
                            CDATASection cdata = outputObject.createCDATASection(child.getTextContent());
                            customData.appendChild(cdata);
                        }
                    }

                }
            }

            if (useParams && lastParamName < paramNames.length())
            {
                if (verbose)
                {
                    System.out.println("     more params declared than found @param tags for, inventing param elements");
                    System.out.println("        params to synth docs for: " + paramNames.substring(lastParamName));
                }

                while (lastParamName < paramNames.length())
                {
                    int nextParam = paramNames.indexOf(";", lastParamName);
                    if (nextParam == -1)
                    {
                        nextParam = paramNames.length();
                    }

                    if (lastParamName > nextParam)
                    {
                        lastParamName = nextParam;
                    }

                    String nextName = paramNames.substring(lastParamName, nextParam);
                    lastParamName = nextParam + 1;

                    nextParam = paramTypes.indexOf(";", lastParamType);
                    if (nextParam == -1)
                    {
                        nextParam = paramTypes.length();
                    }
                    if (lastParamType > nextParam)
                    {
                        lastParamType = nextParam;
                    }

                    String nextType = paramTypes.substring(lastParamType, nextParam);
                    lastParamType = nextParam + 1;

                    nextParam = paramDefaults.indexOf(";", lastParamDefault);
                    if (nextParam == -1)
                    {
                        nextParam = paramDefaults.length();
                    }
                    if (lastParamDefault > nextParam)
                    {
                        lastParamDefault = nextParam;
                    }

                    String nextDefault = paramDefaults.substring(lastParamDefault, nextParam);
                    lastParamDefault = nextParam + 1;

                    Element apiParam = outputObject.createElement("apiParam");
                    Element apiItemName = outputObject.createElement("apiItemName");
                    apiItemName.setTextContent(nextName);
                    apiParam.appendChild(apiItemName);

                    AsClass paramClass = classTable.get(nextType);
                    if (paramClass != null)
                    {
                        Element apiOperationClassifier = outputObject.createElement("apiOperationClassifier");
                        apiOperationClassifier.setTextContent(paramClass.getFullName());
                        apiParam.appendChild(apiOperationClassifier);
                    }
                    else
                    {
                        Element apiType = outputObject.createElement("apiType");

                        if (nextType.equals("*"))
                        {
                            apiType.setAttribute("value", "any");
                        }
                        else
                        {
                            apiType.setAttribute("value", nextType);
                        }

                        apiParam.appendChild(apiType);
                    }

                    if (nextDefault != null && !nextDefault.equals("undefined"))
                    {
                        Element apiData = outputObject.createElement("apiData");
                        apiData.setTextContent(nextDefault);
                        apiParam.appendChild(apiData);
                    }

                    params.appendChild(apiParam);
                    paramFound = true;
                }
            }

            if (seeFound)
            {
                target.appendChild(relatedLinks);
            }

            if (paramFound)
            {
                Element apiOperationDetail = asDocUtil.getElementByTagName(target, "apiOperationDetail");
                if (apiOperationDetail != null)
                {
                    Element apiOperationDef = asDocUtil.getElementByTagName(apiOperationDetail, "apiOperationDef");
                    if (apiOperationDef == null)
                    {
                        apiOperationDef = outputObject.createElement("apiOperationDef");
                    }

                    NodeList listofChilds = params.getElementsByTagName("apiParam");
                    for (int iChild = 0; iChild < listofChilds.getLength(); iChild++)
                    {
                        Node node = listofChilds.item(iChild);
                        apiOperationDef.appendChild(node.cloneNode(true));
                    }
                }
                else
                {
                    Element apiConstructorDetail = asDocUtil.getElementByTagName(target, "apiConstructorDetail");
                    if (apiConstructorDetail != null)
                    {
                        Element apiConstructorDef = asDocUtil.getElementByTagName(apiConstructorDetail, "apiConstructorDef");
                        if (apiConstructorDef == null)
                        {
                            apiConstructorDef = outputObject.createElement("apiConstructorDef");
                        }

                        NodeList listofChilds = params.getElementsByTagName("apiParam");
                        for (int iChild = 0; iChild < listofChilds.getLength(); iChild++)
                        {
                            Node node = listofChilds.item(iChild);
                            apiConstructorDef.appendChild(node.cloneNode(true));
                        }
                    }
                    else
                    {
                        if (verbose)
                        {
                            System.out.println("Error neither operationdetail nor constructordetail exists for " + target.getNodeName());
                        }
                    }
                }
            }

            if (includeExamplesFound)
            {
                Element detailNode = asDocUtil.getDetailNode(target);
                for (int ix = 0; ix < includeExamples.size(); ix++)
                {
                    detailNode.appendChild(includeExamples.get(ix));
                }
            }

            if (customsFound)
            {
                Element asCustoms = null;
                // we need to get to the asCustoms Node. if not present then
                // create it.. it should go to prolog..
                // if prolog is not present then create it and add asCustoms.
                Element prolog = asDocUtil.getElementByTagName(target, "prolog");
                if (prolog != null)
                {
                    asCustoms = asDocUtil.getElementByTagName(prolog, "asCustoms");
                    if (asCustoms == null)
                    {
                        asCustoms = outputObject.createElement("asCustoms");
                        prolog.appendChild(asCustoms);
                    }
                }
                else
                {
                    asCustoms = outputObject.createElement("asCustoms");
                    prolog = outputObject.createElement("prolog");
                    prolog.appendChild(asCustoms);
                    target.appendChild(prolog);
                }

                asCustoms.appendChild(customData);
            }

            if (tipTextFound)
            {
                Element defNode = asDocUtil.getDefNode(target);
                defNode.appendChild(apiTipTexts);
            }
        }
    }

    private QualifiedNameInfo decomposeFullMethodOrFieldName(String fullName)
    {
        QualifiedNameInfo result = asDocUtil.decomposeFullClassName(fullName);

        // last "class" is actually the function or variable name
        int classNameSize = result.getClassNames().size();
        if (classNameSize != 0)
        {
            result.setMethodName((String)result.getClassNames().get(classNameSize - 1));
            result.getClassNames().remove(classNameSize - 1);
        }

        int classNameSpacesSize = result.getClassNameSpaces().size();
        if (classNameSpacesSize != 0)
        {
            result.setMethodNameSpace((String)result.getClassNameSpaces().get(classNameSpacesSize - 1));
            result.getClassNameSpaces().remove(classNameSpacesSize - 1);
        }

        classNameSize = result.getClassNames().size();
        classNameSpacesSize = result.getClassNameSpaces().size();

        // unless it was a getter or setter.
        if (result.getMethodName().equals("get") && classNameSize > 1)
        {
            result.setGetterSetter("Get");
            result.setMethodName((String)result.getClassNames().get(classNameSize - 1));
            result.getClassNames().remove(classNameSize - 1);

            if (classNameSpacesSize != 0)
            {
                result.setMethodNameSpace((String)result.getClassNameSpaces().get(classNameSpacesSize - 1));
                result.getClassNameSpaces().remove(classNameSpacesSize - 1);
            }
        }
        else if (result.getMethodName().equals("set") && classNameSize > 1)
        {
            result.setGetterSetter("Set");

            result.setMethodName((String)result.getClassNames().get(classNameSize - 1));
            result.getClassNames().remove(classNameSize - 1);

            if (classNameSpacesSize != 0)
            {
                result.setMethodNameSpace((String)result.getClassNameSpaces().get(classNameSpacesSize - 1));
                result.getClassNameSpaces().remove(classNameSpacesSize - 1);
            }
        }

        classNameSize = result.getClassNames().size();

        if (result.getMethodNameSpace().equals(result.getPackageName()))
        {
            result.setMethodNameSpace("public");
        }

        classNameSpacesSize = result.getClassNameSpaces().size();
        // special case for a method or var which is toplevel within a package:
        if (classNameSize == 0 && !result.getPackageName().equals(""))
        {
            result.getClassNames().add("$$" + result.getPackageName() + "$$");
        }

        // now rebuild fullclassname from components
        result.setFullClassName("");
        if (!result.getPackageName().equals(""))
        {
            result.setFullClassName(result.getPackageName());

            if (classNameSpacesSize != 0 && !result.getClassNameSpaces().get(0).equals("public") && !result.getClassNameSpaces().get(0).equals(""))
            {
                result.setFullClassName(result.getFullClassName() + "$" + result.getClassNameSpaces().get(0) + ":");
            }
            else
            {
                result.setFullClassName(result.getFullClassName() + ":");
            }
        }

        classNameSize = result.getClassNames().size();
        if (classNameSize != 0 && !result.getClassNames().get(0).equals(""))
        {
            result.setFullClassName(result.getFullClassName() + result.getClassNames().get(0));
        }

        if (result.getFullClassName().equals(""))
        {
            result.setFullClassName(GLOBAL); // use fake "global" class to
            // hold global methods/props
        }
        else if (classNameSize != 0 && result.getClassNames().get(0).equals("$$" + result.getPackageName() + "$$"))
        {
            AsClass fakeClass = classTable.get(result.getFullClassName());
            if (fakeClass == null)
            {
                fakeClass = new AsClass();
                fakeClass.setName((String)result.getClassNames().get(0));
                fakeClass.setDecompName(result);
                fakeClass.setBaseName(""); // don't use Object, else it shows
                // up in Object's decendants
                fakeClass.setInterfaceFlag(false);

                Element apiClassifier = outputObject.createElement("apiClassifier");
                fakeClass.setNode(apiClassifier);

                classTable.put(result.getFullClassName(), fakeClass);
                HashMap<String, AsClass> packageContents = packageContentsTable.get(result.getPackageName());

                if (packageContents == null)
                {
                    packageContents = new HashMap<String, AsClass>();
                    packageContentsTable.put(result.getPackageName(), packageContents);
                }
                packageContents.put((String)result.getClassNames().get(0), fakeClass);
            }
        }

        return result;
    }

    private Element processSeeTag(String fullName, String seeStr)
    {
        String labelStr = "";
        String hrefStr = "";
        String invalidHrefStr = null;

        seeStr = asDocUtil.normalizeString(seeStr);
        if (seeStr.length() == 0)
        {
            if (verbose)
            {
                System.out.println("ERROR: Empty @see string in " + fullName);
            }

            Element link = outputObject.createElement("link");
            link.setAttribute("href", "");
            Element linkText = outputObject.createElement("linktext");
            link.appendChild(linkText);
            return link;
        }

        int spaceIndex = seeStr.indexOf(" ");

        if (seeStr.indexOf("\"") == 0)
        {
            labelStr = seeStr.replaceAll("^[\"]|[\"]$", "");
        }
        else
        {
            if (spaceIndex != -1)
            {
                hrefStr = seeStr.substring(0, spaceIndex);
                labelStr = seeStr.substring(spaceIndex + 1);
            }
            else
            {
                hrefStr = seeStr;
                labelStr = seeStr;
            }

            if (hrefStr.indexOf("http://") == -1 && hrefStr.indexOf(".html") == -1)
            {
                int poundLoc = hrefStr.indexOf("#");

                hrefStr = hrefStr.replaceAll("event:", "event!");
                hrefStr = hrefStr.replaceAll("style:", "style!");
                hrefStr = hrefStr.replaceAll("effect:", "effect!");
                hrefStr = hrefStr.replaceAll("skinstate:", "skinstate!");
                hrefStr = hrefStr.replaceAll("skinpart:", "skinpart!");

                int lastDot = hrefStr.lastIndexOf(".");

                if (lastDot != -1)
                {
                    hrefStr = hrefStr.substring(0, lastDot) + ":" + hrefStr.substring(lastDot + 1);
                }

                int colonLoc = hrefStr.indexOf(":");
                String packageNameStr = "";
                String className = "";

                boolean isValidLink = true;

                if (poundLoc != -1)
                {
                    QualifiedNameInfo qualifiedName = (fullName.indexOf("/") == -1 ? asDocUtil.decomposeFullClassName(fullName) : decomposeFullMethodOrFieldName(fullName));

                    String memberName = hrefStr.substring(poundLoc + 1);

                    // colonLoc should be greater that poundLoc to avoid string index exception 
                    // for cases like @see MystrViewerControl#newTraversal(model: IModel) 
                    if (colonLoc != -1 && colonLoc < poundLoc)
                    {
                        packageNameStr = hrefStr.substring(0, colonLoc);
                        className = hrefStr.substring(colonLoc + 1, poundLoc);
                        // start check if packageNameStr + classNameStr is
                        // really a class or a package
                        if (classTable.get(hrefStr.substring(0, poundLoc)) == null)
                        {
                            String fullNameStr = packageNameStr + "." + className;
                            fullNameStr = fullNameStr.replaceAll(":", ".");

                            if (fullNameStr.endsWith("."))
                            {
                                fullNameStr = fullNameStr.substring(0, fullNameStr.length() - 1);
                            }

                            if (packageContentsTable.get(fullNameStr) != null)
                            {
                                packageNameStr = fullNameStr;
                                className = "";
                            }
                            else
                            {
                                isValidLink = false;
                            }
                        }
                    }
                    else
                    {
                        className = hrefStr.substring(0, poundLoc);
                        if (className.equals(""))
                        {
                            if (qualifiedName.getClassNames().size() != 0)
                            {
                                className = (String)qualifiedName.getClassNames().get(qualifiedName.getClassNames().size() - 1);
                            }
                        }

                        if (packageNameStr.equals("") && classTable.get(className) == null)
                        {
                            packageNameStr = qualifiedName.getPackageName();
                        }

                        String fullNameStr = "";

                        if (!packageNameStr.equals(""))
                        {
                            fullNameStr = packageNameStr + ":";
                        }

                        if (!className.equals(""))
                        {
                            fullNameStr = fullNameStr + className;
                        }

                        if (classTable.get(fullNameStr) == null && !className.equals("global"))
                        {
                            isValidLink = false;
                        }
                    }

                    if (isValidLink)
                    {
                        if (!packageNameStr.equals(""))
                        {
                            hrefStr = packageNameStr + ".xml#" + className + "/" + memberName;
                        }
                        else
                        {
                            hrefStr = "#" + className + "/" + memberName;
                        }
                    }
                    else
                    {
                        hrefStr = "";

                        if (!packageNameStr.equals(""))
                        {
                            invalidHrefStr = packageNameStr + ".xml#" + className + "/" + memberName;
                        }
                        else
                        {
                            invalidHrefStr = "#" + className + "/" + memberName;
                        }
                    }
                }
                else
                {
                    QualifiedNameInfo qualifiedName = asDocUtil.decomposeFullClassName(fullName);

                    if (colonLoc != -1)
                    {
                        packageNameStr = hrefStr.substring(0, colonLoc);
                        className = hrefStr.substring(colonLoc + 1);
                    }
                    else
                    {
                        className = hrefStr;
                    }

                    if (className.equals(""))
                    {
                        if (qualifiedName.getClassNames().size() != 0)
                        {
                            className = (String)qualifiedName.getClassNames().get(qualifiedName.getClassNames().size() - 1);
                        }
                    }

                    if (packageNameStr.equals("") && classTable.get(className) == null)
                    {
                        packageNameStr = qualifiedName.getPackageName();
                    }

                    String fullNameStr = "";

                    if (!packageNameStr.equals(""))
                    {
                        fullNameStr = packageNameStr + ":";
                    }

                    fullNameStr = fullNameStr + className;

                    if (classTable.get(fullNameStr) == null)
                    {
                        String temp = fullNameStr.replaceAll(":", ".");
                        if (packageContentsTable.get(temp) != null)
                        {
                            hrefStr = temp + ".xml";
                        }
                        else
                        {
                            hrefStr = "";
                            invalidHrefStr = temp + ".xml";
                        }
                    }
                    else if (!packageNameStr.equals(""))
                    {
                        hrefStr = packageNameStr + ".xml#" + className;
                    }
                    else
                    {
                        hrefStr = "#" + className;
                    }
                }

                hrefStr = hrefStr.replaceAll("event!", "event:");
                hrefStr = hrefStr.replaceAll("style!", "style:");
                hrefStr = hrefStr.replaceAll("effect!", "effect:");
                hrefStr = hrefStr.replaceAll("skinstate!", "skinstate:");
                hrefStr = hrefStr.replaceAll("skinpart!", "skinpart:");

                if (invalidHrefStr != null)
                {
                    invalidHrefStr = invalidHrefStr.replaceAll("event!", "event:");
                    invalidHrefStr = invalidHrefStr.replaceAll("style!", "style:");
                    invalidHrefStr = invalidHrefStr.replaceAll("effect!", "effect:");
                    invalidHrefStr = invalidHrefStr.replaceAll("skinstate!", "skinstate:");
                    invalidHrefStr = invalidHrefStr.replaceAll("skinpart!", "skinpart:");
                }

                if (labelStr.indexOf("#") == 0)
                {
                    labelStr = labelStr.replaceAll("#", "");
                }
                else
                {
                    labelStr = labelStr.replaceAll("#", ".");
                }

                labelStr = labelStr.replaceAll("event:", "");
                labelStr = labelStr.replaceAll("style:", "");
                labelStr = labelStr.replaceAll("effect:", "");
                labelStr = labelStr.replaceAll("skinstate:", "");
                labelStr = labelStr.replaceAll("skinpart:", "");
                labelStr = labelStr.replaceAll("global\\.", "");
            }
        }

        Element link = outputObject.createElement("link");
        link.setAttribute("href", hrefStr);

        if (invalidHrefStr != null)
        {
            link.setAttribute("invalidHref", invalidHrefStr);
        }

        Element linkText = outputObject.createElement("linktext");
        linkText.setTextContent(labelStr);

        link.appendChild(linkText);
        return link;
    }

    private Element processIncludeExampleTag(String fullName, String exampleStr)
    {
        if (verbose)
        {
            System.out.println("processIncludeExampleTag:: fullname : " + fullName + "   exampleStr :" + exampleStr);
        }

        boolean noSwf = false;
        Element result = null;

        int versionIdx = exampleStr.indexOf("-version");
        String versionStr = "";

        // remove -noswf from the @includeExample string
        int noSwfIdx = exampleStr.indexOf("-noswf");
        if (noSwfIdx != -1)
        {
            noSwf = true;
            if (versionIdx != -1 && versionIdx > noSwfIdx)
            {
                versionStr = exampleStr.substring(versionIdx + 8);
            }

            exampleStr = exampleStr.substring(0, noSwfIdx);
        }
        else if (versionIdx != -1)
        {
            versionStr = exampleStr.substring(versionIdx + 8);
            exampleStr = exampleStr.substring(0, versionIdx);
        }

        // remove whitespace from @includeExample string
        exampleStr = exampleStr.replaceAll("\\s*", "");

        // generate the examplefilename string
        String exampleFileName = exampleStr;
        int index = exampleFileName.lastIndexOf('/');
        if (index != -1)
        {
            exampleFileName = exampleFileName.substring(index + 1);
        }

        // generate the swfpart string
        String swfPartFile = exampleStr;

        index = swfPartFile.lastIndexOf('.');
        if (index != -1)
        {
            swfPartFile = swfPartFile.substring(0, index);
            swfPartFile += ".swf";
        }

        // construct the location of the mxml code and read in the mxml code
        String codePart = null;
        String codeFileName = "";

        try
        {
            NodeList includeExamplesList = asDocConfig.getElementsByTagName("includeExamplesDirectory");
            if (includeExamplesList != null && includeExamplesList.getLength() != 0)
            {
                codeFileName = includeExamplesList.item(0).getTextContent();
            }

            codeFileName += "/";
            QualifiedNameInfo qualifiedFullName = asDocUtil.decomposeFullClassName(fullName);
            codeFileName += qualifiedFullName.getPackageName().replaceAll("\\.+", "/");
            codeFileName += "/";
            codeFileName += exampleStr;

            codePart = FileUtil.readFile(new File(codeFileName));
        }
        catch (Exception ex)
        {
            if (verbose)
            {
                System.out.print("The file specified in @includeExample, " + exampleStr + ", cannot be found at " + codeFileName);
            }
        }

        if (codePart != null)
        {
            codeFileName = codeFileName.toLowerCase();
            Pattern pattern = Pattern.compile("\n");
            Matcher matcher = pattern.matcher(codePart);
            codePart = matcher.replaceAll("\n\n");

            codePart = codePart.replaceAll("\\t", "    ");

            StringBuilder output = new StringBuilder();
            int descBegin = 0;
            int descEnd = 0;
            int descEnd1 = 0;
            String descText = null;
            String descText2 = null;

            descBegin = codePart.indexOf("@exampleText");
            if (descBegin != -1)
            {
                descEnd1 = codePart.indexOf("@", descBegin + 1);

                // depending upon the extension of the external examples file.. the comment closing will be different.
                if (codeFileName.endsWith(".mxml"))
                {
                    descEnd = codePart.indexOf("-->", descBegin); // mxml files have xml comment closing
                }
                else
                {
                    descEnd = codePart.indexOf("*/", descBegin); // as files have */ comment closing.
                }

                if (descEnd1 != -1)
                {
                    if (descEnd1 < descEnd)
                    {
                        descEnd = descEnd1;
                    }
                }
                
                if (descEnd != -1)
                {
	                String temp = codePart.substring(descBegin + 12, descEnd - 1);
	
	                pattern = Pattern.compile("^\\s*\\*", Pattern.MULTILINE);
	                matcher = pattern.matcher(temp);
	                descText = matcher.replaceAll("");
	
	                if (codeFileName.endsWith(".mxml"))
	                {
	                    pattern = Pattern.compile("^\\s*-", Pattern.MULTILINE); // for consistency mxml comment may have a - at the line start.
	                    matcher = pattern.matcher(descText);
	                    descText = matcher.replaceAll("");
	                }
                }
                else
                {
                	String validationErrors = asDocUtil.getValidationErrors();
                    validationErrors += "comment not closed correctly in "+ codeFileName + " for " + fullName +" \n";
                    asDocUtil.setValidationErrors(validationErrors);
                    asDocUtil.setErrors(true);
                }
            }

            int codeBegin = -1;

            // depending upon the extension of the external examples file.. the comment closing will be different.
            if (codeFileName.endsWith(".mxml"))
            {
                if (codePart.indexOf("<!---") != -1)
                {
                    codeBegin = codePart.indexOf("-->"); // mxml files have xml comment closing
                }
            }
            else
            {
                codeBegin = codePart.indexOf("*/"); // as files have */ comment closing.
            }

            if (codeBegin == -1)
            {
                codeBegin = 0;
            }
            else
            {
                codeBegin += 2;

                if (codeFileName.endsWith(".mxml")) // mxml files have xml comment closing -->, so lets skip one more character.
                {
                    codeBegin += 1;
                }
            }

            int codeEnd = -1;

            //depending upon the extension of the external examples file.. the comment beginning will also be different.
            if (codeFileName.endsWith(".mxml"))
            {
                codeEnd = codePart.indexOf("<!---", codeBegin);
            }
            else
            {
                codeEnd = codePart.indexOf("/*", codeBegin);
            }

            if (codeEnd != -1 && codeEnd < codeBegin)
            {
                codeBegin = 0;
            }

            String codeBlock = "";
            if (codeEnd == -1)
            {
                codeBlock = codePart.substring(codeBegin);
            }
            else
            {
                codeBlock = codePart.substring(codeBegin, codeEnd - 1);
            }

            if (codeBlock.replaceAll("\\s*", "").length() == 0)
            {
                if (verbose)
                {
                    System.out.println("warning :: codeblock is empty for " + codeFileName);
                }
            }

            if (codeBegin < descBegin)
            {
                output.append("<codeblock>");
                output.append(asDocUtil.convertToEntity(codeBlock));
                output.append("</codeblock>");

                if (descText != null)
                {
                    output.append(descText);
                }
            }
            else
            {
                if (descText != null)
                {
                    output.append(descText);
                }

                output.append("<codeblock>");
                output.append(asDocUtil.convertToEntity(codeBlock));
                output.append("</codeblock>");

                codeEnd = codeBegin + codeBlock.length();

                descBegin = codePart.indexOf("@exampleText", codeEnd);

                if (descBegin != -1)
                {
                    descEnd1 = codePart.indexOf("@", descBegin + 1);

                    // depending upon the extension of the external examples file.. the comment closing will be different.
                    if (codeFileName.endsWith(".mxml"))
                    {
                        descEnd = codePart.indexOf("-->", descBegin);
                    }
                    else
                    {
                        descEnd = codePart.indexOf("*/", descBegin);

                    }

                    if (descEnd1 != -1)
                    {
                        if (descEnd1 < descEnd)
                        {
                            descEnd = descEnd1;
                        }
                    }

                    if (descEnd != -1)
                    {
                    	String temp = codePart.substring(descBegin + 12, descEnd - 1);

                        pattern = Pattern.compile("^\\s*\\*", Pattern.MULTILINE);
                        matcher = pattern.matcher(temp);
                        descText2 = matcher.replaceAll("");

                        if (codeFileName.endsWith(".mxml"))
                        {
                            pattern = Pattern.compile("^\\s*-", Pattern.MULTILINE);
                            matcher = pattern.matcher(descText2);
                            descText2 = matcher.replaceAll("");
                        }

                        output.append(descText2);
                    }
                    else
                    {
                    	String validationErrors = asDocUtil.getValidationErrors();
                        validationErrors += "comment not closed correctly in "+ codeFileName + " for " + fullName +" \n";
                        asDocUtil.setValidationErrors(validationErrors);
                        asDocUtil.setErrors(true);
                    }
                }
            }
            result = outputObject.createElement("example");
            result.setAttribute("conref", exampleFileName);
            CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(output.toString(), "includeExample " + exampleStr, fullName));
            result.appendChild(cdata);
            // result.setTextContent(asDocUtil.validateText(output.toString()));
        }

        if (result == null)
        {
            result = outputObject.createElement("example");
            result.setAttribute("conref", exampleFileName);
        }

        asDocUtil.convertDescToDITA(result, oldNewNamesMap);
        if (!noSwf)
        {
            Element swfBlock = outputObject.createElement("swfblock");
            swfBlock.setAttribute("conref", swfPartFile);
            result.appendChild(swfBlock);
        }

        if (!versionStr.equals(""))
        {
            int langVersionIdx = versionStr.indexOf("-langversion");
            int productVersionIdx = versionStr.indexOf("-productversion");
            int playerVersionIdx = versionStr.indexOf("-playerversion");

            boolean skipVersions = false;

            if (langVersionIdx != -1 && versionStr.indexOf("-langversion", langVersionIdx + 1) != -1)
            {
                String validationErrors = asDocUtil.getValidationErrors();
                validationErrors += "@includeExample for " + fullName + " contains multiple -langversion \n";
                asDocUtil.setValidationErrors(validationErrors);
                asDocUtil.setErrors(true);
                skipVersions = true;
            }

            if (productVersionIdx != -1 && versionStr.indexOf("-productversion", productVersionIdx + 1) != -1)
            {
                String validationErrors = asDocUtil.getValidationErrors();
                validationErrors += "@includeExample for " + fullName + " contains multiple -productversion \n";
                asDocUtil.setValidationErrors(validationErrors);
                asDocUtil.setErrors(true);
                skipVersions = true;
            }

            if (playerVersionIdx != -1 && versionStr.indexOf("-playerversion", playerVersionIdx + 1) != -1)
            {
                String validationErrors = asDocUtil.getValidationErrors();
                validationErrors += "@includeExample for " + fullName + " contains multiple -playerversion \n";
                asDocUtil.setValidationErrors(validationErrors);
                asDocUtil.setErrors(true);
                skipVersions = true;
            }

            if (!skipVersions)
            {
                ArrayList<Integer> tagIndexs = new ArrayList<Integer>();

                if (langVersionIdx != -1)
                {
                    tagIndexs.add(langVersionIdx);
                }

                if (productVersionIdx != -1)
                {
                    tagIndexs.add(productVersionIdx);
                }

                if (playerVersionIdx != -1)
                {
                    tagIndexs.add(playerVersionIdx);
                }

                int tagLength = tagIndexs.size();

                Collections.sort(tagIndexs);

                Element asMetadata = outputObject.createElement("asMetadata");
                Element apiVersion = outputObject.createElement("apiVersion");
                asMetadata.appendChild(apiVersion);

                Element prolog = outputObject.createElement("prolog");
                prolog.appendChild(asMetadata);

                if (langVersionIdx != -1)
                {
                    int idx = tagIndexs.indexOf(langVersionIdx);

                    String langVersion = "";
                    if (idx != tagLength - 1)
                    {
                        langVersion = versionStr.substring(langVersionIdx + 12, tagIndexs.get(idx + 1));
                    }
                    else
                    {
                        langVersion = versionStr.substring(langVersionIdx + 12);
                    }

                    langVersion = langVersion.replaceAll("\n", "").replaceAll("\r", "");

                    if (langVersion.length() > 0)
                    {
                        Element apiLanguage = outputObject.createElement("apiLanguage");

                        langVersion = langVersion.replaceAll("^\\s+", "");
                        langVersion = langVersion.replaceAll("^\\s+$", "");
                        langVersion = langVersion.replaceAll("\\s+", " ");

                        String[] langVersionArr = langVersion.split(" ");

                        if (langVersionArr.length > 1)
                        {
                            apiLanguage.setAttribute("name", langVersionArr[0]);
                            apiLanguage.setAttribute("version", langVersionArr[1]);
                        }
                        else
                        {
                            apiLanguage.setAttribute("version", langVersionArr[0]);
                        }
                        apiVersion.appendChild(apiLanguage);
                    }
                }

                if (playerVersionIdx != -1)
                {
                    int idx = tagIndexs.indexOf(playerVersionIdx);

                    String playerVersionStr = "";
                    if (idx != tagLength - 1)
                    {
                        playerVersionStr = versionStr.substring(playerVersionIdx + 14, tagIndexs.get(idx + 1));
                    }
                    else
                    {
                        playerVersionStr = versionStr.substring(playerVersionIdx + 14);
                    }

                    playerVersionStr = playerVersionStr.replaceAll("\n", "").replaceAll("\r", "");

                    if (playerVersionStr.length() > 0)
                    {
                        ArrayList<String[]> playerVersion = new ArrayList<String[]>();

                        playerVersionStr = playerVersionStr.replaceAll("\\A\\s+", "");
                        playerVersionStr = playerVersionStr.replaceAll("\\Z\\s+", "");
                        playerVersionStr = playerVersionStr.replaceAll("\\s+", " ");

                        String[] playerVersionArr = playerVersionStr.split(",");
                        for (int ix = 0; ix < playerVersionArr.length; ix++)
                        {
                            String tmpPlayerVersion = playerVersionArr[ix].trim();
                            playerVersion.add(tmpPlayerVersion.split(" "));
                        }

                        for (int ix = 0; ix < playerVersion.size(); ix++)
                        {
                            String[] tempPlayerVersionArr = playerVersion.get(ix);
                            StringBuilder versionDescription = new StringBuilder();

                            if (tempPlayerVersionArr.length > 2)
                            {
                                for (int iy = 2; iy < tempPlayerVersionArr.length; iy++)
                                {
                                    if (!"".equals(tempPlayerVersionArr[iy]) && !"\n".equals(tempPlayerVersionArr[iy]))
                                    {
                                        if ((iy != tempPlayerVersionArr.length - 1) && !tempPlayerVersionArr[iy].matches("\\s"))
                                        {
                                            versionDescription.append(tempPlayerVersionArr[iy].replaceAll("\\s", ""));
                                            versionDescription.append(" ");
                                        }
                                        else
                                        {
                                            versionDescription.append(tempPlayerVersionArr[iy].replaceAll("\\s", ""));
                                        }
                                    }
                                }
                            }

                            if (tempPlayerVersionArr.length > 1)
                            {
                                Element apiPlatform = outputObject.createElement("apiPlatform");
                                apiPlatform.setAttribute("name", tempPlayerVersionArr[0]);
                                apiPlatform.setAttribute("version", tempPlayerVersionArr[1].replaceAll("\\s", ""));
                                apiPlatform.setAttribute("description", versionDescription.toString());
                                apiVersion.appendChild(apiPlatform);
                            }
                        }
                    }
                }

                if (productVersionIdx != -1)
                {
                    int idx = tagIndexs.indexOf(productVersionIdx);

                    String productVersionStr = "";
                    if (idx != tagLength - 1)
                    {
                        productVersionStr = versionStr.substring(productVersionIdx + 15, tagIndexs.get(idx + 1));
                    }
                    else
                    {
                        productVersionStr = versionStr.substring(productVersionIdx + 15);
                    }

                    productVersionStr = productVersionStr.replaceAll("\n", "").replaceAll("\r", "");

                    if (productVersionStr.length() > 0)
                    {
                        ArrayList<String[]> productVersion = new ArrayList<String[]>();

                        productVersionStr = productVersionStr.replaceAll("\\A\\s+", "");
                        productVersionStr = productVersionStr.replaceAll("\\Z\\s+", "");
                        productVersionStr = productVersionStr.replaceAll("\\s+", " ");

                        String[] productVersionArr = productVersionStr.split(",");
                        for (int ix = 0; ix < productVersionArr.length; ix++)
                        {
                            String tmpProductVersion = productVersionArr[ix].trim();
                            productVersion.add(tmpProductVersion.split(" "));
                        }

                        for (int ix = 0; ix < productVersion.size(); ix++)
                        {
                            String[] tmpProductVersionArr = productVersion.get(ix);
                            StringBuilder versionDescription = new StringBuilder();

                            if (tmpProductVersionArr.length > 2)
                            {
                                for (int iy = 2; iy < tmpProductVersionArr.length; iy++)
                                {
                                    if (!"".equals(tmpProductVersionArr[iy]) && !"\n".equals(tmpProductVersionArr[iy]))
                                    {
                                        if ((iy != tmpProductVersionArr.length - 1) && !tmpProductVersionArr[iy].matches("\\s"))
                                        {
                                            versionDescription.append(tmpProductVersionArr[iy].replaceAll("\\s", ""));
                                            versionDescription.append(" ");
                                        }
                                        else
                                        {
                                            versionDescription.append(tmpProductVersionArr[iy].replaceAll("\\s", ""));
                                        }
                                    }
                                }
                            }

                            if (tmpProductVersionArr.length > 1)
                            {
                                Element apiTool = outputObject.createElement("apiTool");
                                apiTool.setAttribute("name", tmpProductVersionArr[0]);
                                apiTool.setAttribute("version", tmpProductVersionArr[1].replaceAll("\\s", ""));
                                apiTool.setAttribute("description", versionDescription.toString());
                                apiVersion.appendChild(apiTool);
                            }
                        }
                    }
                }

                result.appendChild(prolog);
            }

        }

        return result;
    }

    private void processExcludes()
    {
        processExcludesForChildren(domObject);

        Set<String> keyset = classTable.keySet();
        if (keyset != null)
        {
            Iterator<String> iterator = keyset.iterator();

            if (iterator != null)
            {
                while (iterator.hasNext())
                {
                    AsClass tempClass = classTable.get(iterator.next());
                    AsClass baseClass = classTable.get(tempClass.getBaseName());

                    while (baseClass != null)
                    {
                        Element prolog = asDocUtil.getElementByTagName(baseClass.getNode(), "prolog");
                        if (prolog != null)
                        {
                            Element asMetadata = asDocUtil.getElementByTagName(prolog, "asMetadata");
                            if (asMetadata != null)
                            {
                                Element exclude = asDocUtil.getElementByTagName(asMetadata, "Exclude");
                                if (exclude != null)
                                {
                                    tempClass.getExcludedProperties().addAll(baseClass.getExcludedProperties());
                                }
                            }
                        }

                        if (baseClass.getName().equals("Object"))
                        {
                            break;
                        }
                        else
                        {
                            baseClass = classTable.get(baseClass.getBaseName());
                        }
                    }
                }
            }
        }
    }

    private void processExcludesForChildren(Node parent)
    {
        if (parent.getNodeName().equals("Exclude"))
        {
            String fullName = ((Element)parent).getAttribute("owner");
            AsClass ownerClass = classTable.get(fullName);

            if (ownerClass != null)
            {
                Element node = ownerClass.getNode();
                Element asMetadata = null;

                // we need to get to the asMetadata Node. if not present then
                // create it.. it should go to prolog..
                // if prolog is not present then create it and add asMetadata.
                Element prolog = asDocUtil.getElementByTagName(node, "prolog");
                if (prolog != null)
                {
                    asMetadata = asDocUtil.getElementByTagName(prolog, "asMetadata");
                    if (asMetadata == null)
                    {
                        asMetadata = outputObject.createElement("asMetadata");
                        prolog.appendChild(asMetadata);
                    }
                }
                else
                {
                    asMetadata = outputObject.createElement("asMetadata");
                    prolog = outputObject.createElement("prolog");
                    prolog.appendChild(asMetadata);
                    node.appendChild(prolog);
                }

                Element excludeElement = outputObject.createElement("Exclude");
                excludeElement.setAttribute("name", ((Element)parent).getAttribute("name"));
                excludeElement.setAttribute("kind", ((Element)parent).getAttribute("kind"));
                asMetadata.appendChild(excludeElement);

                if (((Element)parent).getAttribute("id").equals("property"))
                {
                    ownerClass.getExcludedProperties().add(((Element)parent).getAttribute("name"));
                }
            }
        }

        // Go deep and process excludes..
        NodeList listOfChilds = parent.getChildNodes();
        if (listOfChilds != null && listOfChilds.getLength() != 0)
        {
            for (int ix = 0; ix < listOfChilds.getLength(); ix++)
            {
                Node childNode = listOfChilds.item(ix);
                if (childNode.getNodeType() != Node.ELEMENT_NODE)
                {
                    continue;
                }
                Element child = (Element)childNode;

                processExcludesForChildren(child);
            }
        }
    }

    private void processFields()
    {
        processFieldsForChildren(domObject);
    }

    private void processFieldsForChildren(Node parent)
    {
        // Go deep and process excludes..
        NodeList listOfChilds = parent.getChildNodes();
        if (listOfChilds != null && listOfChilds.getLength() != 0)
        {
            for (int ix = 0; ix < listOfChilds.getLength(); ix++)
            {
                Node childNode = listOfChilds.item(ix);
                if (childNode.getNodeType() != Node.ELEMENT_NODE)
                {
                    continue;
                }
                Element child = (Element)childNode;

                processFieldsForChildren(child);
            }
        }

        if (parent.getNodeName().equals("field"))
        {
            String name = ((Element)parent).getAttribute("name");
            String fullName = ((Element)parent).getAttribute("fullname");
            if (verbose)
            {
                System.out.println("   processing field: " + fullName);
            }

            // skip fields tagged with @private, even if they are public
            NodeList children = ((Element)parent).getElementsByTagName("private");
            if (((children != null && children.getLength() != 0) || ((Element)parent).getAttribute("access").equals("private")) && !includePrivate)
            {
                return;
            }

            QualifiedNameInfo qualifiedFullName = decomposeFullMethodOrFieldName(fullName);

            // skip fields actually in the private namespace
            if (asDocUtil.hideNamespace(qualifiedFullName.getMethodNameSpace(), namespaces) || asDocUtil.hidePackage(qualifiedFullName.getPackageName(), hiddenPackages))
            {
                return;
            }

            AsClass myClass = classTable.get(qualifiedFullName.getFullClassName());
            if (myClass == null)
            {
                // not an error, likely a method or field for a private class
                return;
            }

            Element prolog = asDocUtil.getElementByTagName(myClass.getNode(), "prolog");
            if (prolog != null)
            {
                Element asMetadata = asDocUtil.getElementByTagName(prolog, "asMetadata");
                if (asMetadata != null)
                {
                    NodeList excludeList = asMetadata.getElementsByTagName("Exclude");
                    if (excludeList != null && excludeList.getLength() != 0)
                    {
                        for (int ix = 0; ix < excludeList.getLength(); ix++)
                        {
                            Element exclude = (Element)excludeList.item(ix);
                            if (exclude.getAttribute("kind").equals("property"))
                            {
                                if (exclude.getAttribute("name").equals(name))
                                {
                                    if (verbose)
                                    {
                                        System.out.println("Excluding property " + name + " from " + myClass.getName());
                                    }

                                    return;
                                }
                            }
                        }
                    }
                }
            }

            String isConst = ((Element)parent).getAttribute("isConst");

            if (isConst.equals(""))
            {
                isConst = "false";
            }

            Element apiValue = outputObject.createElement("apiValue");
            apiValue.setAttribute("id", asDocUtil.formatId(fullName));

            Element apiName = outputObject.createElement("apiName");
            apiName.setTextContent(name);

            apiValue.appendChild(apiName);
            Element shortdesc = outputObject.createElement("shortdesc");
            apiValue.appendChild(shortdesc);
            prolog = outputObject.createElement("prolog");
            apiValue.appendChild(prolog);

            Element apiValueDetail = outputObject.createElement("apiValueDetail");
            Element apiValueDef = outputObject.createElement("apiValueDef");
            apiValueDetail.appendChild(apiValueDef);

            apiValue.appendChild(apiValueDetail);

            if (isConst.equals("false"))
            {
                Element apiProperty = outputObject.createElement("apiProperty");
                apiValueDef.appendChild(apiProperty);
            }

            children = ((Element)parent).getElementsByTagName("author");
            if (children != null && children.getLength() != 0)
            {
                String author = children.item(0).getTextContent();
                if (!author.equals(""))
                {
                    Element authorElement = outputObject.createElement("author");
                    authorElement.setTextContent(author);
                    prolog.appendChild(authorElement);
                }
            }

            Element apiAccess = outputObject.createElement("apiAccess");
            apiAccess.setAttribute("value", qualifiedFullName.getMethodNameSpace());
            apiValueDef.appendChild(apiAccess);

            if (((Element)parent).getAttribute("isStatic").equals("true"))
            {
                Element apiStatic = outputObject.createElement("apiStatic");
                apiValueDef.appendChild(apiStatic);
            }
            else
            {
                Element apiDynamic = outputObject.createElement("apiDynamic");
                apiValueDef.appendChild(apiDynamic);
            }

            String defaultValue = ((Element)parent).getAttribute("defaultValue");
            if (defaultValue.length() > 0)
            {
                Element apiData = outputObject.createElement("apiData");
                apiData.setTextContent(defaultValue);
                apiValueDef.appendChild(apiData);
            }

            String type = ((Element)parent).getAttribute("type");

            AsClass fieldClass = classTable.get(type);
            if (fieldClass != null)
            {
                Element apiValueClassifier = outputObject.createElement("apiValueClassifier");
                apiValueClassifier.setTextContent(fieldClass.getFullName());
                apiValueDef.appendChild(apiValueClassifier);
            }
            else
            {
                Element apiType = outputObject.createElement("apiType");
                if (type.equals("*"))
                {
                    apiType.setAttribute("value", "any");
                }
                else
                {
                    apiType.setAttribute("value", type);
                }
                apiValueDef.appendChild(apiType);
            }

            String fullDesc = null;

            NodeList descriptionList = ((Element)parent).getElementsByTagName("description");
            if (descriptionList != null && descriptionList.getLength() != 0)
            {
                fullDesc = descriptionList.item(0).getTextContent();
                Element apiDesc = outputObject.createElement("apiDesc");
                CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(fullDesc, "description", fullName));
                apiDesc.appendChild(cdata);
                apiValueDetail.appendChild(apiDesc);
                asDocUtil.convertDescToDITA(apiDesc, oldNewNamesMap);
                shortdesc.setTextContent(asDocUtil.descToShortDesc(fullDesc));
            }

            children = ((Element)parent).getElementsByTagName("example");
            if (children != null)
            {
                for (int ix = 0; ix < children.getLength(); ix++)
                {
                    Element inputExampleElement = (Element)children.item(ix);

                    Element example = outputObject.createElement("example");

                    CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(inputExampleElement.getTextContent(), "example", fullName));
                    example.appendChild(cdata);
                    apiValueDetail.appendChild(example);
                    asDocUtil.convertDescToDITA(example, oldNewNamesMap);
                }
            }

            children = ((Element)parent).getElementsByTagName("throws");
            if (children != null && children.getLength() != 0)
            {
                for (int ix = 0; ix < children.getLength(); ix++)
                {
                    Element throwsElement = (Element)children.item(ix);
                    apiValueDef.appendChild(createCanThrow(throwsElement, qualifiedFullName));
                }
            }

            processVersions((Element)parent, apiValue);
            processCustoms((Element)parent, apiValue, false, "", "", "");

            children = ((Element)parent).getElementsByTagName("eventType");
            if (children != null && children.getLength() != 0)
            {
                String eventNameStr = children.item(0).getTextContent();
                eventNameStr = eventNameStr.replaceAll("\\n", "");
                eventNameStr = eventNameStr.replaceAll("\\r", "");
                eventNameStr = asDocUtil.normalizeString(eventNameStr);

                int firstSpace = eventNameStr.indexOf(" ");
                if (firstSpace != -1)
                {
                    eventNameStr = eventNameStr.substring(0, firstSpace);
                }

                String eventId = asDocUtil.formatId(fullName) + "_" + eventNameStr;

                Element adobeApiEvent = outputObject.createElement("adobeApiEvent");
                adobeApiEvent.setAttribute("id", eventId);
                Element apiName2 = outputObject.createElement("apiName");
                apiName2.setTextContent(eventNameStr);
                adobeApiEvent.appendChild(apiName2);

                adobeApiEvent.appendChild(outputObject.createElement("prolog"));
                Element adobeApiEventDetail = outputObject.createElement("adobeApiEventDetail");
                adobeApiEvent.appendChild(adobeApiEventDetail);

                Element adobeApiEventDef = outputObject.createElement("adobeApiEventDef");
                adobeApiEventDetail.appendChild(adobeApiEventDef);

                Element apiEventType = outputObject.createElement("apiEventType");
                apiEventType.setTextContent(asDocUtil.formatId(fullName));
                adobeApiEventDef.appendChild(apiEventType);

                Element adobeApiEventClassifier = outputObject.createElement("adobeApiEventClassifier");
                adobeApiEventClassifier.setTextContent(myClass.getFullName());
                adobeApiEventDef.appendChild(adobeApiEventClassifier);

                Element apiDefinedEvent = outputObject.createElement("apiDefinedEvent");
                adobeApiEventDef.appendChild(apiDefinedEvent);

                processCustoms((Element)parent, adobeApiEvent, false, "", "", "");
                myClass.getNode().appendChild(adobeApiEvent);
                if (verbose)
                {
                    System.out.println("event handling for fields added event " + eventNameStr + " to class " + myClass.getNode().getNodeName());
                }

                if (descriptionList != null && descriptionList.getLength() != 0)
                {
                    myClass.getEventCommentTable().put(eventNameStr, descriptionList.item(0).getTextContent());
                }
            }

            if (myClass != null)
            {

                if (myClass.getFieldCount() == 0)
                {
                    Element fields = outputObject.createElement("fields");
                    fields.appendChild(apiValue);
                    myClass.setFields(fields);
                }
                else
                {
                    myClass.getFields().appendChild(apiValue);
                }

                myClass.setFieldCount(myClass.getFieldCount() + 1);
            }
            else
            {
                if (verbose)
                {
                    System.out.print("*** Internal error: can't find class for field: " + qualifiedFullName.getFullClassName());
                }
            }

            if (verbose)
            {
                System.out.println(" done  processing field: " + fullName);
            }
        }
    }

    // <apiException id="ExceptionName">
    // <apiItemName>ExceptionName</apiItemName>
    // <apiType value="primitive data type"/>
    // <apiOperationClassifier>Class name</apiOperationClassifier>
    // <apiDesc>Help text</apiDesc>
    // </apiException>
    private Element createCanThrow(Element source, QualifiedNameInfo qualifiedFullName)
    {
        String throwComment = "";
        String fullThrows = source.getTextContent();
        int nextSpaceIndex = fullThrows.indexOf(" ");

        String errorClassStr = null;
        if (nextSpaceIndex == -1)
        {
            errorClassStr = "Error";
            throwComment = fullThrows;
        }
        else
        {
            errorClassStr = fullThrows.substring(0, nextSpaceIndex);
            throwComment = fullThrows.substring(nextSpaceIndex + 1);
        }
        Element apiException = outputObject.createElement("apiException");
        Element apiDesc = outputObject.createElement("apiDesc");
        CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(throwComment, "throws", qualifiedFullName.getFullClassName()));
        apiDesc.appendChild(cdata);
        apiException.appendChild(apiDesc);
        asDocUtil.convertDescToDITA(apiDesc, oldNewNamesMap);

        AsClass errorClass = classTable.get(errorClassStr);
        if (errorClass == null)
        {
            if (verbose)
            {
                System.out.println("   Can not resolve error class name: " + errorClassStr + " looking in flash.errors");
            }
            errorClass = classTable.get("flash.errors:" + errorClassStr);
        }

        if (errorClass == null)
        {
            if (errorClassStr.indexOf(".") != -1 && errorClassStr.indexOf(":") == -1)
            {
                String[] parts = errorClassStr.split("\\.");
                errorClassStr = "";
                for (int ix = 0; ix < parts.length; ix++)
                {
                    if (ix == parts.length - 1)
                    {
                        errorClassStr += ":";
                    }
                    else if (ix != 0)
                    {
                        errorClassStr += ".";
                    }

                    errorClassStr += parts[ix];
                }
                errorClass = classTable.get(errorClassStr);
            }
        }

        if (errorClass == null)
        {
            errorClass = classTable.get("Error");
        }

        Element apiItemName = outputObject.createElement("apiItemName");
        Element apiOperationClassifier = outputObject.createElement("apiOperationClassifier");

        // no matter if we generate the error class or not. We should still show it in the generated asdoc. 
        // if class is missing. the link should be inactive. i.e. just display and no link.
        if (errorClass != null)
        {
            apiItemName.setTextContent(errorClass.getName());
            apiOperationClassifier.setTextContent(errorClass.getFullName());
        }
        else
        {
            apiItemName.setTextContent(errorClassStr);
            apiOperationClassifier.setTextContent(errorClassStr);
        }

        apiException.appendChild(apiItemName);
        apiException.appendChild(apiOperationClassifier);

        return apiException;
    }

    private void processMethods()
    {
        processMethodsForChildren(domObject);
    }

    private void processMethodsForChildren(Node parent)
    {
        // Go deep and process excludes..
        NodeList listOfChilds = parent.getChildNodes();
        if (listOfChilds != null && listOfChilds.getLength() != 0)
        {
            for (int ix = 0; ix < listOfChilds.getLength(); ix++)
            {
                Node childNode = listOfChilds.item(ix);
                if (childNode.getNodeType() != Node.ELEMENT_NODE)
                {
                    continue;
                }
                Element child = (Element)childNode;

                processMethodsForChildren(child);
            }
        }

        if (parent.getNodeName().equals("method"))
        {
            String name = ((Element)parent).getAttribute("name");
            String fullName = ((Element)parent).getAttribute("fullname");
            if (verbose)
            {
                System.out.println("   #processing method: " + fullName);
            }

            QualifiedNameInfo qualifiedFullName = decomposeFullMethodOrFieldName(fullName);

            if (asDocUtil.hidePackage(qualifiedFullName.getPackageName(), hiddenPackages))
            {
                return;
            }

            boolean isBindable = false;
            if (bindableTable.get(fullName) != null)
            {
                isBindable = true;
            }

            if (!isBindable && bindableTable.get(qualifiedFullName.getFullClassName()) != null)
            {
                isBindable = true;
            }
            if (verbose)
            {
                System.out.println(" @@ qualifiedFullName.getFullClassName() " + qualifiedFullName.getFullClassName());
            }

            AsClass myClass = classTable.get(qualifiedFullName.getFullClassName());

            // skip class methods in the private namespace (always)
            if (myClass == null || !myClass.isInterfaceFlag())
            {
                // constructors are always considered public, even if they're
                // not declared that way
                if (qualifiedFullName.getClassNames() != null || qualifiedFullName.getClassNames().size() != 0 || !name.equals(qualifiedFullName.getClassNames().get(qualifiedFullName.getClassNames().size() - 1)))
                {
                    if (asDocUtil.hideNamespace(qualifiedFullName.getMethodNameSpace(), namespaces))
                    {
                        return;
                    }
                }
            }

            if (myClass != null)
            {
                Element prolog = asDocUtil.getElementByTagName(myClass.getNode(), "prolog");
                if (prolog != null)
                {
                    Element asMetadata = asDocUtil.getElementByTagName(prolog, "asMetadata");
                    if (asMetadata != null)
                    {
                        NodeList excludeList = asMetadata.getElementsByTagName("Exclude");
                        if (excludeList != null && excludeList.getLength() != 0)
                        {
                            String kind = qualifiedFullName.getGetterSetter().length() != 0 ? "property" : "method";

                            for (int ix = 0; ix < excludeList.getLength(); ix++)
                            {
                                Element exclude = (Element)excludeList.item(ix);
                                if (exclude.getAttribute("kind").equals(kind))
                                {
                                    if (exclude.getAttribute("name").equals(name))
                                    {
                                        if (verbose)
                                        {
                                            System.out.println("Excluding " + kind + " " + name + " from " + myClass.getName());
                                        }
                                        return;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if (myClass == null)
            {
                // not an error, probably a method from a class marked @private
                return;
            }
            else if (myClass != null && qualifiedFullName.getGetterSetter().length() != 0)
            {
                if (verbose)
                {
                    System.out.println("   changing method: " + fullName + " into a field (its a getter or setter)");
                }

                Element apiValue = outputObject.createElement("apiValue");
                apiValue.setAttribute("id", asDocUtil.formatId(fullName));

                Element apiName = outputObject.createElement("apiName");
                apiName.setTextContent(name);
                apiValue.appendChild(apiName);

                Element shortdesc = outputObject.createElement("shortdesc");
                apiValue.appendChild(shortdesc);
                Element prolog = outputObject.createElement("prolog");
                apiValue.appendChild(prolog);

                Element apiValueDetail = outputObject.createElement("apiValueDetail");
                Element apiValueDef = outputObject.createElement("apiValueDef");
                apiValueDetail.appendChild(apiValueDef);

                boolean isOverride = Boolean.parseBoolean(((Element)parent).getAttribute("isOverride"));

                if (isOverride)
                {
                    Element apiIsOverride = outputObject.createElement("apiIsOverride");
                    apiValueDef.appendChild(apiIsOverride);
                }

                apiValue.appendChild(apiValueDetail);

                Element apiProperty = outputObject.createElement("apiProperty");
                apiValueDef.appendChild(apiProperty);

                Element apiAccess = outputObject.createElement("apiAccess");
                apiAccess.setAttribute("value", qualifiedFullName.getMethodNameSpace());
                apiValueDef.appendChild(apiAccess);

                if (((Element)parent).getAttribute("isStatic").equals("true"))
                {
                    Element apiStatic = outputObject.createElement("apiStatic");
                    apiValueDef.appendChild(apiStatic);
                }
                else
                {
                    Element apiDynamic = outputObject.createElement("apiDynamic");
                    apiValueDef.appendChild(apiDynamic);
                }

                String getterSetterFullDesc = "";
                NodeList descriptionList = ((Element)parent).getElementsByTagName("description");
                if (descriptionList != null && descriptionList.getLength() != 0)
                {
                    getterSetterFullDesc = descriptionList.item(0).getTextContent();
                    Element apiDesc = outputObject.createElement("apiDesc");
                    CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(getterSetterFullDesc, "description", fullName));
                    apiDesc.appendChild(cdata);
                    apiValueDetail.appendChild(apiDesc);
                    asDocUtil.convertDescToDITA(apiDesc, oldNewNamesMap);
                    shortdesc.setTextContent(asDocUtil.descToShortDesc(getterSetterFullDesc));
                }

                if (isBindable)
                {
                    apiProperty.setAttribute("isBindable", "true");
                }

                processVersions((Element)parent, apiValue);

                if (myClass.getFieldGetSet().get(name) == null)
                {
                    myClass.getFieldGetSet().put(name, 0);
                }

                // skip method tagged with @private, even if they are public
                NodeList privateChilds = ((Element)parent).getElementsByTagName("private");
                if ((privateChilds != null && privateChilds.getLength() != 0) && !includePrivate)
                {
                    if (myClass.getPrivateGetSet().get(name) == null)
                    {
                        myClass.getPrivateGetSet().put(name, 0);
                    }

                    if (qualifiedFullName.getGetterSetter().equals("Get"))
                    {
                        if (myClass.getPrivateGetSet().get(name) <= 1)
                        {
                            myClass.getPrivateGetSet().put(name, 1);
                            myClass.getFieldGetSet().put(name, 1);
                        }
                        else
                        {
                            myClass.getPrivateGetSet().put(name, myClass.getPrivateGetSet().get(name) + 1);
                            myClass.getFieldGetSet().put(name, myClass.getFieldGetSet().get(name) + 1);
                        }
                    }
                    else
                    {
                        myClass.getPrivateGetSet().put(name, myClass.getPrivateGetSet().get(name) + 2);

                        myClass.getFieldGetSet().put(name, myClass.getFieldGetSet().get(name) + 2);
                    }

                    return;
                }

                AsClass fieldTypeClass = null;
                String type = null;

                if (qualifiedFullName.getGetterSetter().equals("Get"))
                {
                    type = ((Element)parent).getAttribute("result_type");
                    fieldTypeClass = classTable.get(type);

                    if (myClass.getFieldGetSet().get(name) <= 1)
                    {
                        myClass.getFieldGetSet().put(name, 1);
                    }
                    else
                    {
                        myClass.getFieldGetSet().put(name, myClass.getFieldGetSet().get(name) + 1);
                    }
                }
                else
                {
                    type = ((Element)parent).getAttribute("param_types");
                    fieldTypeClass = classTable.get(type);

                    myClass.getFieldGetSet().put(name, myClass.getFieldGetSet().get(name) + 2);
                }

                Element apiValueAccess = outputObject.createElement("apiValueAccess");
                apiValueDef.appendChild(apiValueAccess);

                if (fieldTypeClass != null)
                {
                    Element apiValueClassifier = outputObject.createElement("apiValueClassifier");
                    apiValueClassifier.setTextContent(fieldTypeClass.getFullName());
                    apiValueDef.appendChild(apiValueClassifier);
                }
                else
                {
                    Element apiType = outputObject.createElement("apiType");
                    if (type.equals("*"))
                    {
                        apiType.setAttribute("value", "any");
                    }
                    else
                    {
                        apiType.setAttribute("value", type);
                    }
                    apiValueDef.appendChild(apiType);
                }

                NodeList exampleList = ((Element)parent).getElementsByTagName("example");
                if (exampleList != null)
                {
                    for (int ix = 0; ix < exampleList.getLength(); ix++)
                    {
                        Element inputExampleElement = (Element)exampleList.item(ix);

                        Element example = outputObject.createElement("example");

                        CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(inputExampleElement.getTextContent(), "example", fullName));
                        example.appendChild(cdata);
                        apiValueDetail.appendChild(example);
                        asDocUtil.convertDescToDITA(example, oldNewNamesMap);
                    }
                }

                NodeList throwsList = ((Element)parent).getElementsByTagName("throws");
                if (throwsList != null && throwsList.getLength() != 0)
                {
                    for (int ix = 0; ix < throwsList.getLength(); ix++)
                    {
                        Element throwsElement = (Element)throwsList.item(ix);
                        apiValueDef.appendChild(createCanThrow(throwsElement, qualifiedFullName));
                    }
                }

                processCustoms((Element)parent, apiValue, false, "", "", "");

                if (myClass != null)
                {
                    if (myClass.getFieldCount() == 0)
                    {
                        Element fields = outputObject.createElement("fields");
                        fields.appendChild(apiValue);
                        myClass.setFields(fields);

                        myClass.setFieldCount(myClass.getFieldCount() + 1);
                    }
                    else
                    {
                        Element temp = myClass.getFields();
                        NodeList apiValueList = temp.getElementsByTagName("apiValue");
                        int numChildren = apiValueList.getLength();
                        Element foundField = null;

                        for (int ix = 0; ix < numChildren; ix++)
                        {
                            if (((Element)apiValueList.item(ix)).getElementsByTagName("apiName").item(0).getTextContent().equals(apiName.getTextContent()))
                            {
                                foundField = (Element)apiValueList.item(ix);
                                break;
                            }
                        }

                        if (foundField == null)
                        {
                            myClass.getFields().appendChild(apiValue);
                            myClass.setFieldCount(myClass.getFieldCount() + 1);

                        }
                        else
                        {
                            boolean replaceFlag = false;
                            if (getterSetterFullDesc != null && getterSetterFullDesc.trim().length() != 0)
                            {
                                Element foundApiDesc = null;
                                Element foundApiValueDetail = asDocUtil.getElementByTagName(foundField, "apiValueDetail");

                                if (foundApiValueDetail != null)
                                {
                                    foundApiDesc = asDocUtil.getElementByTagName(foundApiValueDetail, "apiDesc");
                                    if (foundApiDesc != null)
                                    {
                                        if (foundApiDesc.getTextContent().trim().length() == 0)
                                        {
                                            replaceFlag = true;
                                        }
                                    }
                                    else
                                    {
                                        replaceFlag = true;
                                    }

                                    if (replaceFlag)
                                    {
                                        temp.replaceChild(apiValue, foundField);
                                    }
                                }
                            }

                            if (!replaceFlag)
                            {
                                Element foundApiValueDef = null;
                                Element foundApiValueDetail = null;

                                Element apiType = asDocUtil.getElementByTagName(apiValueDef, "apiType");
                                if (apiType != null)
                                {
                                    foundApiValueDetail = asDocUtil.getElementByTagName(foundField, "apiValueDetail");
                                    if (foundApiValueDetail != null)
                                    {
                                        foundApiValueDef = asDocUtil.getElementByTagName(foundApiValueDetail, "apiValueDef");
                                        if (foundApiValueDef == null)
                                        {
                                            foundApiValueDef = outputObject.createElement("apiValueDef");
                                            foundApiValueDetail.appendChild(foundApiValueDef);
                                        }
                                    }
                                    else
                                    {
                                        foundApiValueDef = outputObject.createElement("apiValueDef");
                                        foundApiValueDetail = outputObject.createElement("apiValueDetail");
                                        foundApiValueDetail.appendChild(foundApiValueDef);

                                        foundField.appendChild(foundApiValueDetail);
                                    }

                                    if (asDocUtil.getElementByTagName(foundApiValueDef, "apiType") == null)
                                    {
                                        foundApiValueDef.appendChild(apiType);
                                    }
                                }
                                else
                                {
                                    Element apiValueClassifier = asDocUtil.getElementByTagName(apiValueDef, "apiValueClassifier");
                                    if (apiValueClassifier != null)
                                    {
                                        foundApiValueDetail = asDocUtil.getElementByTagName(foundField, "apiValueDetail");
                                        if (foundApiValueDetail != null)
                                        {
                                            foundApiValueDef = asDocUtil.getElementByTagName(foundApiValueDetail, "apiValueDef");
                                            if (foundApiValueDef == null)
                                            {
                                                foundApiValueDef = outputObject.createElement("apiValueDef");
                                                foundApiValueDetail.appendChild(foundApiValueDef);
                                            }
                                        }
                                        else
                                        {
                                            foundApiValueDef = outputObject.createElement("apiValueDef");
                                            foundApiValueDetail = outputObject.createElement("apiValueDetail");
                                            foundApiValueDetail.appendChild(foundApiValueDef);

                                            foundField.appendChild(foundApiValueDetail);
                                        }

                                        if (asDocUtil.getElementByTagName(foundApiValueDef, "apiValueClassifier") == null)
                                        {
                                            foundApiValueDef.appendChild(apiValueClassifier);
                                        }
                                    }
                                    else
                                    {
                                        if (verbose)
                                        {
                                            System.out.println("Error : No type definition for " + name);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else if (myClass != null)
            {
                // skip method tagged with @private, even if they are public
                NodeList privateChilds = ((Element)parent).getElementsByTagName("private");
                if ((privateChilds != null && privateChilds.getLength() != 0) && !includePrivate)
                {
                    return;
                }

                Element apiOperation = null;
                Element detailNode = null;
                Element defNode = null;
                Element shortdesc = null;
                Element prolog = null;
                boolean isConstructor = false;

                if (qualifiedFullName.getClassNames() != null && qualifiedFullName.getClassNames().size() != 0 && name.equals(qualifiedFullName.getClassNames().get(qualifiedFullName.getClassNames().size() - 1)))
                {

                    apiOperation = outputObject.createElement("apiConstructor");
                    apiOperation.setAttribute("id", asDocUtil.formatId(fullName));

                    Element apiName = outputObject.createElement("apiName");
                    apiName.setTextContent(name);
                    apiOperation.appendChild(apiName);

                    shortdesc = outputObject.createElement("shortdesc");
                    apiOperation.appendChild(shortdesc);

                    prolog = outputObject.createElement("prolog");
                    apiOperation.appendChild(prolog);

                    detailNode = outputObject.createElement("apiConstructorDetail");
                    defNode = outputObject.createElement("apiConstructorDef");
                    detailNode.appendChild(defNode);

                    Element apiAccess = outputObject.createElement("apiAccess");
                    apiAccess.setAttribute("value", qualifiedFullName.getMethodNameSpace());
                    defNode.appendChild(apiAccess);

                    apiOperation.appendChild(detailNode);

                    isConstructor = true;
                }
                else
                {
                    boolean isFinal = Boolean.parseBoolean(((Element)parent).getAttribute("isFinal"));
                    boolean isOverride = Boolean.parseBoolean(((Element)parent).getAttribute("isOverride"));
                    boolean isStatic = Boolean.parseBoolean(((Element)parent).getAttribute("isStatic"));

                    if (isOverride)
                    {
                        myClass.getMethodOverrideTable().put(name, "true");
                    }

                    apiOperation = outputObject.createElement("apiOperation");
                    apiOperation.setAttribute("id", asDocUtil.formatId(fullName));

                    Element apiName = outputObject.createElement("apiName");
                    apiName.setTextContent(name);
                    apiOperation.appendChild(apiName);

                    shortdesc = outputObject.createElement("shortdesc");
                    apiOperation.appendChild(shortdesc);

                    prolog = outputObject.createElement("prolog");
                    apiOperation.appendChild(prolog);

                    detailNode = outputObject.createElement("apiOperationDetail");
                    defNode = outputObject.createElement("apiOperationDef");
                    detailNode.appendChild(defNode);

                    Element apiAccess = outputObject.createElement("apiAccess");
                    apiAccess.setAttribute("value", qualifiedFullName.getMethodNameSpace());
                    defNode.appendChild(apiAccess);

                    if (isFinal)
                    {
                        Element apiFinal = outputObject.createElement("apiFinal");
                        defNode.appendChild(apiFinal);
                    }

                    if (isStatic)
                    {
                        Element apiStatic = outputObject.createElement("apiStatic");
                        defNode.appendChild(apiStatic);
                    }

                    if (isOverride)
                    {
                        Element apiIsOverride = outputObject.createElement("apiIsOverride");
                        defNode.appendChild(apiIsOverride);
                    }

                    apiOperation.appendChild(detailNode);
                }

                NodeList descriptionList = ((Element)parent).getElementsByTagName("description");
                if (descriptionList != null && descriptionList.getLength() != 0)
                {
                    String fullDesc = descriptionList.item(0).getTextContent();

                    // if constructor for a mxml file - lets add default description of Constructor
                    if (isConstructor && fullDesc.length() == 0 && myClass.getSourceFile().toLowerCase().endsWith(".mxml"))
                    {
                        fullDesc = "Constructor.";
                    }

                    Element apiDesc = outputObject.createElement("apiDesc");
                    CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(fullDesc, "description", fullName));
                    apiDesc.appendChild(cdata);
                    detailNode.appendChild(apiDesc);
                    asDocUtil.convertDescToDITA(apiDesc, oldNewNamesMap);
                    shortdesc.setTextContent(asDocUtil.descToShortDesc(fullDesc));
                }

                NodeList exampleList = ((Element)parent).getElementsByTagName("example");
                if (exampleList != null)
                {
                    for (int ix = 0; ix < exampleList.getLength(); ix++)
                    {
                        Element inputExampleElement = (Element)exampleList.item(ix);

                        Element example = outputObject.createElement("example");

                        CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(inputExampleElement.getTextContent(), "example", fullName));
                        example.appendChild(cdata);
                        detailNode.appendChild(example);
                        asDocUtil.convertDescToDITA(example, oldNewNamesMap);
                    }
                }

                NodeList throwsList = ((Element)parent).getElementsByTagName("throws");
                if (throwsList != null && throwsList.getLength() != 0)
                {
                    for (int ix = 0; ix < throwsList.getLength(); ix++)
                    {
                        Element throwsElement = (Element)throwsList.item(ix);
                        defNode.appendChild(createCanThrow(throwsElement, myClass.getDecompName()));
                    }
                }

                NodeList authorList = ((Element)parent).getElementsByTagName("author");
                if (authorList != null && authorList.getLength() != 0)
                {
                    String author = authorList.item(0).getTextContent();
                    if (!author.equals(""))
                    {
                        Element authorElement = outputObject.createElement("author");
                        authorElement.setTextContent(author);
                        prolog.appendChild(authorElement);
                    }
                }

                processVersions((Element)parent, apiOperation);

                if (!isConstructor)
                {
                    NodeList returnList = ((Element)parent).getElementsByTagName("return");
                    Element apiReturn = outputObject.createElement("apiReturn");
                    if (returnList != null && returnList.getLength() != 0)
                    {
                        Element apiDesc = outputObject.createElement("apiDesc");

                        CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(returnList.item(0).getTextContent(), "return", fullName));
                        apiDesc.appendChild(cdata);
                        apiReturn.appendChild(apiDesc);

                        defNode.appendChild(apiReturn);
                        asDocUtil.convertDescToDITA(apiDesc, oldNewNamesMap);
                    }
                    else
                    {
                        defNode.appendChild(apiReturn);
                    }

                    String returnType = ((Element)parent).getAttribute("result_type");
                    AsClass returnClass = classTable.get(returnType);
                    if (returnClass != null)
                    {
                        Element apiOperationClassifier = outputObject.createElement("apiOperationClassifier");
                        apiOperationClassifier.setTextContent(returnClass.getFullName());
                        apiReturn.appendChild(apiOperationClassifier);
                    }
                    else if (returnType.equals("*"))
                    {
                        Element apiType = outputObject.createElement("apiType");
                        apiType.setAttribute("value", "any");
                        apiReturn.appendChild(apiType);
                    }
                    else
                    {
                        Element apiType = outputObject.createElement("apiType");
                        apiType.setAttribute("value", returnType);
                        apiReturn.appendChild(apiType);
                    }
                }

                String paramNames = ((Element)parent).getAttribute("param_names");
                String paramTypes = ((Element)parent).getAttribute("param_types");
                String paramDefaults = ((Element)parent).getAttribute("param_defaults");

                processCustoms((Element)parent, apiOperation, true, paramNames, paramTypes, paramDefaults, myClass);

                NodeList eventList = ((Element)parent).getElementsByTagName("event");
                if (eventList != null && eventList.getLength() != 0)
                {
                    for (int ix = 0; ix < eventList.getLength(); ix++)
                    {
                        String fullEventStr = eventList.item(ix).getTextContent();
                        String eventCommentStr = "";
                        int nextSpaceIndex = fullEventStr.indexOf(" ");
                        String eventClassStr = null;
                        if (nextSpaceIndex == -1)
                        {
                            eventClassStr = "Event";
                            eventCommentStr = fullEventStr;
                            nextSpaceIndex = fullEventStr.length() - 1;
                        }
                        String eventName = fullEventStr.substring(0, nextSpaceIndex);
                        /*
                         * var apiEvent = <apiEvent
                         * id={formatId(method.@fullname)} generated="true">
                         * <apiItemName>{eventName}</apiItemName>
                         * <apiEventDetail/> </apiEvent>;
                         */
                        if (eventClassStr == null)
                        {
                            int lastSpaceIndex = nextSpaceIndex + 1;
                            nextSpaceIndex = fullEventStr.indexOf(" ", lastSpaceIndex);
                            if (nextSpaceIndex == -1)
                            {
                                eventClassStr = "Event";
                                eventCommentStr = fullEventStr.substring(lastSpaceIndex);
                            }
                            else
                            {
                                eventClassStr = fullEventStr.substring(lastSpaceIndex, nextSpaceIndex);
                                eventCommentStr = fullEventStr.substring(nextSpaceIndex + 1);
                            }
                        }

                        if (eventClassStr != null && eventClassStr.indexOf(':') == -1 && eventClassStr.indexOf('.') != -1)
                        {
                            int periodIndex = eventClassStr.lastIndexOf('.');
                            eventClassStr = eventClassStr.substring(0, periodIndex) + ':' + eventClassStr.substring(periodIndex + 1);
                        }

                        AsClass eventClass = classTable.get(eventClassStr);

                        if (eventClass == null)
                        {
                            if (verbose)
                            {
                                System.out.println("   Can not resolve event name: " + eventClassStr + " looking in flash.events");
                            }
                            eventClass = classTable.get("flash.events:" + eventClassStr);

                            if (eventClass == null)
                            {
                                if (verbose)
                                {
                                    System.out.println("   Can not resolve event name: " + eventClassStr + " looking in air.update.events");
                                }
                                eventClass = classTable.get("air.update.events:" + eventClassStr);
                            }
                        }

                        String eventId = asDocUtil.formatId(fullName) + "_" + eventName;
                        String eventComment = asDocUtil.validateText(eventCommentStr, "event", fullName);

                        Element adobeApiEvent = outputObject.createElement("adobeApiEvent");
                        adobeApiEvent.setAttribute("id", eventId);
                        Element apiName2 = outputObject.createElement("apiName");
                        apiName2.setTextContent(eventName);
                        adobeApiEvent.appendChild(apiName2);

                        adobeApiEvent.appendChild(outputObject.createElement("prolog"));
                        Element adobeApiEventDetail = outputObject.createElement("adobeApiEventDetail");
                        adobeApiEvent.appendChild(adobeApiEventDetail);

                        Element adobeApiEventDef = outputObject.createElement("adobeApiEventDef");
                        adobeApiEventDetail.appendChild(adobeApiEventDef);

                        Element apiDesc = outputObject.createElement("apiDesc");
                        CDATASection cdata = outputObject.createCDATASection(eventComment);
                        apiDesc.appendChild(cdata);
                        adobeApiEventDetail.appendChild(apiDesc);

                        if (eventClass != null)
                        {
                            Element adobeApiEventClassifier = outputObject.createElement("adobeApiEventClassifier");
                            adobeApiEventClassifier.setTextContent(eventClass.getFullName());
                            adobeApiEventDef.appendChild(adobeApiEventClassifier);
                        }

                        Element apiGeneratedEvent = outputObject.createElement("apiGeneratedEvent");
                        adobeApiEventDef.appendChild(apiGeneratedEvent);

                        asDocUtil.convertDescToDITA(apiDesc, oldNewNamesMap);

                        Element shortdesc2 = outputObject.createElement("shortdesc");
                        shortdesc2.setTextContent(asDocUtil.descToShortDesc(eventComment));
                        adobeApiEvent.appendChild(shortdesc2);

                        apiOperation.appendChild(adobeApiEvent);
                        if (verbose)
                        {
                            System.out.println("event handling for methods added event " + eventName + " to method " + fullName);
                        }
                    }
                }

                if (isConstructor)
                {
                    Element constructors = null;
                    if (myClass.getConstructorCount() == 0)
                    {
                        constructors = outputObject.createElement("constructors");
                        myClass.setConstructors(constructors);
                    }

                    myClass.getConstructors().appendChild(apiOperation);
                    myClass.setConstructorCount(myClass.getConstructorCount() + 1);
                }
                else
                {
                    Element methods = null;
                    if (myClass.getMethodCount() == 0)
                    {
                        methods = outputObject.createElement("methods");
                        myClass.setMethods(methods);
                    }

                    myClass.getMethods().appendChild(apiOperation);
                    myClass.setMethodCount(myClass.getMethodCount() + 1);
                }
            }
            else
            {
                if (verbose)
                {
                    System.out.println("can't find method for class: " + qualifiedFullName.getFullClassName());
                }
            }
            if (verbose)
            {
                System.out.println("  done processing method: " + fullName);
            }
        }
    }

    private void processMetadata()
    {
        processMetadataForChildren(domObject);
    }

    private void processMetadataForChildren(Node parent)
    {
        // Go deep and process excludes..
        NodeList listOfChilds = parent.getChildNodes();
        if (listOfChilds != null && listOfChilds.getLength() != 0)
        {
            for (int ix = 0; ix < listOfChilds.getLength(); ix++)
            {
                Node childNode = listOfChilds.item(ix);
                if (childNode.getNodeType() != Node.ELEMENT_NODE)
                {
                    continue;
                }
                Element child = (Element)childNode;

                processMetadataForChildren(child);
            }
        }

        if (parent.getNodeName().equals("metadata"))
        {
            Element styleElement = asDocUtil.getElementByTagName((Element)parent, "Style");
            if (styleElement != null)
            {
                // skip metadata if private
                NodeList childrenOfStyle = styleElement.getElementsByTagName("private");
                if ((childrenOfStyle != null && childrenOfStyle.getLength() != 0) && !includePrivate)
                {
                    return;
                }

                Element newStyleElement = asDocUtil.renameElementAndImportChild(styleElement, outputObject, "style");

                String name = newStyleElement.getAttribute("name");
                String fullName = newStyleElement.getAttribute("owner");

                AsClass myClass = classTable.get(fullName);

                if (myClass == null)
                {
                    if (verbose)
                    {
                        System.out.println("   Can not resolve style class name: " + fullName);
                    }

                    return;
                }

                Element node = myClass.getNode();

                // we need to get to the Exclude Node. it should be under
                // prolog.asMetadata
                Element prolog = asDocUtil.getElementByTagName(node, "prolog");
                if (prolog != null)
                {
                    Element asMetadata = asDocUtil.getElementByTagName(prolog, "asMetadata");

                    if (asMetadata != null)
                    {
                        HashMap<String, String> attributes = new HashMap<String, String>();
                        attributes.put("kind", "style");
                        attributes.put("name", name);
                        
                        Element excludeElement = asDocUtil.getElementByTagNameAndMatchingAttributes(asMetadata, "Exclude", attributes.entrySet());
                        if (excludeElement != null)
                        {
                            if (verbose)
                            {
                                System.out.println("Excluding style " + name + " from " + myClass.getName());
                            }
                            return;
                        }
                    }
                }

                asDocUtil.processCustoms(newStyleElement, outputObject);

                childrenOfStyle = newStyleElement.getElementsByTagName("default");
                if (childrenOfStyle != null && childrenOfStyle.getLength() != 0)
                {
                    Element defaultElement = (Element)childrenOfStyle.item(0);
                    String defaultText = defaultElement.getTextContent();

                    Element newDefaultElement = outputObject.createElement("default");
                    newDefaultElement.setTextContent(defaultText);

                    newStyleElement.replaceChild(newDefaultElement, defaultElement);
                }

                NodeList descriptionList = newStyleElement.getElementsByTagName("description");
                if (descriptionList != null && descriptionList.getLength() != 0)
                {
                    Element descriptionElement = (Element)descriptionList.item(0);
                    String descriptionText = descriptionElement.getTextContent();

                    Element newDescriptionElement = outputObject.createElement("description");
                    CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(descriptionText, "description", fullName));
                    newDescriptionElement.appendChild(cdata);

                    newStyleElement.replaceChild(newDescriptionElement, descriptionElement);
                    asDocUtil.convertDescToDITA(newDescriptionElement, oldNewNamesMap);
                }

                childrenOfStyle = newStyleElement.getElementsByTagName("see");
                if (childrenOfStyle != null && childrenOfStyle.getLength() != 0)
                {
                    Element relatedLinks = outputObject.createElement("related-links");
                    for (int ix = 0; ix < childrenOfStyle.getLength(); ix++)
                    {
                        Element seeElement = (Element)childrenOfStyle.item(ix);
                        relatedLinks.appendChild(processSeeTag(fullName, seeElement.getTextContent()));
                    }
                    newStyleElement.appendChild(relatedLinks);

                    for (int ix = 0; ix < childrenOfStyle.getLength(); ix++)
                    {
                        newStyleElement.removeChild(childrenOfStyle.item(ix));
                    }

                }

                childrenOfStyle = newStyleElement.getElementsByTagName("copy");
                if (childrenOfStyle != null && childrenOfStyle.getLength() != 0)
                {
                    String text = childrenOfStyle.item(0).getTextContent();
                    text = text.replaceAll("\\s+", "");

                    descriptionList = newStyleElement.getElementsByTagName("description");
                    Element descriptionElement = null;
                    if (descriptionList != null && descriptionList.getLength() != 0)
                    {
                        descriptionElement = (Element)descriptionList.item(0);
                    }
                    else
                    {
                        descriptionElement = outputObject.createElement("description");
                        newStyleElement.appendChild(descriptionElement);
                    }
                    descriptionElement.setAttribute("conref", text);

                    newStyleElement.removeChild(childrenOfStyle.item(0));
                }

                childrenOfStyle = newStyleElement.getElementsByTagName("playerversion");
                if (childrenOfStyle != null && childrenOfStyle.getLength() != 0)
                {
                    String playerversion = childrenOfStyle.item(0).getTextContent();
                    playerversion = playerversion.replaceAll("\\s+", "");

                    newStyleElement.setAttribute("playerVersion", playerversion);
                    newStyleElement.removeChild(childrenOfStyle.item(0));
                }

                Element stylesElement = null;
                Element asMetadata = null;

                if (prolog != null)
                {
                    asMetadata = asDocUtil.getElementByTagName(prolog, "asMetadata");

                    if (asMetadata != null)
                    {
                        stylesElement = asDocUtil.getElementByTagName(asMetadata, "styles");

                        if (stylesElement == null)
                        {
                            stylesElement = outputObject.createElement("styles");
                            asMetadata.appendChild(stylesElement);
                        }
                    }
                    else
                    {
                        stylesElement = outputObject.createElement("styles");
                        asMetadata = outputObject.createElement("asMetadata");

                        asMetadata.appendChild(stylesElement);
                        prolog.appendChild(asMetadata);

                    }
                }
                else
                {
                    stylesElement = outputObject.createElement("styles");
                    asMetadata = outputObject.createElement("asMetadata");
                    asMetadata.appendChild(stylesElement);
                    prolog = outputObject.createElement("prolog");
                    prolog.appendChild(asMetadata);
                    myClass.getNode().appendChild(prolog);
                }

                newStyleElement = (Element)outputObject.importNode(newStyleElement, true);
                stylesElement.appendChild(newStyleElement);
            }

            Element effectElement = asDocUtil.getElementByTagName((Element)parent, "Effect");
            if (effectElement != null)
            {
                // skip metadata if private
                NodeList childrenOfEffect = effectElement.getElementsByTagName("private");
                if ((childrenOfEffect != null && childrenOfEffect.getLength() != 0) && !includePrivate)
                {
                    return;
                }

                Element newEffectElement = asDocUtil.renameElementAndImportChild(effectElement, outputObject, "effect");

                String name = newEffectElement.getAttribute("name");
                String fullName = newEffectElement.getAttribute("owner");

                AsClass myClass = classTable.get(fullName);

                if (myClass == null)
                {
                    if (verbose)
                    {
                        System.out.println("   Can not resolve effect class name: " + fullName);
                    }
                    return;
                }

                Element node = myClass.getNode();

                // we need to get to the Exclude Node. it should be under
                // prolog.asMetadata
                Element prolog = asDocUtil.getElementByTagName(node, "prolog");
                if (prolog != null)
                {
                    Element asMetadata = asDocUtil.getElementByTagName(prolog, "asMetadata");

                    if (asMetadata != null)
                    {
                        HashMap<String, String> attributes = new HashMap<String, String>();
                        attributes.put("kind", "effect");
                        attributes.put("name", name);
                        
                        Element excludeElement = asDocUtil.getElementByTagNameAndMatchingAttributes(asMetadata, "Exclude", attributes.entrySet());
                        if (excludeElement != null)
                        {
                            if (verbose)
                            {
                                System.out.println("Excluding effect " + name + " from " + myClass.getName());
                            }
                            return;
                        }
                    }
                }

                asDocUtil.processCustoms(newEffectElement, outputObject);

                childrenOfEffect = newEffectElement.getElementsByTagName("default");
                if (childrenOfEffect != null && childrenOfEffect.getLength() != 0)
                {
                    Element defaultElement = (Element)childrenOfEffect.item(0);
                    String defaultText = defaultElement.getTextContent();

                    Element newDefaultElement = outputObject.createElement("default");
                    newDefaultElement.setTextContent(defaultText);

                    newEffectElement.replaceChild(newDefaultElement, defaultElement);
                }

                NodeList descriptionList = newEffectElement.getElementsByTagName("description");
                if (descriptionList != null && descriptionList.getLength() != 0)
                {
                    Element descriptionElement = (Element)descriptionList.item(0);
                    String descriptionText = descriptionElement.getTextContent();

                    Element newDescriptionElement = outputObject.createElement("description");
                    CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(descriptionText, "description", fullName));
                    newDescriptionElement.appendChild(cdata);

                    newEffectElement.replaceChild(newDescriptionElement, descriptionElement);
                    asDocUtil.convertDescToDITA(newDescriptionElement, oldNewNamesMap);
                }

                childrenOfEffect = newEffectElement.getElementsByTagName("copy");
                if (childrenOfEffect != null && childrenOfEffect.getLength() != 0)
                {
                    String text = childrenOfEffect.item(0).getTextContent();
                    text = text.replaceAll("[\\n\\s]", "");

                    descriptionList = newEffectElement.getElementsByTagName("description");
                    Element descriptionElement = null;
                    if (descriptionList != null && descriptionList.getLength() != 0)
                    {
                        descriptionElement = (Element)descriptionList.item(0);
                    }
                    else
                    {
                        descriptionElement = outputObject.createElement("description");
                        newEffectElement.appendChild(descriptionElement);
                    }
                    descriptionElement.setAttribute("conref", text);

                    newEffectElement.removeChild(childrenOfEffect.item(0));
                }

                Element effectsElement = null;
                Element asMetadata = null;

                if (prolog != null)
                {
                    asMetadata = asDocUtil.getElementByTagName(prolog, "asMetadata");

                    if (asMetadata != null)
                    {
                        effectsElement = asDocUtil.getElementByTagName(asMetadata, "effects");

                        if (effectsElement == null)
                        {
                            effectsElement = outputObject.createElement("effects");
                            asMetadata.appendChild(effectsElement);
                        }
                    }
                    else
                    {
                        effectsElement = outputObject.createElement("effects");
                        asMetadata = outputObject.createElement("asMetadata");

                        asMetadata.appendChild(effectsElement);
                        prolog.appendChild(asMetadata);

                    }
                }
                else
                {
                    effectsElement = outputObject.createElement("effects");
                    asMetadata = outputObject.createElement("asMetadata");
                    asMetadata.appendChild(effectsElement);
                    prolog = outputObject.createElement("prolog");
                    prolog.appendChild(asMetadata);
                    myClass.getNode().appendChild(prolog);
                }

                newEffectElement = (Element)outputObject.importNode(newEffectElement, true);
                effectsElement.appendChild(newEffectElement);
            }

            Element eventElement = asDocUtil.getElementByTagName((Element)parent, "Event");
            if (eventElement != null)
            {
                // skip metadata if private
                NodeList childrenOfEvent = eventElement.getElementsByTagName("private");
                if ((childrenOfEvent != null && childrenOfEvent.getLength() != 0) && !includePrivate)
                {
                    return;
                }

                String name = eventElement.getAttribute("name");
                String fullName = eventElement.getAttribute("owner");

                AsClass myClass = classTable.get(fullName);

                if (myClass == null)
                {
                    if (verbose)
                    {
                        System.out.println("   Can not resolve event  class name: " + fullName);
                    }
                    return;
                }

                Element node = myClass.getNode();

                // we need to get to the Exclude Node. it should be under
                // prolog.asMetadata
                Element prolog = asDocUtil.getElementByTagName(node, "prolog");
                if (prolog != null)
                {
                    Element asMetadata = asDocUtil.getElementByTagName(prolog, "asMetadata");

                    if (asMetadata != null)
                    {
                        HashMap<String, String> attributes = new HashMap<String, String>();
                        attributes.put("kind", "event");
                        attributes.put("name", name);
                        
                        Element excludeElement = asDocUtil.getElementByTagNameAndMatchingAttributes(asMetadata, "Exclude", attributes.entrySet());
                        if (excludeElement != null)
                        {
                            if (verbose)
                            {
                                System.out.println("Excluding event " + name + " from " + myClass.getName());
                            }
                            return;
                        }
                    }
                }

                String eventType = null;
                childrenOfEvent = ((Element)parent).getElementsByTagName("eventType");
                if (childrenOfEvent != null && childrenOfEvent.getLength() != 0)
                {
                    eventType = childrenOfEvent.item(0).getTextContent().replaceAll("\\s+", "");
                }

                String eventObjectType = eventElement.getAttribute("type");
                String fullDesc = "";

                childrenOfEvent = eventElement.getElementsByTagName("description");
                if (childrenOfEvent != null && childrenOfEvent.getLength() != 0)
                {
                    Element descriptionElement = (Element)childrenOfEvent.item(0);
                    descriptionElement.normalize();

                    fullDesc = descriptionElement.getTextContent();
                }

                String eventId = null;

                if (eventType != null)
                {
                    eventId = asDocUtil.formatId(myClass.getFullName()) + "_" + asDocUtil.formatId(eventType) + "_" + name;
                }
                else
                {
                    eventId = asDocUtil.formatId(myClass.getFullName()) + "_" + asDocUtil.formatId(eventObjectType) + "_" + name;
                }

                Element adobeApiEvent = outputObject.createElement("adobeApiEvent");
                adobeApiEvent.setAttribute("id", eventId);
                Element apiName = outputObject.createElement("apiName");
                apiName.setTextContent(name);
                adobeApiEvent.appendChild(apiName);

                Element shortdesc = outputObject.createElement("shortdesc");
                adobeApiEvent.appendChild(shortdesc);
                adobeApiEvent.appendChild(outputObject.createElement("prolog"));
                Element adobeApiEventDetail = outputObject.createElement("adobeApiEventDetail");
                adobeApiEvent.appendChild(adobeApiEventDetail);

                Element adobeApiEventDef = outputObject.createElement("adobeApiEventDef");
                adobeApiEventDetail.appendChild(adobeApiEventDef);

                if (eventType != null)
                {
                    Element apiEventType = outputObject.createElement("apiEventType");
                    apiEventType.setTextContent(eventType);
                    adobeApiEventDef.appendChild(apiEventType);
                }

                if (eventObjectType != null)
                {
                    Element adobeApiEventClassifier = outputObject.createElement("adobeApiEventClassifier");
                    adobeApiEventClassifier.setTextContent(eventObjectType);
                    adobeApiEventDef.appendChild(adobeApiEventClassifier);
                }

                Element apiGeneratedEvent = outputObject.createElement("apiGeneratedEvent");
                adobeApiEventDef.appendChild(apiGeneratedEvent);

                Element apiDesc = outputObject.createElement("apiDesc");
                CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(fullDesc, "description", fullName));
                apiDesc.appendChild(cdata);
                adobeApiEventDetail.appendChild(apiDesc);

                asDocUtil.convertDescToDITA(apiDesc, oldNewNamesMap);
                shortdesc.setTextContent(asDocUtil.descToShortDesc(fullDesc));

                eventElement.setAttribute("fullname", fullName);

                processVersions(eventElement, adobeApiEvent);

                processCustoms(eventElement, adobeApiEvent, false, "", "", "");

                Element deprecatedNode = null;

                if (!eventElement.getAttribute("deprecatedMessage").equals(""))
                {
                    deprecatedNode = outputObject.createElement("apiDeprecated");
                    Element apiDesc2 = outputObject.createElement("apiDesc");
                    CDATASection cdata2 = outputObject.createCDATASection(eventElement.getAttribute("deprecatedMessage"));
                    apiDesc2.appendChild(cdata2);
                    deprecatedNode.appendChild(apiDesc2);
                    asDocUtil.convertDescToDITA(apiDesc2, oldNewNamesMap);
                }
                else if (!eventElement.getAttribute("deprecatedReplacement").equals(""))
                {
                    deprecatedNode = outputObject.createElement("apiDeprecated");
                    deprecatedNode.setAttribute("replacement", eventElement.getAttribute("deprecatedReplacement"));
                }

                if (deprecatedNode != null)
                {
                    if (!eventElement.getAttribute("deprecatedSince").equals(""))
                    {
                        deprecatedNode.setAttribute("sinceVersion", eventElement.getAttribute("deprecatedSince"));
                    }
                    adobeApiEventDef.appendChild(deprecatedNode);
                }

                childrenOfEvent = eventElement.getElementsByTagName("example");
                if (childrenOfEvent != null)
                {
                    for (int ix = 0; ix < childrenOfEvent.getLength(); ix++)
                    {
                        Element inputExampleElement = (Element)childrenOfEvent.item(ix);

                        Element example = outputObject.createElement("example");

                        CDATASection cdata2 = outputObject.createCDATASection(asDocUtil.validateText(inputExampleElement.getTextContent(), "example", fullName));
                        example.appendChild(cdata2);
                        adobeApiEvent.appendChild(example);
                        asDocUtil.convertDescToDITA(example, oldNewNamesMap);
                    }
                }

                if (myClass != null && eventElement != null)
                {
                    myClass.getNode().appendChild(adobeApiEvent);
                    if (verbose)
                    {
                        System.out.println("event handling for metadata added event " + name + " to class " + fullName);
                    }
                }
                else
                {
                    if (verbose)
                    {
                        System.out.println("*** Internal error: can't find class for event: " + fullName);
                    }
                }
            }

            Element bindableElement = asDocUtil.getElementByTagName((Element)parent, "Bindable");
            if (bindableElement != null)
            {
                // skip metadata if private
                NodeList childrenOfBindable = bindableElement.getElementsByTagName("private");
                if ((childrenOfBindable != null && childrenOfBindable.getLength() != 0) && !includePrivate)
                {
                    return;
                }

                String fullName = bindableElement.getAttribute("owner");
                if (verbose)
                {
                    System.out.println(" processing bindable " + fullName);
                }
                
                String bindableEventName = bindableElement.getAttribute("name");

                AsClass myClass = classTable.get(fullName);

                if (myClass == null)
                {
                    QualifiedNameInfo qualifiedFullName = decomposeFullMethodOrFieldName(fullName);
                    myClass = classTable.get(qualifiedFullName.getFullClassName());
                    boolean found = false;
                    if (myClass != null && myClass.getFields() != null)
                    {
                        NodeList apiValueList = myClass.getFields().getChildNodes();

                        for (int ix = 0; ix < apiValueList.getLength(); ix++)
                        {
                            Element apiValueElement = (Element)apiValueList.item(ix);
                            if (apiValueElement.getAttribute("id").equals(asDocUtil.formatId(fullName)))
                            {

                                Element apiValueDetail = null;
                                Element apiValueDef = null;
                                Element apiProperty = null;

                                NodeList apiValueDetailList = apiValueElement.getElementsByTagName("apiValueDetail");
                                if (apiValueDetailList != null && apiValueDetailList.getLength() != 0)
                                {
                                    apiValueDetail = (Element)apiValueDetailList.item(0);

                                    NodeList apiValueDefList = apiValueDetail.getElementsByTagName("apiValueDef");
                                    if (apiValueDefList != null && apiValueDefList.getLength() != 0)
                                    {
                                        apiValueDef = (Element)apiValueDefList.item(0);

                                        NodeList apiPropertyList = apiValueDef.getElementsByTagName("apiProperty");
                                        if (apiPropertyList != null && apiPropertyList.getLength() != 0)
                                        {
                                            apiProperty = (Element)apiPropertyList.item(0);
                                            if (apiProperty.getAttribute("isBindable").equals("") || !apiProperty.getAttribute("isBindable").equals("true"))
                                            {
                                                apiProperty.setAttribute("isBindable", "true");
                                                
                                                if (!bindableEventName.equals(""))
                                                {
                                                    apiProperty.setAttribute("name", bindableEventName);  
                                                }
                                                
                                                found = true;
                                                break;
                                            }
                                        }
                                        else
                                        {
                                            apiProperty = outputObject.createElement("apiProperty");
                                            apiProperty.setAttribute("isBindable", "true");
                                            
                                            if (!bindableEventName.equals(""))
                                            {
                                                apiProperty.setAttribute("name", bindableEventName);  
                                            }

                                            apiValueDef.appendChild(apiProperty);
                                            found = true;
                                            break;
                                        }
                                    }
                                    else
                                    {
                                        apiProperty = outputObject.createElement("apiProperty");
                                        apiProperty.setAttribute("isBindable", "true");
                                        
                                        if (!bindableEventName.equals(""))
                                        {
                                            apiProperty.setAttribute("name", bindableEventName);  
                                        }
                                        
                                        apiValueDef = outputObject.createElement("apiValueDef");
                                        apiValueDef.appendChild(apiProperty);

                                        apiValueDetail.appendChild(apiValueDef);
                                        found = true;
                                        break;
                                    }
                                }
                                else
                                {
                                    apiProperty = outputObject.createElement("apiProperty");
                                    apiProperty.setAttribute("isBindable", "true");
                                    
                                    if (!bindableEventName.equals(""))
                                    {
                                        apiProperty.setAttribute("name", bindableEventName);  
                                    }

                                    apiValueDef = outputObject.createElement("apiValueDef");
                                    apiValueDetail = outputObject.createElement("apiValueDetail");

                                    apiValueDetail.appendChild(apiValueDef);
                                    apiValueDef.appendChild(apiProperty);
                                    apiValueElement.appendChild(apiValueDetail);
                                    found = true;
                                    break;
                                }

                            }
                        }

                    }

                    if (!found)
                    {
                        bindableTable.put(fullName, "isBindable");
                    }
                }
                else
                {
                    bindableTable.put(fullName, "isBindable");
                }
            }

            Element defaultPropertyElement = asDocUtil.getElementByTagName((Element)parent, "DefaultProperty");
            if (defaultPropertyElement != null)
            {
                String fullName = defaultPropertyElement.getAttribute("owner");

                AsClass myClass = classTable.get(fullName);

                if (myClass != null)
                {

                    Element node = myClass.getNode();
                    Element asMetadata = null;

                    Element defaultProperty = outputObject.createElement("DefaultProperty");
                    defaultProperty.setAttribute("name", defaultPropertyElement.getAttribute("name"));
                    Element prolog = asDocUtil.getElementByTagName(node, "prolog");
                    if (prolog != null)
                    {
                        asMetadata = asDocUtil.getElementByTagName(prolog, "asMetadata");

                        if (asMetadata != null)
                        {
                            asMetadata.appendChild(defaultProperty);
                        }
                        else
                        {
                            asMetadata = outputObject.createElement("asMetadata");
                            asMetadata.appendChild(defaultProperty);
                            prolog.appendChild(asMetadata);
                        }
                    }
                    else
                    {
                        asMetadata = outputObject.createElement("asMetadata");
                        asMetadata.appendChild(defaultProperty);

                        prolog = outputObject.createElement("prolog");
                        prolog.appendChild(asMetadata);

                        myClass.getNode().appendChild(prolog);
                    }
                }
            }

            Element deprecatedElement = asDocUtil.getElementByTagName((Element)parent, "Deprecated");
            if (deprecatedElement != null)
            {
                String fullName = deprecatedElement.getAttribute("owner");

                if (verbose)
                {
                    System.out.println(" processing deprecated " + fullName);
                }

                AsClass myClass = classTable.get(fullName);
                Node node = null;

                if (myClass != null)
                {
                    node = myClass.getNode();
                }
                else
                {
                    QualifiedNameInfo qualifiedFullName = decomposeFullMethodOrFieldName(fullName);
                    myClass = classTable.get(qualifiedFullName.getFullClassName());
                    if (myClass != null)
                    {
                        if (myClass.getFields() != null)
                        {
                            NodeList childNodeList = myClass.getFields().getElementsByTagName("apiValue");
                            for (int ix = 0; ix < childNodeList.getLength(); ix++)
                            {
                                Element childElement = (Element)childNodeList.item(ix);
                                if (childElement.getAttribute("id").equals(asDocUtil.formatId(fullName)))
                                {
                                    node = childElement;
                                    break;
                                }
                            }
                        }

                        if (node == null && myClass.getMethods() != null)
                        {
                            NodeList childNodeList = myClass.getMethods().getElementsByTagName("apiOperation");
                            for (int ix = 0; ix < childNodeList.getLength(); ix++)
                            {
                                Element childElement = (Element)childNodeList.item(ix);
                                if (childElement.getAttribute("id").equals(asDocUtil.formatId(fullName)))
                                {
                                    node = childElement;
                                    break;
                                }
                            }
                        }
                    }
                    else
                    {
                        if (verbose)
                        {
                            System.out.println("   did not find my class for : " + qualifiedFullName.getFullClassName());
                        }
                    }
                }

                if (node == null)
                {
                    return;
                }

                Element defNode = asDocUtil.getDefNode((Element)node);

                Element apiDeprecated = outputObject.createElement("apiDeprecated");

                if (!deprecatedElement.getAttribute("replacement").equals(""))
                {
                    apiDeprecated.setAttribute("replacement", deprecatedElement.getAttribute("replacement"));
                }
                else if (!deprecatedElement.getAttribute("message").equals(""))
                {
                    Element apiDesc = outputObject.createElement("apiDesc");
                    CDATASection cdata = outputObject.createCDATASection(deprecatedElement.getAttribute("message"));
                    apiDesc.appendChild(cdata);
                    apiDeprecated.appendChild(apiDesc);
                    asDocUtil.convertDescToDITA(apiDesc, oldNewNamesMap);
                }
                else if (!deprecatedElement.getAttribute("name").equals(""))
                {
                    Element apiDesc = outputObject.createElement("apiDesc");
                    CDATASection cdata = outputObject.createCDATASection(deprecatedElement.getAttribute("name"));
                    apiDesc.appendChild(cdata);
                    apiDeprecated.appendChild(apiDesc);
                    asDocUtil.convertDescToDITA(apiDesc, oldNewNamesMap);
                }

                if (!deprecatedElement.getAttribute("since").equals(""))
                {
                    apiDeprecated.setAttribute("sinceVersion", deprecatedElement.getAttribute("since"));
                }

                defNode.appendChild(apiDeprecated);
            }

            Element skinStateElement = asDocUtil.getElementByTagName((Element)parent, "SkinState");
            if (skinStateElement != null)
            {
                // skip metadata if private
                NodeList childrenOfSkinState = skinStateElement.getElementsByTagName("private");
                if ((childrenOfSkinState != null && childrenOfSkinState.getLength() != 0) && !includePrivate)
                {
                    return;
                }

                String fullName = skinStateElement.getAttribute("owner");
                String name = skinStateElement.getAttribute("name");

                AsClass myClass = classTable.get(fullName);

                if (myClass != null)
                {
                    Element node = myClass.getNode();

                    Element skinStatesElement = null;
                    Element asMetadata = null;
                    Element prolog = asDocUtil.getElementByTagName(node, "prolog");
                    if (prolog != null)
                    {
                        asMetadata = asDocUtil.getElementByTagName(prolog, "asMetadata");
                        if (asMetadata != null)
                        {
                            HashMap<String, String> attributes = new HashMap<String, String>();
                            attributes.put("kind", "SkinState");
                            attributes.put("name", name);
                            
                            Element excludeElement = asDocUtil.getElementByTagNameAndMatchingAttributes(asMetadata, "Exclude", attributes.entrySet());
                            if (excludeElement != null)
                            {
                                if (verbose)
                                {
                                    System.out.println("Excluding SkinState " + name + " from " + myClass.getName());
                                }
                                return;
                            }

                            skinStatesElement = asDocUtil.getElementByTagName(asMetadata, "skinStates");
                            if (skinStatesElement == null)
                            {
                                skinStatesElement = outputObject.createElement("skinStates");
                                asMetadata.appendChild(skinStatesElement);
                            }
                        }
                        else
                        {
                            skinStatesElement = outputObject.createElement("skinStates");
                            asMetadata = outputObject.createElement("asMetadata");
                            asMetadata.appendChild(skinStatesElement);
                            prolog.appendChild(asMetadata);
                        }
                    }
                    else
                    {
                        skinStatesElement = outputObject.createElement("skinStates");
                        asMetadata = outputObject.createElement("asMetadata");
                        asMetadata.appendChild(skinStatesElement);

                        prolog = outputObject.createElement("prolog");
                        prolog.appendChild(asMetadata);

                        myClass.getNode().appendChild(prolog);
                    }

                    Element newSkinStateElement = (Element)outputObject.importNode(skinStateElement, true);

                    asDocUtil.processCustoms(newSkinStateElement, outputObject);

                    childrenOfSkinState = newSkinStateElement.getElementsByTagName("default");
                    if (childrenOfSkinState != null && childrenOfSkinState.getLength() != 0)
                    {
                        Element defaultElement = (Element)childrenOfSkinState.item(0);
                        String defaultText = defaultElement.getTextContent();

                        Element newDefaultElement = outputObject.createElement("default");
                        newDefaultElement.setTextContent(defaultText);

                        newSkinStateElement.replaceChild(newDefaultElement, defaultElement);
                    }

                    NodeList descriptionList = newSkinStateElement.getElementsByTagName("description");
                    if (descriptionList != null && descriptionList.getLength() != 0)
                    {
                        Element descriptionElement = (Element)descriptionList.item(0);
                        String descriptionText = descriptionElement.getTextContent();

                        Element newDescriptionElement = outputObject.createElement("description");
                        CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(descriptionText, "description", fullName));
                        newDescriptionElement.appendChild(cdata);

                        newSkinStateElement.replaceChild(newDescriptionElement, descriptionElement);
                        asDocUtil.convertDescToDITA(newDescriptionElement, oldNewNamesMap);
                    }

                    childrenOfSkinState = newSkinStateElement.getElementsByTagName("see");
                    if (childrenOfSkinState != null && childrenOfSkinState.getLength() != 0)
                    {
                        Element relatedLinks = outputObject.createElement("related-links");
                        for (int ix = 0; ix < childrenOfSkinState.getLength(); ix++)
                        {
                            Element seeElement = (Element)childrenOfSkinState.item(ix);
                            relatedLinks.appendChild(processSeeTag(fullName, seeElement.getTextContent()));
                        }
                        newSkinStateElement.appendChild(relatedLinks);

                        for (int ix = 0; ix < childrenOfSkinState.getLength(); ix++)
                        {
                            newSkinStateElement.removeChild(childrenOfSkinState.item(ix));
                        }

                    }

                    childrenOfSkinState = newSkinStateElement.getElementsByTagName("copy");
                    if (childrenOfSkinState != null && childrenOfSkinState.getLength() != 0)
                    {
                        String text = childrenOfSkinState.item(0).getTextContent();
                        text = text.replaceAll("\\s+", "");

                        descriptionList = newSkinStateElement.getElementsByTagName("description");
                        Element descriptionElement = null;
                        if (descriptionList != null && descriptionList.getLength() != 0)
                        {
                            descriptionElement = (Element)descriptionList.item(0);
                        }
                        else
                        {
                            descriptionElement = outputObject.createElement("description");
                            newSkinStateElement.appendChild(descriptionElement);
                        }
                        descriptionElement.setAttribute("conref", text);

                        newSkinStateElement.removeChild(childrenOfSkinState.item(0));
                    }

                    childrenOfSkinState = newSkinStateElement.getElementsByTagName("playerversion");
                    if (childrenOfSkinState != null && childrenOfSkinState.getLength() != 0)
                    {
                        String playerversion = childrenOfSkinState.item(0).getTextContent();
                        playerversion = playerversion.replaceAll("\\s+", "");

                        newSkinStateElement.setAttribute("playerVersion", playerversion);
                        newSkinStateElement.removeChild(childrenOfSkinState.item(0));
                    }

                    skinStatesElement.appendChild(newSkinStateElement);
                }
            }

            Element skinPartElement = asDocUtil.getElementByTagName((Element)parent, "SkinPart");
            if (skinPartElement != null)
            {
                // skip metadata if private
                NodeList childrenOfSkinPart = skinPartElement.getElementsByTagName("private");
                if ((childrenOfSkinPart != null && childrenOfSkinPart.getLength() != 0) && !includePrivate)
                {
                    return;
                }

                String fullName = skinPartElement.getAttribute("owner");
                String name = skinPartElement.getAttribute("name");

                AsClass myClass = classTable.get(fullName);

                if (myClass != null)
                {
                    Element node = myClass.getNode();

                    Element skinPartsElement = null;
                    Element asMetadata = null;
                    Element prolog = asDocUtil.getElementByTagName(node, "prolog");
                    if (prolog != null)
                    {
                        asMetadata = asDocUtil.getElementByTagName(prolog, "asMetadata");
                        if (asMetadata != null)
                        {
                            HashMap<String, String> attributes = new HashMap<String, String>();
                            attributes.put("kind", "SkinPart");
                            attributes.put("name", name);
                            
                            Element excludeElement = asDocUtil.getElementByTagNameAndMatchingAttributes(asMetadata, "Exclude", attributes.entrySet());
                            if (excludeElement != null)
                            {
                                if (verbose)
                                {
                                    System.out.println("Excluding SkinPart " + name + " from " + myClass.getName());
                                }
                                return;
                            }

                            skinPartsElement = asDocUtil.getElementByTagName(asMetadata, "skinParts");
                            if (skinPartsElement == null)
                            {
                                skinPartsElement = outputObject.createElement("skinParts");
                                asMetadata.appendChild(skinPartsElement);
                            }
                        }
                        else
                        {
                            skinPartsElement = outputObject.createElement("skinParts");
                            asMetadata = outputObject.createElement("asMetadata");
                            asMetadata.appendChild(skinPartsElement);
                            prolog.appendChild(asMetadata);
                        }
                    }
                    else
                    {
                        skinPartsElement = outputObject.createElement("skinParts");
                        asMetadata = outputObject.createElement("asMetadata");
                        asMetadata.appendChild(skinPartsElement);

                        prolog = outputObject.createElement("prolog");
                        prolog.appendChild(asMetadata);

                        myClass.getNode().appendChild(prolog);
                    }

                    Element newSkinPartElement = (Element)outputObject.importNode(skinPartElement, true);

                    asDocUtil.processCustoms(newSkinPartElement, outputObject);

                    childrenOfSkinPart = newSkinPartElement.getElementsByTagName("default");
                    if (childrenOfSkinPart != null && childrenOfSkinPart.getLength() != 0)
                    {
                        Element defaultElement = (Element)childrenOfSkinPart.item(0);
                        String defaultText = defaultElement.getTextContent();

                        Element newDefaultElement = outputObject.createElement("default");
                        newDefaultElement.setTextContent(defaultText);

                        newSkinPartElement.replaceChild(newDefaultElement, defaultElement);
                    }

                    NodeList descriptionList = newSkinPartElement.getElementsByTagName("description");
                    if (descriptionList != null && descriptionList.getLength() != 0)
                    {
                        Element descriptionElement = (Element)descriptionList.item(0);
                        String descriptionText = descriptionElement.getTextContent();

                        Element shortdesc = outputObject.createElement("shortdesc");
                        newSkinPartElement.appendChild(shortdesc);
                        shortdesc.setTextContent(asDocUtil.descToShortDesc(descriptionText));
                        
                        Element newDescriptionElement = outputObject.createElement("description");
                        CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(descriptionText, "description", fullName));
                        newDescriptionElement.appendChild(cdata);

                        newSkinPartElement.replaceChild(newDescriptionElement, descriptionElement);
                        asDocUtil.convertDescToDITA(newDescriptionElement, oldNewNamesMap);
                    }

                    childrenOfSkinPart = newSkinPartElement.getElementsByTagName("see");
                    if (childrenOfSkinPart != null && childrenOfSkinPart.getLength() != 0)
                    {
                        Element relatedLinks = outputObject.createElement("related-links");
                        for (int ix = 0; ix < childrenOfSkinPart.getLength(); ix++)
                        {
                            Element seeElement = (Element)childrenOfSkinPart.item(ix);
                            relatedLinks.appendChild(processSeeTag(fullName, seeElement.getTextContent()));
                        }
                        newSkinPartElement.appendChild(relatedLinks);

                        for (int ix = 0; ix < childrenOfSkinPart.getLength(); ix++)
                        {
                            newSkinPartElement.removeChild(childrenOfSkinPart.item(ix));
                        }

                    }

                    childrenOfSkinPart = newSkinPartElement.getElementsByTagName("copy");
                    if (childrenOfSkinPart != null && childrenOfSkinPart.getLength() != 0)
                    {
                        String text = childrenOfSkinPart.item(0).getTextContent();
                        text = text.replaceAll("\\s+", "");

                        descriptionList = newSkinPartElement.getElementsByTagName("description");
                        Element descriptionElement = null;
                        if (descriptionList != null && descriptionList.getLength() != 0)
                        {
                            descriptionElement = (Element)descriptionList.item(0);
                        }
                        else
                        {
                            descriptionElement = outputObject.createElement("description");
                            newSkinPartElement.appendChild(descriptionElement);
                        }
                        descriptionElement.setAttribute("conref", text);

                        newSkinPartElement.removeChild(childrenOfSkinPart.item(0));
                    }

                    childrenOfSkinPart = newSkinPartElement.getElementsByTagName("playerversion");
                    if (childrenOfSkinPart != null && childrenOfSkinPart.getLength() != 0)
                    {
                        String playerversion = childrenOfSkinPart.item(0).getTextContent();
                        playerversion = playerversion.replaceAll("\\s+", "");

                        newSkinPartElement.setAttribute("playerVersion", playerversion);
                        newSkinPartElement.removeChild(childrenOfSkinPart.item(0));
                    }

                    skinPartsElement.appendChild(newSkinPartElement);
                }
            }

            Element alternativeElement = asDocUtil.getElementByTagName((Element)parent, "Alternative");
            if (alternativeElement != null)
            {
                String fullName = alternativeElement.getAttribute("owner");

                AsClass myClass = classTable.get(fullName);

                if (myClass != null)
                {
                    Element node = myClass.getNode();
                    Element asMetadata = null;

                    Element prolog = asDocUtil.getElementByTagName(node, "prolog");
                    if (prolog != null)
                    {
                        asMetadata = asDocUtil.getElementByTagName(prolog, "asMetadata");

                        if (asMetadata == null)
                        {
                            asMetadata = outputObject.createElement("asMetadata");
                            prolog.appendChild(asMetadata);
                        }
                    }
                    else
                    {
                        asMetadata = outputObject.createElement("asMetadata");

                        prolog = outputObject.createElement("prolog");
                        prolog.appendChild(asMetadata);

                        myClass.getNode().appendChild(prolog);
                    }

                    Element alternative = (Element)outputObject.importNode(alternativeElement, true);

                    asDocUtil.processCustoms(alternative, outputObject);

                    NodeList descriptionList = alternative.getElementsByTagName("description");
                    if (descriptionList != null && descriptionList.getLength() != 0)
                    {
                        Element descriptionElement = (Element)descriptionList.item(0);
                        String descriptionText = descriptionElement.getTextContent();

                        Element newDescriptionElement = outputObject.createElement("description");
                        CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(descriptionText, "description", fullName));
                        newDescriptionElement.appendChild(cdata);

                        alternative.replaceChild(newDescriptionElement, descriptionElement);
                        asDocUtil.convertDescToDITA(newDescriptionElement, oldNewNamesMap);
                    }

                    NodeList childrenOfAlternative = alternative.getElementsByTagName("see");
                    if (childrenOfAlternative != null && childrenOfAlternative.getLength() != 0)
                    {
                        Element relatedLinks = outputObject.createElement("related-links");
                        for (int ix = 0; ix < childrenOfAlternative.getLength(); ix++)
                        {
                            Element seeElement = (Element)childrenOfAlternative.item(ix);
                            relatedLinks.appendChild(processSeeTag(fullName, seeElement.getTextContent()));
                        }
                        alternative.appendChild(relatedLinks);

                        for (int ix = 0; ix < childrenOfAlternative.getLength(); ix++)
                        {
                            alternative.removeChild(childrenOfAlternative.item(ix));
                        }

                    }

                    childrenOfAlternative = alternative.getElementsByTagName("copy");
                    if (childrenOfAlternative != null && childrenOfAlternative.getLength() != 0)
                    {
                        String text = childrenOfAlternative.item(0).getTextContent();
                        text = text.replaceAll("\\s+", "");

                        descriptionList = alternative.getElementsByTagName("description");
                        Element descriptionElement = null;
                        if (descriptionList != null && descriptionList.getLength() != 0)
                        {
                            descriptionElement = (Element)descriptionList.item(0);
                        }
                        else
                        {
                            descriptionElement = outputObject.createElement("description");
                            alternative.appendChild(descriptionElement);
                        }
                        descriptionElement.setAttribute("conref", text);

                        alternative.removeChild(childrenOfAlternative.item(0));
                    }

                    asMetadata.appendChild(alternative);
                }
            }
            
            Element discouragedForProfileElement = asDocUtil.getElementByTagName((Element)parent, "DiscouragedForProfile");
            if (discouragedForProfileElement != null)
            {
                // skip metadata if private
                NodeList childrenOfDiscouragedForProfile = discouragedForProfileElement.getElementsByTagName("private");
                if ((childrenOfDiscouragedForProfile != null && childrenOfDiscouragedForProfile.getLength() != 0) && !includePrivate)
                {
                    return;
                }

                String fullName = discouragedForProfileElement.getAttribute("owner");
                String name = discouragedForProfileElement.getAttribute("name");

                AsClass myClass = classTable.get(fullName);

                if (myClass != null)
                {
                    Element node = myClass.getNode();

                    Element profilesElement = null;
                    Element asMetadata = null;
                    Element prolog = asDocUtil.getElementByTagName(node, "prolog");
                    if (prolog != null)
                    {
                        asMetadata = asDocUtil.getElementByTagName(prolog, "asMetadata");
                        if (asMetadata != null)
                        {
                            HashMap<String, String> attributes = new HashMap<String, String>();
                            attributes.put("kind", "DiscouragedForProfile");
                            attributes.put("name", name);
                            
                            Element excludeElement = asDocUtil.getElementByTagNameAndMatchingAttributes(asMetadata, "Exclude", attributes.entrySet());
                            if (excludeElement != null)
                            {
                                if (verbose)
                                {
                                    System.out.println("Excluding DiscouragedForProfile " + name + " from " + myClass.getName());
                                }
                                return;
                            }

                            profilesElement = asDocUtil.getElementByTagName(asMetadata, "discouragedForProfiles");
                            if (profilesElement == null)
                            {
                            		profilesElement = outputObject.createElement("discouragedForProfiles");
                                asMetadata.appendChild(profilesElement);
                            }
                        }
                        else
                        {
                        		profilesElement = outputObject.createElement("discouragedForProfiles");
                            asMetadata = outputObject.createElement("asMetadata");
                            asMetadata.appendChild(profilesElement);
                            prolog.appendChild(asMetadata);
                        }
                    }
                    else
                    {
                    		profilesElement = outputObject.createElement("discouragedForProfiles");
                        asMetadata = outputObject.createElement("asMetadata");
                        asMetadata.appendChild(profilesElement);

                        prolog = outputObject.createElement("prolog");
                        prolog.appendChild(asMetadata);

                        myClass.getNode().appendChild(prolog);
                    }

                    Element discouragedForProfile = (Element)outputObject.importNode(discouragedForProfileElement, true);

                    asDocUtil.processCustoms(discouragedForProfile, outputObject);

                    NodeList descriptionList = discouragedForProfile.getElementsByTagName("description");
                    if (descriptionList != null && descriptionList.getLength() != 0)
                    {
                        Element descriptionElement = (Element)descriptionList.item(0);
                        String descriptionText = descriptionElement.getTextContent();

                        Element newDescriptionElement = outputObject.createElement("description");
                        CDATASection cdata = outputObject.createCDATASection(asDocUtil.validateText(descriptionText, "description", fullName));
                        newDescriptionElement.appendChild(cdata);

                        discouragedForProfile.replaceChild(newDescriptionElement, descriptionElement);
                        asDocUtil.convertDescToDITA(newDescriptionElement, oldNewNamesMap);
                    }

                    NodeList childrenOfDiscouragedForProfiles = discouragedForProfile.getElementsByTagName("see");
                    if (childrenOfDiscouragedForProfiles != null && childrenOfDiscouragedForProfiles.getLength() != 0)
                    {
                        Element relatedLinks = outputObject.createElement("related-links");
                        for (int ix = 0; ix < childrenOfDiscouragedForProfiles.getLength(); ix++)
                        {
                            Element seeElement = (Element)childrenOfDiscouragedForProfiles.item(ix);
                            relatedLinks.appendChild(processSeeTag(fullName, seeElement.getTextContent()));
                        }
                        discouragedForProfile.appendChild(relatedLinks);

                        for (int ix = 0; ix < childrenOfDiscouragedForProfiles.getLength(); ix++)
                        {
                        	discouragedForProfile.removeChild(childrenOfDiscouragedForProfiles.item(ix));
                        }

                    }

                    childrenOfDiscouragedForProfiles = discouragedForProfile.getElementsByTagName("copy");
                    if (childrenOfDiscouragedForProfiles != null && childrenOfDiscouragedForProfiles.getLength() != 0)
                    {
                        String text = childrenOfDiscouragedForProfiles.item(0).getTextContent();
                        text = text.replaceAll("\\s+", "");

                        descriptionList = discouragedForProfile.getElementsByTagName("description");
                        Element descriptionElement = null;
                        if (descriptionList != null && descriptionList.getLength() != 0)
                        {
                            descriptionElement = (Element)descriptionList.item(0);
                        }
                        else
                        {
                            descriptionElement = outputObject.createElement("description");
                            discouragedForProfile.appendChild(descriptionElement);
                        }
                        descriptionElement.setAttribute("conref", text);

                        discouragedForProfile.removeChild(childrenOfDiscouragedForProfiles.item(0));
                    }

                    profilesElement.appendChild(discouragedForProfile);
                }
            }   
        }
    }

    private void processClassInheritance()
    {
        Collection<AsClass> classes = classTable.values();
        Iterator<AsClass> classIterator = classes.iterator();
        // first generate the list of direct decendants for each class (and set
        // inner class relationship)
        while (classIterator.hasNext())
        {
            AsClass asClass = classIterator.next();

            if (asClass.getNode() == null || asClass.getName().equals(GLOBAL) || (asClass.getName().startsWith("$$") && asClass.getName().endsWith("$$")) || asClass.getName().equals("Object") || (asClass.isInterfaceFlag() && asClass.getInterfaceStr() == null))
            {
                continue;
            }

            Element defNode = null;

            Element apiClassifierDetailElement = asDocUtil.getElementByTagName(asClass.getNode(), "apiClassifierDetail");
            if (apiClassifierDetailElement != null)
            {
                NodeList apiClassifierDefList = apiClassifierDetailElement.getElementsByTagName("apiClassifierDef");
                if (apiClassifierDefList != null && apiClassifierDefList.getLength() != 0)
                {
                    defNode = (Element)apiClassifierDefList.item(0);
                }
            }

            if (asClass.getInterfaceStr() != null && !asClass.getInterfaceStr().equals("") && !asClass.getInterfaceStr().equals("Object"))
            {
                String[] interfaces = asClass.getInterfaceStr().split(";");

                for (int ix = 0; ix < interfaces.length; ix++)
                {

                    if (interfaces[ix] != null)
                    {
                        Element apiBaseInterface = outputObject.createElement("apiBaseInterface");
                        apiBaseInterface.setTextContent(interfaces[ix]);
                        defNode.appendChild(apiBaseInterface);

                        AsClass interfaceClass = classTable.get(interfaces[ix]);
                        if (interfaceClass != null)
                        {
                            asDocUtil.processAncestorClass(interfaceClass, asClass);
                        }
                    }
                }
            }

            if (asClass.getBaseName() != null)
            {
                Element apiBaseClassifier = outputObject.createElement("apiBaseClassifier");
                apiBaseClassifier.setTextContent(asClass.getBaseName());
                defNode.appendChild(apiBaseClassifier);
            }

            if (!asClass.isInterfaceFlag())
            {
                AsClass baseClass = classTable.get(asClass.getBaseName());

                while (baseClass != null)
                {
                    asDocUtil.processAncestorClass(baseClass, asClass);

                    if (baseClass.getName().equals("Object"))
                    {
                        break;
                    }

                    baseClass = classTable.get(baseClass.getBaseName());
                }
            }

            asDocUtil.processCopyDoc(asClass, classTable);
        }

        // if @copy wasn't processed in the first pass. try one more time for those pending copyDoc updates.
        classes = classTable.values();
        classIterator = classes.iterator();
        while (classIterator.hasNext())
        {
            AsClass asClass = classIterator.next();

            if (asClass.getNode() == null || !asClass.isPendingCopyDoc() || asClass.getName().equals(GLOBAL) || (asClass.getName().startsWith("$$") && asClass.getName().endsWith("$$")) || asClass.getName().equals("Object") || (asClass.isInterfaceFlag() && asClass.getInterfaceStr() == null))
            {
                continue;
            }

            asDocUtil.processCopyDoc(asClass, classTable);
        }
    }

    /**
     * build xml subtrees for all classes, but don't create inner classes just
     * yet. XML property set is by value, so we need to put all the
     * methods/fields into the inner class's xml node before we add that class
     * to the classes xmlList of its containing class.
     */
    private void assembleClassXML()
    {

        Collection<AsClass> classes = classTable.values();
        Iterator<AsClass> classIterator = classes.iterator();
        while (classIterator.hasNext())
        {
            AsClass asClass = classIterator.next();
            if (verbose)
            {
                System.out.println("assembling " + asClass.getFullName());
            }

            if (asClass.getNode() == null)
            {
                continue;
            }

            // assign unique ids if we have more then one constructor
            if (asClass.getConstructorCount() > 1)
            {
                NodeList apiConstructorList = asClass.getConstructors().getElementsByTagName("apiConstructor");

                if (apiConstructorList != null && apiConstructorList.getLength() != 0)
                {
                    for (int ix = 0; ix < apiConstructorList.getLength(); ix++)
                    {
                        Element apiConstructor = (Element)apiConstructorList.item(ix);
                        apiConstructor.setAttribute("id", apiConstructor.getAttribute("id") + "_" + ix);

                    }
                }
            }

            if (asClass.getConstructorCount() > 0)
            {
                NodeList apiConstructorList = asClass.getConstructors().getElementsByTagName("apiConstructor");

                if (apiConstructorList != null && apiConstructorList.getLength() != 0)
                {
                    for (int ix = 0; ix < apiConstructorList.getLength(); ix++)
                    {
                        Element apiConstructor = (Element)apiConstructorList.item(ix);
                        asClass.getNode().appendChild(apiConstructor.cloneNode(true));
                    }
                }

            }

            // if the class has methods then attach them to the class node
            if (asClass.getMethodCount() > 0)
            {
                NodeList apiOperationList = asClass.getMethods().getElementsByTagName("apiOperation");

                if (apiOperationList != null && apiOperationList.getLength() != 0)
                {
                    for (int ix = 0; ix < apiOperationList.getLength(); ix++)
                    {
                        Element apiOperation = (Element)apiOperationList.item(ix);
                        asClass.getNode().appendChild(apiOperation.cloneNode(true));
                    }
                }
            }

            // if the class has fields then attach them to the class node
            if (asClass.getFieldCount() > 0)
            {

                NodeList apiValueList = asClass.getFields().getElementsByTagName("apiValue");

                if (apiValueList != null && apiValueList.getLength() != 0)
                {

                    // special post-process necessary to denote read-only or
                    // write-only properties
                    // This has to happen after all methods have been processed.
                    // Only then can you be
                    // sure that you found a getter but not a setter or visa
                    // versa
                    for (int ix = 0; ix < apiValueList.getLength(); ix++)
                    {

                        Element apiValue = (Element)apiValueList.item(ix);
                        Element apiName = asDocUtil.getElementByTagName(apiValue, "apiName");

                        Integer val = asClass.getFieldGetSet().get(apiName.getTextContent());
                        if (val == null)
                        {
                            asClass.getNode().appendChild(apiValue.cloneNode(true));
                            // probably a normal field.
                            continue;
                        }

                        // we need to get to the apiValueAccess Node. if not
                        // present then create it.. it should go to
                        // apiValue.apiValueDetail.apiValueDef
                        // if apiValueDetail or apiValueDef are not present then
                        // create them and add apiValuseAccess.
                        Element apiValueDetail = null;
                        Element apiValueDef = null;
                        Element apiValueAccess = null;

                        apiValueDetail = asDocUtil.getElementByTagName(apiValue, "apiValueDetail");
                        if (apiValueDetail != null)
                        {
                            apiValueDef = asDocUtil.getElementByTagName(apiValueDetail, "apiValueDef");
                            if (apiValueDef != null)
                            {
                                apiValueAccess = asDocUtil.getElementByTagName(apiValueDef, "apiValueAccess");
                                if (apiValueAccess == null)
                                {
                                    apiValueAccess = outputObject.createElement("apiValueAccess");
                                    apiValueDef.appendChild(apiValueAccess);
                                }
                            }
                            else
                            {
                                apiValueAccess = outputObject.createElement("apiValueAccess");
                                apiValueDef = outputObject.createElement("apiValueDef");

                                apiValueDef.appendChild(apiValueAccess);
                                apiValueDetail.appendChild(apiValueDef);
                            }
                        }
                        else
                        {
                            apiValueAccess = outputObject.createElement("apiValueAccess");
                            apiValueDef = outputObject.createElement("apiValueDef");
                            apiValueDetail = outputObject.createElement("apiValueDetail");

                            apiValueDef.appendChild(apiValueAccess);
                            apiValueDetail.appendChild(apiValueDef);
                            apiValue.appendChild(apiValueDetail);
                        }

                        if (val == 1)
                        {
                            apiValueAccess.setAttribute("value", "read");
                        }
                        else if (val == 2)
                        {
                            apiValueAccess.setAttribute("value", "write");
                        }
                        else if (val == 3)
                        {
                            apiValueAccess.setAttribute("value", "readwrite");
                        }
                        asClass.getNode().appendChild(apiValue.cloneNode(true));
                    }
                }
            }
        }
    }

    /**
     * put inner classes within their containing class create package xml nodes
     * put classes, methods, fields into their containing package
     */
    private void assembleClassPackageHierarchy()
    {
        Collection<AsClass> classes = classTable.values();
        Iterator<AsClass> classIterator = classes.iterator();
        // first put inner classes inside their containing classes
        while (classIterator.hasNext())
        {
            AsClass asClass = classIterator.next();

            if (asClass != null)
            {
                int innerClassSize = asClass.getInnerClasses().size();
                for (int ix = 0; ix < innerClassSize; ix++)
                {
                    AsClass innerClass = asClass.getInnerClasses().get(ix);
                    Element apiName = outputObject.createElement("apiName");
                    apiName.setTextContent(asClass.getName() + "." + innerClass.getName());
                    innerClass.getNode().appendChild(apiName);

                    Element apiClassifier = asDocUtil.getElementByTagName(asClass.getNode(), "apiClassifier");
                    if (apiClassifier != null)
                    {
                        apiClassifier.appendChild(innerClass.getNode());
                    }
                }
            }
        }

        // now build packages
        HashMap<String, AsClass> packageContents = packageContentsTable.get(GLOBAL);
        classes = packageContents.values();
        classIterator = classes.iterator();
        while (classIterator.hasNext())
        {
            AsClass asClass = classIterator.next();
            asClass.getNode().setAttribute("id", "globalClassifier:" + asClass.getNode().getAttribute("id"));
        }

        Element packages = outputObject.createElement("packages");

        Set<String> keySet = packageContentsTable.keySet();
        Iterator<String> keyIterator = keySet.iterator();
        while (keyIterator.hasNext())
        {
            String key = keyIterator.next();

            Element packageElement = packageTable.get(key); // use asDoc comment for package, if available.

            if (packageElement == null)
            {
                String packageName = key.replaceAll("\\$", "_");
                packageElement = outputObject.createElement("apiPackage");
                packageElement.setAttribute("id", packageName);
                Element apiName = outputObject.createElement("apiName");
                apiName.setTextContent(packageName);
                Element apiDetail = outputObject.createElement("apiDetail");
                packageElement.appendChild(apiName);
                packageElement.appendChild(apiDetail);
            }

            NodeList privateChilds = packageElement.getElementsByTagName("private");
            if ((privateChilds != null && privateChilds.getLength() != 0) || asDocUtil.hidePackage(key, hiddenPackages))
            {
                continue;
            }

            if (!key.equals(""))
            {
                packageContents = packageContentsTable.get(key);

                classes = packageContents.values();
                classIterator = classes.iterator();
                while (classIterator.hasNext())
                {
                    AsClass asClass = classIterator.next();
                    if (verbose)
                    {
                        System.out.println("post-processing class " + asClass.getName() + " in package " + key);
                    }

                    // if its the fake class created to hold top level methods
                    // and fields of a package
                    if (asClass.getName().charAt(0) == '$' && asClass.getName().charAt(1) == '$')
                    { // add the fake class's list of methods/fields to the
                        // package
                        NodeList childrenOfNode = asClass.getNode().getElementsByTagName("apiOperation");

                        if (childrenOfNode != null && childrenOfNode.getLength() != 0)
                        {
                            for (int ix = 0; ix < childrenOfNode.getLength(); ix++)
                            {
                                Element apiOperation = (Element)childrenOfNode.item(ix);
                                apiOperation.setAttribute("id", "globalOperation:" + apiOperation.getAttribute("id"));
                                packageElement.appendChild(apiOperation.cloneNode(true));
                            }
                        }

                        childrenOfNode = asClass.getNode().getElementsByTagName("apiValue");

                        if (childrenOfNode != null && childrenOfNode.getLength() != 0)
                        {
                            for (int ix = 0; ix < childrenOfNode.getLength(); ix++)
                            {
                                Element apiValue = (Element)childrenOfNode.item(ix);
                                apiValue.setAttribute("id", "globalValue:" + apiValue.getAttribute("id"));
                                packageElement.appendChild(apiValue.cloneNode(true));
                            }
                        }
                    }
                    else if (!asClass.isInnerClass())
                    {
                        Element apiAccess = asDocUtil.getElementByTagName(asClass.getNode(), "apiAccess");
                        if (apiAccess != null)
                        {
                            if (!apiAccess.getAttribute("value").equals("private") || includePrivate)
                            {
                                packageElement.appendChild(asClass.getNode());
                            }
                        }
                    }
                }
            }

            NodeList apiClassifierList = packageElement.getElementsByTagName("apiClassifier");
            NodeList apiValueList = packageElement.getElementsByTagName("apiValue");
            NodeList apiOperationList = packageElement.getElementsByTagName("apiOperation");

            if (apiClassifierList != null && apiClassifierList.getLength() != 0)
            {
                packages.appendChild(packageElement);
            }
            else if (apiValueList != null && apiValueList.getLength() != 0)
            {
                packages.appendChild(packageElement);
            }
            else if (apiOperationList != null && apiOperationList.getLength() != 0)
            {
                packages.appendChild(packageElement);
            }
        }

        root.appendChild(packages);
    }
}
