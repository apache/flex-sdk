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

package flex2.compiler.as3.reflect;

import flex2.compiler.SymbolTable;
import flex2.compiler.abc.AbcClass;
import flex2.compiler.util.QName;
import flex2.compiler.util.QNameList;
import macromedia.asc.parser.*;
import macromedia.asc.semantics.ObjectValue;
import macromedia.asc.semantics.ParameterizedName;
import macromedia.asc.semantics.ReferenceValue;
import macromedia.asc.semantics.TypeInfo;
import macromedia.asc.util.ObjectList;

import java.util.*;

/**
 * The reflection API exposed to As3Compiler extensions.
 *
 * @author Clement Wong
 * @see flex2.compiler.as3.Extension
 * @see flex2.compiler.as3.As3Compiler
 */
public class TypeTable
{
	public TypeTable(SymbolTable symbolTable)
	{
		this.symbolTable = symbolTable;
	}

	private SymbolTable symbolTable;

	public AbcClass getClass(String className)
	{
		return symbolTable.getClass(className);
	}

	// C: TypeTable should not expose SymbolTable, if possible.
    public SymbolTable getSymbolTable()
    {
        return symbolTable;
    }

	static String convertName(ReferenceValue typeref)
	{
		ObjectValue ns = typeref.namespaces.first();
		if( ns != null && ns.name.length() > 0 )
		{
			StringBuilder value = new StringBuilder(ns.name.length() + 1 + typeref.name.length());
		    value.append(ns.name).append(':').append(typeref.name);
			return value.toString();
		}
		else
		{
			return typeref.name;
		}
	}

	public final Map<String, AbcClass> createClasses(ObjectList clsdefs, QNameList toplevelDefinitions)
	{
		Map<String, AbcClass> classes = new HashMap<String, AbcClass>();
		for (int i = 0, size = clsdefs.size(); i < size; i++)
		{
			ClassDefinitionNode clsdef = (ClassDefinitionNode) clsdefs.get(i);
			macromedia.asc.semantics.QName qName = clsdef.cframe.builder.classname;

			if (toplevelDefinitions.contains(qName.ns.name, qName.name))
			{
				createClass(clsdef, classes);
			}
		}
		return classes;
	}

	private final void createClass(ClassDefinitionNode clsdef, Map<String, AbcClass> classes)
	{
		AbcClass cls = new As3Class(clsdef, this);
		classes.put(cls.getName(), cls);
	}

	static List<flex2.compiler.abc.MetaData> createMetaData(DefinitionNode def)
	{
		List<flex2.compiler.abc.MetaData> list = null;

		for (int i = 0, size = def.metaData != null ? def.metaData.items.size() : 0; i < size; i++)
		{
			MetaDataNode n = (MetaDataNode) def.metaData.items.get(i);
			if (list == null)
			{
				list = new ArrayList<flex2.compiler.abc.MetaData>();
			}
			list.add(new MetaData(n));
		}

		return list;
	}
}
