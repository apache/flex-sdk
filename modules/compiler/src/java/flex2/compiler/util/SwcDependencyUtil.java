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

package flex2.compiler.util;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import flash.localization.LocalizationManager;
import flex2.compiler.CompilerSwcContext;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.swc.Digest;
import flex2.compiler.swc.Swc;
import flex2.compiler.swc.SwcCache;
import flex2.compiler.swc.SwcDependencySet;
import flex2.compiler.swc.SwcGroup;
import flex2.compiler.swc.SwcLibrary;
import flex2.compiler.swc.SwcScript;
import flex2.compiler.util.graph.Vertex;

/**
 * Utility to find the dependency between a given set of SWCs.
 * 
 * @author dloverin
 */
public class SwcDependencyUtil
{
    /**
     * Get the dependency information on a given set of SWCs.
     * 
     * @param swcs The set of SWCs to find the dependency information for. Each
     * VirtualFile in the list must be a SWC or a directory of SWCs.
     * @param scriptDependencyTypes - Set of script dependency types that are checked. 
     * This allows a caller to only look at the dependencies between the set of SWCs
     * based only on inheritance for example. If null, all dependency types are checked.
     * The set of dependency types can be one or more of the following:
     * <ul>
     * <li>SwcDependencySet.INHERITANCE</li>
     * <li>SwcDependencySet.NAMESPACE</li>
     * <li>SwcDependencySet.SIGNATURE</li>
     * <li>SwcDependencySet.EXPRESSION</li>
     * </ul>
     * 
     * @param minimizeDependencySet Removes a SWC from the dependency set if the scripts 
     * resolved in a SWC are a subset of the scripts resolved in another dependent SWC.
     * 
     * @return SwcDependencyInfo The returned class can be queried to find the dependency
     * order among the SWCs. One can also query further to find what scripts are causing the
     * dependencies. 
     */
    public static SwcDependencyInfo getSwcDependencyInfo(VirtualFile[] swcs, 
                                                         String[] dependencyTypesArray,
                                                         boolean minimizeDependencySet)
    {
        Set<String> scriptDependencyTypes = dependencyTypesArray != null ? 
                                            new HashSet<String>(Arrays.asList(dependencyTypesArray)) : null;
        SwcCache cache = new SwcCache();
        SwcGroup swcGroup = cache.getSwcGroup(swcs);
        cache.setLazyRead(true);
        SwcDependencyInfoImpl depInfo = new SwcDependencyInfoImpl();        // return value
        
        // map of swcLocations to a map of script names to the scripts
        Map<String, Map<String, SwcScript>> swcDefMap = new HashMap<String, Map<String, SwcScript>>(swcGroup.getNumberLoaded());
        
        // map of swcLocations to the external scripts in the swc and where they can be resolved
        Map<String, SwcExternalScriptInfoImpl> swcExternMap = new HashMap<String, SwcExternalScriptInfoImpl>(swcGroup.getNumberLoaded());
        
        // for all the swcs
        for (Entry<String,Swc> swcEntry : swcGroup.getSwcs().entrySet())
        {
            if (swcDefMap.get(swcEntry.getValue().getLocation()) != null)
                continue;   // already looked at this one
            
            HashMap<String, SwcScript> defMap = new HashMap<String, SwcScript>();
            //HashMap<String, SwcExternalScriptInfo> externMap = new HashMap<String, SwcExternalScriptInfo>();
            String swcLocation = swcEntry.getValue().getLocation();
            SwcExternalScriptInfoImpl externalScripts = new SwcExternalScriptInfoImpl(swcLocation);
            
            swcDefMap.put(swcLocation, defMap);
            swcExternMap.put(swcLocation, externalScripts);
            depInfo.addSwcExternals(swcLocation, externalScripts);

            // for all the libraries in a swc to find external scripts
            for (Iterator<SwcLibrary> swcLibraryIter = swcEntry.getValue().getLibraryIterator();
                 swcLibraryIter.hasNext();)
            {
                SwcLibrary swcLibrary = (SwcLibrary)swcLibraryIter.next();
                
                // loop thru the script in a library and build the list of definitions
                for (Iterator<SwcScript> scriptIter = swcLibrary.getScriptIterator(); 
                     scriptIter.hasNext();)
                {
                    SwcScript swcScript = (SwcScript)scriptIter.next();

                    for (Iterator<String> defIter = swcScript.getDefinitionIterator(); defIter.hasNext();)
                    {
                        String definition = (String)defIter.next();
                        defMap.put(definition, swcScript);
                    }
                }

                // loop thru the script in a library again and look for external definitions
                for (Iterator<SwcScript> scriptIter = swcLibrary.getScriptIterator(); 
                     scriptIter.hasNext();)
                {
                    SwcScript swcScript = (SwcScript)scriptIter.next();

                    for (Iterator<String> typeIter = swcScript.getDependencySet().getTypeIterator(); 
                             typeIter.hasNext();)
                    {
                        String type = (String)typeIter.next();
                         
                        // filter the list of dependency types we care about.
                        if (scriptDependencyTypes != null)
                        {
                            if (!scriptDependencyTypes.contains(type))
                                continue;
                        }
                        
                        // loop thru the dependencies of each script
                        for (Iterator<String> scriptDepIter = swcScript.getDependencySet().getDependencyIterator(type);
                             scriptDepIter.hasNext();)
                        {
                            String scriptDep = (String)scriptDepIter.next();
                            
                            // does the script definition live in its own swc?
                            SwcScript dependentScript = defMap.get(scriptDep);
                            
                            if (dependentScript == null)
                            {
                                // keep a list of all externals
                                //System.out.println(swcEntry.getValue().getLocation() + " has external " + scriptDep);
                                externalScripts.addScriptDependencyType(scriptDep, type);
                            }
                        }
                    }
                }
            }
        }
        
        Map<String, Set<String>> dependencyMap = null;
        
        if (minimizeDependencySet)
            dependencyMap = new HashMap<String, Set<String>>(swcGroup.getNumberLoaded());
        
        // for each swc try to resolve its externals in other swcs. 
        // Each external can be found in more than one swcs. A dependency could this swc A OR swc B.
        for (Map.Entry<String, SwcExternalScriptInfoImpl> swcExternEntry : swcExternMap.entrySet())
        {
            String swcLocation = swcExternEntry.getKey();
            SwcExternalScriptInfoImpl externalInfo = swcExternEntry.getValue();
            Set<String> dependencyList = null; 
            if (minimizeDependencySet)
            {
                dependencyList = dependencyMap.get(swcLocation);
                if (dependencyList == null)
                {
                    dependencyList = new HashSet<String>();
                    dependencyMap.put(swcLocation, dependencyList);
                }
                
            }

            for (String externName : externalInfo.getExternalScripts())
            {
                // for each extern, look in other swcs until we find the entry.
                // look in all the swcs, so we know all the dependencies
                List<SwcScript> resolvingSwcs = new ArrayList<SwcScript>(); 
                for (Map.Entry<String, Map<String, SwcScript>> swcDefEntry : swcDefMap.entrySet())
                {
                    String swcLocation2 = swcDefEntry.getKey();
                    if (swcLocation2.equals(swcLocation))
                        continue; // skip checking our own definition list

                    Map<String, SwcScript> externMap2 = swcDefEntry.getValue();
                    SwcScript script = externMap2.get(externName); 
                    if (script != null)
                    {
                        // If we want a minimum set, then just record the dependency,
                        // later we will prune out subsets and add dependencies
                        // in depInfo. Otherwise just record the dependency now.
                        if (minimizeDependencySet)
                        {
                            resolvingSwcs.add(script);
                        }
                        else
                        {
                            //System.out.println("Add dependency from " + swcLocation + " to " + swcLocation2); 
                            depInfo.addDependency(swcLocation, swcLocation2);

                            //System.out.println("External " + externName + " in " + swcLocation + " resolved in " + swcLocation2);
                            externalInfo.addResolvingSwc(externName, swcLocation2);
                        }
                        
                    }
                }

                if (minimizeDependencySet)
                {
                	SwcScript externalScript = null;
                	if (resolvingSwcs.size() > 1) 
                	{
                		// chose the swc that will provide us with the original 
                		// source of the swc, not the swc that the script was 
                		// copied from.
                		externalScript = getOriginalSwc(resolvingSwcs);
                	}
                	else if (resolvingSwcs.size() > 0)
                	{
                		externalScript = resolvingSwcs.get(0);
                	}
                	
                	if (externalScript != null)
                	{
                		String swcLocation2 = externalScript.getSwcLocation(); 
                		dependencyList.add(swcLocation2);

                		//System.out.println("External " + externName + " in " + swcLocation + " resolved in " + swcLocation2);
                		externalInfo.addResolvingSwc(externName, swcLocation2);
                	}
//                	else 
//                	{
//                		System.out.println("External " + externName + " not resolved");
//                	}
                }
            }
            
        }

        // If we are looking for the minimum set of swcs, then go thru the list of
        // dependent swcs and remove the ones whose externals are a subset of another
        // swc's externals.
        if (minimizeDependencySet)
        {
            for (Map.Entry<String, SwcExternalScriptInfoImpl> swcExternEntry : swcExternMap.entrySet())
            {
                String swcLocation = swcExternEntry.getKey();
            
                // remove each dependency whose list of externs is a subset of another list of dependencies.
                removeDependencySubsets(swcLocation, dependencyMap, depInfo);

                // Set up dependency info for remaining dependencies
                for (String swcDependLocation : dependencyMap.get(swcLocation))
                {
                    depInfo.addDependency(swcLocation, swcDependLocation);
                }
            }
            
        }
        
        // Make sure we don't leak open files...
        if( swcGroup != null )
        	swcGroup.close();
        
        return depInfo;
    }
    
    /**
     * Given a list of SwcScripts for different SWCs, choose the one that 
     * represents the original source of the script.
	 *
     * The current rules for choosing the original source are (in priority):
     * 1. Choose the script with the newest modified time. This 
     * allows the dependencies to take into consideration monkey patchers.
     * 2. Choose the swc if it has a signed RSL. These RSLs
     * have all other swcs excluded from then so they only 
     * contain their own source.
     * 3. Choose the swc with the oldest compile date/time. The
     * Swc with the newer compile time must have copied the classes
     * from the other swc.
     * 
     * @param resolvingSwcs
     * @return 
     */
    private static SwcScript getOriginalSwc(List<SwcScript> resolvingSwcs) 
    {
    	SwcScript originalScript = null;
    	SwcScript newestScript = null;
    	long oldestSwcCreationTime = Long.MAX_VALUE;
    	long newestScriptTime = Long.MAX_VALUE;
    	boolean allScriptTimesEqual = true;		// if all the script times are equal, then
    											// there is no monkey patching.
    	
    	for (SwcScript script : resolvingSwcs)
    	{
    	    // Rule 1. Use the newest script.
    		if (newestScript == null)
    		{
    			newestScript = script;
    			newestScriptTime = script.getLastModified();
    		}
    		else if (script.getLastModified() != newestScriptTime)
    		{
    			allScriptTimesEqual = false;
    			if (script.getLastModified() > newestScriptTime)
    			{
        			newestScript = script;
        			newestScriptTime = script.getLastModified();
    			}
    		}

    		// If all the script mod times are equal then apply rules 2 & 3.
    		if (allScriptTimesEqual)
    		{
    			SwcLibrary library = script.getLibrary();
				if (allScriptTimesEqual && 
				    library.getDigest(Digest.SHA_256, true) != null)
                {
                    originalScript = script;
                }
                else if (originalScript == null && 
                         library.getSwcCreationTime() < oldestSwcCreationTime)
                {
                    oldestSwcCreationTime = library.getSwcCreationTime();
                    originalScript = script;
                }
    		}
    	}
    	
		return allScriptTimesEqual ? originalScript : newestScript;
	}


	/**
     * Look at the dependency information and remove swc dependencies that are subsets of
     * other swc dependencies.
     * 
     * @param depInfo
     */
    private static void removeDependencySubsets(String swcLocation, 
            Map<String, Set<String>> dependencyMap,                                    
            SwcDependencyInfoImpl depInfo)
    {
        Set<String>removeSet = new HashSet<String>();   // record the list of swcs to remove as dependencies.
        SwcExternalScriptInfo externalInfo = depInfo.getSwcExternalScriptInfo(swcLocation);
        Map<String, Set<String>> externalsBySwc = new HashMap<String, Set<String>>();

        for (String swcDependLocation : dependencyMap.get(swcLocation))
        {
            // loop thru the other dependencies and remove it if it is a subset of any others.
            for (String swcDependLocation2 : dependencyMap.get(swcLocation))
            {
                if (swcDependLocation.equals(swcDependLocation2))
                    continue;
                
                Set<String>externalScripts = externalsBySwc.get(swcDependLocation);
                Set<String>externalScripts2 = externalsBySwc.get(swcDependLocation2);
                
                if (externalScripts == null) 
                {
                    externalScripts = externalInfo.getExternalScripts(swcDependLocation);
                    externalsBySwc.put(swcDependLocation, externalScripts);
                }
                
                if (externalScripts2 == null) 
                {
                    externalScripts2 = externalInfo.getExternalScripts(swcDependLocation2);
                    externalsBySwc.put(swcDependLocation2, externalScripts2);
                }

                // If not a subset, then add the dependency.
                if (externalScripts2.size() > externalScripts.size() &&
                    externalScripts2.containsAll(externalScripts))
                {
                    removeSet.add(swcDependLocation);
                    break;
                }
            }
        }

        Set<String> dependencySet = dependencyMap.get(swcLocation);
        dependencySet.removeAll(removeSet);
    }
    
    /**
     * Convert a Set of Vertex to a String.
     * 
     * @param vertexSet
     * @return a String with a message about the dependencies of the vertices.
     */
    public static String SetOfVertexToString(Set<Vertex<String, SwcExternalScriptInfo>> vertexSet)
    {
      StringBuilder dependencyMessage = new StringBuilder();
      String lineSeparator = System.getProperty("line.separator");
      LocalizationManager i10n = ThreadLocalToolkit.getLocalizationManager();
      
      for (Vertex<String, SwcExternalScriptInfo> vertexEntry : vertexSet)
      {
          String message = i10n.getLocalizedTextString(new DependsOn(vertexEntry.getWeight()));
          dependencyMessage.append(message + lineSeparator);
          Set<Vertex<String, SwcExternalScriptInfo>> predSet = vertexEntry.getPredecessors();

          for (Vertex<String, SwcExternalScriptInfo> predEntry : predSet)
          {
              dependencyMessage.append("\t" + predEntry.getWeight() + lineSeparator);
          }
          
      }

      return dependencyMessage.toString();
        
    }
    
    /**
     *  ${location} depends on:
     * 
     */
    public static class DependsOn extends CompilerMessage.CompilerInfo
    {
        
        private static final long serialVersionUID = 948175715607113717L;

        public DependsOn(String location)
        {
            this.location = location;
        }

        public String location;
    }
    
    /**
     * Check a set of target swcs to see if they contain any inheritance dependencies
     * in a set of source swcs.
     * @param targetSwcs A linked list of swcs to check against the inheritance dependencies 
     * of the source swcs.
     * @param sourceSwcs Set of source swcs.
     * @param swcContext
     * @return foundSwcs list of targetSwcs that contain inheritance dependencies
     * found in the source swcs.
     */
    public static Set<String> checkInheritanceDependencies(List<String>targetSwcs, 
                                                    Set<String>sourceSwcs, 
                                                    CompilerSwcContext swcContext)
    {
        if (sourceSwcs.isEmpty())
        {
            return Collections.emptySet();
        }
        
        // Loop over the source swcs to see if they have any inheritance 
        // dependencies on target swcs.
        Set<String> inheritanceDependencies = new HashSet<String>(64 * sourceSwcs.size());
        Set<String> inheritanceDependencyType = new HashSet<String>();
        inheritanceDependencyType.add(SwcDependencySet.INHERITANCE);

        // get the inheritance dependencies of all source swcs
        for (String sourceSwc : sourceSwcs)
        {
            Swc swc = swcContext.getSwc(sourceSwc);
            inheritanceDependencies.addAll(
                    getSwcDependencies(swc, inheritanceDependencyType));
        }

        if (inheritanceDependencies.isEmpty())
            return Collections.emptySet();

        // check to see if any of the inheritance dependencies live in the
        // target swcs.
        // move thru the list backwards to we can handle the case where a
        // newly found swc can be used to test an upstream swc.
        Set<String> foundSwcs = new HashSet<String>();
        for (ListIterator<String> iter = targetSwcs.listIterator(targetSwcs.size()); iter.hasPrevious();)
        {
            String targetSwc = iter.previous();
            Set<String> scriptNameSet = getSwcScripts(swcContext.getSwc(targetSwc));
            for (String dependency : inheritanceDependencies)
            {
                if (scriptNameSet.contains(dependency))
                {
                    foundSwcs.add(targetSwc);

                    // add the found swc to the list of inheritance dependencies.
                    if (iter.hasPrevious())
                    {
                        inheritanceDependencies.addAll(
                                    getSwcDependencies(swcContext.getSwc(targetSwc), 
                                                       inheritanceDependencyType));
                    }
                    break;
                }
            }
        }

        return foundSwcs;
    }
    
    /**
     * Get a list of class names defined in a swc.
     * 
     * @param swc
     * @return Set of strings of class names.
     */
    public static Set<String> getSwcScripts(Swc swc)
    {
        Set<String>scripts = new HashSet<String>(64);
        
        // for all the libraries in a swc to find external scripts
        for (Iterator<SwcLibrary> swcLibraryIter = swc.getLibraryIterator();
             swcLibraryIter.hasNext();)
        {
            SwcLibrary swcLibrary = (SwcLibrary)swcLibraryIter.next();
            
            // loop thru the script in a library and build the list of definitions
            for (Iterator<SwcScript> scriptIter = swcLibrary.getScriptIterator(); 
                 scriptIter.hasNext();)
            {
                SwcScript swcScript = (SwcScript)scriptIter.next();

                for (Iterator<String> defIter = swcScript.getDefinitionIterator(); defIter.hasNext();)
                {
                    String definition = (String)defIter.next();
                    scripts.add(definition);
                }
            }
        }        
        
        return scripts;
    }
    
    /**
     * Returns the class names from a swc with the specified dependency.
     * All classes that match one of the dependencies are included.
     * 
     * @param swc - the swc
     * @param dependencyTypes - may contain any combination of
     * <ul>
     * <li> 
     *          SwcDependencySet.INHERITANCE
     *</li>
     * <li>          
     *          SwcDependencySet.NAMESPACE
     *</li>
     * <li>
     *          SwcDependencySet.SIGNATURE
     *</li>
     * <li>
     *          SwcDependencySet.EXPRESSION
     * </li>
     * </ul>
     * @return  dependencies found in the swc.
     */
    public static Set<String> getSwcDependencies(Swc swc, Set<String>dependencyTypes)
    {
        // loop thru the script in a library and build the list of definitions
        // for all the libraries in a swc to find external scripts
        Set<String> dependencies = new HashSet<String>(64);
        
        for (Iterator<SwcLibrary> swcLibraryIter = swc.getLibraryIterator();
             swcLibraryIter.hasNext();)
        {
            SwcLibrary swcLibrary = (SwcLibrary)swcLibraryIter.next();
            
            // loop thru the script in a library and build the list of definitions
            for (Iterator<SwcScript> scriptIter = swcLibrary.getScriptIterator(); 
                 scriptIter.hasNext();)
            {
                SwcScript swcScript = (SwcScript)scriptIter.next();

                for (String dependencyType : dependencyTypes)
                {
                    for (Iterator<String> depIter = swcScript.getDependencySet().
                            getDependencyIterator(dependencyType);
                     depIter != null && depIter.hasNext();)
                    {
                    String definition = (String)depIter.next();
                    dependencies.add(definition);
                    }
                }
            }
        }
        
        return dependencies;
    }
    

}
