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

import macromedia.asc.semantics.*;
import macromedia.asc.util.*;

import static macromedia.asc.parser.Tokens.*;

/**
 * Node
 */
public class BinaryExpressionNode extends Node
{
	public Node lhs;
	public Node rhs;
	public int op;
	public Slot slot;
    public TypeInfo lhstype;
    public TypeInfo rhstype;
    public NumberUsage numberUsage;

	public BinaryExpressionNode(int op, Node lhs, Node rhs)
	{
		this.op = op;
		slot = null;
		this.lhs = lhs;
		this.rhs = rhs;
		lhstype = null;
        rhstype = null;
		void_result = false;
		numberUsage = null;
	}

	public Value evaluate(Context cx, Evaluator evaluator)
	{
		return evaluator.checkFeature(cx, this) ? evaluator.evaluate(cx, this) : null;
	}

	public boolean isBooleanExpression()
	{
		return op == NOTEQUALS_TOKEN
			|| op == STRICTNOTEQUALS_TOKEN
			|| op == LOGICALAND_TOKEN
			|| op == LOGICALXOR_TOKEN
			|| op == LOGICALXORASSIGN_TOKEN
			|| op == LOGICALOR_TOKEN
			|| op == LESSTHAN_TOKEN
			|| op == LESSTHANOREQUALS_TOKEN
			|| op == EQUALS_TOKEN
			|| op == STRICTEQUALS_TOKEN
			|| op == GREATERTHAN_TOKEN
			|| op == GREATERTHANOREQUALS_TOKEN;
	}

	public String toString()
	{
		return "BinaryExpression";
	}

	public boolean void_result;

	public void voidResult()
	{
		void_result = true;
	}
}