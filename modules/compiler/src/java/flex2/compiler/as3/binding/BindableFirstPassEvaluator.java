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

package flex2.compiler.as3.binding;

import flex2.compiler.util.CompilerMessage;
import flex2.compiler.as3.genext.GenerativeFirstPassEvaluator;
import flex2.compiler.as3.reflect.NodeMagic;
import flex2.compiler.as3.reflect.TypeTable;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.lang.TextParser;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.QName;
import macromedia.asc.parser.*;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;

import java.util.*;

/**
 * This evaluator handles processing class, function, property and
 * variable level Bindable metadata.
 *
 * @author Paul Reilly
 */
public class BindableFirstPassEvaluator extends GenerativeFirstPassEvaluator
{
    private static final int BINDABLE_NONE = 0, BINDABLE_USER = 1, BINDABLE_CODEGEN_PROP = 2, BINDABLE_CODEGEN_CLASS = 3;
    private static final String STYLE = "style";

    private final Set metaData;

	private Set<DefinitionNode> bindableClasses;
    private Set<DefinitionNode> managedClasses;
    private Set<DefinitionNode> evaluatedClasses;
    private Map<String, BindableInfo> classMap;

    //  visitation state
    private ClassDefinitionNode currentClassNode = null;
    private BindableInfo bindableInfo;
    private Map<String, Integer> visitedProps;

    private boolean inFunction = false;

    public BindableFirstPassEvaluator(TypeTable typeTable, StandardDefs defs, Set metaData)
	{
		super(typeTable, defs);
		this.metaData = metaData;
		classMap = new LinkedHashMap<String, BindableInfo>();
		evaluatedClasses = new HashSet<DefinitionNode>();
	}

	/**
	 * Note: we do the classdef MetaDataNode preprocessing here, because it turns out the ProgramNode's statement list
	 * is <strong>out of order</strong>, so we often see a class's MetaDataNode only *after* seeing the class it
	 * annotates.
	 */
	public Value evaluate(Context context, ProgramNode programNode)
	{
        //  first, note any [Managed] classes - need to have these in hand for check below
        for (Iterator iter = metaData.iterator(); iter.hasNext(); )
        {
            MetaDataNode metaDataNode = (MetaDataNode)iter.next();
            if (StandardDefs.MD_MANAGED.equals(metaDataNode.getId()))
            {
                if (metaDataNode.def instanceof ClassDefinitionNode)
                {
                    registerManagedClass(metaDataNode.def);
                }
            }
        }

        //  now [Bindable] classes - check, then register
        for (Iterator iter = metaData.iterator(); iter.hasNext(); )
		{
			MetaDataNode metaDataNode = (MetaDataNode)iter.next();
			if (StandardDefs.MD_BINDABLE.equals(metaDataNode.getId()))
			{
				if (metaDataNode.def instanceof ClassDefinitionNode)
				{
					if (isManagedClass(metaDataNode.def))
					{
						context.localizedWarning2(metaDataNode.pos(), new ClassBindableUnnecessaryOnManagedClass());
					}
					else if (getEventName(metaDataNode, context) == null)
					{
						registerBindableClass((ClassDefinitionNode)metaDataNode.def);
					}
				}
			}
		}

        //  now do the standard visit
        return super.evaluate(context, programNode);
	}

	/**
	 * Check property-level [Bindable] annotations here
	 */
	public Value evaluate(Context context, MetaDataNode metaDataNode)
	{
		if (StandardDefs.MD_BINDABLE.equals(metaDataNode.getId()))
		{
			if (metaDataNode.def instanceof ClassDefinitionNode)
			{
				//	class-level [Bindable] done already, see evaluate(ProgramNode)
			}
			else if (metaDataNode.def instanceof FunctionDefinitionNode)
			{
				//	function [Bindable]
                FunctionDefinitionNode node = (FunctionDefinitionNode) metaDataNode.def;
                if ("true".equals(metaDataNode.getValue(STYLE)))
                {
                    // do nothing
                }
                else if (getEventName(metaDataNode, context) == null)
                {
                    if (inManagedClass())
                    {
                        context.localizedWarning2(node.pos(), new PropertyBindableUnnecessaryOnManagedClass());
                    }
                    else if (inBindableClass())
                    {
                        context.localizedWarning2(node.pos(), new PropertyBindableUnnecessaryOnBindableClass());
                    }
                    else
                    {
                        boolean isGetter = NodeMagic.functionIsGetter(node);
                        if (isGetter || NodeMagic.functionIsSetter(node))
                        {
                            if (checkBindableGetterSetter(context, node, false, false))
                            {
                                registerBindableGetterSetter(context, node, true, isGetter);
                            }
                        }
                        else
                        {
                            context.localizedWarning2(node.pos(), new BindableFunctionRequiresEventName());
                        }
                    }
                }
                else
                {
                    if (NodeMagic.functionIsGetter(node) || NodeMagic.functionIsSetter(node))
                    {
                        String name = NodeMagic.getFunctionName(node);

                        if (getVisitedGetterSetterBindType(name) == BINDABLE_CODEGEN_CLASS)
                        {
                            //  if class is bindable, we may have previously registered the other member of the getter/setter
                            //  pair as requiring codegen. If so, unregister it. (Note OTOH that both may be specified at
                            //  the property level.)
                            QName qname = new QName(NodeMagic.getUserNamespace(node), name);
                            unregisterBindableAccessor(qname);
                        }

                        registerVisitedGetterSetter(name, BINDABLE_USER);
                    }
                }
			}
			else if (metaDataNode.def instanceof VariableDefinitionNode)
			{
				//	var [Bindable]
				VariableDefinitionNode node = (VariableDefinitionNode)metaDataNode.def;

				if (inFunction)
				{
					context.localizedError2(node.pos(), new BindableNotAllowedInsideFunctionDefinition());
				}
				else
				{
					if (getEventName(metaDataNode, context) == null)
					{
                        if (inManagedClass())
                        {
                            context.localizedWarning2(node.pos(), new PropertyBindableUnnecessaryOnManagedClass());
                        }
						else if (inBindableClass())
						{
                            context.localizedWarning2(node.pos(), new PropertyBindableUnnecessaryOnBindableClass());
						}
						else if (checkBindableVariable(context, node, false, false))
						{
							registerBindableVariable(context, node, true);
						}
					}
				}
			}
			else
			{
                //  something unsupported marked [Bindable]
                context.localizedError2(metaDataNode.pos(), new BindableNotAllowedHere());
			}
		}

		return null;
	}

	/**
	 *
	 */
	public Value evaluate(Context context, ClassDefinitionNode node)
	{
		if (!evaluatedClasses.contains(node))
		{
			evaluatedClasses.add(node);

            try
            {
				setCurrentClass(context, node);

                if (node.statements != null)
                {
                    if (node.instanceinits != null)
                    {
                        //	visit instance variable initializers
                        Iterator iterator = node.instanceinits.iterator();

                        while (iterator.hasNext())
                        {
                            Node instanceinit = (Node) iterator.next();
                            instanceinit.evaluate(context, this);
                        }
                    }

                    //	visit all statements within the classdef
                    node.statements.evaluate(context, this);
                }

				if (bindableInfo != null)
				{
					bindableInfo.setClassName(NodeMagic.getUnqualifiedClassName(node));
					classMap.put(NodeMagic.getClassName(node), bindableInfo);

					NodeMagic.addImport(context, node, NameFormatter.toDot(standardDefs.CLASS_EVENT));
					NodeMagic.addImport(context, node, NameFormatter.toDot(standardDefs.CLASS_EVENTDISPATCHER));
					NodeMagic.addImport(context, node, NameFormatter.toDot(standardDefs.INTERFACE_IEVENTDISPATCHER));
					NodeMagic.addImport(context, node, NameFormatter.toDot(standardDefs.CLASS_BINDINGMANAGER));
				}
            }
            finally
            {
                setCurrentClass(context, null);
            }
        }

		return null;
    }

    /**
     * 1. In [Bindable] classes, sweep getter/setters.
     * 2. Set in-function sentinel and visit function subtree.
     */
    public Value evaluate(Context context, FunctionDefinitionNode node)
    {
        String name = NodeMagic.getFunctionName(node);

        if (inBindableClass())
        {
            boolean isGetter = NodeMagic.functionIsGetter(node);

            if (isGetter || NodeMagic.functionIsSetter(node))
            {
                //	pick up getter/setter in [Bindable] class, unless user-specified [Bindable(...)] has already been
                // seen on 'other side'
                if (getVisitedGetterSetterBindType(name) != BINDABLE_USER)
                {
                    registerBindableGetterSetter(context, node, false, isGetter);
                }
            }
        }

        inFunction = true;
        super.evaluate(context, node);
        inFunction = false;
        return null;
    }

    /**
	 * Here we visit every VariableDefinitionNode in the program tree. If we decide to add Bindability to the variable,
	 * we add an entry to bindableInfo and set makeSecondPass true. Eligible variables are: a) in classes marked
     * [Bindable]; b) not function locals; c) not overriden by explicit [Bindable(..)] metadata; d) ok according to
     * checkBindableVariable().
	 */
	public Value evaluate(Context context, VariableDefinitionNode node)
	{
		QName qname = new QName(NodeMagic.getUserNamespace(node), NodeMagic.getVariableName(node));
		if (inBindableClass() &&
            !inFunction &&
            !isBindableAccessor(qname) &&
            checkBindableVariable(context, node, true, true))
		{
			registerBindableVariable(context, node, false);
		}

		return null;
	}

	/**
	 *
	 */
	private boolean checkBindableVariable(Context context, VariableDefinitionNode def, boolean quiet, boolean publicOnly)
	{
		//	variable outside class?
		if (!inClass())
        {
			if (!quiet)
			{
				context.localizedError2(def.pos(), new BindableNotAllowedOnGlobalOrPackageVariables());
			}
			return false;
        }

		//	const variable?
		if ((def.list != null) &&
        	(def.list.items != null) &&
            (def.list.items.size() > 0))
        {
            Object item = def.list.items.get(0);

            if (item instanceof VariableBindingNode)
            {
                VariableBindingNode variableBinding = (VariableBindingNode) item;

                if (variableBinding.kind == Tokens.CONST_TOKEN)
                {
                    if (!quiet)
                    {
                        context.localizedError2(def.pos(), new BindableNotAllowedOnConstMemberVariables());
                    }
                    return false;
                }
            }
        }

		//	non-public variable && publicsOnly?
		if (publicOnly && (def.attrs == null || !def.attrs.hasAttribute(NodeMagic.PUBLIC)))
		{
			if (!quiet)
			{
				context.localizedError2(def.pos(), new BindableNotAllowedHereOnNonPublicMemberVariables());
			}
			return false;
		}

		return true;
	}

	/**
	 *
	 */
	private boolean checkBindableGetterSetter(Context context, FunctionDefinitionNode def, boolean quiet, boolean publicOnly)
	{
		//	Note: getter/setters outside a class is nonsense code, but we're seeing the parse tree before any semantic analysis
		if (!inClass())
		{
			if (!quiet)
			{
				context.localizedError2(def.pos(), new BindableNotAllowedOnGlobalOrPackageFunctions());
			}
			return false;
		}

		//	non-public getter/setter && publicsOnly?
		if (publicOnly && (def.attrs == null || !def.attrs.hasAttribute(NodeMagic.PUBLIC)))
		{
			if (!quiet)
			{
				context.localizedError2(def.pos(), new BindableNotAllowedHereOnNonPublicFunctions());
			}
			return false;
		}

		return true;
	}

    /**
     *
     */
    private void setCurrentClass(Context context, ClassDefinitionNode node)
    {
        currentClassNode = node;
        visitedProps = null;

		if (isBindableClass(currentClassNode))
		{
			//	Creating bindableInfo unconditionally on [Bindable] classes ensures that they
			//	acquire bindability infrastructure, even if they lack properties.
			bindableInfo = new BindableInfo(context, typeTable.getSymbolTable());
		}
		else
		{
			bindableInfo = null;
		}
	}

    /**
     *
     */
    private boolean inClass()
    {
        return currentClassNode != null;
    }

    /**
     *
     */
    private boolean inManagedClass()
    {
        return inClass() && isManagedClass(currentClassNode);
    }

    /**
     *
     */
    private boolean inBindableClass()
    {
        return inClass() && isBindableClass(currentClassNode);
    }

	/**
	 *
	 */
	private void registerBindableClass(ClassDefinitionNode def)
	{
        (bindableClasses != null ? bindableClasses : (bindableClasses = new HashSet<DefinitionNode>())).add(def);
	}

	/**
	 *
	 */
	private boolean isBindableClass(DefinitionNode def)
	{
		return bindableClasses != null && bindableClasses.contains(def);
	}
	
	/**
	 * Called from {@link HostComponentExtension}'s parse2.  This adds a new bindable
	 * variable to the binding information after the {@link BindableFirstPassEvaluator} has
	 * already run from the parse1 method of the {@link BindableExtension}.  This method allows
	 * the {@link HostComponentExtension} to do all of its work in parse2 which when it has enough
	 * symbol table information to do its job properly.
	 * <p>
	 * This method can handle the case where the new bindable variable is the first bindable variable.
	 * @param context
	 * @param classNode
	 * @param varNode
	 */
	public void registerBindableVariable(Context context, ClassDefinitionNode classNode, VariableDefinitionNode varNode)
	{
		BindableInfo bInfo = classMap.get(NodeMagic.getClassName(classNode));
		if (bInfo == null) {
			bInfo = new BindableInfo(context, typeTable.getSymbolTable());
			bInfo.setClassName(NodeMagic.getUnqualifiedClassName(classNode));
			classMap.put(NodeMagic.getClassName(classNode), bInfo);

			NodeMagic.addImport(context, classNode, NameFormatter.toDot(standardDefs.CLASS_EVENT));
			NodeMagic.addImport(context, classNode, NameFormatter.toDot(standardDefs.CLASS_EVENTDISPATCHER));
			NodeMagic.addImport(context, classNode, NameFormatter.toDot(standardDefs.INTERFACE_IEVENTDISPATCHER));
			NodeMagic.addImport(context, classNode, NameFormatter.toDot(standardDefs.CLASS_BINDINGMANAGER));
		}
		
		assert !varNode.attrs.hasAttribute(NodeMagic.STATIC);
		bInfo.addAccessorVariable(varNode, false);
	}

    /**
     * register a bindable variable, due either to bindable on class, or directly on the variable
     */
    private void registerBindableVariable(Context context,
                                          VariableDefinitionNode node,
                                          boolean propLevel)
    {
        if (bindableInfo == null)
        {
            bindableInfo = new BindableInfo(context, typeTable.getSymbolTable());
        }

        if ((node.attrs != null) && node.attrs.hasAttribute(NodeMagic.STATIC))
        {
            bindableInfo.setRequiresStaticEventDispatcher(true);
        }

        bindableInfo.addAccessorVariable(node, propLevel);
    }

    /**
     * register a bindable getter or setter, due either to [Bindable] on class, or directly on the function.
     * Note that code will not actually be generated unless both a getter and setter are found. If a getter with no
     * setter is marked bindable, a warning is issued (later).
     */
    private void registerBindableGetterSetter(Context context,
                                              FunctionDefinitionNode node,
                                              boolean propLevel,
                                              boolean isGetter)
    {
        if (bindableInfo == null)
        {
            bindableInfo = new BindableInfo(context, typeTable.getSymbolTable());
        }

        if ((node.attrs != null) && node.attrs.hasAttribute(NodeMagic.STATIC))
        {
            bindableInfo.setRequiresStaticEventDispatcher(true);
        }

        bindableInfo.addAccessorFunction(node, propLevel, isGetter);

        registerVisitedGetterSetter(NodeMagic.getFunctionName(node), propLevel ? BINDABLE_CODEGEN_PROP : BINDABLE_CODEGEN_CLASS);
    }

    /**
     *
     */
    private void unregisterBindableAccessor(QName qname)
    {
        if (bindableInfo != null)
        {
            bindableInfo.removeAccessor(qname);
        }
    }

    /**
	 *
	 */
	private boolean isBindableAccessor(QName qname)
	{
		return bindableInfo != null && bindableInfo.hasAccessor(qname);
	}

    /**
     *
     */
    private void registerManagedClass(DefinitionNode def)
    {
        (managedClasses != null ? managedClasses : (managedClasses = new HashSet<DefinitionNode>())).add(def);
    }

    /**
     *
     */
    private boolean isManagedClass(DefinitionNode def)
    {
        return managedClasses != null && managedClasses.contains(def);
    }

	/**
	 *
	 */
	private void registerVisitedGetterSetter(String name, int bindType)
	{
        (visitedProps != null ? visitedProps : (visitedProps = new HashMap<String, Integer>())).put(name, new Integer(bindType));
	}

	/**
	 *
	 */
	private int getVisitedGetterSetterBindType(String name)
	{
        return visitedProps == null || !visitedProps.containsKey(name) ? BINDABLE_NONE
                : visitedProps.get(name).intValue();
	}

	/**
	 *
	 */
	public Map<String, BindableInfo> getClassMap()
	{
		return classMap != null ? classMap : Collections.<String, BindableInfo>emptyMap();
	}

	/**
	 *
	 */
    public boolean makeSecondPass()
    {
        return classMap != null && classMap.size() > 0;
    }

    /**
	 * Extract event name from metadata node. Note: <strong>we assume that checkBindableArgs has already been called</strong>.
	 */
	private static String getEventName(MetaDataNode node, Context context)
	{
		//	[Bindable( ... event="<eventname>" ... )]
		String eventName = node.getValue(StandardDefs.MDPARAM_BINDABLE_EVENT);
		if (eventName == null && node.count() == 1)
		{
			//	[Bindable("<eventname>")]
			eventName = node.getValue(0);
		}

		if (eventName != null && ! TextParser.isValidIdentifier(eventName))
		{
			context.localizedError2(node.pos(), new EventNameNotValid());
		}
		return eventName;
	}

    /**
     * CompilerMessages
     */
    public static class ClassBindableUnnecessaryOnManagedClass extends CompilerMessage.CompilerWarning
    {
        private static final long serialVersionUID = -4120994886934453698L;
    }

    public static class PropertyBindableUnnecessaryOnManagedClass extends CompilerMessage.CompilerWarning
    {
        private static final long serialVersionUID = 5345954896036961112L;
    }

    public static class PropertyBindableUnnecessaryOnBindableClass extends CompilerMessage.CompilerWarning
    {
        private static final long serialVersionUID = 8676289663338335097L;
    }

    public static class BindableFunctionRequiresEventName extends CompilerMessage.CompilerWarning
    {
        private static final long serialVersionUID = -158997496711365923L;
    }

    public static class BindableNotAllowedInsideFunctionDefinition extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -6225358794137597473L;
    }

    public static class BindableNotAllowedHere extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 4321459267717857499L;
    }

    public static class BindableNotAllowedOnGlobalOrPackageVariables extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -4467324380515362675L;
    }

    public static class BindableNotAllowedOnConstMemberVariables extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -6790403636487031318L;
    }

    public static class BindableNotAllowedOnStaticMemberVariables extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -912748026548162244L;
    }

    public static class BindableNotAllowedHereOnNonPublicMemberVariables extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 1242538769384014352L;
    }

    public static class BindableNotAllowedOnGlobalOrPackageFunctions extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 1325086298753296115L;
    }

    public static class BindableNotAllowedHereOnNonPublicFunctions extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -2691841106860119387L;
    }

	public static class EventNameNotValid extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -3786463371533992541L;
    }
}
