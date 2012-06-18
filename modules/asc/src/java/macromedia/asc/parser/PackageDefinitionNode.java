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
public class PackageDefinitionNode extends DefinitionNode
{
	public ReferenceValue ref;
	public PackageNameNode name;
	public StatementListNode statements;

	public ObjectList<FunctionCommonNode> fexprs = new ObjectList<FunctionCommonNode>();
	public ObjectList<ClassDefinitionNode> clsdefs = new ObjectList<ClassDefinitionNode>();

	public ObjectValue defaultNamespace;
	public ObjectValue publicNamespace;
    public ObjectValue internalNamespace;
    
    public Namespaces used_namespaces = new Namespaces();
    public Namespaces used_def_namespaces = new Namespaces();
    public Multinames imported_names = new Multinames();
    
	public int var_count;
	public int temp_count;
	public Context cx;

	public boolean package_retrieved;
    public boolean in_this_pkg;

	public PackageDefinitionNode(Context cx, AttributeListNode attrs, PackageNameNode name, StatementListNode statements)
	{
        super(null,attrs,0);
		this.cx = cx;
		this.ref = null;
		this.name = name;
		this.statements = statements;
		this.var_count = 0;
		this.temp_count = 0;
		
		package_retrieved = false;
		in_this_pkg = false;

		defaultNamespace = null;
		publicNamespace = null;
        internalNamespace = null;
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

	public Node initializerStatement(Context cx)
	{
		return cx.getNodeFactory().emptyStatement();
	}

	public boolean isConst()
	{
		return true;
	}

    public boolean isDefinition()
    {
        return false;  // this is not an error. this keeps packages from getting hoisted
    }

	public String toString()
	{
		if(Node.useDebugToStrings)
         return "PackageDefinition@" + pos();
      else
         return "PackageDefinition";
	}
}
