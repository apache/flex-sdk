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

package flex2.compiler.mxml.builder;

import flex2.compiler.CompilationUnit;
import flex2.compiler.util.CompilerMessage.CompilerError;
import flex2.compiler.util.CompilerMessage.CompilerWarning;
import flex2.compiler.mxml.MxmlConfiguration;
import flex2.compiler.mxml.dom.CDATANode;
import flex2.compiler.mxml.dom.Node;
import flex2.compiler.mxml.dom.XMLNode;
import flex2.compiler.mxml.lang.TextParser;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.mxml.rep.BindingExpression;
import flex2.compiler.mxml.rep.Model;
import flex2.compiler.mxml.rep.MxmlDocument;
import flex2.compiler.mxml.rep.XML;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.PrefixMapping;
import flex2.compiler.util.QName;
import flex2.compiler.util.XMLStringSerializer;
import flex2.compiler.util.QNameMap;
import macromedia.asc.util.IntegerPool;

import org.xml.sax.Attributes;

import java.io.IOException;
import java.io.StringWriter;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

/*
 * TODO haven't converted the text value parsing here. CDATANode.inCDATA is being ignored; don't know if there are other issues.
 */
/**
 * This builder handles building an XML instance from an XMLNode and
 * it's children.
 *
 * @author Clement Wong
 */
class XMLBuilder extends AbstractBuilder
{
    XMLBuilder(CompilationUnit unit, TypeTable typeTable, MxmlConfiguration mxmlConfiguration, MxmlDocument document)
    {
        this(unit, typeTable, mxmlConfiguration, document, null);
        allowTopLevelBinding = true;
        allowTwoWayBind = true;
    }

    XMLBuilder(CompilationUnit unit, TypeTable typeTable, MxmlConfiguration mxmlConfiguration, MxmlDocument document, Model parent)
    {
        super(unit, typeTable, mxmlConfiguration, document);
        this.parent = parent;
        allowTopLevelBinding = false;
        allowTwoWayBind = false;
    }

    private String id;
    private Model parent;
    private boolean allowTopLevelBinding;
    private boolean allowTwoWayBind;
    XML xml;

    public void analyze(XMLNode node)
    {
        id = (String)getLanguageAttributeValue(node, StandardDefs.PROP_ID);
        boolean e4x = node.isE4X();
        Type t = typeTable.getType(standardDefs.getXmlBackingClassName(e4x));
        xml = new XML(document, t, parent, e4x, node.beginLine);
        if (id != null)
        {
            xml.setId(id, false);
        }

        StringWriter writer = new StringWriter();

        if (node.getChildCount() > 1)
        {
            log(node, new OnlyOneRootTag());
        }
        else if (node.getChildCount() == 0)
        {
            writer.write("null");
        }
        else if ((node.getChildCount() == 1) && (node.getChildAt(0) instanceof CDATANode))
        {
            /**
             * <mx:XML>{binding_expression}</mx:XML>
             */
            CDATANode cdata = (CDATANode)node.getChildAt(0);

            if (cdata.image.length() > 0)
            {
                BindingExpression be = textParser.parseBindingExpression(cdata.image, cdata.beginLine);

                if (be != null)
                {
                    if (allowTopLevelBinding)
                    {
                        if (!be.isTwoWayPrimary() || allowTwoWayBind)
                        {
                            be.setDestination(xml);
                            writer.write("null");
                        }
                        else
                        {
                            log(cdata, new AbstractBuilder.TwoWayBindingNotAllowed());
                        }
                    }
                    else
                    {
                        log(cdata, new AbstractBuilder.BindingNotAllowed());
                    }
                }
                else
                {
                    log(node, new RequireXMLContent());
                }
            }
        }
        else
        {
            if (e4x)
            {
                processChildren(e4x, node, writer, null, new Stack<String>(), new Stack<PrefixMapping>());
            }
            else
            {
                processChildren(e4x, node, new XMLStringSerializer(writer), null, new Stack<String>(), null);
            }
        }

        xml.setLiteralXML(writer.toString());
    }

    /**
     *
     */
    private void processNode(boolean e4x,
                             Node node,
                             Object serializer,
                             String getElementsByLocalName,
                             Stack<String> destinationPropertyStack,
                             Stack<PrefixMapping> namespaces)
    {
        QNameMap<BindingExpression> attributeBindings = processAttributes(node);

        if (attributeBindings != null)
        {
            String destinationProperty = createExpression(destinationPropertyStack);

            for (Iterator<QName> i = attributeBindings.keySet().iterator(); i.hasNext();)
            {
                flex2.compiler.util.QName attrName = i.next();

                String attrExpr, nsUri = null;
                int nsId = 0;
                if (e4x)
                {
                    // If the attribute node has a namespace use that.  Otherwise 
                    // use the namespace of the element node.
                    nsUri = attrName.getNamespace();
                    if (nsUri.length() > 0)
                    {
                        nsId = PrefixMapping.getNamespaceId(nsUri, namespaces);                        
                    }
                    else
                    {
                        PrefixMapping pm = (PrefixMapping) namespaces.peek();
                        nsUri = pm.getUri();
                        nsId = pm.getNs();
                    }
                    
                    if (nsId > 0)
                    {
                        attrExpr = getElementsByLocalName + ".@ns" + nsId + "::" + attrName.getLocalPart();
                    }
                    else
                    {
                        attrExpr = getElementsByLocalName + ".@" + attrName.getLocalPart();
                    }
                }
                else
                {
                    attrExpr = getElementsByLocalName + ".attributes[\"" + attrName.getLocalPart() + "\"]";
                }

                BindingExpression be = attributeBindings.get(attrName);

                be.setDestinationE4X(e4x);
                be.setDestinationXMLAttribute(true);
                be.setDestinationLValue(attrExpr);
                be.setDestinationProperty(destinationProperty + "[" + node.getIndex() + "]");
                be.setDestination(xml);

                xml.setHasBindings(true);

                if (e4x)
                {
                    PrefixMapping.pushNamespaces(be, namespaces);
                    if (nsUri.length() > 0)
                    {
                        be.addNamespace(nsUri, nsId);
                    }
                }
            }
        }

        try
        {
            if (e4x)
            {
                node.toStartElement((StringWriter) serializer);
            }
            else
            {
                QName qname = new QName(node.getNamespace(), node.getLocalPart(), node.getPrefix());
                ((XMLStringSerializer) serializer).startElement(qname, new AttributesHelper(node));
            }

            if (node.getChildCount() == 1 && node.getChildAt(0) instanceof CDATANode)
            {
                CDATANode cdata = (CDATANode) node.getChildAt(0);
                if (cdata.image.length() > 0)
                {
                    if (cdata.inCDATA)
                    {
                        //in CDATA Section, leave exactly as is
                        if (e4x)
                        {
                            ((StringWriter) serializer).write("<![CDATA[" + cdata.image + "]]>");
                        }
                        else
                        {
                            ((XMLStringSerializer) serializer).writeString(cdata.image);
                        }                        
                    }
                    else
                    {
                        //not in CDATA section so extract bindings and cleanup binding escapes 
                        BindingExpression be = textParser.parseBindingExpression(cdata.image, cdata.beginLine);
                        if (be != null)
                        {
                            if (be.isTwoWayPrimary() && !allowTwoWayBind)
                            {
                                log(cdata, new AbstractBuilder.TwoWayBindingNotAllowed());
                            }
                            else
                            {
                                String destinationProperty = createExpression(destinationPropertyStack);

                                be.setDestinationLValue(getElementsByLocalName);
                                be.setDestinationProperty(destinationProperty + "[" + node.getIndex() + "]");
                                be.setDestination(xml);
                                be.setDestinationXMLNode(true);

                                xml.setHasBindings(true);

                                if (e4x)
                                {
                                    be.setDestinationE4X(true);
                                    PrefixMapping.pushNamespaces(be, namespaces);
                                }
                            }
                        }
                        else if (e4x)
                        {
                            ((StringWriter) serializer).write(TextParser.replaceBindingEscapesForE4X(cdata.image));
                        }
                        else
                        {
                            String text = TextParser.cleanupBindingEscapes(cdata.image);
                            text = TextParser.cleanupAtFunctionEscapes(text);
                            ((XMLStringSerializer) serializer).writeString(text);
                        }                        
                    }                    
                }
            }
            else
            {
                processChildren(e4x, node, serializer, getElementsByLocalName, destinationPropertyStack, namespaces);
            }

            if (e4x)
            {
                node.toEndElement((StringWriter) serializer);
            }
            else
            {
                ((XMLStringSerializer) serializer).endElement();
            }
        }
        catch (IOException e)
        {
            logError(node, e.getLocalizedMessage());
        }
    }

    private void processChildren(boolean e4x,
                                 Node node,
                                 Object serializer,
                                 String getElementsByLocalName,
                                 Stack<String> destinationProperty,
                                 Stack<PrefixMapping> namespaces)
    {
        assignIndices(node);

        int numCData = 0;
        
        for (int i = 0, count = node.getChildCount(); i < count; i++)
        {
            Node child = (Node) node.getChildAt(i);
            if (child instanceof CDATANode)
            {
            	numCData++;
                CDATANode cdata = (CDATANode) child;
                
                if (cdata.image.length() > 0)
                {
                    if (cdata.inCDATA)
                    {
                        //in CDATA Section, leave exactly as is
                        if (e4x)
                        {
                            ((StringWriter) serializer).write("<![CDATA[" + cdata.image + "]]>");
                        }
                        else
                        {
                        	try
                        	{
                        		((XMLStringSerializer) serializer).writeString(cdata.image);
                        	}
                        	catch (IOException e)
                            {
                                logError(cdata, e.getLocalizedMessage());
                            }
                        }                        
                    }
                    else
                    {
                        // We're not in CDATA section so extract bindings and cleanup binding escapes 
                        BindingExpression be = textParser.parseBindingExpression(cdata.image, cdata.beginLine);
                        if (be != null)
                        {
                            if (be.isTwoWayPrimary() && !allowTwoWayBind)
                            {
                                log(cdata, new AbstractBuilder.TwoWayBindingNotAllowed());
                            }
                            else
                            {
                                be.setDestinationLValue(getElementsByLocalName + ".text()[" + (numCData - 1) + "]");
                                be.setDestinationProperty(destinationProperty + "[" + node.getIndex() + "]" + ".text()[" + i + "]" );
                                be.setDestination(xml);
                                be.setDestinationXMLNode(true);

                                xml.setHasBindings(true);

                                if (e4x)
                                {
                                    be.setDestinationE4X(true);
                                    PrefixMapping.pushNamespaces(be, namespaces);
                                }
                                
                                // Inject placeholder cdata child so we can target it 
                                // with binding.
                                ((StringWriter) serializer).write("<![CDATA[" +  "]]>");
                            }
                        }
                        else if (e4x)
                        {
                            ((StringWriter) serializer).write(TextParser.replaceBindingEscapesForE4X(cdata.image));
                        }
                        else
                        {
                            String text = TextParser.cleanupBindingEscapes(cdata.image);
                            text = TextParser.cleanupAtFunctionEscapes(text);
                            try
                            {
                            	((XMLStringSerializer) serializer).writeString(text);
                            }
                            catch (IOException e)
                            {
                                logError(cdata, e.getLocalizedMessage());
                            }
                        }                        
                    }                    
                }
            }
            else if (e4x)
            {
                PrefixMapping.pushNodeNamespace(child, namespaces);
                
                if (getElementsByLocalName != null)
                {
                    StringBuilder e4xbuffer = new StringBuilder(getElementsByLocalName);
                    String destProp = child.getLocalPart();
                    if (child.getNamespace().length() > 0)
                    {
                        PrefixMapping pm = namespaces.peek();
                        destProp = "ns" + pm.getNs() + "::" + destProp;
                    }
                    e4xbuffer.append(".").append(destProp).append("[").append(child.getIndex()).append("]");

                    destinationProperty.push(destProp);
                    processNode(e4x, child, serializer, e4xbuffer.toString(), destinationProperty, namespaces);
                    destinationProperty.pop();
                }
                else
                {
                    processNode(e4x, child, serializer, xml.getId(), destinationProperty, namespaces);
                }
                
                PrefixMapping.popNodeNamespace(namespaces);
            }
            else
            {
                String classNamespaceUtil = NameFormatter.toDot(standardDefs.CLASS_NAMESPACEUTIL);
                document.addImport(classNamespaceUtil, node.beginLine);

                StringBuilder buffer = new StringBuilder(classNamespaceUtil + ".getElementsByLocalName(");
                buffer.append((getElementsByLocalName == null) ? xml.getId() : getElementsByLocalName);
                buffer.append(", \"").append(child.getLocalPart()).append("\")[").append(child.getIndex()).append("]");

                destinationProperty.push(child.getLocalPart());
                processNode(e4x, child, serializer, buffer.toString(), destinationProperty, null);
                destinationProperty.pop();
            }
        }
    }

    private QNameMap<BindingExpression> processAttributes(Node node)
    {
        QNameMap<BindingExpression> attributeBindings = null;

        for (Iterator<QName> i = node.getAttributeNames(); i != null && i.hasNext();)
        {
            QName qname = i.next();
            String value = (String) node.getAttributeValue(qname);

            BindingExpression be = textParser.parseBindingExpression(value, node.beginLine);

            if (be != null)
            {
                if (be.isTwoWayPrimary() && !allowTwoWayBind)
                {
                    log(node, new AbstractBuilder.TwoWayBindingNotAllowed());
                    continue;
                }
                                        
                if (attributeBindings == null)
                {
                    attributeBindings = new QNameMap<BindingExpression>();
                }
                
                // C: only localPart as the key?
                attributeBindings.put(qname, be);
                i.remove();
            }
        }

        return attributeBindings;
    }

    // C: The implementation of this method depends on the implementation of app model's
    //    NamespaceUtil.getElementsByLocalName()...
    private void assignIndices(Node parent)
    {
        Map<String, Integer> counts = new HashMap<String, Integer>();

        Integer zero = IntegerPool.getNumber(0);

        for (int i = 0, count = parent.getChildCount(); i < count; i++)
        {
            Node child = (Node) parent.getChildAt(i);
            if (child instanceof CDATANode)
            {
                continue;
            }

            if (!counts.containsKey(child.image))
            {
                counts.put(child.image, zero);
                child.setIndex(0);
            }
            else
            {
                int num = counts.get(child.image).intValue() + 1;
                counts.put(child.image, IntegerPool.getNumber(num));
                child.setIndex(num);
            }
        }
    }

    private String createExpression(Stack<String> stack)
    {
        StringBuilder buffer = new StringBuilder();

        for (int i = 0, count = stack.size(); i < count; i++)
        {
            buffer.append(stack.get(i));
            if (i < count - 1)
            {
                buffer.append(".");
            }
        }

        return buffer.toString();
    }

    // C: Not efficient... flex2.compiler.mxml.Element needs a better data structure to support
    //    SAX-style Attributes.
    class AttributesHelper implements Attributes
    {
        AttributesHelper(Node node)
        {
            namespaces = new String[node.getAttributeCount()];
            localParts = new String[node.getAttributeCount()];
            values = new Object[node.getAttributeCount()];

            Iterator names = node.getAttributeNames();
            for (int i = 0; names != null && names.hasNext(); i++)
            {
                flex2.compiler.util.QName qname = (flex2.compiler.util.QName) names.next();
                namespaces[i] = qname.getNamespace();
                localParts[i] = qname.getLocalPart();
                values[i] = node.getAttributeValue(qname);
            }
        }

        private String[] namespaces;
        private String[] localParts;
        private Object[] values;

        public int getLength ()
        {
            return values.length;
        }

        public String getURI (int index)
        {
            return namespaces[index];
        }

        public String getLocalName (int index)
        {
            return localParts[index];
        }

        public String getQName (int index)
        {
            if ((namespaces[index] == null) || (namespaces[index].equals("")))
            {
                return localParts[index];
            }
            else
            {
                return namespaces[index] + ":" + localParts[index];
            }
        }

        public String getType (int index)
        {
            return "CDATA";
        }

        public String getValue (int index)
        {
            return (String) values[index];
        }

        public int getIndex (String uri, String localName)
        {
            for (int i = 0, count = namespaces.length; i < count; i++)
            {
                if (namespaces[i].equals(uri) && localParts[i].equals(localName))
                {
                    return i;
                }
            }

            return -1;
        }

        public int getIndex (String qName)
        {
            for (int i = 0, count = namespaces.length; i < count; i++)
            {
                if (getQName(i).equals(qName))
                {
                    return i;
                }
            }

            return -1;
        }

        public String getType (String uri, String localName)
        {
            return "CDATA";
        }

        public String getType (String qName)
        {
            return "CDATA";
        }

        public String getValue (String uri, String localName)
        {
            for (int i = 0, count = namespaces.length; i < count; i++)
            {
                if (namespaces[i].equals(uri) && localParts[i].equals(localName))
                {
                    return (String) values[i];
                }
            }

            return null;
        }

        public String getValue (String qName)
        {
            for (int i = 0, count = namespaces.length; i < count; i++)
            {
                if (getQName(i).equals(qName))
                {
                    return (String) values[i];
                }
            }

            return null;
        }
    }

    public static class MixedContent extends CompilerWarning
    {
        private static final long serialVersionUID = 8086425515879147830L;
        public String image;

        public MixedContent(String image)
        {
            this.image = image;
        }
    }

    public static class OnlyOneRootTag extends CompilerError
    {
        private static final long serialVersionUID = 5956735990753539012L;

        public OnlyOneRootTag()
        {
            super();
        }
    }

    public static class RequireXMLContent extends CompilerError
    {
        private static final long serialVersionUID = -2844205717905239917L;

        public RequireXMLContent()
        {
            super();
        }
    }
}
