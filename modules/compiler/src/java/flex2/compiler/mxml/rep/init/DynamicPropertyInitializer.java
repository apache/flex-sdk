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

package flex2.compiler.mxml.rep.init;

import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.mxml.reflect.Type;

/**
 * This class represents an initializer for a property on a dynamic
 * object.
 */
public class DynamicPropertyInitializer extends NamedInitializer
{
	protected final Type type;
	protected final String name;

	public DynamicPropertyInitializer(Type type, String name, Object value, int line, StandardDefs defs)
	{
		super(value, line, defs);
		this.type = type;
		this.name = name;
	}

	public String getName()
	{
		return name;
	}

	public Type getLValueType()
	{
		return type;
	}
}
