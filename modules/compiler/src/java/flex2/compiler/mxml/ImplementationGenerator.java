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

package flex2.compiler.mxml;

import flash.css.StyleCondition;
import flash.css.StyleDeclaration;
import flash.css.StyleDeclarationBlock;
import flash.css.StyleProperty;
import flash.css.StyleSelector;
import flex2.compiler.Source;
import flex2.compiler.as3.AbstractSyntaxTreeUtil;
import flex2.compiler.as3.As3Compiler;
import flex2.compiler.as3.BytecodeEmitter;
import flex2.compiler.css.StyleDef;
import flex2.compiler.mxml.lang.FrameworkDefs;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.gen.StatesGenerator;
import flex2.compiler.mxml.rep.AtEmbed;
import flex2.compiler.mxml.rep.AtResource;
import flex2.compiler.mxml.rep.BindingExpression;
import flex2.compiler.mxml.rep.DocumentInfo;
import flex2.compiler.mxml.rep.Model;
import flex2.compiler.mxml.rep.MovieClip;
import flex2.compiler.mxml.rep.MxmlDocument;
import flex2.compiler.mxml.rep.VariableDeclaration;
import flex2.compiler.mxml.rep.decl.PropertyDeclaration;
import flex2.compiler.mxml.rep.init.EffectInitializer;
import flex2.compiler.mxml.rep.init.EventInitializer;
import flex2.compiler.mxml.rep.init.Initializer;
import flex2.compiler.mxml.rep.init.NamedInitializer;
import flex2.compiler.mxml.rep.init.VisualChildInitializer;
import flex2.compiler.util.NameFormatter;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import macromedia.asc.embedding.ConfigVar;
import macromedia.asc.parser.*;
import macromedia.asc.util.ContextStatics;
import macromedia.asc.util.ObjectList;
import org.apache.commons.collections.Predicate;
import org.apache.commons.collections.iterators.FilterIterator;

/**
 * This class handles direct AST generation for the second pass full
 * implemenation.
 *
 * @author Paul Reilly
 */
public class ImplementationGenerator extends AbstractGenerator
{
    private static final String ASTERISK = "*";

    // intern all identifier constants
    private static final String __MODULE_FACTORY_INITIALIZED = "__moduleFactoryInitialized".intern();
    private static final String ACCEPT_MEDIA_LIST = "acceptMediaList".intern();
    private static final String ADD_EVENT_LISTENER = "addEventListener".intern();    
    private static final String ADDED_TO_STAGE = "ADDED_TO_STAGE".intern();    
    private static final String ARRAY = "Array".intern();
    private static final String BINDINGS = "bindings".intern();
    private static final String BOOLEAN = "Boolean".intern();
    private static final String CAPITAL_BINDING = "Binding".intern();
    private static final String CHILD_DESCRIPTORS = "childDescriptors".intern();
    private static final String CONCAT = "concat".intern();
    private static final String CONDITION = "condition".intern();
    private static final String CONDITIONS = "conditions".intern();
    private static final String CSS_CONDITION = "CSSCondition".intern();
    private static final String CSS_SELECTOR = "CSSSelector".intern();
    private static final String CSS_STYLE_DECLARATION = "CSSStyleDeclaration".intern();
    private static final String DEFAULT_FACTORY = "defaultFactory".intern();
    private static final String DESIGN_LAYER = "designLayer".intern();
    private static final String DESTINATION = "destination".intern();
    private static final String EFFECTS = "effects".intern();
    private static final String EMBED = "Embed".intern();
    private static final String EVENT_NAME = "event".intern();
    private static final String EVENT_TYPE = "Event".intern();
    private static final String EVENTS = "events".intern();
    private static final String EXECUTE = "execute".intern();
    private static final String FACTORY = "factory".intern();
    private static final String GET_DEFINITION_BY_NAME = "getDefinitionByName".intern();
    private static final String GET_STYLE_DECLARATION = "getStyleDeclaration".intern();
    private static final String GET_STYLE_MANAGER = "getStyleManager".intern();
    private static final String I = "i".intern();
    private static final String ID = "id".intern();
    private static final String IFLEX_MODULE_FACTORY = "IFlexModuleFactory".intern();
    private static final String INIT = "init".intern();
    private static final String INITIALIZE = "initialize".intern();
    private static final String INIT_PROTO_CHAIN_ROOTS = "initProtoChainRoots".intern();
    private static final String INSPECTABLE = "Inspectable".intern();
    private static final String INSTANCE_INDICES = "instanceIndices".intern();
    private static final String IS_TWO_WAY_PRIMARY = "isTwoWayPrimary".intern();
    private static final String ISTYLE_MANAGER2 = "IStyleManager2".intern();
    private static final String IWATCHER_SETUP_UTIL2 = "IWatcherSetupUtil2".intern();
    private static final String LENGTH = "length".intern();
    private static final String LOWERCASE_BINDING = "binding".intern();
    private static final String MODULE_FACTORY = "moduleFactory".intern();
    private static final String OBJECT = "Object".intern();
    private static final String PROXY = "Proxy".intern();
    private static final String PROPERTIES_FACTORY = "propertiesFactory".intern();
    private static final String PROPERTY_NAME = "propertyName".intern();
    private static final String PUSH = "push".intern();
    private static final String REGISTER_EFFECTS = "registerEffects".intern();
    private static final String REMOVE_EVENT_LISTENER = "removeEventListener".intern();    
    private static final String REPEATABLE_BINDING = "RepeatableBinding".intern();
    private static final String REPEATER_INDICES = "repeaterIndices".intern();
    private static final String RESOURCE_BUNDLE = "ResourceBundle".intern();
    private static final String RESULT = "result".intern();
    private static final String SELECTOR = "selector".intern();
    private static final String SETUP = "setup".intern();
    private static final String SET_DOCUMENT_DESCRIPTOR = "setDocumentDescriptor".intern();
    private static final String SET_STYLE_DECLARATION = "setStyleDeclaration".intern();
    private static final String STATIC = "static".intern();
    private static final String STRING = "String".intern();
    private static final String STYLE = "style".intern();
    private static final String STYLES_FACTORY = "stylesFactory".intern();
    private static final String STYLE_DECLARATION = "styleDeclaration".intern();
    private static final String STYLE_MANAGER_INSTANCE = "styleManager".intern();
    private static final String STYLE_MANAGER = "StyleManager".intern();
    private static final String TARGET = "target".intern();
    private static final String TWO_WAY_COUNTERPART = "twoWayCounterpart".intern();
    private static final String TYPE = "type".intern();
    private static final String UINT = "uint".intern();
    private static final String UI_COMPONENT_DESCRIPTOR = "UIComponentDescriptor".intern();
    private static final String UNDEFINED = "undefined".intern();
    private static final String WATCHERS = "watchers".intern();
    private static final String WATCHER_SETUP_UTIL = "watcherSetupUtil".intern();
    private static final String WATCHER_SETUP_UTIL_CLASS = "watcherSetupUtilClass".intern();
    private static final String _BINDINGS = "_bindings".intern();
    private static final String _DOCUMENT = "_document".intern();
    private static final String _DOCUMENT_DESCRIPTOR_ = "_documentDescriptor_".intern();
    private static final String _SOURCE_FUNCTION_RETURN_VALUE = "_sourceFunctionReturnValue".intern();
    private static final String _WATCHERS = "_watchers".intern();
    private static final String _WATCHER_SETUP_UTIL = "_watcherSetupUtil".intern();

    private MxmlDocument mxmlDocument;

    private boolean processComments = false;
    
    ImplementationGenerator(MxmlDocument mxmlDocument, boolean generateDocComments,
            ContextStatics contextStatics, Source source,
            BytecodeEmitter bytecodeEmitter, ObjectList<ConfigVar> defines)
    {
        this(mxmlDocument, generateDocComments, contextStatics, source, bytecodeEmitter, defines, false);
    }
    
    ImplementationGenerator(MxmlDocument mxmlDocument, boolean generateDocComments,
                            ContextStatics contextStatics, Source source,
                            BytecodeEmitter bytecodeEmitter, ObjectList<ConfigVar> defines, boolean processComments)
    {
        super(mxmlDocument.getStandardDefs());

        this.mxmlDocument = mxmlDocument;
        this.generateDocComments = generateDocComments;
        this.processComments = processComments;
        
        context = AbstractSyntaxTreeUtil.generateContext(contextStatics, source,
                                                         bytecodeEmitter, defines);
        nodeFactory = context.getNodeFactory();

        DocCommentNode packageDocComment = null;

        if (generateDocComments)
        {
            packageDocComment = generatePackageDocComment(mxmlDocument.getPackageName(),
                                                          mxmlDocument.getClassName(),
                                                          mxmlDocument.getSourcePath());
        }

        configNamespaces = new HashSet<String>();
        StatementListNode configVars = AbstractSyntaxTreeUtil.parseConfigVars(context, configNamespaces);
        programNode = AbstractSyntaxTreeUtil.generateProgram(context, configVars,
                                                             mxmlDocument.getPackageName(),
                                                             packageDocComment,
                                                             mxmlDocument.getRoot().getXmlLineNumber());
        StatementListNode programStatementList = programNode.statements;

        programStatementList = generateImports(programStatementList);
        programStatementList = generateAtResources(programStatementList);
        programStatementList = generateMetaData(programStatementList, mxmlDocument.getMetadata());

        if(processComments) 
        {
            MetaDataNode classDocComment = null;
            if(mxmlDocument.getComment() != null ) 
            {
                classDocComment = AbstractSyntaxTreeUtil.generateDocComment(nodeFactory, mxmlDocument.getComment().intern());
            } 
            else
            {
                classDocComment = AbstractSyntaxTreeUtil.generateDocComment(nodeFactory, "<description><![CDATA[]]></description>".intern());
            }
            
            if (classDocComment != null)
            {
                programStatementList = nodeFactory.statementList(programStatementList, classDocComment);
            }
        }
        
        ClassDefinitionNode classDefinition = generateClassDefinition();
        programStatementList = nodeFactory.statementList(programStatementList, classDefinition);
        programNode.statements = programStatementList;

        PackageDefinitionNode packageDefinition = nodeFactory.finishPackage(context, null);
        nodeFactory.statementList(programStatementList, packageDefinition);

        // Useful when comparing abstract syntax trees
        //flash.swf.tools.SyntaxTreeDumper.dump(programNode, "/tmp/" + mxmlDocument.getClassName() + "-generated.new.xml");

        As3Compiler.cleanNodeFactory(nodeFactory);
    }

	/**
	 * convenience wrapper for generating non-toplevel descriptor entries
	 */
	public static MemberExpressionNode addDescriptorInitializerFragments(NodeFactory nodeFactory,
                                                                         HashSet<String> configNamespaces,
                                                                         boolean generateDocComments,
                                                                         Model model, Set<String> includePropNames,
                                                                         boolean includeDesignLayer)
	{
		return addDescriptorInitializerFragments(nodeFactory, configNamespaces, generateDocComments,
                                                 model, includePropNames, false, includeDesignLayer);
	}

	/**
	 * @param includePropNames if non-null, this is a set of names of properties to include in the descriptor.
	 *
	 * A filtered set is sometimes needed to conform to the framework API, which requires a handful of properties
	 * (e.g. height, width) be encoded into the top-level descriptor, even though procedural code sets all top-level
	 * ('document') properties.
	 *
	 * Recursive calls to generateDescriptorCode() always pass null for this param, causing all child properties to be
	 * encoded, as required by the framework.
	 *
	 * Note: as with includePropNames, non-property entries are only suppressed (controlled by the propsOnly param to
	 * addDescriptorInitializerFragments being set to true) at the top level of the descriptor.
	 *
	 * Note: _childDescriptor, built from MovieClip.children, is encoded unconditionally at all levels.
	 *
	 * @param propsOnly if true, event, effect and style entries are suppressed. This is a top- vs. nontop-level
	 * constraint, like includePropNames.
	 */
	private static MemberExpressionNode addDescriptorInitializerFragments(NodeFactory nodeFactory,
                                                                          HashSet<String> configNamespaces,
                                                                          boolean generateDocComments,
                                                                          Model model, Set includePropNames,
                                                                          boolean propsOnly, boolean includeDesignLayer)
	{
		model.setDescribed(true);

        LiteralStringNode mxCoreLiteralString = nodeFactory.literalString(model.getStandardDefs().getCorePackage(), false);
        QualifiedIdentifierNode uiComponentDescriptorQualifiedIdentifier =
            nodeFactory.qualifiedIdentifier(mxCoreLiteralString, UI_COMPONENT_DESCRIPTOR);

        IdentifierNode typeIdentifier = nodeFactory.identifier(TYPE, false);
        String modelTypeName = model.getType().getName();
        String packageName = NameFormatter.retrievePackageName(modelTypeName);
        String className = NameFormatter.retrieveClassName(modelTypeName).intern();
        Node modelTypeIdentifier;

        int position = AbstractSyntaxTreeUtil.lineNumberToPosition(nodeFactory, model.getXmlLineNumber());
        
        if (packageName.equals(""))
        {
            modelTypeIdentifier = nodeFactory.identifier(className, false);
        }
        else
        {
            LiteralStringNode packageNameLiteralString = nodeFactory.literalString(packageName);
            modelTypeIdentifier = nodeFactory.qualifiedIdentifier(packageNameLiteralString, className);
        }

        GetExpressionNode typeGetExpression = nodeFactory.getExpression(modelTypeIdentifier, position);
        MemberExpressionNode typeMemberExpression = nodeFactory.memberExpression(null, typeGetExpression);
        LiteralFieldNode typeLiteralField = nodeFactory.literalField(typeIdentifier, typeMemberExpression);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, typeLiteralField);

		//	id?
		if (model.isDeclared())
		{
            IdentifierNode idIdentifier = nodeFactory.identifier(ID, false);
            LiteralStringNode idLiteralString = nodeFactory.literalString(model.getId());
            LiteralFieldNode idLiteralField = nodeFactory.literalField(idIdentifier, idLiteralString);
            argumentList = nodeFactory.argumentList(argumentList, idLiteralField);
		}
        
		//	events?
		if (!propsOnly)
        {
			argumentList = addDescriptorEvents(nodeFactory, argumentList, model);
        }

		//	effect names?
		if (!propsOnly)
        {
			argumentList = addDescriptorEffectNames(nodeFactory, argumentList, model);
        }

		//	styles and/or effects?
		if (!propsOnly)
        {
			argumentList = addDescriptorStylesAndEffects(nodeFactory, configNamespaces, generateDocComments, argumentList, model);
        }

		//	descriptor properties are Model.properties + synthetic property 'childDescriptors' from MovieClip.children
		argumentList = addDescriptorProperties(nodeFactory, configNamespaces, generateDocComments, argumentList,
                                               model, includePropNames, includeDesignLayer);

        LiteralObjectNode literalObject = nodeFactory.literalObject(argumentList);
        ArgumentListNode uiComponentDescriptorArgumentList = nodeFactory.argumentList(null, literalObject);
        CallExpressionNode uiComponentDescriptorCallExpression =
            (CallExpressionNode) nodeFactory.callExpression(uiComponentDescriptorQualifiedIdentifier,
                                                            uiComponentDescriptorArgumentList);
        uiComponentDescriptorCallExpression.is_new = true;
        uiComponentDescriptorCallExpression.setRValue(false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, uiComponentDescriptorCallExpression);

        return memberExpression;
	}

    /**
     *
     */
    private static ArgumentListNode addDescriptorProperties(NodeFactory nodeFactory, HashSet<String> configNamespaces,
                                                            boolean generateDocComments, ArgumentListNode argumentList,
                                                            Model model, final Set includePropNames, boolean includeDesignLayer)
    {
        //  ordinary properties
        Iterator propIter = includePropNames == null ?
            model.getPropertyInitializerIterator(false) :
            new FilterIterator(model.getPropertyInitializerIterator(false), new Predicate() {
                    public boolean evaluate(Object obj)
                    {
                        return includePropNames.contains(((NamedInitializer) obj).getName());
                    }
                });

        //  visual children
        Iterator vcIter = (model instanceof MovieClip && ((MovieClip)model).hasChildren()) ?
            ((MovieClip)model).children().iterator() :
            Collections.EMPTY_LIST.iterator();

        // designLayer ?
        Boolean hasDesignLayer = (includeDesignLayer && (model.layerParent != null) &&
                                  model.getType().isAssignableTo(model.getStandardDefs().INTERFACE_IVISUALELEMENT));
            
        if (propIter.hasNext() || vcIter.hasNext() || hasDesignLayer)
        {
            IdentifierNode propertiesFactoryIdentifier = nodeFactory.identifier(PROPERTIES_FACTORY, false);
            MemberExpressionNode objectMemberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, OBJECT, false);
            TypeExpressionNode typeExpression = nodeFactory.typeExpression(objectMemberExpression,
                                                                           true, false, -1);
            FunctionSignatureNode functionSignature = nodeFactory.functionSignature(null, typeExpression);
            ArgumentListNode propertiesFactoryArgumentList = null;

            // properties
            while (propIter.hasNext())
            {
                NamedInitializer init = (NamedInitializer) propIter.next();
                if (!init.isStateSpecific())
                {
                    IdentifierNode propertyIdentifier = nodeFactory.identifier(init.getName());
                    Node valueExpr = init.generateValueExpr(nodeFactory, configNamespaces, generateDocComments);
                    LiteralFieldNode propertyLiteralField = nodeFactory.literalField(propertyIdentifier,
                                                                                 valueExpr);
                    propertiesFactoryArgumentList = nodeFactory.argumentList(propertiesFactoryArgumentList,
                                                                         propertyLiteralField);
                }
            }

            // designLayer
            if (hasDesignLayer)
            {
            	if (model.getType().isAssignableTo(model.getStandardDefs().INTERFACE_IVISUALELEMENT))
                {
                    IdentifierNode layerPropertyIdentifier = nodeFactory.identifier(DESIGN_LAYER, false);
                    MemberExpressionNode memberExpression =
                        AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, model.layerParent.getId(), true);
                	LiteralFieldNode layerLiteralField = nodeFactory.literalField(layerPropertyIdentifier, memberExpression);
                	propertiesFactoryArgumentList = nodeFactory.argumentList(propertiesFactoryArgumentList,
                			layerLiteralField);
                } 
            }
            
            // visual children
            if (vcIter.hasNext())
            {
                IdentifierNode childDescriptorsIdentifier = nodeFactory.identifier(CHILD_DESCRIPTORS, false);
                ArgumentListNode childDescriptorsArgumentList = null;

                while (vcIter.hasNext())
                {
                    VisualChildInitializer init = (VisualChildInitializer) vcIter.next();
                    Model child = (MovieClip)init.getValue();
                    if (child.isDescriptorInit()) 
                    {
                        MemberExpressionNode memberExpression =
                            addDescriptorInitializerFragments(nodeFactory, configNamespaces, generateDocComments,
                                                              (MovieClip) init.getValue(), null, true);
                        childDescriptorsArgumentList = nodeFactory.argumentList(childDescriptorsArgumentList,
                                                                            memberExpression);
                    }
                }

                LiteralArrayNode literalArray = nodeFactory.literalArray(childDescriptorsArgumentList);
                LiteralFieldNode childDescriptorsLiteralField =
                    nodeFactory.literalField(childDescriptorsIdentifier, literalArray);
                propertiesFactoryArgumentList = nodeFactory.argumentList(propertiesFactoryArgumentList,
                                                                         childDescriptorsLiteralField);
            }

            LiteralObjectNode literalObject = nodeFactory.literalObject(propertiesFactoryArgumentList);
            ListNode list = nodeFactory.list(null, literalObject);
            ReturnStatementNode returnStatement = nodeFactory.returnStatement(list);
            StatementListNode body = nodeFactory.statementList(null, returnStatement);
            FunctionCommonNode functionCommon = nodeFactory.functionCommon(nodeFactory.getContext(),
                                                                           null, functionSignature, body);
            functionCommon.setUserDefinedBody(true);
            LiteralFieldNode propertiesFactoryLiteralField =
                nodeFactory.literalField(propertiesFactoryIdentifier, functionCommon);
            argumentList = nodeFactory.argumentList(argumentList, propertiesFactoryLiteralField);
        }

        return argumentList;
    }

	/**
	 *
	 */
	private static ArgumentListNode addDescriptorStylesAndEffects(NodeFactory nodeFactory,
                                                                  HashSet<String> configNamespaces,
                                                                  boolean generateDocComments,
                                                                  ArgumentListNode argumentList, Model model)
	{
		Iterator styleAndEffectIter = model.getStyleAndEffectInitializerIterator();

		if (styleAndEffectIter.hasNext())
		{
            IdentifierNode stylesFactoryIdentifier = nodeFactory.identifier(STYLES_FACTORY, false);
            FunctionSignatureNode functionSignature = nodeFactory.functionSignature(null, null);
            functionSignature.void_anno = true;
            StatementListNode body = null;

			while (styleAndEffectIter.hasNext())
			{
				NamedInitializer init = (NamedInitializer) styleAndEffectIter.next();
                ThisExpressionNode thisExpression = nodeFactory.thisExpression(-1);
                IdentifierNode identifier = nodeFactory.identifier(init.getName());
                Node valueExpr = init.generateValueExpr(nodeFactory, configNamespaces, generateDocComments);
                ArgumentListNode styleAndEffectArgumentList = nodeFactory.argumentList(null, valueExpr);
                SetExpressionNode setExpression = nodeFactory.setExpression(identifier, styleAndEffectArgumentList, false);
                MemberExpressionNode memberExpression = nodeFactory.memberExpression(thisExpression, setExpression);
                ListNode styleAndEffectList = nodeFactory.list(null, memberExpression);
                ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(styleAndEffectList);
                body = nodeFactory.statementList(body, expressionStatement);
			}

            FunctionCommonNode functionCommon = nodeFactory.functionCommon(nodeFactory.getContext(),
                                                                           null, functionSignature, body);
            functionCommon.setUserDefinedBody(true);
            LiteralFieldNode stylesFactoryLiteralField = nodeFactory.literalField(stylesFactoryIdentifier,
                                                                                  functionCommon);
            argumentList = nodeFactory.argumentList(argumentList, stylesFactoryLiteralField);
		}

        return argumentList;
	}

	/**
	 *
	 */
	private static ArgumentListNode addDescriptorEffectNames(NodeFactory nodeFactory,
                                                             ArgumentListNode argumentList, Model model)
	{
		Iterator effectEventNameIterator = model.getEffects().values().iterator();

		if (effectEventNameIterator.hasNext())
		{
            IdentifierNode effectsIdentifier = nodeFactory.identifier(EFFECTS, false);
            ArgumentListNode effectsArgumentList = null;

            while (effectEventNameIterator.hasNext())
            {
                EffectInitializer effectInitializer = (EffectInitializer) effectEventNameIterator.next();
                LiteralStringNode literalString = nodeFactory.literalString(effectInitializer.getName());
                effectsArgumentList = nodeFactory.argumentList(effectsArgumentList, literalString);
            }

            LiteralArrayNode literalArray = nodeFactory.literalArray(effectsArgumentList);
            LiteralFieldNode literalField = nodeFactory.literalField(effectsIdentifier, literalArray);
            argumentList = nodeFactory.argumentList(argumentList, literalField);
		}

        return argumentList;
	}

	/**
	 *
	 */
	private static ArgumentListNode addDescriptorEvents(NodeFactory nodeFactory,
                                                        ArgumentListNode argumentList, Model model)
	{
		Iterator eventIter = model.getEventInitializerIterator();

		if (eventIter.hasNext())
		{
            IdentifierNode eventsIdentifier = nodeFactory.identifier(EVENTS, false);
            ArgumentListNode eventsArgumentList = null;

			while (eventIter.hasNext())
			{
				EventInitializer init = (EventInitializer) eventIter.next();
				IdentifierNode identifier = nodeFactory.identifier(init.getName());
                LiteralStringNode literalString = nodeFactory.literalString(init.getValueExpr());
                LiteralFieldNode literalField = nodeFactory.literalField(identifier, literalString);
                eventsArgumentList = nodeFactory.argumentList(eventsArgumentList, literalField);
			}

            LiteralObjectNode eventsLiteralObject = nodeFactory.literalObject(eventsArgumentList);
            LiteralFieldNode eventsLiteralField = nodeFactory.literalField(eventsIdentifier, eventsLiteralObject);
            argumentList = nodeFactory.argumentList(argumentList, eventsLiteralField);
		}

        return argumentList;
	}

    private Set<String> createInterfaceNames()
    {
        Set<String> result = new TreeSet<String>();
        Iterator<DocumentInfo.NameInfo> iterator = mxmlDocument.getInterfaceNames().iterator();

        while (iterator.hasNext())
        {
            result.add(iterator.next().getName());
        }

        return result;
    }

    protected StatementListNode generateAtResources(StatementListNode programStatementList)
    {
        StatementListNode result = programStatementList;
        Iterator<AtResource> iterator = mxmlDocument.getAtResources().iterator();

        while (iterator.hasNext())
        {
            //[ResourceBundle("$atResource.bundle")]
            String bundle = iterator.next().getBundle();
            MetaDataNode metaData =
                AbstractSyntaxTreeUtil.generateMetaData(nodeFactory, RESOURCE_BUNDLE, bundle);
            result = nodeFactory.statementList(result, metaData);
        }

        return result;
    }

    private ExpressionStatementNode generateBinding(BindingExpression bindingExpression)
    {
        // result[${bindingExpression.id}] = new mx.binding.Binding(this, ...
        MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, RESULT, false);
        LiteralNumberNode literalNumber = nodeFactory.literalNumber(bindingExpression.getId());
        ArgumentListNode literalNumberArgumentList = nodeFactory.argumentList(null, literalNumber);

        QualifiedIdentifierNode qualifiedIdentifier =
            AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory, standardDefs.getBindingPackage(), CAPITAL_BINDING, false);
        ThisExpressionNode thisExpression = nodeFactory.thisExpression(-1);
        ArgumentListNode callArgumentList = nodeFactory.argumentList(null, thisExpression);

        if (bindingExpression.isSourcePublicProperty() && !bindingExpression.getDestinationTypeName().equals(ARRAY))
        {
            int position = AbstractSyntaxTreeUtil.lineNumberToPosition(nodeFactory, bindingExpression.getXmlLineNumber());
            LiteralNullNode literalNull = nodeFactory.literalNull(position);
            callArgumentList = nodeFactory.argumentList(callArgumentList, literalNull);
        }
        else
        {
            FunctionCommonNode sourceFunctionCommon = generateSourceFunction(bindingExpression);
            callArgumentList = nodeFactory.argumentList(callArgumentList, sourceFunctionCommon);
        }

        if (bindingExpression.isSimpleChain() && !bindingExpression.isDestinationNonPublicProperty() )
        {
            LiteralNullNode literalNull = nodeFactory.literalNull(-1);
            callArgumentList = nodeFactory.argumentList(callArgumentList, literalNull);
        }
        else
        {
            FunctionCommonNode destinationFunctionCommon = generateDestinationFunction(bindingExpression);
            callArgumentList = nodeFactory.argumentList(callArgumentList, destinationFunctionCommon);
        }

        LiteralStringNode destLiteralString = nodeFactory.literalString(bindingExpression.getDestinationPath(false));
        callArgumentList = nodeFactory.argumentList(callArgumentList, destLiteralString);

        if (bindingExpression.isSourcePublicProperty())
        {
            LiteralStringNode srcLiteralString = nodeFactory.literalString(bindingExpression.getSourceAsProperty());
            callArgumentList = nodeFactory.argumentList(callArgumentList, srcLiteralString);
        }

        CallExpressionNode callExpression = (CallExpressionNode) nodeFactory.callExpression(qualifiedIdentifier,
                                                                                                callArgumentList);
        callExpression.is_new = true;
        callExpression.setRValue(false);
        MemberExpressionNode bindingMemberExpression = nodeFactory.memberExpression(null, callExpression);
        ArgumentListNode setArgumentList = nodeFactory.argumentList(null, bindingMemberExpression);
        SetExpressionNode selector = nodeFactory.setExpression(literalNumberArgumentList,
                                                               setArgumentList, false);
        selector.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    private Node generateBindingsForLoop()
    {
        // for (var i:uint = 0; i < bindings.length; i++)
        // Binding(bindings[i]).execute();

        MemberExpressionNode iMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, I, false);
        MemberExpressionNode bindingsMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, BINDINGS, false);

        IdentifierNode lengthIdentifier = nodeFactory.identifier(LENGTH, false);
        GetExpressionNode lengthGetExpression = nodeFactory.getExpression(lengthIdentifier);
        lengthGetExpression.setMode(Tokens.DOT_TOKEN);
        MemberExpressionNode lengthMemberExpression = nodeFactory.memberExpression(bindingsMemberExpression,
                                                                                   lengthGetExpression);

        BinaryExpressionNode binaryExpression = nodeFactory.binaryExpression(Tokens.LESSTHAN_TOKEN,
                                                                             iMemberExpression,
                                                                             lengthMemberExpression);
        ListNode test = nodeFactory.list(null, binaryExpression);

        IdentifierNode iIdentifier = nodeFactory.identifier(I, false);
        IncrementNode incrementNode = nodeFactory.increment(Tokens.PLUSPLUS_TOKEN, iIdentifier, true);
        MemberExpressionNode iteratorMemberExpression = nodeFactory.memberExpression(null,
                                                                                     incrementNode);
        ListNode increment = nodeFactory.list(null, iteratorMemberExpression);

        IdentifierNode bindingIdentifier = nodeFactory.identifier(CAPITAL_BINDING, false);
        bindingsMemberExpression = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory,
                                                                                 BINDINGS, false);
        iMemberExpression = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, I, false);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, iMemberExpression);
        GetExpressionNode getExpression = nodeFactory.getExpression(argumentList);
        getExpression.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(bindingsMemberExpression,
                                                                             getExpression);
        ArgumentListNode callArgumentList = nodeFactory.argumentList(null, memberExpression);
        CallExpressionNode bindingCallExpression =
            (CallExpressionNode) nodeFactory.callExpression(bindingIdentifier, callArgumentList);
        bindingCallExpression.setRValue(false);
        MemberExpressionNode base = nodeFactory.memberExpression(null, bindingCallExpression);
        IdentifierNode executeIdentifier = nodeFactory.identifier(EXECUTE, false);
        CallExpressionNode executeCallExpression =
            (CallExpressionNode) nodeFactory.callExpression(executeIdentifier, null);
        executeCallExpression.setRValue(false);
        MemberExpressionNode MemberExpression = nodeFactory.memberExpression(base, executeCallExpression);
        ListNode list = nodeFactory.list(null, MemberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        StatementListNode statement = nodeFactory.statementList(null, expressionStatement);

        return nodeFactory.forStatement(null, test, increment, statement);
    }

    private StatementListNode generateBindingManagementVars(StatementListNode statementList)
    {
        StatementListNode result = statementList;

        Iterator<VariableDeclaration> iterator = MxmlDocument.getBindingManagementVars().iterator();

        while (iterator.hasNext())
        {
            VariableDeclaration variableDeclaration = iterator.next();
            if (!mxmlDocument.superHasPublicProperty(variableDeclaration.getName()))
            {
                if (generateDocComments)
                {
                    DocCommentNode docComment =
                        AbstractSyntaxTreeUtil.generatePrivateDocComment(nodeFactory);
                    result = nodeFactory.statementList(result, docComment);
                }

                //$var.namespace var $var.name : $var.type = $var.initializer;
                String initializerString = variableDeclaration.getInitializer();
                Node initializerNode = null;

                if (initializerString.equals("[]"))
                {
                    initializerNode = nodeFactory.literalArray(null);
                }
                else if (initializerString.equals("{}"))
                {
                    initializerNode = nodeFactory.literalObject(null);
                }
                else
                {
                    assert false : initializerString;
                }

                String variableName = variableDeclaration.getName();
                QualifiedIdentifierNode qualifiedIdentifier =
                    AbstractSyntaxTreeUtil.generateMxInternalQualifiedIdentifier(nodeFactory,
                                                                                 variableName,
                                                                                 false);
                VariableDefinitionNode variableDefinition =
                    AbstractSyntaxTreeUtil.generateVariable(nodeFactory,
                                                            generateMxInternalAttribute(),
                                                            qualifiedIdentifier,
                                                            variableDeclaration.getType(),
                                                            false,
                                                            initializerNode);

                result = nodeFactory.statementList(result, variableDefinition);
            }
        }

        return result;
    }

    private ExpressionStatementNode generateBindingsAssignment()
    {
        MemberExpressionNode mxInternalGetterSelector =
            AbstractSyntaxTreeUtil.generateResolvedGetterSelector(nodeFactory, standardDefs.getCorePackage(), MX_INTERNAL);
        QualifiedIdentifierNode qualifiedIdentifier =
            AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory, mxInternalGetterSelector,
                                                               _BINDINGS, false);
        MemberExpressionNode rvalueBase = generateMxInternalGetterSelector(_BINDINGS, false);
        IdentifierNode concatIdentifier = nodeFactory.identifier(CONCAT, false);
        MemberExpressionNode bindingsMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, BINDINGS, false);
        ArgumentListNode concatArgumentList = nodeFactory.argumentList(null, bindingsMemberExpression);
        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(concatIdentifier, concatArgumentList);
        callExpression.setRValue(false);
        MemberExpressionNode argument = nodeFactory.memberExpression(rvalueBase, callExpression);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, argument);
        SetExpressionNode setExpression = nodeFactory.setExpression(qualifiedIdentifier, argumentList, false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, setExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    /**
     * Equivalent from ClassDefLib.vm:
     * <PRE>
     * private function ${convertedClassName}_bindingExprs():void
     * {
     *     ${doc.getAllBindingNamespaceDeclarations()}
     *     #foreach ($bindingExpression in $doc.bindingExpressions)
     *     #if (!$bindingExpression.destination)
     *     #embedText("$bindingExpression.destinationProperty = $bindingExpression.sourceExpression;" $bindingExpression.xmlLineNumber)
     *     #end
     *     #end
     * }
     * </PRE>
     */
    private StatementListNode generateBindingExprsFunction(StatementListNode statementList) 	 
    { 	 
        StatementListNode result = statementList; 	 
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(null, null); 	 
        functionSignature.void_anno = true; 	 
        VariableDefinitionNode variableDefinition = 	 
            AbstractSyntaxTreeUtil.generateVariable(nodeFactory, DESTINATION, false); 	 
        StatementListNode functionStatementList = nodeFactory.statementList(null, 	 
                                                                            variableDefinition); 	 
	  	 
        // ${doc.getAllBindingNamespaces()} 	 
        Map<Integer, String> allNs = mxmlDocument.getAllBindingNamespaces(); 	 
        if (allNs.size() > 0) 	 
        { 	 
            functionStatementList = BindingExpression.generateNamespaceDeclarations(allNs, context, 	 
                                                                                    functionStatementList); 	 
        } 	 
	  	 
        for (BindingExpression bindingExpression : mxmlDocument.getBindingExpressions()) 	 
        { 	 
            if (bindingExpression.getDestination() == null) 	 
            { 	 
                //$bindingExpression.destinationProperty = $bindingExpression.sourceExpression; 	 
                String text = (bindingExpression.getDestinationProperty() + " = " + 	 
                               bindingExpression.getSourceExpression()); 	 
                int xmlLineNumber = bindingExpression.getXmlLineNumber(); 	 
                List<Node> nodeList =
                    AbstractSyntaxTreeUtil.parseExpression(context, configNamespaces, text,
                                                           xmlLineNumber, generateDocComments);
	  	 
                if (!nodeList.isEmpty()) 	 
                { 	 
                    functionStatementList = nodeFactory.statementList(functionStatementList, nodeList.get(0));
                } 	 
            } 	 
        } 	 
	  	 
        FunctionCommonNode functionCommon = nodeFactory.functionCommon(context, null, functionSignature, 	 
                                                                       functionStatementList); 	 
        functionCommon.setUserDefinedBody(true); 	 
	  	 
        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generatePrivateAttribute(nodeFactory); 	 
        IdentifierNode bindingsSetupIdentifier = nodeFactory.identifier(mxmlDocument.getConvertedClassName() + 	 
                                                                        "_bindingExprs"); 	 
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.EMPTY_TOKEN, bindingsSetupIdentifier); 	 
	  	 
        FunctionDefinitionNode functionDefinition = nodeFactory.functionDefinition(context, attributeList, 	 
                                                                                   functionName, functionCommon); 	 
        return nodeFactory.statementList(result, functionDefinition); 	 
    }

    private StatementListNode generateBindingsSetup(StatementListNode statementList)
    {
        StatementListNode result = statementList;

        result = generateBindingsSetupFunction(result);

        if (mxmlDocument.hasBindingTags()) 	 
        { 	 
            // Output a source to destination assignment expression
            // for each Binding tag, so that ASC can detect coercion
            // errors.  This function is never called, so we could
            // potentially remove it before code generation.
            result = generateBindingExprsFunction(result);
        }

        result = generateSetWatcherSetupUtilFunction(result);

        AttributeListNode attributeList =
            AbstractSyntaxTreeUtil.generatePrivateStaticAttribute(nodeFactory);
        QualifiedIdentifierNode qualifiedIdentifier =
            AbstractSyntaxTreeUtil.generateMxInternalQualifiedIdentifier(nodeFactory,
                                                                         _WATCHER_SETUP_UTIL,
                                                                         false);
        VariableDefinitionNode variableDefinition =
            AbstractSyntaxTreeUtil.generateVariable(nodeFactory, attributeList,
                                                    qualifiedIdentifier,
                                                    IWATCHER_SETUP_UTIL2, false, null);

        return nodeFactory.statementList(result, variableDefinition);
    }

    private StatementListNode generateBindingsSetupFunction(StatementListNode statementList)
    {
        StatementListNode result = statementList;
        MemberExpressionNode arrayMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, ARRAY, false);
        TypeExpressionNode returnType = nodeFactory.typeExpression(arrayMemberExpression, true, false, -1);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(null, returnType);

        Node resultVariableDefinition = generateResultVariable();
        StatementListNode functionStatementList = nodeFactory.statementList(null, resultVariableDefinition);

        Iterator<BindingExpression> iterator = mxmlDocument.getBindingExpressions().iterator();

        while (iterator.hasNext())
        {
            BindingExpression bindingExpression = iterator.next();

            if (bindingExpression.isRepeatable())
            {
                ExpressionStatementNode expressionStatement = generateRepeatableBinding(bindingExpression);
                functionStatementList = nodeFactory.statementList(functionStatementList, expressionStatement);
            }
            else
            {
                ExpressionStatementNode expressionStatement = generateBinding(bindingExpression);
                functionStatementList = nodeFactory.statementList(functionStatementList, expressionStatement);
            }

            if (bindingExpression.getTwoWayCounterpart() != null)
            {
                if (bindingExpression.isTwoWayPrimary())
                {
                    // result[${bindingExpression.id}].isTwoWayPrimary = true;
                    ExpressionStatementNode expressionStatement =
                        generateIsTwoWayPrimaryAssignment(bindingExpression.getId());
                    functionStatementList = nodeFactory.statementList(functionStatementList, expressionStatement);
                }

                {
                    // result[${bindingExpression.id}].twoWayCounterpart = result[${bindingExpression.twoWayCounterpart.id}];
                    ExpressionStatementNode expressionStatement =
                        generateTwoWayCounterpartAssignment(bindingExpression.getId(),
                                                            bindingExpression.getTwoWayCounterpart().getId());
                    functionStatementList = nodeFactory.statementList(functionStatementList, expressionStatement);
                }

                if (bindingExpression.getTwoWayCounterpart().isTwoWayPrimary())
                {
                    // result[${bindingExpression.twoWayCounterpart.id}].isTwoWayPrimary = true;
                    ExpressionStatementNode expressionStatement =
                        generateIsTwoWayPrimaryAssignment(bindingExpression.getTwoWayCounterpart().getId());
                    functionStatementList = nodeFactory.statementList(functionStatementList, expressionStatement);
                }

                {
                    //result[${bindingExpression.twoWayCounterpart.id}].twoWayCounterpart = result[${bindingExpression.id}];
                    ExpressionStatementNode expressionStatement =
                        generateTwoWayCounterpartAssignment(bindingExpression.getTwoWayCounterpart().getId(),
                                                            bindingExpression.getId());
                    functionStatementList = nodeFactory.statementList(functionStatementList, expressionStatement);
                }
            }
        }

        MemberExpressionNode memberExpression = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory,
                                                                                              RESULT, false);
        ListNode list = nodeFactory.list(null, memberExpression);
        ReturnStatementNode returnStatement = nodeFactory.returnStatement(list);
        functionStatementList = nodeFactory.statementList(functionStatementList, returnStatement);

        FunctionCommonNode functionCommon = nodeFactory.functionCommon(context, null, functionSignature,
                                                                       functionStatementList);
        functionCommon.setUserDefinedBody(true);

        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generatePrivateAttribute(nodeFactory);
        IdentifierNode bindingsSetupIdentifier = nodeFactory.identifier(mxmlDocument.getConvertedClassName() +
                                                                        "_bindingsSetup");
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.EMPTY_TOKEN, bindingsSetupIdentifier);

        FunctionDefinitionNode functionDefinition = nodeFactory.functionDefinition(context, attributeList,
                                                                                   functionName, functionCommon);
        return nodeFactory.statementList(result, functionDefinition);
    }

    private Node generateBindingVariable()
    {
        int kind = Tokens.VAR_TOKEN;
        QualifiedIdentifierNode qualifiedIdentifier = nodeFactory.qualifiedIdentifier(null, LOWERCASE_BINDING);
        MemberExpressionNode memberExpression = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, CAPITAL_BINDING, false);
        TypeExpressionNode typeExpression = nodeFactory.typeExpression(memberExpression, true, false, -1);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(qualifiedIdentifier, typeExpression);
        VariableBindingNode variableBinding = nodeFactory.variableBinding(null, kind, typedIdentifier, null);
        ListNode list = nodeFactory.list(null, variableBinding);
        return nodeFactory.variableDefinition(null, kind, list);
    }

    private Node generateBindingsVariable()
    {
        int kind = Tokens.VAR_TOKEN;
        QualifiedIdentifierNode qualifiedIdentifier = nodeFactory.qualifiedIdentifier(null, BINDINGS);
        MemberExpressionNode memberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, ARRAY, false);
        TypeExpressionNode typeExpression = nodeFactory.typeExpression(memberExpression, true, false, -1);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(qualifiedIdentifier, typeExpression);

        IdentifierNode bindingsSetupIdentifier = nodeFactory.identifier(mxmlDocument.getConvertedClassName() +
                                                                        "_bindingsSetup");
        CallExpressionNode callExpression = (CallExpressionNode) nodeFactory.callExpression(bindingsSetupIdentifier,
                                                                                            null);
        callExpression.setRValue(false);
        MemberExpressionNode initializer = nodeFactory.memberExpression(null, callExpression);
        VariableBindingNode variableBinding = nodeFactory.variableBinding(null, kind, typedIdentifier, initializer);
        ListNode list = nodeFactory.list(null, variableBinding);
        return nodeFactory.variableDefinition(null, kind, list);
    }

    private ClassDefinitionNode generateClassDefinition()
    {
        StatementListNode statementList = null;
        
        statementList = generateInstanceVariables(statementList);
        statementList = generateTypeImportDummies(statementList);

        String className = mxmlDocument.getClassName();

        if (mxmlDocument.getIsIUIComponent())
        {
            if (mxmlDocument.getDescribeVisualChildren() && 
                mxmlDocument.getIsContainer())
            {
                // Container document descriptor
                MemberExpressionNode memberExpression =
                    AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, standardDefs.getCorePackage(),
                                                                  UI_COMPONENT_DESCRIPTOR, false);
                TypeExpressionNode typeExpression = nodeFactory.typeExpression(memberExpression, true, false, -1);
                MemberExpressionNode initializer = getDescriptorInitializerFragments(nodeFactory, configNamespaces,
                                                                                     generateDocComments, mxmlDocument.getRoot());
                Node documentDescriptorVariableDefinition =
                    AbstractSyntaxTreeUtil.generatePrivateVariable(nodeFactory, typeExpression,
                                                                   _DOCUMENT_DESCRIPTOR_, initializer);
                statementList = nodeFactory.statementList(statementList, documentDescriptorVariableDefinition);
            }

            StatementListNode constructorStatementList = null;
            if (mxmlDocument.getIsContainer() || mxmlDocument.getIsVisualElementContainer())
            {
                ExpressionStatementNode expressionStatement = generateDocumentAssignment();
                constructorStatementList = nodeFactory.statementList(constructorStatementList,
                                                                     expressionStatement);
            }
            
            constructorStatementList = generateBindingInitializers(constructorStatementList);
            constructorStatementList = generateComponentInitializers(constructorStatementList);
            constructorStatementList = generateStatesInitializers(constructorStatementList);
            constructorStatementList = generateInitialBindingExecutions(constructorStatementList);
           	
            statementList = generateConstructor(statementList, generateDocComments,
                                                className, null, 
                                                constructorStatementList);

           	if (mxmlDocument.getIsIFlexModule())
           	{
           		statementList = nodeFactory.statementList(statementList, 
           										generateModuleFactoryInitializedVariable());
           		
           		StatementListNode moduleFactoryStatementList = generateComponentStyleInitializers(null);
           		
           		if (generateDocComments)
           		{
           		    DocCommentNode docComment = AbstractSyntaxTreeUtil.generatePrivateDocComment(nodeFactory);
           		    statementList = nodeFactory.statementList(statementList, docComment);
           		}
           		
           		FunctionDefinitionNode functionDefinition = generateModuleFactoryPropertyOverride(moduleFactoryStatementList);
           		statementList = nodeFactory.statementList(statementList, functionDefinition);
           	}

           	if (generateDocComments)
            {
                DocCommentNode docComment =
                    AbstractSyntaxTreeUtil.generatePrivateDocComment(nodeFactory);
                statementList = nodeFactory.statementList(statementList, docComment);
            }
            
            statementList = nodeFactory.statementList(statementList, generateInitializeFunction());
        }
        else
        {
            StatementListNode constructorStatementList = null;

            constructorStatementList = generateBindingInitializers(constructorStatementList);
            constructorStatementList = generateStatesInitializers(constructorStatementList);
            constructorStatementList = generateComponentInitializers(constructorStatementList);
            constructorStatementList = generateInitialBindingExecutions(constructorStatementList);

            statementList = generateConstructor(statementList, generateDocComments,
                                                className, null, 
                                                constructorStatementList);
        }
        
        
        if (mxmlDocument.getHasStagePropertyInitializers())
        {
            statementList = generateAddedToStageHandlerFunction(statementList);
        }
        
        statementList = generateScripts(statementList, mxmlDocument.getScripts());
        statementList = generateInitializerSupportDefs(statementList);
        statementList = generateEmbeds(statementList);

        if (mxmlDocument.getBindingExpressions().size() > 0)
        {
            statementList = generateBindingManagementVars(statementList);
        }
        
        return AbstractSyntaxTreeUtil.generateClassDefinition(context, className,
                                                              mxmlDocument.getSuperClassName(),
                                                              createInterfaceNames(), statementList);
    }
    
	/**
     * Generate code to create the listener function for the Event.ADDED_TO_STAGE method.
     * 
     * <pre>
     *  private function _MyFlex4_addedToStageHandler(event:Event):void
     *  {
     *       removeEventListener(Event.ADDED_TO_STAGE, _MyFlex4_addedToStageHandler);
     *
     *       // stage properties
     *       ...
     *  }
     *
     * </pre>
     * 
     * @param statementList
     * @return
     */
    private StatementListNode generateAddedToStageHandlerFunction(StatementListNode statementList)
    {
        StatementListNode result = statementList;
        
        // function signature
        ParameterNode parameter = AbstractSyntaxTreeUtil.generateParameter(nodeFactory,
                                        EVENT_NAME,
                                        EVENT_TYPE, false);
        ParameterListNode parameterList = nodeFactory.parameterList(null, parameter);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(parameterList, null);
        functionSignature.void_anno = true;

        // function body
        StatementListNode bodyList = null;

        bodyList = generateEventListenerCall(bodyList, false);
        bodyList = generatePropertyInitializers(bodyList, true);
        
        FunctionCommonNode functionCommon = nodeFactory.functionCommon(context, null, functionSignature, bodyList);
        functionCommon.setUserDefinedBody(true);

        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generatePrivateAttribute(nodeFactory);
        String funcName = getAddedToStageHandlerFunctionName();
        IdentifierNode identifier = nodeFactory.identifier(funcName, true);
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.EMPTY_TOKEN, identifier);

        FunctionDefinitionNode functionDefinition = nodeFactory.functionDefinition(context, attributeList, functionName, functionCommon);
        result = nodeFactory.statementList(result, functionDefinition);
        return result;
    }
    
    /**
     * @return name of the addedToStageHandler function. 
     */
    private String getAddedToStageHandlerFunctionName()
    {
        return "_" + mxmlDocument.getClassName() + "_addedToStageHandler";
    }

    private StatementListNode generateComponentInitializers(StatementListNode statementList)
    {
        StatementListNode result = statementList;

        if (!mxmlDocument.getIsIFlexModule())
        {
        	result = generateComponentStyleSettings(result);

	        if (mxmlDocument.getStylesContainer().getStyleDefs().size() > 0 ||
	            (mxmlDocument.getIsFlexApplication()))
	        {
	            String functionName = "_" + mxmlDocument.getClassName() + "_StylesInit";
	            QualifiedIdentifierNode qualifiedIdentifier =
	                AbstractSyntaxTreeUtil.generateMxInternalQualifiedIdentifier(nodeFactory,
	                                                                             functionName,
	                                                                             true);
	            CallExpressionNode callExpression =
	                (CallExpressionNode) nodeFactory.callExpression(qualifiedIdentifier, null);
	            callExpression.setRValue(false);
	            MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, callExpression);
	            ListNode list = nodeFactory.list(null, memberExpression);
	            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
	
	            result = nodeFactory.statementList(result, expressionStatement);
	        }
        }
        
        result = generateDesignLayerInitializers(result);
        result = generatePropertyInitializers(result, false);
        result = generateEventListenerCall(result, true);
        result = generateEventInitializers(result);

        return result;
    }

    
    private StatementListNode generateComponentStyleInitializers(StatementListNode statementList)
    {
        StatementListNode result = statementList;

    	result = generateComponentStyleSettings(result);

        if (mxmlDocument.getStylesContainer().getStyleDefs().size() > 0 ||
            (mxmlDocument.getIsFlexApplication()))
        {
            String functionName = "_" + mxmlDocument.getClassName() + "_StylesInit";
            QualifiedIdentifierNode qualifiedIdentifier =
                AbstractSyntaxTreeUtil.generateMxInternalQualifiedIdentifier(nodeFactory,
                                                                             functionName,
                                                                             true);
            CallExpressionNode callExpression =
                (CallExpressionNode) nodeFactory.callExpression(qualifiedIdentifier, null);
            callExpression.setRValue(false);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, callExpression);
            ListNode list = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);

            result = nodeFactory.statementList(result, expressionStatement);
        }

        return result;
    }
    
    
    /**
     * Generate code to call either "addEventListener(Event.ADDED_TO_STAGE, _{$doc.className}_addedToStageHandler);"
     * or "removeEventListener(Event.ADDED_TO_STAGE, _{$doc.className}_addedToStageHandler);" depending of the 
     * value of <code>addListener</code>
     * 
     * @param statementList
     * @param addListener - if true, generated "addEventListener", otherwise generate "removeEventListener".
     * @return
     */
    private StatementListNode generateEventListenerCall(StatementListNode statementList, boolean addListener)
    {
        StatementListNode result = statementList;

        if (mxmlDocument.getHasStagePropertyInitializers())
        {
            IdentifierNode addedToStageIdentifierNode = nodeFactory.identifier(ADDED_TO_STAGE, false);
            GetExpressionNode addedToStageGetExpression = nodeFactory.getExpression(addedToStageIdentifierNode);
            IdentifierNode eventIdentifierNode = nodeFactory.identifier(EVENT_TYPE, false);
            GetExpressionNode eventGetExpression = nodeFactory.getExpression(eventIdentifierNode);
            MemberExpressionNode eventMemberExpression = nodeFactory.memberExpression(null, eventGetExpression);
            MemberExpressionNode eventAddedToStageMemberExpression =
                nodeFactory.memberExpression(eventMemberExpression, addedToStageGetExpression);
            // create second arg for function handler
            String addedToStageFuncName = getAddedToStageHandlerFunctionName();
            MemberExpressionNode addedToStageFuncNode = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, 
                                                        addedToStageFuncName, true);

            ArgumentListNode argumentList = nodeFactory.argumentList(null, eventAddedToStageMemberExpression);
            nodeFactory.argumentList(argumentList, addedToStageFuncNode);
            
            IdentifierNode addEventListenerIdentifier = nodeFactory.identifier(addListener ? ADD_EVENT_LISTENER : 
                                                                                             REMOVE_EVENT_LISTENER, 
                                                                               false);
            CallExpressionNode callExpression = (CallExpressionNode)nodeFactory.callExpression(addEventListenerIdentifier, 
                                                                                               argumentList);
            callExpression.setRValue(false);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, callExpression);
            ListNode list = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            result = nodeFactory.statementList(result, expressionStatement);
        }

        return result;
    }

    
    private VariableDefinitionNode generateVariable(String name, String type)
    {
        int kind = Tokens.VAR_TOKEN;
        QualifiedIdentifierNode qualifiedIdentifier = generateMxInternalQualifiedIdentifier(name, false);
        MemberExpressionNode memberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, type, false);
        TypeExpressionNode typeExpression = nodeFactory.typeExpression(memberExpression, true, false, -1);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(qualifiedIdentifier, typeExpression);
        VariableBindingNode variableBinding = nodeFactory.variableBinding(null, kind, typedIdentifier, null);
        ListNode list = nodeFactory.list(null, variableBinding);
        return (VariableDefinitionNode) nodeFactory.variableDefinition(null, kind, list);
    }

    private StatementListNode generateBindingInitializers(StatementListNode statementList)
    {
        StatementListNode result = statementList;

        if (mxmlDocument.getBindingExpressions().size() > 0)
        {
            Node bindingsVariableDefinition = generateBindingsVariable();
            result = nodeFactory.statementList(result, bindingsVariableDefinition);
            Node watchersVariableDefinition = generateWatchersVariable();
            result = nodeFactory.statementList(result, watchersVariableDefinition);
            Node targetVariableDefinition = generateTargetVariable();
            result = nodeFactory.statementList(result, targetVariableDefinition);

            MemberExpressionNode watcherSetupUtilMemberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, _WATCHER_SETUP_UTIL, false);
            LiteralNullNode literalNull = nodeFactory.literalNull(-1);
            BinaryExpressionNode binaryExpression = nodeFactory.binaryExpression(Tokens.EQUALS_TOKEN,
                                                                                 watcherSetupUtilMemberExpression,
                                                                                 literalNull);
            ListNode test = nodeFactory.list(null, binaryExpression);

            Node watcherSetupUtilClassVariableDefinition = generateWatcherSetupUtilClassVariable();
            StatementListNode then = nodeFactory.statementList(null, watcherSetupUtilClassVariableDefinition);

            MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory,
                                                                                      WATCHER_SETUP_UTIL_CLASS, false);
            LiteralStringNode literalString = nodeFactory.literalString(INIT, false);
            ArgumentListNode initArgumentList = nodeFactory.argumentList(null, literalString);
            literalNull = nodeFactory.literalNull(-1);
            ArgumentListNode nullArgumentList = nodeFactory.argumentList(null, literalNull);
            CallExpressionNode initSelector =
                (CallExpressionNode) nodeFactory.callExpression(initArgumentList, nullArgumentList);
            initSelector.setMode(Tokens.LEFTBRACKET_TOKEN);
            initSelector.setRValue(false);
            MemberExpressionNode initMemberExpression = nodeFactory.memberExpression(base, initSelector);
            ListNode list = nodeFactory.list(null, initMemberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            then = nodeFactory.statementList(then, expressionStatement);

            Node ifStatement = nodeFactory.ifStatement(test, then, null);
            result = nodeFactory.statementList(result, ifStatement);

            MemberExpressionNode watcherSetupUtilBase =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, _WATCHER_SETUP_UTIL, false);

            IdentifierNode setupIdentifier = nodeFactory.identifier(SETUP, false);
            ThisExpressionNode thisExpression = nodeFactory.thisExpression(-1);
            ArgumentListNode setupArgumentList = nodeFactory.argumentList(null, thisExpression);

            FunctionCommonNode propertyGetter = generatePropertyGetterFunction();
            setupArgumentList = nodeFactory.argumentList(setupArgumentList, propertyGetter);

            FunctionCommonNode staticPropertyGetter = generateStaticPropertyGetterFunction();
            setupArgumentList = nodeFactory.argumentList(setupArgumentList, staticPropertyGetter);

            MemberExpressionNode bindingsMemberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, BINDINGS, false);
            setupArgumentList = nodeFactory.argumentList(setupArgumentList, bindingsMemberExpression);

            MemberExpressionNode watchersMemberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHERS, false);
            setupArgumentList = nodeFactory.argumentList(setupArgumentList, watchersMemberExpression);

            CallExpressionNode setupSelector = (CallExpressionNode) nodeFactory.callExpression(setupIdentifier,
                                                                                               setupArgumentList);
            setupSelector.setRValue(false);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(watcherSetupUtilBase,
                                                                                 setupSelector);
            ListNode setupList = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode setupExpressionStatement = nodeFactory.expressionStatement(setupList);
            result = nodeFactory.statementList(result, setupExpressionStatement);

            ExpressionStatementNode bindingsExpressionStatement = generateBindingsAssignment();
            result = nodeFactory.statementList(result, bindingsExpressionStatement);

            ExpressionStatementNode watchersExpressionStatement = generateWatchersAssignment();
            result = nodeFactory.statementList(result, watchersExpressionStatement);
        }

        return result;
    }

    private StatementListNode generateInitialBindingExecutions(StatementListNode statementList)
    {
    	StatementListNode result = statementList;

        if (mxmlDocument.getBindingExpressions().size() > 0)
        {
        	int kind = Tokens.VAR_TOKEN;
            QualifiedIdentifierNode qualifiedIdentifier = nodeFactory.qualifiedIdentifier(null, I);
            MemberExpressionNode uintMemberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, UINT, false);
            TypeExpressionNode typeExpression = nodeFactory.typeExpression(uintMemberExpression, true,
                                                                           false, -1);
            TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(qualifiedIdentifier,
                                                                              typeExpression);
            LiteralNumberNode initializer = nodeFactory.literalNumber(0);
            VariableBindingNode variableBinding = nodeFactory.variableBinding(null, kind,
                                                                              typedIdentifier, initializer);
            ListNode initializeList = nodeFactory.list(null, variableBinding);
            Node variableDefinition = nodeFactory.variableDefinition(null, kind, initializeList);
            result = nodeFactory.statementList(result, variableDefinition);

            Node forStatement = generateBindingsForLoop();
            result = nodeFactory.statementList(result, forStatement);
        }
        return result;
    }
    
    private StatementListNode generateStatesInitializers(StatementListNode statementList)
    {
        StatementListNode result = statementList;
        if (mxmlDocument.getVersion() >= 4)
        {
            StatesGenerator generator = new StatesGenerator(standardDefs);
            result = generator.getStatesASTInitializers(mxmlDocument.getStatefulModel(), nodeFactory,
                                                        configNamespaces, generateDocComments, statementList);
        }
        return result;
    }
    
    private StatementListNode generateComponentStyleSettings(StatementListNode statementList)
    {
        StatementListNode result = statementList;

        Iterator<Initializer> iterator = mxmlDocument.getRoot().getStyleAndEffectInitializerIterator();

        if (iterator.hasNext())
        {
            Node ifStatement = generateStyleDeclarationIfStatement();
            result = nodeFactory.statementList(result, ifStatement);

            ThisExpressionNode thisExpression = nodeFactory.thisExpression(-1);
            IdentifierNode styleDeclarationIdentifier = nodeFactory.identifier(STYLE_DECLARATION, false);
            GetExpressionNode getExpression = nodeFactory.getExpression(styleDeclarationIdentifier);
            MemberExpressionNode base = nodeFactory.memberExpression(thisExpression, getExpression);

            IdentifierNode defaultFactoryIdentifier = nodeFactory.identifier(DEFAULT_FACTORY, false);

            FunctionSignatureNode functionSignature = nodeFactory.functionSignature(null, null);
            functionSignature.void_anno = true;
            StatementListNode body = null;

            while (iterator.hasNext())
            {
                NamedInitializer namedInitializer = (NamedInitializer) iterator.next();
                thisExpression = nodeFactory.thisExpression(-1);
                IdentifierNode nameIdentifier = nodeFactory.identifier(namedInitializer.getName());
                Node rvalue = namedInitializer.generateValueExpr(nodeFactory, configNamespaces, generateDocComments);
                ArgumentListNode argumentList = nodeFactory.argumentList(null, rvalue);
                SetExpressionNode setExpression = nodeFactory.setExpression(nameIdentifier, argumentList, false);
                MemberExpressionNode memberExpression = nodeFactory.memberExpression(thisExpression, setExpression);
                ListNode list = nodeFactory.list(null, memberExpression);
                ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
                body = nodeFactory.statementList(body, expressionStatement);
            }

            FunctionCommonNode functionCommon = nodeFactory.functionCommon(context, null, functionSignature, body);
            ArgumentListNode argumentList = nodeFactory.argumentList(null, functionCommon);
            SetExpressionNode selector = nodeFactory.setExpression(defaultFactoryIdentifier, argumentList, false);

            MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
            ListNode list = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            result = nodeFactory.statementList(result, expressionStatement);
        }

        //this.registerEffects( [ $effectEventNames ] );
        Iterator<Initializer> effectIterator = mxmlDocument.getRoot().getEffectInitializerIterator();

        if (effectIterator.hasNext())
        {
            ThisExpressionNode thisExpression = nodeFactory.thisExpression(-1);
            IdentifierNode identifier = nodeFactory.identifier(REGISTER_EFFECTS, false);
            ArgumentListNode effectsArgumentList = null;

            while (effectIterator.hasNext())
            {
                EffectInitializer effectInitializer = (EffectInitializer) effectIterator.next();
                String name = effectInitializer.getName();
                LiteralStringNode literalString = nodeFactory.literalString(name);
                effectsArgumentList = nodeFactory.argumentList(effectsArgumentList, literalString);
            }

            LiteralArrayNode literalArray = nodeFactory.literalArray(effectsArgumentList);
            ArgumentListNode argumentList = nodeFactory.argumentList(null, literalArray);
            CallExpressionNode callExpression =
                (CallExpressionNode) nodeFactory.callExpression(identifier, argumentList);
            callExpression.setRValue(false);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(thisExpression, callExpression);
            ListNode list = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            result = nodeFactory.statementList(result, expressionStatement);
        }

        return result;
    }

    private StatementListNode generateConstructor(StatementListNode statementList, boolean generateDocComments,
                                                  String className, ParameterListNode parameterList, 
                                                  StatementListNode constructorStatementList)
    {
        StatementListNode result = statementList;

        if (generateDocComments && !processComments)
        {
            DocCommentNode docComment =
                AbstractSyntaxTreeUtil.generatePrivateDocComment(nodeFactory);
            result = nodeFactory.statementList(result, docComment);
        }
        
        if(processComments) // in some cases *not* having a private comment is not enough. So adding a blank comment to the c'tor
        {
            DocCommentNode docComment =
                AbstractSyntaxTreeUtil.generateDocComment(nodeFactory, "<description><![CDATA[]]></description>".intern());
            result = nodeFactory.statementList(result, docComment);
        }

        int position = AbstractSyntaxTreeUtil.lineNumberToPosition(context.getNodeFactory(), mxmlDocument.getRoot().getXmlLineNumber());
        
        FunctionDefinitionNode constructor =
            AbstractSyntaxTreeUtil.generateConstructor(context, className, parameterList, true, 
            		constructorStatementList, position);
        result = nodeFactory.statementList(result, constructor);

        return result;
    }

    private VariableDefinitionNode generateStylesPackageVariable(String name, String type)
    {
        int kind = Tokens.VAR_TOKEN;
        QualifiedIdentifierNode qualifiedIdentifier = generateMxInternalQualifiedIdentifier(name, false);
        MemberExpressionNode memberExpression =
            AbstractSyntaxTreeUtil.generateResolvedGetterSelector(nodeFactory, standardDefs.getStylesPackage(), type);
        TypeExpressionNode typeExpression = nodeFactory.typeExpression(memberExpression, true, false, -1);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(qualifiedIdentifier, typeExpression);
        VariableBindingNode variableBinding = nodeFactory.variableBinding(null, kind, typedIdentifier, null);
        ListNode list = nodeFactory.list(null, variableBinding);
        return (VariableDefinitionNode) nodeFactory.variableDefinition(null, kind, list);
    }

    private FunctionCommonNode generateDestinationFunction(BindingExpression bindingExpression)
    {
        String destinationTypeName = bindingExpression.getDestinationTypeName();
        ParameterNode parameter = AbstractSyntaxTreeUtil.generateParameter(nodeFactory,
                                                                           _SOURCE_FUNCTION_RETURN_VALUE,
                                                                           destinationTypeName, true);
        ParameterListNode parameterList = nodeFactory.parameterList(null, parameter);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(parameterList, null);
        functionSignature.void_anno = true;
        StatementListNode body = null;
        String text;

        if (bindingExpression.isStyle())
        {
            //${bindingExpression.getDestinationPathRoot(true)}.setStyle("${bindingExpression.destinationStyle}", _sourceFunctionReturnValue);
            text = (bindingExpression.getDestinationPathRoot(true) +
                    ".setStyle(\"" + bindingExpression.getDestinationStyle() +
                    "\", _sourceFunctionReturnValue)");
        }
        else if (bindingExpression.isDestinationObjectProxy())
        {
            //${bindingExpression.getDestinationPath(true)} = new mx.utils.ObjectProxy(_sourceFunctionReturnValue);
            text = (bindingExpression.getDestinationPath(true) +
                    " = new " + standardDefs.getUtilsPackage() + ".ObjectProxy(_sourceFunctionReturnValue)");
        }
        else
        {
            //${bindingExpression.getNamespaceDeclarations()}
            if (bindingExpression.getNamespaceDeclarations().length() > 0)
            {
                body = bindingExpression.generateNamespaceDeclarations(context, body);
            }

            //${bindingExpression.getDestinationPath(true)} = _sourceFunctionReturnValue;
            text = (bindingExpression.getDestinationPath(true) +
                    " = _sourceFunctionReturnValue");
        }

        int xmlLineNumber = bindingExpression.getXmlLineNumber();
        List<Node> nodeList =
            AbstractSyntaxTreeUtil.parseExpression(context, configNamespaces, text,
                                                   xmlLineNumber, generateDocComments);
        
        if (!nodeList.isEmpty())
        {
            body = nodeFactory.statementList(body, nodeList.get(0));
        }

        return nodeFactory.functionCommon(context, null, functionSignature, body);
    }

    private ExpressionStatementNode generateDocumentAssignment()
    {
        QualifiedIdentifierNode qualifiedIdentifier =
            AbstractSyntaxTreeUtil.generateMxInternalQualifiedIdentifier(nodeFactory, _DOCUMENT, false);
        ThisExpressionNode thisExpression = nodeFactory.thisExpression(-1);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, thisExpression);
        SetExpressionNode setExpression = nodeFactory.setExpression(qualifiedIdentifier,
                                                                    argumentList, false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, setExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    // effects = style.mx_internal::effects;
    private ExpressionStatementNode generateEffectsInitializer()
    {
        IdentifierNode effectsIdentifier = nodeFactory.identifier(EFFECTS, false);
        MemberExpressionNode styleMemberExpression = 
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, STYLE, false);
        QualifiedIdentifierNode qualifiedIdentifier =
            AbstractSyntaxTreeUtil.generateMxInternalQualifiedIdentifier(nodeFactory,
                                                                         EFFECTS,
                                                                         false);
        GetExpressionNode effectsGetExpression = nodeFactory.getExpression(qualifiedIdentifier);
        MemberExpressionNode styleEffectsMemberExpression = nodeFactory.memberExpression(styleMemberExpression,
                                                                                         effectsGetExpression);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, styleEffectsMemberExpression);
        SetExpressionNode setExpression = nodeFactory.setExpression(effectsIdentifier, argumentList, false);
        MemberExpressionNode effectsMemberExpression = nodeFactory.memberExpression(null, setExpression);
        ListNode list = nodeFactory.list(null, effectsMemberExpression);
        return nodeFactory.expressionStatement(list);
    }

    private StatementListNode generateEmbeds(StatementListNode statementList)
    {
        StatementListNode result = statementList;

        Iterator<AtEmbed> iterator = mxmlDocument.getAtEmbeds().iterator();

        while (iterator.hasNext())
        {
            AtEmbed atEmbed = iterator.next();
            Map<String, Object> attributes = atEmbed.getAttributes();
            MetaDataNode metaData =
                AbstractSyntaxTreeUtil.generateMetaData(nodeFactory, EMBED, attributes);
            result = nodeFactory.statementList(result, metaData);

            MemberExpressionNode memberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory,
                                                              atEmbed.getType(),
                                                              true);
            TypeExpressionNode typeExpression =
                nodeFactory.typeExpression(memberExpression, true, false, -1);
            Node variableDefinition =
                AbstractSyntaxTreeUtil.generatePrivateVariable(nodeFactory,
                                                               typeExpression,
                                                               atEmbed.getPropName());
            result = nodeFactory.statementList(result, variableDefinition);
        }

        return result;
    }

    private StatementListNode generateEventInitializers(StatementListNode statementList)
    {
        StatementListNode result = statementList;

        Iterator<Initializer> iterator = mxmlDocument.getRoot().getEventInitializerIterator();

        while (iterator.hasNext())
        {
            Initializer initializer = iterator.next();
            ThisExpressionNode thisExpression = nodeFactory.thisExpression(-1);
            result = initializer.generateAssignExpr(nodeFactory, configNamespaces, generateDocComments,
                                                    result, thisExpression);
        }

        return result;
    }

    private ExpressionStatementNode generateGetStyleDeclaration(String styleDeclarationName)
    {
        IdentifierNode styleIdentifier = nodeFactory.identifier(STYLE, false);
        MemberExpressionNode base =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, STYLE_MANAGER_INSTANCE, false);
        IdentifierNode getStyleDeclarationIdentifier = nodeFactory.identifier(GET_STYLE_DECLARATION, false);
        LiteralStringNode literalString = nodeFactory.literalString(styleDeclarationName);
        ArgumentListNode callExpressionArgumentList = nodeFactory.argumentList(null, literalString);
        CallExpressionNode selector =
            (CallExpressionNode) nodeFactory.callExpression(getStyleDeclarationIdentifier,
                                                            callExpressionArgumentList);
        selector.setRValue(false);
        MemberExpressionNode argumentMemberExpression = nodeFactory.memberExpression(base, selector);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, argumentMemberExpression);
        SetExpressionNode setExpression = nodeFactory.setExpression(styleIdentifier, argumentList, false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, setExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    private void generateIfNullEffectsAndPushes(StyleDef styleDef, StyleDeclaration declaration, StatementListNode statementList)
    {
        //if (!effects)
        MemberExpressionNode memberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, EFFECTS, false);
        Node unaryExpression = nodeFactory.unaryExpression(Tokens.NOT_TOKEN, memberExpression);
        ListNode test = nodeFactory.list(null, unaryExpression);

        //effects = style.mx_internal::effects = [];
        IdentifierNode effectsIdentifier = nodeFactory.identifier(EFFECTS, false);
        MemberExpressionNode styleMemberExpression = 
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, STYLE, false);
        QualifiedIdentifierNode qualifiedIdentifier = 
            AbstractSyntaxTreeUtil.generateMxInternalQualifiedIdentifier(nodeFactory, EFFECTS, false);
        LiteralArrayNode literalArray = nodeFactory.literalArray(null);
        ArgumentListNode mxInternalEffectsArgumentList = nodeFactory.argumentList(null, literalArray);
        SetExpressionNode mxInternalEffectsSetExpression =
            nodeFactory.setExpression(qualifiedIdentifier, mxInternalEffectsArgumentList, false);
        MemberExpressionNode mxInternalEffectsMemberExpression =
            nodeFactory.memberExpression(styleMemberExpression, mxInternalEffectsSetExpression);
        ArgumentListNode effectsArgumentList = nodeFactory.argumentList(null, mxInternalEffectsMemberExpression);
        SetExpressionNode effectsSetExpression =
            nodeFactory.setExpression(effectsIdentifier, effectsArgumentList, false);
        MemberExpressionNode effectsMemberExpression = nodeFactory.memberExpression(null, effectsSetExpression);
        ListNode list = nodeFactory.list(null, effectsMemberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        StatementListNode ifStatementList = nodeFactory.statementList(null, expressionStatement);

        Node ifStatement = nodeFactory.ifStatement(test, ifStatementList, null);
        statementList = nodeFactory.statementList(statementList, ifStatement);

        if (declaration != null) // Flex 4 advanced style declarations
        {
            List<StyleDeclarationBlock> blocks = declaration.getDeclarationBlocks();
            for (StyleDeclarationBlock block : blocks)
            {
                //effects.push("${effectStyle}");
                Iterator<String> iterator = block.getEffectStyles().iterator();

                if (block.hasMediaList())
                {
                    StatementListNode effectsStatementList = generateEffectStyles(iterator, null);

                    // if (styleManager.acceptMediaList("$block.mediaList.toString()"))
                    MemberExpressionNode expr = generateStyleManagerAcceptMediaList(block.getMediaList().toString());
                    ListNode mediaTest = nodeFactory.list(null, expr);
                    ifStatement = nodeFactory.ifStatement(mediaTest, effectsStatementList, null);
                    statementList = nodeFactory.statementList(statementList, ifStatement);
                }
                else
                {
                    statementList = generateEffectStyles(iterator, statementList);
                }
            }
        }
        else // Flex 3 legacy style def
        {
            //effects.push("${effectStyle}");
            Iterator<String> iterator = styleDef.getEffectStyles().iterator();
            statementList = generateEffectStyles(iterator, statementList);
        }
    }

    private StatementListNode generateEffectStyles(Iterator<String> iterator, StatementListNode statementList)
    {
        while (iterator.hasNext())
        {
            //effects.push("${effectStyle}");
            ExpressionStatementNode pushExpressionStatement =
                generatePush(EFFECTS, nodeFactory.literalString(iterator.next()));
            statementList = nodeFactory.statementList(statementList, pushExpressionStatement);
        }
        
        return statementList;
    }
        
    private Node generateIfNullStyleDeclaration(String subject, StyleSelector selector)
    {
        //if (!style)
        MemberExpressionNode styleMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, STYLE, false);
        Node unaryExpression = nodeFactory.unaryExpression(Tokens.NOT_TOKEN,
                                                           styleMemberExpression);
        ListNode test = nodeFactory.list(null, unaryExpression);

        // style = new CSSStyleDeclaration(selector, styleManager);
        IdentifierNode styleIdentifier = nodeFactory.identifier(STYLE, false);
        IdentifierNode cssStyleDeclarationIdentifier =
            AbstractSyntaxTreeUtil.generateResolvedIdentifier(nodeFactory, standardDefs.getStylesPackage(),
                                                              CSS_STYLE_DECLARATION);

        MemberExpressionNode selectorMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, SELECTOR, false);
        ArgumentListNode callArgumentList = nodeFactory.argumentList(null, selectorMemberExpression);
        MemberExpressionNode memberExpression = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, STYLE_MANAGER_INSTANCE, false);
        callArgumentList = nodeFactory.argumentList(callArgumentList, memberExpression);

        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(cssStyleDeclarationIdentifier, callArgumentList);
        callExpression.is_new = true;
        callExpression.setRValue(false);
        MemberExpressionNode argumentMemberExpression = nodeFactory.memberExpression(null, callExpression);
        ArgumentListNode setArgumentList = nodeFactory.argumentList(null, argumentMemberExpression);
        SetExpressionNode setExpression = nodeFactory.setExpression(styleIdentifier, setArgumentList, false);
        memberExpression = nodeFactory.memberExpression(null, setExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        StatementListNode statementList = nodeFactory.statementList(null, expressionStatement);

        return nodeFactory.ifStatement(test, statementList, null);
    }

    private Node generateIfNullStyleDeclaration(StyleDef styleDef)
    {
        //if (!style)
        MemberExpressionNode styleMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, STYLE, false);
        Node unaryExpression = nodeFactory.unaryExpression(Tokens.NOT_TOKEN,
                                                           styleMemberExpression);
        ListNode test = nodeFactory.list(null, unaryExpression);

        StatementListNode statementList;

        //  style = new CSSStyleDeclaration(null, styleManager);
        {
            IdentifierNode styleIdentifier = nodeFactory.identifier(STYLE, false);
            IdentifierNode cssStyleDeclarationIdentifier =
                AbstractSyntaxTreeUtil.generateResolvedIdentifier(nodeFactory, standardDefs.getStylesPackage(),
                                                                  CSS_STYLE_DECLARATION);
            ArgumentListNode argumentList = nodeFactory.argumentList(null, nodeFactory.literalNull());
            MemberExpressionNode memberExpression = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, STYLE_MANAGER_INSTANCE, false);
            argumentList = nodeFactory.argumentList(argumentList, memberExpression);
            CallExpressionNode callExpression =
                (CallExpressionNode) nodeFactory.callExpression(cssStyleDeclarationIdentifier, argumentList);
            callExpression.is_new = true;
            callExpression.setRValue(false);
            MemberExpressionNode argumentMemberExpression = nodeFactory.memberExpression(null, callExpression);
            argumentList = nodeFactory.argumentList(null, argumentMemberExpression);
            SetExpressionNode setExpression = nodeFactory.setExpression(styleIdentifier, argumentList, false);
            memberExpression = nodeFactory.memberExpression(null, setExpression);
            ListNode list = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            statementList = nodeFactory.statementList(null, expressionStatement);
        }

        {
            MemberExpressionNode base =
                AbstractSyntaxTreeUtil.generateResolvedGetterSelector(nodeFactory, standardDefs.getStylesPackage(), STYLE_MANAGER);
            IdentifierNode setStyleDeclarationIdentifier = nodeFactory.identifier(SET_STYLE_DECLARATION, false);
            LiteralStringNode literalString;

            if (styleDef.isTypeSelector())
            {
                //StyleManager.setStyleDeclaration("${styleDef.typeName}", style, false);
                literalString = nodeFactory.literalString(styleDef.getTypeName());
            }
            else
            {
                //StyleManager.setStyleDeclaration(".${styleDef.typeName}", style, false);
                literalString = nodeFactory.literalString("." + styleDef.getTypeName());
            }

            ArgumentListNode argumentList = nodeFactory.argumentList(null, literalString);
            styleMemberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, STYLE, false);
            argumentList = nodeFactory.argumentList(argumentList, styleMemberExpression);
            LiteralBooleanNode literalBoolean = nodeFactory.literalBoolean(false);
            argumentList = nodeFactory.argumentList(argumentList, literalBoolean);
            CallExpressionNode selector =
                (CallExpressionNode) nodeFactory.callExpression(setStyleDeclarationIdentifier,
                                                                argumentList);
            selector.setRValue(false);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
            ListNode list = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            statementList = nodeFactory.statementList(statementList, expressionStatement);
        }

        return nodeFactory.ifStatement(test, statementList, null);
    }

    private Node generateIfNullStyleFactory(StyleDef styleDef, StyleDeclaration declaration)
    {
        //if (style.factory == null)
        ListNode test;
        {
            MemberExpressionNode base = 
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, STYLE, false);
            IdentifierNode factoryIdentifier = nodeFactory.identifier(FACTORY, false);
            GetExpressionNode selector = nodeFactory.getExpression(factoryIdentifier);
            selector.setRValue(false);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
            LiteralNullNode literalNull = nodeFactory.literalNull(-1);
            BinaryExpressionNode binaryExpression = nodeFactory.binaryExpression(Tokens.EQUALS_TOKEN,
                                                                                 memberExpression,
                                                                                 literalNull);
            test = nodeFactory.list(null, binaryExpression);
        }

        //style.factory = function():void
        StatementListNode statementList;
        {
            MemberExpressionNode base = 
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, STYLE, false);
            IdentifierNode factoryIdentifier = nodeFactory.identifier(FACTORY, false);
            FunctionCommonNode functionCommon = generateStyleFactory(styleDef, declaration);
            ArgumentListNode argumentList = nodeFactory.argumentList(null, functionCommon);
            SetExpressionNode selector = nodeFactory.setExpression(factoryIdentifier,
                                                                   argumentList, false);
            selector.setRValue(false);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
            ListNode list = nodeFactory.list(null, memberExpression); 
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            statementList = nodeFactory.statementList(null, expressionStatement);
        }

        return nodeFactory.ifStatement(test, statementList, null);
    }

    private StatementListNode generateImports(StatementListNode statementList)
    {
        StatementListNode result = statementList;

        Iterator<String[]> splitImportIterator = mxmlDocument.getSplitImports().iterator();

        while (splitImportIterator.hasNext())
        {
            String[] splitImport = splitImportIterator.next();
            ImportDirectiveNode importDirective = AbstractSyntaxTreeUtil.generateImport(context, splitImport);
            result = nodeFactory.statementList(result, importDirective);
        }

        Iterator<DocumentInfo.NameInfo> iterator = mxmlDocument.getImports().iterator();

        while (iterator.hasNext())
        {
            DocumentInfo.NameInfo nameInfo = iterator.next();
            int position = AbstractSyntaxTreeUtil.lineNumberToPosition(nodeFactory, nameInfo.getLine());
            ImportDirectiveNode importDirective = AbstractSyntaxTreeUtil.generateImport(context, nameInfo.getName(), position);            
            result = nodeFactory.statementList(result, importDirective);
        }

        return result;
    }

    private StatementListNode generateInitializerSupportDefs(StatementListNode statementList)
    {
        StatementListNode result = statementList;

        Iterator<Initializer> topLevelInitializerIterator = mxmlDocument.getTopLevelInitializerIterator();

        // Top level document initializer iterator.
        while (topLevelInitializerIterator.hasNext())
        {
            result = topLevelInitializerIterator.next().generateDefinitions(context, configNamespaces,
                                                                            generateDocComments, result);
        }

        Iterator<Initializer> eventInitializerIterator = mxmlDocument.getStatefulEventIterator();

        // Stateful event initializer iterator.
        while (eventInitializerIterator.hasNext())
        {
            result = eventInitializerIterator.next().generateDefinitions(context, configNamespaces,
                                                                         generateDocComments, result);
        }
        
        Iterator<Initializer> rootSubInitializerIterator = mxmlDocument.getRoot().getSubInitializerIterator();

        // Root sub-initializer iterator.
        while (rootSubInitializerIterator.hasNext())
        {
            Initializer initializer = rootSubInitializerIterator.next();
            result = initializer.generateDefinitions(context, configNamespaces, generateDocComments, result);
        }

        // Stateful document initializers
        if (mxmlDocument.getVersion() >= 4)
        {
            Iterator<Initializer> statesSubInitializerIterator = mxmlDocument.getStatefulModel().getSubInitializerIterators();
            while (statesSubInitializerIterator.hasNext())
            {
                Initializer initializer = statesSubInitializerIterator.next();
                result = initializer.generateDefinitions(context, configNamespaces, generateDocComments, result);
            }
        }
        
        if (mxmlDocument.getBindingExpressions().size() > 0)
        {
            result = generateBindingsSetup(result);
        }
        	
        if (mxmlDocument.getStylesContainer().getStyleDefs().size() > 0 ||
            mxmlDocument.getIsFlexApplication())
        {
            result = generateStylesInitFunction(result);
        }

        return result;
    }

    private FunctionDefinitionNode generateInitializeFunction()
    {
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(null, null);
        functionSignature.void_anno = true;

        StatementListNode statementList = null;

        if (mxmlDocument.getDescribeVisualChildren() && mxmlDocument.getIsContainer())
        {
            QualifiedIdentifierNode qualifiedIdentifier =
                AbstractSyntaxTreeUtil.generateMxInternalQualifiedIdentifier(nodeFactory,
                                                                             SET_DOCUMENT_DESCRIPTOR,
                                                                             false);
            MemberExpressionNode getterSelector =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory,
                                                              _DOCUMENT_DESCRIPTOR_,
                                                              false);
            ArgumentListNode argumentList = nodeFactory.argumentList(null, getterSelector);
            CallExpressionNode callExpression = (CallExpressionNode) nodeFactory.callExpression(qualifiedIdentifier,
                                                                                                argumentList);
            callExpression.setRValue(false);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, callExpression);
            ListNode list = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            statementList = nodeFactory.statementList(statementList, expressionStatement);
        }

        SuperExpressionNode superExpression = nodeFactory.superExpression(null, -1);
        IdentifierNode identifier = nodeFactory.identifier(INITIALIZE, false);
        CallExpressionNode callExpression = (CallExpressionNode) nodeFactory.callExpression(identifier, null);
        callExpression.setRValue(false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(superExpression, callExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        statementList = nodeFactory.statementList(statementList, expressionStatement);

        FunctionCommonNode functionCommon = nodeFactory.functionCommon(context, null, functionSignature, statementList);
        functionCommon.setUserDefinedBody(true);

        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generateOverridePublicAttribute(nodeFactory);
        identifier = nodeFactory.identifier(INITIALIZE, false);
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.EMPTY_TOKEN, identifier);

        return nodeFactory.functionDefinition(context, attributeList, functionName, functionCommon);
    }

    private ExpressionStatementNode generateInitProtoChainRoots()
    {
        MemberExpressionNode base =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, STYLE_MANAGER_INSTANCE, false);
        IdentifierNode identifier = nodeFactory.identifier(INIT_PROTO_CHAIN_ROOTS);
        CallExpressionNode selector = (CallExpressionNode) nodeFactory.callExpression(identifier, null);
        selector.setRValue(false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    private StatementListNode generateInstanceVariables(StatementListNode statementList)
    {
        StatementListNode result = statementList;
        Iterator<PropertyDeclaration> iterator = mxmlDocument.getDeclarationIterator();

        while (iterator.hasNext())
        {
            PropertyDeclaration propertyDeclaration = iterator.next();

            if (propertyDeclaration.getInspectable())
            {
                MetaDataNode inspectableMetaData = AbstractSyntaxTreeUtil.generateMetaData(nodeFactory, INSPECTABLE);
                result = nodeFactory.statementList(result, inspectableMetaData);
            }

            if (!propertyDeclaration.getIdIsAutogenerated() || propertyDeclaration.getBindabilityEnsured())
            {
            	MetaDataNode bindableMetaData = AbstractSyntaxTreeUtil.generateMetaData(nodeFactory, BINDABLE);
                result = nodeFactory.statementList(result, bindableMetaData);
            }
            
            if (!propertyDeclaration.getIdIsAutogenerated())
            {
                if(processComments)
                {
                    MetaDataNode propertyDocComment = null;
                    if(propertyDeclaration.getComment() != null ) 
                    {
                        propertyDocComment = AbstractSyntaxTreeUtil.generateDocComment(nodeFactory, propertyDeclaration.getComment().intern());
                    }
                    
                    if (propertyDocComment != null)
                    {
                        result = nodeFactory.statementList(result, propertyDocComment);
                    }
                    else 
                    {
                        // when individual classes are listed using doc-classes, properties with id but no comment are not visible. So adding a blank comment.
                        DocCommentNode docComment =
                            AbstractSyntaxTreeUtil.generateDocComment(nodeFactory, "<description><![CDATA[]]></description>".intern());
                        result = nodeFactory.statementList(result, docComment);
                    }
                }
                
                if (generateDocComments && !processComments)
                {
                    DocCommentNode docComment = AbstractSyntaxTreeUtil.generatePrivateDocComment(nodeFactory);
                    result = nodeFactory.statementList(result, docComment);
                }                
            } 
            else 
            {
                if (generateDocComments)
                {
                    DocCommentNode docComment = AbstractSyntaxTreeUtil.generatePrivateDocComment(nodeFactory);
                    result = nodeFactory.statementList(result, docComment);
                }                
            }

            TypeExpressionNode typeExpression =
                AbstractSyntaxTreeUtil.generateTypeExpression(nodeFactory,
                                                              propertyDeclaration.getTypeExpr(), true);
            
            Node variableDefinition =
                AbstractSyntaxTreeUtil.generatePublicVariable(context, typeExpression,
                                                              propertyDeclaration.getName());
            result = nodeFactory.statementList(result, variableDefinition);
        }

        return result;
    }

    private ExpressionStatementNode generateIsTwoWayPrimaryAssignment(int leftValueId)
    {
        MemberExpressionNode leftResultMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, RESULT, false);
        LiteralNumberNode leftLiteralNumber = nodeFactory.literalNumber(leftValueId);;
        ArgumentListNode leftGetExpressionArgumentList = nodeFactory.argumentList(null, leftLiteralNumber);
        GetExpressionNode leftGetExpression = nodeFactory.getExpression(leftGetExpressionArgumentList);
        leftGetExpression.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode base = nodeFactory.memberExpression(leftResultMemberExpression, leftGetExpression);

        IdentifierNode twoWayCounterpartIdentifier = nodeFactory.identifier(IS_TWO_WAY_PRIMARY, false);
        LiteralBooleanNode literalBoolean = nodeFactory.literalBoolean(true);
        ArgumentListNode setExpressionArgumentList = nodeFactory.argumentList(null, literalBoolean);
        SetExpressionNode selector = nodeFactory.setExpression(twoWayCounterpartIdentifier,
                                                               setExpressionArgumentList, false);

        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    private MemberExpressionNode generateMxInternalGetterSelector(String name, boolean intern)
    {
        MemberExpressionNode mxInternalGetterSelector =
            AbstractSyntaxTreeUtil.generateResolvedGetterSelector(nodeFactory, standardDefs.getCorePackage(), MX_INTERNAL);
        return AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, mxInternalGetterSelector, name, true);
    }

    private ExpressionStatementNode generateNullInitializer(String name)
    {
        IdentifierNode identifier = nodeFactory.identifier(name);
        LiteralNullNode literalNull = nodeFactory.literalNull(-1);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, literalNull);
        SetExpressionNode setExpression = nodeFactory.setExpression(identifier, argumentList, false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, setExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    private DocCommentNode generatePackageDocComment(String packageName, String className, String path)
    {
        StringBuilder stringBuilder = new StringBuilder();

        stringBuilder.append("<description><![CDATA[\n  Generated by mxmlc 4.0\n  Package: ");
        stringBuilder.append(packageName);
        stringBuilder.append("\n Class:   ");
        stringBuilder.append(className);
        stringBuilder.append("\n Source:  ");
        stringBuilder.append(path);
        stringBuilder.append("\n ]]></description>");

        return AbstractSyntaxTreeUtil.generateDocComment(nodeFactory, stringBuilder.toString().intern());
    }

    private FunctionCommonNode generatePropertyGetterFunction()
    {
        ParameterNode parameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, PROPERTY_NAME, STRING, false);
        ParameterListNode parameterList = nodeFactory.parameterList(null, parameter);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(parameterList, null);

        MemberExpressionNode base =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, TARGET, false);
        MemberExpressionNode argument =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, PROPERTY_NAME, false);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, argument);
        GetExpressionNode selector = nodeFactory.getExpression(argumentList);
        selector.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
        ListNode list = nodeFactory.list(null, memberExpression);
        ReturnStatementNode returnStatement = nodeFactory.returnStatement(list);
        StatementListNode statementList = nodeFactory.statementList(null, returnStatement);

        return nodeFactory.functionCommon(context, null, functionSignature, statementList);
    }

    private StatementListNode generatePropertyInitializers(StatementListNode statementList, boolean stageProperties)
    {
        StatementListNode result = statementList;

        Iterator<Initializer> iterator = stageProperties ? mxmlDocument.getStagePropertyInitializerIterator()
                                                         : mxmlDocument.getNonStagePropertyInitializerIterator();

        while (iterator.hasNext())
        {
            Initializer initializer = iterator.next();
            ThisExpressionNode thisExpression = nodeFactory.thisExpression(-1);
            result = initializer.generateAssignExpr(nodeFactory, configNamespaces, generateDocComments, result, thisExpression);
        }

        return result;
    }
    
    private StatementListNode generateDesignLayerInitializers(StatementListNode statementList)
    {
        StatementListNode result = statementList;

        Iterator<Initializer> iterator = mxmlDocument.getDesignLayerPropertyInitializerIterator();
                                                        
        while (iterator.hasNext())
        {
            Initializer initializer = iterator.next();
            ThisExpressionNode thisExpression = nodeFactory.thisExpression(-1);
            result = initializer.generateAssignExpr(nodeFactory, configNamespaces, generateDocComments, result, thisExpression);
        }

        return result;
    }

    private ExpressionStatementNode generatePush(String variable, Node node)
    {
        MemberExpressionNode variableMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, variable, false);
        IdentifierNode identifier = nodeFactory.identifier(PUSH);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, node);
        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(identifier, argumentList);
        callExpression.setRValue(false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(variableMemberExpression,
                                                                             callExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    private ExpressionStatementNode generateRepeatableBinding(BindingExpression bindingExpression)
    {
        // result[${bindingExpression.id}] = new mx.binding.RepeatableBinding(this, ...
        MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, RESULT, false);
        LiteralNumberNode literalNumber = nodeFactory.literalNumber(bindingExpression.getId());
        ArgumentListNode literalNumberArgumentList = nodeFactory.argumentList(null, literalNumber);

        QualifiedIdentifierNode qualifiedIdentifier =
            AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory, standardDefs.getBindingPackage(), REPEATABLE_BINDING, false);
        ThisExpressionNode thisExpression = nodeFactory.thisExpression(-1);
        ArgumentListNode callArgumentList = nodeFactory.argumentList(null, thisExpression);

        FunctionCommonNode sourceFunctionCommon = generateRepeatableSourceFunction(bindingExpression);
        callArgumentList = nodeFactory.argumentList(callArgumentList, sourceFunctionCommon);

        FunctionCommonNode destinationFunctionCommon = generateRepeatableDestinationFunction(bindingExpression);
        callArgumentList = nodeFactory.argumentList(callArgumentList, destinationFunctionCommon);

        LiteralStringNode literalString = nodeFactory.literalString(bindingExpression.getDestinationPath(false));
        callArgumentList = nodeFactory.argumentList(callArgumentList, literalString);

        CallExpressionNode callExpression = (CallExpressionNode) nodeFactory.callExpression(qualifiedIdentifier,
                                                                                                callArgumentList);
        callExpression.is_new = true;
        callExpression.setRValue(false);

        MemberExpressionNode bindingMemberExpression = nodeFactory.memberExpression(null, callExpression);
        ArgumentListNode setArgumentList = nodeFactory.argumentList(null, bindingMemberExpression);
        SetExpressionNode selector = nodeFactory.setExpression(literalNumberArgumentList,
                                                               setArgumentList, false);
        selector.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    private FunctionCommonNode generateRepeatableDestinationFunction(BindingExpression bindingExpression)
    {
        ParameterNode sourceFunctionReturnValueParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, _SOURCE_FUNCTION_RETURN_VALUE,
                                                     bindingExpression.getDestinationTypeName(), true);
        ParameterListNode parameterList =
            nodeFactory.parameterList(null, sourceFunctionReturnValueParameter);
        ParameterNode instanceIndicesParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, INSTANCE_INDICES, ARRAY, false);
        parameterList = nodeFactory.parameterList(parameterList, instanceIndicesParameter);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(parameterList, null);
        functionSignature.void_anno = true;
        String text;

        if (bindingExpression.isStyle())
        {
            //${bindingExpression.getDestinationPathRoot(true)}.setStyle("${bindingExpression.destinationLValue}", _sourceFunctionReturnValue);
            text = (bindingExpression.getDestinationPathRoot(true) + ".setStyle(\"" +
                    bindingExpression.getDestinationLValue() + "\", _sourceFunctionReturnValue)");
        }
        else if (bindingExpression.isDestinationObjectProxy())
        {
            //${bindingExpression.getDestinationPathRoot(true)}.${bindingExpression.destinationLValue} = new mx.utils.ObjectProxy(_sourceFunctionReturnValue);
            text = (bindingExpression.getDestinationPathRoot(true) + "." +
                    bindingExpression.getDestinationLValue() +
                    " = new " + standardDefs.getUtilsPackage() + ".ObjectProxy(_sourceFunctionReturnValue)");
        }
        else
        {
            //${bindingExpression.getDestinationPathRoot(true)}.${bindingExpression.destinationLValue} = _sourceFunctionReturnValue;
            text = (bindingExpression.getDestinationPathRoot(true) + "." +
                    bindingExpression.getDestinationLValue() + " = _sourceFunctionReturnValue");
        }

        int xmlLineNumber = bindingExpression.getXmlLineNumber();
        List<Node> nodeList =
            AbstractSyntaxTreeUtil.parseExpression(context, configNamespaces, text,
                                                   xmlLineNumber, generateDocComments);
        StatementListNode body = null;
        
        if (!nodeList.isEmpty())
        {
            ExpressionStatementNode expressionStatement = (ExpressionStatementNode) nodeList.get(0);
            body = nodeFactory.statementList(null, expressionStatement);
        }

        return nodeFactory.functionCommon(context, null, functionSignature, body);
    }

    private FunctionCommonNode generateRepeatableSourceFunction(BindingExpression bindingExpression)
    {
        ParameterNode instanceIndicesParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, INSTANCE_INDICES, ARRAY, false);
        ParameterListNode parameterList = nodeFactory.parameterList(null, instanceIndicesParameter);
        ParameterNode repeaterIndicesParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, REPEATER_INDICES, ARRAY, false);
        parameterList = nodeFactory.parameterList(parameterList, repeaterIndicesParameter);
        String destinationTypeName = bindingExpression.getDestinationTypeName();
        TypeExpressionNode returnType = AbstractSyntaxTreeUtil.generateTypeExpression(nodeFactory,
                                                                                      destinationTypeName,
                                                                                      true);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(parameterList, returnType);
        StatementListNode body = null;
        String text = bindingExpression.getRepeatableSourceExpression();
        int xmlLineNumber = bindingExpression.getXmlLineNumber();
        List<Node> nodeList =
            AbstractSyntaxTreeUtil.parseExpression(context, configNamespaces, text,
                                                   xmlLineNumber, generateDocComments);
        
        if (!nodeList.isEmpty())
        {
            ExpressionStatementNode sourceExpressionStatement = (ExpressionStatementNode) nodeList.get(0);
            ListNode list = (ListNode) sourceExpressionStatement.expr;

            if (destinationTypeName.equals(STRING))
            {
                body = generateSourceFunctionStringConversion(body, destinationTypeName, list.items.get(0));
            }
            else if (destinationTypeName.equals(ARRAY))
            {
                body = generateSourceFunctionArrayConversion(body, destinationTypeName, list.items.get(0));
            }
            else
            {
                ReturnStatementNode returnStatement = nodeFactory.returnStatement(list);
                body = nodeFactory.statementList(body, returnStatement);
            }
        }

        return nodeFactory.functionCommon(context, null, functionSignature, body);
    }

    private Node generateResultVariable()
    {
        int kind = Tokens.VAR_TOKEN;
        QualifiedIdentifierNode qualifiedIdentifier = nodeFactory.qualifiedIdentifier(null, RESULT);
        MemberExpressionNode memberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, ARRAY, false);
        TypeExpressionNode typeExpression = nodeFactory.typeExpression(memberExpression, true, false, -1);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(qualifiedIdentifier, typeExpression);
        LiteralArrayNode literalArray = nodeFactory.literalArray(null);
        VariableBindingNode variableBinding = nodeFactory.variableBinding(null, kind, typedIdentifier,
                                                                          literalArray);
        ListNode list = nodeFactory.list(null, variableBinding);
        return nodeFactory.variableDefinition(null, kind, list);
    }

    private void generateSelectorAncestor(StyleSelector selector, StatementListNode statementList)
    {
        if (selector.getAncestor() != null)
        {
            generateSelectorAncestor(selector.getAncestor(), statementList);
        }

        if (selector.getConditions() != null)
        {
            // conditions = [];
            IdentifierNode identifier = nodeFactory.identifier(CONDITIONS, false);
            LiteralArrayNode literalArray = nodeFactory.literalArray(null);
            ArgumentListNode argumentList = nodeFactory.argumentList(null, literalArray);
            SetExpressionNode setExpression =
                nodeFactory.setExpression(identifier, argumentList, false);
            MemberExpressionNode memberExpression =
                nodeFactory.memberExpression(null, setExpression);
            ListNode list = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            statementList = nodeFactory.statementList(statementList, expressionStatement);

            for (StyleCondition condition : selector.getConditions())
            {
                // condition = new CSSCondition($condition.kind, "$condition.value");
                IdentifierNode conditionIdentifier = nodeFactory.identifier(CONDITION, false);
                IdentifierNode cssConditionIdentifier =
                    AbstractSyntaxTreeUtil.generateResolvedIdentifier(nodeFactory,
                                                                      standardDefs.getStylesPackage(),
                                                                      CSS_CONDITION);
                LiteralStringNode literalString = nodeFactory.literalString(condition.getKind());
                ArgumentListNode callArgumentList = nodeFactory.argumentList(null, literalString);
                literalString = nodeFactory.literalString(condition.getValue());
                callArgumentList = nodeFactory.argumentList(callArgumentList, literalString);
                CallExpressionNode callExpression =
                    (CallExpressionNode) nodeFactory.callExpression(cssConditionIdentifier, callArgumentList);
                callExpression.is_new = true;
                callExpression.setRValue(false);
                MemberExpressionNode argumentMemberExpression = nodeFactory.memberExpression(null, callExpression);
                ArgumentListNode setArgumentList = nodeFactory.argumentList(null, argumentMemberExpression);
                SetExpressionNode conditionSetExpression = nodeFactory.setExpression(conditionIdentifier, setArgumentList, false);
                MemberExpressionNode conditionMemberExpression = nodeFactory.memberExpression(null, conditionSetExpression);
                ListNode conditionList = nodeFactory.list(null, conditionMemberExpression);
                ExpressionStatementNode conditionExpressionStatement = nodeFactory.expressionStatement(conditionList);
                statementList = nodeFactory.statementList(statementList, conditionExpressionStatement);

                // conditions.push(condition);
                conditionMemberExpression =
                    AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, CONDITION, false);
                ExpressionStatementNode pushExpressionStatement =
                    generatePush(CONDITIONS, conditionMemberExpression);
                statementList = nodeFactory.statementList(statementList, pushExpressionStatement);
            }
        }
        else
        {
            // conditions = null;
            ExpressionStatementNode conditionsInitializer = generateNullInitializer(CONDITIONS);
            statementList = nodeFactory.statementList(statementList, conditionsInitializer);
        }

        // selector = new CSSSelector($selector.kind, "$selector.value", conditions, selector);
        IdentifierNode conditionIdentifier = nodeFactory.identifier(SELECTOR, false);
        IdentifierNode cssSelectorIdentifier =
            AbstractSyntaxTreeUtil.generateResolvedIdentifier(nodeFactory,
                                                              standardDefs.getStylesPackage(),
                                                              CSS_SELECTOR);
        LiteralStringNode literalString = nodeFactory.literalString(selector.getValue());
        ArgumentListNode callArgumentList = nodeFactory.argumentList(null, literalString);
        MemberExpressionNode conditionsMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, CONDITIONS, false);
        callArgumentList = nodeFactory.argumentList(callArgumentList, conditionsMemberExpression);
        MemberExpressionNode selectorMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, SELECTOR, false);
        callArgumentList = nodeFactory.argumentList(callArgumentList, selectorMemberExpression);
        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(cssSelectorIdentifier, callArgumentList);
        callExpression.is_new = true;
        callExpression.setRValue(false);
        MemberExpressionNode argumentMemberExpression = nodeFactory.memberExpression(null, callExpression);
        ArgumentListNode setArgumentList = nodeFactory.argumentList(null, argumentMemberExpression);
        SetExpressionNode setExpression = nodeFactory.setExpression(conditionIdentifier, setArgumentList, false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, setExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        statementList = nodeFactory.statementList(statementList, expressionStatement);
    }

    private StatementListNode generateSetWatcherSetupUtilFunction(StatementListNode statementList)
    {
        StatementListNode result = statementList;

        if (generateDocComments)
        {
            DocCommentNode docComment = AbstractSyntaxTreeUtil.generatePrivateDocComment(nodeFactory);
            result = nodeFactory.statementList(result, docComment);
        }

        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generatePublicStaticAttribute(nodeFactory);
        IdentifierNode watcherSetupUtilIdentifier = nodeFactory.identifier(WATCHER_SETUP_UTIL, false);
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.SET_TOKEN, watcherSetupUtilIdentifier);

        ParameterNode parameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, WATCHER_SETUP_UTIL,
                                                     IWATCHER_SETUP_UTIL2, false);
        ParameterListNode parameterList = nodeFactory.parameterList(null, parameter);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(parameterList, null);
        functionSignature.void_anno = true;

        MemberExpressionNode classMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, mxmlDocument.getClassName(), true);
        ListNode base = nodeFactory.list(null, classMemberExpression);
        IdentifierNode identifier = nodeFactory.identifier(_WATCHER_SETUP_UTIL, false);
        MemberExpressionNode watcherSetupUtilMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHER_SETUP_UTIL, false);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, watcherSetupUtilMemberExpression);
        SetExpressionNode selector = nodeFactory.setExpression(identifier, argumentList, false);
        selector.setRValue(false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        StatementListNode functionStatementList = nodeFactory.statementList(null, expressionStatement);
        FunctionCommonNode functionCommon = nodeFactory.functionCommon(context, null,
                                                                       functionSignature,
                                                                       functionStatementList);
        functionCommon.setUserDefinedBody(true);

        FunctionDefinitionNode functionDefinition = nodeFactory.functionDefinition(context, attributeList,
                                                                                   functionName, functionCommon);
        return nodeFactory.statementList(result, functionDefinition);
    }

    private FunctionCommonNode generateSourceFunction(BindingExpression bindingExpression)
    {
        String destinationTypeName = bindingExpression.getDestinationTypeName();
        TypeExpressionNode returnType = null;

        if (!destinationTypeName.equals(ASTERISK))
        {
            MemberExpressionNode memberExpression =
                AbstractSyntaxTreeUtil.generateMemberExpression(nodeFactory, destinationTypeName);
            returnType = nodeFactory.typeExpression(memberExpression, true, false, -1);
        }

        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(null, returnType);
        StatementListNode body = null;
        String text = bindingExpression.getSourceExpression();
        int xmlLineNumber = bindingExpression.getXmlLineNumber();
        List<Node> nodeList =
            AbstractSyntaxTreeUtil.parseExpression(context, configNamespaces, text,
                                                   xmlLineNumber, generateDocComments);
        
        if (!nodeList.isEmpty())
        {
            ExpressionStatementNode sourceExpressionStatement = (ExpressionStatementNode) nodeList.get(0);
            ListNode list = (ListNode) sourceExpressionStatement.expr;

            if (destinationTypeName.equals(STRING))
            {
                body = generateSourceFunctionStringConversion(body, destinationTypeName, list.items.get(0));
            }
            else if (destinationTypeName.equals(ARRAY))
            {
                body = generateSourceFunctionArrayConversion(body, destinationTypeName, list.items.get(0));
            }
            else
            {
                //if (${bindingExpression.getTwoWayCounterpart()})
                //    ${bindingExpression.getTwoWayCounterpart().getNamespaceDeclarations()}
                if (bindingExpression.getTwoWayCounterpart() != null &&
                    bindingExpression.getTwoWayCounterpart().getNamespaceDeclarations().length() > 0)
                {
                    body = bindingExpression.getTwoWayCounterpart().generateNamespaceDeclarations(context, body);
                }

                //return $bindingExpression.sourceExpression;
                ReturnStatementNode returnStatement = nodeFactory.returnStatement(list);
                body = nodeFactory.statementList(body, returnStatement);
            }
        }

        return nodeFactory.functionCommon(context, null, functionSignature, body);
    }

    private StatementListNode generateSourceFunctionArrayConversion(StatementListNode statementList,
                                                                    String destinationTypeName,
                                                                    Node initializer)
    {
        // return ((result == null) || (result is Array) || (result is flash.utils.Proxy) ? result : [result]);
        StatementListNode result = statementList;

        int kind = Tokens.VAR_TOKEN;
        QualifiedIdentifierNode qualifiedIdentifier = nodeFactory.qualifiedIdentifier(null, RESULT);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(qualifiedIdentifier, null);
        VariableBindingNode variableBinding = nodeFactory.variableBinding(null, kind, typedIdentifier,
                                                                          initializer);
        ListNode variableList = nodeFactory.list(null, variableBinding);
        Node variableDefinition = nodeFactory.variableDefinition(null, kind, variableList);
        result = nodeFactory.statementList(result, variableDefinition);

        MemberExpressionNode resultMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, RESULT, false);
        LiteralNullNode literalNull = nodeFactory.literalNull(-1);
        BinaryExpressionNode binaryExpression = nodeFactory.binaryExpression(Tokens.EQUALS_TOKEN,
                                                                             resultMemberExpression,
                                                                             literalNull);

        resultMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, RESULT, false);
        MemberExpressionNode arrayMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, ARRAY, false);
        BinaryExpressionNode arrayBinaryExpression =
            nodeFactory.binaryExpression(Tokens.IS_TOKEN, resultMemberExpression, arrayMemberExpression);
        ListNode innerBinaryExpressionList = nodeFactory.list(null, arrayBinaryExpression);

        BinaryExpressionNode innerBinaryExpression =
            nodeFactory.binaryExpression(Tokens.LOGICALOR_TOKEN, binaryExpression, innerBinaryExpressionList);

        resultMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, RESULT, false);
        MemberExpressionNode proxyMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, StandardDefs.PACKAGE_FLASH_UTILS, PROXY, false);
        BinaryExpressionNode proxyBinaryExpression =
            nodeFactory.binaryExpression(Tokens.IS_TOKEN, resultMemberExpression, proxyMemberExpression);
        ListNode outerBinaryExpressionList = nodeFactory.list(null, proxyBinaryExpression);

        BinaryExpressionNode outerBinaryExpression =
            nodeFactory.binaryExpression(Tokens.LOGICALOR_TOKEN, innerBinaryExpression, outerBinaryExpressionList);

        resultMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, RESULT, false);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, resultMemberExpression);
        LiteralArrayNode literalArray = nodeFactory.literalArray(argumentList);

        ConditionalExpressionNode conditionalExpression =
            nodeFactory.conditionalExpression(outerBinaryExpression, resultMemberExpression, literalArray);
        ListNode returnList = nodeFactory.list(null, conditionalExpression);
        ListNode returnListList = nodeFactory.list(null, returnList);
        ReturnStatementNode returnStatement = nodeFactory.returnStatement(returnListList);
        result = nodeFactory.statementList(result, returnStatement);

        return result;
    }

    private StatementListNode generateSourceFunctionStringConversion(StatementListNode statementList,
                                                                     String destinationTypeName,
                                                                     Node initializer)
    {
        // return (result == undefined ? null : String(result));
        StatementListNode result = statementList;

        int kind = Tokens.VAR_TOKEN;
        QualifiedIdentifierNode qualifiedIdentifier = nodeFactory.qualifiedIdentifier(null, RESULT);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(qualifiedIdentifier, null);
        VariableBindingNode variableBinding = nodeFactory.variableBinding(null, kind, typedIdentifier,
                                                                          initializer);
        ListNode variableList = nodeFactory.list(null, variableBinding);
        Node variableDefinition = nodeFactory.variableDefinition(null, kind, variableList);
        result = nodeFactory.statementList(result, variableDefinition);

        MemberExpressionNode resultMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, RESULT, false);
        MemberExpressionNode undefinedMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, UNDEFINED, false);
        BinaryExpressionNode binaryExpression = nodeFactory.binaryExpression(Tokens.EQUALS_TOKEN,
                                                                             resultMemberExpression,
                                                                             undefinedMemberExpression);
        LiteralNullNode literalNull = nodeFactory.literalNull(-1);

        IdentifierNode stringIdentifier = nodeFactory.identifier(destinationTypeName, false);
        resultMemberExpression = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, RESULT, false);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, resultMemberExpression);
        CallExpressionNode callExpression = (CallExpressionNode) nodeFactory.callExpression(stringIdentifier,
                                                                                            argumentList);
        callExpression.setRValue(false);
        MemberExpressionNode stringMemberExpression = nodeFactory.memberExpression(null, callExpression);
        ConditionalExpressionNode conditionalExpression =
            nodeFactory.conditionalExpression(binaryExpression, literalNull, stringMemberExpression);
        ListNode returnList = nodeFactory.list(null, conditionalExpression);
        ListNode returnListList = nodeFactory.list(null, returnList);
        ReturnStatementNode returnStatement = nodeFactory.returnStatement(returnListList);
        result = nodeFactory.statementList(result, returnStatement);

        return result;
    }

    private AttributeListNode generateMxInternalAttributeList()
    {
        MemberExpressionNode mxInternalGetterSelector =
            AbstractSyntaxTreeUtil.generateResolvedGetterSelector(nodeFactory, standardDefs.getCorePackage(), MX_INTERNAL);
        ListNode list = nodeFactory.list(null, mxInternalGetterSelector);
        return nodeFactory.attributeList(list, null);
    }

    private QualifiedIdentifierNode generateMxInternalQualifiedIdentifier(String name, boolean intern)
    {
        if (intern)
        {
            name = name.intern();
    }
        return nodeFactory.qualifiedIdentifier(generateMxInternalAttributeList(), name);
    }

    private FunctionCommonNode generateStaticPropertyGetterFunction()
    {
        ParameterNode parameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, PROPERTY_NAME, STRING, false);
        ParameterListNode parameterList = nodeFactory.parameterList(null, parameter);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(parameterList, null);

        MemberExpressionNode base =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, mxmlDocument.getClassName(), true);
        MemberExpressionNode argument =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, PROPERTY_NAME, false);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, argument);
        GetExpressionNode selector = nodeFactory.getExpression(argumentList);
        selector.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
        ListNode list = nodeFactory.list(null, memberExpression);
        ReturnStatementNode returnStatement = nodeFactory.returnStatement(list);
        StatementListNode statementList = nodeFactory.statementList(null, returnStatement);

        return nodeFactory.functionCommon(context, null, functionSignature, statementList);
    }

    private Node generateStyleDeclarationIfStatement()
    {
        ThisExpressionNode thisExpression = nodeFactory.thisExpression(-1);
        IdentifierNode styleDeclarationIdentifier = nodeFactory.identifier(STYLE_DECLARATION, false);
        GetExpressionNode getExpression = nodeFactory.getExpression(styleDeclarationIdentifier);
        MemberExpressionNode testMemberExpression = nodeFactory.memberExpression(thisExpression, getExpression);
        Node unaryExpression = nodeFactory.unaryExpression(Tokens.NOT_TOKEN, testMemberExpression);
        ListNode testList = nodeFactory.list(null, unaryExpression);

        styleDeclarationIdentifier = nodeFactory.identifier(STYLE_DECLARATION, false);
        IdentifierNode cssStyleDeclarationIdentifier =
            AbstractSyntaxTreeUtil.generateResolvedIdentifier(nodeFactory, standardDefs.getStylesPackage(),
                                                              CSS_STYLE_DECLARATION);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, nodeFactory.literalNull());
        MemberExpressionNode argumentMemberExpression = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, STYLE_MANAGER_INSTANCE, false);
        argumentList = nodeFactory.argumentList(argumentList, argumentMemberExpression);
        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(cssStyleDeclarationIdentifier, argumentList);
        callExpression.is_new = true;
        callExpression.setRValue(false);
        argumentMemberExpression = nodeFactory.memberExpression(null, callExpression);
        argumentList = nodeFactory.argumentList(null, argumentMemberExpression);
        SetExpressionNode setExpression = nodeFactory.setExpression(styleDeclarationIdentifier, argumentList, false);
        MemberExpressionNode thenMemberExpression = nodeFactory.memberExpression(thisExpression, setExpression);
        ListNode list = nodeFactory.list(null, thenMemberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        StatementListNode thenStatementList = nodeFactory.statementList(null, expressionStatement);

        return nodeFactory.ifStatement(testList, thenStatementList, null);
    }

    private FunctionCommonNode generateStyleFactory(StyleDef styleDef, StyleDeclaration declaration)
    {
        //style.factory = function():void
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(null, null);
        functionSignature.void_anno = true;
        StatementListNode statementList = null;

        if (declaration != null) // Flex 4 advanced styles
        {
            List<StyleDeclarationBlock> blocks = declaration.getDeclarationBlocks();
            for (StyleDeclarationBlock block : blocks)
            {
                Iterator<StyleProperty> iterator = block.getProperties().values().iterator();
                if (block.hasMediaList())
                {
                    //this.${style.name} = ${style.value};
                    StatementListNode stylePropStatementList = generateStyleProperties(null, iterator);

                    // if (styleManager.acceptMediaList("$block.mediaList.toString()"))
                    MemberExpressionNode expr = generateStyleManagerAcceptMediaList(block.getMediaList().toString());
                    ListNode test = nodeFactory.list(null, expr);
                    Node ifStatementNode = nodeFactory.ifStatement(test, stylePropStatementList, null);
                    statementList = nodeFactory.statementList(statementList,
                            ifStatementNode);
                }
                else
                {
                    //this.${style.name} = ${style.value};
                    statementList = generateStyleProperties(statementList, iterator);
                }
            }
        }
        else // Flex 3 legacy styles
        {
            Iterator<StyleProperty> iterator = styleDef.getStyles().values().iterator();
            statementList = generateStyleProperties(statementList, iterator);
        }

        return nodeFactory.functionCommon(context, null, functionSignature, statementList);
    }

    private StatementListNode generateStyleProperties(StatementListNode statementList, Iterator<StyleProperty> iterator)
    {
        while (iterator.hasNext())
        {
            StyleProperty styleProperty = iterator.next();
            //this.${style.name} = ${style.value};
            /*
            ThisExpressionNode base = nodeFactory.thisExpression(-1);
            IdentifierNode identifier = nodeFactory.identifier(styleProperty.getName());
            ArgumentListNode argumentList = nodeFactory.argumentList(null, );
            SetExpressionNode selector = nodeFactory.setExpression(identifier,
                                                                   argumentList, false);
            selector.setRValue(false);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
            ListNode list = nodeFactory.list(null, memberExpression);
            ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            */
            // This is a temporary hack.  We should be able to
            // generate Nodes directly for a StyleProperty.
            String text = ("this." + styleProperty.getName() + " = " + styleProperty.getValue());
            int lineNumber = styleProperty.getLineNumber();
            List<Node> nodeList =
                AbstractSyntaxTreeUtil.parseExpression(context, configNamespaces, text,
                                                       lineNumber, generateDocComments);
            
            assert nodeList.size() == 1;
            assert nodeList.get(0) instanceof ExpressionStatementNode;
            
            if (!nodeList.isEmpty())
            {
                statementList = nodeFactory.statementList(statementList, nodeList.get(0));
            }
        }

        return statementList;
    }

    // styleManager.acceptMediaList("$block.mediaList.toString()")
    private MemberExpressionNode generateStyleManagerAcceptMediaList(String mediaList)
    {
        MemberExpressionNode base =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, STYLE_MANAGER_INSTANCE, false);
        IdentifierNode getStyleDeclarationIdentifier = nodeFactory.identifier(ACCEPT_MEDIA_LIST, false);
        LiteralStringNode literalString = nodeFactory.literalString(mediaList);
        ArgumentListNode callExpressionArgumentList = nodeFactory.argumentList(null, literalString);
        CallExpressionNode selector =
            (CallExpressionNode) nodeFactory.callExpression(getStyleDeclarationIdentifier,
                                                            callExpressionArgumentList);
        selector.setRValue(false);
        MemberExpressionNode argumentMemberExpression = nodeFactory.memberExpression(base, selector);
        return argumentMemberExpression;
    }
    
    private StatementListNode generateStylesInitFunction(StatementListNode statementList)
    {
        StatementListNode result = statementList;
        result = nodeFactory.statementList(result, generateStylesInitVariable());

        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(null, null);
        functionSignature.void_anno = true;

        Node ifStatement = generateStylesInitDoneIfStatement();
        StatementListNode initFunctionStatementList = nodeFactory.statementList(null, ifStatement);

        // var style:CSSStyleDeclaration;
        VariableDefinitionNode variableDefinition = generateStylesPackageVariable(STYLE, CSS_STYLE_DECLARATION);
        initFunctionStatementList = nodeFactory.statementList(initFunctionStatementList, variableDefinition);

        // var effects:Array;
        variableDefinition = generateVariable(EFFECTS, ARRAY);
        initFunctionStatementList = nodeFactory.statementList(initFunctionStatementList, variableDefinition);

        if (!mxmlDocument.getIsIUIComponent())
        {
        	variableDefinition = generateStyleManagerVariableAndInit();
        	initFunctionStatementList = nodeFactory.statementList(initFunctionStatementList, variableDefinition);
        }
        
        if (mxmlDocument.getStylesContainer().isAdvanced())
        {
            // var conditions:Array;
            variableDefinition = generateVariable(CONDITIONS, ARRAY);
            initFunctionStatementList = nodeFactory.statementList(initFunctionStatementList, variableDefinition);

            // var condition:CSSCondition;
            variableDefinition = generateStylesPackageVariable(CONDITION, CSS_CONDITION);
            initFunctionStatementList = nodeFactory.statementList(initFunctionStatementList, variableDefinition);

            // var selector:CSSSelector;
            variableDefinition = generateStylesPackageVariable(SELECTOR, CSS_SELECTOR);
            initFunctionStatementList = nodeFactory.statementList(initFunctionStatementList, variableDefinition);
        }

        Iterator<StyleDef> styleDefIterator = mxmlDocument.getStylesContainer().getStyleDefs().iterator();

        while (styleDefIterator.hasNext())
        {
            StyleDef styleDef = styleDefIterator.next();

            if (styleDef.isAdvanced())
            {
                for (StyleDeclaration styleDeclaration : styleDef.getDeclarations().values())
                {
                    StyleSelector selector = styleDeclaration.getSelector();

                    // selector = null;
                    ExpressionStatementNode selectorInitializer = generateNullInitializer(SELECTOR);
                    initFunctionStatementList = nodeFactory.statementList(initFunctionStatementList, selectorInitializer);

                    // conditions = null;
                    ExpressionStatementNode conditionsInitializer = generateNullInitializer(CONDITIONS);
                    initFunctionStatementList = nodeFactory.statementList(initFunctionStatementList, conditionsInitializer);

                    generateSelectorAncestor(selector, initFunctionStatementList);

                    // style = StyleManager.getStyleDeclaration("${selector.toString}");
                    ExpressionStatementNode expressionStatement = generateGetStyleDeclaration(selector.toString());
            initFunctionStatementList = nodeFactory.statementList(initFunctionStatementList, expressionStatement);

                    Node nullStyleDeclarationIfStatement = generateIfNullStyleDeclaration(styleDeclaration.getSubject(), selector);
                    initFunctionStatementList = nodeFactory.statementList(initFunctionStatementList,
                                                                          nullStyleDeclarationIfStatement);

                    if (styleDeclaration.hasProperties())
                    {
                        Node nullStyleFactoryIfStatement =
                            generateIfNullStyleFactory(styleDef, styleDeclaration);
                        initFunctionStatementList = nodeFactory.statementList(initFunctionStatementList,
                                                                              nullStyleFactoryIfStatement);
                    }

                    if (styleDeclaration.hasEffectStyles())
                    {
                        // effects = style.mx_internal::effects;
                        initFunctionStatementList =
                            nodeFactory.statementList(initFunctionStatementList, generateEffectsInitializer());

                        generateIfNullEffectsAndPushes(styleDef, styleDeclaration,
                                                       initFunctionStatementList);
                    }
                }
            }
            else
            {
                ExpressionStatementNode expressionStatement;

                if (styleDef.isTypeSelector())
                {
                    //style = StyleManager.getStyleDeclaration("${styleDef.typeName}");
                    expressionStatement = generateGetStyleDeclaration(styleDef.getSubject());
                }
                else
                {
                    //style = StyleManager.getStyleDeclaration(".${styleDef.typeName}");
                    expressionStatement = generateGetStyleDeclaration("." + styleDef.getSubject());
                }

                initFunctionStatementList = nodeFactory.statementList(initFunctionStatementList, expressionStatement);

            Node nullStyleDeclarationIfStatement = generateIfNullStyleDeclaration(styleDef);
            initFunctionStatementList = nodeFactory.statementList(initFunctionStatementList,
                                                                  nullStyleDeclarationIfStatement);

            if (styleDef.getStyles().size() > 0)
            {
                    Node nullStyleFactoryIfStatement =
                        generateIfNullStyleFactory(styleDef, null);
                initFunctionStatementList = nodeFactory.statementList(initFunctionStatementList,
                                                                      nullStyleFactoryIfStatement);
            }

            if (styleDef.getEffectStyles().size() > 0)
            {
                    initFunctionStatementList =
                        nodeFactory.statementList(initFunctionStatementList, generateEffectsInitializer());

                    generateIfNullEffectsAndPushes(styleDef, null,
                                                   initFunctionStatementList);
            }
        }
        }

        if (mxmlDocument.getIsFlexApplication())
        {
            ExpressionStatementNode expressionStatement = generateInitProtoChainRoots();
            initFunctionStatementList = nodeFactory.statementList(initFunctionStatementList, expressionStatement);
        }

        FunctionCommonNode functionCommon = nodeFactory.functionCommon(context, null, functionSignature,
                                                                       initFunctionStatementList);
        functionCommon.setUserDefinedBody(true);

        AttributeListNode attributeList = generateMxInternalAttribute();
        String className = mxmlDocument.getClassName();
        IdentifierNode stylesInitIdentifier = nodeFactory.identifier("_" + className + "_StylesInit");
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.EMPTY_TOKEN, stylesInitIdentifier);

        FunctionDefinitionNode functionDefinition = nodeFactory.functionDefinition(context, attributeList,
                                                                                   functionName, functionCommon);
        result = nodeFactory.statementList(result, functionDefinition);

        return result;
    }

    private Node generateStylesInitDoneIfStatement()
    {
        String className = mxmlDocument.getClassName();
        String stylesInitDone = ("_" + className + "_StylesInit_done").intern();
        MemberExpressionNode testGetterSelector =
            generateMxInternalGetterSelector(stylesInitDone, false);
        ListNode testList = nodeFactory.list(null, testGetterSelector);

        ReturnStatementNode returnStatement = nodeFactory.returnStatement(null);
        StatementListNode thenStatementList = nodeFactory.statementList(null, returnStatement);
        MemberExpressionNode qualifier =
            AbstractSyntaxTreeUtil.generateResolvedGetterSelector(nodeFactory, standardDefs.getCorePackage(), MX_INTERNAL);
        QualifiedIdentifierNode qualifiedIdentifier = nodeFactory.qualifiedIdentifier(qualifier, stylesInitDone);
        LiteralBooleanNode literalBoolean = nodeFactory.literalBoolean(true);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, literalBoolean);
        SetExpressionNode setExpression = nodeFactory.setExpression(qualifiedIdentifier, argumentList, false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, setExpression);
        ListNode elseList = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(elseList);
        StatementListNode elseStatementList = nodeFactory.statementList(null, expressionStatement);
        return nodeFactory.ifStatement(testList, thenStatementList, elseStatementList);
    }

    private VariableDefinitionNode generateStylesInitVariable()
    {
        AttributeListNode attributeList = generateMxInternalAttributeList();
        int kind = Tokens.VAR_TOKEN;

        String className = mxmlDocument.getClassName();
        QualifiedIdentifierNode qualifiedIdentifier =
            generateMxInternalQualifiedIdentifier("_" + className + "_StylesInit_done", true);
        MemberExpressionNode memberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, BOOLEAN, false);
        TypeExpressionNode typeExpression = nodeFactory.typeExpression(memberExpression, true, false, -1);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(qualifiedIdentifier, typeExpression);
        LiteralBooleanNode literalBoolean = nodeFactory.literalBoolean(false);
        VariableBindingNode variableBinding = nodeFactory.variableBinding(attributeList, kind, typedIdentifier,
                                                                          literalBoolean);
        ListNode list = nodeFactory.list(null, variableBinding);
        return (VariableDefinitionNode) nodeFactory.variableDefinition(attributeList, kind, list);
    }

    private Node generateTargetVariable()
    {
        //var target:Object = this;
        int kind = Tokens.VAR_TOKEN;
        QualifiedIdentifierNode qualifiedIdentifier = nodeFactory.qualifiedIdentifier(null, TARGET);
        MemberExpressionNode memberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, OBJECT, true);
        TypeExpressionNode typeExpression = nodeFactory.typeExpression(memberExpression, true, false, -1);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(qualifiedIdentifier, typeExpression);
        ThisExpressionNode thisExpression = nodeFactory.thisExpression(-1);
        VariableBindingNode variableBinding = nodeFactory.variableBinding(null, kind, typedIdentifier,
                                                                          thisExpression);
        ListNode list = nodeFactory.list(null, variableBinding);
        return nodeFactory.variableDefinition(null, kind, list);
    }

    private ExpressionStatementNode generateTwoWayCounterpartAssignment(int leftValueId, int rightValueId)
    {
        MemberExpressionNode leftResultMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, RESULT, false);
        LiteralNumberNode leftLiteralNumber = nodeFactory.literalNumber(leftValueId);;
        ArgumentListNode leftGetExpressionArgumentList = nodeFactory.argumentList(null, leftLiteralNumber);
        GetExpressionNode leftGetExpression = nodeFactory.getExpression(leftGetExpressionArgumentList);
        leftGetExpression.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode base = nodeFactory.memberExpression(leftResultMemberExpression, leftGetExpression);

        IdentifierNode twoWayCounterpartIdentifier = nodeFactory.identifier(TWO_WAY_COUNTERPART, false);
        MemberExpressionNode rightResultMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, RESULT, false);
        LiteralNumberNode rightLiteralNumber = nodeFactory.literalNumber(rightValueId);;
        ArgumentListNode rightGetExpressionArgumentList = nodeFactory.argumentList(null, rightLiteralNumber);
        GetExpressionNode rightGetExpression = nodeFactory.getExpression(rightGetExpressionArgumentList);
        rightGetExpression.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode rightValueMemberExpression =
            nodeFactory.memberExpression(rightResultMemberExpression, rightGetExpression);
        ArgumentListNode setExpressionArgumentList = nodeFactory.argumentList(null, rightValueMemberExpression);
        SetExpressionNode selector = nodeFactory.setExpression(twoWayCounterpartIdentifier,
                                                               setExpressionArgumentList, false);

        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    private StatementListNode generateTypeImportDummies(StatementListNode statementList)
    {
        StatementListNode result = statementList;

        Iterator<String> iterator = mxmlDocument.getTypeRefs().iterator();
        int index = 1;

        while (iterator.hasNext())
        {
            TypeExpressionNode typeExpression =
                AbstractSyntaxTreeUtil.generateTypeExpression(nodeFactory, iterator.next(), true);
            Node variableDefinition =
                AbstractSyntaxTreeUtil.generatePrivateVariable(nodeFactory, typeExpression,
                                                               "_typeRef" + index);
            result = nodeFactory.statementList(result, variableDefinition);
            index++;
        }

        return result;
    }

    private ExpressionStatementNode generateWatchersAssignment()
    {
        MemberExpressionNode mxInternalGetterSelector =
            AbstractSyntaxTreeUtil.generateResolvedGetterSelector(nodeFactory, standardDefs.getCorePackage(), MX_INTERNAL);
        QualifiedIdentifierNode qualifiedIdentifier =
            AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory, mxInternalGetterSelector,
                                                               _WATCHERS, false);
        MemberExpressionNode rvalueBase = generateMxInternalGetterSelector(_WATCHERS, false);
        IdentifierNode concatIdentifier = nodeFactory.identifier(CONCAT, false);
        MemberExpressionNode watchersMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WATCHERS, false);
        ArgumentListNode concatArgumentList = nodeFactory.argumentList(null, watchersMemberExpression);
        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(concatIdentifier, concatArgumentList);
        callExpression.setRValue(false);
        MemberExpressionNode argument = nodeFactory.memberExpression(rvalueBase, callExpression);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, argument);
        SetExpressionNode setExpression = nodeFactory.setExpression(qualifiedIdentifier, argumentList, false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, setExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        return nodeFactory.expressionStatement(list);
    }

    private Node generateWatchersVariable()
    {
        int kind = Tokens.VAR_TOKEN;
        QualifiedIdentifierNode qualifiedIdentifier = nodeFactory.qualifiedIdentifier(null, WATCHERS);
        MemberExpressionNode memberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, ARRAY, false);
        TypeExpressionNode typeExpression = nodeFactory.typeExpression(memberExpression, true, false, -1);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(qualifiedIdentifier, typeExpression);
        LiteralArrayNode literalArray = nodeFactory.literalArray(null);
        VariableBindingNode variableBinding = nodeFactory.variableBinding(null, kind, typedIdentifier,
                                                                          literalArray);
        ListNode list = nodeFactory.list(null, variableBinding);
        return nodeFactory.variableDefinition(null, kind, list);
    }

    private Node generateWatcherSetupUtilClassVariable()
    {
        int kind = Tokens.VAR_TOKEN;
        QualifiedIdentifierNode qualifiedIdentifier = nodeFactory.qualifiedIdentifier(null, WATCHER_SETUP_UTIL_CLASS);
        MemberExpressionNode memberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, OBJECT, false);
        TypeExpressionNode typeExpression = nodeFactory.typeExpression(memberExpression, true, false, -1);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(qualifiedIdentifier, typeExpression);

        IdentifierNode getDefinitionByNameIdentifier = nodeFactory.identifier(GET_DEFINITION_BY_NAME, false);
        LiteralStringNode literalString = nodeFactory.literalString(mxmlDocument.getWatcherSetupUtilClassName());
        ArgumentListNode argumentList = nodeFactory.argumentList(null, literalString);
        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(getDefinitionByNameIdentifier, argumentList);
        callExpression.setRValue(false);
        MemberExpressionNode initializer = nodeFactory.memberExpression(null, callExpression);
        VariableBindingNode variableBinding = nodeFactory.variableBinding(null, kind, typedIdentifier,
                                                                          initializer);
        ListNode list = nodeFactory.list(null, variableBinding);
        return nodeFactory.variableDefinition(null, kind, list);
    }

	/**
	 * wrapper for generating entire descriptor tree. See notes on includePropNames param below.
	 */
	private static MemberExpressionNode getDescriptorInitializerFragments(NodeFactory nodeFactory, HashSet<String>configNamespaces,
                                                                          boolean generateDocComments, Model model)
	{
        return addDescriptorInitializerFragments(nodeFactory, configNamespaces, generateDocComments, model,
                                                 FrameworkDefs.requiredTopLevelDescriptorProperties,
                                                 true);
	}

    String getPath()
    {
        return mxmlDocument.getSourcePath();
    }
    
    /**
     *  private var __moduleFactoryInitialized:Boolean = false;
	 *
     * @return
     */
    private VariableDefinitionNode generateModuleFactoryInitializedVariable()
    {
    	
        MemberExpressionNode memberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, BOOLEAN, false);
        TypeExpressionNode typeExpression = nodeFactory.typeExpression(memberExpression, true, false, -1);
        LiteralBooleanNode literalBoolean = nodeFactory.literalBoolean(false);
    	Node variableDefinition = AbstractSyntaxTreeUtil.generatePrivateVariable(nodeFactory, 
    														typeExpression,
    														__MODULE_FACTORY_INITIALIZED,
    														literalBoolean);
        return (VariableDefinitionNode)variableDefinition;
    }
    
    
    /**
     *          override public function set moduleFactory(factory:IFlexModuleFactory):void
	 *          {
	 *               super.moduleFactory = factory;
	 *               
	 *               if (__moduleFactoryInitialized)
	 *                   return;
     *	
	 *              __moduleFactoryInitialized = true;
	 *              
	 *              // statementList
     *          }
     *           
     * @param statementList - statements to be executed in the module factory property override.
     * @return
     */
    private FunctionDefinitionNode generateModuleFactoryPropertyOverride(StatementListNode statementList)
    {
        // constructor(factory:IFlexModuleFactory)
        ParameterNode parameter = AbstractSyntaxTreeUtil.generateParameter(nodeFactory, FACTORY, IFLEX_MODULE_FACTORY, true);
        ParameterListNode constructorParameterList = nodeFactory.parameterList(null, parameter);
	    FunctionSignatureNode functionSignature = nodeFactory.functionSignature(constructorParameterList, null);
	    functionSignature.void_anno = true;
	
        // super.moduleFactory = factory;
	    MemberExpressionNode memberExpression = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, FACTORY, false);
	    ExpressionStatementNode expressionStatement = AbstractSyntaxTreeUtil.generateAssignment(nodeFactory, 
			    										  nodeFactory.superExpression(null, -1), 
			    										  MODULE_FACTORY, 
			    										  memberExpression);
	    StatementListNode initStatementList = nodeFactory.statementList(null, expressionStatement);
        
        // if (__moduleFactoryInitialized)
        //     return;
	    memberExpression = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, __MODULE_FACTORY_INITIALIZED, false);
	    ListNode listNode = nodeFactory.list(null, memberExpression);
	    Node ifStatement = nodeFactory.ifStatement(listNode, nodeFactory.returnStatement(null), null); 
	    initStatementList = nodeFactory.statementList(initStatementList, ifStatement);
	    					

	    // __moduleFactoryInitialized = true;
 	    expressionStatement = AbstractSyntaxTreeUtil.generateAssignment(nodeFactory, null, __MODULE_FACTORY_INITIALIZED, 
 	    						nodeFactory.literalBoolean(true));
 	    initStatementList = nodeFactory.statementList(initStatementList, expressionStatement);
 	    
 	    // combine the statements we created here with the passed in statements
 	    statementList = nodeFactory.statementList(initStatementList, statementList);
 	    
	    AttributeListNode attributeList = AbstractSyntaxTreeUtil.generateOverridePublicAttribute(nodeFactory);
	    QualifiedIdentifierNode identifier = nodeFactory.qualifiedIdentifier(attributeList, MODULE_FACTORY);
	    FunctionCommonNode functionCommon = nodeFactory.functionCommon(context, identifier, functionSignature, statementList);
	    functionCommon.setUserDefinedBody(true);
	
	    FunctionNameNode functionName = nodeFactory.functionName(Tokens.SET_TOKEN, identifier);
	
	    return nodeFactory.functionDefinition(context, attributeList, functionName, functionCommon);
	}

	// #if ($doc.isIFlexModule)         
	//     var styleManager:IStyleManager2 = StyleManager.getStyleManager(moduleFactory);
	// #else
	//     var styleManager:IStyleManager2 = StyleManager.getStyleManager(null);
	// #end
	//
    private VariableDefinitionNode generateStyleManagerVariableAndInit()
    {
    	int kind = Tokens.VAR_TOKEN;
        QualifiedIdentifierNode qualifiedIdentifier = nodeFactory.qualifiedIdentifier(null, STYLE_MANAGER_INSTANCE);
        MemberExpressionNode memberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, ISTYLE_MANAGER2, false);
        TypeExpressionNode typeExpression = nodeFactory.typeExpression(memberExpression, true, false, -1);
        TypedIdentifierNode typedIdentifier = nodeFactory.typedIdentifier(qualifiedIdentifier, typeExpression);

        // initialize the variable
        MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, STYLE_MANAGER, false);
        ArgumentListNode args = null;
         
        if (mxmlDocument.getIsIFlexModule())
        {
        	args = nodeFactory.argumentList(null, 
    		                        AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, MODULE_FACTORY, false));
        }
        else
        {
        	args = nodeFactory.argumentList(null, nodeFactory.literalNull());
        }
        
        CallExpressionNode selector = (CallExpressionNode) nodeFactory.callExpression(
        																nodeFactory.identifier(GET_STYLE_MANAGER), args);
        selector.setRValue(false);
        memberExpression = nodeFactory.memberExpression(base, selector);
        VariableBindingNode variableBinding = nodeFactory.variableBinding(null, kind, typedIdentifier, memberExpression);
        ListNode list = nodeFactory.list(null, variableBinding);
                
        return (VariableDefinitionNode) nodeFactory.variableDefinition(null, kind, list);

    }
    
}
