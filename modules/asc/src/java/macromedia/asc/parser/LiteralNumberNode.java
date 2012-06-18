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

/**
 * Node
 *
 * @author Jeff Dyer
 */
public class LiteralNumberNode extends Node
{
	public TypeValue type;
	public String value;
    public NumberConstant numericValue;
    public NumberUsage numberUsage;

	public LiteralNumberNode(String value)
	{
		type = null;
		void_result = false;
		this.value = value.intern();
		numberUsage = null;
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

	public boolean void_result;

	public void voidResult()
	{
		void_result = true;
	}

    public boolean isLiteral()
    {
        return true;    
    }

	public boolean isLiteralNumber()
	{
		return true;
	}

	public boolean isLiteralInteger()
	{
		return false;
	}

	public int intValue()
	{
		return Integer.parseInt(value);
	}

	public void negate()
	{
		if (value.charAt(0) == '-') {
			value = value.substring(1);
		}
		else {
			value = "-" + value;
		}

		value = value.intern();
	}

	public String toString()
	{
		return "LiteralNumber";
	}
}
