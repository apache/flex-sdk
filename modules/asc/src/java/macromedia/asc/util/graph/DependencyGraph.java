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

package macromedia.asc.util.graph;

import java.util.*;

/**
 * @author Clement Wong
 */
public final class DependencyGraph<T> extends Graph<String, Object>
{
	public DependencyGraph()
	{
		map = new HashMap<String, T>();
		vertices = new HashMap<String, Vertex<String>>();
	}

	private Map<String, T> map;
	private Map<String, Vertex<String>> vertices;

	// put(), get(), remove() are methods for 'map'

	public void put(String key, T value)
	{
		map.put(key, value);
	}

	public T get(String key)
	{
		return map.get(key);
	}

	public void remove(String key)
	{
		map.remove(key);
	}

	public Set<String> keySet()
	{
		return map.keySet();
	}

	public int size()
	{
		return map.size();
	}

	public boolean containsKey(String key)
	{
		return map.containsKey(key);
	}

	public boolean containsVertex(String key)
	{
		return vertices.containsKey(key);
	}
	
	// methods for graph manipulations

	public void addVertex(Vertex<String> v)
	{
		super.addVertex(v);
		vertices.put(v.getWeight(), v);
	}

	public void addDependency(String name, String dep)
	{
		Vertex<String> tail = null, head = null;

		if ((head = vertices.get(name)) == null)
		{
			head = new Vertex<String>(name);
			addVertex(head);
		}

		if ((tail = vertices.get(dep)) == null)
		{
			tail = new Vertex<String>(dep);
			addVertex(tail);
		}

		addEdge(new Edge<Object>(tail, head, null));
	}
}

