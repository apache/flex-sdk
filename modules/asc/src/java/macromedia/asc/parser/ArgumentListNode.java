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
public class ArgumentListNode extends Node
{
	public ObjectList<Node> items = new ObjectList<Node>(1);
	public ObjectList<TypeInfo> expected_types; // declared argument types
	public ByteList   decl_styles;      // for function calls, a vector of PARAM_REQUIRED, PARAM_Optional, or PARAM_Rest
    public boolean is_bracket_selector = false;  //  a[x,y,z] is a comma operator, all values but the last have void result


	public ArgumentListNode(Node item, int pos)
	{
		super(pos);
		items.add(item);
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

	public int size()
	{
		return items.size();
	}

	public int pos()
	{
		return items.size() != 0 ? items.last().pos() : 0;
	}

	public boolean isLiteralInteger()
	{
		if (items.size() == 1 && items.first().isLiteralInteger())
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	public String toString()
	{
		return "ArgumentList";
	}
	
	public void addType(TypeInfo type)
	{
		if (expected_types == null)
			expected_types = new ObjectList<TypeInfo>(2);
		expected_types.push_back(type);
	}
	
	public void addDeclStyle(int style)
	{
		if (decl_styles == null)
			decl_styles = new ByteList(2);
		decl_styles.push_back((byte)style);
	}

    public boolean hasSideEffect()
    {
        for( Node n : items )
        {
            if( n.hasSideEffect() )
            {
                return true;
            }
        }
        return false;
    }
}
