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
import macromedia.asc.embedding.avmplus.InstanceBuilder;
import macromedia.asc.embedding.avmplus.ClassBuilder;
import macromedia.asc.embedding.avmplus.ActivationBuilder;

import static macromedia.asc.parser.Tokens.*;

/**
 * Node
 *
 * @author Jeff Dyer
 */
public class FunctionDefinitionNode extends DefinitionNode
{
	public FunctionNameNode name;
	public FunctionCommonNode fexpr;
	public int fixedCount;
	public ObjectValue fun;
	public ReferenceValue ref;
	public Context cx;
	public ExpressionStatementNode init;
	public boolean needs_init;
    public boolean is_prototype;
    public int version = -1;

    public FunctionDefinitionNode(Context cx, PackageDefinitionNode pkgdef, AttributeListNode attrs, FunctionNameNode name, FunctionCommonNode fexpr)
	{
		super(pkgdef, attrs, -1);
		this.cx = cx;
		ref = null;
		this.name = name;
		this.fexpr = fexpr;
		fexpr.def = this;
		init = null;
		needs_init = false;
        is_prototype = false;
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

	public Node first()
	{
		return fexpr.body.first();
	}

	public Node last()
	{
		return fexpr.body.last();
	}

	public Node initializerStatement(Context cx)
	{
        NodeFactory nodeFactory = cx.getNodeFactory();
        ObjectValue obj = cx.scope();
        Builder bui = obj.builder;
        Node node;

        // If this is a getter, setter or package, class or instance method, then don't create a closure

        if( !(bui instanceof ActivationBuilder) &&
            ( bui instanceof ClassBuilder ||
              bui instanceof InstanceBuilder ||
              this.pkgdef != null ||
              this.name.kind == GET_TOKEN ||
              this.name.kind == SET_TOKEN ) )
        {
            node = nodeFactory.emptyStatement();
        }
        else
        {
            node = this;
            this.needs_init = true;
        }
        return node;
	}

	public int countVars()
	{
		return name.kind==EMPTY_TOKEN?1:0;
	}

	public boolean isDefinition()
	{
		return true;
	}

	public boolean isConst()
	{
		return true;
	}

	public String toString()
	{
		return "FunctionDefinition";
	}
}
