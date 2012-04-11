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

import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.reflect.Type;
import java.util.HashSet;
import macromedia.asc.parser.ArgumentListNode;
import macromedia.asc.parser.ExpressionStatementNode;
import macromedia.asc.parser.ListNode;
import macromedia.asc.parser.LiteralNumberNode;
import macromedia.asc.parser.MemberExpressionNode;
import macromedia.asc.parser.Node;
import macromedia.asc.parser.NodeFactory;
import macromedia.asc.parser.SetExpressionNode;
import macromedia.asc.parser.StatementListNode;
import macromedia.asc.parser.Tokens;

/**
 * This class represents an Array element initializer.
 */
public class ArrayElementInitializer extends ValueInitializer
{
	final Type type;
	final int index;

	public ArrayElementInitializer(Type type, int index, Object value, int line, StandardDefs defs)
	{
		super(value, line, defs);
		this.type = type;
		this.index = index;
	}

	public Type getLValueType()
	{
		return type;
	}

	public String getAssignExpr(String lvalueBase)
	{
		return lvalueBase + "[" + index + "] = " + getValueExpr();
	}

	public StatementListNode generateAssignExpr(NodeFactory nodeFactory,
                                                HashSet<String> configNamespaces,
                                                boolean generateDocComments, 
                                                StatementListNode statementList,
                                                Node lvalueBase)
    {
        LiteralNumberNode literalNumber = nodeFactory.literalNumber(index);
        ArgumentListNode expr = nodeFactory.argumentList(null, literalNumber);
        Node value = generateValueExpr(nodeFactory, configNamespaces, generateDocComments);
        ArgumentListNode argumentList = nodeFactory.argumentList(null, value);
        SetExpressionNode setExpression = nodeFactory.setExpression(expr, argumentList, false);
		setExpression.setMode(Tokens.LEFTBRACKET_TOKEN);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(lvalueBase, setExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        return nodeFactory.statementList(statementList, expressionStatement);
    }
}
