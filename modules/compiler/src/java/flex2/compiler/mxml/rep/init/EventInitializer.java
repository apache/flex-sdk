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
import flex2.compiler.as3.CodeFragmentsInputBuffer;
import flex2.compiler.mxml.gen.CodeFragmentList;
import flex2.compiler.mxml.gen.TextGen;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.rep.EventHandler;
import flex2.compiler.util.NameFormatter;
import macromedia.asc.parser.*;
import macromedia.asc.util.Context;
import org.apache.commons.collections.iterators.SingletonIterator;

import java.util.HashSet;
import java.util.Iterator;
import java.util.List;

/**
 * This class represents an initializer for an event.
 */
public class EventInitializer implements Initializer
{
    private static final String EVENT = "event".intern();

	private final EventHandler handler;

	public EventInitializer(EventHandler handler)
	{
		this.handler = handler;
	}

	public String getName()
	{
		return handler.getName();
	}

	public Type getLValueType()
	{
		return handler.getType();
	}

	public int getLineRef()
	{
		return handler.getXmlLineNumber();
	}
	
	public String getHandlerText()
	{
		return handler.getEventHandlerText();
	}

	public boolean isBinding()
	{
		return false;
	}
	
	public boolean isStateSpecific()
	{
		return false;
	}

	public String getValueExpr()
	{
		return handler.getDocumentFunctionName();
	}

	/**
	 *
	 */
	public Node generateValueExpr(NodeFactory nodeFactory, HashSet<String> configNamespaces, boolean generateDocComments)
    {
        return AbstractSyntaxTreeUtil.generateGetterSelector(nodeFactory,
                                                             handler.getDocumentFunctionName(),
                                                             true);
    }

	public String getAssignExpr(String lvalueBase)
	{
		return lvalueBase + ".addEventListener(" + TextGen.quoteWord(getName()) + ", " + getValueExpr() + ")";
	}

    // intern all identifier constants
    private static final String ADD_EVENT_LISTENER = "addEventListener".intern();

	public StatementListNode generateAssignExpr(NodeFactory nodeFactory, HashSet<String> configNamespaces,
                                                boolean generateDocComments, StatementListNode statementList,
                                                Node lvalueBase)
    {
        IdentifierNode identifier = nodeFactory.identifier(ADD_EVENT_LISTENER, false);
        LiteralStringNode literalString = nodeFactory.literalString(getName());
        ArgumentListNode argumentList = nodeFactory.argumentList(null, literalString);
        argumentList = nodeFactory.argumentList(argumentList, generateValueExpr(nodeFactory, configNamespaces,
                                                                                generateDocComments));
        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(identifier, argumentList);
        callExpression.setRValue(false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(lvalueBase, callExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        return nodeFactory.statementList(statementList, expressionStatement);
    }

	public boolean hasDefinition()
	{
		return true;
	}

	public Iterator getDefinitionsIterator()
	{
		return new SingletonIterator(getDefinitionBody());
	}

	private CodeFragmentList getDefinitionBody()
	{
		int line = getLineRef();
		CodeFragmentList list = new CodeFragmentList();

		//	TODO public only for UIObjectDescriptor, which takes names rather than function refs
		list.add("/**", line);
		list.add(" * @private", line);
		list.add(" **/", line);
		list.add("public function ", handler.getDocumentFunctionName(), "(event:", NameFormatter.toDot(handler.getType().getName()), "):void", line);
		list.add("{", line);
		list.add("\t", handler.getEventHandlerText(), line);
		list.add("}", line);

		return list;
	}

	/**
	 *
	 */
    public StatementListNode generateDefinitions(Context context, HashSet<String> configNamespaces,
                                                 boolean generateDocComments, StatementListNode statementList)
    {
        StatementListNode result = statementList;
        NodeFactory nodeFactory = context.getNodeFactory();

        if (generateDocComments)
        {
            DocCommentNode docComment = AbstractSyntaxTreeUtil.generatePrivateDocComment(nodeFactory);
            result = nodeFactory.statementList(result, docComment);
        }

        String type = NameFormatter.toDot(handler.getType().getName());
        ParameterNode parameter = AbstractSyntaxTreeUtil.generateParameter(nodeFactory, EVENT, type, true);
        ParameterListNode parameterList = nodeFactory.parameterList(null, parameter);
        FunctionSignatureNode functionSignature = nodeFactory.functionSignature(parameterList, null);
        functionSignature.void_anno = true;

        AttributeListNode attributeList = AbstractSyntaxTreeUtil.generatePublicAttribute(nodeFactory);
        IdentifierNode stylesInitIdentifier = nodeFactory.identifier(handler.getDocumentFunctionName());
        FunctionNameNode functionName = nodeFactory.functionName(Tokens.EMPTY_TOKEN, stylesInitIdentifier);

        StatementListNode functionStatementList = null;

        String text = handler.getEventHandlerText();
        int xmlLineNumber = handler.getXmlLineNumber();
        List<Node> list =
            AbstractSyntaxTreeUtil.parseExpression(context, configNamespaces, text,
                                                   xmlLineNumber, generateDocComments);
        Iterator<Node> nodeIterator = list.iterator();

        while (nodeIterator.hasNext())
        {
            Node node = nodeIterator.next();
            functionStatementList = nodeFactory.statementList(functionStatementList, node);
        }

        int position = AbstractSyntaxTreeUtil.lineNumberToPosition(nodeFactory, getLineRef());
        
        FunctionCommonNode functionCommon = nodeFactory.functionCommon(context, null, functionSignature,
                                                                       functionStatementList, position);
        functionCommon.setUserDefinedBody(true);

        if (functionStatementList != null)
        {
            ReturnStatementNode returnStatement = (ReturnStatementNode) functionStatementList.items.last();
            returnStatement.setPositionTerminal(position);
        }

        FunctionDefinitionNode functionDefinition =
            nodeFactory.functionDefinition(context, attributeList, functionName, functionCommon);
        result = nodeFactory.statementList(result, functionDefinition);

        return result;
    }
}
