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
public class NamespaceDefinitionNode extends DefinitionNode
{
	public IdentifierNode name;
	public Node value;
	public ReferenceValue ref;
	public String debug_name;
	public QName qualifiedname;
	public boolean needs_init;
	public BitSet gen_bits;

	public NamespaceDefinitionNode(PackageDefinitionNode pkgdef, AttributeListNode attrs, IdentifierNode name, Node value)
	{
		super(pkgdef, attrs, -1);
		this.name = name;
		this.value = value;
		ref = null;
		qualifiedname = null;
		gen_bits = null;
		needs_init = false;
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

	public boolean isConst()
	{
		return true;
	}

	public ReferenceValue getRef(Context cx)    
	{
		return ref;
	}
	
	public Node initializerStatement(Context cx)
	{
	    needs_init = true;
	    return this;
	}

	public BitSet getGenBits()
	{
		return gen_bits;
	}

	public BitSet getKillBits()
	{
		if (ref != null && ref.slot != null)
		{
			if (ref.slot.getDefBits() != null)
			{
				return xor(ref.slot.getDefBits(), gen_bits);
			}
			else
			{
				return gen_bits;
			}
		}
		else
		{
			return null;
		}
	}
	public String toString()
	{
		return "NamespaceDefinition";
	}
}
