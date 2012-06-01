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

package flex2.compiler.mxml.dom;

import flex2.compiler.mxml.MXMLNamespaces;
import flex2.compiler.mxml.Parser;
import flex2.compiler.mxml.ParserConstants;
import flex2.compiler.mxml.Token;
import flex2.compiler.mxml.TokenManager;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.ThreadLocalToolkit;
import org.xml.sax.Attributes;
import org.xml.sax.Locator;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.ext.LexicalHandler;
import org.xml.sax.helpers.DefaultHandler;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Stack;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static flex2.compiler.mxml.lang.StandardDefs.SPARK_TEXT_ATTRIBUTE;
import static flex2.compiler.mxml.lang.StandardDefs.SPARK_TEXT_CONTENT_PROPERTIES;
import static flex2.compiler.mxml.lang.StandardDefs.SPARK_TEXT_TAGS;

/**
 * JavaCC-compatible token manager. It uses SAXParser to do MXML parsing.
 * 
 * @author Clement Wong
 */
public class MxmlScanner extends DefaultHandler implements TokenManager,
        MXMLNamespaces
{
    private static final String CUSTOM_ATTRIBUTES_CLASS = "org.apache.xerces.parsers.AbstractSAXParserMMImpl$AttributesProxy";
    private static Class CustomAttributeClass = null;
    private static XercesClassLoader xercesClassLoader;

    public static String MarkupNotRecognizedInContent, ReservedPITarget,
            MarkupNotRecognizedInMisc, ETagRequired;

    static
    {
        try
        {
            // use reflection to determine if the Attributes implementation is
            // an instance of
            // the Flex Xerces modified class - don't directly use
            // instanceof because
            // we want to avoid having a hard dependency on that custom class,
            // or any xerces code,
            // so that MxmlParser.java can remain cross-platform wrt J2EE and
            // .NET
            ClassLoader contextClassLoader = getXercesClassLoader();
            CustomAttributeClass = Class.forName(CUSTOM_ATTRIBUTES_CLASS, true, contextClassLoader);
        }
        catch (Exception ex)
        {
            ThreadLocalToolkit.log(new XMLTagAttributeLineNumber());
        }

        java.util.ResourceBundle rb = null;
        try
        {
            rb = java.util.ResourceBundle.getBundle("org.apache.xerces.impl.msg.XMLMessages");
            if (rb != null)
            {
                MarkupNotRecognizedInContent = rb.getString("MarkupNotRecognizedInContent");
                ReservedPITarget = rb.getString("ReservedPITarget");
                MarkupNotRecognizedInMisc = rb.getString("MarkupNotRecognizedInMisc");
                ETagRequired = rb.getString("ETagRequired");
            }
        }
        catch (Exception ex)
        {
        }
        finally
        {
            if (rb == null)
            {
                MarkupNotRecognizedInContent = "The content of elements must consist of well-formed character data or markup.";
                ReservedPITarget = "The processing instruction target matching \"[xX][mM][lL]\" is not allowed.";
                MarkupNotRecognizedInMisc = "The markup in the document following the root element must be well-formed.";
                ETagRequired = "The element type \"{0}\" must be terminated by the matching end-tag \"</{0}>\".";
            }
        }
    }

    public MxmlScanner(InputStream in, boolean processDesignLayers)
    {
        this(in, processDesignLayers, false);
    }

    public MxmlScanner(InputStream in, boolean processDesignLayers, boolean processComments)
    {
        saxEvents = new ArrayList<Object>(100);
        elementStack = new Stack<Object>();
        cdataHandler = new CDATAHandler(processComments);
        this.processDesignLayers = processDesignLayers;
        pos = 0;
        ClassLoader cl = Thread.currentThread().getContextClassLoader();

        try
        {
            ClassLoader xercesClassLoader = getXercesClassLoader();
            Thread.currentThread().setContextClassLoader(xercesClassLoader);
            SAXParserFactory saxFactory = SAXParserFactory.newInstance();
            saxFactory.setValidating(false);
            saxFactory.setNamespaceAware(true);
            SAXParser parser = saxFactory.newSAXParser();
            parser.setProperty("http://xml.org/sax/properties/lexical-handler", cdataHandler);
            parser.parse(in, this);
        }
        catch (ParserConfigurationException ex)
        {
        }
        catch (SAXException ex)
        {
            Throwable t = ex.getCause();
            if (t instanceof ScannerError)
            {
                throw (ScannerError)t;
            }
        }
        catch (IOException ex)
        {
        }
        finally
        {
            Thread.currentThread().setContextClassLoader(cl);            
        }
    }

    private static ClassLoader getXercesClassLoader() throws IOException
    {
        if (xercesClassLoader == null)
        {
            URL url = MxmlScanner.class.getProtectionDomain().getCodeSource().getLocation();
            String urlString = url.toString();
            String base = urlString.substring(0, urlString.lastIndexOf("/"));
            URL xercesPatchJarURL = new URL(base + "/external/xercesPatch.jar");
            URL xercesImplJarURL = new URL(base + "/external/xercesImpl.jar");
            URL xercesImplJaJarURL = new URL(base + "/external/xercesImpl_ja.jar");
            URL[] classpath = new URL[] {xercesPatchJarURL, xercesImplJarURL, xercesImplJaJarURL};
            xercesClassLoader = new XercesClassLoader(classpath, MxmlScanner.class.getClassLoader());
        }

        return xercesClassLoader;
    }

    /**
     * saxEvents holds Tokens and ScannerErrors
     */
    private String languageNamespace;
    private int languageVersion;
    private List<Object> saxEvents;
    private Stack<Object> elementStack;
    private CDATAHandler cdataHandler;
    private int beginLine, beginColumn, pos, kind;
    private boolean processDesignLayers = false;

    /**
     * Implements the JavaCC TokenManager interface.
     * 
     * @return
     * @throws ScannerError
     */
    public Token getNextToken() throws ScannerError
    {
        Object evt;

        if (pos >= saxEvents.size())
        {
            evt = saxEvents.get(saxEvents.size() - 1);

            int line, col;

            if (evt instanceof Token)
            {
                line = ((Token)evt).beginLine;
                col = ((Token)evt).beginColumn;

                String msg = ThreadLocalToolkit.getLocalizationManager().getLocalizedTextString(new UnexpectedEndOfTokenStream(((Token)evt).image));
                throw new ScannerError(line, col, msg);
            }
            else
            {
                line = ((ScannerError)evt).getLineNumber();
                col = ((ScannerError)evt).getColumnNumber();

                String msg = ThreadLocalToolkit.getLocalizationManager().getLocalizedTextString(new UnexpectedEndOfSAXStream(((ScannerError)evt).getReason()));
                throw new ScannerError(line, col, msg);
            }
        }

        evt = saxEvents.get(pos++);

        if (evt instanceof Token)
        {
            return (Token)evt;
        }
        else
        {
            throw (ScannerError)evt;
        }
    }

    /**
     * lexer state mgmt, to support legacy 1.x syntax
     * <p>
     * NOTE: this scheme works without a stack <strong>only as long as legacy
     * MXML subtrees do not nest</strong>.
     * <p>
     * E.g. at present, we support legacy syntax in subtrees rooted by Effect,
     * RemoteObject, WebService and HttpService, none of which may appear inside
     * any of the others.
     * <p>
     * If that constraint is violated, you'll need a stack to track lexer state,
     * at which point Scanner will resemble nothing so much as a standard SAX
     * handler-stack XML processor, sitting in front of what amounts to a
     * javacc-generated regex matcher in Parser. Once things get to that point,
     * we should move revisiting and simplifying the parser architecture to the
     * top of the list..
     */
    private static final int LEX_FLEX2 = 0;
    private static final int LEX_FLEX1_WEBSERVICE = 1;
    private static final int LEX_FLEX1_HTTPSERVICE = 2;
    private static final int LEX_FLEX1_REMOTEOBJECT = 3;
    private static final int LEX_FLEX2_PRIVATE = 4;
    private int state = LEX_FLEX2;
    private int textDepth;

    private int findElementType(String uri, String localName, boolean start)
    {
        int kind = Parser.findElementType(uri, localName, start);

        switch (state)
        {
            /**
             * Standard Flex 2 lex state. Transition into Flex1-compatible
             * top-level tags; suppress special Flex1 grandkids.
             */
            case LEX_FLEX2:
                switch (kind)
                {
                    case ParserConstants.START_WEBSERVICE:
                        state = LEX_FLEX1_WEBSERVICE;
                        break;
                    case ParserConstants.START_HTTPSERVICE:
                        state = LEX_FLEX1_HTTPSERVICE;
                        break;
                    case ParserConstants.START_REMOTEOBJECT:
                        state = LEX_FLEX1_REMOTEOBJECT;
                        break;
                    case ParserConstants.START_PRIVATE:
                        state = LEX_FLEX2_PRIVATE;
                        break;
                    case ParserConstants.START_OPERATION:
                    case ParserConstants.START_REQUEST:
                    case ParserConstants.START_METHOD:
                    case ParserConstants.START_ARGUMENTS:
                        kind = ParserConstants.START_ELEMENT;
                        break;
                    case ParserConstants.END_OPERATION:
                    case ParserConstants.END_REQUEST:
                    case ParserConstants.END_METHOD:
                    case ParserConstants.END_ARGUMENTS:
                        kind = ParserConstants.END_ELEMENT;
                        break;
                }
                break;

            /**
             * Ignore everything between the Private elements.
             */
            case LEX_FLEX2_PRIVATE:
                switch (kind)
                {
                    case ParserConstants.END_PRIVATE:
                        state = LEX_FLEX2;
                        break;
                    default:
                        kind = ParserConstants.SKIP_ELEMENT;
                        break;
                }
                break;

            /**
             * Flex 1 WebService lex state. Transition out on end tag, suppress
             * non-WS specialness.
             */
            case LEX_FLEX1_WEBSERVICE:
                switch (kind)
                {
                    case ParserConstants.END_WEBSERVICE:
                        state = LEX_FLEX2;
                        break;
                    case ParserConstants.START_METHOD:
                    case ParserConstants.START_ARGUMENTS:
                        kind = ParserConstants.START_ELEMENT;
                        break;
                    case ParserConstants.END_METHOD:
                    case ParserConstants.END_ARGUMENTS:
                        kind = ParserConstants.END_ELEMENT;
                        break;
                }
                break;

            /**
             * Flex 1 HTTPService lex state. Transition out on end tag, suppress
             * non-HTTPS specialness.
             */
            case LEX_FLEX1_HTTPSERVICE:
                switch (kind)
                {
                    case ParserConstants.END_HTTPSERVICE:
                        state = LEX_FLEX2;
                        break;
                    case ParserConstants.START_OPERATION:
                    case ParserConstants.START_METHOD:
                    case ParserConstants.START_ARGUMENTS:
                        kind = ParserConstants.START_ELEMENT;
                        break;
                    case ParserConstants.END_OPERATION:
                    case ParserConstants.END_METHOD:
                    case ParserConstants.END_ARGUMENTS:
                        kind = ParserConstants.END_ELEMENT;
                        break;
                }
                break;

            /**
             * Flex 1 RemoteObject lex state. Transition out on end tag,
             * suppress non-RO specialness.
             */
            case LEX_FLEX1_REMOTEOBJECT:
                switch (kind)
                {
                    case ParserConstants.END_REMOTEOBJECT:
                        state = LEX_FLEX2;
                        break;
                    case ParserConstants.START_OPERATION:
                    case ParserConstants.START_REQUEST:
                        kind = ParserConstants.START_ELEMENT;
                        break;
                    case ParserConstants.END_OPERATION:
                    case ParserConstants.END_REQUEST:
                        kind = ParserConstants.END_ELEMENT;
                        break;
                }
                break;
        }

        return kind;
    }

    protected Node createNode(int kind, String uri, String localName,
            Attributes attributes)
    {
        int numAttributes = attributes.getLength();
        Node node = null;

        switch (kind)
        {
            case ParserConstants.START_STYLE:
                node = new StyleNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_SCRIPT:
                node = new ScriptNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_METADATA:
                node = new MetaDataNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_MODEL:
                node = new ModelNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_XML:
                node = new XMLNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_XMLLIST:
                node = new XMLListNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_ARRAY:
                node = new ArrayNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_VECTOR:
                node = new VectorNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_STRING:
                node = new StringNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_NUMBER:
                node = new NumberNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_INT:
                node = new IntNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_UINT:
                node = new UIntNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_BOOLEAN:
                node = new BooleanNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_CLASS:
                node = new ClassNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_FUNCTION:
                node = new FunctionNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_WEBSERVICE:
                node = new WebServiceNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_HTTPSERVICE:
                node = new HTTPServiceNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_REMOTEOBJECT:
                node = new RemoteObjectNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_OPERATION:
                node = new OperationNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_REQUEST:
                if ("xml".equals(attributes.getValue("", "format")))
                {
                    node = new XMLNode(uri, localName, numAttributes);
                }
                else
                {
                    node = new RequestNode(uri, localName, numAttributes);
                }
                break;
            case ParserConstants.START_METHOD:
                node = new MethodNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_ARGUMENTS:
                node = new ArgumentsNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_BINDING:
                node = new BindingNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_ELEMENT:
                if (saxEvents.size() == 0)
                {
                    DocumentNode documentNode = new DocumentNode(uri, localName, numAttributes);
                    documentNode.setLanguageNamespace(languageNamespace);
                    documentNode.setVersion(languageVersion);
                    node = documentNode;
                }
                else
                {
                    // If the immediate parent of this node is a DesignLayer
                    // then we construct a LayeredNode and associate the layer
                    // parent if applicable.
                    Object parentElement = elementStack.peek();
                    if (processDesignLayers && parentElement instanceof DesignLayerNode)
                        node = new LayeredNode(uri, localName, numAttributes, (DesignLayerNode) parentElement);
                    else
                        node = new Node(uri, localName, numAttributes);
                }
                break;
            case ParserConstants.START_COMPONENT:
                node = new InlineComponentNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_DESIGNLAYER:
            	// If immediate parent is a design layer, then ensure our
            	// node is assigned a layerParent;
            	Object parentElement = elementStack.peek();
            	DesignLayerNode layerParent = (processDesignLayers && parentElement instanceof DesignLayerNode) ?
            			(DesignLayerNode) parentElement : null;
                node = new DesignLayerNode(uri, localName, numAttributes, layerParent);
                break;
            case ParserConstants.START_DECLARATIONS:
                node = new DeclarationsNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_REPARENT:
                node = new ReparentNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_STATE:
                node = new StateNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_PRIVATE:
                node = new PrivateNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_LIBRARY:
                node = new LibraryNode(uri, localName, numAttributes);
                break;
            case ParserConstants.START_DEFINITION:
                node = new DefinitionNode(uri, localName, numAttributes);
                break;
        }

        return node;
    }

    private void assignTokenPosition(Token t)
    {
        if (saxEvents.size() == 0)
        {
            beginLine = locator.getLineNumber();
            beginColumn = locator.getColumnNumber();
        }

        t.beginLine = beginLine;
        t.beginColumn = beginColumn;
        t.endLine = locator.getLineNumber();
        t.endColumn = locator.getColumnNumber();
    }

    public void close()
    {
        saxEvents.clear();
    }

    // override DefaultHandler

    private Locator locator;
    private Map<String, String> prefixMappings;

    public void setDocumentLocator(Locator locator)
    {
        this.locator = locator;
    }

    public void processingInstruction (String target, String data) throws SAXException
    {
        ThreadLocalToolkit.log(new UnexpectedProcessingInstruction(data));
    }
    
    public void startDocument() throws SAXException
    {
        prefixMappings = new HashMap<String, String>();
        textDepth = 0;
    }

    public void endDocument() throws SAXException
    {
        Token t = new Token();
        t.kind = ParserConstants.EOF;
        assignTokenPosition(t);
        t.image = "";
        saxEvents.add(t);
        kind = ParserConstants.EOF;

        locator = null;
        prefixMappings = null;
    }

    public void startPrefixMapping(String prefix, String uri)
            throws SAXException
    {
        prefixMappings.put(uri, prefix);

        int version = getLanguageVersion(uri);
        if (version != -1)
        {
            // Only one language version can be used per document.
            if (languageNamespace != null && !languageNamespace.equals(uri))
            {
                String msg = ThreadLocalToolkit.getLocalizationManager().getLocalizedTextString(new ConflictingLanguageVersion(languageNamespace, uri));
                throw new ScannerError(locator.getLineNumber(), locator.getColumnNumber(), msg);
            }

            languageNamespace = uri;
            languageVersion = version;
        }
    }

    public void endPrefixMapping(String prefix) throws SAXException
    {
        prefixMappings.remove(prefix);
    }

    public void startElement(String uri, String localName, String qName,
            Attributes attributes) throws SAXException
    {
        kind = findElementType(uri, localName, true);

        // don't process skip tokens
        if (kind == ParserConstants.SKIP_ELEMENT)
        {
            return;
        }

        int numAttributes = attributes.getLength();
        Node n = createNode(kind, uri, localName, attributes);
        n.addPrefixMapping(uri, prefixMappings.get(uri));
        assignTokenPosition(n);

        Method lineNumMethod = null;
        // C: if n.beginLine == n.endLine, then we don't really need to do
        // this...
        if (numAttributes > 0 && CustomAttributeClass != null && attributes.getClass().isAssignableFrom(CustomAttributeClass))
        {
            try
            {
                lineNumMethod = attributes.getClass().getMethod("getLineNumber", new Class[] {Integer.TYPE});
            }
            catch (NoSuchMethodException ex)
            {
                // do nothing... really...
            }
        }

        for (int i = 0; i < numAttributes; i++)
        {
            int line = n.beginLine;

            try
            {
                if (lineNumMethod != null)
                {
                    line = Integer.parseInt(lineNumMethod.invoke(attributes, new Object[] {new Integer(i)}).toString());
                }
            }
            catch (IllegalAccessException ex)
            {
            }
            catch (InvocationTargetException ex)
            {
            }

            String attrUri = attributes.getURI(i);
            n.addAttribute(attrUri, attributes.getLocalName(i), attributes.getValue(i), line);
            n.addPrefixMapping(attrUri, prefixMappings.get(attrUri));
        }

        n.kind = kind;
        n.image = "<" + qName + ">";

        // if there was a comment, lets stick it inside the node.
        if (cdataHandler.comment != null)
        {
            n.comment = cdataHandler.comment;

            // clear up the comment.
            cdataHandler.comment = null;
        }

        // SDK-22601: a workaround for the custom whitespace preservation
        // requirements for spark text components (as MXML does not preserve
        // whitespace outside of a CDATA block). TODO: replace this with a
        // generic mechanism.
        if (SPARK_NAMESPACE.equals(uri))
        {
            if (SPARK_TEXT_TAGS.contains(localName))
            {
                textDepth++;
                n.processChildrenIndividually = true;
                n.preserveWhitespace = true;

                // SDK-24699: a workaround for the case where text was
                // explicitly set via an attribute but whitespace exists as
                // character data in the tag (which would otherwise be assigned
                // to the default property and clobber the text attribute).
                if (attributes.getValue("", SPARK_TEXT_ATTRIBUTE) != null
                        || attributes.getValue(uri, SPARK_TEXT_ATTRIBUTE) != null)
                {
                    n.preserveWhitespace = false;
                }
            }
            else if (textDepth > 0)
            {
                // We must also preserve whitespace under explicit text content
                // properties.
                if (SPARK_TEXT_CONTENT_PROPERTIES.contains(localName))
                {
                    n.processChildrenIndividually = true;
                    n.preserveWhitespace = true;
                }

                // If a spark text tag has a child tag that is not part of
                // text mark-up, we won't preserve whitespace for character
                // data directly attached to this node. This is to avoid bug
                // SDK-23972.
                if (!elementStack.empty())
                {
                    Node parent = (Node) elementStack.peek();
                    parent.preserveWhitespace = false;
                }        
            }
        }

        saxEvents.add(n);
        elementStack.push(n);

        beginLine = locator.getLineNumber();
        beginColumn = locator.getColumnNumber();
    }

    public void endElement(String uri, String localName, String qName)
            throws SAXException
    {
        Token n = new Token();

        n.kind = findElementType(uri, localName, false);

        // don't process skip tokens
        if (n.kind == ParserConstants.SKIP_ELEMENT)
        {
            return;
        }

        assignTokenPosition(n);
        n.image = "</" + qName + ">";

        saxEvents.add(n);

        // As part of a workaround for SDK-22601 we stop preserving whitespace
        // when we leave the scope of a text tag.
        if (textDepth > 0 && SPARK_NAMESPACE.equals(uri) && SPARK_TEXT_TAGS.contains(localName))
        {
            textDepth--;
        }

        if (!elementStack.empty())
        {
            Node prevNode = (Node) elementStack.peek();  	
            if (prevNode.getNamespace().equals(uri) && prevNode.getLocalPart().equals(localName) )
                elementStack.pop();
        }

        kind = n.kind;

        beginLine = locator.getLineNumber();
        beginColumn = locator.getColumnNumber();
    }

    public void characters(char ch[], int start, int length)
            throws SAXException
    {
        String image = new String(ch, start, length);
        Object obj = saxEvents.get(saxEvents.size() - 1);
        boolean wasInCDATA = (obj instanceof CDATANode && ((CDATANode)obj).inCDATA), skip = false;
        CDATANode cdata = (obj instanceof CDATANode) ? (CDATANode)obj : null;

        if (wasInCDATA && cdataHandler.inCDATA)
        {
            // do not null out cdata...
        }
        else if (wasInCDATA && !cdataHandler.inCDATA)
        {
            if (image.trim().length() > 0)
            {
                cdata = null;
            }
            else
            {
                skip = true;
            }
        }
        else if (!wasInCDATA && cdataHandler.inCDATA)
        {
            cdata = null;
        }
        else
        // if (!wasInCDATA && !cdataHandler.inCDATA)
        {
            // do not null out cdata...
            if (kind != ParserConstants.CDATA
                    && image.trim().length() == 0)
            {
                // As part of a workaround for SDK-22601 we skip whitespace if
                // the parent tag does not preserve it.
                if (textDepth > 0)
                {
                    // Check to see if the parent node will preserve whitespace
                    if (!elementStack.empty())
                    {
                        Node parent = (Node) elementStack.peek();
                        if (!parent.preserveWhitespace)
                            skip = true;
                    }
                }
                else
                {
                    skip = true;
                }
            }
        }

        if (!skip && cdata == null)
        {
            cdata = new CDATANode();
            cdata.kind = ParserConstants.CDATA;
            assignTokenPosition(cdata);
            cdata.image = image;
            cdata.inCDATA = cdataHandler.inCDATA;
            saxEvents.add(cdata);
        }
        else if (!skip)
        {
            cdata.image += image;
            // C: only reassign the node's end position.
            cdata.endLine = locator.getLineNumber();
            cdata.endColumn = locator.getColumnNumber();
        }

        if (!skip)
        {
            kind = ParserConstants.CDATA;
        }

        beginLine = locator.getLineNumber();
        beginColumn = locator.getColumnNumber();
    }

    public void warning(SAXParseException e) throws SAXException
    {
        int line = (locator != null) ? locator.getLineNumber() : 1;
        int col = (locator != null) ? locator.getColumnNumber() : 1;

        ScannerError err = new ScannerError(line, col, e.getMessage());
        saxEvents.add(err);
    }

    public void error(SAXParseException e) throws SAXException
    {
        int line = (locator != null) ? locator.getLineNumber() : 1;
        int col = (locator != null) ? locator.getColumnNumber() : 1;

        ScannerError err = new ScannerError(line, col, e.getMessage());
        saxEvents.add(err);
    }

    public void fatalError(SAXParseException e) throws SAXException
    {
        int line = (locator != null) ? locator.getLineNumber() : 1;
        int col = (locator != null) ? locator.getColumnNumber() : 1;

        ScannerError err = new flex2.compiler.mxml.dom.ScannerError(line, col, e.getMessage());
        saxEvents.add(err);
        throw e;
    }

    private class CDATAHandler implements LexicalHandler
    {
        CDATAHandler(boolean processComments)
        {
            this.processComments = processComments;
        }

        boolean inCDATA = false;

        // field to store comment.
        String comment = null;

        // field to check if we care about comments.
        boolean processComments = false;

        public void startCDATA() throws SAXException
        {
            inCDATA = true;
        }

        public void endCDATA() throws SAXException
        {
            inCDATA = false;
        }

        public void startDTD(String s, String s1, String s2)
                throws SAXException
        {
        }

        public void endDTD() throws SAXException
        {
        }

        public void startEntity(String s) throws SAXException
        {
        }

        public void endEntity(String s) throws SAXException
        {
        }

        public void comment(char[] chars, int i, int i1) throws SAXException
        {
            // only process comments if entry is from asdoc.
            if (!processComments)
            {
                return;
            }

            String temp = new String(chars, i, i1);
            // only process comments which are nested in <!---, the ones with <!-- are regular comments. 
            // <!--- 3 dashes are *required*.
            if (temp != null && temp.startsWith("-"))
            {
                temp = temp.substring(1); // ignore the starting dash (-)

                temp = temp.trim();

                // removing the prefix /** and suffix */ - this helps if we user
                // -keep-generated-actionscript, other the generated actionscript
                // breaks the comment then looks like /** /** blah */ */
                if (temp.startsWith("/**"))
                {
                    temp = temp.substring(3);
                }

                if (temp.endsWith("*/"))
                {
                    temp = temp.substring(0, temp.length() - 2);
                }
                
                // replace all - at the start of a line.
                // This should help to support mxml comments like
                //  <!---
                //    - blah
                //    - @private  
                //    -->
                Pattern pattern = Pattern.compile("^\\s*\\-", Pattern.MULTILINE);
                Matcher matcher = pattern.matcher(temp);
                comment = matcher.replaceAll("");
            }
        }
    }

    private static int getLanguageVersion(String uri)
    {
        if (MXML_2009_NAMESPACE.equals(uri) || FXG_2008_NAMESPACE.equals(uri))
        {
            return 4;
        }
        else if (MXML_2006_NAMESPACE.equals(uri))
        {
            return 3;
        }

        return -1;
    }

    // error messages

    public static class ConflictingLanguageVersion extends
            CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -9106905839748620966L;
        public final String ns1;
        public final String ns2;

        public ConflictingLanguageVersion(String ns1, String ns2)
        {
            this.ns1 = ns1;
            this.ns2 = ns2;
        }
    }
    
    public static class UnexpectedProcessingInstruction extends CompilerMessage.CompilerWarning
    {
        private static final long serialVersionUID = -6576251697820779447L;

        public UnexpectedProcessingInstruction(String reason)
        {
            super();
            this.reason = reason;
        }

        public final String reason;
    }
    
    public static class XMLTagAttributeLineNumber extends
            CompilerMessage.CompilerWarning
    {
        private static final long serialVersionUID = -461995005628630535L;

        public XMLTagAttributeLineNumber()
        {
            super();
            noPath();
        }
    }

    public static class UnexpectedEndOfTokenStream extends
            CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 4354585678545293412L;

        public UnexpectedEndOfTokenStream(String token)
        {
            super();
            this.token = token;
        }

        public final String token;
    }

    public static class UnexpectedEndOfSAXStream extends
            CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -3989054372427510063L;

        public UnexpectedEndOfSAXStream(String reason)
        {
            super();
            this.reason = reason;
        }

        public final String reason;
    }
}
