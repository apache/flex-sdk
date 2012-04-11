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

package flex2.compiler.mxml.rep.init;

import static macromedia.asc.parser.Tokens.ASSIGN_TOKEN;
import static macromedia.asc.parser.Tokens.CONST_TOKEN;
import flash.util.StringUtils;
import flex2.compiler.as3.AbstractSyntaxTreeUtil;
import flex2.compiler.mxml.ImplementationGenerator;
import flex2.compiler.mxml.gen.CodeFragmentList;
import flex2.compiler.mxml.gen.DescriptorGenerator;
import flex2.compiler.mxml.gen.TextGen;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.reflect.TypeTable;
import flex2.compiler.mxml.rep.*;
import flex2.compiler.util.IteratorList;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.compiler.util.CompilerMessage;
import macromedia.asc.parser.*;
import macromedia.asc.util.Context;
import org.apache.commons.collections.iterators.SingletonIterator;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * This class represents a general rvalue initializer.  Subclasses
 * handle codegen variations for different lvalues.
 */
/*
 * TODO this logic is complicated a bit by the fact that some legacy builders upstream are still using POJOs
 * as their initializer rvalues. Once those have all been ported to use (at least) Primitives, all the
 * "if (value instanceof Model)" scaffolding can be removed. At that point it would also make sense to move
 * from a subclasses-of-Model approach (another remaining bit of legacy) to an explicit-discriminant approach.
 */
public abstract class ValueInitializer implements Initializer, Cloneable
{
	private static final String INT = "int";
	private static final String ARRAY = "Array";
	private static final String NULL = "null";
	private static final String THIS = "this";
    private static final String DOT = ".";

    // intern all identifier constants
    private static final String NEW_VALUE = "newValue".intern();
    private static final String OLD_VALUE = "oldValue".intern();
    private static final String PROPERTY = "property".intern();
    private static final String OBJECT = "Object".intern();
    private static final String SOURCE = "source".intern();
    private static final String ADD_LAYER = "addLayer".intern();
    private static final String BINDING_MANAGER = "BindingManager".intern();
    private static final String CD = "cd".intern();
    private static final String CHILD_DESCRIPTORS = "childDescriptors".intern();
    private static final String CLASS = "Class".intern();
    private static final String CREATE_XML_DOCUMENT = "createXMLDocument".intern();
    private static final String DEFERRED_INSTANCE_FROM_CLASS = "DeferredInstanceFromClass".intern();
    private static final String DEFERRED_INSTANCE_FROM_FUNCTION = "DeferredInstanceFromFunction".intern();
    private static final String DESIGN_LAYER = "designLayer".intern();
    private static final String DISPATCH_EVENT = "dispatchEvent".intern();
    private static final String DOCUMENT = "document".intern();
    private static final String EXECUTE_BINDINGS = "executeBindings".intern();
    private static final String EVENT = "Event".intern();
    private static final String FIRST_CHILD = "firstChild".intern();
    private static final String GET_DEFINITION_BY_NAME = "getDefinitionByName".intern();
    private static final String I = "i".intern();
    private static final String ID = "id".intern();
    private static final String INITIALIZE = "initialize".intern();
    private static final String INITIALIZED = "initialized".intern();
    private static final String LENGTH = "length".intern();
    private static final String MX_INTERNAL = "mx_internal".intern();
    private static final String REGISTER_EFFECTS = "registerEffects".intern();
    private static final String TEMP = "temp".intern();
    private static final String UNDEFINED = "undefined".intern();
    private static final String XML_UTIL = "XMLUtil".intern();
    private static final String _DOCUMENT_DESCRIPTOR = "_documentDescriptor".intern();
    private static final String __CLASS = "__class".intern();
    private static final String __E = "__e".intern();

    protected final StandardDefs standardDefs;
    protected Object value;
	protected final int line;
	protected boolean stateSpecific;

	ValueInitializer(Object value, int line, StandardDefs defs)
	{
        this.value = value;
        this.line = line;
        this.stateSpecific = false;
        this.standardDefs = defs;
        setValue(value);
	}

	public Object getValue()
	{
		return value;
	}
	
	public void setValue(Object value)
	{
		this.value = value;
		
		if (value instanceof Model)
        {
            // Assume the current ValueInitializer instance is state specific
            // if the rvalue is itself state specific.
            this.stateSpecific = ((Model)value).isStateSpecific();
        } 
	}

	//	Initializer impl

	public int getLineRef()
	{
		return line;
	}

	public boolean isBinding()
	{
		return value instanceof BindingExpression || (value instanceof Primitive && ((Primitive)value).hasBindings());
	}
	
	public boolean isDesignLayer()
	{
		return value instanceof DesignLayer;
	}
	
	public boolean isStateSpecific()
	{
		return stateSpecific;
	}
	
	public void setStateSpecific(boolean value)
	{
		stateSpecific = value;
	}

	/**
	 *
	 */
	public boolean hasDefinition()
	{
		if (value instanceof Model)
		{
			Model model = (Model)value;
			return model.isDeclared() || !modelHasInlineRValue() || isInstanceGeneratorOverDefinition();
		}
		else
		{
			assert isBinding() || !standardDefs.isInstanceGenerator(getLValueType())
					: "instance generator lvalue has non-Model, non-BindingExpression rvalue (" + value.getClass() + ")";
			return false;
		}
	}

	/**
	 * note the exception for simple classdef-based deferrals
	 */
	protected boolean isInstanceGeneratorOverDefinition()
	{
		Type ltype = getLValueType();
		return standardDefs.isIFactory(ltype) || (standardDefs.isIDeferredInstance(ltype) && !rvalueIsClassRef());
	}

	/**
	 * TODO replace with actual ClassRef subclass of Model or Primitive
	 */
	protected boolean rvalueIsClassRef()
	{
		return value instanceof Primitive && ((Primitive)value).getType().equals(getTypeTable().classType);
	}

	/**
	 *
	 */
	public String getValueExpr()
	{
		Type lvalueType = getLValueType();

		if (standardDefs.isIDeferredInstance(lvalueType))
		{
			if (rvalueIsClassRef())
			{
				return "new " + NameFormatter.toDot(standardDefs.CLASS_DEFERREDINSTANCEFROMCLASS) + "(" + getInlineRValue() + ")";
			}
			else
			{
				return "new " + NameFormatter.toDot(standardDefs.CLASS_DEFERREDINSTANCEFROMFUNCTION) + "(" + getDefinitionName() + 
				    (standardDefs.isITransientDeferredInstance(lvalueType) ? "," + ((Model)value).getDefinitionName() + "_r" : "") + ")"; 
			}
		}
		else
		{
			return hasDefinition() ? getDefinitionName() + "()" : getInlineRValue();
		}
	}

	/**
	 *
	 */
	public Node generateValueExpr(NodeFactory nodeFactory, HashSet<String> configNamespaces,
                                  boolean generateDocComments)
	{
		Node result;
		Type lvalueType = getLValueType();

		if (standardDefs.isIDeferredInstance(lvalueType))
		{
			IdentifierNode typeIdentifier;
			ArgumentListNode args;

			if (rvalueIsClassRef())
			{
				typeIdentifier = AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory,
																					standardDefs.getCorePackage(),
																					DEFERRED_INSTANCE_FROM_CLASS,
                                                                                    false);
                Node inlineRValue = generateInlineRValue(nodeFactory, configNamespaces, generateDocComments);
				args = nodeFactory.argumentList(null, inlineRValue);
			}
			else
			{
				typeIdentifier = AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory,
																					standardDefs.getCorePackage(),
																					DEFERRED_INSTANCE_FROM_FUNCTION,
                                                                                    false);
				IdentifierNode identifier =
                    AbstractSyntaxTreeUtil.generateIdentifier(nodeFactory, getDefinitionName(), true);
				args = nodeFactory.argumentList(null, identifier);
				
				if (standardDefs.isITransientDeferredInstance(lvalueType))
				{
					identifier = AbstractSyntaxTreeUtil.generateIdentifier(nodeFactory, ((Model)value).getDefinitionName() + "_r", true);
					args = nodeFactory.argumentList(args, identifier);
				}
			}

			CallExpressionNode callExpression =
				(CallExpressionNode) nodeFactory.callExpression(typeIdentifier, args);
			callExpression.is_new = true;
			callExpression.setRValue(false);
			result = nodeFactory.memberExpression(null, callExpression);
		}
		else if (hasDefinition())
		{
			IdentifierNode identifier =
                AbstractSyntaxTreeUtil.generateIdentifier(nodeFactory, getDefinitionName(), true);
			CallExpressionNode callExpression =
				(CallExpressionNode) nodeFactory.callExpression(identifier, null);
			callExpression.setRValue(false);
			result = nodeFactory.memberExpression(null, callExpression);
		}
		else
		{
			return generateInlineRValue(nodeFactory, configNamespaces, generateDocComments);
		}

		return result;
	}
	
    /**
     *
     */
    protected boolean modelHasInlineRValue()
    {
        boolean result = false;
        assert value instanceof Model;
        Model model = (Model) value;

        if (model instanceof Vector)
        {
            Vector vector = (Vector) model;

            if (!vector.isFixed())
            {
                result = true;
            }
        }
        else if (model instanceof XML ||
                 model instanceof XMLList ||
                 model instanceof Primitive ||
                 model instanceof Array ||
                 model.getType().equals(getTypeTable().objectType))
        {
            result = true;
        }

        return result;
    }

	/**
	 *
	 */
	private String getInlineRValue()
	{
		if (value instanceof Model)
		{
			if (value instanceof Primitive)
			{
				Primitive primitive = (Primitive)value;
				return formatExpr(primitive.getType(), primitive.getValue());
			}
			else if (value instanceof Vector)
			{
				return asVectorLiteral((Vector) value);
			}
			else if (value instanceof Array)
			{
				return asArrayLiteral((Array)value);
			}
			else if (value instanceof XML)
			{
				XML xml = (XML)value;
				return asXmlLiteral(xml);
			}
			else if (value instanceof XMLList)
			{
				return asXMLList((XMLList)value);
			}
			else if (((Model)value).getType().equals(getTypeTable().objectType))
			{
				return asObjectLiteral((Model)value);
			}
			else
			{
				assert false : "can't generate inline expr for values of type " + value.getClass();
				return null;
			}
		}
		else
		{
			return formatExpr(getLValueType(), value);
		}
	}

	private Node generateInlineRValue(NodeFactory nodeFactory, HashSet<String> configNamespaces,
                                      boolean generateDocComments)
	{
		if (value instanceof Model)
		{
			if (value instanceof Primitive)
			{
				Primitive primitive = (Primitive)value;
				return formatExpr(nodeFactory, configNamespaces, generateDocComments,
                                  primitive.getType(), primitive.getValue());
			}
			else if (value instanceof Vector)
			{
				return asVectorLiteral(nodeFactory, configNamespaces, generateDocComments, (Vector) value);
			}
			else if (value instanceof Array)
			{
				return asArrayLiteral(nodeFactory, configNamespaces, generateDocComments, (Array) value);
			}
			else if (value instanceof XML)
			{
				XML xml = (XML)value;
				return asXmlLiteral(nodeFactory, xml);
			}
			else if (value instanceof XMLList)
			{
				return asXMLList(nodeFactory, (XMLList) value);
			}
			else if (((Model)value).getType().equals(getTypeTable().objectType))
			{
				return asObjectLiteral(nodeFactory, configNamespaces, generateDocComments, (Model)value);
			}
			else
			{
				assert false : "can't generate inline expr for values of type " + value.getClass();
				return null;
			}
		}
		else
		{
			return formatExpr(nodeFactory, configNamespaces, generateDocComments, getLValueType(), value);
		}
	}

	/**
	 * Note: the definition function will create and return our rvalue. If the rvalue is declared (i.e. carries an id),
	 * then it will also initialize the declared variable by side effect. Hence the "_init" vs "_create" suffixes.
	 */
	protected String getDefinitionName()
	{
		assert hasDefinition() : "no definition in getDefinitionName()";
		assert value instanceof Model : "non-Model value has definition in getDefinitionName()";

		return ((Model)value).getDefinitionName() + (((Model)value).isDeclared() ? "_i" : "_c");
	}

	/**
	 *
	 */
    protected CodeFragmentList getDefinitionBody()
    {
        assert hasDefinition() : "no definition in getDefinitionBody()";
        assert value instanceof Model : "non-Model value has definition in getDefinitionBody()";

        final String varName = "temp";

        Model self = (Model)value;
        Type selfType = self.getType();
        String selfTypeName;

        if (value instanceof Vector)
        {
            Vector vector = (Vector) value;
            String elementTypeName = vector.getElementTypeName();
            selfTypeName = StandardDefs.CLASS_VECTOR + ".<" + elementTypeName + ">";
        }
        else
        {
            selfTypeName = NameFormatter.toDot(selfType.getName());
        }

        boolean isDeclared = self.isDeclared();
        String id = isDeclared ? self.getId() : varName;

        int line = getLineRef();

        CodeFragmentList list = new CodeFragmentList();

        //  function header
        list.add("private function ", getDefinitionName(), "() : ", selfTypeName, line);
        list.add("{", line);

        //  value creation
        StringBuilder stringBuilder = new StringBuilder("\tvar " + varName + " : " + selfTypeName + " = ");

        if (modelHasInlineRValue())
        {
            stringBuilder.append(getInlineRValue());
        }
        else if (value instanceof Vector)
        {
            Vector vector = (Vector) value;

            stringBuilder.append("new " + selfTypeName + "(" + vector.size());
            
            if (vector.isFixed())
            {
                stringBuilder.append(", true)");
            }
            else
            {
                stringBuilder.append(")");
            }
        }
        else
        {
            // TODO confirm the availability of a 0-arg ctor!! but do it upstream from here, like when Model is built
            stringBuilder.append("new " + selfTypeName + "()");
        }

        stringBuilder.append(";");
        list.add(stringBuilder.toString(), line);

        if (!modelHasInlineRValue())
        {
            if (value instanceof Vector)
            {
                Vector vector = (Vector) value;
                addAssignExprs(list, vector.getElementInitializerIterator(), varName);
            }
            else
            {
                // set properties
                addAssignExprs(list, self.getPropertyInitializerIterator(self.getType().hasDynamic()), varName);
            }
        }
        
        //  set styles
        addAssignExprs(list, self.getStyleInitializerIterator(), varName);

        //  set effects
        addAssignExprs(list, self.getEffectInitializerIterator(), varName);

        //  add event handlers
        addAssignExprs(list, self.getEventInitializerIterator(), varName);

        //  register effect names
        String effectEventNames = self.getEffectNames();
        if (effectEventNames.length() > 0)
        {
            list.add("\t", varName, ".registerEffects([ ", effectEventNames, " ]);", line);
        }

        //  post-init actions for values that are being assigned to properties (via id attribution)
        if (isDeclared && standardDefs.isIUIComponentWithIdProperty(selfType))
        {
            //  set id on IUIComponents that carry an id prop
            list.add("\t", varName, ".id = \"", id, "\";", line);
        }

        // Design layer related items
        if (self.layerParent != null)
        {
            if (self instanceof DesignLayer)
            {
                list.add("\t", self.layerParent.getId(), ".addLayer(", varName, ");", line);
            }
            else if (self.getType().isAssignableTo(standardDefs.INTERFACE_IVISUALELEMENT))
            {
                list.add("\t", varName, ".designLayer = ", self.layerParent.getId(), ";", line);
            }    
        }
        
        //  UIComponent-specific init steps
        if (standardDefs.isIUIComponent(selfType))
        {
            assert self instanceof MovieClip : "isIUIComponent(selfType) but !(self instanceof MovieClip)";
            MovieClip movieClip = (MovieClip) self;

            //  MXML implementations of IUIComponent initialize set their document property to themselves at
            //  construction time. Others need it set to the enclosing document (us).

            list.add("\tif (!", varName, ".document) ", varName, ".document = this;", line);

            //  add visual children
            if (!standardDefs.isRepeater(selfType))
            {
                if (standardDefs.isContainer(selfType))
                {
                    if (movieClip.hasChildren())
                    {
                        list.add("\t", varName, ".mx_internal::_documentDescriptor = ", line);
                        DescriptorGenerator.addDescriptorInitializerFragments(list, movieClip,
                                                                              Collections.<String>emptySet(),
                                                                              false, "\t\t");
                        list.add("\t;", line);
                        list.add("\t", varName, ".mx_internal::_documentDescriptor.document = this;", line);
                    }
                }
                else
                {
                    //  non-repeater - replicate DI child-creation sequence procedurally:
                    Iterator childIter = movieClip.getChildInitializerIterator();

                    while (childIter.hasNext())
                    {
                        VisualChildInitializer init = (VisualChildInitializer)childIter.next();

                        // Filter out state specific children.
                        if ( !((Model)init.getValue()).isStateSpecific())
                        {
                            list.add("\t", init.getAssignExpr(varName), ";", init.getLineRef());
                        }
                    }
                }
            }
            else
            {
                //  repeater-specific init sequence: don't add children directly, instead use existing DI setup
                //  initializing repeater's childDescriptors property, for now

                list.add("\tvar cd:Array = ", varName, ".childDescriptors = [", line);

                for (Iterator childIter = movieClip.children().iterator(); childIter.hasNext(); )
                {
                    VisualChildInitializer init = (VisualChildInitializer)childIter.next();
                    DescriptorGenerator.addDescriptorInitializerFragments(list, (MovieClip)init.getValue(), "\t\t");

                    if (childIter.hasNext())
                    {
                        list.add(",", 0);
                    }
                }

                list.add("\t];", line);
                list.add("\tfor (var i:int = 0; i < cd.length; i++) cd[i].document = this;", line);
            }
        }

        // TODO: Remove [IMXMLObject] metadata support once we have a
        // non-framework dependent swc to link in mx.core.IMXMLObject

        //  call IMXMLObject.initialized() on implementors
        if (self.getType().isAssignableTo(standardDefs.INTERFACE_IMXMLOBJECT)
                || self.getType().hasMetadata(StandardDefs.MD_IMXMLOBJECT, true))
        {
            String idParam = (isDeclared ? TextGen.quoteWord(id) : "null");
            list.add("\t", varName, ".initialized(this, ", idParam, ")", line);
        }

        // generate idAssigned dispatching logic for user declared instances.
        if (isDeclared)
        {
            if (self.getRepeaterLevel() == 0)
            {
                list.add("\t", id, " = ", varName, ";", line);
            }
            else
            {
                ThreadLocalToolkit.log(new DeclaredAndProceduralWithinRepeater(), self.getDocument().getSourcePath(), line);
            }

            //  evaluate all property bindings for this object - i.e. initialize properties of the object whose values
            //  are binding expressions. E.g. if we've just created <mx:Foo id="bar" x="100" y="{baz.z}"/>, then
            //  we need to evaluate (baz.z) and assign it to bar.y. This explicit evaluation pass is necessary because
            //  baz may already have been initialized, although the fact that we do it even when that's not the case is
            //  suboptimal.
            list.add("\t", NameFormatter.toDot(standardDefs.CLASS_BINDINGMANAGER),
                     ".executeBindings(this, ", TextGen.quoteWord(id), ", " + id + ");", line);
        }

        // If this is a stateful Halo Container, with itemCreationPolicy "immediate" we need to ensure
        // that the instance and all descendants are instantiated.
        if (standardDefs.isContainer(selfType) && self.isEarlyInit())
        {
            list.add("\t", varName,".initialize();", line);
        }
        
        //  return created value
        list.add("\treturn ", varName, ";", line);
        list.add("}", line);
        
        Type lvalueType = getLValueType();
        if (standardDefs.isITransientDeferredInstance(lvalueType) || self.getIsTransient())
        	list = getDestructorBody(list, line);

        return list;
    }

    /*
     * Helper function to collect all declarations and sub-declarations for a 
     * given model initializer (used by getDestructorBody).
     */
    private void collectDeclarations(Iterator<Initializer> initializers, Set<String> ids)
    {
    	for (Iterator<Initializer> iter = initializers; iter.hasNext(); )
        {
    		Initializer initializer = iter.next();
    		if (initializer instanceof ValueInitializer)
    		{
    			ValueInitializer valueInitializer = (ValueInitializer)initializer;
    			Object value = valueInitializer.getValue();
    		    if (value instanceof Model)
    			{
    			    if (((Model)value).isDeclared())
    				    ids.add(((Model)value).getId());
    			    collectDeclarations(((Model)value).getSubInitializerIterator(), ids);
    			}
    		}
        }
    }
    
    /**
     * Generates the destructor/reset method as necessary as required by
     * ITransientDeferredInstance rvalues.
     */
    protected CodeFragmentList getDestructorBody(CodeFragmentList list, int line)
    {
    	Model model = (Model) value;
    	
    	Set<String> ids = new LinkedHashSet<String>();
    	if (model.isDeclared()) ids.add(model.getId());

    	// Collect ids (declarations) that this destructor needs to reset.
    	collectDeclarations(model.getSubInitializerIterator(), ids);
    	
        // function header
        list.add("\nprivate function ", model.getDefinitionName() + "_r", "() : void", line);
        list.add("{", line);

        // generate declaration and sub-declaration cleanup. 
        for (String id : ids)
        {
            list.add("\t", id, " = null;", 0);
        }

        list.add("}", line);
        
    	return list;
    }
    
	/**
	 * return an iterator over our definition if we have one, and all the definitions of our children
	 */
	public Iterator getDefinitionsIterator()
	{
		IteratorList iterList = null;

		if (hasDefinition())
		{
			//	Note: isDescribed() guard omits our own definition if we're in a descriptor tree
			// 	TODO remove this once DI is done directly
			if (!(value instanceof Model) || !((Model)value).isDescribed())
			{
				(iterList = new IteratorList()).add(new SingletonIterator(getDefinitionBody()));
			}
		}

		if (value instanceof Model)
		{
			(iterList != null ? iterList : (iterList = new IteratorList())).add(((Model)value).getSubDefinitionsIterator());
		}

		return iterList != null ? iterList.toIterator() : Collections.EMPTY_LIST.iterator();
	}

    public StatementListNode generateDefinitionBody(Context context, HashSet<String> configNamespaces,
                                                    boolean generateDocComments, StatementListNode statementList)
    {
        assert hasDefinition() : "no definition in getDefinitionBody()";
        assert value instanceof Model : "non-Model value has definition in getDefinitionBody()";

        NodeFactory nodeFactory = context.getNodeFactory();
        StatementListNode result = statementList;

        final String varName = TEMP;
        
        Model self = (Model) value;
        Type selfType = self.getType();
        String selfTypeName;

        if (value instanceof Vector)
        {
            Vector vector = (Vector) value;
            String elementTypeName = vector.getElementTypeName();
            selfTypeName = StandardDefs.CLASS_VECTOR + ".<" + elementTypeName + ">";
        }
        else
        {
            selfTypeName = NameFormatter.toDot(selfType.getName());
        }

        boolean isDeclared = self.isDeclared();
        String id = isDeclared ? self.getId() : varName;

        TypeExpressionNode returnType =
            AbstractSyntaxTreeUtil.generateTypeExpression(nodeFactory, selfTypeName, true);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(null, returnType);        
        int position = AbstractSyntaxTreeUtil.lineNumberToPosition(nodeFactory, getLineRef());
        VariableDefinitionNode variableDefinition;

        //  value creation
        if (modelHasInlineRValue())
        {
            Node inlineRValue = generateInlineRValue(nodeFactory, configNamespaces, generateDocComments);
            variableDefinition = AbstractSyntaxTreeUtil.generateVariable(nodeFactory, varName,
                                                                         selfTypeName, true,
                                                                         inlineRValue, position);
        }
        else if (value instanceof Vector)
        {
            Vector vector = (Vector) value;
            LiteralNumberNode literalNumber = nodeFactory.literalNumber(vector.size());
            ArgumentListNode argumentList = nodeFactory.argumentList(null, literalNumber);

            if (vector.isFixed())
            {
                LiteralBooleanNode literalBoolean = nodeFactory.literalBoolean(vector.isFixed());
                argumentList = nodeFactory.argumentList(argumentList, literalBoolean);
            }
            
            variableDefinition = AbstractSyntaxTreeUtil.generateVariableNew(nodeFactory, varName,
                                                                            selfTypeName, argumentList,
                                                                            position);
        }
        else
        {
            //  TODO confirm the availability of a 0-arg ctor!! but do
            //  it upstream from here, like when Model is built
            variableDefinition = AbstractSyntaxTreeUtil.generateVariableNew(nodeFactory, varName,
                                                                            selfTypeName, position);
        }

        StatementListNode functionStatementList = nodeFactory.statementList(null, variableDefinition);

        if (!modelHasInlineRValue())
        {
            if (value instanceof Vector)
            {
                Vector vector = (Vector) value;
                addAssignExprs(nodeFactory, configNamespaces, generateDocComments, functionStatementList,
                               vector.getElementInitializerIterator(), varName);
            }
            else
            {
                // set properties
                addAssignExprs(nodeFactory, configNamespaces, generateDocComments, functionStatementList,
                               self.getPropertyInitializerIterator(self.getType().hasDynamic()),
                               varName);
            }
        }
        
        //  set styles
        addAssignExprs(nodeFactory, configNamespaces, generateDocComments, functionStatementList,
                       self.getStyleInitializerIterator(), varName);

        //  set effects
        addAssignExprs(nodeFactory, configNamespaces, generateDocComments, functionStatementList,
                       self.getEffectInitializerIterator(), varName);

        //  add event handlers
        addAssignExprs(nodeFactory, configNamespaces, generateDocComments, functionStatementList,
                       self.getEventInitializerIterator(), varName);

        //  register effect names
        Iterator<Initializer> iterator = self.getEffectInitializerIterator();

        if (iterator.hasNext())
        {
            //list.add("\t", varName, ".registerEffects([ ", effectEventNames, " ]);", line);
            MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, varName, false);

            IdentifierNode identifier = nodeFactory.identifier(REGISTER_EFFECTS, false);
            ArgumentListNode effectEventNamesArgumentList = null;

            while (iterator.hasNext())
            {
                EffectInitializer effectInitializer = (EffectInitializer) iterator.next();
                String effectName = effectInitializer.getName();
                LiteralStringNode literalString = nodeFactory.literalString(effectName);
                effectEventNamesArgumentList = nodeFactory.argumentList(effectEventNamesArgumentList,
                                                                        literalString);
            }

            LiteralArrayNode literalArray = nodeFactory.literalArray(effectEventNamesArgumentList);
            ArgumentListNode argumentList = nodeFactory.argumentList(null, literalArray);
            CallExpressionNode selector = (CallExpressionNode) nodeFactory.callExpression(identifier,
                                                                                          argumentList);
            selector.setRValue(false);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
            ListNode list = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            functionStatementList = nodeFactory.statementList(functionStatementList, expressionStatement);
        }

        //  post-init actions for values that are being assigned to properties (via id attribution)
        if (isDeclared && standardDefs.isIUIComponentWithIdProperty(selfType))
        {
            //  set id on IUIComponents that carry an id prop
            MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, varName, false);
            IdentifierNode identifier = nodeFactory.identifier(ID, false);
            LiteralStringNode literalString = nodeFactory.literalString(id);
            ArgumentListNode argumentList = nodeFactory.argumentList(null, literalString);
            SetExpressionNode selector = nodeFactory.setExpression(identifier, argumentList, false);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
            ListNode list = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            functionStatementList = nodeFactory.statementList(functionStatementList, expressionStatement);
        }

        // Design layer related items
        if (self.layerParent != null)
        {
            if (self instanceof DesignLayer)
            {
                //list.add("\t", self.layerParent.getId(), ".addLayer(", varName, ");", line);
            	
                IdentifierNode method = nodeFactory.identifier(ADD_LAYER, false);
                
                IdentifierNode layerIdentifier = nodeFactory.identifier(self.layerParent.getId());
            	GetExpressionNode getExpression = nodeFactory.getExpression(layerIdentifier);
            	MemberExpressionNode layerMemberExpression = nodeFactory.memberExpression(null, getExpression);
            	
            	IdentifierNode varIdentifier = nodeFactory.identifier(varName);
            	GetExpressionNode varGetExpression = nodeFactory.getExpression(varIdentifier);
            	MemberExpressionNode varMemberExpression = nodeFactory.memberExpression(null, varGetExpression);
            	
                ArgumentListNode argumentList = nodeFactory.argumentList(null, varMemberExpression);
                
                CallExpressionNode selector = (CallExpressionNode) nodeFactory.callExpression(method, argumentList);
                selector.setRValue(false);
                
                MemberExpressionNode memberExpression = nodeFactory.memberExpression(layerMemberExpression, selector);
                ListNode list = nodeFactory.list(null, memberExpression);
                ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
                functionStatementList = nodeFactory.statementList(functionStatementList, expressionStatement); 
                
            }
            else if (self.getType().isAssignableTo(standardDefs.INTERFACE_IVISUALELEMENT))
            {   
            	// list.add("\t", varName, ".layer = ", self.layerParent.getId(), ";", line);
            	IdentifierNode varIdentifier = nodeFactory.identifier(varName);
            	GetExpressionNode varGetExpression = nodeFactory.getExpression(varIdentifier);
            	MemberExpressionNode base = nodeFactory.memberExpression(null, varGetExpression);
            	

            	IdentifierNode identifier = nodeFactory.identifier(DESIGN_LAYER, false);
            	
            	IdentifierNode layerIdentifier = nodeFactory.identifier(self.layerParent.getId());
            	GetExpressionNode getExpression = nodeFactory.getExpression(layerIdentifier);
            	
            	MemberExpressionNode rvalueMemberExpression = nodeFactory.memberExpression(null, getExpression);
                ArgumentListNode argumentList = nodeFactory.argumentList(null, rvalueMemberExpression);
                
            	SetExpressionNode selector = nodeFactory.setExpression(identifier, argumentList, false);
            	
                MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
                ListNode list = nodeFactory.list(null, memberExpression);
                ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
                functionStatementList = nodeFactory.statementList(functionStatementList, expressionStatement); 
            }    
        }
        
        //  UIComponent-specific init steps
        if (standardDefs.isIUIComponent(selfType))
        {
            assert self instanceof MovieClip : "isIUIComponent(selfType) but !(self instanceof MovieClip)";
            MovieClip movieClip = (MovieClip) self;

            //  MXML implementations of IUIComponent initialize set their document property to themselves at
            //  construction time. Others need it set to the enclosing document (us).

            ListNode test;
            {
                MemberExpressionNode base =
                    AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, varName, false);
                IdentifierNode identifier = nodeFactory.identifier(DOCUMENT, false);
                GetExpressionNode selector = nodeFactory.getExpression(identifier);
                MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
                Node unaryExpression = nodeFactory.unaryExpression(Tokens.NOT_TOKEN, memberExpression);
                test = nodeFactory.list(null, unaryExpression);
            }

            StatementListNode then;
            {
                MemberExpressionNode base =
                    AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, varName, false);
                IdentifierNode identifier = nodeFactory.identifier(DOCUMENT, false);
                ThisExpressionNode thisExpression = nodeFactory.thisExpression(-1);
                ArgumentListNode argumentList = nodeFactory.argumentList(null, thisExpression);
                SetExpressionNode selector = nodeFactory.setExpression(identifier, argumentList, false);
                MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
                ListNode list = nodeFactory.list(null, memberExpression);
                ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
                then = nodeFactory.statementList(null, expressionStatement);
            }

            Node ifStatement = nodeFactory.ifStatement(test, then, null);
            functionStatementList = nodeFactory.statementList(functionStatementList, ifStatement);

            //  add visual children
            if (!standardDefs.isRepeater(selfType))
            {
                if (standardDefs.isContainer(selfType))
                {
                    if (movieClip.hasChildren())
                    {
                        functionStatementList = generateDocumentDescriptorAssignment(nodeFactory, configNamespaces, generateDocComments,
                                                                                     movieClip, varName, functionStatementList);
                        functionStatementList = generateDocumentDescriptorDocumentAssignment(nodeFactory, varName, 
                                                                                             functionStatementList);
                    }
                }
                else
                {
                    //  non-repeater - replicate DI child-creation sequence procedurally:       
                    Iterator childIter = movieClip.getChildInitializerIterator();
                    while (childIter.hasNext())
                    {
                        VisualChildInitializer init = (VisualChildInitializer)childIter.next();
                    
                        // Filter out state specific children.
                        if ( !((Model)init.getValue()).isStateSpecific())
                        {
                            MemberExpressionNode memberExpression =
                                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, varName, true);
                            functionStatementList =
                                init.generateAssignExpr(nodeFactory, configNamespaces, generateDocComments,
                                                        functionStatementList, memberExpression);
                        }
                    }
                }
            }
            else
            {
                //  repeater-specific init sequence: don't add children directly, instead use existing DI setup
                //  initializing repeater's childDescriptors property, for now
                VariableDefinitionNode childDescriptorVariableDefinition =
                    generateChildDescriptorVariable(nodeFactory, configNamespaces, generateDocComments,
                                                    varName, movieClip);
                functionStatementList = nodeFactory.statementList(functionStatementList,
                                                                  childDescriptorVariableDefinition);
                Node forStatement = generateRepeaterChildDescriptorLoop(nodeFactory);
                functionStatementList = nodeFactory.statementList(functionStatementList, forStatement);
            }
        }

        //  call IMXMLObject.initialized() on implementors
        if (self.getType().isAssignableTo(standardDefs.INTERFACE_IMXMLOBJECT)
                || self.getType().hasMetadata(StandardDefs.MD_IMXMLOBJECT, true))
        {
            MemberExpressionNode varNameMemberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, varName, false);
            IdentifierNode identifier = nodeFactory.identifier(INITIALIZED, false);
            ThisExpressionNode thisExpression = nodeFactory.thisExpression(-1);
            ArgumentListNode argumentList = nodeFactory.argumentList(null, thisExpression);

            if (isDeclared)
            {
                LiteralStringNode literalString = nodeFactory.literalString(id);
                argumentList = nodeFactory.argumentList(argumentList, literalString);
            }
            else
            {
                LiteralNullNode literalNull = nodeFactory.literalNull(-1);
                argumentList = nodeFactory.argumentList(argumentList, literalNull);
            }

            CallExpressionNode callExpression =
                (CallExpressionNode) nodeFactory.callExpression(identifier, argumentList);
            callExpression.setRValue(false);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(varNameMemberExpression,
                                                                                 callExpression);
            ListNode list = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            functionStatementList = nodeFactory.statementList(functionStatementList, expressionStatement);
        }

        // generate idAssigned dispatching logic for user declared instances.
        if (isDeclared)
        {
            if (self.getRepeaterLevel() == 0)
            {
                functionStatementList = generateValueCreation(nodeFactory, functionStatementList, id, varName);
            }
            else
            {
                ThreadLocalToolkit.log(new DeclaredAndProceduralWithinRepeater(),
                                       self.getDocument().getSourcePath(), getLineRef());
            }
        
            //  evaluate all property bindings for this object - i.e. initialize properties of the object whose values
            //  are binding expressions. E.g. if we've just created <mx:Foo id="bar" x="100" y="{baz.z}"/>, then
            //  we need to evaluate (baz.z) and assign it to bar.y. This explicit evaluation pass is necessary because
            //  baz may already have been initialized, although the fact that we do it even when that's not the case is
            //  suboptimal.
            MemberExpressionNode base =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, standardDefs.getBindingPackage(), BINDING_MANAGER, false);
            IdentifierNode identifier = nodeFactory.identifier(EXECUTE_BINDINGS, false);
            ThisExpressionNode thisExpression = nodeFactory.thisExpression(-1);
            ArgumentListNode argumentList = nodeFactory.argumentList(null, thisExpression);
            LiteralStringNode literalString = nodeFactory.literalString(id);
            argumentList = nodeFactory.argumentList(argumentList, literalString);
            MemberExpressionNode idMemberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, id, true);
            argumentList = nodeFactory.argumentList(argumentList, idMemberExpression);
            CallExpressionNode selector = (CallExpressionNode) nodeFactory.callExpression(identifier, argumentList);
            selector.setRValue(false);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
            ListNode list = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            functionStatementList = nodeFactory.statementList(functionStatementList, expressionStatement);
        }

        // If this is a stateful Halo Container, with itemCreationPolicy "immediate" we need to ensure
        // that the instance and all descendants are instantiated.
        if (standardDefs.isContainer(selfType) && self.isEarlyInit())
        {
            MemberExpressionNode varNameMemberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, varName, false);
            IdentifierNode identifier = nodeFactory.identifier(INITIALIZE, false);
            
            CallExpressionNode callExpression =
                (CallExpressionNode) nodeFactory.callExpression(identifier, null);
            callExpression.setRValue(false);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(varNameMemberExpression,
                                                                                 callExpression);
            ListNode list = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            functionStatementList = nodeFactory.statementList(functionStatementList, expressionStatement);
        }
        
        //  return created value
        MemberExpressionNode memberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, varName, false);
        ListNode list = nodeFactory.list(null, memberExpression);
        ReturnStatementNode returnStatement = nodeFactory.returnStatement(list);
        functionStatementList = nodeFactory.statementList(functionStatementList, returnStatement);

        IdentifierNode functionIdentifier = nodeFactory.identifier(getDefinitionName());
        FunctionCommonNode functionCommon = nodeFactory.functionCommon(context,
                                                                       functionIdentifier,
                                                                       functionSignature,
                                                                       functionStatementList);
        functionCommon.setUserDefinedBody(true);
        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generatePrivateAttribute(nodeFactory);
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.EMPTY_TOKEN, functionIdentifier);

        FunctionDefinitionNode functionDefinition = nodeFactory.functionDefinition(context, attributeList,
                                                                                   functionName, functionCommon);

        result = nodeFactory.statementList(result, functionDefinition);

        Type lvalueType = getLValueType();
        if (standardDefs.isITransientDeferredInstance(lvalueType) || self.getIsTransient())
        	result = generateDestructorBody(context, result);
        
        return result;
    }

    /**
     * Generates the destructor/reset method as necessary as required by
     * ITransientDeferredInstance rvalues.
     */
    protected StatementListNode generateDestructorBody(Context context, StatementListNode statementList)
    {    	
    	Model model = (Model) value;
    	
    	Set<String> ids = new LinkedHashSet<String>();
    	if (model.isDeclared()) ids.add(model.getId());

    	// Collect ids (declarations) that this destructor needs to reset.
    	collectDeclarations(model.getSubInitializerIterator(), ids);
    	
    	NodeFactory nodeFactory = context.getNodeFactory();
        StatementListNode result = statementList;
        
        StatementListNode functionStatementList = null;
        
        // Assignment expressions.
        
        for (String id : ids)
        { 
            LiteralNullNode literalNull = nodeFactory.literalNull();
            IdentifierNode identifier = nodeFactory.identifier(id);
            Node expressionStatement = nodeFactory.assignmentExpression(identifier,ASSIGN_TOKEN,literalNull);
            functionStatementList = nodeFactory.statementList(functionStatementList, expressionStatement);
        }
        
        // function body
        
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(null, null);
        functionSignature.void_anno = true;
        IdentifierNode functionIdentifier = nodeFactory.identifier(model.getDefinitionName() + "_r");
        FunctionCommonNode functionCommon = nodeFactory.functionCommon(context,
                                                                       functionIdentifier,
                                                                       functionSignature,
                                                                       functionStatementList);
      
        functionCommon.setUserDefinedBody(true);
        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generatePrivateAttribute(nodeFactory);
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.EMPTY_TOKEN, functionIdentifier);

        FunctionDefinitionNode functionDefinition = nodeFactory.functionDefinition(context, attributeList,
                                                                                   functionName, functionCommon);

        result = nodeFactory.statementList(result, functionDefinition);
        
    	return result;
    }
    
	public VariableDefinitionNode generateChildDescriptorVariable(NodeFactory nodeFactory, HashSet<String> configNamespaces,
                                                                  boolean generateDocComments, String varName,
																  MovieClip movieClip)
	{
		//list.add("\tvar cd:Array = ", varName, ".childDescriptors = [", line);
		MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, varName, true);
		IdentifierNode childDescriptorsIdentifier = nodeFactory.identifier(CHILD_DESCRIPTORS, false);
		ArgumentListNode visualChildArgumentList = null;

		for (Iterator childIter = movieClip.children().iterator(); childIter.hasNext(); )
		{
			//DescriptorGenerator.addDescriptorInitializerFragments(list, (MovieClip)init.getValue(), "\t\t");
			VisualChildInitializer init = (VisualChildInitializer) childIter.next();
			Model model = (MovieClip) init.getValue();
			MemberExpressionNode memberExpression =
				ImplementationGenerator.addDescriptorInitializerFragments(nodeFactory, configNamespaces,
                                                                          generateDocComments, movieClip,
                                                                          null, true);
			visualChildArgumentList = nodeFactory.argumentList(visualChildArgumentList,
															   memberExpression);
		}

		LiteralArrayNode literalArray = nodeFactory.literalArray(visualChildArgumentList);
		ArgumentListNode argumentList = nodeFactory.argumentList(null, literalArray);
		SetExpressionNode selector = nodeFactory.setExpression(childDescriptorsIdentifier,
															   argumentList, false);
		selector.setRValue(false);
		MemberExpressionNode initializer = nodeFactory.memberExpression(base, selector);
		return AbstractSyntaxTreeUtil.generateVariable(nodeFactory, CD, ARRAY, false, initializer);
	}

	private VariableDefinitionNode generateClassVariable(NodeFactory nodeFactory)
	{
		IdentifierNode getDefinitionByNameIdentifier = nodeFactory.identifier(GET_DEFINITION_BY_NAME);
		LiteralStringNode literalString = nodeFactory.literalString(standardDefs.CLASS_PROPERTYCHANGEEVENT_DOT);
		ArgumentListNode argumentList = nodeFactory.argumentList(null, literalString);
		CallExpressionNode callExpression =
			(CallExpressionNode) nodeFactory.callExpression(getDefinitionByNameIdentifier,
															argumentList);
		callExpression.setRValue(false);
		MemberExpressionNode getDefinitionMemberExpression =
			nodeFactory.memberExpression(null, callExpression);
		IdentifierNode classIdentifier = nodeFactory.identifier(CLASS);
		GetExpressionNode getExpression = nodeFactory.getExpression(classIdentifier);
		MemberExpressionNode classMemberExpression =
			nodeFactory.memberExpression(null, getExpression);
		BinaryExpressionNode binaryExpression =
			nodeFactory.binaryExpression(Tokens.AS_TOKEN,
										 getDefinitionMemberExpression,
										 classMemberExpression);
		return AbstractSyntaxTreeUtil.generateVariable(nodeFactory, __CLASS, CLASS,
													   false, binaryExpression);
	}

	public StatementListNode generateDefinitions(Context context, HashSet<String> configNamespaces,
                                                 boolean generateDocComments, StatementListNode statementList)
	{
		StatementListNode result = statementList;

		if (hasDefinition())
		{
			//	Note: isDescribed() guard omits our own definition if we're in a descriptor tree
			// 	TODO remove this once DI is done directly
			if (!(value instanceof Model) || !((Model) value).isDescribed())
			{
				result = generateDefinitionBody(context, configNamespaces, generateDocComments, result);
			}
		}

		if (value instanceof Model)
		{
			Iterator<Initializer> iterator = ((Model) value).getSubInitializerIterator();

			while (iterator.hasNext())
			{
				result = iterator.next().generateDefinitions(context, configNamespaces, generateDocComments, result);
			}
		}

		return result;
	}

	private ExpressionStatementNode generateDispatchEvent(NodeFactory nodeFactory)
	{
		IdentifierNode dispatchEventIdentifier = nodeFactory.identifier(DISPATCH_EVENT, false);
		IdentifierNode eventIdentifier = nodeFactory.identifier(EVENT, false);
		MemberExpressionNode eMemberExpression =
			AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, __E, false);
		ArgumentListNode eventArgumentList = nodeFactory.argumentList(null, eMemberExpression);
		CallExpressionNode eventCallExpression =
			(CallExpressionNode) nodeFactory.callExpression(eventIdentifier, eventArgumentList);
		eventCallExpression.setRValue(false);
		MemberExpressionNode eventMemberExpression = nodeFactory.memberExpression(null, eventCallExpression);
		ArgumentListNode dispatchEventArgumentList = nodeFactory.argumentList(null, eventMemberExpression);
		CallExpressionNode dispatchEventCallExpression =
			(CallExpressionNode) nodeFactory.callExpression(dispatchEventIdentifier, dispatchEventArgumentList);
		dispatchEventCallExpression.setRValue(false);
		MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, dispatchEventCallExpression);
		ListNode list = nodeFactory.list(null, memberExpression);
		return nodeFactory.expressionStatement(list);
	}

    private StatementListNode generateDocumentDescriptorAssignment(NodeFactory nodeFactory,
                                                                   HashSet<String> configNamespaces,
                                                                   boolean generateDocComments,
                                                                   MovieClip movieClip,
                                                                   String varName,
                                                                   StatementListNode statementList)
    {
        QualifiedIdentifierNode qualifiedIdentifier =
            AbstractSyntaxTreeUtil.generateMxInternalQualifiedIdentifier(nodeFactory,
                                                                         _DOCUMENT_DESCRIPTOR,
                                                                         false);
        MemberExpressionNode descriptorsMemberExpression =
            ImplementationGenerator.addDescriptorInitializerFragments(nodeFactory, configNamespaces,
                                                                      generateDocComments, movieClip,
                                                                      Collections.<String>emptySet(), false);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, descriptorsMemberExpression);
        SetExpressionNode setExpression = nodeFactory.setExpression(qualifiedIdentifier, argumentList, false);
        MemberExpressionNode base =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, varName, false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, setExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        return nodeFactory.statementList(statementList, expressionStatement);
    }

    private StatementListNode generateDocumentDescriptorDocumentAssignment(NodeFactory nodeFactory,
                                                                           String varName,
                                                                           StatementListNode statementList)
    {
        MemberExpressionNode varNameMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, varName, false);
        QualifiedIdentifierNode qualifiedIdentifier =
            AbstractSyntaxTreeUtil.generateMxInternalQualifiedIdentifier(nodeFactory, _DOCUMENT_DESCRIPTOR, false);
        GetExpressionNode documentDescriptorGetExpression = nodeFactory.getExpression(qualifiedIdentifier);
        MemberExpressionNode varNameDocumentDescriptorMemberExpression =
            nodeFactory.memberExpression(varNameMemberExpression, documentDescriptorGetExpression);
        IdentifierNode identifier = nodeFactory.identifier(DOCUMENT, false);
        ThisExpressionNode thisExpression = nodeFactory.thisExpression(-1);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, thisExpression);
        SetExpressionNode setExpression = nodeFactory.setExpression(identifier, argumentList, false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(varNameDocumentDescriptorMemberExpression,
                                                                             setExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        return nodeFactory.statementList(statementList, expressionStatement);
    }

	private Node generateRepeaterChildDescriptorLoop(NodeFactory nodeFactory)
	{
		//list.add("\tfor (var i:int = 0; i < cd.length; i++) cd[i].document = this;", line);
		LiteralNumberNode initializer = nodeFactory.literalNumber(0);
		VariableDefinitionNode init =
			AbstractSyntaxTreeUtil.generateVariable(nodeFactory, I, INT, false, initializer);
		MemberExpressionNode iMemberExpression =
			AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, I, false);
		MemberExpressionNode cdMemberExpression =
			AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, CD, false);

		IdentifierNode lengthIdentifier = nodeFactory.identifier(LENGTH, false);
		GetExpressionNode lengthGetExpression = nodeFactory.getExpression(lengthIdentifier);
		MemberExpressionNode cdLengthMemberExpression = nodeFactory.memberExpression(cdMemberExpression,
																					 lengthGetExpression);
		BinaryExpressionNode binaryExpression = nodeFactory.binaryExpression(Tokens.LESSTHAN_TOKEN,
																			 iMemberExpression,
																			 cdLengthMemberExpression);
		ListNode test = nodeFactory.list(null, binaryExpression);

		IdentifierNode iIdentifier = nodeFactory.identifier(I, false);
		IncrementNode increment = nodeFactory.increment(Tokens.PLUSPLUS_TOKEN, iIdentifier, true);
		MemberExpressionNode incrMemberExpression = nodeFactory.memberExpression(null, increment);
		ListNode incr = nodeFactory.list(null, incrMemberExpression);

		cdMemberExpression = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, CD, false);

		iMemberExpression = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, I, false);
		ArgumentListNode getArgumentList = nodeFactory.argumentList(null, iMemberExpression);
		GetExpressionNode iGetExpression = nodeFactory.getExpression(getArgumentList);
		iGetExpression.setMode(Tokens.LEFTBRACKET_TOKEN);
		MemberExpressionNode base = nodeFactory.memberExpression(cdMemberExpression, iGetExpression);

		IdentifierNode documentIdentifier = nodeFactory.identifier(DOCUMENT, false);
		ThisExpressionNode thisExpression = nodeFactory.thisExpression(-1);
		ArgumentListNode setArgumentList = nodeFactory.argumentList(null, thisExpression);
		SetExpressionNode selector = nodeFactory.setExpression(documentIdentifier,
															   setArgumentList, false);

		MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
		ListNode list = nodeFactory.list(null, memberExpression);
		ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
		StatementListNode body = nodeFactory.statementList(null, expressionStatement);

		return nodeFactory.forStatement(init, test, incr, body);
	}

	private StatementListNode generateValueCreation(NodeFactory nodeFactory, StatementListNode statementList,
													String id, String varName)
	{
		ExpressionStatementNode expressionStatement =
			AbstractSyntaxTreeUtil.generateAssignment(nodeFactory, id, varName);
		return nodeFactory.statementList(statementList, expressionStatement);
	}

	/**
	 *
	 */
	private TypeTable getTypeTable()
	{
		return getLValueType().getTypeTable();
	}

	/**
	 *
	 */
	private static void addAssignExprs(CodeFragmentList list, Iterator initIter, String name)
	{
        while (initIter.hasNext())
        {
            Initializer init = (Initializer)initIter.next();
            if (!init.isStateSpecific())
                list.add("\t", init.getAssignExpr(name), ";", init.getLineRef());
        }
	}

	/**
	 *
	 */
	private static void addAssignExprs(NodeFactory nodeFactory, HashSet<String> configNamespaces,
                                       boolean generateDocComments, StatementListNode statementList,
									   Iterator<? extends Initializer> initIter,
									   String name)
	{
        while (initIter.hasNext())
        {
            Initializer init = initIter.next();
            if (!init.isStateSpecific())
            {
                MemberExpressionNode memberExpression =
                    AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, name, true);
                statementList = init.generateAssignExpr(nodeFactory, configNamespaces, generateDocComments,
                                                        statementList, memberExpression);
            }
        }
	}

	/**
	 * TODO once all POJO rvalues have been eliminated, this can go away completely
	 */
	protected String formatExpr(Type targetType, Object value)
	{
		assert targetType != null;
		assert value != null;

		TypeTable typeTable = getTypeTable();

		if (value instanceof BindingExpression)
		{
			if (targetType.equals(typeTable.booleanType) ||
				targetType.equals(typeTable.numberType) ||
				targetType.equals(typeTable.intType) ||
				targetType.equals(typeTable.uintType))
			{
				return StandardDefs.UNDEFINED;
			}
			else
			{
				return StandardDefs.NULL;
			}
		}

		if (value instanceof AtEmbed)
		{
			return ((AtEmbed) value).getPropName();
		}

		if (value instanceof AtResource)
		{
			return ((AtResource)value).getValueExpression();
		}

		if (targetType.equals(typeTable.stringType))
		{
			return StringUtils.formatString(value.toString());
		}
		else if (targetType.equals(typeTable.booleanType) ||
				targetType.equals(typeTable.numberType) ||
				targetType.equals(typeTable.intType) ||
				targetType.equals(typeTable.uintType))
		{
			return value.toString();
		}
		else if (targetType.equals(typeTable.objectType) || targetType.equals(typeTable.noType))
		{
			if (value instanceof String)
			{
				return StringUtils.formatString((String) value);
			}
			else if (value instanceof Number || value instanceof Boolean)
			{
				return value.toString();
			}
			else
			{
				assert false : "formatExpr: unsupported rvalue type '" + value.getClass() + "' for lvalue type 'Object'";
			}
		}
		else if (targetType.equals(typeTable.classType))
		{
			return value.toString();
		}
		else if (targetType.equals(typeTable.functionType))
		{
			return value.toString();
		}
		else if (targetType.equals(typeTable.regExpType))
		{
			return value.toString();
		}
		else if (targetType.equals(typeTable.xmlType))
		{
			return asXmlLiteral((XML)value);
		}
		else if (targetType.equals(typeTable.xmlListType))
		{
			return asXMLList((XMLList)value);
		}
		else if (standardDefs.isInstanceGenerator(targetType))
		{
			assert false : "formatExpr: instance generator lvalue with non-Model lvalue";
		}
		else
		{
			assert false : "formatExpr: unsupported lvalue type: " + targetType.getName();
		}

		assert false;
		return null;
	}

	/**
	 * TODO once all POJO rvalues have been eliminated, this can go away completely
	 */
	protected Node formatExpr(NodeFactory nodeFactory, HashSet<String> configNamespaces,
                              boolean generateDocComments, Type targetType, Object value)
	{
		assert targetType != null;
		assert value != null;

		TypeTable typeTable = getTypeTable();

		if (value instanceof BindingExpression)
		{
			if (targetType.equals(typeTable.booleanType) ||
				targetType.equals(typeTable.numberType) ||
				targetType.equals(typeTable.intType) ||
				targetType.equals(typeTable.uintType))
			{
				return nodeFactory.identifier(UNDEFINED, false);
			}
			else
			{
				return nodeFactory.literalNull(-1);
			}
		}

		if (value instanceof AtEmbed)
		{
			return AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory,
																 ((AtEmbed) value).getPropName(),
																 true);
		}

		if (value instanceof AtResource)
		{
			return ((AtResource) value).getValueExpression(nodeFactory);
		}

		if (targetType.equals(typeTable.stringType))
		{
			return nodeFactory.literalString(StringUtils.unformatString(value.toString()));
		}

		if (targetType.equals(typeTable.booleanType))
		{
			return nodeFactory.literalBoolean(Boolean.parseBoolean(value.toString()));
		}
		else if (targetType.equals(typeTable.numberType) ||
				 targetType.equals(typeTable.intType) ||
				 targetType.equals(typeTable.uintType))
		{
			return nodeFactory.literalNumber(value.toString());
		}
		else if (targetType.equals(typeTable.objectType) || targetType.equals(typeTable.noType))
		{
			if (value instanceof String)
			{
				return nodeFactory.literalString(StringUtils.unformatString((String) value));
			}
			else if (value instanceof Number)
			{
				return nodeFactory.literalNumber(value.toString());
			}
			else if (value instanceof Boolean)
			{
				return nodeFactory.literalBoolean(Boolean.parseBoolean(value.toString()));
			}
			else
			{
				assert false : "formatExpr: unsupported rvalue type '" + value.getClass() + "' for lvalue type 'Object'";
			}
		}
		else if (targetType.equals(typeTable.classType))
		{
            if (value.equals(THIS))
            {
                return nodeFactory.thisExpression(-1);
            }
            else if (value.equals(NULL))
            {
                return nodeFactory.literalNull(-1);
            }
            else
            {
            	int position = AbstractSyntaxTreeUtil.lineNumberToPosition(nodeFactory, getLineRef());
                return AbstractSyntaxTreeUtil.generateMemberExpression(nodeFactory, value.toString(), position);
            }
		}
		else if (targetType.equals(typeTable.functionType))
		{
            // The value can be a function reference, like "foo",
            // "C.foo", or "a.b.C.foo", or it can be a function
            // definition, like "function () {}".  The "var f =" is
            // necessary to put ASC's parser into the correct state to
            // handle a function definition.
            List<Node> list =
                AbstractSyntaxTreeUtil.parse(nodeFactory.getContext(), configNamespaces,
                                             "var f = " + value.toString(), getLineRef(),
                                             generateDocComments);
            
            VariableDefinitionNode variableDefinition = null;
            
            if(list.get(0) instanceof DocCommentNode)
            {
                variableDefinition = (VariableDefinitionNode) ((DocCommentNode) list.get(0)).def;
            }
            else 
            {
                variableDefinition = (VariableDefinitionNode) list.get(0); 
            }
            
            VariableBindingNode variableBinding = (VariableBindingNode) variableDefinition.list.items.get(0);
            return variableBinding.initializer;
		}
		else if (targetType.equals(typeTable.regExpType))
		{
			return nodeFactory.literalRegExp(value.toString(), -1);
		}
		else if (targetType.equals(typeTable.xmlType))
		{
			return asXmlLiteral(nodeFactory, (XML) value);
		}
		else if (targetType.equals(typeTable.xmlListType))
		{
			return asXMLList(nodeFactory, (XMLList) value);
		}
		else if (standardDefs.isInstanceGenerator(targetType))
		{
			assert false : "formatExpr: instance generator lvalue with non-Model lvalue";
		}
		else
		{
			assert false : "formatExpr: unsupported lvalue type: " + targetType.getName();
		}

		assert false;
		return null;
	}

	/**
	 *
	 */
	private static String asArrayLiteral(Array array)
	{
		List<String> elements = new ArrayList<String>();

		for (Iterator<ArrayElementInitializer> iter = array.getElementInitializerIterator(); iter.hasNext(); )
		{
			ArrayElementInitializer initializer = iter.next();
			
			if (!initializer.isStateSpecific())
			{
				elements.add(initializer.getValueExpr());
			}
		}

		return "[" + TextGen.toCommaList(elements.iterator()) + "]";
	}

	/**
	 *
	 */
	private static LiteralArrayNode asArrayLiteral(NodeFactory nodeFactory, HashSet<String> configNamespaces,
                                                   boolean generateDocComments, Array array)
	{
		ArgumentListNode argumentList = null;

		for (Iterator<ArrayElementInitializer> iter = array.getElementInitializerIterator(); iter.hasNext(); )
		{
			ArrayElementInitializer initializer = iter.next();
			if (!initializer.isStateSpecific())
			{
				Node valueExprNode = initializer.generateValueExpr(nodeFactory, configNamespaces, generateDocComments);
				argumentList = nodeFactory.argumentList(argumentList, valueExprNode);
			}
		}

		return nodeFactory.literalArray(argumentList);
	}

	/**
	 *
	 */
	private static String asObjectLiteral(Model model)
	{
		List<String> pairs = new ArrayList<String>();

		for (Iterator<Initializer> iter = model.getPropertyInitializerIterator(); iter.hasNext(); )
		{
			NamedInitializer init = (NamedInitializer)iter.next();
			pairs.add(init.getName() + ": " + init.getValueExpr());
		}

		return "{" + TextGen.toCommaList(pairs.iterator()) + "}";
	}

	/**
	 *
	 */
	private static LiteralObjectNode asObjectLiteral(NodeFactory nodeFactory, HashSet<String> configNamespaces,
                                                     boolean generateDocComments, Model model)
	{
		ArgumentListNode argumentList = null;

		for (Iterator<Initializer> iter = model.getPropertyInitializerIterator(); iter.hasNext(); )
		{
			NamedInitializer init = (NamedInitializer) iter.next();
			IdentifierNode identifier = nodeFactory.identifier(init.getName());
			LiteralFieldNode literalField =
				nodeFactory.literalField(identifier,
                                         init.generateValueExpr(nodeFactory, configNamespaces,
                                                                generateDocComments));
			argumentList = nodeFactory.argumentList(argumentList, literalField);
		}

		return nodeFactory.literalObject(argumentList);
	}

    /**
     *
     */
    private static String asVectorLiteral(Vector vector)
    {
        List<String> elements = new ArrayList<String>();

        for (Iterator<ArrayElementInitializer> iter = vector.getElementInitializerIterator(); iter.hasNext(); )
        {
            ArrayElementInitializer initializer = iter.next();
		
            if (!initializer.isStateSpecific())
            {
                elements.add(initializer.getValueExpr());
            }
        }

        return "new <" + vector.getElementTypeName() + ">[" + TextGen.toCommaList(elements.iterator()) + "]";
    }

    /**
     *
     */
    private static LiteralVectorNode asVectorLiteral(NodeFactory nodeFactory, HashSet<String> configNamespaces,
                                                     boolean generateDocComments, Vector vector)
    {
        ArgumentListNode argumentList = null;

        for (Iterator<ArrayElementInitializer> iter = vector.getElementInitializerIterator(); iter.hasNext(); )
        {
            ArrayElementInitializer initializer = iter.next();
            if (!initializer.isStateSpecific())
            {
                Node valueExprNode = initializer.generateValueExpr(nodeFactory, configNamespaces, generateDocComments);
                argumentList = nodeFactory.argumentList(argumentList, valueExprNode);
            }
        }

        ApplyTypeExprNode applyTypeExpr =
            AbstractSyntaxTreeUtil.generateApplyTypeExpr(nodeFactory, vector.getElementTypeName());

        return nodeFactory.literalVector(applyTypeExpr, argumentList, 0);
    }

	/**
	 *
	 */
	private static String fixupXMLString(String orig)
	{
		StringBuilder result = new StringBuilder();

		for (int i = 0; i < orig.length(); i++)
		{
			if (orig.charAt(i) == '\r')
			{
				continue;
			}
			else if (orig.charAt(i) == '\n')
			{
				result.append("\\n");
				continue;
			}
			if (orig.charAt(i) == '\"')
			{
				result.append('\\');
			}
			result.append(orig.charAt(i));
		}

		return result.toString();
	}

	/**
	 *
	 */
	private String asXmlLiteral(XML component)
	{
		String xml = component.getLiteralXML();
		if (component.getIsE4X())
		{
			return xml;
		}
		else
		{
			StringBuilder buf = new StringBuilder(NameFormatter.toDot(standardDefs.CLASS_XMLUTIL) + ".createXMLDocument(\"");
			buf.append(fixupXMLString(xml));
			buf.append("\").firstChild");
			return buf.toString();
		}
	}

	/**
	 *
	 */
	private Node asXmlLiteral(NodeFactory nodeFactory, XML component)
	{
		String xml = component.getLiteralXML();
		if (component.getIsE4X())
		{
			LiteralStringNode literalString = nodeFactory.literalString(component.getLiteralXML());
			ListNode list = nodeFactory.list(null, literalString);
			return nodeFactory.literalXML(list, false, -1);
		}
		else
		{
			//StringBuilder buf = new StringBuilder(NameFormatter.toDot(StandardDefs.CLASS_XMLUTIL) + ".createXMLDocument(\"");
			//buf.append(fixupXMLString(xml));
			//buf.append("\").firstChild");
			//return buf.toString();
			MemberExpressionNode base =
				AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, standardDefs.getUtilsPackage(), XML_UTIL, false);
			IdentifierNode createXMLDocumentIdentifier = nodeFactory.identifier(CREATE_XML_DOCUMENT, false);
			LiteralStringNode literalString = nodeFactory.literalString(xml);
			ArgumentListNode argumentList = nodeFactory.argumentList(null, literalString);
			CallExpressionNode selector =
				(CallExpressionNode) nodeFactory.callExpression(createXMLDocumentIdentifier,
																argumentList);
			selector.setRValue(false);
			MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);

			IdentifierNode firstChildIdentifier = nodeFactory.identifier(FIRST_CHILD, false);
			GetExpressionNode getExpression = nodeFactory.getExpression(firstChildIdentifier);
			return nodeFactory.memberExpression(memberExpression, getExpression);
		}
	}

	private static String asXMLList(XMLList component)
	{
		StringBuilder buf = new StringBuilder("<>");
		buf.append(component.getLiteralXML());
		buf.append("</>");
		return buf.toString();
	}

	private static LiteralXMLNode asXMLList(NodeFactory nodeFactory, XMLList component)
	{
		LiteralStringNode literalString = nodeFactory.literalString(component.getLiteralXML());
		ListNode list = nodeFactory.list(null, literalString);
		LiteralXMLNode literalXML = nodeFactory.literalXML(list, false, -1);
		literalXML.is_xmllist = true;
		return literalXML;
	}

	/**
	 * NOTE this class should NOT contain Errors or Warnings. This exception is a late-stage patch to replace
	 * an intolerably obscure error from generated AS (due to an outstanding bug) with a more specific error,
	 * to improve usability while the bug still exists. To be removed when 173905 is fixed.
	 */
	public static class DeclaredAndProceduralWithinRepeater extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 5966918771156671871L;
	}

	/**
	 * get the comment from the model.
	 * @return comment associated with the model.
	 */
	public String getComment() 
	{
	    if(value instanceof Model) 
	    {
	        return ((Model)value).comment;
	    }
	    
	    return null;
	}
	
	public ValueInitializer clone() throws CloneNotSupportedException 
	{
        return (ValueInitializer) super.clone();
    }

}
