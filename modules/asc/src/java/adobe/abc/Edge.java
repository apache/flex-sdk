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

package adobe.abc;

public class Edge implements Comparable<Edge>
{
	public Block from;
	public Block to;
	int label;
	int id;

	/**
	 *  Exception edge's handler.
	 */
	Handler handler;
	boolean is_backwards_branch = false;
	
	Edge(Method m, Block f, int i)
	{
		from = f;
		label = i;
		id = m.edgeId++;
	}
	
	public Edge(Method m, Block f, int i, Block t)
	{
		this(m,f,i);
		to = t;
	}
	
	Edge(Method m, Block f, int i, Handler h)
	{
		this(m,f,i);
		handler = h;
	}
	
	public boolean isBackedge()
	{
		return from.postorder < to.postorder;
	}
	
	public int hashCode()
	{
		return label ^ to.hashCode() ^ (from != null ? from.hashCode() : 0);
	}
	
	public boolean equals(Object o)
	{
		return (o instanceof Edge) && ((Edge)o).from == from && ((Edge)o).to == to && ((Edge)o).label == label;
	}
	
	public String toString()
	{
		return (isThrowEdge() ? handler.toString()+" ":"") + 
				(from != null ? label+":"+from : "") + "->" + to;
	}
	
	public int compareTo(Edge e)
	{
		int d = label - e.label;
		if (d != 0) return d;
		if (from != null && e.from == null) return 1;
		if (from == null && e.from != null) return -1;
		if (from != null && (d = from.compareTo(e.from)) != 0)
			return d;
		return to.compareTo(e.to);
	}
	
	public boolean isThrowEdge()
	{
		return handler != null;
	}

	public int getLabel() 
	{
		return label;
	}
}