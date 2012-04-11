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

package flex2.tools;

import flash.localization.LocalizationManager;
import flash.localization.ResourceBundleLocalizer;
import flash.localization.XLRLocalizer;
import flash.swf.Movie;
import flash.util.Trace;
import flex2.compiler.*;
import flex2.compiler.common.*;
import flex2.compiler.config.*;
import flex2.compiler.extensions.ExtensionManager;
import flex2.compiler.extensions.IMxmlcExtension;
import flex2.compiler.i18n.I18nUtils;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.swc.SwcCache;
import flex2.compiler.swc.SwcException;
import flex2.compiler.util.Benchmark;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.NameMappings;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.linker.ConsoleApplication;
import flex2.linker.LinkerAPI;
import flex2.linker.LinkerException;

import java.io.*;
import java.util.*;
import java.util.Map.Entry;

/**
 * A command line tool for compiling Flex applications.  Despite the
 * name, in addition to .mxml files, this tool can be used to compile
 * other file formats, like .as and .css.
 *
 * @author Clement Wong
 */
public final class Mxmlc extends Tool
{
    public static final String FILE_SPECS = "file-specs";

    /**
     * The entry-point for Mxmlc.
     * Note that if you change anything in this method, make sure to check Compc, Shell, and
     * the server's CompileFilter to see if the same change needs to be made there.  You
     * should also inform the Zorn team of the change.
     *
     * @param args
     */
    public static void main(String[] args)
    {
        mxmlc(args);
        System.exit(ThreadLocalToolkit.errorCount());
    }

    public static void mxmlc(String[] args)
    {
        Transcoder[] transcoders = null;
        Benchmark benchmark = null;

        try
        {
            CompilerAPI.useAS3();

            // setup the path resolver
            CompilerAPI.usePathResolver();

            // set up for localizing messages
            LocalizationManager l10n = new LocalizationManager();
            l10n.addLocalizer( new XLRLocalizer() );
            l10n.addLocalizer( new ResourceBundleLocalizer() );
            ThreadLocalToolkit.setLocalizationManager(l10n);

            // setup the console logger. the configuration parser needs a logger.
            CompilerAPI.useConsoleLogger();

            // process configuration
            ConfigurationBuffer cfgbuf = new ConfigurationBuffer(CommandLineConfiguration.class, Configuration.getAliases());

            // Do not set this.  The file-specs should be included in the configuration buffer
            // checksum so changes to the class list can be detected during incremental builds.
            //cfgbuf.setDefaultVar(FILE_SPECS);
            DefaultsConfigurator.loadDefaults( cfgbuf );
            CommandLineConfiguration configuration = (CommandLineConfiguration) processConfiguration(
                l10n, "mxmlc", args, cfgbuf, CommandLineConfiguration.class, FILE_SPECS);

            // well, setup the logger again now that we know configuration.getWarnings()???
            CompilerAPI.useConsoleLogger(true, true, configuration.getWarnings(), true);
            CompilerAPI.setupHeadless(configuration);

            if (configuration.benchmark())
            {
                benchmark = CompilerAPI.runBenchmark();
                benchmark.startTime(Benchmark.PRECOMPILE);
            }
            else
            {
                CompilerAPI.disableBenchmark();
            }

            // make sure targetFile abstract pathname is an absolute path...
            VirtualFile targetFile = CompilerAPI.getVirtualFile(configuration.getTargetFile());
            WebTierAPI.checkSupportedTargetMimeType(targetFile);

            // mxmlc only wants to take one file.
            List<String> fileList = configuration.getFileList();
            if (fileList == null || fileList.size() != 1)
            {
                throw new ConfigurationException.OnlyOneSource( "filespec", null, -1);
            }

            List<VirtualFile> virtualFileList = CompilerAPI.getVirtualFileList(fileList);

            CompilerConfiguration compilerConfig = configuration.getCompilerConfiguration();
            NameMappings mappings = CompilerAPI.getNameMappings(configuration);

            // create a FileSpec... can reuse based on targetFile, debug settings, etc...
            FileSpec fileSpec = new FileSpec(Collections.<VirtualFile>emptyList(), WebTierAPI.getFileSpecMimeTypes());

            // create a SourcePath...
            VirtualFile[] asClasspath = compilerConfig.getSourcePath();
            SourceList sourceList = new SourceList(virtualFileList,
                                                   asClasspath,
                                                   targetFile,
                                                   WebTierAPI.getSourcePathMimeTypes());
            SourcePath sourcePath = new SourcePath(asClasspath,
                                                   targetFile,
                                                   WebTierAPI.getSourcePathMimeTypes(),
                                                   compilerConfig.allowSourcePathOverlap());

            ResourceContainer resources = new ResourceContainer();
            ResourceBundlePath bundlePath = new ResourceBundlePath(configuration.getCompilerConfiguration(), targetFile);

            ArrayList<Source> sources = new ArrayList<Source>();
            List<CompilationUnit> units = new ArrayList<CompilationUnit>();

            if (benchmark != null)
            {
                benchmark.benchmark(l10n.getLocalizedTextString(new InitialSetup()));
            }

            // load SWCs
            CompilerSwcContext swcContext = new CompilerSwcContext();
            SwcCache cache = new SwcCache();
            
            // lazy read should only be set by mxmlc/compc
            cache.setLazyRead(true);

            swcContext.load( compilerConfig.getLibraryPath(),
                             Configuration.getAllExcludedLibraries(compilerConfig, configuration),
                             compilerConfig.getThemeFiles(),
                             compilerConfig.getIncludeLibraries(),
                             mappings,
                             I18nUtils.getTranslationFormat(compilerConfig),
                             cache );
            configuration.addExterns( swcContext.getExterns() );
            configuration.addIncludes( swcContext.getIncludes() );
            configuration.getCompilerConfiguration().addThemeCssFiles( swcContext.getThemeStyleSheets() );

            // Figure out the name of the output file.
            File outputFile = getOutputFile(configuration, targetFile);

            // Checksums to figure out if incremental compile can be done.
            String incrementalFileName = null;
            SwcChecksums swcChecksums = null;

            // Should we attempt to build incrementally using the incremental file?
            boolean recompile = true;

            // If incremental compilation is enabled and the output file exists,
            // use the persisted store to figure out if a compile/link is necessary.
            // link without a compile is not supported without changes to the
            // persistantStore since units for Sources of type isSwcScriptOwner()
            // aren't stored/restored properly. units contains null entries for those
            // type of Source.  To force a rebuild, with -incremental specified, delete the
            // incremental file.
            if (configuration.getCompilerConfiguration().getIncremental())
            {
                swcChecksums = new SwcChecksums(swcContext, cfgbuf, configuration);

                // If incremental compilation is enabled, read the cached
                // compilation units...  Do not include the checksum in the file name so that
                // cache files don't pile up as the configuration changes.  There needs
                // to be a 1-to-1 mapping between the swc file and the cache file.
                incrementalFileName = outputFile.getPath() + ".cache";

                // If the output file doesn't exist don't bother loading the
                // cache since a recompile is needed.
                if (outputFile.exists())
                {
                    RandomAccessFile incrementalFile = null;
                    try
                    {
                        incrementalFile = new RandomAccessFile(incrementalFileName, "r");

                        // For loadCompilationUnits, loadedChecksums[1] must match
                        // the cached value else IOException is thrown.
                        int[] loadedChecksums = swcChecksums.copy();

                        CompilerAPI.loadCompilationUnits(configuration, fileSpec, sourceList, sourcePath, resources, bundlePath, null, /* sources */
                        null, /*units */
                        loadedChecksums, swcChecksums.getSwcDefSignatureChecksums(), swcChecksums.getSwcFileChecksums(), null, /* archiveFiles */
                        incrementalFile, incrementalFileName, null /* font manager */);

                        if (!(swcChecksums.isRecompilationNeeded(loadedChecksums) && !swcChecksums.isRelinkNeeded(loadedChecksums)))
                        {
                            recompile = false;
                        }
                    }
                    catch (FileNotFoundException ex)
                    {
                            // the incremental file doesn't exist
                            ThreadLocalToolkit.logDebug(ex.getLocalizedMessage());
                    }
                    catch (IOException ex)
                    {
                        // error loading the incremental file - most likely checksum
                        // mismatch or format mismatch
                        ThreadLocalToolkit.logInfo(ex.getLocalizedMessage());
                    }
                    finally
                    {
                        if (incrementalFile != null)
                        {
                            try
                            {
                                incrementalFile.close();
                            }
                            catch (IOException ex)
                            {
                            }
                            // If the load failed, or recompilation is needed, reset
                            // all the variables to their original state.
                            if (recompile)
                            {
                                fileSpec = new FileSpec(Collections.<VirtualFile>emptyList(), WebTierAPI.getFileSpecMimeTypes());
                                sourceList = new SourceList(virtualFileList,
                                                            asClasspath,
                                                            targetFile,
                                                            WebTierAPI.getSourcePathMimeTypes());
                                sourcePath = new SourcePath(asClasspath,
                                                            targetFile,
                                                            WebTierAPI.getSourcePathMimeTypes(),
                                                            compilerConfig.allowSourcePathOverlap());
                                resources = new ResourceContainer();
                                bundlePath = new ResourceBundlePath(configuration.getCompilerConfiguration(), targetFile);
                            }
                        }
                    }
                }
            }

            VirtualFile projector = configuration.getProjector();
            boolean createProjector = (projector != null && projector.getName().endsWith("avmplus.exe"));

            // Validate CompilationUnits in FileSpec and SourcePath.  If
            // count > 0 something changed.
            int count = CompilerAPI.validateCompilationUnits(
                    fileSpec, sourceList, sourcePath, bundlePath, resources,
                    swcContext,
                    null    /* perCompileData */,
                    configuration);
            recompile = recompile || (count > 0);

            if (recompile)
            {
                // Get standard bundle of compilers, transcoders.
                transcoders = WebTierAPI.getTranscoders( configuration );
                SubCompiler[] compilers = WebTierAPI.getCompilers(compilerConfig, mappings, transcoders);

                if (benchmark != null)
                {
                    benchmark.stopTime(Benchmark.PRECOMPILE, false);
                }

                units = CompilerAPI.compile(fileSpec, sourceList,
                                            null, /* classes */
                                            sourcePath, resources, bundlePath, swcContext,
                                            mappings, configuration, compilers,
                                            createProjector ? null : new PreLink(),
                                            configuration.getLicensesConfiguration().getLicenseMap(),
                                            sources);

                if (benchmark != null)
                {
                    benchmark.startTime(Benchmark.POSTCOMPILE);
                }

                OutputStream swfOut = new BufferedOutputStream(new FileOutputStream(outputFile));
                PostLink postLink = null;

                if (configuration.optimize() && !configuration.debug())
                {
                    postLink = new PostLink(configuration);
                }

                // link
                if (createProjector)
                {
                    ConsoleApplication app = LinkerAPI.linkConsole(units, postLink, configuration);
                    
                    createProjector(configuration, projector, app, swfOut);
                }
                else
                {
                    Movie movie = LinkerAPI.link(units, postLink, configuration);
                    
                    if (projector != null)
                    {
                        createProjector(configuration, projector, movie, swfOut);
                    }
                    else
                    {
                        CompilerAPI.encode(configuration, movie, swfOut);
                    }
                }

                swfOut.flush();
                swfOut.close();

                // If incremental compilation is enabled, save the compilation units.
                if (configuration.getCompilerConfiguration().getIncremental())
                {
                    // Make sure the checksums are all current.
                    swcChecksums.saveChecksums(units);

                    RandomAccessFile incrementalFile = null;
                    try
                    {
                        incrementalFile = new RandomAccessFile(incrementalFileName, "rw");

                        // In case we're reusing the file, clear it.
                        incrementalFile.setLength(0);

                        CompilerAPI.persistCompilationUnits(
                                configuration, fileSpec, sourceList, sourcePath,
                                resources, bundlePath,
                                sources,   /* sources */
                                units,   /* units */
                                swcChecksums.getChecksums(),
                                swcChecksums.getSwcDefSignatureChecksums(),
                                swcChecksums.getSwcFileChecksums(),
                                null,   /* archiveFiles */
                                "", incrementalFile);
                    }
                    catch (IOException ex)
                    {
                        ThreadLocalToolkit.logInfo(ex.getLocalizedMessage());

                        // Get rid of the cache file since the write failed.
                        new File(incrementalFileName).deleteOnExit();
                    }
                    finally
                    {
                        if (incrementalFile != null)
                        {
                            try
                            {
                                incrementalFile.close();
                            }
                            catch (IOException ex)
                            {
                            }
                        }
                    }
                }

                ThreadLocalToolkit.log(new OutputMessage(FileUtil.getCanonicalPath(outputFile),
                        Long.toString(outputFile.length())));
            }
            else
            {
                if (benchmark != null)
                {
                    benchmark.stopTime(Benchmark.PRECOMPILE, false);
                    benchmark.startTime(Benchmark.POSTCOMPILE);
                }

                // swf is already up-to-date so no need to compile/link or rewrite file
                ThreadLocalToolkit.log(new NoUpdateMessage(FileUtil.getCanonicalPath(outputFile)));
            }
            
            Set<IMxmlcExtension> extensions = ExtensionManager.getMxmlcExtensions( configuration.getCompilerConfiguration().getExtensionsConfiguration().getExtensionMappings() );
            for ( IMxmlcExtension extension : extensions )
            {
                if(ThreadLocalToolkit.errorCount() == 0) {
                    extension.run( args );
                }
            }        
        
        }
        catch (ConfigurationException ex)
        {
        	ThreadLocalToolkit.logInfo( getStartMessage( "mxmlc" ) );
            processConfigurationException(ex, "mxmlc");
        }
        catch (CompilerException ex)
        {
            assert ThreadLocalToolkit.errorCount() > 0;
        }
        catch (LinkerException ex)
        {
            assert ThreadLocalToolkit.errorCount() > 0;
        }
        catch (SwcException ex)
        {
            assert ThreadLocalToolkit.errorCount() > 0;
        }
        catch (Throwable t) // IOException, Throwable
        {
            ThreadLocalToolkit.logError(t.getLocalizedMessage());

            if (Trace.error)
            {
                t.printStackTrace();
            }
        }
        finally
        {
            if (benchmark != null)
            {
                if ((ThreadLocalToolkit.errorCount() == 0) &&
                    benchmark.hasStarted(Benchmark.POSTCOMPILE))
                {
                    benchmark.stopTime(Benchmark.POSTCOMPILE, false);
                }
                benchmark.totalTime();
                benchmark.peakMemoryUsage(true);
            }

            if (transcoders != null)
            {
                for (Transcoder element : transcoders)
                {
                    element.clear();
                }
            }

            CompilerAPI.removePathResolver();
        }
    }

    private static File getOutputFile(CommandLineConfiguration configuration, VirtualFile targetFile)
    {
        String name;
        VirtualFile projector = configuration.getProjector();
        boolean createProjector = (projector != null && projector.getName().endsWith("avmplus.exe"));

        if (createProjector)
        {
            // output .exe
            name = configuration.getOutput();
            if (name == null)
            {
                name = targetFile.getName();
                name = name.substring(0, name.lastIndexOf('.')) + ".exe";
            }
        }
        else
        {
            // output SWF
            name = configuration.getOutput();
            if (name == null)
            {
                name = targetFile.getName();
                if (projector != null)
                {
                    name = name.substring(0, name.lastIndexOf('.')) + ".exe";
                }
                else
                {
                    name = name.substring(0, name.lastIndexOf('.')) + ".swf";
                }
            }
        }

        return FileUtil.openFile(name, true);
    }

    public static void createProjector(Configuration config, VirtualFile projector, ConsoleApplication app, OutputStream out)
    {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try
        {
            CompilerAPI.encode(app, baos);
            createProjector(config, projector, baos, out);
        }
        catch (IOException ex)
        {
        }
    }

    public static void createProjector(Configuration config, VirtualFile projector, Movie movie, OutputStream out)
    {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try
        {
            CompilerAPI.encode(config, movie, baos);
            createProjector(config, projector, baos, out);
        }
        catch (IOException ex)
        {
        }
        finally
        {
        }
    }

    public static long createProjector(Configuration config, VirtualFile projector, ByteArrayOutputStream baos, OutputStream out)
    {
        long size = 0;
        BufferedInputStream in = null;
        try
        {
            in = new BufferedInputStream(projector.getInputStream());
            FileUtil.streamOutput(in, out);
            byte header[] = new byte[8];
            header[0] = 0x56;
            header[1] = 0x34;
            header[2] = 0x12;
            header[3] = (byte) 0xFA;
            header[4] = (byte) (baos.size() & 0xFF);
            header[5] = (byte) ((baos.size() >> 8) & 0xFF);
            header[6] = (byte) ((baos.size() >> 16) & 0xFF);
            header[7] = (byte) ((baos.size() >> 24) & 0xFF);
            out.write(baos.toByteArray());
            out.write(header);
            out.flush();
            size = projector.size() + baos.size() + 8;
        }
        catch (IOException ex)
        {
            size = 0;
        }
        finally
        {
            if (in != null) { try { in.close(); } catch (IOException ex) {} }
        }

        return size;
    }

    static private String l10nConfigPrefix = "flex2.configuration";

    public static Configuration processConfiguration( LocalizationManager lmgr, String program, String[] args,
            ConfigurationBuffer cfgbuf, Class<? extends Configuration> cls, String defaultVar)
        throws ConfigurationException, IOException
    {
            return processConfiguration(lmgr, program, args, cfgbuf, cls, defaultVar, false);
    }

    public static Configuration processConfiguration( LocalizationManager lmgr, String program, String[] args,
                                               ConfigurationBuffer cfgbuf, Class<? extends Configuration> cls, String defaultVar,
                                               boolean ignoreUnknownItems)
        throws ConfigurationException, IOException
    {
        SystemPropertyConfigurator.load( cfgbuf, "flex" );

        // Parse the command line a first time, to peak at stuff like
        // "flexlib" and "load-config".  The first parse is thrown
        // away after that and we intentionally parse a second time
        // below.  See note below.
        CommandLineConfigurator.parse( cfgbuf, defaultVar, args);

        String flexlib = cfgbuf.getToken( "flexlib" );
        if (flexlib == null)
        {
            String appHome = System.getProperty( "application.home" );

            if (appHome == null)
            {
                appHome = ".";
            }
            else
            {
                appHome += File.separator + "frameworks";       // FIXME - need to eliminate this from the compiler
            }
            cfgbuf.setToken( "flexlib", appHome );
        }

        // Framework Type
        // halo, gumbo, interop...
        String framework = cfgbuf.getToken("framework");
        if (framework == null)
        {
            cfgbuf.setToken("framework", "halo");
        }

        String configname = cfgbuf.getToken( "configname" );
        if (configname == null)
        {
            cfgbuf.setToken( "configname", "flex" );
        }

        String buildNumber = cfgbuf.getToken( "build.number" );
        if (buildNumber == null)
        {
            if ("".equals(VersionInfo.getBuild()))
               {
                buildNumber = "workspace";
               }
            else
            {
                buildNumber = VersionInfo.getBuild();
            }
            cfgbuf.setToken( "build.number", buildNumber);
        }


        // We need to intercept "help" options because we want to try to correctly
        // interpret them even when the rest of the configuration is totally screwed up.

        if (cfgbuf.getVar( "version" ) != null)
        {
            System.out.println(VersionInfo.buildMessage());
            System.exit(0);
        }

        processHelp(cfgbuf, program, defaultVar, lmgr, args);

        // at this point, we should have enough to know both
        // flexlib and the config file.

        ConfigurationPathResolver configResolver = new ConfigurationPathResolver();

        List<ConfigurationValue> configs = cfgbuf.peekConfigurationVar( "load-config" );

        if (configs != null)
        {
            for (ConfigurationValue cv : configs)
            {
                for (String path : cv.getArgs())
                {
                    VirtualFile configFile = ConfigurationPathResolver.getVirtualFile( path, configResolver, cv );
                    cfgbuf.calculateChecksum(configFile);
                    InputStream in = configFile.getInputStream();
                    if (in != null)
                    {
                        FileConfigurator.load(cfgbuf, new BufferedInputStream(in), configFile.getName(),
                                              configFile.getParent(), "flex-config", ignoreUnknownItems);
                    }
                    else
                    {
                        throw new ConfigurationException.ConfigurationIOError( path, cv.getVar(), cv.getSource(), cv.getLine() );
                    }
                }
            }
        }

        PathResolver resolver = ThreadLocalToolkit.getPathResolver();
        // Load project file, if any...
        List fileValues = cfgbuf.getVar( FILE_SPECS );
        if ((fileValues != null) && (fileValues.size() > 0))
        {
            ConfigurationValue cv = (ConfigurationValue) fileValues.get( fileValues.size() - 1 );
            if (cv.getArgs().size() > 0)
            {
                String val = cv.getArgs().get( cv.getArgs().size() - 1 );
                int index = val.lastIndexOf( '.' );
                if (index != -1)
                {
                    String project = val.substring( 0, index ) + "-config.xml";
                    VirtualFile projectFile = resolver.resolve( configResolver, project );
                    if (projectFile != null)
                    {
                        cfgbuf.calculateChecksum(projectFile);
                        InputStream in = projectFile.getInputStream();
                        if (in != null)
                        {
                            FileConfigurator.load( cfgbuf, new BufferedInputStream(in),
                                                   projectFile.getName(), projectFile.getParent(), "flex-config",
                                                   ignoreUnknownItems);
                        }
                    }
                }
            }
        }

        // The command line needs to take precedence over all defaults and config files.
        // This is a bit gross, but by simply re-merging the command line back on top,
        // we will get the behavior we want.
        cfgbuf.clearSourceVars( CommandLineConfigurator.source );
        CommandLineConfigurator.parse(cfgbuf, defaultVar, args);

        ToolsConfiguration toolsConfiguration = null;
        try
        {
            toolsConfiguration = (ToolsConfiguration)cls.newInstance();
            toolsConfiguration.setConfigPathResolver( configResolver );
        }
        catch (Exception e)
        {
            LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
            throw new ConfigurationException(l10n.getLocalizedTextString(new CouldNotInstantiate(toolsConfiguration)));
        }
        cfgbuf.commit( toolsConfiguration );

        // enterprise service config file has other config file dependencies. add them here...
        calculateServicesChecksum(toolsConfiguration, cfgbuf);

        toolsConfiguration.validate( cfgbuf );

        // consolidate license keys...
        VirtualFile licenseFile = toolsConfiguration.getLicenseFile();
        if (licenseFile != null)
        {
            Map<String, String> fileLicenses = Tool.getLicenseMapFromFile(licenseFile.getName());
            Map<String, String> cmdLicenses = toolsConfiguration.getLicensesConfiguration().getLicenseMap();
            if (cmdLicenses == null)
            {
                toolsConfiguration.getLicensesConfiguration().setLicenseMap(fileLicenses);
            }
            else if (fileLicenses != null)
            {
                fileLicenses.putAll(cmdLicenses);
                toolsConfiguration.getLicensesConfiguration().setLicenseMap(fileLicenses);
            }
        }

        return toolsConfiguration;
    }

    static void processHelp(ConfigurationBuffer cfgbuf, String program, String defaultVar, LocalizationManager lmgr, String[] args)
    {
        if (cfgbuf.getVar( "help" ) != null)
        {
            Set<String> keywords = new HashSet<String>();
            List vals = cfgbuf.getVar( "help" );
            for (Iterator it = vals.iterator(); it.hasNext();)
            {
                ConfigurationValue val = (ConfigurationValue) it.next();
                for (Object element : val.getArgs())
                {
                    String keyword = (String) element;
                    while (keyword.startsWith( "-" ))
                        keyword = keyword.substring( 1 );
                    keywords.add( keyword );
                }
            }
            if (keywords.size() == 0)
            {
                keywords.add( "help" );
            }

            ThreadLocalToolkit.logInfo( getStartMessage( program ) );
            System.out.println();
            System.out.println( CommandLineConfigurator.usage( program, defaultVar, cfgbuf, keywords, lmgr, l10nConfigPrefix ));
            System.exit( 1 );
        }

        if (args.length == 0 && ("mxmlc".equals(program) || "compc".equals(program)))
        {
        	ThreadLocalToolkit.logInfo( getStartMessage( program ) );
            System.err.println( CommandLineConfigurator.brief( program, defaultVar, lmgr, l10nConfigPrefix ));
            System.exit(1);
        }
    }

    private static void calculateServicesChecksum(Configuration config, ConfigurationBuffer cfgbuf)
    {
        Map<String,Long> services = null;
        if (config.getCompilerConfiguration().getServicesDependencies() != null)
        {
            services = config.getCompilerConfiguration().getServicesDependencies().getConfigPaths();
        }

        if (services != null)
        {
            for (Entry<String, Long> entry : services.entrySet())
            {
                cfgbuf.calculateChecksum(entry.getKey(), entry.getValue());
            }
        }
    }

    public static void processConfigurationException(ConfigurationException ex, String program)
    {
        ThreadLocalToolkit.log( ex );

        if (ex.source == null || ex.source.equals("command line"))
        {
            Map<String, String> p = new HashMap<String, String>();
            p.put( "program", program );
            String help = ThreadLocalToolkit.getLocalizationManager().getLocalizedTextString( "flex2.compiler.CommandLineHelp", p );
            if (help != null)
            {
                // "Use '" + program + " -help' for information about using the command line.");
                System.err.println( help );
            }
        }
    }

    private static String getStartMessage( String program )
    {
        LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();

        return l10n.getLocalizedTextString(new StartMessage(program, VersionInfo.buildMessage()));
    }

    // error messages

    public static class InitialSetup extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 1333039844101599298L;

        public InitialSetup()
        {
            super();
        }
    }

    public static class DumpConfig extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 953067728556782737L;

        public DumpConfig(String filename)
        {
            this.filename = filename;
        }
        public final String filename;
    }

    public static class LoadedSWCs extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 5287457959220324715L;

        public LoadedSWCs(int num)
        {
            super();
            this.num = num;
        }

        public final int num;
    }

    public static class CouldNotInstantiate extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = -8970190710117830662L;

        public CouldNotInstantiate(Configuration config)
        {
            super();
            this.config = config;
        }

        public final Configuration config;
    }

    public static class StartMessage extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 4807822711658875257L;

        public StartMessage(String program, String buildMessage)
        {
            super();
            this.program = program;
            this.buildMessage = buildMessage;
        }

        public final String program, buildMessage;
    }

    public static class OutputMessage extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = -4859993585489031839L;

        public String name;
        public String length;

        public OutputMessage(String name, String length)
        {
            this.name = name;
            this.length = length;
        }
    }

    public static class NoUpdateMessage extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 6943388392279226490L;
        public String name;

        public NoUpdateMessage(String name)
        {
            this.name = name;
        }
    }

}

