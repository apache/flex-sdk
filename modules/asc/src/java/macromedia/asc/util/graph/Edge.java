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

/**
 * @author Clement Wong
 */
public final class Edge <W>
{
	public Edge(Vertex tail, Vertex head, W weight)
	{
		this.head = head;
		this.tail = tail;
		this.weight = weight;

		tail.addEmanatingEdge(this);
		tail.addSuccessor(head);
		head.addIncidentEdge(this);
		head.addPredecessor(tail);
	}

	private Vertex head, tail;
	private W weight;

	public Vertex getHead()
	{
		return head;
	}

	public Vertex getTail()
	{
		return tail;
	}

	public W getWeight()
	{
		return weight;
	}

	public boolean equals(Object object)
	{
		if (object instanceof Edge)
		{
			Edge e = (Edge) object;
			return e.head == head && e.tail == tail && e.weight == weight;
		}
		else
		{
			return false;
		}
	}

	public int hashCode()
	{
		return (weight != null) ? weight.hashCode() : super.hashCode();
	}
}
