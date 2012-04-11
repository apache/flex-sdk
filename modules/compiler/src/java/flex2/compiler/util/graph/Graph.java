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

package flex2.compiler.util.graph;

import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

//TODO Try to remove this class and use ASC's equivalent

/**
 * A base class for DependencyGraph.
 *
 * @author Clement Wong
 */
public class Graph<VertexWeight,EdgeWeight>
{
	public Graph()
	{
		vertices = new HashSet<Vertex<VertexWeight,EdgeWeight>>(300);
		edges = new HashSet<Edge<VertexWeight,EdgeWeight>>(300);
	}

	private int counter;
	private Vertex<VertexWeight,EdgeWeight> root;
	private Set<Vertex<VertexWeight,EdgeWeight>> vertices;
	private Set<Edge<VertexWeight,EdgeWeight>> edges;


	public Vertex<VertexWeight,EdgeWeight> getRoot()
	{
		return root;
	}

	public Set<Vertex<VertexWeight,EdgeWeight>> getVertices()
	{
		return vertices;
	}

	public Set<Edge<VertexWeight,EdgeWeight>> getEdges()
	{
		return edges;
	}

	public void clear()
	{
		counter = 0;
		root = null;
		vertices.clear();
		edges.clear();
	}

	public void addVertex(Vertex<VertexWeight,EdgeWeight> v)
	{
		if (vertices.size() == 0)
		{
			root = v;
		}
		v.id = counter++;
		vertices.add(v);
	}
	
	public void removeVertex(Vertex<VertexWeight,EdgeWeight> v)
	{
		vertices.remove(v);
		if (v == root)
		{
			Iterator<Vertex<VertexWeight,EdgeWeight>> i = vertices.iterator();
			root = i.hasNext() ? i.next() : null;
		}

        Set<Edge<VertexWeight,EdgeWeight>> s = v.getEmanatingEdges();
		if (s != null)
		{
            for (Edge<VertexWeight, EdgeWeight> e : s)
			{
				Vertex<VertexWeight, EdgeWeight> h = e.getHead();
				h.removeIncidentEdge(e);
				h.removePredecessor(v);
				
				edges.remove(e);
			}
		}
		
		s = v.getIncidentEdges();
		if (s != null)
		{
            for (Edge<VertexWeight, EdgeWeight> e : s)
			{
				Vertex<VertexWeight, EdgeWeight> t = e.getTail();
				t.removeEmanatingEdge(e);
				t.removeSuccessor(v);
				
				edges.remove(e);
			}
		}
		
		normalize();
	}

	public void addEdge(Edge<VertexWeight,EdgeWeight> e)
	{
		edges.add(e);
	}

	public void normalize()
	{
		counter = 0;
		for (Vertex<VertexWeight, EdgeWeight> name : vertices)
        {
			name.id = counter++;
		}
	}
}
