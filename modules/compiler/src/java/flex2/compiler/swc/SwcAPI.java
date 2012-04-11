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

import flex2.compiler.CompilerException;
import flex2.compiler.Source;
import flex2.compiler.SourceList;
import flex2.compiler.SourcePath;
import flex2.compiler.CompilationUnit;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.InMemoryFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.NameMappings;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.linker.LinkerConfiguration;
import flex2.linker.LinkerException;
import flex2.tools.CompcConfiguration;
import flash.util.Trace;

import java.io.IOException;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.TreeMap;

/**
 * API for SWC creation.
 *
 * @author Brian Deitte
 * @see flex2.tools.Compc
 */
public class SwcAPI
{
    public static List<SwcComponent> setupNamespaceComponents(CompcConfiguration configuration, NameMappings mappings,
                                                              SourcePath sourcePath, SourceList sourceList, Map<String, Source> classes)
            throws ConfigurationException, CompilerException
    {
        return setupNamespaceComponents(configuration.getNamespaces(), mappings, sourcePath, sourceList,
                                        classes, configuration.getIncludeLookupOnly(), false);
    }

    public static List<SwcComponent> setupNamespaceComponents(List targets, NameMappings mappings, SourcePath sourcePath,
                                                              SourceList sourceList, Map<String, Source> classes)
        throws ConfigurationException, CompilerException
    {
        return setupNamespaceComponents(targets, mappings, sourcePath, sourceList, classes, false, false);
    }
    
    /**
     * Method to read components entries from the namespace files.
     * 
     * @param targets - list of name spaces
     * @param mappings - mappings of namespace to manifest files.
     * @param sourcePath Used to find a Source for the component.
     * @param sourceList Used to find a Source for the component.
     * @param classes - map containing class to source
     * @param includeLookupOnly - parameter specifying whether to only include components with lookup="true".
     * @param includeAllForAsdoc - this parameter is set to true by asdoc only. if set to true it will also include 
     * 										components with lookuponly="true" along with the regular components.
     * @return 
     * @throws ConfigurationException
     * @throws CompilerException
     */
    public static List<SwcComponent> setupNamespaceComponents(List targets, NameMappings mappings, SourcePath sourcePath,
                                                              SourceList sourceList, Map<String, Source> classes,
                                                              boolean includeLookupOnly, boolean includeAllForAsdoc)
            throws ConfigurationException, CompilerException
    {
        List<SwcComponent> nsComponents = new LinkedList<SwcComponent>();

        try
        {
            for (Iterator iterator = targets.iterator(); iterator.hasNext();)
            {
                String nsTarget = (String)iterator.next();
                if (nsTarget != null)
                {
                    Map map = mappings.getNamespace(nsTarget);
                    if (map == null)
                    {
                        // fixme - pass enough info down to actually format this exception reasonably?
                        throw new ConfigurationException.UnknownNamespace( nsTarget, null, null, -1 );
                    }
                    for (Iterator iter2 = map.entrySet().iterator(); iter2.hasNext();)
                    {
                        Map.Entry entry = (Map.Entry)iter2.next();
                        String compName = (String) entry.getKey();
                        String className = (String) entry.getValue();
                        String packageName = NameFormatter.retrievePackageName(className);
                        String leafName = NameFormatter.retrieveClassName(className);
                        if (! mappings.isLookupOnly(nsTarget, className) || includeAllForAsdoc)
                        {
                            // Check SourceList before SourcePath to avoid duplicate Source objects.
                            Source s = sourceList.findSource(packageName, leafName);

                            if (s == null)
                            {
                                s = sourcePath.findSource(packageName, leafName);
                            }

                            if (s == null)
                            {
                            	// if includeAllForAsdoc is set to true then don't generate an exception if the source is not found.
                            	// there are cases when flash classes are listed in the manifest but the source is not available 
                            	// (or is not organized in folders as should be by package)
                            	if(includeAllForAsdoc)
                            	{
                            		continue;
                            	}
                            	
                                SwcException e = new SwcException.NoSourceForClass( className, nsTarget );
                                ThreadLocalToolkit.log(e);
                                throw e;
                            }
                            classes.put(s.getName(), s);

                            SwcComponent component = new SwcComponent(className, compName, nsTarget);
                            nsComponents.add(component);
                        }
                        else if (includeLookupOnly)
                        {
                            nsComponents.add(new SwcComponent(className, compName, nsTarget));
                        }
                    }
                }
            }
        }
        catch(CompilerException ce)
        {
            ThreadLocalToolkit.logError(ce.getMessage());
            throw ce;
        }
        return nsComponents;
    }

    public static void setupClasses(CompcConfiguration configuration, SourcePath sourcePath,
                                    SourceList sourceList, Map<String, Source> classes)
        throws CompilerException
    {
        setupClasses(configuration.getClasses(), sourcePath, sourceList, classes);
    }

    public static void setupClasses(List list, SourcePath sourcePath, SourceList sourceList,
                                    Map<String, Source> classes)
        throws CompilerException
    {
        if (list != null)
        {
            try
            {
                for (Iterator iterator = list.iterator(); iterator.hasNext();)
                {
                    String className = (String) iterator.next();
                    String tempName = className.replace('/', '.').replace('\\', '.');
                    String packageName = NameFormatter.retrievePackageName(tempName);
                    String leafName = NameFormatter.retrieveClassName(tempName);

                    // Check SourceList before SourcePath to avoid duplicate Source objects.
                    Source s = sourceList.findSource(packageName, leafName);
                    
                    if (s == null)
                    {
                        s = sourcePath.findSource(packageName, leafName);
                    }

                    if (s == null)
                    {
                        SwcException msg;
                        if (className.endsWith(".as") || className.endsWith(".mxml"))
                        {
                            msg = new SwcException.CouldNotFindFileSource(className);
                        }
                        else
                        {
                            msg = new SwcException.CouldNotFindSource(className);
                        }
                        ThreadLocalToolkit.log(msg);
                        throw msg;
                    }
                    classes.put(s.getName(), s);
                }
            }
            catch(CompilerException ce)
            {
                ThreadLocalToolkit.logError(ce.getMessage());
                throw ce;
            }
        }
    }

    public static SwcMovie link(LinkerConfiguration linkerConfiguration, List<CompilationUnit> units) throws LinkerException
    {
        // instantiate an empty movie
        SwcMovie movie = new SwcMovie(linkerConfiguration);

        // give all the compilation units to the movie object - it will setup dependencies and use a linker
        // to generate movie export order.
        // todo - break dep on CompilationUnit, take ABCs?
        movie.generate( units );
        return movie;
    }

    public static void exportSwc(CompcConfiguration configuration, List<CompilationUnit> units,
                                 List nsComponents, SwcCache cache, Map<String, VirtualFile> rbFiles)
            throws Exception
    {
    	Map<String, VirtualFile> m = new TreeMap<String, VirtualFile>();
    	if (configuration.getCSSArchiveFiles() != null) m.putAll(configuration.getCSSArchiveFiles());
    	if (configuration.getL10NArchiveFiles() != null) m.putAll(configuration.getL10NArchiveFiles());
    	if (configuration.getFiles() != null) m.putAll(configuration.getFiles());
    	
        exportSwc(configuration.getOutput(), configuration.isDirectory(), m,
        		  configuration.getStylesheets(), configuration,
                  units, nsComponents, cache, rbFiles);
    }

    public static void exportSwc(String swcStr, boolean isDirectory, Map<String, VirtualFile> files, Map<String, VirtualFile> stylesheets,
    							 LinkerConfiguration linkerConfiguration,
                                 List<CompilationUnit> units, List nsComponents, SwcCache cache, Map<String, VirtualFile> rbFiles)
            throws Exception
    {
        SwcArchive archive = isDirectory?
                             (SwcArchive) new SwcDirectoryArchive( swcStr ) : new SwcLazyReadArchive( swcStr );
        exportSwc(archive, files, stylesheets, linkerConfiguration, units, nsComponents, cache, rbFiles);
    }

    private static void exportSwc(SwcArchive archive, Map<String, VirtualFile> files, Map<String, VirtualFile> stylesheets, LinkerConfiguration linkerConfiguration,
                                 List<CompilationUnit> units, List nsComponents, SwcCache cache, Map<String, VirtualFile> rbFiles)
            throws Exception
    {
        SwcMovie m = link(linkerConfiguration, units);
        exportSwc(archive, files, stylesheets, linkerConfiguration, m, nsComponents, cache, rbFiles);
    }

    public static void exportSwc(SwcArchive archive, Map<String, VirtualFile> files, Map<String, VirtualFile> stylesheets, LinkerConfiguration linkerConfiguration,
                                 SwcMovie m, List nsComponents, SwcCache cache, Map<String, VirtualFile> rbFiles)
            throws Exception
    {
        try
        {
            Swc swc = new Swc( archive );

            if (linkerConfiguration.generateLinkReport() && linkerConfiguration.getLinkReportFileName() != null)
            {
                FileUtil.writeFile(linkerConfiguration.getLinkReportFileName(), m.getLinkReport());
            }
            if (linkerConfiguration.generateRBList() && linkerConfiguration.getRBListFileName() != null)
            {
                FileUtil.writeFile(linkerConfiguration.getRBListFileName(), m.getRBList());
            }

            if (ThreadLocalToolkit.errorCount() > 0)
            {
                return;
            }

            // Step 1: get map of all components known to swcs referenced from exported units
            Map<String, SwcComponent> allClassComp = new HashMap<String, SwcComponent>();
            //Map refClassComp = new HashMap();

            for (Iterator e = m.getExportedUnits().iterator(); e.hasNext();)
            {
                CompilationUnit unit = (CompilationUnit) e.next();
                if (unit.getSource().isSwcScriptOwner())
                {
                    Swc unitswc = ((SwcScript) unit.getSource().getOwner()).getLibrary().getSwc();
                    for (Iterator ci = unitswc.getComponentIterator(); ci.hasNext();)
                    {
                        SwcComponent c = (SwcComponent) ci.next();
                        allClassComp.put( c.getClassName(), c );
                    }
                }
            }

            for (Iterator nsc = nsComponents.iterator(); nsc.hasNext();)
            {
                SwcComponent c = (SwcComponent) nsc.next();
                allClassComp.put(c.getClassName(), c);
            }

            // Now pare this down to just referenced classes (and thus components)

            for (Iterator e = m.getExportedUnits().iterator(); e.hasNext();)
            {
                CompilationUnit unit = (CompilationUnit) e.next();
                for (int i = 0, s = unit.topLevelDefinitions.size();i < s; i++)
                {
                    String def = unit.topLevelDefinitions.get(i).toString();
                    if (allClassComp.containsKey( def ))
                    {
                        swc.addComponent( allClassComp.get( def ) );
                    }
                }
            }

            // fixme - for now, we'll have a single canned library name
            // eventually support building multi-library swcs
            swc.buildLibrary( "library", linkerConfiguration, m );

            addArchiveFiles(files, swc);
            addArchiveFiles(rbFiles, swc);
            addArchiveFiles(stylesheets, swc);

            cache.export(swc);

            if (ThreadLocalToolkit.errorCount() > 0)
            {
                return;
            }
        }
        catch (Exception e)
        {
            if (Trace.error)
            {
                e.printStackTrace();
            }

            if (e instanceof CompilerException || e instanceof LinkerException ||
                e instanceof SwcException.SwcNotExported)
            {
                throw e;
            }

            SwcException ex = (e instanceof SwcException) ? (SwcException) e : new SwcException.SwcNotExported(archive.getLocation(), e);
            ThreadLocalToolkit.log(ex);
            throw ex;
        }

        if (ThreadLocalToolkit.getBenchmark() != null)
        {
            ThreadLocalToolkit.getBenchmark().benchmark("Exporting " + archive.getLocation() + "...");
        }
    }
    
    private static void addArchiveFiles(Map<String, VirtualFile> files, Swc swc) throws IOException
    {
        for (Iterator iterator = files.entrySet().iterator(); iterator.hasNext();)
        {
            Map.Entry entry = (Map.Entry)iterator.next();
            String fileName = (String)entry.getKey();
            VirtualFile f = (VirtualFile)entry.getValue();
            if (swc.getArchive().getFile( fileName ) == null)   // icons were already added, don't overwrite
            {
                try
                {
                    VirtualFile swcFile = new InMemoryFile(f.getInputStream(), fileName,
                                                           f.getMimeType(), f.getLastModified());
                    swc.addFile(swcFile);
                }
                catch (IOException ioException)
                {
                    throw new SwcException.ArchiveFileException(ioException.getMessage());
                }
            }
        }
    }
}
