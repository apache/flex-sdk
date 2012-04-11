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

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;
import java.net.URI;

import flash.util.Trace;
import flex2.compiler.CompilationUnit;
import flex2.compiler.CompilerAPI;
import flex2.compiler.CompilerException;
import flex2.compiler.CompilerSwcContext;
import flex2.compiler.FileSpec;
import flex2.compiler.ResourceBundlePath;
import flex2.compiler.ResourceContainer;
import flex2.compiler.Source;
import flex2.compiler.SourceList;
import flex2.compiler.SourcePath;
import flex2.compiler.SubCompiler;
import flex2.compiler.SymbolTable;
import flex2.compiler.Transcoder;
import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.extensions.ExtensionManager;
import flex2.compiler.extensions.ILibraryExtension;
import flex2.compiler.i18n.I18nUtils;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.LocalFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.swc.SwcAPI;
import flex2.compiler.swc.SwcArchive;
import flex2.compiler.swc.SwcCache;
import flex2.compiler.swc.SwcComponent;
import flex2.compiler.swc.SwcDirectoryArchive;
import flex2.compiler.swc.SwcLazyReadArchive;
import flex2.compiler.swc.SwcException;
import flex2.compiler.swc.SwcMovie;
import flex2.compiler.util.Benchmark;
import flex2.compiler.util.CompilerControl;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.NameMappings;
import flex2.compiler.util.PerformanceData;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.linker.LinkerConfiguration;
import flex2.linker.LinkerException;
import flex2.linker.SimpleMovie;
import flex2.tools.CompcPreLink;
import flex2.tools.Mxmlc;
import flex2.tools.ToolsConfiguration;
import flex2.tools.WebTierAPI;
import flex2.tools.oem.internal.LibraryData;
import flex2.tools.oem.internal.OEMConfiguration;
import flex2.tools.oem.internal.OEMReport;
import flex2.tools.oem.internal.OEMUtil;
import macromedia.asc.util.ContextStatics;

/**
 * The <code>Library</code> class represents a SWC archive or a RSL. It implements the <code>Builder</code> interface
 * which allows for building the library incrementally. The following example defines a SWC archive or RSL:
 *
 * <pre>
 * Library lib = new Library();
 * </pre>
 *
 * You can add components to the <code>Library</code> object in the following ways:
 *
 * <pre>
 * 1. String              - Specify a fully-qualified name.
 * 2. File                - Specify a source file.
 * 3. VirtualLocalFile    - Specify an in-memory source object.
 * 4. URI                 - Specify a namespace URI.
 * </pre>
 *
 * <p>
 * To add resource bundles to the <code>Library</code>, you can use the <code>addResourceBundle()</code> method,
 * as the following example shows:
 *
 * <pre>
 * lib.addResourceBundle("mx.controls"));
 * </pre>
 *
 * <p>
 * To add archive files to the <code>Library</code>, you can use the <code>addArchiveFile()</code> method, as the following
 * example shows:
 *
 * <pre>
 * lib.addArchiveFile("defaults.css", new File("path1/myStyle.css"));
 * </pre>
 *
 * Before you can compile with a <code>Library</code> object, you must configure it. The following
 * four methods are the most common methods you use to configure the <code>Library</code> object:
 *
 * <pre>
 * 1. setLogger()        - Use this to set a Logger so that the client can be notified of events that occurred during the compilation.
 * 2. setConfiguration() - Optional. Use this to specify compiler options.
 * 3. setOutput()        - Optional. Use this to specify an output file name.
 * 4. setDirectory()     - Optional. Use this to specify an RSL output directory.
 * </pre>
 *
 * You must implement the <code>flex2.tools.oem.Logger</code> interface and use the implementation as the <code>Logger</code>
 * for the compilation. The following is an example <code>Logger</code> implementation:
 *
 * <pre>
 * lib.setLogger(new flex2.tools.oem.Logger()
 * {
 *     public void log(Message message, int errorCode, String source)
 *     {
 *         System.out.println(message);
 *     }
 * });
 * </pre>
 *
 * To specify compiler options for the <code>Library</code> object, you
 * must get a <code>Configuration</code> object that is populated with default values. Then, you set
 * compiler options programmatically using methods of the <code>Configuration</code> class.
 *
 * <p>
 * The <code>setOutput()</code> method lets you specify where the <code>Library</code> object writes
 * the output to. If you call the <code>setOutput()</code> method, the <code>build(boolean)</code> method
 * writes directly to the specified location; for example:
 *
 * <pre>
 * lib.setOutput(new File("MyLib.swc"));
 * lib.build(true);
 * </pre>
 *
 * If you do not call the <code>setOutput()</code> method, you can use the <code>build(OutputStream, boolean)</code>
 * method. This requires that you provide a buffered output stream; for example:
 *
 * <pre>
 * lib.build(new BufferedOutputStream(new FileOutputStream("MyLib.swc")), true);
 * </pre>
 *
 * The <code>setDirectory()</code> method lets you output RSLs to the specified directory; for example:
 *
 * <pre>
 * lib.setDirectory(new File("dir1"));
 * lib.build(true);
 * </pre>
 *
 * You can save the <code>Library</code> object compilation
 * data for reuse. You do this using the <code>save(OutputStream)</code> method. Subsequent compilations can use
 * the <code>load(OutputStream)</code> method to get the old data into the <code>Library</code> object; for example:
 *
 * <pre>
 * lib.save(new BufferedOutputStream(new FileOutputStream("MyLib.incr")));
 * </pre>
 *
 * When a cache file (for example, <code>MyLib.incr</code>) from a previous compilation is available before the
 * compilation, you can call the <code>load(OutputStream)</code> method before you call the <code>build()</code> method; for example:
 *
 * <pre>
 * lib.load(new BufferedInputStream(FileInputStream("MyLib.incr")));
 * lib.build(true);
 * </pre>
 *
 * The <code>build(false)</code> and <code>build(OutputStream, false)</code> methods always rebuild the library.
 * The first time you build the <code>Library</code>
 * object, the <code>build(true)/build(OutputStream, true)</code> methods do a complete build, which
 * is equivalent to the <code>build(false)/build(OutputStream, false)</code> methods, respectively. After you call the
 * <code>clean()</code> method, the <code>Library</code> object always does a full build.
 *
 * <p>
 * The <code>clean()</code> method cleans up compilation data in the <code>Library</code> object the output
 * file, if the <code>setOutput()</code> method was called.
 *
 * <p>
 * You can use the <code>Library</code> class to build a library from a combination of source
 * files in the file system and in-memory, dynamically-generated source objects. You
 * must use the <code>addComponent(VirtualLocalFile)</code>, <code>addResourceBundle(VirtualLocalFile)</code>, and
 * <code>addArchiveFile(String, VirtualLocalFile)</code> methods to use in-memory objects.
 *
 * <p>
 * The <code>Library</code> class can be part of a <code>Project</code>.
 *
 * @see flex2.tools.oem.Configuration
 * @see flex2.tools.oem.Project
 * @version 2.0.1
 * @author Clement Wong
 */
public class Library implements Builder, Cloneable
{
    static
    {
        // This "should" trigger the static initialization of Application which locates
        // flex-compiler-oem.jar and set application.home correctly.
        try
        {
            // in Java 1.4, simply saying Application.class would load the class
            // Java 1.5 is much smarter, and you have to coax the JVM to actually load it
            Class.forName("flex2.tools.oem.Application");
        }
        catch (ClassNotFoundException e)
        {
            // I guess it didn't work *shrug*
            e.printStackTrace();
            assert false;
        }
    }

    /**
     * Constructor.
     */
    public Library()
    {
        sources = new TreeSet<VirtualFile>(new Comparator<VirtualFile>()
        {
            public int compare(VirtualFile f0, VirtualFile f1)
            {
                return f0.getName().compareTo(f1.getName());
            }
        });
        classes = new TreeSet<String>();
        namespaces = new TreeSet<URI>();
        resourceBundles = new TreeSet<String>();
        files = new TreeMap<String, VirtualFile>();
        stylesheets = new TreeMap<String, VirtualFile>();

        oemConfiguration = null;
        logger = null;
        output = null;
        directory = null;
        mimeMappings = new MimeMappings();
        meter = null;
        resolver = null;
        cc = new CompilerControl();

        data = null;
        cacheName = null;
        configurationReport = null;
        messages = new ArrayList<Message>();
    }

    private Set<VirtualFile> sources;
    private Set<String> classes, resourceBundles;
    private Set<URI> namespaces;
    private Map<String, VirtualFile> files, stylesheets;
    private OEMConfiguration oemConfiguration;
    private Logger logger;
    private File output, directory;
    private MimeMappings mimeMappings;
    private ProgressMeter meter;
    protected PathResolver resolver;
    private CompilerControl cc;
    private ApplicationCache applicationCache;
    private LibraryCache libraryCache;

    // clean() would null out the following variables
    LibraryData data;
    private String cacheName, configurationReport;
    private List<Message> messages;
    private HashMap<String, PerformanceData[]> compilerBenchmarks;
    private Benchmark benchmark;

    /**
     * Adds a class, function, variable, or namespace to this <code>Library</code> object.
     *
     * This is the equilvalent of the <code>include-classes</code> option of the compc compiler.
     *
     * @param includeClass A fully-qualified name.
     */
    public void addComponent(String includeClass)
    {
        classes.add(includeClass);
    }

    /**
     * Adds a component to this <code>Library</code> object.
     * This is the equilvalent of the <code>include-sources</code> option of the compc compiler.
     *
     * @param includeSource A source file.
     */
    public void addComponent(File includeSource)
    {
        sources.add(new LocalFile(includeSource));
    }

    /**
     * Adds a component to this <code>Library</code> object.
     *
     * This is equilvalent to the <code>include-sources</code> option of the compc compiler.
     *
     * @param includeSource An in-memory source object.
     */
    public void addComponent(VirtualLocalFile includeSource)
    {
        sources.add(includeSource);
    }

    /**
     * Adds a list of components to this <code>Library</code> object.
     *
     * This is equilvalent to the <code>include-namespaces</code> option of the compc compiler.
     *
     * @param includeNamespace A namespace URI.
     */
    public void addComponent(URI includeNamespace)
    {
        namespaces.add(includeNamespace);
    }

    /**
     * Removes the specified component from this <code>Library</code> object.
     * The name can be a class, a function, a variable, or a namespace.
     *
     * @param includeClass A fully-qualified name.
     */
    public void removeComponent(String includeClass)
    {
        classes.remove(includeClass);
    }

    /**
     * Removes the specified component from this <code>Library</code> object.
     *
     * @param includeSource A source file.
     */
    public void removeComponent(File includeSource)
    {
        sources.remove(new LocalFile(includeSource));
    }

    /**
     * Removes the specified component from this <code>Library</code> object.
     *
     * @param includeSource An in-memory source object.
     */
    public void removeComponent(VirtualLocalFile includeSource)
    {
        sources.remove(includeSource);
    }

    /**
     * Removes the specified list of components from this <code>Library</code> object. The input argument is a namespace URI.
     *
     * @param includeNamespace A namespace URI.
     */
    public void removeComponent(URI includeNamespace)
    {
        namespaces.remove(includeNamespace);
    }

    /**
     * Removes all the components from this <code>Library</code> object.
     */
    public void removeAllComponents()
    {
        sources.clear();
        classes.clear();
        namespaces.clear();
    }

    /**
     * Adds a resource bundle to this <code>Library</code> object.
     *
     * This is equilvalent to the <code>include-resource-bundles</code> option of the compc compiler.
     *
     * @param resourceBundle A resource bundle name.
     */
    public void addResourceBundle(String resourceBundle)
    {
        resourceBundles.add(resourceBundle);
    }

    /**
     * Removes the specified resource bundle name from this <code>Library</code> object.
     *
     * @param resourceBundle A resource bundle name.
     */
    public void removeResourceBundle(String resourceBundle)
    {
        resourceBundles.remove(resourceBundle);
    }

    /**
     * Removes all the resource bundles from this <code>Library</code> object.
     *
     */
    public void removeAllResourceBundles()
    {
        resourceBundles.clear();
    }

    /**
     * Adds a file to this <code>Library</code> object. This is equilvalent to the <code>include-file</code> option of the compc compiler.
     *
     * @param name The name in the archive.
     * @param file The file to be added.
     */
    public void addArchiveFile(String name, File file)
    {
        files.put(name, new LocalFile(file));
    }

    /**
     * Adds an in-memory source object to this <code>Library</code> object. This is equilvalent to the <code>
     * include-file</code> option of the compc compiler.
     *
     * @param name The name in the archive.
     * @param file The in-memory source object to be added.
     */
    public void addArchiveFile(String name, VirtualLocalFile file)
    {
        files.put(name, file);
    }

    /**
     * Removes the specified file from this <code>Library</code> object.
     *
     * @param name The name in the archive.
     */
    public void removeArchiveFile(String name)
    {
        files.remove(name);
    }

    /**
     * Removes all the archive files from this <code>Library</code> object.
     */
    public void removeAllArchiveFiles()
    {
        files.clear();
    }

    /**
     * Adds a CSS stylesheet to this <code>Library</code> object. This is equilvalent to the <code>include-stylesheet</code> option of the compc compiler.
     *
     * @param name The name in the archive.
     * @param file The file to be added.
     * @since 3.0
     */
    public void addStyleSheet(String name, File file)
    {
        stylesheets.put(name, new LocalFile(file));
    }

    /**
     * Adds an in-memory CSS stylesheet object to this <code>Library</code> object. This is equilvalent to the <code>
     * include-stylesheet</code> option of the compc compiler.
     *
     * @param name The name in the archive.
     * @param file The in-memory source object to be added.
     * @since 3.0
     */
    public void addStyleSheet(String name, VirtualLocalFile file)
    {
        stylesheets.put(name, file);
    }

    /**
     * Removes the specified CSS stylesheet from this <code>Library</code> object.
     *
     * @param name The name in the archive.
     * @since 3.0
     */
    public void removeStyleSheet(String name)
    {
        stylesheets.remove(name);
    }

    /**
     * Removes all the CSS stylesheets from this <code>Library</code> object.
     * @since 3.0
     */
    public void removeAllStyleSheets()
    {
        stylesheets.clear();
    }

    /**
     * @inheritDoc
     */
    public void setConfiguration(Configuration configuration)
    {
        oemConfiguration = (OEMConfiguration) configuration;
    }

    /**
     * @inheritDoc
     */
    public Configuration getDefaultConfiguration()
    {
        return getDefaultConfiguration(false);
    }

    /**
     *
     * @param processDefaults
     * @return
     */
    private Configuration getDefaultConfiguration(boolean processDefaults)
    {
        return OEMUtil.getLibraryConfiguration(constructCommandLine(null), false, false,
                                               OEMUtil.getLogger(logger, messages), resolver,
                                               mimeMappings, processDefaults);
    }

    /**
     * @inheritDoc
     */
    public HashMap<String, PerformanceData[]> getCompilerBenchmarks()
    {
        return compilerBenchmarks;
    }

    /**
     * @inheritDoc
     */
    public Benchmark getBenchmark()
    {
        return benchmark;
    }

    /**
     * @inheritDoc
     */
    public Configuration getConfiguration()
    {
        return oemConfiguration;
    }

    /**
     * @inheritDoc
     */
    public void setLogger(Logger logger)
    {
        this.logger = logger;
    }

    /**
     * @inheritDoc
     */
    public Logger getLogger()
    {
        return logger;
    }

    /**
     * @inheritDoc
     */
    public void setSupportedFileExtensions(String mimeType, String[] extensions)
    {
        mimeMappings.set(mimeType, extensions);
    }

    /**
     * Sets the output destination. This method is necessary if you use the <code>build(boolean)</code> method.
     * If you use the <code>build(OutputStream, boolean)</code> method, there is no need to use this method.
     *
     * @param output An instance of the <code>java.io.File</code> class.
     */
    public void setOutput(File output)
    {
        this.output = output;
    }

    /**
     * Gets the output destination. This method returns <code>null</code> if you did not call the
     * <code>setOutput()</code> method.
     *
     * @return An instance of the <code>java.io.File</code> class, or <code>null</code> if you did not
     * call the <code>setOutput()</code> method.
     */
    public File getOutput()
    {
        return output;
    }

    /**
     * Sets the RSL output directory.
     *
     * @param directory An RSL directory.
     */
    public void setDirectory(File directory)
    {
        this.directory = directory;
    }

    /**
     * Gets the RSL output directory.
     *
     * @return A <code>java.io.File</code>, or <code>null</code> if you did not call the <code>setDirectory()</code> method.
     */
    public File getDirectory()
    {
        return directory;
    }

    /**
     * @inheritDoc
     */
    public void setProgressMeter(ProgressMeter meter)
    {
        this.meter = meter;
    }

    /**
     * @inheritDoc
     */
    public void setPathResolver(PathResolver resolver)
    {
        this.resolver = resolver;
    }

    /**
     * @inheritDoc
     */
    // IMPORTANT: If you make changes here, you probably want to mirror them in Application.build()
    public long build(boolean incremental) throws IOException
    {
        // I know that directory is not referenced anywhere in here...
        // if you setDirectory but do not setOutput, then output==null but dirctory!=null
        // so this silly looking IF needs to be like this...
        if (output != null || directory != null)
        {
            long size = 0;

            //TODO PERFORMANCE: A lot of unnecessary recopying and buffering here
            try
            {
                int result = compile(incremental);

                if (result == SKIP || result == LINK || result == OK)
                {
                    size = link(null);
                }

                return size;
            }
            finally
            {
                if ((output != null) && (data != null) && (data.swcCache != null))
                {
                    refreshLastModified();
                }

                if ((benchmark != null) && benchmark.hasStarted(Benchmark.POSTCOMPILE))
                {
                    benchmark.stopTime(Benchmark.POSTCOMPILE, false);
                }
                
                runExtensions();
                
                clean(false /* cleanData */,
                      false /* cleanCache */,
                      false /* cleanOutput */,
                      true /* cleanConfig */,
                      false /* cleanMessages */,
                      true /* cleanThreadLocals */);
            }
        }
        else
        {
            return 0;
        }
    }

    private void runExtensions()
    {
        if (oemConfiguration != null)
        {
            Set<ILibraryExtension> extensions = ExtensionManager.getLibraryExtensions( oemConfiguration.getExtensions() );

            for ( ILibraryExtension extension : extensions )
            {
                if (ThreadLocalToolkit.errorCount() == 0)
                {
                    extension.run( this.clone(), oemConfiguration.clone() );
                }
            }
        }
    }

    /**
     * @inheritDoc
     * 
     * Note: If the OutputStream is written to a File,
     * refreshLastModified() should be called to update the timestamp
     * in the SwcCache.  Otherwise, subsequent builds in this Project
     * will think the Library has been externally updated and will
     * force a reload.
     */
    public long build(OutputStream out, boolean incremental) throws IOException
    {
        try
        {
            int result = compile(incremental);

            if (result == SKIP || result == LINK || result == OK)
            {
                return link(out);
            }
            else
            {
                return 0;
            }
        }
        finally
        {
            if ((benchmark != null) && benchmark.hasStarted(Benchmark.POSTCOMPILE))
            {
                benchmark.stopTime(Benchmark.POSTCOMPILE, false);
            }
            
            runExtensions();
            
            clean(false /* cleanData */,
                  false /* cleanCache */,
                  false /* cleanOutput */,
                  true /* cleanConfig */,
                  false /* cleanMessages */,
                  true /* cleanThreadLocals */);
        }
    }

    /**
     * @param fullRecompile if true a full recompile is needed, do not attempted to use cache file.
     *
     * @return  {@link Builder#OK} if this method call resulted in compilation of some/all parts of the application;
     *          {@link Builder#LINK} if this method call did not compile anything in the application but advise the caller to link again;
     *          {@link Builder#SKIP} if this method call did not compile anything in the application;
     *          {@link Builder#FAIL} if this method call encountered errors during compilation.
     */
    private int recompile(boolean fullRecompile, Map licenseMap, OEMConfiguration localOEMConfiguration)
    {
        data = new LibraryData();
        data.configuration = localOEMConfiguration.configuration;
        data.cacheName = cacheName;

        NameMappings mappings = CompilerAPI.getNameMappings(localOEMConfiguration.configuration), copy = mappings.copy();

        CompilerConfiguration compilerConfig = localOEMConfiguration.configuration.getCompilerConfiguration();
        compilerConfig.setMetadataExport(true);

        if (output != null || directory != null)
        {
            OEMUtil.setGeneratedDirectory(compilerConfig, output != null ? output : directory);
        }

        Transcoder[] transcoders = WebTierAPI.getTranscoders( localOEMConfiguration.configuration );
        SubCompiler[] compilers = WebTierAPI.getCompilers(compilerConfig, mappings, transcoders);

        if ((data.fileSet = processSources(compilerConfig)) == null)
        {
            return FAIL;
        }

        data.fileSet.addAll(processStylesheets());

        if (!setupSourceContainers(localOEMConfiguration.configuration, data.fileSet))
        {
            return FAIL;
        }

        // Setup SWC cache
        if (libraryCache != null)
        {
            ContextStatics contextStatics = libraryCache.getContextStatics();

            if (contextStatics != null)
            {
                // Clear out ASC's userDefined, so definitions from a
                // previous compilation don't spill over into this one.
                contextStatics.userDefined.clear();
                data.perCompileData = contextStatics;
                data.swcCache = libraryCache.getSwcCache();
            }
        }

        if (data.swcCache == null)
        {
            data.swcCache = new SwcCache();
        }
        
        // load SWCs
        CompilerSwcContext swcContext = new CompilerSwcContext(true);
        try
        {
            swcContext.load( compilerConfig.getLibraryPath(),
                             compilerConfig.getExternalLibraryPath(),
                             null,
                             compilerConfig.getIncludeLibraries(),
                             mappings,
                             I18nUtils.getTranslationFormat(compilerConfig),
                             data.swcCache );
        }
        catch (SwcException ex)
        {
            if (Trace.error)
            {
                ex.printStackTrace();
            }
            return FAIL;
        }

        // save the generated cache if the caller provided a libraryCache.
        if (libraryCache != null)
        {
            libraryCache.setSwcCache(data.swcCache);
        }

        data.includes = new HashSet<String>(swcContext.getIncludes());
        data.excludes = new HashSet<String>(swcContext.getExterns());
        localOEMConfiguration.configuration.addExterns( swcContext.getExterns() );
        localOEMConfiguration.configuration.addIncludes( swcContext.getIncludes() );
        data.swcArchiveFiles = new HashMap<String, VirtualFile>(swcContext.getIncludeFiles());
        
        // The ToolsConfiguration expects class names in QName format.
        Set<String> qNameClasses = new HashSet<String>();
        for (String className : classes)
        {
            qNameClasses.add(NameFormatter.toColon(className));
        }

        // Allow -include-classes to override the -external-library-path.
        localOEMConfiguration.configuration.removeExterns(qNameClasses);

        // If we want only inheritance dependencies of -include-classes then
        // add the classes to the includes list. When 
        // -include-inheritance-dependencies-only is turned on the dependency
        // walker will ignore all the classes except for the includes.
        if (localOEMConfiguration.configuration.getIncludeInheritanceDependenciesOnly())
        {
            localOEMConfiguration.configuration.addIncludes(qNameClasses);
        }

        data.cmdChecksum = localOEMConfiguration.cfgbuf.checksum_ts();
        data.linkChecksum = localOEMConfiguration.cfgbuf.link_checksum_ts();
        data.swcChecksum = swcContext.checksum();
        int[] checksums = new int[] { 0, data.cmdChecksum, data.linkChecksum, data.swcChecksum };
        boolean clearCache = false;

        // C: must do loadCompilationUnits() after checksum calculation...
        if (!fullRecompile)
        {
            if (!loadCompilationUnits(localOEMConfiguration.configuration, data.fileSet, swcContext, checksums))
            {
                return FAIL;
            }

            data.checksum = checksums[0];
            if (data.units != null &&
                data.units.size() > 0 &&
                OEMUtil.isRecompilationNeeded(data, swcContext, localOEMConfiguration))
            {
                if (!setupSourceContainers(localOEMConfiguration.configuration, data.fileSet))
                {
                    return FAIL;
                }
                clearCache = true;
            }
        }
        else
        {
            clearCache = true;
        }

        if (clearCache && (libraryCache != null) && (output != null))
        {
            String path = FileUtil.getCanonicalPath(output);
            libraryCache.getSwcCache().remove(path);
        }

        // validate CompilationUnits...
        int count = CompilerAPI.validateCompilationUnits(data.fileSpec, data.sourceList, data.sourcePath, data.bundlePath,
                                                         data.resources, swcContext, data.classes, data.perCompileData,
                                                         localOEMConfiguration.configuration);

        SymbolTable symbolTable;

        if (data.perCompileData != null)
        {
            symbolTable = new SymbolTable(localOEMConfiguration.configuration, data.perCompileData);
        }
        else
        {
            symbolTable = new SymbolTable(localOEMConfiguration.configuration);
            data.perCompileData = symbolTable.perCompileData;

            if (libraryCache != null)
            {
                libraryCache.setContextStatics(data.perCompileData);
            }
        }

        Map<String, Source> classes = new TreeMap<String, Source>();
        if ((data.nsComponents = processInputs(swcContext, copy, classes)) == null)
        {
            return FAIL;
        }

        // Only updated the LibraryData's classes if processInputs()
        // is successful.
        data.classes = classes;
        data.sources = new ArrayList<Source>();
        data.units = compile(compilers, swcContext, symbolTable, mappings, licenseMap, data.classes, data.sources);

        // need to update the checksum here since doing a compile could add some
        // some signature checksums and change it.
        data.checksum = OEMUtil.calculateChecksum(data, swcContext, localOEMConfiguration);
        boolean forcedToStop = CompilerAPI.forcedToStop();

        if (data.units == null || forcedToStop)
        {
            return FAIL;
        }
        else
        {
            return OK;
        }
    }

    /**
     * @inheritDoc
     */
    public void stop()
    {
        cc.stop();
    }

    /**
     * @inheritDoc
     */
    public void clean()
    {
        clean(true /* cleanData */,
              true /* cleanCache */,
              true /* cleanOutput */,
              true /* cleanConfig */,
              true /* cleanMessages */,
              true /* cleanThreadLocals */);
    }

    /**
     * @inheritDoc
     */
    public void load(InputStream in) throws IOException
    {
        cacheName = OEMUtil.load(in, cacheName);
        clean(true /* cleanData */,
              false /* cleanCache */,
              false /* cleanOutput */,
              true /* cleanConfig */,
              false /* cleanMessages */,
              true /* cleanThreadLocals */);
    }

    /**
     * @inheritDoc
     */
    public long save(OutputStream out) throws IOException
    {
        return OEMUtil.save(out, cacheName, data);
    }

    /**
     * @inheritDoc
     */
    public Report getReport()
    {
        OEMUtil.setupLocalizationManager();
        return new OEMReport(data == null ? null : data.sources,
                             data == null ? null : data.movie,
                             data == null ? null : data.configuration,
                             data == null ? null : data.sourceList,
                             configurationReport,
                             messages, files);
    }

    /**
     *
     * @param c
     * @return
     */
    private String[] constructCommandLine(OEMConfiguration localOEMConfiguration)
    {
        String[] commandLine = (localOEMConfiguration != null) ? localOEMConfiguration.getCompilerOptions() : 
                                                                 new String[0];
        
        // Translate "classes" into "-include-classes" so the CompcConfiguration can
        // properly validate the configuration.
        if (classes.size() > 0)
        {
            StringBuilder buffer = new StringBuilder("-include-classes=");

            for (Iterator<String> iter = classes.iterator(); iter.hasNext();)
            {
                String className = iter.next();
                buffer.append(className);
                if (iter.hasNext())
                {
                    buffer.append(",");
                }
            }
            
            String[] newCommandLine = new String[commandLine.length + 1];
            System.arraycopy(commandLine, 0, newCommandLine, 0, commandLine.length);
            newCommandLine[commandLine.length] = buffer.toString();
            
            return newCommandLine;
        }

        return commandLine;
    }

    /**
     *
     * @param swcContext
     * @param mappings
     * @param classes
     * @return
     */
    private Set<SwcComponent> processInputs(CompilerSwcContext swcContext, NameMappings mappings, Map<String, Source> classes)
    {
        try
        {
            Set<SwcComponent> nsComponents = processNamespaces(mappings, classes);
            if (nsComponents == null)
            {
                return null;
            }

            if (!processClasses(classes))
            {
                return null;
            }

            for (Map.Entry<String, Source> entry : classes.entrySet())
            {
                Source source = entry.getValue();
                String namespaceURI = source.getRelativePath().replace('/', '.');
                String localPart = source.getShortName();
                Source swcSource = (swcContext != null) ? swcContext.getSource(namespaceURI, localPart) : null;
                
                // No sense recompiling the same source file again.
                if ((swcSource != null) &&
                    ((source.getLastModified() == swcSource.getLastModified()) &&
                     ((source.getCompilationUnit() == null) ||
                      (!source.getCompilationUnit().hasTypeInfo))))
                {
                    classes.put(entry.getKey(), swcSource);
                }
            }

            return nsComponents;
        }
        catch (SwcException ex)
        {
            if (Trace.error)
            {
                ex.printStackTrace();
            }
            assert ThreadLocalToolkit.errorCount() > 0;
            return null;
        }
    }

    /**
     *
     * @param classes
     * @return
     */
    private boolean processClasses(Map<String, Source> classes)
    {
        try
        {
            SwcAPI.setupClasses(new ArrayList<String>(this.classes), data.sourcePath, data.sourceList, classes);
            return true;
        }
        catch (CompilerException ex)
        {
            assert ThreadLocalToolkit.errorCount() > 0;
            return false;
        }
    }

    /**
     * This must be called before CompilerSwcContext.load().
     *
     * @param mappings
     * @param classes
     * @return
     */
    private Set<SwcComponent> processNamespaces(NameMappings mappings, Map<String, Source> classes)
    {
        Set<SwcComponent> nsComponents = null;

        try
        {
            List<SwcComponent> list = SwcAPI.setupNamespaceComponents(toStrings(namespaces), mappings,
                                                                      data.sourcePath, data.sourceList,
                                                                      classes);
            nsComponents = new TreeSet<SwcComponent>(new Comparator<SwcComponent>()
            {
                public int compare(SwcComponent c0, SwcComponent c1)
                {
                    return c0.getClassName().compareTo(c1.getClassName());
                }
            });
            nsComponents.addAll(list);
        }
        catch (ConfigurationException ex)
        {
            Mxmlc.processConfigurationException(ex, "oem");
        }
        catch (CompilerException ex)
        {
            assert ThreadLocalToolkit.errorCount() > 0;
        }

        return nsComponents;
    }

    /**
     *
     * @param set
     * @return
     */
    private List<String> toStrings(Set<URI> set)
    {
        List<String> a = new ArrayList<String>(set.size());
        for (Iterator<URI> i = set.iterator(); i.hasNext(); )
        {
            URI uri = i.next();
            a.add(uri.toString());
        }
        return a;
    }

    /**
     * @param configuration
     * @param fileList
     * @return true, unless a CompilerException occurs.
     */
    private boolean setupSourceContainers(flex2.compiler.common.Configuration configuration, Set<VirtualFile> fileSet)
    {
        CompilerConfiguration compilerConfig = configuration.getCompilerConfiguration();
        VirtualFile[] asClasspath = compilerConfig.getSourcePath();
        boolean result = false;

        try
        {
            // create a SourcePath...
            data.sourcePath = new SourcePath(WebTierAPI.getSourcePathMimeTypes(),
                                             compilerConfig.allowSourcePathOverlap());
            data.sourcePath.addPathElements( asClasspath );

            List<VirtualFile>[] array = CompilerAPI.getVirtualFileList(fileSet, data.sourcePath.getPaths());

            // create a FileSpec...
            data.fileSpec = new FileSpec(array[0], WebTierAPI.getFileSpecMimeTypes(), false);

            // create a SourceList...
            data.sourceList = new SourceList(array[1], asClasspath, null, WebTierAPI.getSourceListMimeTypes(), false);
            
            // create a ResourceContainer...
            data.resources = new ResourceContainer();

            // create a ResourceBundlePath...
            data.bundlePath = new ResourceBundlePath(compilerConfig, null);

            // clear these...
            if (data.sources != null) data.sources.clear();
            if (data.units != null) data.units.clear();
            if (data.swcDefSignatureChecksums != null) data.swcDefSignatureChecksums.clear();
            if (data.swcFileChecksums != null) data.swcFileChecksums.clear();

            result = true;
        }
        catch (CompilerException ex)
        {
            assert ThreadLocalToolkit.errorCount() > 0;
        }

        return result;
    }

    /**
     * Convert the set of sources, which might include directories and
     * files with tokens in the name, into a set of resolved
     * VirtualFiles.
     *
     * @return
     */
    private Set<VirtualFile> processSources(CompilerConfiguration compilerConfiguration)
    {
        Set<VirtualFile> fileSet = null;

        try
        {
            // Create a list of LocalFile paths and remove the LocalFiles "sources".
            List<String> localPathList = new ArrayList<String>();

            for (Iterator<VirtualFile> iterator = sources.iterator(); iterator.hasNext();)
            {
                VirtualFile virtualFile = iterator.next();

                if (virtualFile instanceof LocalFile)
                {
                    localPathList.add(virtualFile.getName());
                    iterator.remove();
                }
            }

            // Convert the localPathList to an Array
            String[] localPathArray = new String[localPathList.size()];
            int i = 0;

            for (String localPath : localPathList)
            {
                localPathArray[i++] = localPath;
            }

            VirtualFile[] virtualFileArray =
                compilerConfiguration.expandTokens(localPathArray, compilerConfiguration.getLocales(), null);

            // Add the token expanded VirtualFile's back into "sources".
            for (VirtualFile virtualFile : virtualFileArray)
            {
                sources.add(virtualFile);
            }

            List<VirtualFile> fileList =
                CompilerAPI.getVirtualFileList(sources, new HashSet<String>(Arrays.asList(WebTierAPI.getSourcePathMimeTypes())));
            fileSet = new TreeSet<VirtualFile>(new Comparator<VirtualFile>()
            {
                public int compare(VirtualFile f0, VirtualFile f1)
                {
                    return f0.getName().compareTo(f1.getName());
                }
            });
            fileSet.addAll(fileList);
        }
        catch (ConfigurationException ex)
        {
            Mxmlc.processConfigurationException(ex, "oem");
            assert ThreadLocalToolkit.errorCount() > 0;
        }

        return fileSet;
    }

    /**
     *
     * @return
     */
    private Set<VirtualFile> processStylesheets()
    {
        Set<VirtualFile> fileSet = null;

        try
        {
            List<VirtualFile> fileList = CompilerAPI.getVirtualFileList(new ArrayList<VirtualFile>(stylesheets.values()), new HashSet<String>(Arrays.asList(new String[] { MimeMappings.CSS })));
            fileSet = new TreeSet<VirtualFile>(new Comparator<VirtualFile>()
            {
                public int compare(VirtualFile f0, VirtualFile f1)
                {
                    return f0.getName().compareTo(f1.getName());
                }
            });
            fileSet.addAll(fileList);
        }
        catch (ConfigurationException ex)
        {
            assert ThreadLocalToolkit.errorCount() > 0;
        }

        return fileSet;
    }

    /**
     *
     * @param configuration
     * @param fileList
     * @return
     */
    private boolean loadCompilationUnits(ToolsConfiguration configuration, Set fileSet, CompilerSwcContext swcContext, int[] checksums)
    {
        if (data.cacheName == null) // note: NOT (cacheName == null)
        {
            return true;
        }

        RandomAccessFile cacheFile = null;

        try
        {
            cacheFile = new RandomAccessFile(data.cacheName, "r");
            CompilerAPI.loadCompilationUnits(configuration, data.fileSpec, data.sourceList,
                                             data.sourcePath, data.resources, data.bundlePath,
                                             data.sources = new ArrayList<Source>(),
                                             data.units = new ArrayList<CompilationUnit>(),
                                             checksums,
                                             data.swcDefSignatureChecksums = new HashMap<QName, Long>(),
                                             data.swcFileChecksums = new HashMap<String, Long>(),
                                             cacheFile, data.cacheName);

            /*
            for (int i = 0, size = data.sources.size(); i < size; i++)
            {
                Object obj = data.sources.get(i);
                if (obj instanceof String)
                {
                    String name = (String) obj;
                    Source s = swcContext.getSource(name);
                    data.sources.set(i, s);
                    data.units.set(i, s != null ? s.getCompilationUnit() : null);
                }
            }
            */
        }
        catch (FileNotFoundException ex)
        {
            ThreadLocalToolkit.logInfo(ex.getMessage());
            // if the cache file is not found, no big deal... return true so that we recompile.
            return true;
        }
        catch (IOException ex)
        {
            ThreadLocalToolkit.logInfo(ex.getMessage());

            if (!setupSourceContainers(configuration, fileSet))
            {
                return false;
            }
        }
        finally
        {
            if (cacheFile != null) try { cacheFile.close(); } catch (IOException ex) {}
        }

        return true;
    }

    /**
     * Compiles the <code>Library</code>. This method does not link the <code>Library</code>.
     *
     * @param incremental If <code>true</code>, build incrementally; if <code>false</code>, rebuild.
     * @return  {@link Builder#OK} if this method call resulted in compilation of some/all parts of the application;
     *          {@link Builder#LINK} if this method call did not compile anything in the application but advise the caller to link again;
     *          {@link Builder#SKIP} if this method call did not compile anything in the application;
     *          {@link Builder#FAIL} if this method call encountered errors during compilation.
     */
    protected int compile(boolean incremental)
    {
        try 
        {
        messages.clear();

        // if there is no configuration, use the default... but don't populate this.configuration.
        OEMConfiguration tempOEMConfiguration;

        if (oemConfiguration == null)
        {
            tempOEMConfiguration = (OEMConfiguration) getDefaultConfiguration(true);
        }
        else
        {
            tempOEMConfiguration = OEMUtil.getLibraryConfiguration(constructCommandLine(oemConfiguration),
                                                                   oemConfiguration.keepLinkReport(),
                                                                   oemConfiguration.keepSizeReport(),
                                                                   OEMUtil.getLogger(logger, messages),
                                                                   resolver, mimeMappings);
        }

        // if c is null, which indicates problems, this method will return.
        if (tempOEMConfiguration == null)
        {
            clean(false /* cleanData */, false /* cleanCache */, false /* cleanOutput */);
            return FAIL;
        }
        else if (oemConfiguration != null && oemConfiguration.keepConfigurationReport())
        {
            configurationReport = OEMUtil.formatConfigurationBuffer(tempOEMConfiguration.cfgbuf);
        }

        if (oemConfiguration != null)
        {
            oemConfiguration.cfgbuf = tempOEMConfiguration.cfgbuf;
        }

        if (tempOEMConfiguration.configuration.benchmark())
        {
            benchmark = CompilerAPI.runBenchmark();
            benchmark.setTimeFilter(tempOEMConfiguration.configuration.getBenchmarkTimeFilter());
            benchmark.startTime(Benchmark.PRECOMPILE);
        }
        else
        {
            CompilerAPI.disableBenchmark();
        }

        // add archive files to the link checksum
        for (Map.Entry<String, VirtualFile>entry : files.entrySet())
        {
            tempOEMConfiguration.cfgbuf.calculateLinkChecksum(entry.getKey(), entry.getValue().getLastModified());
        }            

        // initialize some ThreadLocal variables...
        cc.run();
        OEMUtil.init(OEMUtil.getLogger(logger, messages), mimeMappings, meter, resolver, cc);

        // if there is any problem getting the licenses, this method will return.
        Map licenseMap = OEMUtil.getLicenseMap(tempOEMConfiguration.configuration);

        // if there are no SWC inputs, output an error and return -1
        VirtualFile[] includeLibs = (tempOEMConfiguration.configuration == null) ? null : tempOEMConfiguration.configuration.getCompilerConfiguration().getIncludeLibraries();
        if (sources.size() == 0 && classes.size() == 0 && namespaces.size() == 0 &&
            resourceBundles.size() == 0 && files.size() == 0 && stylesheets.size() == 0 &&
            (includeLibs == null || includeLibs.length == 0))
        {
            ThreadLocalToolkit.log(new ConfigurationException.NoSwcInputs( null, null, -1 ));
            clean(false /* cleanData */, false /* cleanCache */, false /* cleanOutput */);
            return FAIL;
        }

        // if nothing has been built yet, let's rebuild.
        if (data == null || !incremental)
        {
            String compilationType = (cacheName != null) ? "inactive" : "full";
            if (benchmark != null)
            {
                benchmark.benchmark2("Starting " + compilationType + " compile for " + getOutput(), true);
            }

            int returnValue = recompile(false, licenseMap, tempOEMConfiguration);

            if (benchmark != null)
            {
                benchmark.benchmark2("Ending " + compilationType + " compile for " + getOutput(), true);
            }

            clean(returnValue != OK, false, false);
            return returnValue;
        }

        CompilerAPI.setupHeadless(tempOEMConfiguration.configuration);
        NameMappings mappings = CompilerAPI.getNameMappings(tempOEMConfiguration.configuration), copy = mappings.copy();
        
        // Clear out ASC's userDefined, so definitions from a
        // previous compilation don't spill over into this one.
        data.perCompileData.userDefined.clear();

        data.sourcePath.clearCache();
        data.bundlePath.clearCache();
        data.resources.refresh();

        CompilerConfiguration compilerConfig = tempOEMConfiguration.configuration.getCompilerConfiguration();
        compilerConfig.setMetadataExport(true);

        if (output != null || directory != null)
        {
            OEMUtil.setGeneratedDirectory(compilerConfig, output != null ? output : directory);
        }

        Transcoder[] transcoders = WebTierAPI.getTranscoders(tempOEMConfiguration.configuration);
        SubCompiler[] compilers = WebTierAPI.getCompilers(compilerConfig, mappings, transcoders);
        
        CompilerSwcContext swcContext = new CompilerSwcContext(true);
        try
        {
            swcContext.load( compilerConfig.getLibraryPath(),
                             compilerConfig.getExternalLibraryPath(),
                             null,
                             compilerConfig.getIncludeLibraries(),
                             mappings,
                             I18nUtils.getTranslationFormat(compilerConfig),
                             data.swcCache );
        }
        catch (SwcException ex)
        {
            if (Trace.error)
            {
                ex.printStackTrace();
            }
            clean(false /* cleanData */, false /* cleanCache */, false /* cleanOutput */);
            return FAIL;
        }

        // save the generated swcCache if the class has a libraryCache.
        if (libraryCache != null)
        {
            libraryCache.setSwcCache(data.swcCache);
        }

        // If checksum is different, rebuild.
        if (OEMUtil.isRecompilationNeeded(data, swcContext, tempOEMConfiguration))
        {
            if (benchmark != null)
            {
                benchmark.benchmark2("Starting full compile for " + getOutput(), true);
            }

            clean(true /* cleanData */,
                  false /* cleanCache */,
                  false /* cleanOutput */,
                  true /* cleanConfig */,
                  false /* cleanMessages */,
                  false /* cleanThreadLocals */);
            int returnValue = recompile(true, licenseMap, tempOEMConfiguration);

            if (benchmark != null)
            {
                benchmark.benchmark2("Ending full compile for " + getOutput(), true);
            }

            clean(returnValue != OK, false, false);
            return returnValue;
        }

        // If --include-sources is different, rebuild.
        Set<VirtualFile> fileSet = null;
        if ((fileSet = processSources(compilerConfig)) == null)
        {
            clean(false /* cleanData */, false /* cleanCache */, false /* cleanOutput */);
            return FAIL;
        }

        // If --include-stylesheets is different, rebuild.
        fileSet.addAll(processStylesheets());

        boolean isFileSpecDifferent = isDifferent(data.fileSet, fileSet);
        if (isFileSpecDifferent)
        {
            if (benchmark != null)
            {
                benchmark.benchmark2("Starting full compile for " + getOutput(), true);
            }

            clean(true /* cleanData */,
                  false /* cleanCache */,
                  false /* cleanOutput */,
                  true /* cleanConfig */,
                  false /* cleanMessages */,
                  false /* cleanThreadLocals */);
            int returnValue = recompile(true, licenseMap, tempOEMConfiguration);
            
            if (benchmark != null)
            {
                benchmark.benchmark2("Ending full compile for " + getOutput(), true);
            }

            clean(returnValue != OK, false, false);
            return returnValue;
        }

        if (benchmark != null)
        {
            // We aren't really starting the compile here, but it's
            // the earliest that we know that it's going to be an
            // active compilation.
            benchmark.benchmark2("Starting active compile for " + getOutput(), true);
        }

        data.includes = new HashSet<String>(swcContext.getIncludes());
        data.excludes = new HashSet<String>(swcContext.getExterns());
        tempOEMConfiguration.configuration.addExterns( swcContext.getExterns() );
        tempOEMConfiguration.configuration.addIncludes( swcContext.getIncludes() );
        data.swcArchiveFiles = new HashMap<String, VirtualFile>(swcContext.getIncludeFiles());

        // The ToolsConfiguration expects class names in QName format.
        Set<String> qNameClasses = new HashSet<String>();
        for (String className : classes)
        {
            qNameClasses.add(NameFormatter.toColon(className));
        }

        // Allow -include-classes to override the -external-library-path.
        tempOEMConfiguration.configuration.removeExterns(qNameClasses);

        // If we want only inheritance dependencies of -include-classes then
        // add the classes to the includes list. When 
        // -include-inheritance-dependencies-only is turned on the dependency
        // walker will ignore all the classes except for the includes.
        if (tempOEMConfiguration.configuration.getIncludeInheritanceDependenciesOnly())
        {
            tempOEMConfiguration.configuration.addIncludes(qNameClasses);
        }
        
        int count = CompilerAPI.validateCompilationUnits(data.fileSpec, data.sourceList, data.sourcePath,
                                                         data.bundlePath, data.resources, swcContext,
                                                         data.classes, data.perCompileData,
                                                         tempOEMConfiguration.configuration);

        Map<String, Source> classes = new TreeMap<String, Source>();
        Set<SwcComponent> nsComponents = null;

        if ((nsComponents = processInputs(swcContext, copy, classes)) == null)
        {
            clean(false /* cleanData */, false /* cleanCache */, false /* cleanOutput */);
            return FAIL;
        }

        // If the other --include-* are different, build incrementally.
        boolean isDifferent = isDifferent(data.classes.keySet(), classes.keySet());
        if (count > 0 || isDifferent || isResourceBundleListDifferent() ||
            data.swcChecksum != swcContext.checksum())
        {
            // create a symbol table
            SymbolTable symbolTable = new SymbolTable(tempOEMConfiguration.configuration, data.perCompileData);
            data.configuration = tempOEMConfiguration.configuration;
            data.nsComponents = nsComponents;
            data.classes = classes;
            data.fileSet = fileSet;
            data.linkChecksum = tempOEMConfiguration.cfgbuf.link_checksum_ts();
            data.swcChecksum = swcContext.checksum();

            // compile
            data.sources = new ArrayList<Source>();
            data.units = compile(compilers, swcContext, symbolTable, mappings, licenseMap, classes, data.sources);

            boolean forcedToStop = CompilerAPI.forcedToStop();
            if (data.units == null || forcedToStop)
            {
                clean(true, false, false);
                return FAIL;
            }
            else
            {
                if (benchmark != null)
                {
                    benchmark.benchmark2("Ending active compile for " + getOutput(), true);
                }
                clean(false /* cleanData */, false /* cleanCache */, false /* cleanOutput */);
                return OK;
            }
        }
        else
        {
            if (benchmark != null)
            {
                benchmark.stopTime(Benchmark.PRECOMPILE, false);
                benchmark.startTime(Benchmark.POSTCOMPILE);
            }

            int retVal = SKIP;
            if (data != null)
            {
                CompilerAPI.displayWarnings(data.units);
                if (data.linkChecksum != tempOEMConfiguration.cfgbuf.link_checksum_ts())
                {
                    retVal = LINK;
                }
            }
            else
            {
                retVal = LINK;
            }
            data.linkChecksum = tempOEMConfiguration.cfgbuf.link_checksum_ts();
            data.swcChecksum = swcContext.checksum();

            if (CompilerAPI.forcedToStop()) retVal = FAIL;

            if (benchmark != null)
            {
                benchmark.benchmark2("Ending active compile for " + getOutput(), true);
            }

            if (retVal == LINK)
            {
                clean(false /* cleanData */,
                      false /* cleanCache */,
                      false /* cleanOutput */,
                      false /* cleanConfig */,
                      false /* cleanMessages */,
                      false /* cleanThreadLocals */);
            }
            else
            {
                clean(false /* cleanData */, false /* cleanCache */, false /* cleanOutput */);
            }

            return retVal;
        }
    }
        finally
        {
            // clean thread locals
            OEMUtil.clean();
        }
    }

    /**
     *
     * @param compilers
     * @param swcContext
     * @param symbolTable
     * @param licenseMap
     * @param classes
     */
    private List<CompilationUnit> compile(SubCompiler[] compilers, CompilerSwcContext swcContext,
                                          SymbolTable symbolTable, NameMappings nameMappings, Map licenseMap,
                                          Map<String, Source> classes, List<Source> sources)
    {
        List<CompilationUnit> units = null;
        Map<String, VirtualFile> rbFiles = new HashMap<String, VirtualFile>();

        try
        {
            if (benchmark != null)
            {
                for (int i = 0; i < compilers.length; i++)
                {
                    compilers[i].initBenchmarks();
                }

                benchmark.stopTime(Benchmark.PRECOMPILE, false);
            }

            units = CompilerAPI.compile(data.fileSpec, data.sourceList, classes.values(), data.sourcePath, data.resources,
                                        data.bundlePath, swcContext, symbolTable, nameMappings, data.configuration,
                                        compilers, new CompcPreLink(rbFiles, new ArrayList<String>(resourceBundles), false),
                                        licenseMap, sources);

            if (benchmark != null)
            {
                benchmark.startTime(Benchmark.POSTCOMPILE);
            }

            if ((benchmark != null) && (ThreadLocalToolkit.getLogger() != null))
            {
                if (compilerBenchmarks == null)
                    compilerBenchmarks = new HashMap<String, PerformanceData[]>();

                compilerBenchmarks.clear();

                flex2.compiler.Logger logger = ThreadLocalToolkit.getLogger();
                for (int i = 0; i < compilers.length; i++)
                {
                    SubCompiler compiler = compilers[i];
                    PerformanceData[] times = compiler.getBenchmarks();

                    if (times == null)
                        continue;

                    compiler.logBenchmarks(logger);
                    String compilerName = compiler.getName();
                    compilerBenchmarks.put(compilerName, times);
                }
            }
        }
        catch (CompilerException ex)
        {
            if (Trace.error)
            {
                ex.printStackTrace();
            }
            assert ThreadLocalToolkit.errorCount() > 0;
        }
        catch (SwcException ex)
        {
            if (Trace.error)
            {
                ex.printStackTrace();
            }
            assert ThreadLocalToolkit.errorCount() > 0;
        }
        catch (Throwable t)
        {
            if (Trace.error)
            {
                t.printStackTrace();
            }
            ThreadLocalToolkit.logError(t.getLocalizedMessage());
        }
        finally
        {
            data.sourcePath.clearCache();
            data.bundlePath.clearCache();
            data.resources.refresh();
            data.classes = classes;
            data.rbFiles = rbFiles;

            Map<String, VirtualFile> m = data.configuration.getCSSArchiveFiles();
            if (m != null)
            {
                data.cssArchiveFiles = new HashMap<String, VirtualFile>(m);
            }

            m = data.configuration.getL10NArchiveFiles();
            if (m != null)
            {
                data.l10nArchiveFiles = new HashMap<String, VirtualFile>(m);
            }

            OEMUtil.saveSignatureChecksums(units, data, data.configuration);
            OEMUtil.saveSwcFileChecksums(swcContext, data, data.configuration);
            // Make sure the swcContext is closed so we don't leave any dangling file handles
            swcContext.close();
        }

        return units;
    }

    /**
     * Links the <code>Library</code>. This method writes the output
     * to the output stream specified by the client. You should use a
     * buffered output stream for best performance.
     *
     * <p> This method is protected. In most circumstances, the client
     * only needs to call the <code>build()</code> method. Subclasses
     * can call this method so that it links and outputs the
     * application without recompiling.  If the OutputStream is
     * subsequently written to a file, subclasses should call
     * refreshLastModified().
     *
     * @param out The <code>OutputStream</code>.
     * @return The size of the application, in bytes.
     * @throws IOException Thrown when an I/O error occurs during linking.
     */
    protected long link(OutputStream out) throws IOException
    {
        if (data == null || data.units == null)
        {
            return 0;
        }

        boolean hasChanged = (oemConfiguration == null) ? false : oemConfiguration.hasChanged();
        flex2.compiler.common.Configuration config = null;

        if (hasChanged)
        {
            oemConfiguration = OEMUtil.getLinkerConfiguration(oemConfiguration.getLinkerOptions(),
                                                              oemConfiguration.keepLinkReport(),
                                                              oemConfiguration.keepSizeReport(),
                                                              OEMUtil.getLogger(logger, messages),
                                                              mimeMappings, resolver,
                                                              data.configuration,
                                                              oemConfiguration.newLinkerOptionsAfterCompile,
                                                              data.includes, data.excludes);
            if (oemConfiguration == null)
            {
                clean(false /* cleanData */,
                      false /* cleanCache */,
                      false /* cleanOutput */,
                      false /* cleanConfig */,
                      false /* cleanMessages */,
                      true /* cleanThreadLocals */);
                return 0;
            }

            config = oemConfiguration.configuration;
        }
        else
        {
            config = data.configuration;
        }

        if (config.benchmark())
        {
            benchmark = CompilerAPI.runBenchmark();
            benchmark.setTimeFilter(config.getBenchmarkTimeFilter());
        }
        else
        {
            CompilerAPI.disableBenchmark();
        }

        try
        {
            OEMUtil.init(OEMUtil.getLogger(logger, messages), mimeMappings, meter, resolver, cc);

            SimpleMovie temp = data.movie;
            data.movie = SwcAPI.link(config, data.units);

            // link
            SwcArchive archive = null;
            Map<String, VirtualFile> archiveFiles = new TreeMap<String, VirtualFile>();
            if (data.swcArchiveFiles != null) archiveFiles.putAll(data.swcArchiveFiles);
            if (data.cssArchiveFiles != null) archiveFiles.putAll(data.cssArchiveFiles);
            if (data.l10nArchiveFiles != null) archiveFiles.putAll(data.l10nArchiveFiles);
            archiveFiles.putAll(files);

            if (directory != null)
            {
                archive = new SwcDirectoryArchive(FileUtil.getCanonicalPath(directory));
                SwcAPI.exportSwc(archive,
                                                 archiveFiles,
                                                 this.stylesheets,
                                                 (LinkerConfiguration) config,
                                                 (SwcMovie) data.movie,
                                                 new ArrayList<SwcComponent>(data.nsComponents),
                                                 data.swcCache,
                                                 data.rbFiles);
            }

            long size = 0;

            // TODO PERFORMANCE: A lot of unnecessary recopying and buffering here
            ByteArrayOutputStream baos = null;
            String path = null;

            if (output != null)
            {
                path = FileUtil.getCanonicalPath(output);
            }

            // Flex Builder supplies an "out" and an "output", but
            // they really only use the "out", so check for that
            // first.
            if (out != null)
            {
                baos = new ByteArrayOutputStream();
                archive = new SwcLazyReadArchive(baos, path);
            }
            else if (output != null)
            {
                archive = new SwcLazyReadArchive(path);
            }

            SwcAPI.exportSwc(archive,
                             archiveFiles,
                             this.stylesheets,
                             (LinkerConfiguration) config,
                             (SwcMovie) data.movie,
                             new ArrayList<SwcComponent>(data.nsComponents),
                             data.swcCache,
                             data.rbFiles);
            
            if (out != null)
            {
                ByteArrayInputStream in = new ByteArrayInputStream(baos.toByteArray());
                FileUtil.streamOutput(in, out);
                size = baos.size();
            }
            else if (output != null)
            {
                size = output.length();
            }

            if (hasChanged && temp != null)
            {
                data.movie = temp;
            }

            return size;
        }
        catch (LinkerException ex)
        {
            assert ThreadLocalToolkit.errorCount() > 0;
            return 0;
        }
        catch (SwcException ex)
        {
            if (Trace.error)
            {
                ex.printStackTrace();
            }
            assert ThreadLocalToolkit.errorCount() > 0;
            return 0;
        }
        catch (Throwable t)
        {
            if (Trace.error)
            {
                t.printStackTrace();
            }
            ThreadLocalToolkit.logError(t.getLocalizedMessage());
            return 0;
        }
        finally
        {
            // clean thread locals
            OEMUtil.clean();            
    }
    }

    /**
     *
     * @param cleanData
     * @param cleanCache
     * @param cleanOutput
     */
    private void clean(boolean cleanData, boolean cleanCache, boolean cleanOutput)
    {
        clean(cleanData,
              cleanCache,
              cleanOutput,
              true /* cleanConfig */,
              false /* cleanMessages */,
              false /* cleanThreadLocals */);
    }

    /**
     *
     * @param cleanData
     * @param cleanCache
     * @param cleanOutput
     * @param cleanConfig
     * @param cleanMessages
     * @param cleanThreadLocals
     */
    private void clean(boolean cleanData, boolean cleanCache, boolean cleanOutput,
                       boolean cleanConfig, boolean cleanMessages, boolean cleanThreadLocals)
    {
        if (cleanThreadLocals)
        {
            OEMUtil.clean();
        }
        
        if (oemConfiguration != null && cleanConfig)
        {
            oemConfiguration.reset();
        }

        if (cleanData)
        {
            data = null;
            configurationReport = null;
        }

        if (cleanCache)
        {
            if (cacheName != null)
            {
                File dead = FileUtil.openFile(cacheName);
                if (dead != null && dead.exists())
                {
                    dead.delete();
                }
                cacheName = null;
            }
        }

        if (cleanOutput)
        {
            if (output != null && output.exists())
            {
                output.delete();
            }
        }

        if (cleanMessages)
        {
            messages.clear();
        }
    }

    /**
     *
     * @param s1
     * @param s2
     * @return
     */
    private <T> boolean isDifferent(Collection<T> s1, Collection<T> s2)
    {
        for (Iterator<T> i = s2.iterator(); i.hasNext(); )
        {
            if (!s1.contains(i.next()))
            {
                return true;
            }
        }

        return s1.size() > s2.size();
    }

    /**
     *
     * @return
     */
    private boolean isResourceBundleListDifferent()
    {
        int size1 = (data == null || data.rbFiles == null) ? 0 : data.rbFiles.size();
        int size2 = resourceBundles == null ? 0 : resourceBundles.size();
        return size1 != size2;
    }

    /**
     * Returns the cache of sources in the source list and source
     * path.  After building this Library object, the cache may be
     * saved and used to compile another Application or Library object
     * with common sources.
     *
     * @return The active cache. May be null.
     *
     * @since 4.5
     */
    public ApplicationCache getApplicationCache()
    {
        return applicationCache;
    }

    /**
     * Sets the cache for sources in the source list and source path.
     * After compiling this Library object, the cache may be reused to
     * build another Application or Library object with common
     * sources.
     *
     * @param applicationCache A reference to the application cache.
     *
     * @since 4.5
     */
    public void setApplicationCache(ApplicationCache applicationCache)
    {
        this.applicationCache = applicationCache;
    }

    // TODO: deprecate getSwcCache() and setSwcCache(), then add
    // getLibraryCache() and setLibraryCache().
    /**
     * Get the cache of swcs in the library path. After building this
     * Library object, the cache may be saved and used to compile
     * another Library or Application object that uses the same
     * library path.
     *
     * @return The active cache. May be null.
     *
     * @since 3.0
     */
    public LibraryCache getSwcCache()
    {
        return libraryCache;
    }

    /**
     * Set the cache for swcs in the library path. After compiling an
     * Library object, the cache may be reused to build another
     * Library or Application object that uses the same library path.
     *
     * @param swcCache A reference to an allocated swc cache.
     *
     * @since 3.0
     */
    public void setSwcCache(LibraryCache libraryCache)
    {
        this.libraryCache = libraryCache;
    }

    public void refreshLastModified()
    {
        String fileName = FileUtil.getCanonicalPath(output);
        File file = new File(fileName);
        long lastModified = file.lastModified();
        data.swcCache.setLastModified(fileName, lastModified);
    }
    
    @Override
    public Library clone()
    {
        Library clone;
        try
        {
            clone = (Library) super.clone();
        }
        catch ( CloneNotSupportedException e )
        {
            throw new RuntimeException( e ); //wont happen
        }
        clone.oemConfiguration = oemConfiguration.clone();
        return clone;
    }
}
