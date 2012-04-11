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

package flex2.compiler.util;

import java.util.HashMap;

/**
 * This class represents a map of QName to Objects.  It includes handy
 * methods, like containsKey(String, String), which allow performing
 * collection operations without having to create a new QName.
 *
 * @author Clement Wong
 */
public class QNameMap<V extends Object> extends HashMap<QName, V>
{
	private static final long serialVersionUID = -2981999493690343118L;

    public QNameMap()
	{
		super();
		key = new QName();
	}

	public QNameMap(int size)
	{
		super(size);
		key = new QName();
	}

	private QName key;

	public boolean containsKey(String ns, String name)
	{
		key.setNamespace(ns);
		key.setLocalPart(name);
		return containsKey(key);
	}

	public V get(String ns, String name)
	{
		key.setNamespace(ns);
		key.setLocalPart(name);
		return get(key);
	}

	public V put(String ns, String name, V value)
	{
		return put(new QName(ns, name), value);
	}
}
