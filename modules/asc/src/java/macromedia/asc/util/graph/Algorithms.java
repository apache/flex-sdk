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

import java.util.Iterator;
import java.util.LinkedList;

/**
 * @author Clement Wong
 */
public final class Algorithms
{
	public static void topologicalSort(Graph g, Visitor visitor)
	{
		int[] inDegree = new int[g.getVertices().size()];
		Vertex[] vertices = new Vertex[inDegree.length];

		for (Iterator<Vertex> i = g.getVertices().iterator(); i.hasNext();)
		{
			Vertex v = i.next();
			vertices[v.id] = v;
			inDegree[v.id] = v.inDegrees();
		}

		LinkedList<Vertex> queue = new LinkedList<Vertex>();
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
			Vertex v = queue.removeFirst();
			if (visitor != null)
			{
				visitor.visit(v);
			}
			if (v.getSuccessors() != null)
			{
				for (Iterator<Vertex> i = v.getSuccessors().iterator(); i.hasNext();)
				{
					Vertex head = i.next();
					inDegree[head.id] -= 1;
					if (inDegree[head.id] == 0)
					{
						queue.add(head);
					}
				}
			}
		}
	}
}
