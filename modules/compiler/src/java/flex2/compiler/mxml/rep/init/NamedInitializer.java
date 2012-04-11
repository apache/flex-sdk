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

import macromedia.asc.parser.ExpressionStatementNode;
import macromedia.asc.parser.Node;
import macromedia.asc.parser.NodeFactory;
import macromedia.asc.parser.StatementListNode;
import java.util.HashSet;
import flex2.compiler.as3.AbstractSyntaxTreeUtil;
import flex2.compiler.mxml.gen.TextGen;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.lang.TextParser;

/**
 * This class represents an initializer for a named lvalue -
 * e.g. property or style, but not array element or visual child
 */
public abstract class NamedInitializer extends ValueInitializer
{
	NamedInitializer(Object value, int line, StandardDefs defs)
	{
		super(value, line, defs);
	}

	/**
	 *
	 */
	public abstract String getName();

	/**
	 *
	 */
	public String getAssignExpr(String lvalueBase)
	{
		String name = getName();
		
		String lvalue = TextParser.isValidIdentifier(name) ?
				lvalueBase + '.' + name :
				lvalueBase + "[" + TextGen.quoteWord(name) + "]";

		return lvalue + " = " + getValueExpr();
	}

	public StatementListNode generateAssignExpr(NodeFactory nodeFactory,
                                                HashSet<String> configNamespaces,
                                                boolean generateDocComments, 
                                                StatementListNode statementList,
                                                Node lvalueBase)
    {
		String name = getName();

		if (TextParser.isValidIdentifier(name))
        {
            Node valueExpr = generateValueExpr(nodeFactory, configNamespaces, generateDocComments);
            ExpressionStatementNode expressionStatement =
                AbstractSyntaxTreeUtil.generateAssignment(nodeFactory, lvalueBase, name, valueExpr);
            return nodeFactory.statementList(statementList, expressionStatement);
        }
        else
        {
            assert false;
            return null;
        }
    }
}
