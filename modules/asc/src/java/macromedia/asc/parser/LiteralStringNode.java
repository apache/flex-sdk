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
public class LiteralStringNode extends Node
{
	public String value;

	// consts used to identify string delimiter type.
	private static final int SINGLE_QUOTE_DELIMITER = 2;
	private static final int DOUBLE_QUOTE_DELIMITER = 1;
	private static final int OTHER_DELIMITER=0; // this can occur in an xml literal expression, or in LiteralStringNodes synthesized by the compiler
	
	private int delimiterType; // one of the above delim types
	
	public boolean isSingleQuote()
	{
		return delimiterType == SINGLE_QUOTE_DELIMITER;
	}

	public boolean isDoubleQuote()
	{
		return delimiterType == DOUBLE_QUOTE_DELIMITER;
	}

	public LiteralStringNode(String value)
	{
		void_result = false;
		this.value = value.intern();
		delimiterType = OTHER_DELIMITER;
	}

	public LiteralStringNode(String value, boolean singleQuoted)
	{
		this(value, singleQuoted, true);
	}

	/**
	 * This constructor is used by Flex direct AST generation.
	 *
	 * @param intern Controls whether value will be interned.  If
	 *				 <code>value</code> is an interned constant,
	 *				 <code>intern</code> should be false.  Otherwise,
	 *				 it should be true.
	 */
	public LiteralStringNode(String value, boolean singleQuoted, boolean intern)
	{
		void_result = false;

		if (intern)
		{
			this.value = value.intern();
		}
		else
		{
			assert value.intern() == value;
			this.value = value;
		}

		delimiterType = singleQuoted ? SINGLE_QUOTE_DELIMITER : DOUBLE_QUOTE_DELIMITER;
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

    public boolean isLiteral()
    {
        return true;
    }

	public boolean void_result;

	public void voidResult()
	{
		void_result = true;
	}

	public String toString()
	{
		return "LiteralString";
	}
}
