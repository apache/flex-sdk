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
import static macromedia.asc.util.BitSet.*;

/**
 * Node
 *
 * @author Jeff Dyer
 */
public class ExpressionStatementNode extends Node
{
	public Node expr;
	public BitSet gen_bits;
	public ReferenceValue ref;
	public TypeValue expected_type;
	public boolean is_var_stmt;

	public ExpressionStatementNode(Node expr)
	{
		this.expr = expr;
		gen_bits = null;
		ref = null;
		expected_type = null;
		is_var_stmt = false;
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

	public BitSet getGenBits()
	{
		return or(expr.getGenBits(), gen_bits); // union of expr and cv bits.
	}

	public BitSet getKillBits()
	{
		BitSet kb = expr.getKillBits();

		// Union kill bits of the embedded expression and
		// the kill bits of the completion value definition.

		if (ref != null && ref.slot != null)
		{
			if (ref.slot.getDefBits() != null)
			{
				return or(kb, xor(ref.slot.getDefBits(),gen_bits));
			}
			else
			{
				return or(kb, gen_bits);
			}
		}
		else
		{
			return kb;
		}
	}

	public String toString()
	{
      if(Node.useDebugToStrings)
         return "ExpressionStatement@" + pos();
      else
         return "ExpressionStatement";
	}

	public ReferenceValue getRef(Context cx)
	{
		if (ref == null)
		{
			ref = new ReferenceValue(cx, null, "_cv", ObjectValue.internalNamespace);
		}
		return ref;
	}

	public void expectedType(TypeValue type)
	{
		expected_type = type;
   		expr.expectedType(type);
	}

	public void isVarStatement(boolean b)
	{
		is_var_stmt = b;
	}

	public boolean isVarStatement()
	{
		return is_var_stmt;
	}

	public boolean isExpressionStatement()
	{
		return true;
	}

	public boolean isAttribute()
	{
		return expr.isAttribute();
	}
	
	public void voidResult()
	{
	    expr.voidResult();
	}
	
	public boolean isConfigurationName()
	{
		return expr.isConfigurationName();
	}

	private boolean skip = false;
	public void skipNode(boolean b)
	{
		skip = b;
	}

	public boolean skip()
	{
		return skip;
	}
}
