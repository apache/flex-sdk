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

package flex2.tools.oem;

import flex2.compiler.CompilationUnit;
import flex2.compiler.Source;
import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.common.Configuration;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.util.Name;
import flex2.compiler.util.QName;
import java.lang.ref.SoftReference;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import macromedia.asc.embedding.ConfigVar;
import macromedia.asc.util.ObjectList;

/**
 * A cache which allows SourceList, SourcePath, and ResourceContainer
 * based Sources, which are common between compilations, to be shared.
 * When a Flash Builder "user triggered clean" occurs,
 * ApplicationCache.clear() should be called.  When Flash Builder
 * calls Builder.clean() after writing out a PersistenceStore cache,
 * ApplicationCache.clear() should not be called.  Otherwise, the
 * benefit of the application cache would be lost.
 *
 * @since 4.5
 * @author Paul Reilly
 */
public class ApplicationCache extends CacheBase
{
    private Map<String, Source> sources;
    private SoftReference<Object> trigger;
    private int lowestTotalDependentCount;
    private Configuration configuration;

    public ApplicationCache()
    {
        sources = new HashMap<String, Source>();
    }

    /**
     * Check that the cache is consistent with <code>configuration</code>
     * before using it.  For example, a cache created with strict
     * turned on, can't be used in non-strict mode, and vice versa.
     *
     * @return true if it's ok to use the cache.
     */
    boolean isConsistent(Configuration configuration)
    {
        boolean result = true;

        if (contextStatics == null)
        {
            result = false;
        }
        else if (this.configuration != null)
        {
            CompilerConfiguration compilerConfiguration = configuration.getCompilerConfiguration();
            CompilerConfiguration cacheCompilerConfiguration = this.configuration.getCompilerConfiguration();

            if (compilerConfiguration.strict() != cacheCompilerConfiguration.strict())
            {
                result = false;
            }

            if (result && (compilerConfiguration.dialect() != cacheCompilerConfiguration.dialect()))
            {
                result = false;
            }

            if (result && configuration.getTargetPlayerTargetAVM() != this.configuration.getTargetPlayerTargetAVM())
            {
                result = false;
            }

            if (result && (compilerConfiguration.debug() != cacheCompilerConfiguration.debug()))
            {
                result = false;
            }

            if (result && (compilerConfiguration.omitTraceStatements() != cacheCompilerConfiguration.omitTraceStatements()))
            {
                result = false;
            }

            if (result && (compilerConfiguration.accessible() != cacheCompilerConfiguration.accessible()))
            {
                result = false;
            }

            ObjectList<ConfigVar> define = compilerConfiguration.getDefine();
            ObjectList<ConfigVar> cacheDefine = cacheCompilerConfiguration.getDefine();
                    
            if (result && !define.equals(cacheDefine))
            {
                result = false;
            }

            if (result && (compilerConfiguration.verboseStacktraces() != cacheCompilerConfiguration.verboseStacktraces()))
            {
                result = false;
            }

            if (result && !ApplicationCache.<String>equals(compilerConfiguration.getKeepAs3Metadata(),
                                                           cacheCompilerConfiguration.getKeepAs3Metadata()))
            {
                result = false;
            }

            if (result && (compilerConfiguration.keepGeneratedActionScript() != cacheCompilerConfiguration.keepGeneratedActionScript()))
            {
                result = false;
            }

            if (result && (compilerConfiguration.enableRuntimeDesignLayers() != cacheCompilerConfiguration.enableRuntimeDesignLayers()))
            {
                result = false;
            }

            if (result && !ApplicationCache.<String>equals(compilerConfiguration.getLocales(),
                                                           cacheCompilerConfiguration.getLocales()))
            {
                result = false;
            }

            if (result && !compilerConfiguration.getThemeNames().equals(cacheCompilerConfiguration.getThemeNames()))
            {
                result = false;
            }

            if (result && !ApplicationCache.<VirtualFile>equals(compilerConfiguration.getSourcePath(),
                                                                cacheCompilerConfiguration.getSourcePath()))
            {
                result = false;
            }
        }

        return result;
    }

    private static <T> boolean equals(T[] a1, T[] a2)
    {
        boolean result = true;

        if (((a1 == null) && (a2 != null)) ||
            ((a1 != null) && (a2 == null)))
        {
            result = false;
        }
        else if ((a1 != null) && (a2 != null))
        {
            // Convert the arrays to sets to filter out duplicates.
            Set<T> a1Set = new HashSet<T>(Arrays.<T>asList(a1));
            Set<T> a2Set = new HashSet<T>(Arrays.<T>asList(a2));

            if (!a1Set.equals(a2Set))
            {
                result = false;
            }
        }

        return result;
    }

    private static void addDependents(Source source,
                                      Set<QName> dependents,
                                      Map<QName, Source> qNameToSourceMap,
                                      Map<Name, Map<String, Source>> dependentMap)
    {
        CompilationUnit compilationUnit = source.getCompilationUnit();

        if (compilationUnit != null)
        {
            for (QName topLevelDefinition : compilationUnit.topLevelDefinitions)
            {
                Map<String, Source> topLevelDefinitionDependents = dependentMap.get(topLevelDefinition);

                if (topLevelDefinitionDependents != null)
                {
                    for (Source dependentSource : topLevelDefinitionDependents.values())
                    {
                        boolean foundNewDependent = false;
                        CompilationUnit dependentCompilationUnit = dependentSource.getCompilationUnit();

                        if (dependentCompilationUnit != null)
                        {
                            for (QName dependent : dependentCompilationUnit.topLevelDefinitions)
                            {
                                if (!dependents.contains(dependent))
                                {
                                    dependents.add(dependent);
                                    foundNewDependent = true;
                                }
                            }
                        }

                        if (foundNewDependent)
                        {
                            addDependents(dependentSource, dependents, qNameToSourceMap, dependentMap);
                        }
                    }
                }
            }
        }
    }

    /**
     *
     */
    void addSources(Map<String, Source> sources)
    {
        this.sources.putAll(sources);

        Map<QName, Source> qNames = new HashMap<QName, Source>(sources.size());
        Map<Name, Map<String, Source>> dependentMap = new HashMap<Name, Map<String, Source>>(sources.size());

        for (Source source : this.sources.values())
        {
            CompilationUnit compilationUnit = source.getCompilationUnit();

            if (compilationUnit != null)
            {
                for (QName qName : compilationUnit.topLevelDefinitions)
                {
                    qNames.put(qName, source);
                }
            }
        }

        for (Source source : this.sources.values())
        {
            CompilationUnit compilationUnit = source.getCompilationUnit();

            if (compilationUnit != null)
            {
                for (Name name : compilationUnit.inheritance)
                {
                    if (name instanceof QName)
                    {
                        Map<String, Source> inheritanceDependents = dependentMap.get(name);

                        if (inheritanceDependents == null)
                        {
                            inheritanceDependents = new HashMap<String, Source>();
                            dependentMap.put(name, inheritanceDependents);
                        }

                        inheritanceDependents.put(source.getName(), source);
                    }
                }

                for (Name name : compilationUnit.namespaces)
                {
                    if (name instanceof QName)
                    {
                        Map<String, Source> namespacesDependents = dependentMap.get(name);

                        if (namespacesDependents == null)
                        {
                            namespacesDependents = new HashMap<String, Source>();
                            dependentMap.put(name, namespacesDependents);
                        }

                        namespacesDependents.put(source.getName(), source);
                    }
                }

                for (Name name : compilationUnit.expressions)
                {
                    if (name instanceof QName)
                    {
                        Map<String, Source> expressionsDependents = dependentMap.get(name);

                        if (expressionsDependents == null)
                        {
                            expressionsDependents = new HashMap<String, Source>();
                            dependentMap.put(name, expressionsDependents);
                        }

                        expressionsDependents.put(source.getName(), source);
                    }
                }

                for (Name name : compilationUnit.types)
                {
                    if (name instanceof QName)
                    {
                        Map<String, Source> typesDependents = dependentMap.get(name);

                        if (typesDependents == null)
                        {
                            typesDependents = new HashMap<String, Source>();
                            dependentMap.put(name, typesDependents);
                        }

                        typesDependents.put(source.getName(), source);
                    }
                }
            }
        }

        lowestTotalDependentCount = Integer.MAX_VALUE;

        for (Source source : this.sources.values())
        {
            Set<QName> dependents = new HashSet<QName>();
            addDependents(source, dependents, qNames, dependentMap);
            int totalDependentCount = dependents.size();
            source.setTotalDependentCount(totalDependentCount);

            if (totalDependentCount < lowestTotalDependentCount)
            {
                lowestTotalDependentCount = totalDependentCount;
            }
        }

        reloadTrigger();
    }
    
    /**
     * If available, returns the <code>Source</code> associated with
     * the <code>className</code>.
     */
    public Source getSource(String className)
    {
        return sources.get(className);
    }

    private void prune()
    {
        Iterator<Source> iterator = sources.values().iterator();
        int nextLowestTotalDependentCount = Integer.MAX_VALUE;

        while (iterator.hasNext())
        {
            Source source = iterator.next();
            int totalDependentCount = source.getTotalDependentCount();

            if (totalDependentCount == lowestTotalDependentCount)
            {
                iterator.remove();
            }
            else if (totalDependentCount < nextLowestTotalDependentCount)
            {
                nextLowestTotalDependentCount = totalDependentCount;
            }
        }

        if (nextLowestTotalDependentCount < Integer.MAX_VALUE)
        {
            lowestTotalDependentCount = nextLowestTotalDependentCount;
            reloadTrigger();
        }
    }

    private void reloadTrigger()
    {
        if (trigger == null)
        {
            trigger = new SoftReference<Object>(new Object()
                {
                    protected void finalize()
                        throws Throwable
                    {
                        prune();
                    }
                });
        }
    }

    /**
     * Clears the cache.
     */
    public void clear()
    {
        sources.clear();
    }

    /**
     * Get the configuration used to initialize the cache.
     *
     * @return the current configuration.
     */
    Configuration getConfiguration()
    {
        return configuration;
    }

    /**
     * Sets the configuration used to initialize the cache.  The
     * previous checksum is overwritten.
     */
    void setConfiguration(Configuration configuration)
    {
        this.configuration = configuration;
    }
}
