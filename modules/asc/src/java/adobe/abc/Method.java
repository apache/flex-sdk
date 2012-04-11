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

import static adobe.abc.OptimizerConstants.*;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.*;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Method implements Comparable<Method>
{
	InputAbc abc;
	public final int id;
	int emit_id;
	public Edge entry;
	Typeref[] params;
	public Object[] values;
	int optional_count;
	Typeref returns;
	Name name;
	String debugName;
	Name[] paramNames;
	int flags;
	Type cx;
	private int blockId;
	private int exprId;
	int edgeId;
	String kind;
	
	// body fields
	int max_stack;
	int local_count;
	int max_scope;
	int code_len;
	
	Typeref activation;
	public Handler[] handlers = nohandlers;
	
	Map<Expr,Typeref> verifier_types = null;
	
	Map<Expr,Integer>fixedLocals = new HashMap<Expr,Integer>();
	
	Method(int id, InputAbc abc)
	{
		this.id = id;
		this.abc = abc;
	}
	public boolean needsRest()
	{
		return (flags & METHOD_Needrest) != 0;
	}
	public boolean needsArguments()
	{
		return (flags & METHOD_Arguments) != 0;
	}
	public boolean hasParamNames()
	{
		return (flags & METHOD_HasParamNames) != 0;
	}
	public boolean hasOptional()
	{
		return (flags & METHOD_HasOptional) != 0;
	}
	public boolean isNative()
	{
		return (flags & METHOD_Native) != 0;
	}
	
	public int nameIndex(Name n)
	{
		return abc.nameIndex(n);
	}
	
	public Name getName(int idx)
	{
		return abc.names[idx];
	}
	
	public int stringIndex(Object s)
	{
		//  TODO: Delegate to InputAbc
		return Arrays.asList(abc.strings).indexOf(s);
	}
	
	public String getString(int idx)
	{
		return abc.strings[idx];
	}
	
	public int typeIndex(Type t)
	{
		return Arrays.asList(abc.classes).indexOf(t);
	}
	
	public Type getType(int idx)
	{
		return abc.classes[idx];
	}
	
	public int methodIndex(Method m)
	{
		return Arrays.asList(abc.methods).indexOf(m);
	}
	
	public Method getMethod(int idx)
	{
		return abc.methods[idx];
	}
	
	public int compareTo(Method m)
	{
		return id - m.id;
	}
	
	public String toString()
	{
		return kind + " " + String.valueOf(getName());
	}
	
	public Name getParameterName(int idx)
	{
		if ( paramNames != null )
			return paramNames[idx];
		else if ( 0 == idx )
			return new Name("this");
		else
			return new Name("arg" + idx);
	}
	
	public Name getName() 
	{
		return name;
	}
	
	public Typeref[] getParams()
	{
		return params;
	}
	
	public Typeref getReturnType()
	{
		return returns;
	}
	
	public Algorithms.Deque<Block> depthFirstCfg()
	{
		return Algorithms.dfs(entry.to);
	}
	

	/**
	 * @return the next block serial number.
	 * @post Serial number incremented.
	 */
	public int getNextBlockId() 
	{
		return blockId++;
	}
	
	
	/**
	 * @return the next expression serial number.
	 * @post Serial number incremented.
	 */
	public int getNextExprId() 
	{
		return exprId++;
	}
	public List<Name> getAllNames()
	{
		return Arrays.asList(this.abc.names);
	}
}

