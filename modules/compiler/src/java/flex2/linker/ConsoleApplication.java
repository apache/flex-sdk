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

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import flex2.compiler.CompilationUnit;
import flex2.compiler.Source;
import flex2.compiler.util.Name;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.compiler.util.graph.Algorithms;
import flex2.compiler.util.graph.DependencyGraph;
import flex2.compiler.util.graph.Vertex;
import flex2.compiler.util.graph.Visitor;

/**
 * The equivalent of FlexMovie when building a projector, ie a .exe.
 *
 * @author Clement Wong
 */
public class ConsoleApplication
{
	public ConsoleApplication(LinkerConfiguration linkerConfiguration)
	{		
		abcList = new ArrayList<byte[]>();
		enableDebugger = linkerConfiguration.debug();
		exportedUnits = new LinkedList<CompilationUnit>();
	}
	
	private List<byte[]> abcList;
	private byte[] main;
	public final boolean enableDebugger;
	private List<CompilationUnit> exportedUnits;
	
	public List<byte[]> getABCs()
	{
		return abcList;
	}
	
	public void generate(List<CompilationUnit> units) throws LinkerException
	{		
		// create a dependency graph based on source file dependencies...
        final DependencyGraph<CompilationUnit> dependencies = extractCompilationUnitInfo(units);
        exportDependencies(dependencies);

        if (ThreadLocalToolkit.errorCount() > 0)
        {
  			throw new LinkerException.LinkingFailed();
        }
	}

    private DependencyGraph<CompilationUnit> extractCompilationUnitInfo(List<CompilationUnit> units)
    {
        final DependencyGraph<CompilationUnit> dependencies = new DependencyGraph<CompilationUnit>();
		final Map<QName, String> qnames = new HashMap<QName, String>(); // QName, VirtualFile.getName()

        for (int i = 0, length = units.size(); i < length; i++)
        {
            CompilationUnit u = units.get(i);
            Source s = u.getSource();
            String path = s.getName();

            dependencies.put(path, u);
			if (!dependencies.containsVertex(s.getName()))
			{
				dependencies.addVertex(new Vertex<String,CompilationUnit>(path));
			}
				
			// register QName --> VirtualFile.getName()
			for (Iterator<QName> j = u.topLevelDefinitions.iterator(); j.hasNext();)
			{
				qnames.put(j.next(), s.getName());
			}
        }

		// setup inheritance-based dependencies...
		for (int i = 0, size = units.size(); i < size; i++)
		{
            CompilationUnit u = units.get(i);
            Source s = u.getSource();
            String head = s.getName();

			for (Name name : u.inheritance)
			{
				if (name instanceof QName)
				{
					QName qname = (QName) name;
					String tail = qnames.get(qname);

					if (tail != null && !head.equals(tail) && !dependencies.dependencyExists(head, tail))
					{
						dependencies.addDependency(head, tail);
					}
				}
			}
		}

        return dependencies;
    }

	private void exportDependencies(final DependencyGraph<CompilationUnit> dependencies)
	{
		// export compilation units
		Algorithms.topologicalSort(dependencies, new Visitor<Vertex<String,CompilationUnit>>()
		{
			public void visit(Vertex<String,CompilationUnit> v)
			{
				String fileName = v.getWeight();
				CompilationUnit u = dependencies.get(fileName);
				if (!u.getSource().isInternal())
				{
					if (u.isRoot())
					{
						main = u.getByteCodes();
					}
					else
					{
						abcList.add(u.getByteCodes());
					}
					exportedUnits.add(u);
				}
			}
		});
		
		abcList.add(main);
	}
	
    public List<CompilationUnit> getExportedUnits()
    {
        return exportedUnits;
    }
}
