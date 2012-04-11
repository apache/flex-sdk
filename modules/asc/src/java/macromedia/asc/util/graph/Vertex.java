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
public final class Vertex <W>
{
	private static final int INITIAL_CAPACITY = 5;

	public Vertex(W weight)
	{
		this.weight = weight;
	}

	private W weight;

	int id;
	private Set<Edge> incidentEdges;
	private Set<Edge> emanatingEdges;
	private Set<Vertex<W>> predecessors;
	private List<Vertex<W>> successors;

	public W getWeight()
	{
		return weight;
	}

	public void addIncidentEdge(Edge e)
	{
		if (incidentEdges == null)
		{
			incidentEdges = new HashSet<Edge>(INITIAL_CAPACITY);
		}
		incidentEdges.add(e);
	}

	public Set<Edge> getIncidentEdges()
	{
		return incidentEdges;
	}

	public void addEmanatingEdge(Edge e)
	{
		if (emanatingEdges == null)
		{
			emanatingEdges = new HashSet<Edge>(INITIAL_CAPACITY);
		}
		emanatingEdges.add(e);
	}

	public Set<Edge> getEmanatingEdges()
	{
		return emanatingEdges;
	}

	public void addPredecessor(Vertex<W> v)
	{
		if (predecessors == null)
		{
			predecessors = new HashSet<Vertex<W>>(INITIAL_CAPACITY);
		}
		predecessors.add(v);
	}

	public Set<Vertex<W>> getPredecessors()
	{
		return predecessors;
	}

	public void addSuccessor(Vertex<W> v)
	{
		if (successors == null)
		{
			successors = new ArrayList<Vertex<W>>(INITIAL_CAPACITY);
		}
		successors.add(v);
	}

	public List<Vertex<W>> getSuccessors()
	{
		return successors;
	}

	public int inDegrees()
	{
		return incidentEdges == null ? 0 : incidentEdges.size();
	}

	public int outDegrees()
	{
		return emanatingEdges == null ? 0 : emanatingEdges.size();
	}

	public boolean equals(Object object)
	{
		if (object instanceof Vertex)
		{
			return (weight == null) ? super.equals(object) : weight.equals(((Vertex) object).weight);
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
