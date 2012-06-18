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

import java.util.Set;
import java.util.HashSet;

/**
 * Node
 *
 * @author Jeff Dyer
 */
public class ProgramNode extends Node
{
	public StatementListNode statements;
	public ObjectList<FunctionCommonNode> fexprs;
	public ObjectList<ClassDefinitionNode> clsdefs;
	public ObjectList<PackageDefinitionNode> pkgdefs = new ObjectList<PackageDefinitionNode>();
	public ObjectList<ImportNode> imports = new ObjectList<ImportNode>();

	public int temp_count;
	public int var_count;
	public ObjectList<Block> blocks;
	public Context cx;
	public boolean has_unnamed_package;

	public ObjectValue frame;
	public ObjectValue importFrame;

	public ObjectValue default_namespace;
	public ObjectValue public_namespace;

	public static final int Inheritance = 1;
	public static final int Else = 2;
	public static final int Done = 3;
	public int state = Inheritance;

    public Namespaces used_def_namespaces = new Namespaces(); // don't delete
	
    public Set<ReferenceValue> import_def_unresolved = new HashSet<ReferenceValue>();
    public Set<ReferenceValue> package_unresolved = new HashSet<ReferenceValue>();
	public Set<ReferenceValue> ns_unresolved = new HashSet<ReferenceValue>();
	public Set<ReferenceValue> fa_unresolved = new HashSet<ReferenceValue>();
	public Set<ReferenceValue> ce_unresolved = new HashSet<ReferenceValue>();
	public Set<ReferenceValue> body_unresolved = new HashSet<ReferenceValue>();
	public Set<ReferenceValue> rt_unresolved = new HashSet<ReferenceValue>();

	public ProgramNode(Context cx, StatementListNode statements)
	{
	    this.cx = cx;
		this.statements = statements;
		has_unnamed_package = false;
		frame = null;
		default_namespace = null;
		public_namespace  = null;
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

	public String toString()
	{
		return "Program";
	}
}
