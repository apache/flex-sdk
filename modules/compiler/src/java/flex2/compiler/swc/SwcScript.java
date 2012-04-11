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

package flex2.compiler.swc;

import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;
import java.util.Iterator;
import java.util.TreeSet;

import flex2.compiler.CompilationUnit;
import flex2.tools.oem.Script;
import flex2.compiler.util.QName;
import flex2.compiler.util.QNameMap;

/**
 * Represents one Script of ABC within a SWC.
 *
 * @author Roger Gonzalez
 */
public class SwcScript
{
    private final SwcLibrary library;
    private final long modtime;
    private final Long signatureChecksum;
    private final Set<String> defs;
    private final String name;
    private final SwcDependencySet deps;
    private Set<String> symbolClasses;
	private CompilationUnit compilationUnit;
    private byte[] abc;

    public SwcScript( SwcLibrary library, String name, Set<String> defs, SwcDependencySet deps, long modtime,
    				Long signatureChecksum )
    {
        this.library = library;
        this.name = name;
        this.defs = defs;
        this.deps = deps;
        this.modtime = modtime;
        this.signatureChecksum = signatureChecksum;
    }

    void setABC(byte[] abc)
    {
        assert abc != null;
        this.abc = abc;
    }

    public byte[] getABC()
    {
        // Need to parse the library in case there is Symbol information in the SWC/SWF
        // that is needed by compilations that reference the definitions from the ABC.
        // Unfortunately this info does not live anywhere else, like in catalog.xml, so we
        // have to parse the SWF to find the information.
        library.parse();
        assert abc != null;

        return abc;
    }

    public SwcLibrary getLibrary()
    {
        return library;
    }

	public String getSwcLocation()
	{
		return library.getSwcLocation();
	}

    public String getName()
    {
        return name;
    }

    public long getLastModified()
    {
        return modtime;
    }

    public Iterator<String> getDefinitionIterator()
    {
        return defs.iterator();
    }

    public SwcDependencySet getDependencySet()
    {
        return deps;
    }

    public CompilationUnit getCompilationUnit()
    {
        return compilationUnit;
    }        
	
	public void setCompilationUnit(CompilationUnit compilationUnit)
	{
        this.compilationUnit = compilationUnit;

        // This lets us avoid parsing the library's SWF for downstream compilations.
        if ((compilationUnit != null) && compilationUnit.isBytecodeAvailable() && (abc == null))
        {
            abc = compilationUnit.getByteCodes();
	}
	}
	
	public Set<String> getSymbolClasses()
	{
		if (symbolClasses == null)
		{
			symbolClasses = new HashSet<String>();
			for (Iterator<String> i = getDefinitionIterator(); i.hasNext(); )
			{
				library.getSymbolClasses(i.next(), symbolClasses);
			}
		}
		
		return symbolClasses;
	}
	
	// C: Only the Flex Compiler API (flex-compiler-oem.jar) uses this method.
	//    Do not use it in the mxmlc/compc codepath.
	public Script toScript(boolean includeBytecodes)
	{
		return new ScriptImpl(this, includeBytecodes);
	}

	/**
	 * 
	 * @return signature checksum of the source script.
	 */
	public Long getSignatureChecksum()
	{
		return signatureChecksum;
	}

    public String toString()
    {
        StringBuilder builder = new StringBuilder(getSwcLocation());
        builder.append("(");

        Iterator<String> iterator = defs.iterator();

        while (iterator.hasNext())
        {
            builder.append(iterator.next());

            if (iterator.hasNext())
            {
                builder.append(", ");
            }
        }

        builder.append(")");

        return builder.toString();
    }
}



class ScriptImpl implements Script
{
	ScriptImpl(SwcScript swcScript, boolean includeBytecodes)
	{
		location = swcScript.getSwcLocation();
		lastModified = swcScript.getLastModified();
		
		Set<String> names = new LinkedHashSet<String>();
		
		for (Iterator<String> i = swcScript.getDefinitionIterator(); i.hasNext(); )
		{
			names.add(i.next());
		}
		
		names.toArray(definitions = new String[names.size()]);

        SwcDependencySet set = swcScript.getDependencySet();

		names = new TreeSet<String>();		

        for (Iterator i = set.getDependencyIterator(SwcDependencySet.INHERITANCE); i != null && i.hasNext();)
        {
        	names.add((String) i.next());
        }

		names.toArray(prerequisites = new String[names.size()]);

		names.clear();
		
        for (Iterator i = set.getDependencyIterator(SwcDependencySet.SIGNATURE); i != null && i.hasNext();)
        {
        	names.add((String) i.next());
        }

		names.toArray(signatures = new String[names.size()]);

		names.clear();

        for (Iterator i = set.getDependencyIterator(SwcDependencySet.NAMESPACE); i != null && i.hasNext();)
        {
        	names.add((String) i.next());
        }

		names.toArray(namespaces = new String[names.size()]);

		names.clear();

        for (Iterator i = set.getDependencyIterator(SwcDependencySet.EXPRESSION); i != null && i.hasNext();)
        {
        	names.add((String) i.next());
        }

        for (Iterator<String> i = swcScript.getSymbolClasses().iterator(); i.hasNext(); )
        {
        	names.add(i.next());
        }
        
		names.toArray(expressions = new String[names.size()]);
		
		if (includeBytecodes)
		{
			bytecodes = swcScript.getABC();
		}
	}

	private String location;
	private long lastModified;
	private String[] definitions, prerequisites, signatures, namespaces, expressions;
	private byte[] bytecodes;
	
	public String[] getDefinitionNames()
	{
		return definitions;
	}

	public String[] getDependencies(Object type)
	{
		if (type == INHERITANCE)
		{
			return prerequisites;
		}
		else if (type == SIGNATURE)
		{
			return signatures;
		}
		else if (type == NAMESPACE)
		{
			return namespaces;
		}
		else if (type == EXPRESSION)
		{
			return expressions;
		}
		else
		{
			return null;
		}
	}

	public long getLastModified()
	{
		return lastModified;
	}

	public String getLocation()
	{
		return location;
	}

	public String[] getPrerequisites()
	{
		return prerequisites;
	}
	
	public byte[] getBytecodes()
	{
		return bytecodes;
	}
}
