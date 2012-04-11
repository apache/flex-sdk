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

import flex2.compiler.as3.AbstractSyntaxTreeUtil;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.rep.Model;
import flex2.compiler.mxml.rep.MovieClip;
import java.util.HashSet;
import macromedia.asc.parser.ArgumentListNode;
import macromedia.asc.parser.CallExpressionNode;
import macromedia.asc.parser.ConditionalExpressionNode;
import macromedia.asc.parser.ExpressionStatementNode;
import macromedia.asc.parser.GetExpressionNode;
import macromedia.asc.parser.IdentifierNode;
import macromedia.asc.parser.ListNode;
import macromedia.asc.parser.LiteralArrayNode;
import macromedia.asc.parser.LiteralBooleanNode;
import macromedia.asc.parser.MemberExpressionNode;
import macromedia.asc.parser.Node;
import macromedia.asc.parser.NodeFactory;
import macromedia.asc.parser.QualifiedIdentifierNode;
import macromedia.asc.parser.SetExpressionNode;
import macromedia.asc.parser.StatementListNode;
import macromedia.asc.parser.VariableDefinitionNode;

/*
 * TODO remove when you-know-what finally happens
 */
/**
 * This class represents a legacy Halo visual child initializer.
 */
public class VisualChildInitializer extends ValueInitializer
{
	public VisualChildInitializer(MovieClip movieClip)
	{
		super(movieClip, movieClip.getXmlLineNumber(), movieClip.getStandardDefs());
	}

	private String extractName(Node lvalueBase)
	{
		MemberExpressionNode memberExpression = (MemberExpressionNode) lvalueBase;
		GetExpressionNode getExpression = (GetExpressionNode) memberExpression.selector;
		IdentifierNode identifier = (IdentifierNode) getExpression.expr;
		return identifier.name;
	}

	public Type getLValueType()
	{
		return ((Model)value).getType();
	}

	public String getAssignExpr(String lvalueBase)
	{
		if (standardDefs.isRepeater(getLValueType()))
		{
			//	parent must have property mx_internal::childRepeaters.
			/**
			 * TODO: uncomment mx_internal namespace argument, once bug ??????
			 * (user namespaces not showing up in SymbolTable property info) is fixed
			 */
			assert ((Model)value).getParent().getType().getProperty(/* StandardDefs.NAMESPACE_MX_INTERNAL_URI, */
																	StandardDefs.PROP_CONTAINER_CHILDREPEATERS) != null :
				"Repeater parent lacks childRepeaters[] property";
			String cr = lvalueBase + "." + StandardDefs.NAMESPACE_MX_INTERNAL_LOCALNAME + "::" + StandardDefs.PROP_CONTAINER_CHILDREPEATERS;
            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.append("var repeater:" + standardDefs.CLASS_REPEATER_DOT + " = " + getValueExpr() + ";\n");
            stringBuilder.append("\trepeater.initializeRepeater(" + lvalueBase + ", true);\n");
            stringBuilder.append("\t(" + cr + " ? " + cr + " : (" + cr + "=[])).push(repeater)");
            return stringBuilder.toString();
        }
		else
		{
			return lvalueBase + ".addChild(" + getValueExpr() + ")";
		}
	}

    // intern all identifier constants
    private static final String PUSH = "push".intern();
    private static final String ADD_CHILD = "addChild".intern();
    private static final String INITIALIZE_REPEATER = "initializeRepeater".intern();
    private static final String REPEATER = "repeater".intern();

	public StatementListNode generateAssignExpr(NodeFactory nodeFactory,
                                                HashSet<String> configNamespaces,
                                                boolean generateDocComments, 
                                                StatementListNode statementList,
                                                Node lvalueBase)
	{
		if (standardDefs.isRepeater(getLValueType()))
		{
			assert lvalueBase instanceof MemberExpressionNode : lvalueBase.getClass().getName();
			String name = extractName(lvalueBase);

            Node value = generateValueExpr(nodeFactory, configNamespaces, generateDocComments);
            VariableDefinitionNode variableDefinition =
                AbstractSyntaxTreeUtil.generateVariable(nodeFactory, REPEATER,
                                                        standardDefs.CLASS_REPEATER_DOT, true,
                                                        value);
            nodeFactory.statementList(statementList, variableDefinition);

            MemberExpressionNode repeaterBase =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, REPEATER, false);

            IdentifierNode initializeRepeaterIdentifier = nodeFactory.identifier(INITIALIZE_REPEATER, false);
            MemberExpressionNode lvalueBaseMemberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, name, true);
			ArgumentListNode initializeRepeaterArgumentList =
                nodeFactory.argumentList(null, lvalueBaseMemberExpression);
            LiteralBooleanNode literalBoolean = nodeFactory.literalBoolean(true);
            initializeRepeaterArgumentList = nodeFactory.argumentList(initializeRepeaterArgumentList,
                                                                      literalBoolean);
			CallExpressionNode initializeRepeaterCallExpression =
				(CallExpressionNode) nodeFactory.callExpression(initializeRepeaterIdentifier,
                                                                initializeRepeaterArgumentList);
			initializeRepeaterCallExpression.setRValue(false);
            MemberExpressionNode initializeRepeaterMemberExpression =
                nodeFactory.memberExpression(repeaterBase, initializeRepeaterCallExpression);
            ListNode initializeRepeaterList = nodeFactory.list(null, initializeRepeaterMemberExpression);
            ExpressionStatementNode initializeRepeaterExpressionStatement =
                nodeFactory.expressionStatement(initializeRepeaterList);
            nodeFactory.statementList(statementList, initializeRepeaterExpressionStatement);            

			MemberExpressionNode condition = generateChildRepeaters(nodeFactory, lvalueBase);
			MemberExpressionNode thenExpr = generateThen(nodeFactory, name);
			ListNode elseExpr = generateElse(nodeFactory, name);
			ConditionalExpressionNode conditionalExpression =
                nodeFactory.conditionalExpression(condition, thenExpr, elseExpr);
			ListNode base = nodeFactory.list(null, conditionalExpression);

			IdentifierNode pushIdentifier = nodeFactory.identifier(PUSH, false);
            MemberExpressionNode repeaterMemberExpression =
                AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, REPEATER, false);
			ArgumentListNode pushArgumentList = nodeFactory.argumentList(null, repeaterMemberExpression);
			CallExpressionNode pushCallExpression =
				(CallExpressionNode) nodeFactory.callExpression(pushIdentifier, pushArgumentList);
			pushCallExpression.setRValue(false);

			MemberExpressionNode pushMemberExpression = nodeFactory.memberExpression(base, pushCallExpression);
			ListNode pushList = nodeFactory.list(null, pushMemberExpression);
            ExpressionStatementNode pushExpressionStatement = nodeFactory.expressionStatement(pushList);
            return nodeFactory.statementList(statementList, pushExpressionStatement);
		}
		else
		{
			IdentifierNode identifier = nodeFactory.identifier(ADD_CHILD, false);
			Node valueExpr = generateValueExpr(nodeFactory, configNamespaces, generateDocComments);
			ArgumentListNode argumentList = nodeFactory.argumentList(null, valueExpr);
			CallExpressionNode callExpression =
				(CallExpressionNode) nodeFactory.callExpression(identifier, argumentList);
			callExpression.setRValue(false);
			MemberExpressionNode memberExpression = nodeFactory.memberExpression(lvalueBase, callExpression);
			ListNode list = nodeFactory.list(null, memberExpression);
			ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
            return nodeFactory.statementList(statementList, expressionStatement);
		}
	}

	private MemberExpressionNode generateChildRepeaters(NodeFactory nodeFactory, Node lvalueBase)
	{
		QualifiedIdentifierNode qualifiedIdentifier =
			AbstractSyntaxTreeUtil.generateMxInternalQualifiedIdentifier(nodeFactory,
                                                                         StandardDefs.PROP_CONTAINER_CHILDREPEATERS,
                                                                         false);
		GetExpressionNode getExpression = nodeFactory.getExpression(qualifiedIdentifier);
		return nodeFactory.memberExpression(lvalueBase, getExpression);
	}

	private ListNode generateElse(NodeFactory nodeFactory, String name)
	{
		MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, name, true);
		QualifiedIdentifierNode qualifiedIdentifier =
			AbstractSyntaxTreeUtil.generateMxInternalQualifiedIdentifier(nodeFactory,
																		 StandardDefs.PROP_CONTAINER_CHILDREPEATERS,
                                                                         false);
		LiteralArrayNode literalArray = nodeFactory.literalArray(null);
		ArgumentListNode argumentList = nodeFactory.argumentList(null, literalArray);
		SetExpressionNode selector = nodeFactory.setExpression(qualifiedIdentifier, argumentList, false);
		selector.setRValue(false);
		MemberExpressionNode memberExpression = nodeFactory.memberExpression(base, selector);
		return nodeFactory.list(null, memberExpression);
	}

    private MemberExpressionNode generateThen(NodeFactory nodeFactory, String name)
    {
        MemberExpressionNode base = AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory, name, true);
        QualifiedIdentifierNode qualifiedIdentifier =
            AbstractSyntaxTreeUtil.generateMxInternalQualifiedIdentifier(nodeFactory,
                                                                         StandardDefs.PROP_CONTAINER_CHILDREPEATERS,
                                                                         false);
        GetExpressionNode selector = nodeFactory.getExpression(qualifiedIdentifier);
        return nodeFactory.memberExpression(base, selector);
    }
}
