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

import java.io.StringReader;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.Stack;
import java.util.TreeSet;
import java.util.Map.Entry;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.w3c.dom.CDATASection;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * This is a utility class that is used by TopLevelClassesGenerator. This
 * contains utility functions to convert description to short description, to
 * decompose class names, validation functions. It also performs conversion of
 * various html content to DITA format.
 * 
 * @author gauravj
 */
public class AsDocUtil
{
    private boolean verbose = false;

	private boolean errors = false;
	
	/** 
	 * setter method for error flag
	 * @param errors
	 */
	public void setErrors(boolean errors) {
		this.errors = errors;
	}
	
    private String validationErrors = "";

    /**
     * setter method for validation errors
     * @param validationErrors
     */
    public void setValidationErrors(String validationErrors) {
		this.validationErrors = validationErrors;
	}

    /** 
     * Constructor
     * @param verbose
     */
    AsDocUtil(boolean verbose)
    {
        this.verbose = verbose;
    }

    /** 
     * Helper method to break down a string into various qualified parts
     * @param name
     * @param fullName
     */
    void decomposeFullName(String name, QualifiedNameInfo fullName)
    {
        decomposeFullName(name, fullName, "public");
    }

    /**
     * Helper method to break down a class name string into various qualified parts
     * @param fullClassName
     * @return
     */
    QualifiedNameInfo decomposeFullClassName(String fullClassName)
    {
        int indexColon = fullClassName.indexOf(":");
        int indexDollar = fullClassName.indexOf("$");
        int indexSlash = fullClassName.indexOf("/");

        QualifiedNameInfo result = new QualifiedNameInfo();
        if (indexColon == -1 && indexDollar == -1 && indexSlash == -1)
        {
            result.getClassNames().add(fullClassName);
            result.getClassNameSpaces().add("public");
            result.setFullClassName(fullClassName);
            return result;
        }
        else
        {
            int restIdx = 0;
            if (indexDollar != -1)
            {
                restIdx = indexDollar;
            }
            else if (indexColon != -1)
            {
                restIdx = indexColon;
            }
            else if (indexSlash != -1)
            {
                restIdx = indexSlash;
            }

            if (indexColon < restIdx)
            {
                restIdx = indexColon;
            }

            if (indexSlash < restIdx)
            {
                restIdx = indexSlash;
            }

            String restStr = fullClassName.substring(restIdx + 1);

            if (indexDollar != -1)
            {
                int ci = restStr.indexOf(":");
                if (ci != -1)
                {
                	if(indexColon != -1 && indexColon < indexDollar)
                	{
                		result.setPackageName(fullClassName.substring(0, indexColon));
                	}
                	else 
                	{
                		result.setPackageName(fullClassName.substring(0, indexDollar));
                	}
                    
                	indexSlash = restStr.indexOf("/");
                	
                	if(indexSlash != -1 )
                	{
                        if (ci < indexSlash)
                        {
                            result.setPackageName(restStr.substring(0, ci));
                            decomposeFullName(restStr, result);
                        }
                        else if (indexSlash < ci)
                        {
                            result.getClassNames().add(restStr.substring(0, indexSlash));
                            result.getClassNameSpaces().add("public");

                            decomposeFullName(restStr, result);
                        }                		
                	}
                	else 
                	{
                		String nextNameSpace = restStr.substring(0, ci).replaceAll("\\d+\\$", ""); // .as247$ // (247$)
                		decomposeFullName(restStr.substring(ci + 1, restStr.length()), result, nextNameSpace);
                	}
                }
                else 
                {
                    // if it gets here its not an error, if a getter starting with $ is public the colon will be missing.
                    // example mx.core:UIComponent/$transform/get
                    if(indexColon != -1)
                    {
                        result.setPackageName(fullClassName.substring(0, indexColon));
                    }
                    
                    decomposeFullName(restStr, result, "");
                }
            }
            else
            {
                if (indexColon != -1 && indexSlash != -1)
                {
                    if (indexColon < indexSlash)
                    {
                        result.setPackageName(fullClassName.substring(0, indexColon));

                        decomposeFullName(restStr, result, "public");
                    }
                    else if (indexSlash < indexColon)
                    {
                        result.getClassNames().add(fullClassName.substring(0, indexSlash));
                        result.getClassNameSpaces().add("public");

                        decomposeFullName(restStr, result);
                    }
                }
                else
                {
                    if (indexColon != -1)
                    {
                        result.setPackageName(fullClassName.substring(0, indexColon));
                        decomposeFullName(restStr, result, "public");
                    }

                    if (indexSlash != -1)
                    {
                        result.getClassNames().add(fullClassName.substring(0, indexSlash));
                        result.getClassNameSpaces().add("public");

                        decomposeFullName(restStr, result);
                    }
                }
            }
        }

        result.setFullClassName(fullClassName);
        return result;
    }
    
    /**
     * Helper method to break down a string into various qualified parts
     * @param name
     * @param fullName
     * @param namespace
     */
    void decomposeFullName(String name, QualifiedNameInfo fullName,
            String namespace)
    {
        if (name == null || name.equals(""))
        {
            return;
        }

        int classIndex = fullName.getClassNames().size();

        int indexColon = name.indexOf(":");
        int indexSlash = name.indexOf("/");

        if (indexColon == -1 && indexSlash == -1)
        {
            fullName.getClassNames().add(name);
            fullName.getClassNameSpaces().add(namespace);
        }
        else
        {
            if (indexColon != -1 && indexSlash != -1)
            {
                if (indexColon < indexSlash)
                {
                    fullName.getClassNameSpaces().add(name.substring(0, indexColon));
                    if (!namespace.equals("public"))
                    {
                        System.err.println("ERROR: in DecomposeName2, namespace: " + namespace + " was passed in, but namespace: " + fullName.getClassNameSpaces().get(classIndex) + " was specified");
                    }

                    int iNext = name.indexOf("/");
                    boolean proceed = true;
                    if (iNext == -1)
                    {
                        iNext = name.length();
                        proceed = false;
                    }
                    fullName.getClassNames().add(name.substring(indexColon + 1, iNext));

                    if (proceed)
                    {
                        decomposeFullName(name.substring(iNext + 1), fullName);
                    }
                }
                else if (indexSlash < indexColon)
                {
                    fullName.getClassNames().add(name.substring(0, indexSlash));
                    fullName.getClassNameSpaces().add(namespace);

                    decomposeFullName(name.substring(indexSlash + 1), fullName);
                }

            }
            else
            {
                if (indexColon != -1)
                {
                    fullName.getClassNameSpaces().add(name.substring(0, indexColon));
                    if (!namespace.equals("public"))
                    {
                        System.err.println("ERROR: in DecomposeName2, namespace: " + namespace + " was passed in, but namespace: " + fullName.getClassNameSpaces().get(classIndex) + " was specified");
                    }

                    int iNext = name.indexOf("/");
                    boolean proceed = true;
                    if (iNext == -1)
                    {
                        iNext = name.length();
                        proceed = false;
                    }
                    fullName.getClassNames().add(name.substring(indexColon + 1, iNext));

                    if (proceed)
                    {
                        decomposeFullName(name.substring(iNext + 1), fullName);
                    }
                }
                else if (indexSlash != -1)
                {
                    fullName.getClassNames().add(name.substring(0, indexSlash));
                    fullName.getClassNameSpaces().add(namespace);

                    decomposeFullName(name.substring(indexSlash + 1), fullName);
                }
            }

        }
    }

    /**
     * create shortDescription string from long version by looking for the first
     * period followed by whitespace. That first sentence is the shortDesc
     */
    String descToShortDesc(String fullDesc)
    {
        String[] descArr = fullDesc.split("\\.\\s", 2);
        return descArr[0].replaceAll("<.*?>", "") + (descArr.length == 1 ? "" : "."); // remove any tags inside
        // shortdesc element
    }

    /**
     * helper method to validate the text in the xml elements. When validation fails it also sets the 
     * error flag to true and adds an error message to the validationErrors field. It also identifies the 
     * owner name in the error message.  
     */
    String validateText(String inputText, String elementName, String ownerName)
    {
        String output = inputText.replaceAll("</br>", "");
        output = output.replaceAll("<br\\s*/?>", "");

        TransformerFactory transfac = TransformerFactory.newInstance();
        Transformer trans = null;

        try
        {
            String test = "<test>" + output + "</test>";
            trans = transfac.newTransformer();
            // create xml from string
            StringReader stringReader = new StringReader(test);
            StreamSource source = new StreamSource(stringReader);
            DOMResult result = new DOMResult();
            trans.transform(source, result);
        }
        catch (Exception ex)
        {
            String msg = "Text for " + elementName + " in " + ownerName + " is not valid.\n";
            if(ex.getMessage().indexOf("matching end-tag \"</test>\"") == -1 )
            {
                msg += ex.getMessage();
            } 
            else
            {
                msg += "No matching start tag.";
            }

            validationErrors += msg + "\n\n";

            if (verbose)
            {
                System.out.println(msg);
                System.out.println("offending text --------------------------------------");
                System.out.println(inputText);
                System.out.println("end offending text --------------------------------------");
            }

            output = "";
            errors = true;
        }

        return output;
    }

    /**
     * Renames an element and preserves its child elements
     * 
     * @param source
     * @param targetDocument
     * @param newName
     * @return
     */
    Element renameElementAndCloneChild(Element source, Document targetDocument,
            String newName)
    {
        Element newElement = targetDocument.createElement(newName);

        NamedNodeMap namedNodeMap = source.getAttributes();
        for (int iAttr = 0; iAttr < namedNodeMap.getLength(); iAttr++)
        {
            Node node = namedNodeMap.item(iAttr);
            newElement.setAttribute(node.getNodeName(), node.getNodeValue());
        }

        NodeList listofChilds = source.getChildNodes();
        for (int iChild = 0; iChild < listofChilds.getLength(); iChild++)
        {
            Node node = listofChilds.item(iChild);
            newElement.appendChild(node.cloneNode(true));
        }

        return newElement;
    }

    /**
     * Renames an element and imports its child nodes.
     * @param source
     * @param targetDocument
     * @param newName
     * @return
     */
    Element renameElementAndImportChild(Element source,
            Document targetDocument, String newName)
    {
        Element newElement = targetDocument.createElement(newName);

        NamedNodeMap namedNodeMap = source.getAttributes();
        for (int iAttr = 0; iAttr < namedNodeMap.getLength(); iAttr++)
        {
            Node node = namedNodeMap.item(iAttr);
            newElement.setAttribute(node.getNodeName(), node.getNodeValue());
        }

        NodeList listofChilds = source.getChildNodes();
        for (int iChild = 0; iChild < listofChilds.getLength(); iChild++)
        {
            Node node = listofChilds.item(iChild);
            newElement.appendChild(targetDocument.importNode(node, true));
        }

        return newElement;
    }

    /**
     * Converts simple description to DITA format.
     * 
     * @param input
     * @param oldNewNamesMap
     */
    void convertDescToDITA(Element input, HashMap<String, String> oldNewNamesMap)
    {
        convertDescToDITA(input, oldNewNamesMap, false);
    }

    /**
     * Converts simple description to DITA format.
     * 
     * @param input
     * @param oldNewNamesMap
     * @param isTableElement
     */
    void convertDescToDITA(Element input,
            HashMap<String, String> oldNewNamesMap, Boolean isTableElement)
    {
        NodeList descendants = input.getChildNodes();
        if (descendants != null && descendants.getLength() != 0)
        {
            CDATASection cdataSection = (CDATASection)descendants.item(0);
            String inputString = cdataSection.getData();
            if (inputString != null && !inputString.equals(""))
            {
                Document targetDocument = null;
                TransformerFactory transfac = TransformerFactory.newInstance();
                Transformer trans = null;

                try
                {
                    inputString = "<cdatastring>" + inputString + "</cdatastring>";
                    trans = transfac.newTransformer();
                    // create xml from string
                    StringReader stringReader = new StringReader(inputString);
                    StreamSource source = new StreamSource(stringReader);
                    DOMResult result = new DOMResult();
                    trans.transform(source, result);
                    targetDocument = (Document)result.getNode();
                }
                catch (Exception ex)
                {
                    ex.printStackTrace();
                }

                if (targetDocument != null)
                {
                    NodeList cDataDescendants = targetDocument.getDocumentElement().getChildNodes();

                    for (int iy = 0; iy < cDataDescendants.getLength(); iy++)
                    {
                        Node childNode = cDataDescendants.item(iy);
                        if (childNode.getNodeType() != Node.ELEMENT_NODE)
                        {
                            continue;
                        }

                        Element child = (Element)childNode;
                        convert(child, targetDocument.getDocumentElement(), oldNewNamesMap, targetDocument, isTableElement);
                    }
                    
                    cDataDescendants = targetDocument.getDocumentElement().getChildNodes();

                    for (int iy = 0; iy < cDataDescendants.getLength(); iy++)
                    {
                        Node childNode = cDataDescendants.item(iy);
                        if (childNode.getNodeType() != Node.ELEMENT_NODE)
                        {
                            continue;
                        }

                        Element child = (Element)childNode;
                        convertChildren(child, oldNewNamesMap, targetDocument, isTableElement);
                    }                    

                    try
                    {
                        StringWriter sw = new StringWriter();
                        StreamResult result = new StreamResult(sw);
                        DOMSource source = new DOMSource(targetDocument);
                        trans.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
                        trans.transform(source, result);
                        String xmlString = sw.toString();
                        xmlString = xmlString.replaceAll("<cdatastring>", "");
                        xmlString = xmlString.replaceAll("</cdatastring>", "");

                        cdataSection.setData(xmlString);
                    }
                    catch (Exception ex)
                    {
                        ex.printStackTrace();
                    }
                }
            }
        }
    }

    private void convertChildren(Element child,
            HashMap<String, String> oldNewNamesMap, Document targetDocument,
            Boolean isTableElement)
    {
        NodeList cDataDescendants = child.getChildNodes();
        for (int iy = 0; iy < cDataDescendants.getLength(); iy++)
        {

            Node childNode = cDataDescendants.item(iy);
            if (childNode.getNodeType() != Node.ELEMENT_NODE)
            {
                continue;
            }
            Element subChild = (Element)childNode;
            convert(subChild, child, oldNewNamesMap, targetDocument, isTableElement);
        }
        
        cDataDescendants = child.getChildNodes();
        for (int iy = 0; iy < cDataDescendants.getLength(); iy++)
        {

            Node childNode = cDataDescendants.item(iy);
            if (childNode.getNodeType() != Node.ELEMENT_NODE)
            {
                continue;
            }
            Element subChild = (Element)childNode;
            convertChildren(subChild, oldNewNamesMap, targetDocument, isTableElement);
        }
    }

    private void convert(Element child, Node parent,
            HashMap<String, String> oldNewNamesMap, Document targetDocument,
            Boolean isTableElement)
    {
        String oldName = child.getNodeName().toLowerCase();
        String newName = oldNewNamesMap.get(oldName);

        // TODO: check where we need toLowerCase when finding attributes..
        if (newName != null)
        {
            Element newElement = renameElementAndCloneChild(child, targetDocument, newName);

            parent.replaceChild(newElement, child);
        }
        else if (oldName.equals("listing"))
        {
            Element newElement = renameElementAndCloneChild(child, targetDocument, "codeblock");

            if (newElement.hasAttribute("version"))
            {
                newElement.setAttribute("rev", newElement.getAttribute("version"));
                newElement.removeAttribute("version");
            }

            parent.replaceChild(newElement, child);
        }
        else if (oldName.equals("span"))
        {
            Element newElement = renameElementAndCloneChild(child, targetDocument, "ph");

            if (newElement.hasAttribute("class"))
            {
                newElement.setAttribute("outputclass", newElement.getAttribute("class"));
                newElement.removeAttribute("class");
            }

            parent.replaceChild(newElement, child);
        }
        else if (oldName.equals("code"))
        {
            Element newElement = renameElementAndCloneChild(child, targetDocument, "codeph");

            parent.replaceChild(newElement, child);
        }
        else if (oldName.equals("table") && !isTableElement)
        {
            Element newElement = convertTable(child, targetDocument, oldNewNamesMap);
            parent.replaceChild(newElement, child);
        }
        else if (oldName.equals("a"))
        {
            Element newElement = renameElementAndCloneChild(child, targetDocument, "xref");

            if (newElement.hasAttribute("target"))
            {
                String targetVal = newElement.getAttribute("target");
                if (targetVal.toLowerCase().equals("mm_external") || targetVal.toLowerCase().equals("newwindow") || targetVal.toLowerCase().equals("_blank"))
                {
                    newElement.setAttribute("scope", "external");
                }
                else
                {
                    newElement.setAttribute("scope", targetVal);
                }

                newElement.removeAttribute("target");
            }

            parent.replaceChild(newElement, child);
        }
        else if (oldName.equals("img"))
        {

            Element newElement = renameElementAndCloneChild(child, targetDocument, "adobeimage");

            if (newElement.hasAttribute("src"))
            {
                newElement.setAttribute("href", newElement.getAttribute("src"));
                newElement.removeAttribute("src");
            }

            parent.replaceChild(newElement, child);
        }
        else if (oldName.equals("flexonly"))
        {
            // TODO: recheck this..
            NodeList nodes = child.getChildNodes();
            if (nodes != null && nodes.getLength() == 1)
            {
                Element parentNode = (Element)child.getParentNode();
                parentNode.setAttribute("product", "flex");
            }
        }
        else if (oldName.equals("ol"))
        {
            if (child.hasAttribute("type"))
            {
                child.setAttribute("outputclass", child.getAttribute("type"));
                child.removeAttribute("type");
            }
        }
    }

    /** 
     * Converts an HTML table into DITA format.
     * 
     * @param input
     * @param targetDocument
     * @param oldNewNamesMap
     * @return
     */
    Element convertTable(Element input, Document targetDocument,
            HashMap<String, String> oldNewNamesMap)
    {
        NodeList childNodes = input.getElementsByTagName("colgroup");
        for (int iChild = 0; iChild < childNodes.getLength(); iChild++)
        {
            Node node = childNodes.item(iChild);
            input.removeChild(node);
        }

        Element theadNode = null;

        childNodes = input.getChildNodes();
        for (int iChild = 0; iChild < childNodes.getLength(); iChild++)
        {
            if (childNodes.item(iChild).getNodeType() != Node.ELEMENT_NODE)
            {
                continue;
            }

            Element node = (Element)childNodes.item(iChild);
            NodeList thList = node.getElementsByTagName("th");
            if (thList != null && thList.getLength() != 0)
            {
                theadNode = targetDocument.createElement("thead");
                Element row = targetDocument.createElement("row");
                NodeList subChildNodes = node.getChildNodes();
                for (int iSubChild = 0; iSubChild < subChildNodes.getLength(); iSubChild++)
                {
                    if (subChildNodes.item(iSubChild).getNodeType() != Node.ELEMENT_NODE)
                    {
                        continue;
                    }

                    Element subChild = (Element)subChildNodes.item(iSubChild);
                    row.appendChild(subChild.cloneNode(true));
                }

                theadNode.appendChild(row);
                input.removeChild(node);
                break;
            }
        }

        Element tGroup = targetDocument.createElement("tgroup");

        if (theadNode != null)
        {
            tGroup.appendChild(theadNode);
        }

        Element tBody = targetDocument.createElement("tbody");
        tGroup.appendChild(tBody);

        childNodes = input.getChildNodes();
        for (int iChild = 0; iChild < childNodes.getLength(); iChild++)
        {
            if (childNodes.item(iChild).getNodeType() != Node.ELEMENT_NODE)
            {
                continue;
            }

            tBody.appendChild(childNodes.item(iChild));
        }

        childNodes = input.getChildNodes();
        for (int iChild = 0; iChild < childNodes.getLength(); iChild++)
        {
            if (childNodes.item(iChild).getNodeType() != Node.ELEMENT_NODE)
            {
                continue;
            }

            Element node = (Element)childNodes.item(iChild);
            input.removeChild(node);
        }

        input = renameElementAndCloneChild(input, targetDocument, "adobetable");

        input.appendChild(tGroup);

        // remove unwanted attributes
        input.removeAttribute("width");
        input.removeAttribute("colgroup");
        input.removeAttribute("cellpadding");
        input.removeAttribute("cellspacing");
        input.removeAttribute("border");
        input.removeAttribute("style");

        convertTableChilds(targetDocument, input, input);

        int colCount = 0;
        int currentRowLength = 0;

        childNodes = input.getElementsByTagName("row");
        if (childNodes != null)
        {
            for (int iChild = 0; iChild < childNodes.getLength(); iChild++)
            {
                currentRowLength = 0;
                Element rowNode = (Element)childNodes.item(iChild);

                NodeList rowElements = rowNode.getChildNodes();
                // don't simply use getLength() as it also contains count for
                // elements which can be of type TEXT or CDATA
                for (int ix = 0; ix < rowElements.getLength(); ix++)
                {
                    if (rowElements.item(ix).getNodeType() != Node.ELEMENT_NODE)
                    {
                        continue;
                    }
                    currentRowLength++;
                }

                if (colCount < currentRowLength)
                {
                    colCount = currentRowLength;
                }
            }
        }

        tGroup.setAttribute("cols", String.valueOf(colCount));

        convertChildren(input, oldNewNamesMap, targetDocument, false);
        // convertDescToDITA(input, oldNewNamesMap); // now invoke this method
        // again to convert other elements to DITA
        return input;
    }

    private void convertTableChilds(Document targetDocument, Element target,
            Element root)
    {
        String oldName = target.getNodeName().toLowerCase();
        if (oldName.equals("tr"))
        {
            Element newElement = renameElementAndCloneChild(target, targetDocument, "row");

            Node parent = target.getParentNode();
            parent.replaceChild(newElement, target);

            convertTableChilds(targetDocument, newElement, target);
        }

        if (oldName.equals("th") || oldName.equals("td"))
        {
            Element newElement = renameElementAndCloneChild(target, targetDocument, "entry");
            newElement.removeAttribute("colspan");
            newElement.removeAttribute("rowspan");
            newElement.removeAttribute("width");

            if (newElement.hasAttribute("nowrap"))
            {
                String nowrapVal = newElement.getAttribute("nowrap");
                if (!nowrapVal.equals("false"))
                {
                    newElement.setAttribute("outputclass", "nowrap");
                }
                newElement.removeAttribute("nowrap");
            }

            Node parent = target.getParentNode();
            parent.replaceChild(newElement, target);

            convertTableChilds(targetDocument, newElement, target);
        }

        NodeList children = target.getChildNodes();

        if (children != null && children.getLength() != 0)
        {
            for (int ix = 0; ix < children.getLength(); ix++)
            {
                Node childNode = children.item(ix);
                if (childNode.getNodeType() != Node.ELEMENT_NODE)
                {
                    continue;
                }

                Element child = (Element)childNode;

                convertTableChilds(targetDocument, child, target);
            }
        }
    }

    /** 
     * hides a package from the documentation if its listed in hiddenPackages
     * @param packageName
     * @param hiddenPackages
     * @return
     */
    boolean hidePackage(String packageName, String hiddenPackages)
    {
        if (packageName == null || packageName.equals(""))
            return false;
        else if (hiddenPackages.indexOf(":" + packageName + ":") != -1)
            return (hiddenPackages.indexOf(":" + packageName + ":true:") != -1);
        else
            return false;
    }

    /** 
     * Formats a string by replacing slashes with colons.
     * 
     * @param inputId
     * @return
     */
    String formatId(String inputId)
    {
        return inputId.replaceAll("\\/", ":");
    }

    /**
     * Replaces multiple spaces in a string with a single space.
     * 
     * @param str
     * @return
     */
    String normalizeString(String str)
    {
        return str.replaceAll("^[\\s]+|[\\s]+$", "").replaceAll("\\s+", " ");
    }

    /** 
     * escapes xml symbols symbols to html entities 
     * @param input
     * @return
     */
    String convertToEntity(String input)
    {
        // code blocks can contain the ampersand symbol (&)
        // the java transformation doesn't like it. so convert those to entity        
        String output = input.replaceAll("&", "&amp;");
        output = output.replaceAll("<", "&lt;");
        output = output.replaceAll(">", "&gt;");
        
        return output;
    }

    /**
     * Helper method to drill down to the detail node for an element type
     * @param baseNode
     * @return
     */
    Element getDetailNode(Element baseNode)
    {
    	Element element = getElementByTagName(baseNode, "apiClassifierDetail");
    	if(element != null )
    	{
    		return element;
    	}
    	
    	element = getElementByTagName(baseNode, "apiOperationDetail");
    	if(element != null )
    	{
    		return element;
    	}
    	
    	element = getElementByTagName(baseNode, "apiValueDetail");
    	if(element != null )
    	{
    		return element;
    	}
    	
    	element = getElementByTagName(baseNode, "apiConstructorDetail");
    	if(element != null )
    	{
    		return element;
    	}
    	
    	element = getElementByTagName(baseNode, "adobeApiEventDetail");

    	return element;
    }

    /**
     * Helper method to drill down to the def node for an element type
     * @param baseNode
     * @return
     */
    Element getDefNode(Element baseNode)
    {
        Element element  = getElementByTagName(baseNode, "apiClassifierDetail");
        if (element != null)
        {
            Element subElement = getElementByTagName(element, "apiClassifierDef");
            if (subElement != null)
            {
                return subElement;
            }
        }
        
        element  = getElementByTagName(baseNode, "apiOperationDetail");
        if (element != null)
        {
            Element subElement = getElementByTagName(element, "apiOperationDef");
            if (subElement != null)
            {
                return subElement;
            }
        }

        element  = getElementByTagName(baseNode, "apiValueDetail");
        if (element != null)
        {
            Element subElement = getElementByTagName(element, "apiValueDef");
            if (subElement != null)
            {
                return subElement;
            }
        }

        element  = getElementByTagName(baseNode, "apiConstructorDetail");
        if (element != null)
        {
            Element subElement = getElementByTagName(element, "apiConstructorDef");
            if (subElement != null)
            {
                return subElement;
            }
        }

        element  = getElementByTagName(baseNode, "adobeApiEventDetail");
        if (element != null)
        {
            Element subElement = getElementByTagName(element, "adobeApiEventDef");
            if (subElement != null)
            {
                return subElement;
            }
        }

        return null;
    }

    /**
     * Hides a name space from the documentation if its present on the namespaces string.
     * @param namespace
     * @param namespaces
     * @return
     */
    boolean hideNamespace(String namespace, String namespaces)
    {
        if (namespace == null || namespace.equals(""))
        {
            return false;
        }
        else if (namespaces.indexOf(":" + namespace + ":") != -1)
        {
            return (namespaces.indexOf(":" + namespace + ":true:") != -1);
        }
        else if (namespace.equals("public"))
        {
            return false;
        }
        else if (namespace.equals("private"))
        {
            return true;
        }
        else if (namespace.equals("$internal"))
        {
            return true;
        }
        else if (namespace.equals("internal"))
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    /**
     * This function will be used for processing custom elements for styles and
     * effects
     */
    void processCustoms(Element node, Document outputDocument)
    {
        boolean customDataFlag = false;
        Element asCustoms = outputDocument.createElement("asCustoms");

        ArrayList<String> handledTags = new ArrayList<String>();
        handledTags.add("default");
        handledTags.add("description");
        handledTags.add("copy");
        handledTags.add("see");
        handledTags.add("playerversion");
        handledTags.add("inheritDoc");

        for (int ix = 0; ix < node.getChildNodes().getLength(); ix++)
        {
            Node child = node.getChildNodes().item(ix);

            if (child.getNodeType() == Node.ELEMENT_NODE)
            {
                String nodeName = child.getNodeName();
                if (handledTags.contains(nodeName))
                {
                    continue;
                }
                else
                {
                    customDataFlag = true;
                    Element nodeNameElement = outputDocument.createElement(nodeName);
                    CDATASection cdata = outputDocument.createCDATASection(child.getTextContent());
                    nodeNameElement.appendChild(cdata);
                    asCustoms.appendChild(nodeNameElement);
                    node.removeChild(child);
                }
            }
        }

        if (customDataFlag)
        {
        	Element prolog = getElementByTagName(node, "prolog");
            if (prolog != null)
            {
                prolog.appendChild(asCustoms);
            }
            else
            {
                prolog = outputDocument.createElement("prolog");
                prolog.appendChild(asCustoms);
                node.appendChild(prolog);
            }
        }
    }

    /**
     * This function is used to process the base classes whne processing a class inheritance.
     *  
     * @param ancestorClass
     * @param thisClass
     */
    void processAncestorClass(AsClass ancestorClass, AsClass thisClass )
    {
        if (verbose)
        {
            System.out.println("processAncestorClass - thisClass " + thisClass.getFullName() + " ancestorClass " + ancestorClass.getFullName());
        }
        
        if (ancestorClass.getFields() != null)
        {
            NodeList baseFieldList = ancestorClass.getFields().getElementsByTagName("apiValue");
            if (baseFieldList != null && baseFieldList.getLength() != 0)
            {
                for (int ix = 0; ix < baseFieldList.getLength(); ix++)
                {
                    boolean found = false;

                    Element baseField = (Element)baseFieldList.item(ix);

                    for (int excludedCount = 0; excludedCount < thisClass.getExcludedProperties().size(); excludedCount++)
                    {
                    	Element apiValue = getElementByTagName(baseField, "apiValue");
                        if (apiValue != null )
                        {
                            if (thisClass.getExcludedProperties().get(excludedCount).equals(apiValue.getTextContent()))
                            {
                                found = true;
                                break;
                            }
                        }
                    }

                    Element apiName = getElementByTagName(baseField, "apiName");

                    if (found )
                    {
                        continue;
                    }

                    if (thisClass.getFieldGetSet().get(apiName.getTextContent()) != null && thisClass.getFieldGetSet().get(apiName.getTextContent()) != 0 )
                    {
                        if (thisClass.getPrivateGetSet().get(apiName.getTextContent()) == null  || thisClass.getPrivateGetSet().get(apiName.getTextContent()) == 0)
                        {
                            if (thisClass.getFieldGetSet().get(apiName.getTextContent()) == 1)
                            {
                                if (ancestorClass.getFieldGetSet().get(apiName.getTextContent()) != null && ancestorClass.getFieldGetSet().get(apiName.getTextContent()) > 1)
                                {
                                    thisClass.getFieldGetSet().put(apiName.getTextContent(), thisClass.getFieldGetSet().get(apiName.getTextContent()) + 2);
                                }
                            }
                            else if (thisClass.getFieldGetSet().get(apiName.getTextContent()) == 2)
                            {
                                if (ancestorClass.getFieldGetSet().get(apiName.getTextContent()) != null && ancestorClass.getFieldGetSet().get(apiName.getTextContent()) != 2)
                                {
                                    thisClass.getFieldGetSet().put(apiName.getTextContent(), thisClass.getFieldGetSet().get(apiName.getTextContent()) + 1);
                                }
                            }
                        }
                    }
                }
            }
        }

        if (ancestorClass.getPrivateGetSet() != null)
        {
            Set<Map.Entry<String, Integer>> baseEntrySet = ancestorClass.getPrivateGetSet().entrySet();
            Iterator<Map.Entry<String, Integer>> baseEntryIterator = baseEntrySet.iterator();
            if (baseEntryIterator != null)
            {
                while (baseEntryIterator.hasNext())
                {
                    Map.Entry<String, Integer> baseEntry = baseEntryIterator.next();
                    boolean found = false;

                    for (int excludedCount = 0; excludedCount < thisClass.getExcludedProperties().size(); excludedCount++)
                    {
                        if (thisClass.getExcludedProperties().get(excludedCount).equals(baseEntry.getKey()))
                        {
                            found = true;
                            break;
                        }
                    }

                    if (found)
                    {
                        continue;
                    }

                    Set<Map.Entry<String, Integer>> entrySet = thisClass.getPrivateGetSet().entrySet();
                    Iterator<Map.Entry<String, Integer>> entryIterator = entrySet.iterator();
                    if (entryIterator != null)
                    {
                        while (entryIterator.hasNext())
                        {
                            Map.Entry<String, Integer> entry = entryIterator.next();

                            if (entry.getKey().equals(baseEntry.getKey()))
                            {
                                if (entry.getValue() == 3)
                                {
                                    found = true;
                                    break;
                                }
                                else if (entry.getValue() == 2)
                                {
                                    if (ancestorClass.getPrivateGetSet().get(entry.getKey()) > 1)
                                    {
                                        found = true;
                                        break;
                                    }
                                }
                                else if (entry.getValue() == 1)
                                {
                                    if (ancestorClass.getPrivateGetSet().get(entry.getKey()) != 2)
                                    {
                                        found = true;
                                        break;
                                    }
                                }
                            }
                        }
                    }

                    if (found)
                    {
                        continue;
                    }

                    entrySet = thisClass.getFieldGetSet().entrySet();
                    entryIterator = entrySet.iterator();
                    if (entryIterator != null)
                    {
                        while (entryIterator.hasNext())
                        {
                            Map.Entry<String, Integer> entry = entryIterator.next();

                            if (entry.getKey().equals(baseEntry.getKey()))
                            {
                                if (entry.getValue() == 1)
                                {
                                    if (ancestorClass.getPrivateGetSet().get(entry.getKey()) > 1)
                                    {
                                        thisClass.getFieldGetSet().put(entry.getKey(), thisClass.getFieldGetSet().get(entry.getKey()) + 2);
                                    }
                                }
                                else if (entry.getValue() == 2)
                                {
                                    if (ancestorClass.getPrivateGetSet().get(entry.getKey()) != 2)
                                    {
                                        thisClass.getFieldGetSet().put(entry.getKey(), thisClass.getFieldGetSet().get(entry.getKey()) + 1);
                                    }
                                }

                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * Copy the param and return definitions from the class referenced using the
     * copy element.
     */
    void processCopyDoc(AsClass currentClass,
            HashMap<String, AsClass> classTable)
    {
        if (currentClass.getConstructors() != null)
        {
            NodeList apiConstructorList = currentClass.getConstructors().getElementsByTagName("apiConstructor");

            if (apiConstructorList != null && apiConstructorList.getLength() != 0)
            {
                for (int ix = 0; ix < apiConstructorList.getLength(); ix++)
                {
                    Element apiConstructor = (Element)apiConstructorList.item(ix);

                    Element shortdesc = getElementByTagName(apiConstructor, "shortdesc");
                    if (shortdesc != null)
                    {
                        if (!shortdesc.getAttribute("conref").equals(""))
                        {
                            processCopyNode(apiConstructor, shortdesc.getAttribute("conref"), currentClass, classTable);
                        }
                    }
                }
            }
        }

        if (currentClass.getMethods() != null)
        {
            NodeList apiOperationList = currentClass.getMethods().getElementsByTagName("apiOperation");

            if (apiOperationList != null && apiOperationList.getLength() != 0)
            {
                for (int ix = 0; ix < apiOperationList.getLength(); ix++)
                {
                    Element apiOperation = (Element)apiOperationList.item(ix);

                    Element shortdesc = getElementByTagName(apiOperation, "shortdesc");
                    if (shortdesc != null)
                    {
                        if (!shortdesc.getAttribute("conref").equals(""))
                        {
                            processCopyNode(apiOperation, shortdesc.getAttribute("conref"), currentClass, classTable);
                        }
                    }
                }
            }
        }
    }

    private void processCopyNode(Element toNode, String fromNode, AsClass toClass,
            HashMap<String, AsClass> classTable)
    {
        String fromClassName = normalizeString(fromNode);
        AsClass fromClass = getClass(fromClassName, classTable);

        int poundIdx = fromClassName.indexOf("#");
        if (fromClass == null)
        {
            if (poundIdx != -1)
            {
                fromClass = getClass(fromClassName.substring(0, poundIdx), classTable);
            }

            if (fromClass == null)
            {
                if (poundIdx != -1)
                {
                    fromClass = getClass(toClass.getDecompName().getPackageName() + "." + fromClassName.substring(0, poundIdx), classTable);
                }

                if (fromClass == null)
                {
                    return;
                }
            }
        }

        String anchor = fromClassName.substring(poundIdx + 1);
        int braceIdx = anchor.indexOf("(");
        if (braceIdx != -1)
        { // method or constructor
            anchor = anchor.substring(0, braceIdx);

            if (fromClass.getMethodCount() > 0)
            {
                if (fromClass.getMethods() != null)
                {
                    NodeList apiOperationList = fromClass.getMethods().getElementsByTagName("apiOperation");

                    if (apiOperationList != null && apiOperationList.getLength() != 0)
                    {
                        for (int ix = 0; ix < apiOperationList.getLength(); ix++)
                        {
                            Element apiOperation = (Element)apiOperationList.item(ix);

                            Element apiName = getElementByTagName(apiOperation, "apiName");
                            
                            if (apiName != null)
                            {
                                if (anchor.equals(apiName.getTextContent()))
                                {
                                    toClass.setPendingCopyDoc( inheritDocForMethod(toNode, apiOperation) );
                                }
                            }
                        }
                    }
                }
            }

            if (fromClass.getConstructorCount() > 0)
            {
                if (fromClass.getConstructors() != null)
                {
                    NodeList apiConstructorList = fromClass.getConstructors().getElementsByTagName("apiConstructor");

                    if (apiConstructorList != null && apiConstructorList.getLength() != 0)
                    {
                        for (int ix = 0; ix < apiConstructorList.getLength(); ix++)
                        {
                            Element apiConstructor = (Element)apiConstructorList.item(ix);

                            Element apiName = getElementByTagName(apiConstructor, "apiName");

                            if (apiName != null)
                            {
                                if (anchor.equals(apiName.getTextContent()))
                                {
                                    Element apiConstructorDetail = getElementByTagName(apiConstructor, "apiConstructorDetail");
                                    if (apiConstructorDetail != null)
                                    {
                                    	Element apiConstructorDef = getElementByTagName(apiConstructorDetail, "apiConstructorDef");
                                        if (apiConstructorDef != null)
                                        {
                                            NodeList apiParamList = apiConstructorDef.getElementsByTagName("apiParam");
                                            if (apiParamList != null && apiParamList.getLength() != 0)
                                            {
                                            	Element apiConstructorDetail2 = getElementByTagName(toNode, "apiConstructorDetail");
                                                if (apiConstructorDetail2 != null)
                                                {
                                                	Element apiConstructorDef2 = getElementByTagName(apiConstructorDetail2, "apiConstructorDef");
                                                    if (apiConstructorDef2 != null)
                                                    {
                                                        NodeList apiParamList2 = apiConstructorDef2.getElementsByTagName("apiParam");
                                                        
                                                        if(apiParamList2 != null && apiParamList2.getLength() != 0)
                                                    	{
                                                    		if(apiParamList.getLength() != apiParamList2.getLength())
                                                    		{
                                                        		validationErrors += "Number of parameters do not match between " + fromClassName + " and " + toNode.getAttribute("id")
                                                        		+ apiParamList.getLength() + " vs "+ apiParamList2.getLength() +" \n@copy cannot copy @param description \n\n";
                                                        		errors = true;
                                                    		}
                                                    		else 
                                                    		{
                                                        		StringBuilder fromNodeSignature = new StringBuilder();
                                                        		StringBuilder toNodeSignature = new StringBuilder();
                                                        		
                                                        		for (int iy = 0; iy < apiParamList.getLength(); iy++)
                                                        		{
                                                        			Element fromOperationClassifier = getElementByTagName((Element)apiParamList.item(iy), "apiOperationClassifier");
                                                        			
                                                        			if(fromOperationClassifier != null )
                                                        			{
                                                        				fromNodeSignature.append(fromOperationClassifier.getTextContent().trim());
                                                        			}
                                                        			else 
                                                        			{
                                                            			Element fromApiType = getElementByTagName((Element)apiParamList.item(iy), "apiType");
                                                            			fromNodeSignature.append(fromApiType.getAttribute("value").trim());	
                                                        			}
                                                        			
                                                        			Element toOperationClassifier = getElementByTagName((Element)apiParamList2.item(iy), "apiOperationClassifier");
                                                        			if(toOperationClassifier != null )
                                                        			{
                                                        				toNodeSignature.append(toOperationClassifier.getTextContent().trim());
                                                        			}
                                                        			else 
                                                        			{
                                                        				Element toApiType = getElementByTagName((Element)apiParamList2.item(iy), "apiType");
                                                        				toNodeSignature.append(toApiType.getAttribute("value").trim());
                                                        			}
                                                        			
                                                        			if (iy != apiParamList.getLength() -1 )
                                                        			{
                                                        				fromNodeSignature.append(", ");
                                                        				toNodeSignature.append(", ");
                                                        			}
                                                        		}
                                                        		
                                                        		String fromSignature  = fromNodeSignature.toString();
                                                        		String toSignature  = toNodeSignature.toString();
                                                        		
                                                        		if(!fromSignature.equals(toSignature))
                                                        		{
                                                        			validationErrors += "Incompatible methods: \n" + fromClassName + " ( "+ fromSignature +") does not have a matching signature with "+ toNode.getAttribute("id")
                                                            		+ " ( " + toSignature +" ) \n@copy cannot copy @param description\n\n";
                                                            		errors = true;
                                                        		}
                                                        		else 
                                                        		{
                                                                	for (int iy = 0; iy < apiParamList.getLength(); iy++)
                                        							{
                                                                		Element toDesc = getElementByTagName((Element)apiParamList2.item(iy), "apiDesc");
                                                                		Element fromDesc = getElementByTagName((Element)apiParamList.item(iy), "apiDesc");

                                                                		if(toDesc != null )
                                                                		{
                                                                			apiParamList2.item(iy).removeChild(toDesc);
                                                                		}
                                                                		
                                                                		if(fromDesc != null )
                                                                		{
                                                                			apiParamList2.item(iy).appendChild(fromDesc.cloneNode(true));
                                                                		}
                                        							}                        			
                                                        		}                                                    			
                                                    		}
                                                    	}
                                                    	else 
                                                    	{
                                                    		validationErrors += "Number of parameters do not match between " + fromClassName + " and " + toNode.getAttribute("id")
                                                    		+ apiParamList.getLength() + " vs zero. \n@copy cannot copy @param description\n\n";
                                                    		errors = true;
                                                    	}                                                        
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }

    }

    private boolean inheritDocForMethod(Element toNode, Element fromNode)
    {
        if (verbose)
        {
            System.out.println("Enter inheritDocForMethod toNode " + toNode.getAttribute("id") + " fromNode " + fromNode.getAttribute("id"));
        }
        
        Element shortdesc = getElementByTagName(fromNode, "shortdesc");
        if (shortdesc != null)
        {
            if (!shortdesc.getTextContent().equals(""))
            {
                Element apiOperationDef2 = null;

                Element apiOperationDetail2 = getElementByTagName(toNode, "apiOperationDetail");
                if (apiOperationDetail2 != null)
                {
                	apiOperationDef2 = getElementByTagName(apiOperationDetail2, "apiOperationDef");
                }

                Element apiOperationDetail = getElementByTagName(fromNode, "apiOperationDetail");
                if (apiOperationDetail != null)
                {
                	Element apiOperationDef = getElementByTagName(apiOperationDetail, "apiOperationDef");
                    if (apiOperationDef != null )
                    {
                        NodeList apiParamList = apiOperationDef.getElementsByTagName("apiParam");
                        NodeList apiParamList2 = apiOperationDef2.getElementsByTagName("apiParam");
                        if (apiParamList != null && apiParamList.getLength() != 0)
                        {
                        	if(apiParamList2 != null && apiParamList2.getLength() != 0)
                        	{
                        		if(apiParamList.getLength() != apiParamList2.getLength())
                        		{
                            		validationErrors += "Number of parameters do not match between " + fromNode.getAttribute("id") + " and " + toNode.getAttribute("id")
                            		+ apiParamList.getLength() + " vs "+ apiParamList2.getLength() +" \n@copy cannot copy @param description\n\n";
                            		errors = true;
                        		}
                        		else 
                        		{
                            		StringBuilder fromNodeSignature = new StringBuilder();
                            		StringBuilder toNodeSignature = new StringBuilder();
                            		
                            		for (int ix = 0; ix < apiParamList.getLength(); ix++)
                            		{
                            			Element fromOperationClassifier = getElementByTagName((Element)apiParamList.item(ix), "apiOperationClassifier");
                            			
                            			if(fromOperationClassifier != null )
                            			{
                            				fromNodeSignature.append(fromOperationClassifier.getTextContent().trim());
                            			}
                            			else 
                            			{
                                			Element fromApiType = getElementByTagName((Element)apiParamList.item(ix), "apiType");
                                			fromNodeSignature.append(fromApiType.getAttribute("value").trim());	
                            			}
                            			
                            			Element toOperationClassifier = getElementByTagName((Element)apiParamList2.item(ix), "apiOperationClassifier");
                            			if(toOperationClassifier != null )
                            			{
                            				toNodeSignature.append(toOperationClassifier.getTextContent().trim());
                            			}
                            			else 
                            			{
                            				Element toApiType = getElementByTagName((Element)apiParamList2.item(ix), "apiType");
                            				toNodeSignature.append(toApiType.getAttribute("value").trim());
                            			}
                            			
                            			if (ix != apiParamList.getLength() -1 )
                            			{
                            				fromNodeSignature.append(", ");
                            				toNodeSignature.append(", ");
                            			}
                            		}
                            		
                            		String fromSignature  = fromNodeSignature.toString();
                            		String toSignature  = toNodeSignature.toString();
                            		
                            		if(!fromSignature.equals(toSignature))
                            		{
                            			validationErrors += "Incompatible methods: \n" + fromNode.getAttribute("id") + " ( "+ fromSignature +") does not have a matching signature with "+ toNode.getAttribute("id")
                                		+ " ( " + toSignature +" ) \n@copy cannot copy @param description\n\n";
                                		errors = true;
                            		}
                            		else 
                            		{
                                    	for (int ix = 0; ix < apiParamList.getLength(); ix++)
            							{
                                    		Element toDesc = getElementByTagName((Element)apiParamList2.item(ix), "apiDesc");
                                    		Element fromDesc = getElementByTagName((Element)apiParamList.item(ix), "apiDesc");

                                    		if(toDesc != null )
                                    		{
                                    			apiParamList2.item(ix).removeChild(toDesc);
                                    		}
                                    		
                                    		if(fromDesc != null )
                                    		{
                                    			apiParamList2.item(ix).appendChild(fromDesc.cloneNode(true));
                                    		}
            							}                        			
                            		}                        			
                        		}
                        	}
                        	else 
                        	{
                        		validationErrors += "Number of parameters do not match between " + fromNode.getAttribute("id") + " and " + toNode.getAttribute("id")
                        		+ apiParamList.getLength() + " vs zero. \n@copy cannot copy @param description\n\n";
                        		errors = true;
                        	}
                        }

                        Element fromApiReturn = getElementByTagName(apiOperationDef, "apiReturn");
                        if (fromApiReturn != null)
                        {
                        	Element toApiReturn = getElementByTagName(apiOperationDef2, "apiReturn");
                            if (toApiReturn != null)
                            {
                            	Element toReturnDesc = getElementByTagName((Element)toApiReturn, "apiDesc");
                            	Element fromReturnDesc = getElementByTagName((Element)fromApiReturn, "apiDesc");
                            	
                            	if(toReturnDesc != null )
                            	{
                            		toApiReturn.removeChild(toReturnDesc);
                            	}
                            	
                            	if(fromReturnDesc != null )
                            	{
                            		toApiReturn.appendChild(fromReturnDesc.cloneNode(true));
                            	}
                            }
                        }
                    }
                }
                
                if(!shortdesc.getAttribute("conref").equals(""))
                {
                    return true;
                }
            }
        }

        return false;
    }

    private AsClass getClass(String classStr, HashMap<String, AsClass> classTable)
    {
        int pountLoc = classStr.indexOf("#");
        if (pountLoc == 0)
        {
            return null;
        }

        int lastDot = classStr.lastIndexOf('.');
        if (lastDot != -1)
        {
            classStr = classStr.substring(0, lastDot) + ":" + classStr.substring(lastDot + 1);
        }
        classStr = classStr.replaceAll("event:", "");
        classStr = classStr.replaceAll("style:", "");
        classStr = classStr.replaceAll("effect:", "");

        if (pountLoc != -1)
        {
            String className = classStr.substring(0, pountLoc);

            lastDot = className.lastIndexOf('.');

            String fullClassName = className;

            if (lastDot != -1)
            {
                fullClassName = className.substring(0, lastDot) + ":" + className.substring(lastDot + 1);
            }

            if (!classTable.containsKey(className))
            {
                if (!classTable.containsKey(fullClassName))
                {
                    return null;
                }
                else
                {
                    return classTable.get(fullClassName);
                }
            }
            else
            {
                return classTable.get(className);
            }

        }
        else
        {
            return classTable.get(classStr);
        }
    }

    /**
     * Creates the nested TOC for packages.
     */
    Element createApiMap(TreeSet<String> packageNames, Document outputObject)
    {
        ArrayList<String> alreadyAdded = new ArrayList<String>();
        Element apiMap = outputObject.createElement("apiMap");
        String addedPackage = null;
        String currentPackage = null;
        Iterator<String> packages = packageNames.iterator();
        if (packages == null)
        {
            return apiMap;
        }

        while (packages.hasNext())
        {
            currentPackage = packages.next();
            boolean found = false;

            for (int ix = 0; ix < alreadyAdded.size(); ix++)
            {
                addedPackage = alreadyAdded.get(ix);

                if (currentPackage.indexOf(addedPackage) == 0 && currentPackage.charAt(addedPackage.length()) == '.')
                {
                    Element apiItemRef = getPackageNode(apiMap, addedPackage);
                    Element newApiItemRef = outputObject.createElement("apiItemRef");
                    newApiItemRef.setAttribute("href", currentPackage + ".xml");
                    apiItemRef.appendChild(newApiItemRef);
                    alreadyAdded.add(currentPackage);
                    found = true;
                    break;
                }
            }

            if (!found)
            {
                Element apiItemRef = outputObject.createElement("apiItemRef");
                apiItemRef.setAttribute("href", currentPackage + ".xml");
                apiMap.appendChild(apiItemRef);

                alreadyAdded.add(currentPackage);
            }

        }

        return apiMap;
    }

    private Element getPackageNode(Element apiMap, String packageName)
    {
        String key = packageName + ".xml";
        Stack<Element> apiItemRefArr = new Stack<Element>();

        NodeList apiItemRefList = apiMap.getElementsByTagName("apiItemRef");
        if (apiItemRefList != null && apiItemRefList.getLength() != 0)
        {
            for (int ix = 0; ix < apiItemRefList.getLength(); ix++)
            {
                Element apiItemRef = (Element)apiItemRefList.item(ix);
                if (apiItemRef.getAttribute("href").equals(key))
                {
                    return apiItemRef;
                }
                apiItemRefArr.push(apiItemRef);
            }
        }

        while (apiItemRefArr.size() != 0)
        {
            Element apiItemRef = apiItemRefArr.pop();

            NodeList children = apiItemRef.getElementsByTagName("apiItemRef");
            if (children != null && children.getLength() != 0)
            {
                for (int ix = 0; ix < children.getLength(); ix++)
                {
                    Element child = (Element)children.item(ix);
                    if (child.getAttribute("href").equals(key))
                    {
                        return child;
                    }
                    apiItemRefArr.push(child);
                }
            }
        }
        return null;
    }

    /**
     * method to check if any errors were generated during DITA generation
     * @return
     */
    public boolean isErrors()
    {
        return errors;
    }

    /**
     * method to get the details of the validation errors that were encountered during dita generation.
     * 
     * @return
     */
    public String getValidationErrors()
    {
        return validationErrors;
    }

    /*
    void print(Node test)
    {
        System.out.println("-----------------------------------------------");
        TransformerFactory transfac = TransformerFactory.newInstance();
        Transformer trans = null;
        try
        {
            trans = transfac.newTransformer();
            trans.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
            trans.setOutputProperty(OutputKeys.INDENT, "no");

            // create string from xml tree
            StringWriter sw = null;
            StreamResult result = null;

            DOMSource source = null;

            sw = new StringWriter();
            result = new StreamResult(sw);
            source = new DOMSource(test);
            trans.transform(source, result);
            String xmlString = sw.toString();

            System.out.println(xmlString);
        }
        catch (Exception ex)
        {
            ex.printStackTrace(System.err);
        }
    }*/
    
    /**
     * method to extract child element which matches the tag name. 
     */
    Element getElementByTagName(Element parent, String tagName)
    {
        NodeList nodeList = parent.getElementsByTagName(tagName);
        if (nodeList != null && nodeList.getLength() != 0)
        {
        	return (Element)nodeList.item(0);
        }
        
        return null;
    }
    
    /**
     * Method to extract the child element which matches the tag name and all atttibutes.
     * @param parent
     * @param tagName
     * @param attributes
     * @return
     */
    Element getElementByTagNameAndMatchingAttributes(Element parent, String tagName, Set<Entry<String, String>> attributes)
    {
        NodeList nodeList = parent.getElementsByTagName(tagName);
        
        if (nodeList != null && nodeList.getLength() != 0)
        {
            for(int ix=0; ix < nodeList.getLength(); ix++)
            {
                boolean found = true;
                Element temp = (Element)nodeList.item(ix);
                for(Entry<String, String> entry : attributes)
                {
                    if(!temp.getAttribute(entry.getKey()).equals(entry.getValue()))
                    {
                        found = false;
                        break;
                    }
                }
                
                if (found)
                {
                    return temp;
                }
            } 
        }
        
        return null;
    }

    /**
     * method to extract direct child node that matches the tag name
     * @param parent
     * @param tagName
     * @return
     */
    Element getElementImmediateChildByTagName(Element parent, String tagName)
    {
        NodeList nodeList = parent.getElementsByTagName(tagName);
        if (nodeList != null && nodeList.getLength() != 0)
        {
            for(int iChild =0; iChild < nodeList.getLength(); iChild++)
            {
                if(nodeList.item( iChild ).getParentNode().equals( parent ))
                {
                	return (Element)nodeList.item( iChild );
                }
            }        	
        }
        
        return null;
    }

    

}
