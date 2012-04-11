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
import flex2.compiler.SymbolTable;
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
import flex2.compiler.mxml.rep.Vector;
import flex2.compiler.mxml.rep.BindingExpression;
import flex2.compiler.mxml.rep.Model;
import flex2.compiler.mxml.rep.MxmlDocument;
import flex2.compiler.util.NameFormatter;

import java.util.Collection;
import java.util.Iterator;

/**
 * This builder handles building an Vector instance from an VectorNode
 * and it's children.
 *
 * @author Paul Reilly
 */
class VectorBuilder extends AbstractBuilder
{
    
    VectorBuilder(CompilationUnit unit, TypeTable typeTable, MxmlConfiguration mxmlConfiguration,
            MxmlDocument document, Model parent, Assignable assignable,
            Type elementType, boolean allowBinding)
    {
      this(unit, typeTable, mxmlConfiguration, document, parent, assignable, allowBinding);
      this.elementType = elementType;
    }
    
    VectorBuilder(CompilationUnit unit, TypeTable typeTable, MxmlConfiguration mxmlConfiguration,
                MxmlDocument document, Model parent, Assignable assignable, boolean allowBinding)
    {
      super(unit, typeTable, mxmlConfiguration, document);
      this.parent = parent;
      this.assignableProperty = assignable;
      this.allowBinding = allowBinding;
    }

    private ElementNodeHandler elementNodeHandler = new ElementNodeHandler();
    private ElementBindingHandler elementBindingHandler = new ElementBindingHandler();

    private Type elementType;
    private Model parent;
    private Assignable assignableProperty;
    private boolean allowBinding;
    Vector vector;

    private static final int FLAGS = (TextParser.FlagIgnoreArraySyntax |
                                      TextParser.FlagIgnoreAtFunction |
                                      TextParser.FlagIgnoreAtFunctionEscape);

    public void analyze(VectorNode node)
    {
        boolean fixed = false;
        String fixedAttribute = (String) getLanguageAttributeValue(node, StandardDefs.PROP_FIXED);

        if (fixedAttribute != null)
        {
            Object fixedObject = textParser.parseValue(fixedAttribute, typeTable.booleanType, FLAGS,
                                                       node.beginLine, StandardDefs.PROP_FIXED);

            if (fixedObject instanceof BindingExpression)
            {
                log(node.beginLine, new BindingNotAllowed());
            }
            else if (fixedObject != null)
            {
                fixed = (Boolean) fixedObject;
            }
        }

        createVectorModel(node.beginLine, fixed);
        processStateAttributes(node, vector);
        ensureId(node);
        processChildren(node.getChildren());
        registerModel(node, vector, parent == null);
    }

    /*
     * TODO should take vector element type and use when processing text initializer, etc.
     */
    public void createVectorModel(int line, boolean fixed)
    {
        vector = new Vector(document, parent, line, getElementType(), fixed);
        vector.setParentIndex(getName(), getStateName());
    }

    /**
     *
     */
    void createSyntheticVectorModel(int line)
    {
        createVectorModel(line, false);
    }

    /**
     *
     */
    private void ensureId(VectorNode node)
    {
        String id = (String) getLanguageAttributeValue(node, StandardDefs.PROP_ID);
        if (id != null)
            vector.setId(id, false);
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
                elementNodeHandler.invoke(assignableProperty, (Node)iter.next(), document);
            }
        }
    }

    private String getName()
    {
        return assignableProperty != null ? assignableProperty.getName() : null;
    }

    private String getStateName()
    {
        return assignableProperty != null ? assignableProperty.getStateName() : null;
    }

    private Type getElementType()
    {
        if (elementType != null)
            return elementType;
        else
            return assignableProperty != null ? assignableProperty.getElementType() : null;
    }

    /**
     *
     */
    protected class ElementNodeHandler extends ValueNodeHandler
    {
        protected void componentNode(Assignable property, Node node, MxmlDocument document)
        {
            ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, document, vector, null, null, false, elementBindingHandler);
            node.analyze(builder);

            if (builder.component.getType().isAssignableTo(getElementType()))
            {
                builder.component.setParentIndex(vector.size());
                vector.addEntry(builder.component);
            }
            else
            {
                log(node, new WrongElementType(getElementType().getName()));
            }
        }

        protected void arrayNode(Assignable property, ArrayNode node)
        {
            ArrayBuilder builder = new ArrayBuilder(unit, typeTable, mxmlConfiguration, document, vector, null, allowBinding);
            node.analyze(builder);

            if (builder.array.getType().isAssignableTo(getElementType()))
            {
                builder.array.setParentIndex(vector.size());
                vector.addEntry(builder.array);
            }
            else
            {
                log(node, new WrongElementType(getElementType().getName()));
            }
        }

        protected void vectorNode(Assignable property, VectorNode node)
        {
            String typeAttributeValue = (String) node.getAttribute(StandardDefs.PROP_TYPE).getValue();
            Type elementType = typeTable.getType(NameFormatter.toColon(typeAttributeValue));
            VectorBuilder builder = new VectorBuilder(unit, typeTable, mxmlConfiguration, document,
                    vector, null, elementType, allowBinding);
            node.analyze(builder);

            if (builder.vector.getType().isAssignableTo(getElementType()))
            {
                builder.vector.setParentIndex(vector.size());
                vector.addEntry(builder.vector);
            }
            else
            {
                log(node, new WrongElementType(getElementType().getName()));
            }
        }

        protected void primitiveNode(Assignable property, PrimitiveNode node)
        {
            PrimitiveBuilder builder = new PrimitiveBuilder(unit, typeTable, mxmlConfiguration, document, vector, false, null, elementBindingHandler);
            node.analyze(builder);

            if (builder.value.getType().isAssignableTo(getElementType()))
            {
                vector.addEntry(builder.value);
            }
            else
            {
                log(node, new WrongElementType(getElementType().getName()));
            }
        }

        protected void xmlNode(Assignable property, XMLNode node)
        {
            //    TODO why not support XML nodes as vector elements?
            log(node, new ElementNotSupported(node.image));
        }

        protected void xmlListNode(Assignable property, XMLListNode node)
        {
            //  TODO why not support XMLLists nodes as vector elements?
            log(node, new ElementNotSupported(node.image));
        }

        protected void modelNode(Assignable property, ModelNode node)
        {
            //    TODO why not support Model nodes as vector elements?
            log(node, new ElementNotSupported(node.image));
        }

        protected void inlineComponentNode(Assignable property, InlineComponentNode node)
        {
            InlineComponentBuilder builder = new InlineComponentBuilder(unit, typeTable, mxmlConfiguration, document, false);
            node.analyze(builder);

            if (builder.getRValue().getType().isAssignableTo(getElementType()))
            {
                vector.addEntry(builder.getRValue());
            }
            else
            {
                log(node, new WrongElementType(getElementType().getName()));
            }
        }

        protected void reparentNode(Assignable property, ReparentNode node)
        {
            ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, document, vector, null, null, false, null);
            node.analyze(builder);

            if (builder.component.getType().isAssignableTo(getElementType()))
            {
                builder.component.setParentIndex(vector.size());
                vector.addEntry(builder.component);
            }
            else
            {
                log(node, new WrongElementType(getElementType().getName()));
            }
        }

        protected void cdataNode(Assignable property, CDATANode node)
        {
            PrimitiveBuilder builder = new PrimitiveBuilder(unit, typeTable, mxmlConfiguration, document, vector, false, null, elementBindingHandler);
            node.analyze(builder);

            if (builder.value.getType().isAssignableTo(getElementType()))
            {
                vector.addEntry(builder.value);
            }
            else
            {
                log(node, new WrongElementType(getElementType().getName()));
            }
        }

        protected void stateNode(Assignable property, StateNode node)
        {
            ComponentBuilder builder = new ComponentBuilder(unit, typeTable, mxmlConfiguration, document, vector, null, null, false, null);
            node.analyze(builder);

            if (builder.component.getType().isAssignableTo(getElementType()))
            {
                builder.component.setParentIndex(vector.size());
                vector.addEntry(builder.component);
            }
            else
            {
                log(node, new WrongElementType(getElementType().getName()));
            }
        }

        protected void unknown(Assignable property, Node node)
        {
            log(node, new UnknownNode(node.image));
        }
    }

    /**
     *
     */
    public void processTextInitializer(String text, Type vectorElementType, boolean cdata, int line)
    {
        int flags = cdata ? TextParser.FlagInCDATA : 0;
        Type vectorType = typeTable.getVectorType(vectorElementType);
        Object result = textParser.parseValue(text, vectorType, vectorElementType, flags, line, SymbolTable.VECTOR);

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
                        bindingExpression.setDestination(vector);
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
                //    TODO for symmetry's sake, allow <Vector>[a,b,c]</Vector>. (Used to error.) Can yank.
                assert result instanceof Vector;
                vector.setEntries(((Vector)result).getEntries());
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
            bindingExpression.setDestination(vector);
            bindingExpression.setDestinationLValue(Integer.toString(vector.size()));
            bindingExpression.setDestinationProperty(vector.size());
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

    public static class WrongElementType extends CompilerError
    {
        private static final long serialVersionUID = -3924881723877853113L;
        public String elementTypeName;

        public WrongElementType(String elementTypeName)
        {
            this.elementTypeName = elementTypeName;
        }
    }
}
