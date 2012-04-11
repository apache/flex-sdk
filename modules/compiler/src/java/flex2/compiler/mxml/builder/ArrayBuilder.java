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
import flex2.compiler.mxml.MxmlConfiguration;
import flex2.compiler.mxml.dom.*;
import flex2.compiler.mxml.lang.BindingHandler;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.lang.TextParser;
import flex2.compiler.mxml.lang.ValueNodeHandler;
import flex2.compiler.mxml.reflect.Assignable;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.mxml.rep.Array;
import flex2.compiler.mxml.rep.BindingExpression;
import flex2.compiler.mxml.rep.Model;
import flex2.compiler.mxml.rep.MxmlDocument;
import flex2.compiler.util.NameFormatter;

import java.util.Collection;
import java.util.Iterator;

/**
 * This builder handles building an Array instance from an ArrayNode
 * and it's children.
 *
 * @author Clement Wong
 */
class ArrayBuilder extends AbstractBuilder
{
	ArrayBuilder(CompilationUnit unit, TypeTable typeTable, MxmlConfiguration mxmlConfiguration, MxmlDocument document)
	{
		this(unit, typeTable, mxmlConfiguration, document, null, null, true);
	}

	ArrayBuilder(CompilationUnit unit, TypeTable typeTable, MxmlConfiguration mxmlConfiguration, MxmlDocument document,
				 Model parent, Assignable assignable, boolean allowBinding)
	{
		super(unit, typeTable, mxmlConfiguration, document);
		this.parent = parent;
		this.assignable = assignable;
		this.allowBinding = allowBinding;
	}

	private ElementNodeHandler elementNodeHandler = new ElementNodeHandler();
	private ElementBindingHandler elementBindingHandler = new ElementBindingHandler();

	private Model parent;
	private Assignable assignable;
	private boolean allowBinding;
	Array array;

	public void analyze(ArrayNode node)
	{
		createArrayModel(node.beginLine);
		processStateAttributes(node, array);
		ensureId(node);
		processChildren(node.getChildren());
		registerModel(node, array, parent == null);
	}

	/*
	 * TODO should take array element type and use when processing text initializer, etc.
	 */
	public void createArrayModel(int line)
	{
		array = new Array(document, parent, line, getElementType());
        array.setParentIndex(getName(), getStateName());
	}

	/**
	 *
	 */
	void createSyntheticArrayModel(int line)
	{
		createArrayModel(line);
	}
	
	/**
	 * 
	 */
    private void ensureId(ArrayNode node)
    {
    	String id = (String) getLanguageAttributeValue(node, StandardDefs.PROP_ID);
    	if (id != null)
            array.setId(id, false);
    }
    
	/**
	 *
	 */
	void processChildren(Collection nodes)
	{
		CDATANode cdata = getTextContent(nodes, true);
		if (cdata != null)
		{
			processTextInitializer(cdata.image, typeTable.objectType, cdata.inCDATA, cdata.beginLine);
		}
		else
		{
			for (Iterator iter = nodes.iterator(); iter.hasNext(); )
			{
				elementNodeHandler.invoke(assignable, (Node)iter.next(), document);
			}
		}
	}

    private String getName()
    {
        return assignable != null ? assignable.getName() : null;
    }

    private String getStateName()
    {
        return assignable != null ? assignable.getStateName() : null;
    }

    private Type getElementType()
    {
        return assignable != null ? assignable.getElementType() :  typeTable.objectType;
    }

	/**
	 *
	 */
	protected class ElementNodeHandler extends ValueNodeHandler
	{
		protected void componentNode(Assignable property, Node node, MxmlDocument document)
		{
			ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, document, array, null, null, false, elementBindingHandler);
			node.analyze(builder);
			builder.component.setParentIndex(array.size());
			array.addEntry(builder.component);
		}

		protected void arrayNode(Assignable property, ArrayNode node)
		{
			ArrayBuilder builder = new ArrayBuilder(unit, typeTable, mxmlConfiguration, document, array, null, allowBinding);
			node.analyze(builder);
			builder.array.setParentIndex(array.size());
			array.addEntry(builder.array);
		}

        protected void vectorNode(Assignable property, VectorNode node)
        {
            String typeAttributeValue = (String) node.getAttribute(StandardDefs.PROP_TYPE).getValue();
            Type elementType = typeTable.getType(NameFormatter.toColon(typeAttributeValue));
            VectorBuilder builder = new VectorBuilder(unit, typeTable, mxmlConfiguration, document,
                                                      array, null, elementType, allowBinding);
            node.analyze(builder);
            builder.vector.setParentIndex(array.size());
            array.addEntry(builder.vector);
        }

		protected void primitiveNode(Assignable property, PrimitiveNode node)
		{
			PrimitiveBuilder builder = new PrimitiveBuilder(unit, typeTable, mxmlConfiguration, document, array, false, property, elementBindingHandler);
			node.analyze(builder);
			array.addEntry(builder.value);
		}

		protected void xmlNode(Assignable property, XMLNode node)
		{
			//	TODO why not support XML nodes as array elements?
			log(node, new ElementNotSupported(node.image));
		}
        
        protected void xmlListNode(Assignable property, XMLListNode node)
        {
            //  TODO why not support XMLLists nodes as array elements?
            log(node, new ElementNotSupported(node.image));
        }

		protected void modelNode(Assignable property, ModelNode node)
		{
			//	TODO why not support Model nodes as array elements?
			log(node, new ElementNotSupported(node.image));
		}

		protected void inlineComponentNode(Assignable property, InlineComponentNode node)
		{
			InlineComponentBuilder builder = new InlineComponentBuilder(unit, typeTable, mxmlConfiguration, document, false);
			node.analyze(builder);
			array.addEntry(builder.getRValue());
		}

		protected void reparentNode(Assignable property, ReparentNode node)
        {
            ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, document, array, null, null, false, null);
            node.analyze(builder);
            builder.component.setParentIndex(array.size());
            array.addEntry(builder.component);
        }

        protected void cdataNode(Assignable property, CDATANode node)
        {
            PrimitiveBuilder builder = new PrimitiveBuilder(unit, typeTable, mxmlConfiguration, document, array, false, property, elementBindingHandler);
            node.analyze(builder);
            array.addEntry(builder.value);
        }

        protected void stateNode(Assignable property, StateNode node)
        {
            ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, document, array, null, null, false, null);
            node.analyze(builder);
            builder.component.setParentIndex(array.size());
            array.addEntry(builder.component);
        }
        
		protected void unknown(Assignable property, Node node)
		{
			log(node, new UnknownNode(node.image));
		}
	}

	/**
	 *
	 */
	public void processTextInitializer(String text, Type arrayElementType, boolean cdata, int line)
	{
		int flags = cdata ? TextParser.FlagInCDATA : 0;
		Object result = textParser.parseValue(text, typeTable.arrayType, arrayElementType, flags, line, typeTable.arrayType.getName());

		if (result != null)
		{
			if (result instanceof BindingExpression)
			{
				if (allowBinding)
				{
					BindingExpression bindingExpression = (BindingExpression)result;
					if (parent != null)
					{
						bindingExpression.setDestination(parent);
					}
					else
					{
						bindingExpression.setDestination(array);
					}

					bindingExpression.setDestinationLValue(getName());
					bindingExpression.setDestinationProperty(getName());
				}
				else
				{
					log(line, new BindingNotAllowed());
				}
			}
			else
			{
				//	TODO for symmetry's sake, allow <Array>[a,b,c]</Array>. (Used to error.) Can yank.
				assert result instanceof Array;
				array.setEntries(((Array)result).getEntries());
			}
		}
	}

	/**
	 * Note that we don't mind if dest == null. See comments in PrimitiveBuilder
	 */
	protected class ElementBindingHandler implements BindingHandler
	{
		public BindingExpression invoke(BindingExpression bindingExpression, Model dest)
		{
			bindingExpression.setDestination(array);
			bindingExpression.setDestinationLValue(Integer.toString(array.size()));
			bindingExpression.setDestinationProperty(array.size());
			return bindingExpression;
		}
	}

    public static class ElementNotSupported extends CompilerError
    {
        private static final long serialVersionUID = 8466102389418978639L;
        public String image;

        public ElementNotSupported(String image)
        {
            this.image = image;
        }
    }

    public static class UnknownNode extends CompilerError
    {
        private static final long serialVersionUID = -3924881722877853113L;
        public String image;

        public UnknownNode(String image)
        {
            this.image = image;
        }
    }
}
