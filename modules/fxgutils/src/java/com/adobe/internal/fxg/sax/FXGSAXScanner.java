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

package com.adobe.internal.fxg.sax;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

import org.xml.sax.Attributes;
import org.xml.sax.Locator;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

import com.adobe.fxg.util.FXGLog;
import com.adobe.fxg.util.FXGLogger;
import com.adobe.fxg.FXGException;
import com.adobe.fxg.FXGConstants;
import com.adobe.fxg.dom.FXGNode;

import com.adobe.internal.fxg.dom.CDATANode;
import com.adobe.internal.fxg.dom.GraphicNode;
import com.adobe.internal.fxg.dom.DefinitionNode;
import com.adobe.internal.fxg.dom.DelegateNode;
import com.adobe.internal.fxg.dom.PreserveWhiteSpaceNode;

import static com.adobe.fxg.FXGConstants.*;

/**
 * This SAX2 based scanner converts an FXG document (an XML based description of
 * a graphical asset) to a simple object graph to serve as an intermediate
 * representation. The document must be in the FXG 1.0 namespace and the root
 * element must be a &lt;Graphic&gt; tag.
 * 
 * @author Peter Farland
 * @author Sujata Das
 */
public class FXGSAXScanner extends DefaultHandler
{
    // Namespaces
    public static final String APACHE_FLEX_NAMESPACE = "http://ns.apache.org/flex/2012";
    
    private static boolean REJECT_MAJOR_VERSION_MISMATCH = false;
    
    // A special case needed to short circuit GroupNode creation inside a
    // Definition as such Groups are not the same as those in the graphics
    // tree.
    private static final String FXG_GROUP_DEFINITION_ELEMENT = "[GroupDefinition]";
        
    private String profile;
    private GraphicNode root;
    private Stack<FXGNode> stack;
    private int skippedElementCount;
    private boolean seenPrivateElement = false;
    private boolean inMaskAfterPrivateElement = false;
    private Locator locator;
    private int startLine = 0;
    private int startColumn = 0;
    private String documentName = null;
    private String unknownElement = null;
    
    // FXG version handler to handle different fxg versions 
    // depending on input file version at runtime. 
    private FXGVersionHandler versionHandler = null;
    
    /**
     * Construct a new FXGSAXScanner
     */
    public FXGSAXScanner(String profile)
    {
        super();
        this.profile = profile;
        if (profile.equals(FXG_PROFILE_MOBILE))
            versionHandler = FXGVersionHandlerRegistry.getDefaultMobileHandler();
        else
            versionHandler = FXGVersionHandlerRegistry.getDefaultHandler();
        if (versionHandler == null)
            throw new FXGException("FXGVersionHandlerNotRegistered", FXGVersionHandlerRegistry.defaultVersion.asDouble());
    }

    /**
     * Provides access to the root FXGNode of the FXG document AFTER parsing.
     * 
     * @return the root FXGNode of the DOM.
     */
    public FXGNode getRootNode()
    {
        return root;
    }

    //--------------------------------------------------------------------------
    //
    // SAX DefaultHandler Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * {@inheritDoc}
     */
    public void setDocumentLocator(Locator locator)
    {
        this.locator = locator;
    }
    
    /**
     * Set document name used for logging.
     * 
     * @return the document name
     */
    public String getDocumentName()
    {
        return documentName;
    }

    /**
     * Get document name used for logging.
     * 
     * @param documentName the document name
     */
    public void setDocumentName(String documentName)
    {
        this.documentName = documentName;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void startDocument() throws SAXException
    {
        stack = new Stack<FXGNode>();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void startElement(String uri, String localName, String name,
            Attributes attributes) throws SAXException
    {
        // First check if we're currently skipping elements
        if (isSkippedElement(uri, localName, true))
            skippedElementCount++;
        if (inSkippedElement())
            return;
        
        // Check if we're currently skipping unknown elements
        if (unknownElement != null)
        	return;

        // Record starting position
        startLine = locator.getLineNumber();
        startColumn = locator.getColumnNumber();

        // Check the current parent
        FXGNode parent = null;
        if (stack.size() > 0)
            parent = stack.peek();

        // Switch to special GroupDefinitionNode for Definition child
        if (isFXGNamespace(uri))
        {
            if (parent instanceof DefinitionNode && FXG_GROUP_ELEMENT.equals(localName))
                localName = FXG_GROUP_DEFINITION_ELEMENT;
        }

        // Create a node for this element
        FXGNode node = createNode(uri, localName);
        
        if (node == null)
        {
            if (root != null)
            {
                if (root.isVersionGreaterThanCompiler())
                {
                    // Warning: Minor version of this FXG file is greater than minor
                    // version supported by this compiler. Log a warning for an
                    // unknown element.
                    FXGLog.getLogger().log(FXGLogger.WARN, "UnknownElement", null, documentName, startLine, startColumn, localName, versionHandler.getVersion().asString());
                    unknownElement = localName;
                    return;
                }else
                {
                    throw new FXGException(startLine, startColumn, "UnknownElementInVersion", root.getFileVersion().asString(), localName);                    
                }
            }
            else
            {
                throw new FXGException(startLine, startColumn, "InvalidFXGRootNode");
            }
        }

        // Provide access to the root document node used for querying version 
        // for non-root elements
        if (root != null)
        {
            node.setDocumentNode(root);
        }
        
        // Set node name if it is a delegate node. This allows proper error 
        // message to be reported.
        if (node instanceof DelegateNode)
        {
            DelegateNode propertyNode = (DelegateNode)node;
            propertyNode.setName(localName);
        }
        
        // Set attributes on the current node
        for (int i = 0; i < attributes.getLength(); i++)
        {
            String attributeURI = attributes.getURI(i);
            if (attributeURI == null || attributeURI == "" || 
            		isFXGNamespace(attributeURI) || 
            		isApacheFlexNamespace(attributeURI))
            {
                String attributeName = attributes.getLocalName(i);
                String attributeValue = attributes.getValue(i);
                node.setAttribute(attributeName, attributeValue);
            }
        }

        // Associate child with parent node (and handle any special
        // relationships)
        if (parent != null)
        {
            if (node instanceof DelegateNode)
            {
                DelegateNode propertyNode = (DelegateNode)node;
                propertyNode.setDelegate(parent);
            }
            else
            {
                parent.addChild(node);
            }
        }
        else if (node instanceof GraphicNode)
        {
            root = (GraphicNode)node;
            // Provide access to the root document node
            node.setDocumentNode(root);
            if (root.getVersion() == null)
            {
                // Exception: <Graphic> doesn't have the required attribute
                // "version".
                throw new FXGException(startLine, startColumn, "MissingVersionAttribute");
            }
            else
            {
                if (!isMajorVersionMatch(root))
                {
                    FXGVersionHandler newVHandler = FXGVersionHandlerRegistry.getVersionHandler(root.getVersion());
                   
                    if (newVHandler == null) 
                    {
                        if  (REJECT_MAJOR_VERSION_MISMATCH)
                        {
                            // Exception:Major version of this FXG file is greater than
                            // major version supported by this compiler. Cannot process
                            // the file.
                            throw new FXGException(startLine, startColumn, "InvalidFXGVersion", root.getVersion().asString());
                        }
                        else
                        {
                            // Warning: Major version of this FXG file is greater than
                            // major version supported by this compiler.
                            FXGLog.getLogger().log(FXGLogger.WARN, "MajorVersionMismatch", null, getDocumentName(), startLine, startColumn);

                            //use the latest version handler
                            versionHandler = FXGVersionHandlerRegistry.getLatestVersionHandler();
                            if (versionHandler == null)
                            {   
                                throw new FXGException("FXGVersionHandlerNotRegistered", root.getVersion().asString());                              
                            }                           
                        }
                    }
                    else
                    {
                        versionHandler = newVHandler;                        
                    }
                }
            }
            // Provide reference to the handler for querying version of the
            // current document processed.
            root.setDocumentName(documentName);
            root.setVersionGreaterThanCompiler(root.getVersion().greaterThan(versionHandler.getVersion()));
            root.setReservedNodes(versionHandler.getElementNodes(uri));
            root.setCompilerVersion(versionHandler.getVersion());
            root.setProfile(profile);
        }
        else
        {
            // Exception:<Graphic> must be the root node of an FXG document.
            throw new FXGException(startLine, startColumn, "InvalidFXGRootNode");
        }

        stack.push(node);

    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void characters(char[] ch, int start, int length)
            throws SAXException
    {
        if (stack != null && stack.size() > 0 && !inSkippedElement() && (unknownElement == null))
        {
            FXGNode node = stack.peek();
            String content = new String(ch, start, length);

            if (!(node instanceof PreserveWhiteSpaceNode))
            {
                content = content.trim();
            }
            
            if (content.length() > 0)
            {
                CDATANode cdata = new CDATANode();
                cdata.content = content;
                assignNodeLocation(cdata);
                node.addChild(cdata);
            }
        }

        // Reset starting position
        startLine = locator.getLineNumber();
        startColumn = locator.getColumnNumber();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void endElement(String uri, String localName, String name)
            throws SAXException
    {
        if (isSkippedElement(uri, localName, false))
        {
            skippedElementCount--;
        }
        else if (unknownElement != null)
        {
            if (unknownElement.equals(localName))
            {
                unknownElement = null;
            }
        }
        else if (!inSkippedElement())
        {
            stack.pop();
        }
        
        // Reset starting position
        startLine = locator.getLineNumber();
        startColumn = locator.getColumnNumber();
    }


    //--------------------------------------------------------------------------
    //
    // Other Methods
    //
    //--------------------------------------------------------------------------

    /**
     * @return the last processed line number
     */
    public int getStartLine()
    {
        return startLine;
    }

    /**
     * @return the last processed column number
     */
    public int getStartColumn()
    {
        return startColumn;
    }

    /**
     * @param uri - the namespace URI to check
     * @return whether the given namespace URI is considered an FXG namespace. 
     */
    protected boolean isFXGNamespace(String uri)
    {
        return FXG_NAMESPACE.equals(uri);
    }

    /**
     * @param uri - the namespace URI to check
     * @return whether the given namespace URI is considered an Apache Flex namespace. 
     */
    protected boolean isApacheFlexNamespace(String uri)
    {
        return APACHE_FLEX_NAMESPACE.equals(uri);
    }

    /**
     * Specifies that a particular element should be skipped while scanning for
     * tokens in an FXG document. All of the element's attributes and child
     * nodes will be skipped too.
     * 
     * @param version - the version of the FXG element
     * @param uri - the namespace URI of the element to skip
     * @param localName - the name of the element to skip
     */
    protected void skipElement(double version, String uri,  String localName)
    {
        if (localName == null)
            return;

        FXGVersionHandler versionHandler = FXGVersionHandlerRegistry.getVersionHandler(version);
        if (versionHandler != null)
        {
            HashSet<String>skippedElements = new HashSet<String>(1);
            skippedElements.add(localName);
            versionHandler.registerSkippedElements(uri, skippedElements);            
        }
        else
        {
            throw new FXGException("FXGVersionHandlerNotRegistered", version);
        }

    }
    

    /**
     * Determines whether an element should be skipped.
     * 
     * @param uri - the namespace URI of the element
     * @param localName - the name of the element
     * @return true if the element has been marked as skipped, otherwise false.
     */
    protected boolean isSkippedElement(String uri, String localName, boolean startElement)
    {
        Set<String> skippedElements = versionHandler.getSkippedElements(uri);
        if (skippedElements != null)
        {
            if (skippedElements.contains(FXGConstants.FXG_PRIVATE_ELEMENT)) 
            {
                validatePrivateElement(localName, startElement); 
            }
            if (skippedElements.contains(localName))
            {    
                return true;
            }
        }

        return false;
    }

    
    /**
     * Attempts to construct an instance of FXGNode for the given element.
     * 
     * @param uri - the namespace URI of the element
     * @param localName - the name of the element
     * @return FXGNode instance if
     */
    protected FXGNode createNode(String uri, String localName)
    {
        FXGNode node = null;

        try
        {
            Map<String, Class<? extends FXGNode>> elementNodes = getElementNodes(uri);
            if (elementNodes != null)
            {
                Class<? extends FXGNode> nodeClass = elementNodes.get(localName);
                if (nodeClass != null)
                {
                    node = (FXGNode)nodeClass.newInstance();
                }
                else if (root != null)
                {
                    node = root.getDefinitionInstance(localName);
                }
            }
        }
        catch (Throwable t)
        {
            throw new FXGException(startLine, startColumn, "ErrorScanningFXG", t);
        }

        if (node != null)
        {
            assignNodeLocation(node);
        }

        return node;
    }

    /**
     * @return if currently in a skipped element.
     */
    private boolean inSkippedElement()
    {
        return skippedElementCount > 0;
    }
    
    /**
     * Registers a custom FXGNode for a particular type of element encountered 
     * while scanning an FXG document.
     * 
     * @param version - the version of the FXG element
     * @param uri - the namespace URI of the FXG element
     * @param localName - the local name of the FXG element
     * @param nodeClass - Class of an FXGNode implementation that will represent
     * an element in the DOM and process its attributes and child nodes during
     * parsing.
     */
    protected void registerElementNode(double version, String uri, String localName, Class<? extends FXGNode> nodeClass)
    {
        FXGVersionHandler vHandler = FXGVersionHandlerRegistry.getVersionHandler(version);
        if (vHandler != null)
        {
            HashMap<String, Class<? extends FXGNode>> elementNodes = new HashMap<String, Class<? extends FXGNode>>(4);
            elementNodes.put(localName, nodeClass);
            vHandler.registerElementNodes(uri, elementNodes);
        }  
        else
        {
            throw new FXGException("FXGVersionHandlerNotRegistered", version);
        }
    }


    /**
     * Record the start and end line and column information for this node.
     * @param node - the current node 
     */
    private void assignNodeLocation(FXGNode node)
    {
        if (node != null)
        {
            node.setStartLine(startLine);
            node.setStartColumn(startColumn);
            node.setEndLine(locator.getLineNumber());
            node.setEndColumn(locator.getColumnNumber());
        }
    }

    /**
     * @param uri - the namespace URI of the registered FXG elements.
     * @return a Map of the FXGNode Classes registered for elements in the
     * given namespace URI.
     */
    private Map<String, Class<? extends FXGNode>> getElementNodes(String uri)
    {
        return versionHandler.getElementNodes(uri);
    }

    /**
     * validates restrictions on PRIVATE element
     * @param localName
     */
    private void validatePrivateElement(String localName, boolean startElement)
    {
        if (!startElement)
        {
            if (inMaskAfterPrivateElement && localName.equals(FXGConstants.FXG_MASK_ELEMENT))
                inMaskAfterPrivateElement = false;
            return;
        }

        if (localName.equals(FXGConstants.FXG_PRIVATE_ELEMENT))
        {
            if (seenPrivateElement)
            {
                throw new FXGException("PrivateElementMultipleOccurrences", startLine, startColumn);
            }
            else
            {
                if ((!inSkippedElement()) && stack.size() == 1)
                    seenPrivateElement = true;
                else
                    throw new FXGException("PrivateElementNotChildOfGraphic", startLine, startColumn);
            }
        }
        else
        {
            if (seenPrivateElement && (!inSkippedElement()))
            {
                if ((!inMaskAfterPrivateElement) && (localName.equals(FXGConstants.FXG_MASK_ELEMENT)))
                {
                    inMaskAfterPrivateElement = true;
                }
                else
                {
                    if (!inMaskAfterPrivateElement)
                        throw new FXGException("PrivateElementNotLast", startLine, startColumn);
                }
            }
        }
    }
    
    /**
     * @return - true if major version of the FXG file matches the compiler's
     * major version. false otherwise.
     */
    private boolean isMajorVersionMatch(GraphicNode root)
    {
        long majorVersion = root.getVersion().getMajorVersion();
        long compilerMajorVersion = versionHandler.getVersion().getMajorVersion();
        if (majorVersion == compilerMajorVersion)
            return true;
        else
            return false;
    }
    
}
