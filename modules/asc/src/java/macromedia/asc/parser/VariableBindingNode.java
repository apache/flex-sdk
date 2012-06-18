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
public class VariableBindingNode extends Node
{
	public TypedIdentifierNode variable;
	public Node initializer;
	public ReferenceValue ref;
	public ReferenceValue typeref;
	public AttributeListNode attrs;
	public String debug_name;
	public int kind;
	
	protected static final int PACKAGE_FLAG = 1;	

	public VariableBindingNode(PackageDefinitionNode pkgdef, AttributeListNode attrs, int kind, TypedIdentifierNode variable, Node initializer)
	{
		ref = null;
		typeref = null;
		this.attrs = attrs;
		this.variable = variable;
		this.initializer = initializer;
		this.kind = kind;
		
		if (pkgdef != null)
		{
			flags |= PACKAGE_FLAG;
		}
	}

	public boolean inPackage()
	{
		return (flags & PACKAGE_FLAG) != 0;
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

	public int pos()
	{
		return variable.identifier.pos();
	}

	public String toString()
	{
		return "VariableBinding";
	}
}
