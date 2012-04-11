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
import flex2.compiler.util.MxmlCommentUtil;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.mxml.MxmlConfiguration;
import flex2.compiler.mxml.dom.*;
import flex2.compiler.mxml.lang.BindingHandler;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.lang.TextParser;
import flex2.compiler.mxml.reflect.Assignable;
import flex2.compiler.mxml.reflect.Property;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.mxml.rep.BindingExpression;
import flex2.compiler.mxml.rep.Model;
import flex2.compiler.mxml.rep.MxmlDocument;
import flex2.compiler.mxml.rep.Primitive;

/*
 * TODO move processPrimitiveEntry logic to ComponentBuilder.analyze(PrimitiveNode), and kill this class
 */
/**
 * This builder handles building a Primitive instance from a primitive
 * Node.  Primitives being a String, Number, int, uint, Boolean,
 * class, or function.
 *
 * @author Clement Wong
 */
class PrimitiveBuilder extends AbstractBuilder
{
    PrimitiveBuilder(CompilationUnit unit, TypeTable typeTable, MxmlConfiguration mxmlConfiguration, MxmlDocument document,
                     Model parent, boolean topLevel, Assignable property, BindingHandler bindingHandler)
    {
        super(unit, typeTable, mxmlConfiguration, document);
        this.parent = parent;
        this.topLevel = topLevel;
        this.bindingHandler = bindingHandler;
        this.property = property;
    }

    protected Model parent;
    protected boolean topLevel;
    protected BindingHandler bindingHandler;
    Primitive value;
    private Assignable property;

    public void analyze(StringNode node)
    {
        processPrimitiveEntry(node);
    }

    public void analyze(NumberNode node)
    {
        processPrimitiveEntry(node);
    }

    public void analyze(IntNode node)
    {
        processPrimitiveEntry(node);
    }

    public void analyze(UIntNode node)
    {
        processPrimitiveEntry(node);
    }

    public void analyze(BooleanNode node)
    {
        processPrimitiveEntry(node);
    }

    public void analyze(ClassNode node)
    {
        processPrimitiveEntry(node);
    }

    public void analyze(FunctionNode node)
    {
        processPrimitiveEntry(node);
    }

    public void analyze(CDATANode node)
    {
        processPrimitiveEntry(node);
    }

    private void processPrimitiveEntry(Node node)
    {
        Type type = nodeTypeResolver.resolveType(node, document);

        Primitive primitive = initPrimitiveValue(type, node);

        CDATANode cdata = null;
        if (node instanceof CDATANode)
            cdata = (CDATANode)node;
        else
            cdata = getTextContent(node.getChildren(), false);

        if (cdata != null)
        {
            processTextInitializer(cdata.image, type, cdata.inCDATA, cdata.beginLine);
        }
        else
        {
            //  NOTE: our scanner gives us identical representations for <tag/> and <tag></tag>. Here is one place where
            //  that's suboptimal for usability. TODO worth doing something about?
            if (!topLevel)
            {
                if (typeTable.stringType.isAssignableTo(type))
                {
                    processTextInitializer("", type, true, node.beginLine);
                }
                else
                {
                    log(node.beginLine, new InitializerRequired());
                }
            }
        }

        processStateAttributes(node, primitive);

        String id = (String)getLanguageAttributeValue(node, StandardDefs.PROP_ID);
        if (id != null || topLevel || primitive.isDeclarationEnsured())
        {
            if (primitive.getValue() != null)
            {
                if(node.comment == null) 
                {
                    node.comment = "";
                }

                // if generate ast if false, lets not scan the tokens here because they will be scanned later in asc scanner. 
                // we will go the velocity template route
                if(!mxmlConfiguration.getGenerateAbstractSyntaxTree())
                {
                    primitive.comment = node.comment;
                }
                else
                {
                    primitive.comment = MxmlCommentUtil.commentToXmlComment(node.comment);   
                }                    
                
                registerModel(id, primitive, topLevel);
            }
            else
            {
                //  Note: primitives are currently the only kind of MXML tag that can be declared without initializing.
                //  TODO still, we should generalize 'register' to include uninitialized declarations
                boolean autogenerated = false;
                if (id == null)
                {
                    //  anon id has been generated
                    autogenerated = true;
                    id = primitive.getId();
                }

                String tempComment = null;
                
                if(node.comment == null) 
                {
                    node.comment = "";
                }

                // if generate ast if false, lets not scan the tokens here because they will be scanned later in asc scanner. 
                // we will go the velocity template route
                if(!mxmlConfiguration.getGenerateAbstractSyntaxTree())
                {
                    tempComment = node.comment;
                }
                else
                {
                    tempComment = MxmlCommentUtil.commentToXmlComment(node.comment);   
                }                    
                
                document.addDeclaration(id, type.getName(), node.beginLine, true, topLevel, autogenerated, primitive.getBindabilityEnsured(), tempComment);
            }
        }
    }

    /**
     *
     */
    private Primitive initPrimitiveValue(Type type, Node node)
    {
        Primitive primitive = new Primitive(document, type, parent, node.beginLine);
        primitive.setInspectable(true);
        if (property != null)
        {
            primitive.setParentIndex(property.getName(), property.getStateName());
        }
        value = primitive;
        return primitive;
    }

    /**
     *
     */
    public void processTextInitializer(String text, Type type, boolean cdata, int line)
    {
        int flags = cdata ? TextParser.FlagInCDATA : 0;
        
        if (property != null && property instanceof Property)
        {
            if (((Property)property).richTextContent())
            {
                flags = flags | TextParser.FlagRichTextContent;
            }
        }

        Object result = textParser.parseValue(text, type, flags, line, NameFormatter.toDot(type.getName()));

        if (result != null)
        {
            /**
             * Note: we've already set up a Primitive to receive parsed value
             * or function as binding dest.
             */
            if (result instanceof BindingExpression)
            {
                if (bindingHandler != null)
                {
                    bindingHandler.invoke((BindingExpression)result, value);
                }
                else
                {
                    log(new BindingNotAllowed());
                }
            }

            value.setValue(result);
        }
    }

    public static class InitializerRequired extends CompilerError
    {

        private static final long serialVersionUID = -3741993271908572909L;
    }
}
