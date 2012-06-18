/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package macromedia.asc.parser;

import macromedia.asc.util.*;
import macromedia.asc.semantics.*;

/**
 * Node
 *
 * @author Jeff Dyer
 */
public class CatchClauseNode extends Node
{
	public Node parameter;
	public StatementListNode statements;
	public ReferenceValue typeref;
	public boolean finallyInserted;
    public ObjectValue default_namespace;
    public ObjectValue activation;
    
	public CatchClauseNode(Node parameter, StatementListNode statements)
	{
		this.parameter = parameter;
		this.statements = statements;
		this.typeref = null;
		this.finallyInserted = false;
	}

	public Value evaluate(Context cx, Evaluator evaluator)
	{
		if (evaluator.checkFeature(cx, this))
		{
			return evaluator.evaluate(cx, this);
		}
		else
		{
			return null;
		}
	}

	public int countVars()
	{
		// Add 1 for the catch variable
		return 1 + (statements != null ? statements.countVars() : 0);
	}
	
	public String toString()
	{
		return "CatchClause";
	}
}
