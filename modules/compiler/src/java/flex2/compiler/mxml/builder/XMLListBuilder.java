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

import java.io.StringWriter;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

import macromedia.asc.util.IntegerPool;

import flex2.compiler.CompilationUnit;
import flex2.compiler.util.CompilerMessage.CompilerError;
import flex2.compiler.mxml.MxmlConfiguration;
import flex2.compiler.mxml.dom.CDATANode;
import flex2.compiler.mxml.dom.Node;
import flex2.compiler.mxml.dom.XMLListNode;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.lang.TextParser;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.mxml.rep.AtResource;
import flex2.compiler.mxml.rep.BindingExpression;
import flex2.compiler.mxml.rep.Model;
import flex2.compiler.mxml.rep.MxmlDocument;
import flex2.compiler.mxml.rep.XMLList;
import flex2.compiler.util.PrefixMapping;
import flex2.compiler.util.QName;
import flex2.compiler.util.QNameMap;

/**
 * This builder handles building an XMLList instance from an
 * XMLListNode and it's children.
 */
public class XMLListBuilder extends AbstractBuilder
{

    XMLListBuilder(CompilationUnit unit, TypeTable typeTable, MxmlConfiguration mxmlConfiguration, MxmlDocument document)
    {
        this(unit, typeTable, mxmlConfiguration, document, null);
        allowTopLevelBinding = true;
    }

    XMLListBuilder(CompilationUnit unit, TypeTable typeTable, MxmlConfiguration mxmlConfiguration, MxmlDocument document, Model parent)
    {
        super(unit, typeTable, mxmlConfiguration, document);
        this.parent = parent;
        allowTopLevelBinding = false;
    }

    private String id;
    private Model parent;
    private boolean allowTopLevelBinding;
    XMLList xmlList;

    public void analyze(XMLListNode node)
    {
        id = (String)getLanguageAttributeValue(node, StandardDefs.PROP_ID);
        xmlList = new XMLList(document, typeTable.xmlListType, parent, node.beginLine);

        if (id != null)
        {
            xmlList.setId(id, false);
        }

        StringWriter writer = new StringWriter();

        if (node.getChildCount() == 1 && node.getChildAt(0) instanceof CDATANode)
        {
            CDATANode cdata = (CDATANode) node.getChildAt(0);

            if (cdata.image.length() > 0)
            {
                BindingExpression be = textParser.parseBindingExpression(cdata.image, cdata.beginLine);

                if (be != null)
                {
                    if (allowTopLevelBinding)
                    {
                        be.setDestination(xmlList);
                        writer.write("null");
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
            processChildren(node, writer, null, new Stack<String>(), new Stack<PrefixMapping>());
        }

        xmlList.setLiteralXML(writer.toString());
    }

    /**
     *
     */
    private void processNode(Node node,
                             StringWriter serializer,
                             String e4xElementsByLocalName,
                             Stack<String> destinationPropertyStack,
                             Stack<PrefixMapping> namespaces)
    {
        //System.out.println("processChildren: " + e4xElementsByLocalName + " " + createExpression(destinationPropertyStack));
        
        QNameMap<BindingExpression> attributeBindings = processBindingAttributes(node);
        processResourceAttributes(node);
        
        if (attributeBindings != null)
        {
            //[Matt] I think this value is wrong but I can't see where it's used so we'll leave it for now.
            String destinationProperty = createExpression(destinationPropertyStack);

            for (Iterator<QName> i = attributeBindings.keySet().iterator(); i.hasNext();)
            {
                QName attrName = i.next();
                
                String attrExpr;
                int nsId = 0;
                
                // If the attribute node has a namespace use that.  Otherwise 
                // use the namespace of the element node.
                String nsUri = attrName.getNamespace();
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
                    attrExpr = e4xElementsByLocalName + ".@ns" + nsId + "::" + attrName.getLocalPart();
                }
                else
                {
                    attrExpr = e4xElementsByLocalName + ".@" + attrName.getLocalPart();
                }

                BindingExpression be = attributeBindings.get(attrName);
                
                be.setDestinationLValue(attrExpr);
                be.setDestinationProperty(destinationProperty + "[" + node.getIndex() + "]");
                be.setDestination(xmlList);
                be.setDestinationXMLAttribute(true);
                
                // So be.getDestination() will use LValue.  The destinationProperty is wrong.                
                be.setDestinationE4X(true);
                
                //System.out.println("cdata: LValue=" + e4xElementsByLocalName + " prop=" + be.getDestinationProperty()));

                xmlList.setHasBindings(true);

                PrefixMapping.pushNamespaces(be, namespaces);
                if (nsUri.length() > 0)
                {
                    be.addNamespace(nsUri, nsId);
                }
            }
        }

        node.toStartElement(serializer);

        if (node.getChildCount() == 1 && node.getChildAt(0) instanceof CDATANode)
        {
            CDATANode cdata = (CDATANode) node.getChildAt(0);
            if (cdata.image.length() > 0)
            {
                BindingExpression be = textParser.parseBindingExpression(cdata.image, cdata.beginLine);
                if (be != null)
                {
                    //[Matt] I think this value is wrong but I can't see where it's used so we'll leave it for now.
                    String destinationProperty = createExpression(destinationPropertyStack);

                    be.setDestinationLValue(e4xElementsByLocalName);
                    be.setDestinationProperty(destinationProperty + "[" + node.getIndex() + "]");
                    be.setDestination(xmlList);
                    be.setDestinationXMLNode(true);
                    
                    // So be.getDestination() will use LValue.  The destinationProperty is wrong.
                    be.setDestinationE4X(true);

                    //System.out.println("cdata: LValue=" + e4xElementsByLocalName + " prop=" + be.getDestinationProperty()));
                    
                    xmlList.setHasBindings(true);

                    PrefixMapping.pushNamespaces(be, namespaces);
                }
                else
                {
                    String text = TextParser.cleanupBindingEscapes(cdata.image);
                    text = TextParser.cleanupAtFunctionEscapes(text);
                    serializer.write(text);
                }
            }
        }
        else
        {
            processChildren(node, serializer, e4xElementsByLocalName, destinationPropertyStack, namespaces);
        }

        node.toEndElement(serializer);
    }

    private void processChildren(Node node,
                                 StringWriter serializer,
                                 String e4xElementsByLocalName,
                                 Stack<String> destinationPropertyStack,
                                 Stack<PrefixMapping> namespaces)
    {
        //System.out.println("processChildren: " + e4xElementsByLocalName + " " + createExpression(destinationPropertyStack));
        
        assignIndices(node);

        for (int i = 0, count = node.getChildCount(); i < count; i++)
        {
            Node child = (Node) node.getChildAt(i);
            if (child instanceof CDATANode)
            {
                CDATANode cdata = (CDATANode) child;
                if (cdata.image.trim().length() > 0)
                {
                    // C: ignore CDATANode if other XML elements exist...
                    log(child, new XMLBuilder.MixedContent(child.image));
                }
                else
                {
                    // Whitespace is OK
                    serializer.write(cdata.image);
                }
            }
            else
            {
                PrefixMapping.pushNodeNamespace(child, namespaces);

                if (e4xElementsByLocalName != null)
                {
                    StringBuilder e4xbuffer = new StringBuilder(e4xElementsByLocalName);
                    String destProp = child.getLocalPart();
                    if (child.getNamespace().length() > 0)
                    {
                        PrefixMapping pm = namespaces.peek();
                        destProp = "ns" + pm.getNs() + "::" + destProp;
                    }
                    e4xbuffer.append(".").append(destProp).append("[").append(child.getIndex()).append("]");

                    destinationPropertyStack.push(destProp);
                    processNode(child, serializer, e4xbuffer.toString(), destinationPropertyStack, namespaces);
                    destinationPropertyStack.pop();
                }
                else
                {
                    StringBuilder e4xbuffer = new StringBuilder(xmlList.getId());
                    e4xbuffer.append("[").append(i).append("]");

                    destinationPropertyStack.push(child.getLocalPart());
                    processNode(child, serializer, e4xbuffer.toString(), destinationPropertyStack, namespaces);
                    destinationPropertyStack.pop();
                }

                PrefixMapping.popNodeNamespace(namespaces);
            }
        }
    }

    /**
     * Collects/processes Binding attributes from the node, and then removes them from the node.
     */
    private QNameMap<BindingExpression> processBindingAttributes(Node node)
    {
        QNameMap<BindingExpression> attributeBindings = null;

        for (Iterator<QName> i = node.getAttributeNames(); i != null && i.hasNext();)
        {
            QName qname = i.next();
            String value = (String) node.getAttributeValue(qname);
            
            BindingExpression be = textParser.parseBindingExpression(value, node.beginLine);

            if (be != null)
            {
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
    
    /**
     * Processes @Resource attributes from the node.
     */
    // TODO need to do all sorts of error testing
    //         * e.g. invalid atFunctions
    //         * invalid Resource arguments
    //         * @Resource in CDATA (is this allowed?) (like databinding in CDATA?)
    private void processResourceAttributes(Node node)
    {
        final QNameMap<AtResource> attributeResources = new QNameMap<AtResource>();
        
        for (Iterator i = node.getAttributeNames(); i != null && i.hasNext();)
        {
            final QName qname = (QName)i.next();
            final String text = (String) node.getAttributeValue(qname);

            final String atFunction = TextParser.getAtFunctionName(text);
            if ("Resource".equals(atFunction))
            {
                //TODO I am assuming that this should always be a string type because this is
                //     XML, though @Resources allow things like Embed. I'm right?
                //TODO test an Embed and see what happens?
                final AtResource atResource
                    = (AtResource)textParser.resource(text, typeTable.stringType);
                
                if (atResource != null)
                {                
                    // C: only localPart as the key?
                    attributeResources.put(qname, atResource);
                    
                    // we don't remove these here since we don't want to reorder the attributes
                    // we also don't call addAttribute() to update the map to avoid a potential
                    // ConcurrentModificationException on the iterator
                    //i.remove();
                }
            }
            else if (atFunction != null)
            {
                // if we found an invalid @Function, throw an error
                textParser.desc = atFunction;
                textParser.line = node.beginLine;
                textParser.error(TextParser.ErrUnrecognizedAtFunction, null, null, null);
            }
        }
        
        // now update the definitions in the attribute map
        for(Iterator<QName> iter = attributeResources.keySet().iterator(); iter.hasNext();)
        {
            final QName qname = iter.next();
            final AtResource atResource = attributeResources.get(qname);
            
            // attributes are in a LinkedHashMap, so this just updates the existing mapping
            // with the qname -> AtResource. When Element.toStartElement() is emitting the
            // attribute's value, it will notice the special case of an AtResource object
            // (instead of String) and emit an E4X expression with braces rather than a
            // String with double-quotes. 
            node.addAttribute(qname.getNamespace(), qname.getLocalPart(), atResource, node.beginLine);
        }
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

    public static class RequireXMLContent extends CompilerError
    {
        private static final long serialVersionUID = 6892112465291416940L;

        public RequireXMLContent()
        {
            super();
        }
    }
}
