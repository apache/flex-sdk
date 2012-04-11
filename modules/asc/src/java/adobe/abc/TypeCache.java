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
import static java.lang.Boolean.FALSE;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_PackageNamespace;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_Qname;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class TypeCache 
{

	public Type OBJECT, FUNCTION, CLASS, ARRAY;
	public Type INT, UINT, NUMBER, BOOLEAN, STRING, NAMESPACE;
	public Type XML, XMLLIST, QNAME;
	public Type NULL, VOID;
	public Type ANY;
	
	public Set<Type>builtinTypes = new HashSet<Type>();
	public Set<Type>baseTypes    = new HashSet<Type>();

	public Symtab<Type> namedTypes = new Symtab<Type>();
	public Symtab<Typeref> globals = new Symtab<Typeref>();

	public Map<Namespace,Name> namespaceNames = new HashMap<Namespace,Name>();
	
	private static TypeCache the_instance = new TypeCache();
	
	public static TypeCache instance()
	{
		return the_instance;
	}
	
	public Type ANY()
	{
		if ( null == this.ANY )
		{
			this.ANY = new Type(new Name("*"),null);
			this.ANY.ctype = CTYPE_ATOM;
		}
		
		return this.ANY;
	}
	
	Type lookup(Name n, Type base)
	{
		Type t = namedTypes.get(n);

		if (t == null)
		{
			Name n2 = new Name(CONSTANT_Qname, new Namespace(CONSTANT_PackageNamespace, ""), n.name);
			t = namedTypes.get(n2);
			
			if (t == null)
			{
				t = new Type(n2, base);
				TypeCache.instance().namedTypes.put(n2, t);
			}
		}
		return t;
	}
	
	Type lookup(String name, Type base)
	{
		return lookup(new Name(name), base);
	}
	
	Type lookup(String name)
	{
		return lookup(name, OBJECT);
	}
	
	void setupBuiltins()
	{
		assert(null == OBJECT);

		OBJECT = this.namedTypes.get(new Name(Name.PKG_PUBLIC, "Object"));
		assert(null != OBJECT);
		
		NULL = lookup("null");
		CLASS = lookup("Class");
		FUNCTION = lookup("Function");
		ARRAY = lookup("Array");
		INT = lookup("int");
		UINT = lookup("uint");
		NUMBER = lookup("Number");
		BOOLEAN = lookup("Boolean");
		STRING = lookup("String");
		NAMESPACE = lookup("Namespace");
		XML = 	lookup("XML");
		XMLLIST =lookup("XMLList");
		QNAME =	lookup("QName");
		
		VOID =	lookup("void", null);
		
		OBJECT.ctype = CTYPE_ATOM;
		NULL.ctype = CTYPE_ATOM;
		VOID.ctype = CTYPE_VOID;
		INT.ctype = CTYPE_INT;
		UINT.ctype = CTYPE_UINT;
		NUMBER.ctype = CTYPE_DOUBLE;
		BOOLEAN.ctype = CTYPE_BOOLEAN;
		STRING.ctype = CTYPE_STRING;
		NAMESPACE.ctype = CTYPE_NAMESPACE;
		// everything else defaults to CTYPE_OBJECT

		INT.numeric = NUMBER.numeric = UINT.numeric = BOOLEAN.numeric = true;
		
		STRING.primitive = BOOLEAN.primitive = true;
		INT.primitive = NUMBER.primitive = UINT.primitive = true;
		VOID.primitive = NULL.primitive = true;
		
		ANY.atom = OBJECT.atom = VOID.atom = true;
		
		INT.ref = INT.ref.nonnull();
		NUMBER.ref = NUMBER.ref.nonnull();
		UINT.ref = UINT.ref.nonnull();
		BOOLEAN.ref = BOOLEAN.ref.nonnull();
		
		OBJECT.defaultValue = NULL;
		NULL.defaultValue = NULL;
		ANY.defaultValue = UNDEFINED;
		VOID.defaultValue = UNDEFINED;
		BOOLEAN.defaultValue = FALSE;
		NUMBER.defaultValue = NAN;
		INT.defaultValue = 0;
		UINT.defaultValue = 0;
		
		builtinTypes.add(CLASS);
		builtinTypes.add(FUNCTION);
		builtinTypes.add(ARRAY);
		builtinTypes.add(INT);
		builtinTypes.add(UINT);
		builtinTypes.add(NUMBER);
		builtinTypes.add(BOOLEAN);
		builtinTypes.add(STRING);
		builtinTypes.add(NAMESPACE);
		builtinTypes.add(XML);
		builtinTypes.add(XMLLIST);
		builtinTypes.add(QNAME);
		builtinTypes.add(VOID);
	}

	public boolean containsNamedType(Type at) 
	{
		return containsNamedType(at.getName());
	}
	
	public boolean containsNamedType(Name n) 
	{
		return namedTypes.contains(n);
	}
}
