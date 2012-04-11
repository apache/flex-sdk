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

package flex2.linker;

import flex2.compiler.util.graph.Visitor;

import java.util.*;

/**
 * Walk the dependency graph implied by a collection of linkables, and visit
 * each linkable; prerequisites form a DAG and are visited in DFS order.
 * (Non-prerequisite connected linkables are visited in an arbitrary order.)
 *
 * Topological sort of DAG G is equivilent to the DFS of the graph G'
 * where for every edge (u,v) in G there is an edge (v,u) in the transposed
 * graph G'.
 *
 * This is handy since dependencies in Flex are a transposed DAG
 * (edges point to predecessors, not successors).
 *
 * @author Roger Gonzalez
 */
public class DependencyWalker
{
    /**
     * A value object which maintains external definitions, included
     * definitions, unresolved definitions.
     */
    public static class LinkState
    {
        public LinkState( Collection linkables, Set extdefs, Set includes, Set<String> unresolved )
                throws LinkerException
        {
            this.extdefs = extdefs;
	        this.includes = includes;
            this.unresolved = unresolved;

            // Build the defname -> linkable map and check for non-unique linkables

            for (Iterator li = linkables.iterator(); li.hasNext();)
            {
                Linkable l = (Linkable) li.next();

                if (lmap.containsKey( l.getName() ))
                {
                    throw new LinkerException.DuplicateSymbolException( l.getName() );
                }
                LinkableContext lc = new LinkableContext( l );
                lmap.put( l.getName(), lc);

                String external = null;
                for (Iterator di = l.getDefinitions(); di.hasNext();)
                {
                    String def = (String) di.next();
					LinkableContext c = defs.get( def );
                    if (c != null)
                    {
                        throw new LinkerException.MultipleDefinitionsException( def, l.getName(), c.l.getName() ); 
                    }
                    defs.put( def, lc );

                    if (extdefs.contains( def ))
                    {
                        external = def;
                    }
                    else if (external != null)
                    {
                         throw new LinkerException.PartialExternsException( lc.l.getName(), def, external );
                    }
                }
            }
        }

        public Set<String> getUnresolved()
        {
            return unresolved;
        }

        public Set getExternal()
        {
            return extdefs;
        }

	    public Set getIncludes()
	    {
	        return includes;
	    }

        public Set<String> getDefNames()
        {
            return defs.keySet();
        }

        public Collection<LinkableContext> getLinkables()
        {
            return lmap.values();
        }

        public Collection<Linkable> getVisitedLinkables()
        {
            return vmap.values();
        }

        Map<String, Linkable> vmap = new HashMap<String, Linkable>();
        Map<String, LinkableContext> lmap = new HashMap<String, LinkableContext>();
        Map<String, LinkableContext> defs = new HashMap<String, LinkableContext>();
        Set extdefs;
	    Set includes;
        Set<String> unresolved;
    }

    /**
     * @param defs     the base definition set to start traversal, if null, link all.
     * @param state      a (mostly opaque) state object that can be used for multiple traversals
     * @param v             the visitor to invoke for each linkable
     * @throws LinkerException
     */
    public static void traverse( List<String> defs, LinkState state, boolean allowExternal, boolean exportIncludes, 
                                 boolean includeInheritanceDependenciesOnly, Visitor<Linkable> v )
            throws LinkerException
    {
        if (defs == null)
        {
            // If we want inheritance dependencies only, skip populating defs with all the non-external names.
            defs = new LinkedList<String>();
            if (!includeInheritanceDependenciesOnly)
            {
                for (Iterator<String> it = state.getDefNames().iterator(); it.hasNext();)
                {
                    String def = it.next();
                    if (!state.getExternal().contains( def ))
                    {
                        defs.add( def );
                    }
                }
            }
        }

	    if (exportIncludes)
	    {
		    for (Iterator iterator = state.getIncludes().iterator(); iterator.hasNext();)
		    {
			    String def = (String)iterator.next();
			    defs.add( def );
		    }
	    }

        Stack<LinkableContext> stack = new Stack<LinkableContext>();           // holds contexts
        LinkedList<LinkableContext> queue = new LinkedList<LinkableContext>(); // holds contexts

        for (Iterator<String> it = defs.iterator(); it.hasNext();)
        {
            String defname = it.next();
            LinkableContext start = resolve( defname, state, allowExternal, exportIncludes, 
                                            includeInheritanceDependenciesOnly);
            if (start == null)
                continue;
            
            queue.add( start );
        }

        while (!queue.isEmpty())
        {
            LinkableContext qc = queue.removeFirst();

            if (qc.visited)
                continue;

            qc.progress = true;
            stack.push( qc );

            while (!stack.isEmpty())
            {
                LinkableContext c = stack.peek();

                if (c.visited)
                {
                    stack.pop();
                    continue;
                }

                if (c.pi.hasNext())
                {
                    LinkableContext prereq = resolve( (String) c.pi.next(), state, 
                                                      allowExternal, 
                                                      exportIncludes, 
                                                      includeInheritanceDependenciesOnly);
                    if (prereq != null)
                    {
                        if (prereq.progress)
                        {
                            throw new LinkerException.CircularReferenceException( c.l.getName() );
                        }
                        if (!prereq.visited)
                        {
                            prereq.progress = true;
                            stack.push( prereq );
                        }
                    }
                    continue;
                }

//                if (c.visited)
//                {
//                    throw new DependencyException( DependencyException.CIRCULAR,
//                                                   c.l.getName(),
//                                                   "prerequisites of " + c.l.getName() + " contain a circular reference" );
//                }


                v.visit( c.l );
                c.visited = true;
                c.progress = false;
                state.vmap.put( c.l.getName(), c.l );
                stack.pop();

                while (c.di.hasNext())
                {
                    LinkableContext dc = resolve( (String) c.di.next(), state, 
                                                   allowExternal, 
                                                   exportIncludes,
                                                   includeInheritanceDependenciesOnly);

                    if ((dc == null) || dc.visited)
                        continue;

                    queue.add( dc );
                }
            }
        }
    }

    static LinkableContext resolve( String name, LinkState state, boolean allowExternal, boolean exportIncludes,
                                    boolean includeInheritianceDependenciesOnly) throws LinkerException
    {
        if (allowExternal && (state.extdefs != null) && state.extdefs.contains( name ))
        {
            state.unresolved.add( name );
            return null;
        }

	    if (! exportIncludes && (state.includes != null) && state.includes.contains( name ))
	    {
		    state.includes.remove(name);
	    }

        LinkableContext lc = state.defs.get( name );

        if (lc == null)
        {
            if (state.unresolved == null)
                throw new LinkerException.UndefinedSymbolException( name );
            else
                state.unresolved.add( name );
        }
        else
        {
            if (lc.l.isNative())
            {
                state.unresolved.add( name );   // natives are always external
                return null;
            }
            if (!allowExternal && state.extdefs.contains( name ))
            {
                state.extdefs.remove( name );   // not external anymore, we had to resolve it.
            }
            lc.activate(includeInheritianceDependenciesOnly);
        }
        return lc;
    }

    public static String dump(  LinkState state )
    {
        StringBuilder buf = new StringBuilder( 2048 );
        buf.append( "<report>\n" );
        buf.append( "  <scripts>\n" );
        for (Iterator<Linkable> scripts = state.getVisitedLinkables().iterator(); scripts.hasNext();)
        {
            CULinkable l = (CULinkable) scripts.next();

            buf.append( "    <script name=\"")
               .append(l.getName())
               .append("\" mod=\"")
               .append(l.getLastModified())
               .append("\" size=\"")
               .append(l.getSize())
               // optimizedsize is often considerably smaller than size
               .append("\" optimizedsize=\"")
               .append(macromedia.abc.Optimizer.optimize(l.getUnit().bytes).size())
               .append("\">\n");
            
            for (Iterator defs = l.getDefinitions(); defs.hasNext();)
            {
                buf.append( "      <def id=\"" + (String) defs.next() + "\" />\n" );
            }
            for (Iterator pre = l.getPrerequisites(); pre.hasNext();)
            {
                buf.append( "      <pre id=\"" + (String) pre.next() + "\" />\n" );
            }
            for (Iterator dep = l.getDependencies(); dep.hasNext();)
            {
                buf.append( "      <dep id=\"" + (String) dep.next() + "\" />\n" );
            }
            buf.append( "    </script>\n" );
        }
        buf.append( "  </scripts>\n" );

        if ((state.getExternal() != null) || (state.getUnresolved() != null))
        {
            buf.append( "  <external-defs>\n");
            for (Iterator external = state.getExternal().iterator(); external.hasNext();)
            {
                String ext = (String) external.next();
                if (!state.getUnresolved().contains( ext ))    // only print exts we actually depended on
                    continue;

                buf.append( "    <ext id=\"" + ext + "\" />\n" );
            }
            for (Iterator<String> unresolved = state.getUnresolved().iterator(); unresolved.hasNext();)
            {
                String unr = unresolved.next();
                if (state.getExternal().contains( unr ))
                    continue;
                buf.append( "    <missing id=\"" + unr + "\" />\n" );
            }
            buf.append( "  </external-defs>\n");
        }

        buf.append( "</report>\n" );

        return buf.toString();
    }

    static private class LinkableContext
    {
        public LinkableContext( Linkable l )
        {
            this.l = l;
        }
        public void activate(boolean includeInheritianceDependenciesOnly)
        {
            if (!active)
            {
                active = true;
                pi = l.getPrerequisites();
                
                if (!includeInheritianceDependenciesOnly)
                    di = l.getDependencies();
                else
                    di = Collections.EMPTY_LIST.iterator();
            }
        }
        public String toString()
        {
            return l.getName() + " " + (visited? "v":"") + (progress? "p":"");
        }
        public final Linkable l;
        public Iterator pi;
        public Iterator di;
        public boolean active = false;
        public boolean visited = false;
        public boolean progress = false;
    }

}
