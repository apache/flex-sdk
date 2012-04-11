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
import flex2.compiler.SymbolTable;
import flex2.compiler.mxml.MxmlConfiguration;
import flex2.compiler.mxml.dom.CDATANode;
import flex2.compiler.mxml.dom.Node;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.rep.*;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.QName;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import macromedia.asc.util.IntegerPool;

/*
 * TODO port to new setup
 * TODO the primitive-with-properties thing doesn't work in AVM+. Blocked in codegen but must error here also.
 */
/**
 * This builder contains code common to ModelBuilder and
 * ServiceRequestBuilder.
 *
 * @author Matt Chotin
 */
abstract class AnonymousObjectGraphBuilder extends AbstractBuilder
{
    AnonymousObjectGraph graph;
    /* Are nodes allow to have two-way inline bind expressions? */
    private boolean allowTwoWayBind = true;

    AnonymousObjectGraphBuilder(CompilationUnit unit, TypeTable typeTable, MxmlConfiguration mxmlConfiguration, MxmlDocument document)
    {
        super(unit, typeTable, mxmlConfiguration, document);
    }

    private Object processNode(Node node)
    {
        if (node.getChildCount() == 1 && node.getChildAt(0) instanceof CDATANode)
        {
            CDATANode cdata = (CDATANode)node.getChildAt(0);
            if (cdata.image.length() > 0)
            {
				Object value = textParser.parseValue(cdata.image, typeTable.objectType, 0,
						cdata.beginLine, NameFormatter.toDot(graph.getType().getName()));

				if (value instanceof BindingExpression)
				{
				    BindingExpression be = (BindingExpression) value;
				    if (!allowTwoWayBind && be.isTwoWayPrimary())
				    {
	                    log(cdata, new TwoWayBindingNotAllowed());
	                    return null;				        
				    }
				    else if (hasAttributeInitializers(node))
                    {
                        log(cdata, new HasAttributeInitializers());
                        return null;
                    }
                    else
                    {
                        return value;
                    }
                }
                else
                {
                    boolean isPrimitive = (value instanceof String) || (value instanceof Number) || (value instanceof Boolean);
                    if (node.getAttributeCount() > 0 && isPrimitive)
                    {
                        //turn it into a Primitive with properties
                        Primitive p = new Primitive(document, getPrimitiveType(typeTable, value), value, cdata.beginLine);
                        for (Iterator i = node.getAttributeNames(); i.hasNext();)
                        {
                            QName propName = (QName)i.next();
                            p.setProperty(propName.getLocalPart(), node.getAttributeValue(propName), node.getLineNumber(propName));
                        }
                        value = p;
                    }
                    return value;
                }
            }
            else
            {
                // do nothing if the cdata node has nothing...
                return null;
            }
        }
        else
        {
            Model model = new Model(document, graph.getType(), node.beginLine);
            model.setId(node.getLocalPart(), false);
            model.setIsAnonymous(true);

            processAttributes(node, model);
            processChildren(node, model);

            return model;
        }
    }

    protected void processChildren(Node node, Model parent)
    {
        Map<String, Array> arrays = createArrays(parent, countChildren(node));

        for (int i = 0, count = node.getChildCount(); i < count; i++)
        {
            Node child = (Node)node.getChildAt(i);
            if (child instanceof CDATANode)
            {
                // C: ignore CDATANode if other XML elements exist...
                log(child, new IgnoringCDATA(child.image));
                continue;
            }

            String namespaceURI = child.getNamespace();
            String localPart = child.getLocalPart();

            // C: move this check to Grammar.jj or SyntaxAnalyzer
            if (SymbolTable.OBJECT.equals(localPart) && namespaceURI.length() == 0)
            {
                log(child, new ObjectTag());
                continue;
            }

            Object value = processNode(child);

            if (value == null)
            {
                //	continue;
            }
            else if (arrays.containsKey(localPart))
            {
                Array arrayVal = arrays.get(localPart);
                if (value instanceof BindingExpression)
                {
                    BindingExpression bexpr = (BindingExpression)value;
                    bexpr.setDestination(arrayVal);
                    bexpr.setDestinationProperty(arrayVal.size());
                    bexpr.setDestinationLValue(Integer.toString(arrayVal.size()));
                }
                else if (value instanceof Model)
                {
                    Model valueModel = (Model)value;
                    valueModel.setParent(arrayVal);
                    valueModel.setParentIndex(arrayVal.size());
                }

                arrayVal.addEntry(value, child.beginLine);
            }
            else
            {
                if (value instanceof BindingExpression)
                {
                    BindingExpression bexpr = (BindingExpression)value;
                    bexpr.setDestination(parent);
                    bexpr.setDestinationProperty(localPart);
                    bexpr.setDestinationLValue(localPart);
                }
                else if (value instanceof Model)
                {
                    Model valueModel = (Model)value;
                    valueModel.setParent(parent);
                }

                parent.setProperty(localPart, value, child.beginLine);
            }
        }

        for (int i = 0, count = node.getChildCount(); i < count; i++)
        {
            Node child = (Node)node.getChildAt(i);
            if (child instanceof CDATANode)
            {
                continue;
            }

            String namespaceURI = child.getNamespace();
            String localPart = child.getLocalPart();
            if (SymbolTable.OBJECT.equals(localPart) && namespaceURI.length() == 0)
            {
                continue;
            }

            if (arrays.containsKey(localPart))
            {
                Array arrayVal = arrays.get(localPart);
                parent.setProperty(localPart, arrayVal);
            }
        }
    }

    private void processAttributes(Node node, Model model)
    {
        for (Iterator i = node.getAttributeNames(); i != null && i.hasNext();)
        {
            QName qname = (QName)i.next();
			String text = (String)node.getAttributeValue(qname);
            String localPart = qname.getLocalPart();
			int line = node.getLineNumber(qname);

            processDynamicPropertyText(localPart, text, AbstractBuilder.TextOrigin.FROM_ATTRIBUTE, line, model, null);
        }
    }

    private Map<String, Integer> countChildren(Node node)
    {
        Map<String, Integer> counts = new HashMap<String, Integer>();

        for (Iterator i = node.getAttributeNames(); i != null && i.hasNext();)
        {
            QName qname = (QName)i.next();

            String namespaceURI = qname.getNamespace();
            String localPart = qname.getLocalPart();
            if (SymbolTable.OBJECT.equals(localPart) && namespaceURI.length() == 0)
            {
                continue;
            }

            if (!counts.containsKey(localPart))
            {
                counts.put(localPart, IntegerPool.getNumber(1));
            }
            else
            {
                int count = counts.get(localPart).intValue() + 1;
                counts.put(localPart, IntegerPool.getNumber(count));
            }
        }

        for (int i = 0, count = node.getChildCount(); i < count; i++)
        {
            Node child = (Node)node.getChildAt(i);
            if (child instanceof CDATANode)
            {
                continue;
            }

            String namespaceURI = child.getNamespace();
            String localPart = child.getLocalPart();

            if (SymbolTable.OBJECT.equals(localPart) && namespaceURI.length() == 0)
            {
                continue;
            }

            if (!counts.containsKey(localPart))
            {
                counts.put(localPart, IntegerPool.getNumber(1));
            }
            else
            {
                int num = counts.get(localPart).intValue() + 1;
                counts.put(localPart, IntegerPool.getNumber(num));
            }
        }

        return counts;
    }

    private Map<String, Array> createArrays(Model parent, Map<String, Integer> counts)
    {
        Map<String, Array> arrays = new HashMap<String, Array>();

        for (Iterator<String> i = counts.keySet().iterator(); i.hasNext();)
        {
            String localPart = i.next();

            if (counts.get(localPart).intValue() > 1)
            {
                Array a = new Array(document, parent, parent.getXmlLineNumber(), typeTable.objectType);
                a.setId(localPart, false);
                a.setIsAnonymous(true);

                // prepopulate with any properties definied as attributes
                if (parent.hasProperty(localPart))
                {
					a.addEntry(parent.getProperty(localPart), parent.getXmlLineNumber());
                }

                arrays.put(localPart, a);
            }
        }

        return arrays;
    }

	/**
	 * map some java types into AS
	 * TODO should go away once we use Primitive universally
	 */
	private static Type getPrimitiveType(TypeTable typeTable, Object o)
	{
		return (o instanceof Boolean) ? typeTable.booleanType :
				(o instanceof Number) ? typeTable.numberType :
                typeTable.stringType;
	}

	public static class HasAttributeInitializers extends CompilerError
	{

        private static final long serialVersionUID = 2742129880173923426L;
	}

    public static class IgnoringCDATA extends CompilerWarning
    {
        private static final long serialVersionUID = -1934672020085831809L;
        public String image;

        public IgnoringCDATA(String image)
        {
            this.image = image;
        }
    }

    public static class ObjectTag extends CompilerError
    {
        private static final long serialVersionUID = 5342534491716831705L;
    }

    protected void setAllowTwoWayBind(boolean allowTwoWayBind)
    {
        this.allowTwoWayBind = allowTwoWayBind;
    }
}
