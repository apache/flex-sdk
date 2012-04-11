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

import flex2.compiler.CompilationUnit;
import flex2.compiler.as3.AbstractSyntaxTreeUtil;
import flex2.compiler.as3.MetaDataEvaluator;
import flex2.compiler.as3.genext.GenerativeClassInfo.AccessorInfo;
import flex2.compiler.as3.genext.GenerativeClassInfo.GetterSetterInfo;
import flex2.compiler.as3.genext.GenerativeClassInfo.VariableInfo;
import flex2.compiler.as3.genext.GenerativeClassInfo;
import flex2.compiler.as3.genext.GenerativeExtension;
import flex2.compiler.as3.genext.GenerativeSecondPassEvaluator;
import flex2.compiler.as3.reflect.NodeMagic;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.MultiName;
import flex2.compiler.util.QName;
import macromedia.asc.parser.ArgumentListNode;
import macromedia.asc.parser.AttributeListNode;
import macromedia.asc.parser.BinaryExpressionNode;
import macromedia.asc.parser.ClassDefinitionNode;
import macromedia.asc.parser.CallExpressionNode;
import macromedia.asc.parser.DefinitionNode;
import macromedia.asc.parser.DocCommentNode;
import macromedia.asc.parser.ExpressionStatementNode;
import macromedia.asc.parser.FunctionCommonNode;
import macromedia.asc.parser.FunctionDefinitionNode;
import macromedia.asc.parser.FunctionNameNode;
import macromedia.asc.parser.FunctionSignatureNode;
import macromedia.asc.parser.GetExpressionNode;
import macromedia.asc.parser.IdentifierNode;
import macromedia.asc.parser.ListNode;
import macromedia.asc.parser.LiteralBooleanNode;
import macromedia.asc.parser.LiteralNullNode;
import macromedia.asc.parser.LiteralNumberNode;
import macromedia.asc.parser.LiteralStringNode;
import macromedia.asc.parser.MemberExpressionNode;
import macromedia.asc.parser.MetaDataNode;
import macromedia.asc.parser.Node;
import macromedia.asc.parser.NodeFactory;
import macromedia.asc.parser.ParameterListNode;
import macromedia.asc.parser.ParameterNode;
import macromedia.asc.parser.QualifiedIdentifierNode;
import macromedia.asc.parser.ReturnStatementNode;
import macromedia.asc.parser.SetExpressionNode;
import macromedia.asc.parser.StatementListNode;
import macromedia.asc.parser.Tokens;
import macromedia.asc.parser.ThisExpressionNode;
import macromedia.asc.parser.TypeExpressionNode;
import macromedia.asc.parser.VariableDefinitionNode;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;

import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;

/**
 * This class handles the AST manipulation of wrapping properties and
 * variables, with getter/setter pairs, which handle change detection
 * and the dispatching of mx.events.PropertyChangeEvent's.
 *
 * @author Paul Reilly
 */
public class BindableSecondPassEvaluator extends GenerativeSecondPassEvaluator
{
    private static final String ADD_EVENT_LISTENER = "addEventListener".intern();
    private static final String BINDABLE = "Bindable".intern();
    private static final String BOOLEAN = "Boolean".intern();
    private static final String CREATE_UPDATE_EVENT = "createUpdateEvent".intern();
    private static final String DISPATCH_EVENT = "dispatchEvent".intern();
    private static final String EVENT_VAR = "event".intern();
    private static final String EVENT_CLASS = "Event".intern();
    private static final String EVENT_DISPATCHER_VAR = "eventDispatcher".intern();
    private static final String EVENT_DISPATCHER_CLASS = "EventDispatcher".intern();
    private static final String FLASH_EVENTS = "flash.events".intern();
    private static final String FUNCTION = "Function".intern();
    private static final String HAS_EVENT_LISTENER = "hasEventListener".intern();
    private static final String INT = "int".intern();
    private static final String I_EVENT_DISPATCHER = "IEventDispatcher".intern();
    private static final String LISTENER = "listener".intern();
    private static final String MX_EVENTS = "mx.events".intern();
    private static final String OBJECT = "Object".intern();
    private static final String OLD_VALUE= "oldValue".intern();
    private static final String PRIORITY = "priority".intern();
    private static final String PROPERTY_CHANGE = "propertyChange".intern();
    private static final String PROPERTY_CHANGE_EVENT = "PropertyChangeEvent".intern();
    private static final String REMOVE_EVENT_LISTENER = "removeEventListener".intern();
    private static final String STRING = "String".intern();
    private static final String TYPE = "type".intern();
    private static final String USE_CAPTURE = "useCapture".intern();
    private static final String VALUE = "value".intern();
    private static final String WEAK_REF = "weakRef".intern();
    private static final String WILL_TRIGGER = "willTrigger".intern();
    private static final String _BINDING_EVENT_DISPATCHER = "_bindingEventDispatcher".intern();
    private static final String _STATIC_BINDING_EVENT_DISPATCHER = "_staticBindingEventDispatcher".intern();

    private static final String DOT = ".";
    private static final String SPACE = " ";

	private static final String CODEGEN_TEMPLATE_PATH = "flex2/compiler/as3/binding/";
	private static final String STATIC_EVENT_DISPATCHER = "staticEventDispatcher";
	private BindableInfo bindableInfo;
	private boolean inClass = false;

	public BindableSecondPassEvaluator(CompilationUnit unit, Map<String, ? extends GenerativeClassInfo> classMap,
									   TypeAnalyzer typeAnalyzer, String generatedOutputDirectory,
                                       boolean generateAbstractSyntaxTree, boolean processComments)
	{
		super(unit, classMap, typeAnalyzer, generatedOutputDirectory, generateAbstractSyntaxTree, processComments);
	}

    private void addIEventDispatcherImplementation(Context context, ClassDefinitionNode classDefinition)
    {
        NodeFactory nodeFactory = context.getNodeFactory();
        MemberExpressionNode memberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, FLASH_EVENTS,
                                                          I_EVENT_DISPATCHER, false);
        classDefinition.interfaces = nodeFactory.list(classDefinition.interfaces, memberExpression);

        VariableDefinitionNode variableDefinition = generateBindingEventDispatcherVariable(nodeFactory);
        classDefinition.statements =
            nodeFactory.statementList(classDefinition.statements, variableDefinition);

        DocCommentNode docCommentNode = generateInheritDocComment(context);
        classDefinition.statements =
            nodeFactory.statementList(classDefinition.statements, docCommentNode);
        
        FunctionDefinitionNode addEventListenerFunctionDefinition =
            generateAddEventListenerFunctionDefinition(context);
        classDefinition.statements =
            nodeFactory.statementList(classDefinition.statements, addEventListenerFunctionDefinition);

        docCommentNode = generateInheritDocComment(context);
        classDefinition.statements =
            nodeFactory.statementList(classDefinition.statements, docCommentNode);
        
        FunctionDefinitionNode dispatchEventFunctionDefinition =
            generateDispatchEventFunctionDefinition(context);
        classDefinition.statements =
            nodeFactory.statementList(classDefinition.statements, dispatchEventFunctionDefinition);

        docCommentNode = generateInheritDocComment(context);
        classDefinition.statements =
            nodeFactory.statementList(classDefinition.statements, docCommentNode);
        
        FunctionDefinitionNode hasEventListenerFunctionDefinition =
            generateHasEventListenerFunctionDefinition(context);
        classDefinition.statements =
            nodeFactory.statementList(classDefinition.statements, hasEventListenerFunctionDefinition);

        docCommentNode = generateInheritDocComment(context);
        classDefinition.statements =
            nodeFactory.statementList(classDefinition.statements, docCommentNode);
        
        FunctionDefinitionNode removeEventListenerFunctionDefinition =
            generateRemoveEventListenerFunctionDefinition(context);
        classDefinition.statements =
            nodeFactory.statementList(classDefinition.statements, removeEventListenerFunctionDefinition);

        docCommentNode = generateInheritDocComment(context);
        classDefinition.statements =
            nodeFactory.statementList(classDefinition.statements, docCommentNode);
        
        FunctionDefinitionNode willTriggerFunctionDefinition =
            generateWillTriggerFunctionDefinition(context);
        classDefinition.statements =
            nodeFactory.statementList(classDefinition.statements, willTriggerFunctionDefinition);
    }

    private void addStaticEventDispatcherImplementation(Context context, ClassDefinitionNode classDefinition)
    {
        NodeFactory nodeFactory = context.getNodeFactory();
        VariableDefinitionNode variableDefinition = generateStaticBindingEventDispatcherVariable(nodeFactory);
        classDefinition.statements =
            nodeFactory.statementList(classDefinition.statements, variableDefinition);

        FunctionDefinitionNode addEventListenerFunctionDefinition = 
            generateStaticEventDispatcherGetter(context);
        classDefinition.statements =
            nodeFactory.statementList(classDefinition.statements, addEventListenerFunctionDefinition);
    }

	/**
	 *
	 */
	public Value evaluate(Context context, ClassDefinitionNode node)
	{
		if (!evaluatedClasses.contains(node))
		{
			inClass = true;

			String className = NodeMagic.getClassName(node);

			bindableInfo = (BindableInfo) classMap.get(className);

			if (bindableInfo != null)
			{
				ClassInfo classInfo = bindableInfo.getClassInfo();
				if (!classInfo.implementsInterface(StandardDefs.PACKAGE_FLASH_EVENTS,
												   GenerativeExtension.IEVENT_DISPATCHER))
				{
					bindableInfo.setNeedsToImplementIEventDispatcher(true);

					MultiName multiName = new MultiName(StandardDefs.PACKAGE_FLASH_EVENTS,
														GenerativeExtension.IEVENT_DISPATCHER);
					InterfaceInfo interfaceInfo = typeAnalyzer.analyzeInterface(context, multiName, classInfo);

                    // interfaceInfo will be null if IEventDispatcher was not resolved.
                    // This most likely means that playerglobal.swc was not in the
                    // external-library-path and other errors will be reported, so punt.
					if ((interfaceInfo == null) || checkForExistingMethods(context, node, classInfo, interfaceInfo))
					{
						return null;
					}

					classInfo.addInterfaceMultiName(StandardDefs.PACKAGE_FLASH_EVENTS,
													GenerativeExtension.IEVENT_DISPATCHER);
				}

				if (bindableInfo.getRequiresStaticEventDispatcher() &&
					(!classInfo.definesVariable(STATIC_EVENT_DISPATCHER) &&
					 !classInfo.definesGetter(STATIC_EVENT_DISPATCHER, true)))
				{
					bindableInfo.setNeedsStaticEventDispatcher(true);
				}

				postProcessClassInfo(context, bindableInfo);
				prepClassDef(node);

				if (node.statements != null)
				{
					node.statements.evaluate(context, this);
					modifySyntaxTree(context, node, bindableInfo);
				}

				bindableInfo = null;
			}

			inClass = false;

			// Make sure we don't process this class again.
			evaluatedClasses.add(node);
		}

		return null;
	}

    private AttributeListNode generateAttributeList(NodeFactory nodeFactory, String attributeString)
    {
        AttributeListNode result = null;

        if (attributeString.length() > 0)
        {
            int index = attributeString.indexOf(SPACE);

            if (index > -1)
            {
                IdentifierNode identifier = nodeFactory.identifier(attributeString.substring(index + 1));
                AttributeListNode attributeList = nodeFactory.attributeList(identifier, null);
                MemberExpressionNode memberExpression =
                    AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, attributeString.substring(0, index), true);
                ListNode list = nodeFactory.list(null, memberExpression);
                result = nodeFactory.attributeList(list, attributeList);
            }
            else
            {
                MemberExpressionNode memberExpression =
                    AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, attributeString, true);
                ListNode list = nodeFactory.list(null, memberExpression);
                result = nodeFactory.attributeList(list, null);
            }
        }

        return result;
    }

    private VariableDefinitionNode generateBindingEventDispatcherVariable(NodeFactory nodeFactory)
    {
        // Equivalent AS:
        //
        //   private var _bindingEventDispatcher:flash.events.EventDispatcher =
        //     new flash.events.EventDispatcher(flash.events.IEventDispatcher(this));
        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generatePrivateAttribute(nodeFactory);
        IdentifierNode identifier = nodeFactory.identifier(_BINDING_EVENT_DISPATCHER, false);
        QualifiedIdentifierNode eventDispatcherQualifiedIdentifier =
            AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory, FLASH_EVENTS,
                                                               EVENT_DISPATCHER_CLASS, false);
        QualifiedIdentifierNode iEventDispatcherQualifiedIdentifier =
            AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory, FLASH_EVENTS,
                                                               I_EVENT_DISPATCHER, false);
        ThisExpressionNode thisExpression = nodeFactory.thisExpression(0);
        ArgumentListNode castArgumentList = nodeFactory.argumentList(null, thisExpression);
        CallExpressionNode castCallExpression =
            (CallExpressionNode) nodeFactory.callExpression(iEventDispatcherQualifiedIdentifier,
                                                            castArgumentList);
        castCallExpression.setRValue(false);
        MemberExpressionNode innerMemberExpression = nodeFactory.memberExpression(null, castCallExpression);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, innerMemberExpression);
        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(eventDispatcherQualifiedIdentifier,
                                                            argumentList);
        callExpression.is_new = true;
        callExpression.setRValue(false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, callExpression);
        return AbstractSyntaxTreeUtil.generateVariable(nodeFactory, attributeList, identifier,
                                                       FLASH_EVENTS, EVENT_DISPATCHER_CLASS,
                                                       false, memberExpression);
    }

    private StatementListNode generateDispatchEventCall(NodeFactory nodeFactory, StatementListNode then,
                                                        String qualifiedPropertyName)
    {
        // Equivalent AS:
        //   if (this.hasEventListener("propertyChange"))
        //       this.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(this, "$entry.qualifiedPropertyName", oldValue, value));
        ThisExpressionNode innerThisExpression = nodeFactory.thisExpression(0);
        IdentifierNode dispatchEventIdentifier = nodeFactory.identifier(DISPATCH_EVENT, false);

        MemberExpressionNode propertyChangeEventMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, MX_EVENTS, PROPERTY_CHANGE_EVENT, false);;
        IdentifierNode createUpdateEventIdentifier = nodeFactory.identifier(CREATE_UPDATE_EVENT, false);
        ThisExpressionNode thisExpression = nodeFactory.thisExpression(0);
        ArgumentListNode createUpdateEventArgumentList = nodeFactory.argumentList(null, innerThisExpression);

        LiteralStringNode literalString = nodeFactory.literalString(qualifiedPropertyName);
        createUpdateEventArgumentList = nodeFactory.argumentList(createUpdateEventArgumentList, literalString);

        MemberExpressionNode oldValueMemberExpression = 
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, OLD_VALUE, false);
        createUpdateEventArgumentList =
            nodeFactory.argumentList(createUpdateEventArgumentList, oldValueMemberExpression);

        MemberExpressionNode valueMemberExpression = 
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, VALUE, false);
        createUpdateEventArgumentList =
            nodeFactory.argumentList(createUpdateEventArgumentList, valueMemberExpression);

        CallExpressionNode createUpdateEventCallExpression = 
            (CallExpressionNode) nodeFactory.callExpression(createUpdateEventIdentifier, createUpdateEventArgumentList);
        createUpdateEventCallExpression.setRValue(false);
        MemberExpressionNode createUpdateEventMemberExpression =
            nodeFactory.memberExpression(propertyChangeEventMemberExpression, createUpdateEventCallExpression);
        ArgumentListNode dispatchEventArgumentList = 
            nodeFactory.argumentList(null, createUpdateEventMemberExpression);
        CallExpressionNode dispatchEventCallExpression =
            (CallExpressionNode) nodeFactory.callExpression(dispatchEventIdentifier, dispatchEventArgumentList);
        dispatchEventCallExpression.setRValue(false);
        MemberExpressionNode memberExpression =
            nodeFactory.memberExpression(thisExpression, dispatchEventCallExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement =
            nodeFactory.expressionStatement(list);
        
        // if (this.hasEventListener("propertyChange"))
        ThisExpressionNode ifThisExpression = nodeFactory.thisExpression(0);
        IdentifierNode hasEventListenerIdentifier = nodeFactory.identifier(HAS_EVENT_LISTENER, false);
        LiteralStringNode propChangeLiteralString = nodeFactory.literalString(PROPERTY_CHANGE);
        CallExpressionNode hasEventListenerCallExpression =
            (CallExpressionNode) nodeFactory.callExpression(hasEventListenerIdentifier, nodeFactory.argumentList(null, propChangeLiteralString));
        hasEventListenerCallExpression.setRValue(false);
        MemberExpressionNode ifMemberExpression =
            nodeFactory.memberExpression(ifThisExpression, hasEventListenerCallExpression);
        ListNode iftest = nodeFactory.list(null, ifMemberExpression);
        Node ifStatement = nodeFactory.ifStatement(iftest, expressionStatement, null);
        
        return nodeFactory.statementList(then, ifStatement);
    }

    private DocCommentNode generateInheritDocComment(Context context)
    {
        // Equivalent AS:
        //
        //    /**
    	//     * @inheritDoc
    	//     */
        NodeFactory nodeFactory = context.getNodeFactory();

        return AbstractSyntaxTreeUtil.generateInheritDocComment(nodeFactory);
    }
    
    private FunctionDefinitionNode generateAddEventListenerFunctionDefinition(Context context)
    {
        // Equivalent AS:
        //
        //    public function addEventListener(type:String, listener:Function,
        //                                     useCapture:Boolean = false,
        //                                     priority:int = 0,
        //                                     weakRef:Boolean = false):void
        //    {
        //        _bindingEventDispatcher.addEventListener(type, listener, useCapture,
        //                                                 priority, weakRef);
        //    }
        NodeFactory nodeFactory = context.getNodeFactory();

        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generatePublicAttribute(nodeFactory);

        IdentifierNode addEventListenerIdentifier = nodeFactory.identifier(ADD_EVENT_LISTENER, false);
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.EMPTY_TOKEN, addEventListenerIdentifier);

        ParameterNode typeParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, TYPE, STRING, false);
        ParameterListNode parameterList = nodeFactory.parameterList(null, typeParameter);
        ParameterNode listenerParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, LISTENER, FUNCTION, false);
        parameterList = nodeFactory.parameterList(parameterList, listenerParameter);
        LiteralBooleanNode literalBoolean = nodeFactory.literalBoolean(false);
        ParameterNode useCaptureParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, USE_CAPTURE, BOOLEAN,
                                                     false, literalBoolean);
        parameterList = nodeFactory.parameterList(parameterList, useCaptureParameter);
        LiteralNumberNode literalNumber = nodeFactory.literalNumber(0);
        ParameterNode priorityParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, PRIORITY, INT,
                                                     false, literalNumber);
        parameterList = nodeFactory.parameterList(parameterList, priorityParameter);
        literalBoolean = nodeFactory.literalBoolean(false);
        ParameterNode weakRefParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, WEAK_REF, BOOLEAN,
                                                     false, literalBoolean);
        parameterList = nodeFactory.parameterList(parameterList, weakRefParameter);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(parameterList, null);
        functionSignature.void_anno = true;

        MemberExpressionNode _bindingEventDispatcherGetterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, _BINDING_EVENT_DISPATCHER, false);
        IdentifierNode identifier = nodeFactory.identifier(ADD_EVENT_LISTENER, false);
        MemberExpressionNode typeGetterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, TYPE, false);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, typeGetterSelector);
        MemberExpressionNode listenerGetterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, LISTENER, false);
        argumentList = nodeFactory.argumentList(argumentList, listenerGetterSelector);
        MemberExpressionNode useCaptureGetterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, USE_CAPTURE, false);
        argumentList = nodeFactory.argumentList(argumentList, useCaptureGetterSelector);
        MemberExpressionNode priorityGetterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, PRIORITY, false);
        argumentList = nodeFactory.argumentList(argumentList, priorityGetterSelector);
        MemberExpressionNode weakRefGetterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, WEAK_REF, false);
        argumentList = nodeFactory.argumentList(argumentList, weakRefGetterSelector);
        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(identifier, argumentList);
        callExpression.setRValue(false);
        MemberExpressionNode memberExpression =
            nodeFactory.memberExpression(_bindingEventDispatcherGetterSelector, callExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);

        StatementListNode functionStatementList = nodeFactory.statementList(null, expressionStatement);

        FunctionCommonNode functionCommon = nodeFactory.functionCommon(context, null, functionSignature,
                                                                       functionStatementList);
        functionCommon.setUserDefinedBody(true);

        return nodeFactory.functionDefinition(context, attributeList, functionName, functionCommon);
    }

    private FunctionDefinitionNode generateDispatchEventFunctionDefinition(Context context)
    {
        // Equivalent AS:
        //
        //    public function dispatchEvent(event:flash.events.Event):Boolean
        //    {
        //        return _bindingEventDispatcher.dispatchEvent(event);
        //    }
        NodeFactory nodeFactory = context.getNodeFactory();

        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generatePublicAttribute(nodeFactory);

        IdentifierNode dispatchEventIdentifier = nodeFactory.identifier(DISPATCH_EVENT, false);
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.EMPTY_TOKEN, dispatchEventIdentifier);

        ParameterNode parameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, EVENT_VAR, FLASH_EVENTS, EVENT_CLASS, false);
        ParameterListNode parameterList = nodeFactory.parameterList(null, parameter);
        MemberExpressionNode returnTypeMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, BOOLEAN, true);
        TypeExpressionNode returnType = nodeFactory.typeExpression(returnTypeMemberExpression, true, false, -1);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(parameterList, returnType);

        MemberExpressionNode _bindingEventDispatcherGetterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, _BINDING_EVENT_DISPATCHER, false);
        IdentifierNode identifier = nodeFactory.identifier(DISPATCH_EVENT, false);
        MemberExpressionNode eventGetterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, EVENT_VAR, false);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, eventGetterSelector);
        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(identifier, argumentList);
        callExpression.setRValue(false);

        MemberExpressionNode memberExpression =
            nodeFactory.memberExpression(_bindingEventDispatcherGetterSelector, callExpression);
        ListNode returnList = nodeFactory.list(null, memberExpression);
        ReturnStatementNode returnStatement = nodeFactory.returnStatement(returnList);

        StatementListNode functionStatementList = nodeFactory.statementList(null, returnStatement);

        FunctionCommonNode functionCommon = nodeFactory.functionCommon(context, null, functionSignature,
                                                                       functionStatementList);
        functionCommon.setUserDefinedBody(true);

        return nodeFactory.functionDefinition(context, attributeList, functionName, functionCommon);
    }

    private ListNode generateEventDispatcherNotNull(NodeFactory nodeFactory)
    {
        // Equivalent AS:
        //
        //   if (eventDispatcher != null)
        MemberExpressionNode memberExpression = 
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, EVENT_DISPATCHER_VAR, false);
        LiteralNullNode literalNull = nodeFactory.literalNull();
        BinaryExpressionNode binaryExpression = nodeFactory.binaryExpression(Tokens.STRICTNOTEQUALS_TOKEN,
                                                                             memberExpression,
                                                                             literalNull);
        return nodeFactory.list(null, binaryExpression);
    }

    private FunctionDefinitionNode generateGetter(Context context, String className,
                                                  AccessorInfo accessorInfo)
    {
        // Equivalent AS:
        //
        //  $entry.attributeString function get ${entry.propertyName}():$entry.typeName
        NodeFactory nodeFactory = context.getNodeFactory();
        String typeName = accessorInfo.getTypeName();
        int index = typeName.lastIndexOf(DOT);
        int position = ((VariableInfo) accessorInfo).getPosition();
        TypeExpressionNode returnType = AbstractSyntaxTreeUtil.generateTypeExpression(nodeFactory, typeName, true);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(null, returnType);
        AttributeListNode attributeList = generateAttributeList(nodeFactory, accessorInfo.getAttributeString());
        IdentifierNode identifier = nodeFactory.identifier(accessorInfo.getPropertyName());
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.GET_TOKEN, identifier);

        ReturnStatementNode returnStatement;

        if (accessorInfo.getIsStatic())
        {
            // Equivalent AS:
            //
            //  return ${bindableInfo.className}.${entry.qualifiedBackingPropertyName};
            MemberExpressionNode getterSelector =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, className, false);
            String qualifiedBackingPropertyName = accessorInfo.getQualifiedBackingPropertyName().intern();
            IdentifierNode identifer = 
                AbstractSyntaxTreeUtil.generateIdentifier(nodeFactory, qualifiedBackingPropertyName, false);
            GetExpressionNode getExpression = nodeFactory.getExpression(identifer);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(getterSelector, getExpression);
            ListNode returnList = nodeFactory.list(null, memberExpression);
            returnStatement = nodeFactory.returnStatement(returnList);
        }
        else
        {
            // Equivalent AS:
            //
            //  return this.${entry.qualifiedBackingPropertyName};
            ThisExpressionNode thisExpression = nodeFactory.thisExpression(0);
            String qualifiedBackingPropertyName = accessorInfo.getQualifiedBackingPropertyName().intern();
            IdentifierNode identifer =
                AbstractSyntaxTreeUtil.generateIdentifier(nodeFactory, qualifiedBackingPropertyName, false);
            GetExpressionNode getExpression = nodeFactory.getExpression(identifer);
            MemberExpressionNode memberExpression = nodeFactory.memberExpression(thisExpression, getExpression);
            ListNode returnList = nodeFactory.list(null, memberExpression);
            returnStatement = nodeFactory.returnStatement(returnList);
        }

        StatementListNode functionStatementList = nodeFactory.statementList(null, returnStatement);

        FunctionCommonNode functionCommon = nodeFactory.functionCommon(context, null, functionSignature,
                                                                       functionStatementList, position);
        functionCommon.setUserDefinedBody(true);

        return nodeFactory.functionDefinition(context, attributeList, functionName, functionCommon);
    }

    private FunctionDefinitionNode generateHasEventListenerFunctionDefinition(Context context)
    {
        // Equivalent AS:
        //
        //    public function hasEventListener(type:String):Boolean
        //    {
        //        return _bindingEventDispatcher.hasEventListener(type);
        //    }
        NodeFactory nodeFactory = context.getNodeFactory();

        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generatePublicAttribute(nodeFactory);

        IdentifierNode hasEventListenerIdentifier = nodeFactory.identifier(HAS_EVENT_LISTENER, false);
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.EMPTY_TOKEN, hasEventListenerIdentifier);

        ParameterNode typeParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, TYPE, STRING, false);
        ParameterListNode parameterList = nodeFactory.parameterList(null, typeParameter);
        MemberExpressionNode returnTypeMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, BOOLEAN, true);
        TypeExpressionNode returnType = nodeFactory.typeExpression(returnTypeMemberExpression, true, false, -1);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(parameterList, returnType);

        MemberExpressionNode _bindingEventDispatcherGetterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, _BINDING_EVENT_DISPATCHER, false);
        IdentifierNode identifier = nodeFactory.identifier(HAS_EVENT_LISTENER, false);
        MemberExpressionNode typeGetterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, TYPE, false);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, typeGetterSelector);
        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(identifier, argumentList);
        callExpression.setRValue(false);
        MemberExpressionNode memberExpression =
            nodeFactory.memberExpression(_bindingEventDispatcherGetterSelector, callExpression);
        ListNode returnList = nodeFactory.list(null, memberExpression);
        ReturnStatementNode returnStatement = nodeFactory.returnStatement(returnList);

        StatementListNode functionStatementList = nodeFactory.statementList(null, returnStatement);

        FunctionCommonNode functionCommon = nodeFactory.functionCommon(context, null, functionSignature,
                                                                       functionStatementList);
        functionCommon.setUserDefinedBody(true);

        return nodeFactory.functionDefinition(context, attributeList, functionName, functionCommon);
    }

    private ListNode generateOldValueStrictlyNotEqualsValueText(NodeFactory nodeFactory)
    {
        // Equivalent AS:
        //
        // if (oldValue !== value)
        MemberExpressionNode oldValueMemberExpression = 
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, OLD_VALUE, false);
        MemberExpressionNode valueMemberExpression = 
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, VALUE, false);
        BinaryExpressionNode binaryExpression = nodeFactory.binaryExpression(Tokens.STRICTNOTEQUALS_TOKEN,
                                                                             oldValueMemberExpression,
                                                                             valueMemberExpression);
        return nodeFactory.list(null, binaryExpression);
    }

    private VariableDefinitionNode generateOldValueVariable(NodeFactory nodeFactory,
                                                            String setterAccessPropertyName)
    {
        // Equivalent AS:
        //
        //   var oldValue:Object = this.$setterAccessPropertyName;
        ThisExpressionNode thisExpression = nodeFactory.thisExpression(0);
        IdentifierNode identifer =
            AbstractSyntaxTreeUtil.generateIdentifier(nodeFactory, setterAccessPropertyName, false);
        GetExpressionNode getExpression = nodeFactory.getExpression(identifer);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(thisExpression, getExpression);
        return AbstractSyntaxTreeUtil.generateVariable(nodeFactory, OLD_VALUE, OBJECT, false, memberExpression);
    }

    private FunctionDefinitionNode generateRemoveEventListenerFunctionDefinition(Context context)
    {
        // Equivalent AS:
        //
        //    public function removeEventListener(type:String,
        //                                        listener:Function,
        //                                        useCapture:Boolean = false):void
        //    {
        //        _bindingEventDispatcher.removeEventListener(type, listener, useCapture);
        //    }
        NodeFactory nodeFactory = context.getNodeFactory();

        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generatePublicAttribute(nodeFactory);

        IdentifierNode removeEventListenerIdentifier = nodeFactory.identifier(REMOVE_EVENT_LISTENER, false);
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.EMPTY_TOKEN, removeEventListenerIdentifier);

        ParameterNode typeParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, TYPE, STRING, false);
        ParameterListNode parameterList = nodeFactory.parameterList(null, typeParameter);
        ParameterNode listenerParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, LISTENER, FUNCTION, false);
        parameterList = nodeFactory.parameterList(parameterList, listenerParameter);
        LiteralBooleanNode literalBoolean = nodeFactory.literalBoolean(false);
        ParameterNode useCaptureParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, USE_CAPTURE, BOOLEAN,
                                                     false, literalBoolean);
        parameterList = nodeFactory.parameterList(parameterList, useCaptureParameter);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(parameterList, null);
        functionSignature.void_anno = true;

        MemberExpressionNode _bindingEventDispatcherGetterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, _BINDING_EVENT_DISPATCHER, false);
        IdentifierNode identifier = nodeFactory.identifier(REMOVE_EVENT_LISTENER, false);
        MemberExpressionNode typeGetterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, TYPE, false);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, typeGetterSelector);
        MemberExpressionNode listenerGetterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, LISTENER, false);
        argumentList = nodeFactory.argumentList(argumentList, listenerGetterSelector);
        MemberExpressionNode useCaptureGetterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, USE_CAPTURE, false);
        argumentList = nodeFactory.argumentList(argumentList, useCaptureGetterSelector);
        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(identifier, argumentList);
        callExpression.setRValue(false);
        MemberExpressionNode memberExpression =
            nodeFactory.memberExpression(_bindingEventDispatcherGetterSelector, callExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);

        StatementListNode functionStatementList = nodeFactory.statementList(null, expressionStatement);

        FunctionCommonNode functionCommon = nodeFactory.functionCommon(context, null, functionSignature,
                                                                       functionStatementList);
        functionCommon.setUserDefinedBody(true);

        return nodeFactory.functionDefinition(context, attributeList, functionName, functionCommon);
    }

    private FunctionDefinitionNode generateSetter(Context context, String className, AccessorInfo accessorInfo)
    {
        // Equivalent AS:
        //
        //   $entry.attributeString function set ${entry.propertyName}(value:${entry.typeName}):void
        NodeFactory nodeFactory = context.getNodeFactory();
        int position = -1;

        if (accessorInfo instanceof VariableInfo)
        {
            position = ((VariableInfo) accessorInfo).getPosition();
        }
        else if (accessorInfo instanceof GetterSetterInfo)
        {
            position = ((GetterSetterInfo) accessorInfo).getSetterPosition();
        }

        ParameterNode parameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, VALUE, accessorInfo.getTypeName(), true, position);
        ParameterListNode parameterList = nodeFactory.parameterList(null, parameter);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(parameterList, null);
        functionSignature.void_anno = true;
        AttributeListNode attributeList = generateAttributeList(nodeFactory, accessorInfo.getAttributeString());
        IdentifierNode propertyNameIdentifier = nodeFactory.identifier(accessorInfo.getPropertyName());
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.SET_TOKEN, propertyNameIdentifier);
        StatementListNode functionStatementList;
        String qualifiedBackingPropertyName = accessorInfo.getQualifiedBackingPropertyName().intern();
        String setterAccessPropertyName;

        if (accessorInfo.getIsFunction())
        {
            setterAccessPropertyName = accessorInfo.getQualifiedPropertyName().intern();
        }
        else
        {
            setterAccessPropertyName = qualifiedBackingPropertyName;
        }

        if (accessorInfo.getIsStatic())
        {
            VariableDefinitionNode variableDefinition =
                generateStaticOldValueVariable(nodeFactory, className, setterAccessPropertyName);
            functionStatementList = nodeFactory.statementList(null, variableDefinition);

            ListNode test = generateOldValueStrictlyNotEqualsValueText(nodeFactory);
            StatementListNode then =
                generateStaticSetterAssignment(nodeFactory, className, qualifiedBackingPropertyName);
            then = generateStaticDispatchEventCall(nodeFactory, then, className, accessorInfo.getQualifiedPropertyName());

            Node ifStatement = nodeFactory.ifStatement(test, then, null);
            functionStatementList = nodeFactory.statementList(functionStatementList, ifStatement);
        }
        else
        {
            VariableDefinitionNode variableDefinition = generateOldValueVariable(nodeFactory, setterAccessPropertyName);
            functionStatementList = nodeFactory.statementList(null, variableDefinition);

            ListNode test = generateOldValueStrictlyNotEqualsValueText(nodeFactory);
            StatementListNode then = generateSetterAssignment(nodeFactory, qualifiedBackingPropertyName);
            then = generateDispatchEventCall(nodeFactory, then, accessorInfo.getQualifiedPropertyName());

            Node ifStatement = nodeFactory.ifStatement(test, then, null);;
            functionStatementList = nodeFactory.statementList(functionStatementList, ifStatement);
        }

        FunctionCommonNode functionCommon = nodeFactory.functionCommon(context, null, functionSignature,
                                                                       functionStatementList);
        functionCommon.setUserDefinedBody(true);

        return nodeFactory.functionDefinition(context, attributeList, functionName, functionCommon);
    }

    private StatementListNode generateSetterAssignment(NodeFactory nodeFactory,
                                                       String qualifiedBackingPropertyName)
    {
        // Equivalent AS:
        //
        //   this.${entry.qualifiedBackingPropertyName} = value;
        ThisExpressionNode outerThisExpression = nodeFactory.thisExpression(0);
        IdentifierNode identifier =
            AbstractSyntaxTreeUtil.generateIdentifier(nodeFactory, qualifiedBackingPropertyName, false);
        MemberExpressionNode getterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, VALUE, false);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, getterSelector);
        SetExpressionNode setExpression = nodeFactory.setExpression(identifier, argumentList, false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(outerThisExpression, setExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement =
            nodeFactory.expressionStatement(list);
        return nodeFactory.statementList(null, expressionStatement);
    }

    private VariableDefinitionNode generateStaticBindingEventDispatcherVariable(NodeFactory nodeFactory)
    {
        // Equivalent AS:
        //
        //    private static var _staticBindingEventDispatcher:flash.events.EventDispatcher =
        //        new flash.events.EventDispatcher();
        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generatePrivateStaticAttribute(nodeFactory);
        IdentifierNode _staticBindingEventDispatcherIdentifier = nodeFactory.identifier(_STATIC_BINDING_EVENT_DISPATCHER, false);
        QualifiedIdentifierNode qualifiedIdentifier =
            AbstractSyntaxTreeUtil.generateQualifiedIdentifier(nodeFactory, FLASH_EVENTS,
                                                               EVENT_DISPATCHER_CLASS, false);
        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(qualifiedIdentifier, null);
        callExpression.is_new = true;
        callExpression.setRValue(false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(null, callExpression);
        return AbstractSyntaxTreeUtil.generateVariable(nodeFactory, attributeList,
                                                       _staticBindingEventDispatcherIdentifier,
                                                       FLASH_EVENTS, EVENT_DISPATCHER_CLASS,
                                                       false, memberExpression);

    }

    private StatementListNode generateStaticDispatchEventCall(NodeFactory nodeFactory, StatementListNode outerThen,
                                                              String className, String qualifiedPropertyName)
    {
        // Equivalent AS:
        //
        //   var eventDispatcher:IEventDispatcher = ${bindableInfo.className}.staticEventDispatcher;
        MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, className, false);
        IdentifierNode staticEventDispatcherIdentifier = nodeFactory.identifier(STATIC_EVENT_DISPATCHER, false);
        GetExpressionNode selector = nodeFactory.getExpression(staticEventDispatcherIdentifier);
        MemberExpressionNode rvalue = nodeFactory.memberExpression(base, selector);
        VariableDefinitionNode variableDefinition =
            AbstractSyntaxTreeUtil.generateVariable(nodeFactory, EVENT_DISPATCHER_VAR,
                                                    FLASH_EVENTS, I_EVENT_DISPATCHER,
                                                    false, rvalue);
        outerThen = nodeFactory.statementList(outerThen, variableDefinition);
        
        ListNode test = generateEventDispatcherNotNull(nodeFactory);

        // Equivalent AS:
        //
        //   eventDispatcher.dispatchEvent(mx.events.PropertyChangeEvent.createUpdateEvent(${bindableInfo.className}, "$entry.qualifiedPropertyName", oldValue, value));
        IdentifierNode dispatchEventIdentifier = nodeFactory.identifier(DISPATCH_EVENT, false);

        MemberExpressionNode propertyChangeEventMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, MX_EVENTS, PROPERTY_CHANGE_EVENT, false);;
        IdentifierNode createUpdateEventIdentifier = nodeFactory.identifier(CREATE_UPDATE_EVENT, false);
        MemberExpressionNode getterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, className, false);
        ArgumentListNode createUpdateEventArgumentList = nodeFactory.argumentList(null, getterSelector);

        LiteralStringNode literalString = nodeFactory.literalString(qualifiedPropertyName);
        createUpdateEventArgumentList = nodeFactory.argumentList(createUpdateEventArgumentList, literalString);

        MemberExpressionNode oldValueMemberExpression = 
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, OLD_VALUE, false);
        createUpdateEventArgumentList =
            nodeFactory.argumentList(createUpdateEventArgumentList, oldValueMemberExpression);

        MemberExpressionNode valueMemberExpression = 
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, VALUE, false);
        createUpdateEventArgumentList =
            nodeFactory.argumentList(createUpdateEventArgumentList, valueMemberExpression);

        CallExpressionNode createUpdateEventCallExpression = 
            (CallExpressionNode) nodeFactory.callExpression(createUpdateEventIdentifier, createUpdateEventArgumentList);
        createUpdateEventCallExpression.setRValue(false);
        MemberExpressionNode createUpdateEventMemberExpression =
            nodeFactory.memberExpression(propertyChangeEventMemberExpression, createUpdateEventCallExpression);
        ArgumentListNode dispatchEventArgumentList = 
            nodeFactory.argumentList(null, createUpdateEventMemberExpression);
        CallExpressionNode dispatchEventCallExpression =
            (CallExpressionNode) nodeFactory.callExpression(dispatchEventIdentifier, dispatchEventArgumentList);
        dispatchEventCallExpression.setRValue(false);
        MemberExpressionNode eventDispatcherMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, EVENT_DISPATCHER_VAR, false);
        MemberExpressionNode memberExpression =
            nodeFactory.memberExpression(eventDispatcherMemberExpression, dispatchEventCallExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement =
            nodeFactory.expressionStatement(list);
        StatementListNode then = nodeFactory.statementList(null, expressionStatement);

        Node ifStatement = nodeFactory.ifStatement(test, then, null);
        return nodeFactory.statementList(outerThen, ifStatement);
    }

    private FunctionDefinitionNode generateStaticEventDispatcherGetter(Context context)
    {
        // Equivalent AS:
        //
        //    public static function get staticEventDispatcher():IEventDispatcher
        //    {
        //        return _staticBindingEventDispatcher;
        //    }
        NodeFactory nodeFactory = context.getNodeFactory();
        MemberExpressionNode returnTypeMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, I_EVENT_DISPATCHER, true);
        TypeExpressionNode returnType = nodeFactory.typeExpression(returnTypeMemberExpression, true, false, -1);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(null, returnType);
        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generatePublicStaticAttribute(nodeFactory);
        IdentifierNode staticEventDispatcherIdentifier = nodeFactory.identifier(STATIC_EVENT_DISPATCHER, false);
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.GET_TOKEN, staticEventDispatcherIdentifier);
        MemberExpressionNode memberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, _STATIC_BINDING_EVENT_DISPATCHER, false); 
        ListNode returnList = nodeFactory.list(null, memberExpression);
        ReturnStatementNode returnStatement = nodeFactory.returnStatement(returnList);
        StatementListNode functionStatementList = nodeFactory.statementList(null, returnStatement);
        FunctionCommonNode functionCommon = nodeFactory.functionCommon(context, null, functionSignature,
                                                                       functionStatementList);
        functionCommon.setUserDefinedBody(true);
        return nodeFactory.functionDefinition(context, attributeList, functionName, functionCommon);
    }

    private VariableDefinitionNode generateStaticOldValueVariable(NodeFactory nodeFactory,
                                                                  String className,
                                                                  String qualifiedBackingPropertyName)
    {
        // Equivalent AS:
        //
        //   var oldValue:Object = ${bindableInfo.className}.$setterAccessPropertyName;
        MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, className, false);
        IdentifierNode identifer = nodeFactory.identifier(qualifiedBackingPropertyName, false);
        GetExpressionNode getExpression = nodeFactory.getExpression(identifer);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, getExpression);
        return AbstractSyntaxTreeUtil.generateVariable(nodeFactory, OLD_VALUE, OBJECT, false, memberExpression);
    }

    private StatementListNode generateStaticSetterAssignment(NodeFactory nodeFactory, String className,
                                                             String qualifiedBackingPropertyName)
    {
        // Equivalent AS:
        //
        //   ${bindableInfo.className}.${entry.qualifiedBackingPropertyName} = value;
        MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, className, false);        
        IdentifierNode identifier =
            AbstractSyntaxTreeUtil.generateIdentifier(nodeFactory, qualifiedBackingPropertyName, false);
        MemberExpressionNode getterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, VALUE, false);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, getterSelector);
        SetExpressionNode setExpression = nodeFactory.setExpression(identifier, argumentList, false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, setExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement =
            nodeFactory.expressionStatement(list);
        return nodeFactory.statementList(null, expressionStatement);
    }

    private FunctionDefinitionNode generateWillTriggerFunctionDefinition(Context context)
    {
        // Equivalent AS:
        //
        //    public function willTrigger(type:String):Boolean
        //    {
        //        return _bindingEventDispatcher.willTrigger(type);
        //    }
        NodeFactory nodeFactory = context.getNodeFactory();
        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generatePublicAttribute(nodeFactory);

        IdentifierNode willTriggerIdentifier = nodeFactory.identifier(WILL_TRIGGER, false);
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.EMPTY_TOKEN, willTriggerIdentifier);

        ParameterNode typeParameter =
            AbstractSyntaxTreeUtil.generateParameter(nodeFactory, TYPE, STRING, false);
        ParameterListNode parameterList = nodeFactory.parameterList(null, typeParameter);
        MemberExpressionNode returnTypeMemberExpression =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, BOOLEAN, true);
        TypeExpressionNode returnType = nodeFactory.typeExpression(returnTypeMemberExpression, true, false, -1);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(parameterList, returnType);

        MemberExpressionNode _bindingEventDispatcherGetterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, _BINDING_EVENT_DISPATCHER, false);
        IdentifierNode identifier = nodeFactory.identifier(WILL_TRIGGER, false);
        MemberExpressionNode typeGetterSelector =
            AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, TYPE, false);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, typeGetterSelector);
        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(identifier, argumentList);
        callExpression.setRValue(false);

        MemberExpressionNode memberExpression =
            nodeFactory.memberExpression(_bindingEventDispatcherGetterSelector, callExpression);
        ListNode returnList = nodeFactory.list(null, memberExpression);
        ReturnStatementNode returnStatement = nodeFactory.returnStatement(returnList);

        StatementListNode functionStatementList = nodeFactory.statementList(null, returnStatement);

        FunctionCommonNode functionCommon = nodeFactory.functionCommon(context, null, functionSignature,
                                                                       functionStatementList);
        functionCommon.setUserDefinedBody(true);

        return nodeFactory.functionDefinition(context, attributeList, functionName, functionCommon);
    }

	protected void modifySyntaxTree(Context context, ClassDefinitionNode classDefinition,
                                    BindableInfo bindableInfo)
	{
        if (generateAbstractSyntaxTree)
        {
            Map<QName, AccessorInfo> accessors = bindableInfo.getAccessors();

            if (accessors != null)
            {
                for (AccessorInfo accessorInfo : accessors.values())
                {
                    NodeFactory nodeFactory = context.getNodeFactory();
                    String className = bindableInfo.getClassName().intern();
                    StatementListNode statementList = classDefinition.statements;

                    if (!accessorInfo.getIsFunction())
                    {
                        FunctionDefinitionNode getter = generateGetter(context, className, accessorInfo);

                        moveMetaDataToNewDefinition(nodeFactory, accessorInfo.getDefinitionNode(),
                                                    getter, statementList, true);

                        nodeFactory.statementList(statementList, getter);
                    }

                    FunctionDefinitionNode setter = generateSetter(context, className, accessorInfo);

                    if (accessorInfo.getIsFunction())
                    {
                        GetterSetterInfo getterSetterInfo = (GetterSetterInfo) accessorInfo;
                        boolean processedBindable =
                            processGetterMetaData(nodeFactory,
                                                  getterSetterInfo.getGetterFunctionDefinition());
                        moveMetaDataToNewDefinition(nodeFactory,
                                                    getterSetterInfo.getSetterFunctionDefinition(),
                                                    setter, statementList, !processedBindable);
                    }

                    nodeFactory.statementList(statementList, setter);
                }
            }

            if (bindableInfo.getNeedsToImplementIEventDispatcher())
            {
                addIEventDispatcherImplementation(context, classDefinition);
            }

            if (bindableInfo.getNeedsStaticEventDispatcher())
            {
                addStaticEventDispatcherImplementation(context, classDefinition);
            }
        }
        else
        {
            super.modifySyntaxTree(context, classDefinition, bindableInfo);
        }
	}

    /**
     * Moves metadata from the initial definition to the new
     * definition.  If emtpy Bindable metadata is found, an event
     * attribute is added to it.
     */
    private void moveMetaDataToNewDefinition(NodeFactory nodeFactory,
                                             DefinitionNode fromDefinition,
                                             DefinitionNode toDefinition,
                                             StatementListNode classDefinitionStatementList,
                                             boolean addBindableMetaData)
    {
        boolean processedBindableMetaData = false;

        if ((fromDefinition != null) && (fromDefinition.metaData != null))
        {
            for (Node node : fromDefinition.metaData.items)
            {
                MetaDataNode metaData = (MetaDataNode) node;

                if ((metaData.getId() != null) &&
                    metaData.getId().equals(StandardDefs.MD_BINDABLE) &&
                    metaData.count() == 0)
                {
                    processBindableMetaData(nodeFactory, metaData);
                    processedBindableMetaData = true;
                }

                metaData.def = toDefinition;
                classDefinitionStatementList.items.remove(metaData);
                nodeFactory.statementList(classDefinitionStatementList, metaData);
                toDefinition.metaData = nodeFactory.statementList(toDefinition.metaData, metaData);
            }

            fromDefinition.metaData = null;
        }

        if (addBindableMetaData && !processedBindableMetaData)
        {
            MetaDataNode bindableMetaData =
                AbstractSyntaxTreeUtil.generateMetaData(nodeFactory, BINDABLE,
                                                        EVENT_VAR, PROPERTY_CHANGE);
            nodeFactory.statementList(classDefinitionStatementList, bindableMetaData);            
            prepMetaDataNode(nodeFactory.getContext(), bindableMetaData);
        }
    }

    /**
     * Added an event attribute to Bindable metadata.
     */
    private void processBindableMetaData(NodeFactory nodeFactory, MetaDataNode metaData)
    {
        assert metaData.count() == 0;

        Value[] vals =  new Value[1];
        vals[0] = new macromedia.asc.parser.MetaDataEvaluator.KeyValuePair(EVENT_VAR, PROPERTY_CHANGE);
        metaData.setValues(vals);
        prepMetaDataNode(nodeFactory.getContext(), metaData);
    }

    /**
     * Looks for empty Bindable metadata and if found, adds an event attribute to it.
     */
    private boolean processGetterMetaData(NodeFactory nodeFactory, FunctionDefinitionNode getter)
    {
        boolean processedBindableMetaData = false;        

        if ((getter != null) && (getter.metaData != null))
        {
            for (Node node : getter.metaData.items)
            {
                MetaDataNode metaData = (MetaDataNode) node;

                if ((metaData.getId() != null) &&
                    metaData.getId().equals(StandardDefs.MD_BINDABLE) &&
                    metaData.count() == 0)
                {
                    processBindableMetaData(nodeFactory, metaData);
                    processedBindableMetaData = true;
                }
            }
        }

        return processedBindableMetaData;
    }

	/**
	 * prepare class def node for augmentation. Currently, all we need to do is strip class-level [Bindable] md.
	 */
	private void prepClassDef(ClassDefinitionNode node)
	{
		if (node.metaData != null && node.metaData.items != null)
		{
			for (Iterator iter = node.metaData.items.iterator(); iter.hasNext(); )
			{
				MetaDataNode md = (MetaDataNode)iter.next();
				if (StandardDefs.MD_BINDABLE.equals(md.getId()) && md.count() == 0)
				{
					iter.remove();
				}
			}
		}
	}

	/**
	 * Hide *setters* which have had bindable versions generated. Getters are not wrapped.
	 *
	 * In BindableFirstPassEvaluator we visited the interior of a function definition, in order to generate errors on
	 * [Bindable] metadata we found there. Here we avoid FunctionDefinitionNodes because the VariableDefinitionNodes
	 * within them might otherwise be spuriously renamed.
	 */
	public Value evaluate(Context context, FunctionDefinitionNode node)
	{
		if (inClass)
		{
			QName qname = new QName(NodeMagic.getUserNamespace(node), NodeMagic.getFunctionName(node));
			GenerativeClassInfo.AccessorInfo accessorInfo = bindableInfo.getAccessor(qname);

			if (accessorInfo instanceof GetterSetterInfo)
			{
				if (NodeMagic.functionIsSetter(node))
				{
					hideFunction(node, accessorInfo);
					registerRenamedAccessor(accessorInfo);
                    ((GetterSetterInfo) accessorInfo).setSetterInfo(node);
				}
                else
                {
                    ((GetterSetterInfo) accessorInfo).setGetterInfo(node);

                    if (!bindableInfo.getClassInfo().definesSetter(qname.getLocalPart(), false))
                    {
                        context.localizedError2(node.pos(), new MissingNonInheritedSetter(qname.getLocalPart()));
                    }
                }
			}
		}

		return null;
	}

	/**
	 * visits all variable definitions that occur inside class definitions, outside function definitions, and mangles
	 * their names if they've been marked for [Bindable] codegen.
	 */
	public Value evaluate(Context context, VariableDefinitionNode node)
	{
		if (inClass)
		{
			QName qname = new QName(NodeMagic.getUserNamespace(node), NodeMagic.getVariableName(node));
			GenerativeClassInfo.AccessorInfo accessorInfo = bindableInfo.getAccessor(qname);
			if (accessorInfo != null)
			{
				hideVariable(node, accessorInfo);
				registerRenamedAccessor(accessorInfo);
			}
		}

		return null;
	}

	/**
	 *
	 */
	protected String getTemplateName()
	{
		return standardDefs.getBindablePropertyTemplate();
	}

	protected String getTemplatePath()
	{
		return CODEGEN_TEMPLATE_PATH;
	}

	/**
	 *
	 */
	protected Map<String, BindableInfo> getTemplateVars()
	{
		Map<String, BindableInfo> vars = new HashMap<String, BindableInfo>();
		vars.put("bindableInfo", bindableInfo);

		return vars;
	}

	/**
	 *
	 */
	protected String getGeneratedSuffix()
	{
		return "-binding-generated.as";
	}

	public static class MissingNonInheritedSetter extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -1787062656834309810L;
        public String getter;

		public MissingNonInheritedSetter(String getter)
		{
			this.getter = getter;
		}
	}
}
