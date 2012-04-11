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

import java.util.*;

//TODO Try to remove this class and use ASC's equivalent

/**
 * Represents a node in a graph.
 *
 * @author Clement Wong
 */
public final class Vertex <VertexWeight,EdgeWeight>
{
	private static final int INITIAL_CAPACITY = 5;

	public Vertex(VertexWeight weight)
	{
		this.weight = weight;
	}

	private VertexWeight weight;

	int id;
	private Set<Edge<VertexWeight,EdgeWeight>> incidentEdges;     // pointing to this vertex
	private Set<Edge<VertexWeight,EdgeWeight>> emanatingEdges;    // pointing out of this vertex
	private Set<Vertex<VertexWeight,EdgeWeight>> predecessors; // tails of the incident edges
	private List<Vertex<VertexWeight,EdgeWeight>> successors;  // heads of the emanating edges

	public VertexWeight getWeight()
	{
		return weight;
	}

	public void addIncidentEdge(Edge<VertexWeight,EdgeWeight> e)
	{
		if (incidentEdges == null)
		{
			incidentEdges = new HashSet<Edge<VertexWeight,EdgeWeight>>(INITIAL_CAPACITY);
		}
		incidentEdges.add(e);
	}
	
	public void removeIncidentEdge(Edge<VertexWeight,EdgeWeight> e)
	{
		if (incidentEdges != null)
		{
			incidentEdges.remove(e);
		}
	}

	public Set<Edge<VertexWeight,EdgeWeight>> getIncidentEdges()
	{
		return incidentEdges;
	}

	public void addEmanatingEdge(Edge<VertexWeight,EdgeWeight> e)
	{
		if (emanatingEdges == null)
		{
			emanatingEdges = new HashSet<Edge<VertexWeight,EdgeWeight>>(INITIAL_CAPACITY);
		}
		emanatingEdges.add(e);
	}

	public void removeEmanatingEdge(Edge<VertexWeight,EdgeWeight> e)
	{
		if (emanatingEdges != null)
		{
			emanatingEdges.remove(e);
		}
	}

	public Set<Edge<VertexWeight,EdgeWeight>> getEmanatingEdges()
	{
		return emanatingEdges;
	}

	public void addPredecessor(Vertex<VertexWeight,EdgeWeight> v)
	{
		if (predecessors == null)
		{
			predecessors = new HashSet<Vertex<VertexWeight,EdgeWeight>>(INITIAL_CAPACITY);
		}
		predecessors.add(v);
	}
	
	public void removePredecessor(Vertex<VertexWeight,EdgeWeight> v)
	{
		if (predecessors != null)
		{
			predecessors.remove(v);
		}
	}

	public Set<Vertex<VertexWeight,EdgeWeight>> getPredecessors()
	{
		return predecessors;
	}

	public void addSuccessor(Vertex<VertexWeight,EdgeWeight> v)
	{
		if (successors == null)
		{
			successors = new ArrayList<Vertex<VertexWeight,EdgeWeight>>(INITIAL_CAPACITY);
		}
		successors.add(v);
	}

	public void removeSuccessor(Vertex<VertexWeight,EdgeWeight> v)
	{
		if (successors != null)
		{
			successors.remove(v);
		}
	}

	public List<Vertex<VertexWeight,EdgeWeight>> getSuccessors()
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
		return false;
	}

	public int hashCode()
	{
		return (weight != null) ? weight.hashCode() : super.hashCode();
	}
}
