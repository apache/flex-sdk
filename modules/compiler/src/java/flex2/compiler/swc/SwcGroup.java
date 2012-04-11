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

import flash.util.Trace;
import flex2.compiler.CompilationUnit;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.NameMappings;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;

import java.util.*;

/**
 * SwcGroup returns information about a set of SWCs returned from
 * SwcCache. This grouping is used instead of a List of SWCs because
 * it allows us to precompute certain information about the view, like
 * name mappings.
 * 
 * @author Brian Deitte
 */
public class SwcGroup
{
	// map of Swcs in this group
	private Map<String, Swc> swcs;

	// The RSLs that are included in this group.
    private SwcGroup rslGroup;
    
	// used to determine a component's name
	private NameMappings nameMappings = new NameMappings();

	// list of files in file section of catalogs
	private Map<String, VirtualFile> files = new HashMap<String, VirtualFile>();

	private Set<QName> qnames;

	private Map<String, SwcScript> def2script;

    private Map<SwcScript, String> obsoleted = new HashMap<SwcScript, String>();

	// use SwcCache.getSwcGroup() to get a SwcGroup
	SwcGroup(Map<String, Swc> swcs)
	{
		this.swcs = swcs;
		this.rslGroup = null;
		updateNameMappings();
		updateFiles();
		updateMaps();
	}

	/**
	 * Create a swc group and specify the RSLs that are in the group.
	 * 
	 * @param swcs
	 * @param rslGroup The RSLs that are included in this group.
	 */
    SwcGroup(Map<String, Swc> swcs, SwcGroup rslGroup)
    {
        this.swcs = swcs;
        this.rslGroup = rslGroup;
        updateNameMappings();
        updateFiles();
        updateMaps();
    }

    public int getNumberLoaded()
	{
		return swcs.size();
	}

	/**
	 * Returns a NameMapping class which can be used to determine a component's
	 * name.
	 */
	public NameMappings getNameMappings()
	{
		return nameMappings;
	}

	public Map<String, SwcScript> getScriptMap()
	{
		return def2script;
	}

	public Set<QName> getQNames()
	{
		return qnames;
	}

	public Map<String, VirtualFile> getFiles()
	{
		return files;
	}

	/**
	 * Returns a file in a specific SWC. This should only be used for files
	 * already resolved by getFiles().
	 */
	public VirtualFile getFile(String name)
	{
		VirtualFile swcFile = null;
		String location = SwcFile.getSwcLocation(name);
		String fileName = SwcFile.getFilePath(name);
		if (location != null && fileName != null)
		{
			Swc swc = swcs.get(location);
			if (swc != null)
			{
				swcFile = swc.getFile(fileName);
			}
		}
		return swcFile;
	}

	/**
	 * Get an individual swc from this group.
	 * 
	 * @param name -
	 *            name of the swc's virtual filename, may not be null.
	 * @return Swc - the swc in the group or null if the swc is not found.
	 * @throws NullPointerException -
	 *             if name is null
	 */
	public Swc getSwc(String name)
	{
		if (name == null)
		{
			throw new NullPointerException("getSwc: name may not be null");
		}

		return swcs.get(name);
	}

	public Map<String, Swc> getSwcs()
	{
		return swcs;
	}

	public List<Long> getSwcTimes()
	{
		List<Long> lastModified = new ArrayList<Long>();

		for (Iterator<Swc> iterator = swcs.values().iterator(); iterator.hasNext();)
		{
			Swc swc = iterator.next();
			lastModified.add(new Long(swc.getLastModified()));
		}

		return lastModified;
	}

    public Map<SwcScript, String> getObsoleted()
    {
        return obsoleted;
    }

	public void close()
	{
		for (Iterator<Swc> iterator = swcs.values().iterator(); iterator.hasNext();)
		{
			Swc swc = iterator.next();
			swc.close();
		}
	}

	private void updateNameMappings()
	{
		for (Iterator<Swc> iter = swcs.values().iterator(); iter.hasNext();)
		{
			Swc swc = iter.next();
			Iterator iter2 = swc.getComponentIterator();
			while (iter2.hasNext())
			{
				SwcComponent component = (SwcComponent) iter2.next();
				String namespaceURI = component.getUri();
				String name = component.getName();

				if (namespaceURI == null) continue;
				
				if ("".equals(namespaceURI))
				{
					if (name != null)
					{
						SwcException e = new SwcException.EmptyNamespace(name);
						ThreadLocalToolkit.log(e);
						throw e;
					}
					continue;
				}
				String className = component.getClassName();
				if (name == null)
				{
					name = NameFormatter.retrieveClassName(className);
				}

				boolean success = nameMappings.addClass(namespaceURI, name,
						className);
				if (!success)
				{
					SwcException e = new SwcException.ComponentDefinedTwice(
							name, className, nameMappings.lookupClassName(
									namespaceURI, name));
					ThreadLocalToolkit.log(e);
					throw e;
				}
			}
		}
	}

	private void updateFiles()
	{
		for (Iterator<Swc> iterator = swcs.values().iterator(); iterator.hasNext();)
		{
			Swc swc = iterator.next();
            Map<String, VirtualFile> catalogFiles = swc.getCatalogFiles();

            if (catalogFiles != null)
			{
                for (VirtualFile file : catalogFiles.values())
                {
                    String name = file.getName();
                    String swcName = SwcFile.getFilePath(name);
                    if (swcName != null)
                    {
                        name = swcName;
                    }
                    VirtualFile curFile = files.get(name);
                    if (curFile == null || file.getLastModified() > curFile.getLastModified())
                    {
                        files.put(name, file);
                    }
                }
            }
        }
	}

	private void updateMaps()
	{
		// Given a set of SWCs, we need to build a map from each top-level
		// definition back to scripts.

		ArrayList<SwcScript> scriptList = new ArrayList<SwcScript>();

		for (Iterator<Swc> swcit = swcs.values().iterator(); swcit.hasNext();)
		{
			Swc swc = swcit.next();

			for (Iterator libit = swc.getLibraryIterator(); libit.hasNext();)
			{
				SwcLibrary lib = (SwcLibrary) libit.next();

				for (Iterator scriptit = lib.getScriptIterator(); scriptit.hasNext();)
				{
					SwcScript script = (SwcScript) scriptit.next();
					scriptList.add(script);
				}
			}
		}

		SwcScript[] scriptArray = scriptList.toArray(new SwcScript[scriptList.size()]);

		Arrays.sort(scriptArray, new Comparator<SwcScript>()
		{
			public int compare(SwcScript swcScript1, SwcScript swcScript2)
			{
				long swcScript1mod = (swcScript1).getLastModified();
				long swcScript2mod = (swcScript2).getLastModified();

				if (swcScript1mod == swcScript2mod)
				{
                    // Prefer scripts that come from rsls. This is important for
                    // the remove-unused-rsls feature because we look at the 
                    // swc where a script came from to determine if the rsl was 
                    // used.
                    if (rslGroup != null)
                    {
                        boolean script1IsInRsl = rslGroup.getSwcs().containsKey(swcScript1.getSwcLocation());
                        boolean script2IsInRsl = rslGroup.getSwcs().containsKey(swcScript2.getSwcLocation());

                        if (script1IsInRsl && !script2IsInRsl)
                        {
                            return -1;
                        }
                        else if (!script1IsInRsl && script2IsInRsl)
                        {
                            return 1;
                        }
                    }
                    
                    // Favor SwcScript's with a cached CompilationUnit
                    CompilationUnit swcScript1CompilationUnit = swcScript1.getCompilationUnit();
                    CompilationUnit swcScript2CompilationUnit = swcScript2.getCompilationUnit();

                    if (swcScript1CompilationUnit != null)
                    {
                        if (swcScript1CompilationUnit.hasTypeInfo)
                        {
                            return -1;
                        }
                    }
                    else if (swcScript2CompilationUnit != null)
                    {
                        if (swcScript2CompilationUnit.hasTypeInfo)
                        {
                            return 1;
                        }
                    }

					return 0;
				}
                else if (swcScript1mod < swcScript2mod)
				{
					return 1;
				}
                else
				{
					return -1;
				}
			}
		});

		def2script = new HashMap<String, SwcScript>();
		qnames = new HashSet<QName>();
		for (int i = 0; i < scriptArray.length; i++)
		{
			SwcScript s = scriptArray[i];
			String name = s.getName();
			HashMap<String, SwcScript> staging = new HashMap<String, SwcScript>();
			for (Iterator defit = s.getDefinitionIterator(); defit.hasNext();)
			{
				String def = (String) defit.next();
				staging.put(def, s);
                SwcScript newerSwcScript = def2script.get(def);

				if (newerSwcScript != null)
				{
                    // already have a newer definition, this script is obsolete.
                    staging = null;

                    CompilationUnit compilationUnit = s.getCompilationUnit();

                    if (compilationUnit != null)
                    {
                        CompilationUnit newerCompilationUnit = newerSwcScript.getCompilationUnit();

                        if (newerCompilationUnit != null)
                        {
                            if ((newerCompilationUnit != null) &&
                                (compilationUnit.typeInfo != newerCompilationUnit.typeInfo))
                            {
                                obsoleted.put(s, newerSwcScript.getLibrary().getSwcLocation());
                                break;
                            }
                        }
                    }
                    break;
				}
			}

			if (staging != null)
			{
				for (Map.Entry<String, SwcScript> entry : staging.entrySet())
				{
					String def = entry.getKey();

					qnames.add(new QName(def));
					def2script.put(def, entry.getValue());

					if (Trace.swc)
					{
						Trace.trace("Using " + def + " from " + s);
					}
				}
			}
		}
	}

}
 
