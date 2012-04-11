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
public class Graph <V,E>
{
	public Graph()
	{
		vertices = new HashSet<Vertex<V>>();
		edges = new HashSet<Edge<E>>();
	}

	private int counter;
	private Vertex<V> root;
	private Set<Vertex<V>> vertices;
	private Set<Edge<E>> edges;

	public Vertex getRoot()
	{
		return root;
	}

	public Set<Vertex<V>> getVertices()
	{
		return vertices;
	}

	public Set<Edge<E>> getEdges()
	{
		return edges;
	}

	public void addVertex(Vertex<V> v)
	{
		if (vertices.size() == 0)
		{
			root = v;
		}
		v.id = counter++;
		vertices.add(v);
	}

	public void addEdge(Edge<E> e)
	{
		edges.add(e);
	}

	public void normalize()
	{
		counter = 0;
		for (Iterator<Vertex<V>> i = vertices.iterator(); i.hasNext();)
		{
			i.next().id = counter++;
		}
	}
}
