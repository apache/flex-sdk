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

import static adobe.abc.OptimizerConstants.*;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.*;

public class Type
{
	Name name;
	public Type base;
	Type[] interfaces = notypes;
	Symtab<Binding> defs;
	Method init;
	Type itype;
	int flags;
	Namespace protectedNs;
	Typeref[] scopes = notyperefs; // captured outer scopes
	boolean numeric;
	boolean primitive;
	boolean atom;
	Object defaultValue;
	public Typeref ref;
	int size;
	int slotCount;
	int ctype;
	boolean obscure_natives;
	
	Type()
	{
		this.ref = new Typeref(this, true);
		this.obscure_natives = false;
		
		defaultValue = TypeCache.instance().NULL;
		this.ctype = CTYPE_OBJECT;
	}

	Type(Name name, Type base)
	{
		this();
		this.name = name;
		this.base = base;
		this.defs = new Symtab<Binding>();
		this.obscure_natives = false;
	}
	
	boolean emitAsAny()
	{
		// not sure about this, attempting to coerce native class as *
		//  FIXME: need to account for interfaces now...
		return base == null && 
		this != TypeCache.instance().VOID && 
		defs.size() == 0 && 
		! TypeCache.instance().builtinTypes.contains(this) && 
		!TypeCache.instance().baseTypes.contains(this);
		
	}
	
	public String toString()
	{
		return String.valueOf(name);
	}
	
	public boolean isFinal()
	{
		return (flags & CLASS_FLAG_final) != 0;
	}
	
	void setFinal()
	{
		flags |= CLASS_FLAG_final;
	}
	
	Binding find(Name n)
	{
		// look up the inheritance tree
		for (Type t = this; t != null; t = t.base)
		{
			Binding b = t.defs.get(n);
			if (b != null)
				return b;
		}
		return null;
	}
	
	Binding findGet(Name n)
	{
		Binding first = find(n);
		if (first != null && GlobalOptimizer.isSetter(first))
		{
			if (first.peer != null)
				return first.peer;
			Binding second;
			if (base != null && GlobalOptimizer.isGetter(second=base.findGet(n)))
				return second;
		}
		return first;
	}
	
	public Binding findSlot(int slot)
	{
		for (Binding b: defs.values())
		{
			if (GlobalOptimizer.isSlot(b) && b.slot == slot)
				return b;
		}
		return null;
	}
	
	public boolean hasProtectedNs()
	{
		return (flags & CLASS_FLAG_protected) != 0;
	}
	
	boolean isMachineCompatible(Type t)
	{
		boolean result;
		
		result  = equals(t);
		result |= equals(TypeCache.instance().NULL) && !t.isMachineType();
		result |= t.equals(TypeCache.instance().NULL) && !isMachineType();
		result |= !isMachineType() && !t.isMachineType() && !equals(TypeCache.instance().ANY) && !t.equals(TypeCache.instance().ANY);
		
		return result;
	}
	
	boolean isMachineType() 
	{
		return
			equals(TypeCache.instance().OBJECT) ||
			equals(TypeCache.instance().VOID) ||
			equals(TypeCache.instance().INT) ||
			equals(TypeCache.instance().UINT) ||
			equals(TypeCache.instance().BOOLEAN) ||
			equals(TypeCache.instance().ARRAY) ||  // TODO: AVM doesn't make this a machine type, but it acts like one.
			equals(TypeCache.instance().NUMBER);
	}
	
	public boolean isAtom()
	{
		return this.atom;
	}

	public Name getName() {
		return name;
	}


	public boolean isPrimitive() {
		return primitive;
	}

	public boolean isNumeric() 
	{
		return numeric;
	}
	
	public boolean extendsOrIsBase(Type c)
	{
		return this == c || this.extendsBase(c);
	}
	
	public boolean extendsBase(Type c)
	{
		for (Type t = this.base; t != null; t = t.base)
			if (t == c) 
				return true;
		return false;
	}
	
	public boolean implementsInterface(Type i)
	{
		for ( Type x: this.interfaces )
			if ( x == i )
				return true;
		return false;
	}
	
	public boolean isDerivedFrom(Type x)
	{
		return this.extendsBase(x) || this.implementsInterface(x);
	}
}
