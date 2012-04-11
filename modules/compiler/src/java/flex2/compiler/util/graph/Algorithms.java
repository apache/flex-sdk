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
import java.util.LinkedList;
import java.util.Set;

//TODO Try to remove this class and use ASC's equivalent

/**
 * A collection of graph sorting and utility methods.
 *
 * @author Clement Wong
 */
public final class Algorithms
{
	public static <VertexWeight,EdgeWeight> boolean isCyclic(Graph<VertexWeight,EdgeWeight> g)
	{
		ConnectednessCounter<VertexWeight,EdgeWeight> counter = new ConnectednessCounter<VertexWeight,EdgeWeight>();
		topologicalSort(g, counter);
		return counter.count != g.getVertices().size();
	}

	public static <VertexWeight,EdgeWeight> Set<Vertex<VertexWeight,EdgeWeight>> detectCycles(Graph<VertexWeight,EdgeWeight> g)
	{
		ConnectednessCounter<VertexWeight,EdgeWeight> counter = new ConnectednessCounter<VertexWeight,EdgeWeight>(g.getVertices());
		topologicalSort(g, counter);
		return counter.remained;
	}

    public static <VertexWeight,EdgeWeight> void topologicalSort(Graph<VertexWeight,EdgeWeight> g, Visitor<Vertex<VertexWeight,EdgeWeight>> visitor)
	{
		int[] inDegree = new int[g.getVertices().size()];
        
        // unchecked because you cannot create a generic array
		@SuppressWarnings("unchecked")
		Vertex<VertexWeight,EdgeWeight>[] vertices = new Vertex[inDegree.length];

		for (Iterator<Vertex<VertexWeight,EdgeWeight>> i = g.getVertices().iterator(); i.hasNext();)
		{
			Vertex<VertexWeight,EdgeWeight> v = i.next();
			vertices[v.id] = v;
			inDegree[v.id] = v.inDegrees();
		}

		LinkedList<Vertex<VertexWeight,EdgeWeight>> queue = new LinkedList<Vertex<VertexWeight,EdgeWeight>>();
		for (int i = 0, length = vertices.length; i < length; i++)
		{
			// in case of seeing multiple degree-zero candidates, we could
			// use the vertices different weights...
			if (inDegree[i] == 0)
			{
				queue.add(vertices[i]);
			}
		}

		while (!queue.isEmpty())
		{
			Vertex<VertexWeight,EdgeWeight> v = queue.removeFirst();
			if (visitor != null)
			{
				visitor.visit(v);
			}
			if (v.getSuccessors() != null)
			{
				for (Iterator<Vertex<VertexWeight,EdgeWeight>> i = v.getSuccessors().iterator(); i.hasNext();)
				{
					Vertex<VertexWeight,EdgeWeight> head = i.next();
					inDegree[head.id] -= 1;
					if (inDegree[head.id] == 0)
					{
						queue.add(head);
					}
				}
			}
		}
	}

	private static class ConnectednessCounter<VertexWeight,EdgeWeight> implements Visitor<Vertex<VertexWeight,EdgeWeight>>
	{
		private ConnectednessCounter()
		{
			count = 0;
		}

		private ConnectednessCounter(Set<Vertex<VertexWeight,EdgeWeight>> vertices)
		{
			this.remained = new HashSet<Vertex<VertexWeight,EdgeWeight>>(vertices);
		}

		private int count;
		private Set<Vertex<VertexWeight,EdgeWeight>> remained;

		public void visit(Vertex<VertexWeight,EdgeWeight> v)
		{
			count++;
			remained.remove(v);
		}
	}
}
