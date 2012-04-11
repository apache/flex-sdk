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

import flex2.compiler.mxml.reflect.Type;
import macromedia.asc.parser.ExpressionStatementNode;
import macromedia.asc.parser.Node;
import macromedia.asc.parser.NodeFactory;
import macromedia.asc.parser.StatementListNode;
import macromedia.asc.util.Context;

import java.util.HashSet;
import java.util.Iterator;

/**
 * This is the base interface for all initializers.
 */
public interface Initializer
{
	/**
	 *
	 */
	int getLineRef();

	/**
	 *
	 */
	boolean isBinding();

	/**
	 *
	 */
	Type getLValueType();

	/**
	 *
	 */
	String getValueExpr();

	/**
	 *
	 */
	Node generateValueExpr(NodeFactory nodeFactory, HashSet<String> configNamespaces, boolean generateDocComments);

	/**
	 *
	 */
	String getAssignExpr(String lvalueBase);

	/**
	 *
	 */
	StatementListNode generateAssignExpr(NodeFactory nodeFactory, HashSet<String> configNamespaces,
                                         boolean generateDocComments, StatementListNode statementList,
                                         Node lvalueBase);

	/**
	 *
	 */
	boolean hasDefinition();
	
	/**
	 *
	 */
	boolean isStateSpecific();

	/**
	 *
	 */
	Iterator getDefinitionsIterator();

	/**
	 *
	 */
    StatementListNode generateDefinitions(Context context, HashSet<String> configNamespaces,
                                          boolean generateDocComments, StatementListNode statementList);
}
