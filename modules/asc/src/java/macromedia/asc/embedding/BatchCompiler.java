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

package macromedia.asc.embedding;

import macromedia.abc.AbcParser;
import macromedia.asc.embedding.avmplus.ActionBlockEmitter;
import macromedia.asc.embedding.avmplus.GlobalBuilder;
import macromedia.asc.parser.*;
import macromedia.asc.semantics.*;
import macromedia.asc.util.*;
import macromedia.asc.util.graph.DependencyGraph;
import macromedia.asc.util.graph.Algorithms;
import macromedia.asc.util.graph.Visitor;
import macromedia.asc.util.graph.Vertex;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;
import java.util.ArrayList;
import java.util.List;

/**
 * asc batch compiler
 */
public class BatchCompiler
{
	private static List<File> file;
	private static List<Context> cx;
	private static List<ActionBlockEmitter> emitter;
	private static List<ProgramNode> node;
	private static List<FlowAnalyzer> fa;
	private static Set<Pair> inheritance;
	private static Set<Pair> type;

	private static ContextStatics s;

	public static void main(String[] args) throws Throwable
	{
		long startTime = System.currentTimeMillis();

		init(args);

		int start = 0, end = file.size();

		while (start < end)
		{
			parse(start, end);
			fa_part1(start, end);
			resolveInheritance(start, end);

			start = end;
			end = file.size();

			if (start < end) continue;

			sortInheritance();
			fa_part2();
			resolveType();

			start = end;
			end = file.size();

			if (start < end) continue;

			importType();
			ce();
			cg();

			// In theory, this should be in a second compile loop in order to reduce memory usage.
			resolveExpression();

			start = end;
			end = file.size();
		}

		clear();

		System.err.println("Files: " + file.size() + " Time: " + (System.currentTimeMillis() - startTime) + "ms");
	}

	private static void init(String[] args) throws Throwable
	{
		TypeValue.init();
		ObjectValue.init();
		s = new ContextStatics();
		//s.use_namespaces.addAll(null) // no automatic use_namespaces
		//s.es4_numerics = ...

		file = new ArrayList<File>(args.length);
		for (int i = 0, length = args.length; i < length; i++)
		{
			File f = new File(args[i]);
			if (f.exists() && f.isFile())
			{
				file.add(f.getCanonicalFile());
			}
		}

		cx = new ArrayList<Context>(file.size());
		for (int i = 0, length = file.size(); i < length; i++)
		{
			cx.add(new Context(s));
		}

		emitter = new ArrayList<ActionBlockEmitter>(file.size());
		for (int i = 0, length = file.size(); i < length; i++)
		{
			emitter.add(new ActionBlockEmitter(cx.get(i), file.get(i).getPath(), new StringPrintWriter(), new StringPrintWriter(), false, false, false, false));
		}

		node = new ArrayList<ProgramNode>(file.size());
		fa = new ArrayList<FlowAnalyzer>(file.size());
		inheritance = new HashSet<Pair>();
		type = new HashSet<Pair>();
	}

	private static void parse(int start, int end) throws Throwable
	{
		for (int i = start; i < end; i++)
		{
			cx.get(i).setEmitter(emitter.get(i));
			cx.get(i).setScriptName(file.get(i).getName());
			cx.get(i).setPath(file.get(i).getParent());

			if (file.get(i).getName().endsWith(".as"))
			{
				node.add(new Parser(cx.get(i), new FileInputStream(file.get(i)), file.get(i).getPath(), null).parseProgram());
			}
			else
			{
				node.add(new AbcParser(cx.get(i), file.get(i).getPath()).parseAbc());
			}

			cx.get(i).getNodeFactory().pkg_defs.clear();
		}
	}

	private static void fa_part1(int start, int end)
	{
		for (int i = start; i < end; i++)
		{
			if (cx.get(i).errorCount() == 0 && node.get(i).state == ProgramNode.Inheritance)
			{
				cx.get(i).pushScope(new ObjectValue(cx.get(i), new GlobalBuilder(), null));
				FlowGraphEmitter fgEmitter = new FlowGraphEmitter(cx.get(i), file.get(i).getPath(), false);
				fa.add(new FlowAnalyzer(fgEmitter));
				node.get(i).evaluate(cx.get(i), fa.get(i));
				cx.get(i).popScope();
			}
		}
	}

	private static void resolveInheritance(int start, int end) throws Throwable
	{
		for (int i = start; i < end; i++)
		{
			for (Iterator<ReferenceValue> k = node.get(i).fa_unresolved.iterator(); k.hasNext();)
			{
				ReferenceValue ref = k.next();
				boolean found = false;
				for (int j = 0, size = (ref.getImmutableNamespaces() != null) ? ref.getImmutableNamespaces().size() : 0; j < size; j++)
				{
					QName qname = new QName(ref.getImmutableNamespaces().get(j), ref.name);
					int where = findClass(qname);
					if (where != -1)
					{
						if (i != where)
						{
							Pair p = new Pair(i, where);
							if (!inheritance.contains(p))
							{
								inheritance.add(p);
							}
						}
						found = true;
						break;
					}
				}
				if (!found)
				{
					System.err.println(ref.toMultiName() + " in " + file.get(i) + " not resolved");
				}
			}

			node.get(i).fa_unresolved.clear();
		}
	}

	private static void sortInheritance() throws Throwable
	{
		for (Iterator<Pair> i = inheritance.iterator(); i.hasNext();)
		{
			Pair p = i.next();
			if (!p.processed)
			{
				fa.get(p.i).inheritSlots(node.get(p.where).frame, node.get(p.i).frame, node.get(p.i).frame.builder, cx.get(p.i));
				p.processed = true;
			}
		}

		final DependencyGraph<Integer> g = new DependencyGraph<Integer>();

		for (int i = 0, length = node.size(); i < length; i++)
		{
			String path = file.get(i).getPath();
			g.put(path, i);

			if (!g.containsVertex(path))
			{
				g.addVertex(new Vertex<String>(path));
			}

			for (Iterator<Pair> j = inheritance.iterator(); j.hasNext();)
			{
				Pair p = j.next();
				if (p.i == i)
				{
					g.addDependency(path, file.get(p.where).getPath());
				}
			}
		}

		final List<Integer> tsort = new ArrayList<Integer>(node.size());

		Algorithms.topologicalSort(g, new Visitor<String>()
		{
			public void visit(Vertex<String> v)
			{
				String name = v.getWeight();
				tsort.add(g.get(name));
			}
		});

		if (node.size() > tsort.size())
		{
			for (int i = 0, length = node.size(); i < length; i++)
			{
				int j = 0;
				for (; j < tsort.size(); j++)
				{
					if (tsort.get(j) == i)
					{
						break;
					}
				}
				if (j == tsort.size())
				{
					String path = file.get(i).getPath();
					System.out.println(path + " in circular reference");
				}
			}
		}
		else
		{
			List<File> tempFile = new ArrayList<File>(file.size());
			List<Context> tempCX = new ArrayList<Context>(cx.size());
			List<ActionBlockEmitter> tempEmitter = new ArrayList<ActionBlockEmitter>(emitter.size());
			List<ProgramNode> tempNode = new ArrayList<ProgramNode>(node.size());
			List<FlowAnalyzer> tempFA = new ArrayList<FlowAnalyzer>(fa.size());

			for (int i = 0, length = tsort.size(); i < length; i++)
			{
				int loc = tsort.get(i);

				tempFile.add(file.get(loc));
				tempCX.add(cx.get(loc));
				tempEmitter.add(emitter.get(loc));
				tempNode.add(node.get(loc));
				tempFA.add(fa.get(loc));
			}

			file = tempFile;
			cx = tempCX;
			emitter = tempEmitter;
			node = tempNode;
			fa = tempFA;

			for (Iterator<Pair> i = type.iterator(); i.hasNext();)
			{
				Pair p = i.next();
				for (int j = 0, length = tsort.size(); j < length; j++)
				{
					if (tsort.get(j) == p.i)
					{
						p.i = j;
						break;
					}
				}
				for (int j = 0, length = tsort.size(); j < length; j++)
				{
					if (tsort.get(j) == p.where)
					{
						p.where = j;
						break;
					}
				}
			}

			for (Iterator<Pair> i = inheritance.iterator(); i.hasNext();)
			{
				Pair p = i.next();
				for (int j = 0, length = tsort.size(); j < length; j++)
				{
					if (tsort.get(j) == p.i)
					{
						p.i = j;
						break;
					}
				}
				for (int j = 0, length = tsort.size(); j < length; j++)
				{
					if (tsort.get(j) == p.where)
					{
						p.where = j;
						break;
					}
				}
			}
		}
	}

	private static void fa_part2()
	{
		for (int i = 0, length = file.size(); i < length; i++)
		{
			if (cx.get(i).errorCount() == 0 && node.get(i).state == ProgramNode.Else)
			{
				cx.get(i).pushScope(node.get(i).frame);
				node.get(i).evaluate(cx.get(i), fa.get(i));
				cx.get(i).popScope();
			}
		}
	}

	private static void resolveType() throws Throwable
	{
		for (int i = 0, length = node.size(); i < length; i++)
		{
			for (Iterator<ReferenceValue> k = node.get(i).ce_unresolved.iterator(); k.hasNext();)
			{
				ReferenceValue ref = k.next();
				boolean found = false;
				for (int j = 0, size = (ref.getImmutableNamespaces() != null) ? ref.getImmutableNamespaces().size() : 0; j < size; j++)
				{
					QName qname = new QName(ref.getImmutableNamespaces().get(j), ref.name);
					int where = findClass(qname);
					if (where != -1)
					{
						if (i != where)
						{
							Pair p = new Pair(i, where);
							if (!type.contains(p))
							{
								type.add(p);
							}
						}
						found = true;
						break;
					}
				}
				if (!found)
				{
					System.err.println(ref.toMultiName() + " in " + file.get(i) + " not resolved");
				}
			}

			node.get(i).ce_unresolved.clear();
		}

		for (int i = 0, length = node.size(); i < length; i++)
		{
			for (Iterator<ReferenceValue> k = node.get(i).body_unresolved.iterator(); k.hasNext();)
			{
				ReferenceValue ref = k.next();
				boolean found = false;
				for (int j = 0, size = (ref.getImmutableNamespaces() != null) ? ref.getImmutableNamespaces().size() : 0; j < size; j++)
				{
					QName qname = new QName(ref.getImmutableNamespaces().get(j), ref.name);
					int where = findClass(qname);
					if (where != -1)
					{
						if (i != where)
						{
							Pair p = new Pair(i, where);
							if (!type.contains(p))
							{
								type.add(p);
							}
						}
						found = true;
						break;
					}
				}
				if (!found)
				{
					System.err.println(ref.toMultiName() + " in " + file.get(i) + " not resolved");
				}
			}

			node.get(i).body_unresolved.clear();
		}

		for (int i = 0, length = node.size(); i < length; i++)
		{
			for (Iterator<ReferenceValue> k = node.get(i).ns_unresolved.iterator(); k.hasNext();)
			{
				ReferenceValue ref = k.next();
				boolean found = false;
				for (int j = 0, size = (ref.getImmutableNamespaces() != null) ? ref.getImmutableNamespaces().size() : 0; j < size; j++)
				{
					QName qname = new QName(ref.getImmutableNamespaces().get(j), ref.name);
					int where = findDefinition(qname);
					if (where != -1)
					{
						if (i != where)
						{
							Pair p = new Pair(i, where);
							if (!type.contains(p))
							{
								type.add(p);
							}
						}
						found = true;
						break;
					}
				}
				if (!found)
				{
					System.err.println(ref.toMultiName() + " in " + file.get(i) + " not resolved");
				}
			}

			node.get(i).ns_unresolved.clear();
		}
	}

	private static void importType() throws Throwable
	{
		for (Iterator<Pair> i = type.iterator(); i.hasNext();)
		{
			Pair p = i.next();
			if (!p.processed)
			{
				if (!inheritance.contains(p))
				{
					fa.get(p.i).inheritSlots(node.get(p.where).frame, node.get(p.i).frame, node.get(p.i).frame.builder, cx.get(p.i));
				}
				p.processed = true;
			}
		}
	}

	private static void ce()
	{
		for (int i = 0, length = file.size(); i < length; i++)
		{
			if (cx.get(i).errorCount() == 0 && file.get(i).getName().endsWith(".as") && emitter.get(i) != null)
			{
				cx.get(i).pushScope(node.get(i).frame);
				ConstantEvaluator analyzer = new ConstantEvaluator(cx.get(i));
				node.get(i).evaluate(cx.get(i), analyzer);
				cx.get(i).popScope();
			}
		}
	}

	private static void cg() throws Throwable
	{
		for (int i = 0, length = file.size(); i < length; i++)
		{
			if (cx.get(i).errorCount() == 0 && file.get(i).getName().endsWith(".as") && emitter.get(i) != null)
			{
				cx.get(i).setEmitter(emitter.get(i));
				cx.get(i).pushScope(node.get(i).frame);
				CodeGenerator generator = new CodeGenerator(cx.get(i).getEmitter());
				node.get(i).evaluate(cx.get(i), generator);

				ByteList bytes = new ByteList();
				cx.get(i).getEmitter().emit(bytes);
				// String str = ((ActionBlockEmitter) cx.get(i).getEmitter()).il_str();
				emitter.set(i, null);
				FileOutputStream out = new FileOutputStream(new File(file.get(i).getParentFile(), file.get(i).getName().substring(0, file.get(i).getName().length() - "as".length()) + "abc"));
				System.err.println(file.get(i).getName() + ": " + bytes.size());
				out.write(bytes.toByteArray());
				out.flush();
				out.close();

				/*
				FileWriter fout = new FileWriter(new File(file.get(i).getParentFile(), file.get(i).getName().substring(0, file.get(i).getName().length() - "as".length()) + "il"));
				fout.write(str);
				fout.flush();
				fout.close();
                */

				cx.get(i).popScope();
			}
		}
	}

	private static void resolveExpression() throws Throwable
	{
		for (int i = 0, length = node.size(); i < length; i++)
		{
			for (Iterator<ReferenceValue> k = node.get(i).rt_unresolved.iterator(); k.hasNext();)
			{
				ReferenceValue ref = k.next();
				boolean found = false;
				for (int j = 0, size = (ref.getImmutableNamespaces() != null) ? ref.getImmutableNamespaces().size() : 0; j < size; j++)
				{
					QName qname = new QName(ref.getImmutableNamespaces().get(j), ref.name);
					if (qname.ns instanceof UnresolvedNamespace && ((UnresolvedNamespace) qname.ns).resolved)
					{
						found = true;
						break;
					}
					int where = findDefinition(qname);
					if (where != -1)
					{
						found = true;
						break;
					}
				}
				if (!found)
				{
					System.err.println(ref.toMultiName() + " in " + file.get(i) + " not resolved");
				}
			}

			node.get(i).rt_unresolved.clear();
		}
	}

	private static void clear()
	{
		s.clear();

		ObjectValue.clear();
		TypeValue.clear();
	}

	private static int findDefinition(QName defName) throws Throwable
	{
		for (int i = 0, length = node.size(); i < length; i++)
		{
			Names names = node.get(i).frame.builder.getNames();
			for (int j = 0; j < 4; j++)
			{
				if (names.containsKey(defName.name, defName.ns, j))
				{
					return i;
				}
			}
		}

		return searchClasspath(defName);
	}

	private static int findClass(QName className) throws Throwable
	{
		for (int i = 0, length = node.size(); i < length; i++)
		{
			for (int j = 0, size = (node.get(i).clsdefs != null) ? node.get(i).clsdefs.size() : 0; j < size; j++)
			{
				ClassDefinitionNode clsdef = node.get(i).clsdefs.get(j);
				if (clsdef.cframe.builder.classname.equals(className))
				{
					return i;
				}
			}
		}

		return searchClasspath(className);
	}

	private static int searchClasspath(QName qname) throws Throwable
	{
		String path = qname.ns.name.replace('.', File.separatorChar) + File.separatorChar + qname.name;
		File f = new File(path + ".as");
		if (f.exists() && f.isFile())
		{
			f = f.getCanonicalFile();
			Context context = new Context(s);

			int where = file.indexOf(f);
			if (where == -1)
			{
				file.add(f);
				cx.add(context);
				emitter.add(new ActionBlockEmitter(context, f.getPath(), new StringPrintWriter(), new StringPrintWriter(), false, false, false, false));
				where = file.size() - 1;
			}
			return where;
		}

		return -1;
	}

	static class Pair
	{
		Pair(int i, int where)
		{
			this.i = i;
			this.where = where;
			processed = false;
		}

		int i, where;
		boolean processed;

		public boolean equals(Object obj)
		{
			if (obj instanceof Pair)
			{
				return i == ((Pair) obj).i && where == ((Pair) obj).where;
			}
			else
			{
				return false;
			}
		}

		public int hashCode()
		{
			return (((1 * 17) + i) * 17) + where;
		}
	}
}
