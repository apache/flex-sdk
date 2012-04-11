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

import flex2.compiler.mxml.gen.TextGen;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.reflect.Style;
import flex2.compiler.mxml.reflect.Type;
import java.util.HashSet;
import macromedia.asc.parser.ArgumentListNode;
import macromedia.asc.parser.CallExpressionNode;
import macromedia.asc.parser.ExpressionStatementNode;
import macromedia.asc.parser.IdentifierNode;
import macromedia.asc.parser.ListNode;
import macromedia.asc.parser.LiteralStringNode;
import macromedia.asc.parser.MemberExpressionNode;
import macromedia.asc.parser.Node;
import macromedia.asc.parser.NodeFactory;
import macromedia.asc.parser.StatementListNode;

/**
 * This class represents an initializer for a style.
 */
public class StyleInitializer extends NamedInitializer
{
	protected final Style style;

	public StyleInitializer(Style style, Object value, int line, StandardDefs standardDefs)
	{
		super(value, line, standardDefs);
		this.style = style;
	}

	public Style getStyle()
	{
		return style;
	}

	public Type getLValueType()
	{
		return style.getType();
	}

	public String getName()
	{
		return style.getName();
	}

	public String getAssignExpr(String lvalueBase)
	{
		return lvalueBase + ".setStyle(" + TextGen.quoteWord(getName()) + ", " + getValueExpr() + ")";
	}

    // intern all identifier constants
    private static final String SET_STYLE = "setStyle".intern();

	public StatementListNode generateAssignExpr(NodeFactory nodeFactory,
                                                HashSet<String> configNamespaces,
                                                boolean generateDocComments, 
                                                StatementListNode statementList,
                                                Node lvalueBase)
    {
        IdentifierNode identifier = nodeFactory.identifier(SET_STYLE, false);
        LiteralStringNode literalString = nodeFactory.literalString(getName());
        ArgumentListNode argumentList = nodeFactory.argumentList(null, literalString);
        Node valueExpr = generateValueExpr(nodeFactory, configNamespaces, generateDocComments);
        argumentList = nodeFactory.argumentList(argumentList, valueExpr);
        CallExpressionNode callExpression =
            (CallExpressionNode) nodeFactory.callExpression(identifier, argumentList);
        callExpression.setRValue(false);
        MemberExpressionNode memberExpression = nodeFactory.memberExpression(lvalueBase, callExpression);
        ListNode list = nodeFactory.list(null, memberExpression);
        ExpressionStatementNode expressionStatement = nodeFactory.expressionStatement(list);
        return nodeFactory.statementList(statementList, expressionStatement);
    }
}
