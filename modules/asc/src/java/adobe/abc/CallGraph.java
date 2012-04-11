/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package adobe.abc;

import adobe.abc.GlobalOptimizer.InputAbc;


import java.util.ArrayList;
import java.util.List;

import static macromedia.asc.embedding.avmplus.ActionBlockConstants.*;

public class CallGraph
{
	InputAbc abc;
	
	CallGraph(InputAbc abc)
	{
		this.abc = abc;
	}

	public List<Method> traverseDepthFirstUnique()
	{
		List<Method> traversed_methods = new ArrayList<Method>();
		
		for (Type t: this.abc.scripts)
		{
			searchType(t, traversed_methods);
		}
		
		return traversed_methods;
	}
	
	private void searchType(Type t, List<Method> traversed_methods)
	{
		searchMethod(t.init, traversed_methods);

		for (Binding b1: t.defs.values())
			if (b1.method != null)
				searchMethod(b1.method, traversed_methods);
		
	}
		
	private void searchMethod(Method m, List<Method> traversed_methods)
	{
		if ( traversed_methods.contains(m))
		{
			return;
		}
		
		traversed_methods.add(m);
		
		for ( Block b: Algorithms.dfs(m.entry.to))
		{
			for ( Expr e: b.exprs )
			{
				switch(e.op)
				{
					case OP_newclass:
					{
						searchType(e.c, traversed_methods);
						searchType(e.c.itype, traversed_methods);
						break;
					} 
					case OP_newfunction:
					{
						Method f = e.m;
						searchMethod(f, traversed_methods);
						break;
					}
				}
			}
		}
	}

}
