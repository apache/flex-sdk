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

public class Typeref
{
	public final Type t;
	final boolean nullable;
	
	Typeref(Type t, boolean nullable)
	{
		assert(t != null);
		this.t = t;
		this.nullable = nullable;
	}
	
	Typeref nonnull()
	{
		return nullable ? new Typeref(t,false) : this;
	}
	
	Typeref nullable()
	{
		return nullable? this: new Typeref(t, true);
	}
	
	public boolean equals(Object o)
	{
		return (o instanceof Typeref) && ((Typeref)o).t == t && ((Typeref)o).nullable == nullable;
	}
	
	Binding find(Name n)
	{
		return t.find(n);
	}
	
	Binding findGet(Name n)
	{
		return t.findGet(n);
	}
	
	public String toString()
	{
		return !t.ref.nullable || t==TypeCache.instance().NULL || t==TypeCache.instance().VOID || t==TypeCache.instance().ANY ? t.toString() :
				nullable ? t.toString() + "?" :
				t.toString();
	}
	
	public Type getType()
	{
		return t;
	}
}
