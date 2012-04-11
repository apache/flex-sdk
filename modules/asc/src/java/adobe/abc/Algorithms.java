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

import static adobe.abc.OptimizerConstants.OP_phi;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.BitSet;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

public abstract class Algorithms
{

	/**
	 * Cast a BitSet, so to speak, to an iterable Set.
	 * @param x - the set to be iterated over.
	 * @return the same numbers in a sorted Set.
	 */
	public static Set<Integer> foreach(BitSet x)
	{
		Set<Integer> result = new TreeSet<Integer>();
		for ( int i = 0; i < x.length(); i++ )
			if ( x.get(i) )
				result.add(i);
		
		return result;
	}
	
	/**
	 * compute idom(b) for each b in the flow graph using the
	 * classic iterative algorithm with the dom set formed by
	 * the list of idom(b) from b to entry, as presented by
	 * Cooper, Harvey, and Kennedy:
	 * http://citeseer.ist.psu.edu/cooper01simple.html
	 * @return
	 */
	public static Map<Block,Block> idoms(Deque<Block> all, SetMap<Block,Edge>pred)
	{
		Block entry = all.peekFirst();
		Block[] doms = new Block[entry.postorder+1];
		
		doms[entry.postorder] = entry;
		boolean changed;
		do
		{
			changed = false;
			for (Block b: all)
			{
				if (b == entry)
					continue;
				Block new_idom = null;
				// pick any pred that is processed already
				for (Edge e: pred.get(b))
				{
					Block p = e.from;
					if (doms[p.postorder] != null)
					{
						new_idom = p;
						break;
					}
				}
				// intersect with all other processed preds
				for (Edge e: pred.get(b))
				{
					Block p = e.from;
					if (p != new_idom && doms[p.postorder] != null)
						new_idom = intersect(p, new_idom, doms);
				}
				// if new dominator found then do another pass
				if (doms[b.postorder] != new_idom)
				{
					doms[b.postorder] = new_idom;
					changed = true;
				}
			}
		}
		while (changed);
		
		Map<Block,Block> map = new TreeMap<Block,Block>();
		for (Block b: all)
			if (b != entry)
				map.put(b, doms[b.postorder]);
		
		return map;
	}
	
	/**
	 * find the nearest common dominator of b1 and b2
	 *
	 * @param b1
	 * @param b2
	 * @param doms
	 * @return
	 */
	public static Block intersect(Block b1, Block b2, Block[] doms)
	{
		while (b1 != b2)
		{
			while (b1.postorder < b2.postorder)
				b1 = doms[b1.postorder];
			while (b2.postorder < b1.postorder)
				b2 = doms[b2.postorder];
		}
		return b1;
	}
	
	public static boolean dominates(Block p, Block s, Map<Block,Block>idom)
	{
		for (Block b = s; b != null; b = idom.get(b))
			if (b == p)
				return true;
		return false;
	}
	
	public static SetMap<Block,Edge> preds(Deque<Block> code)
	{
		SetMap<Block,Edge> pred = new SetMap<Block,Edge>();
		for (Block b: code)
			for (Edge s: b.succ())
				pred.get(s.to).add(s);
		
		return pred;
	}
	
	static void checkPredecessors(SetMap<Block,Edge> pred, Deque<Block> code)
	{
		for (Block b: code)
			for (Expr e: b)
				if (e.op != OP_phi)
					break;
				else
				{
					// make sure each PHI has the same set of incoming
					// edges as the block does.
					Set<Edge>phi_in = new TreeSet<Edge>();
					for (Edge p: e.pred) phi_in.add(p);
					Set<Edge>blk_in = pred.get(b);
					assert(phi_in.equals(blk_in));
				}
	}

	static SetMap<Block,Edge> allpreds(Deque<Block> code)
	{
		SetMap<Block,Edge> pred = new SetMap<Block,Edge>();
		for (Block b: code)
		{
			for (Edge s: b.succ())
				pred.get(s.to).add(s);
			for (Edge x: b.xsucc)
				pred.get(x.to).add(x);
		}
		return pred;
	}
	
	/**
	 * find the set of def->use edges.  These are the opposite of the
	 * use->def edges encoded in Expr.args[] and scopes[]. 
	 * @param code
	 * @return
	 */
	public static EdgeMap<Expr> findUses(Deque<Block> code)
	{
		EdgeMap<Expr> uses = new EdgeMap<Expr>();
		for (Block b : code)
			for (Expr e : b)
			{
				for (Expr a : e.args) uses.get(a).add(e);
				for (Expr a : e.locals) uses.get(a).add(e);
				for (Expr a : e.scopes) uses.get(a).add(e);
			}
		return uses;
	}
	
	private static void dfs_visit_el(Edge[] el, BitSet visited, Deque<Block>list)
	{
		for (int i=el.length-1; i >= 0; i--)
			dfs_visit(el[i].to, visited, list);
	}
	
	private static Deque<Block> dfs_visit(Block b, BitSet visited, Deque<Block>list)
	{
		if (!visited.get(b.id))
		{
			visited.set(b.id);
			
			dfs_visit_el(b.xsucc, visited, list);
			dfs_visit_el(b.succ(), visited, list);

			b.postorder = list.size();
			list.addFirst(b);
		}
		return list;
	}
	
	public static Deque<Block> dfs(Block entry)
	{
		return dfs_visit(entry, new BitSet(), new LinkedDeque<Block>());
	}
	
	public static class SetMap<K,V> extends TreeMap<K, Set<V>>
	{
		public Set<V> get(Object e)
		{
			Set<V> s = super.get(e);
			if (s == null)
				put((K)e,s = new TreeSet<V>());
			return s;
		}
		static final long serialVersionUID=0;
	}
	
	public static class EdgeMap<E> extends SetMap<E,E>
	{
		public Set<E> get(Object e)
		{
			return super.get(e);
		}
		static final long serialVersionUID=0;
	}
	
	/**
	 *   Deque isn't present on pre 1.6 systems,
	 *   so the GlobalOptimizer needs its own
	 *   interface and implementations.
	 */
	public static interface Deque<E> extends List<E>
	{
		E removeFirst();
		E peekFirst();
		E removeLast();
		E peekLast();
		void addFirst(E e);
	}
	
	public static class ArrayDeque<E> extends ArrayList<E> implements Deque<E>
	{
		public ArrayDeque()
		{
		}
		
		public ArrayDeque(Collection<E> c)
		{
			addAll(c);
		}
		public void addFirst(E e)
		{
			add(0, e);
		}
		public E removeFirst()
		{
			return remove(0);
		}
		public E peekFirst()
		{
			return isEmpty() ? null : get(0);
		}
		public E removeLast()
		{
			return remove(size()-1);
		}
		public E peekLast()
		{
			return isEmpty() ? null : get(size()-1);
		}
		public static final long serialVersionUID = 0;
	}
	
	public static class LinkedDeque<E> extends LinkedList<E> implements Deque<E>
	{
		public E peekFirst()
		{
			return isEmpty() ? null : getFirst();
		}
		public E peekLast()
		{
			return isEmpty() ? null : getLast();
		}
		public static final long serialVersionUID = 0;
	}
	
	/**
	 * Abstract representation of an ABC pool,
	 * which can be sorted according to some
	 * criterion (e.g., most used elements to
	 * lowest positions).
	 *
	 * @param <T>
	 */
	public static class Pool<T extends Comparable>
	{
		Map<T,Integer> refs = new HashMap<T,Integer>();
		ArrayList<T> values;
		int countFrom;
		
		Pool(int countFrom)
		{
			this.countFrom = countFrom;
		}
		
		int add(T e)
		{
			int n = !refs.containsKey(e) ? 1 : refs.get(e) + 1;
			refs.put(e, n);
			return n;
		}
		
		@SuppressWarnings("unchecked")
		void sort()
		{
			Ranker<T>[] arr = new Ranker[refs.size()];
			int i=0;
			for (T e: refs.keySet())
				arr[i++] = new Ranker<T>(e,refs.get(e));
			assert(i==refs.size());
			Arrays.sort(arr);
			values = new ArrayList<T>();
			i=countFrom;
			for (Ranker<T> r: arr)
			{
				values.add(r.value);
				refs.put(r.value, i++);
			}
		}
		
		int id(T e)
		{
			assert(refs.containsKey(e));
			assert(refs.get(e) < size());
			return refs.get(e);
		}
		
		public String toString()
		{
			return String.valueOf(refs);
		}
		
		int size()
		{
			return countFrom + refs.size();
		}
		
		static class Ranker<T> implements Comparable
		{
			T value;
			int rank;
			Ranker(T value, int rank)
			{
				this.value = value;
				this.rank = rank;
			}
			public int compareTo(Object o)
			{
				return ((Ranker)o).rank - rank;
			}
		}
	}

	public static Block getBlock(Set<Block>work)
	{
		Iterator<Block> i = work.iterator();
		Block b = i.next();
		i.remove();
		return b;
	}
	
	public static Expr getExpr(Set<Expr>work)
	{
		Iterator<Expr> i = work.iterator();
		Expr e = i.next();
		i.remove();
		return e;
	}
	
	public static Edge getEdge(Set<Edge>work)
	{
		Iterator<Edge> i = work.iterator();
		Edge e = i.next();
		i.remove();
		return e;
	}
	
	public static Method getMethod(List<Method> list)
	{
		return list.remove(list.size()-1);
	}
	
	public static class TopologicalSort<T>
	{
		public interface DependencyChecker<T>
		{
			public boolean depends(T dep, T parent);
		}
		
		public List<T> toplogicalSort(List<T> unsorted, DependencyChecker<T> checker)
		{	
			//  Create a dependency graph.
			Map<T,Set<T>> dep = new HashMap<T,Set<T>>(unsorted.size());
			
			for ( T x: unsorted)
			{
				Set<T> parents = new HashSet<T>(); 
				dep.put(x, parents);
				
				for ( T y: unsorted )
				{
					if ( x != y && checker.depends(x, y))
					{
						if(checker.depends(y,x))
							throw new IllegalArgumentException("Cyclical graphs can't be topologically sorted.");

						parents.add(y);
					}
				}
			}
			
			//  Sort the dependency graph.
			List<T> sorted = new ArrayList<T>(unsorted.size());
			
			while ( dep.size() > 0 )
			{
				boolean found_sorted_element = false;
				
				for ( T x: dep.keySet() )
				{	
					if ( 0 == dep.get(x).size() )
					{
						//  No unsorted parents; add it to the sorted list.
						sorted.add(x);
						found_sorted_element = true;

						//  Remove this dependency from the remaining elements.
						for ( T y: unsorted )
						{
							if ( dep.containsKey(y) )
							{
								dep.get(y).remove(x);
							}
						}
						
						dep.remove(x);
						break;
					}
				}
				
				if ( !found_sorted_element )
					throw new IllegalArgumentException("Cyclical graphs can't be topologically sorted.");
			}

			return sorted;
		}
	}
}
