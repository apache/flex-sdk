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
 */
public class IfStatementNode extends Node
{
	public Node condition;
	public Node thenactions;
	public Node elseactions;
	public boolean is_true;
	public boolean is_false;
	
	public IfStatementNode(Node condition, Node thenactions, Node elseactions)
	{
	    is_true = false;
	    is_false = false;
	    
		this.condition = condition;
		this.thenactions = thenactions;
		this.elseactions = elseactions;
	}

	public Value evaluate(Context cx, Evaluator evaluator)
	{
		return evaluator.checkFeature(cx, this) ? evaluator.evaluate(cx, this) : null;
	}

	public int countVars()
	{
		return (thenactions != null ? thenactions.countVars() : 0) + (elseactions != null ? elseactions.countVars() : 0);
	}

	public String toString()
	{
		return "IfStatement";
	}

	public boolean isBranch()
	{
		return true;
	}
}
