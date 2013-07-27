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

package flex2.compiler;

import flash.fonts.FontManager;
import flash.localization.LocalizationManager;
import flash.localization.ResourceBundleLocalizer;
import flash.localization.XLRLocalizer;
import flash.swf.Movie;
import flash.swf.MovieEncoder;
import flash.swf.TagEncoder;
import flash.swf.TagEncoderReporter;
import flash.swf.tools.SizeReport;
import flash.util.FileUtils;

import flex2.compiler.config.ServicesDependenciesWrapper;

import flex2.compiler.as3.As3Compiler;
import flex2.compiler.as3.SignatureExtension;
import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.common.Configuration;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.common.FramesConfiguration;
import flex2.compiler.common.LocalFilePathResolver;
import flex2.compiler.common.PathResolver;
import flex2.compiler.common.SinglePathResolver;
import flex2.compiler.common.FramesConfiguration.FrameInfo;
import flex2.compiler.extensions.ExtensionManager;
import flex2.compiler.extensions.IPreCompileExtension;
import flex2.compiler.i18n.I18nUtils;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.InMemoryFile;
import flex2.compiler.io.LocalFile;
import flex2.compiler.io.ResourceFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.swc.SwcScript;
import flex2.compiler.util.*;
import flex2.compiler.util.graph.Algorithms;
import flex2.compiler.util.graph.DependencyGraph;
import flex2.compiler.util.graph.Vertex;
import flex2.compiler.util.graph.Visitor;
import flex2.linker.ConsoleApplication;
import flex2.linker.LinkerConfiguration;
import flex2.linker.LinkerException;
import flex2.linker.SimpleMovie;
import flex2.tools.CompcPreLink;
import flex2.tools.oem.ProgressMeter;

import java.io.IOException;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.io.File;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.util.*;
import java.util.Map.Entry;

import macromedia.asc.parser.Tokens;
import macromedia.asc.semantics.ObjectValue;
import macromedia.asc.semantics.Slot;
import macromedia.asc.semantics.TypeValue;
import macromedia.asc.semantics.VariableSlot;
import macromedia.asc.util.Context;
import macromedia.asc.util.ContextStatics;
import macromedia.asc.util.Names;

/**
 * This class orchestrates delegation to the subcompilers using
 * batch1() when -conservative is true or batch2(), the default.  It
 * also handles common tasks like validating CompilationUnit's before
 * an incremental compilation, resolving dependences, loading a cache
 * from a previous compilation, and storing a compilation cache.
 *
 * @see flex2.compiler.SubCompiler
 * @see flex2.compiler.PersistentStore
 * @see flex2.compiler.abc.AbcCompiler
 * @see flex2.compiler.as3.As3Compiler
 * @see flex2.compiler.css.CssCompiler
 * @see flex2.compiler.fxg.FXGCompiler
 * @see flex2.compiler.i18n.I18nCompiler
 * @see flex2.compiler.mxml.MxmlCompiler
 * @author Clement Wong
 */
public final class CompilerAPI
{
    private final static int INHERITANCE = 1;
    private final static int NAMESPACES = 2;
    private final static int TYPES = 3;
    private final static int EXPRESSIONS = 4;

    public static void useAS3()
    {
        // do this so there is no need to start java with -DAS3 and -DAVMPLUS...
        // this will likely not work in server environment.
        System.setProperty("AS3", "");
        System.setProperty("AVMPLUS", "");
    }

    public static void useConsoleLogger()
    {
        useConsoleLogger(true, true, true, true);
    }

    public static void useConsoleLogger(boolean isInfoEnabled, boolean isDebugEnabled, boolean isWarningEnabled, boolean isErrorEnabled)
    {
        ThreadLocalToolkit.setLogger(new ConsoleLogger(isInfoEnabled, isDebugEnabled, isWarningEnabled, isErrorEnabled));
    }

    public static Benchmark runBenchmark()
    {
        Benchmark b = ThreadLocalToolkit.getBenchmark();

        if (b == null)
        {
            try
            {
                String className = System.getProperty("flex2.compiler.benchmark");

                if (className != null)
                {
                    Class benchmarkClass = Class.forName(className, true, Thread.currentThread().getContextClassLoader());
                    b = (Benchmark) benchmarkClass.newInstance();
                }
            }
            catch (Exception e)
            {
                assert false : e.toString();
            }

            if (b == null)
            {
                b = new Benchmark();
            }

            ThreadLocalToolkit.setBenchmark(b);
            ThreadLocalToolkit.resetBenchmark();
        }

        return b;
    }

    public static void disableBenchmark()
    {
        ThreadLocalToolkit.setBenchmark(null);
    }

    public static void usePathResolver()
    {
        usePathResolver(null);
    }

    public static void usePathResolver(SinglePathResolver resolver)
    {
        PathResolver pathResolver = new PathResolver();
        if (resolver != null)
        {
            pathResolver.addSinglePathResolver(resolver);
        }
        pathResolver.addSinglePathResolver( LocalFilePathResolver.getSingleton() );
        pathResolver.addSinglePathResolver( URLPathResolver.getSingleton() );
        ThreadLocalToolkit.setPathResolver(pathResolver);
    }

    public static void removePathResolver()
    {
        ThreadLocalToolkit.setPathResolver(null);
        ThreadLocalToolkit.resetResolvedPaths();
    }

    public static void setupHeadless(Configuration configuration)
    {
        if (configuration.getCompilerConfiguration().headlessServer())
        {
            try
            {
                // needed for J#, which does not support setProperty method on System
                java.util.Properties systemProps = java.lang.System.getProperties();
                systemProps.put("java.awt.headless", "true");
                java.lang.System.setProperties(systemProps);
            }
            catch (SecurityException securityException)
            {
                // log warning for users who need to set property via command line due to policy settings
                ThreadLocalToolkit.log(new UnableToSetHeadless());
            }
        }
    }

    public static NameMappings getNameMappings(Configuration configuration)
    {
        NameMappings mappings = new NameMappings();
        Map<String, List<VirtualFile>> manifests = configuration.getCompilerConfiguration().getNamespacesConfiguration().getManifestMappings();
        if (manifests != null)
        {
            Iterator<Entry<String, List<VirtualFile>>> entryIterator = manifests.entrySet().iterator();
            while (entryIterator.hasNext())
            {
                Entry<String, List<VirtualFile>> entry = entryIterator.next();
                String ns = entry.getKey();
                List<VirtualFile> files = entry.getValue();
                Iterator<VirtualFile> filesIterator = files.iterator();
                while (filesIterator.hasNext())
                {
                    VirtualFile file = filesIterator.next();
                    ManifestParser.parse(ns, file, mappings);
                }
            }
        }
        return mappings;
    }

    private static final int preprocess                 = (1 << 1);
    private static final int parse1                     = (1 << 2);
    private static final int parse2                     = (1 << 3);
    private static final int analyze1                   = (1 << 4);
    private static final int analyze2                   = (1 << 5);
    private static final int analyze3                   = (1 << 6);
    private static final int analyze4                   = (1 << 7);
//    private static final int resolveInheritance         = (1 << 8);
//    private static final int sortInheritance            = (1 << 9);
    private static final int resolveType                = (1 << 10);
//    private static final int importType                 = (1 << 11);
//    private static final int resolveExpression          = (1 << 12);
    private static final int generate                   = (1 << 13);
    private static final int resolveImportStatements    = (1 << 14);
    private static final int adjustQNames               = (1 << 15);
    private static final int extraSources               = (1 << 16);

    /**
     * CompilerAPI.batch1() is used when -conservative is specified.
     *
     * It waits until*every* source has completed each compilation stage (e.g. analyze1())
     * before continuing (e.g. to analyze2())
     */
    private static void batch1(List<Source> sources, List<CompilationUnit> units,
                               DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph,
                               SymbolTable symbolTable, flex2.compiler.SubCompiler[] compilers, SourceList sourceList,
                               SourcePath sourcePath, ResourceContainer resources, CompilerSwcContext swcContext,
                               Configuration configuration)
    {
        int start = 0, end = sources.size();

        while (start < end)
        {
            if (!preprocess(sources, compilers, start, end, symbolTable.getSuppressWarningsIncremental()))
            {
                break;
            }

            if (tooManyErrors() || forcedToStop()) break;

            if (!parse1(sources, units, igraph, dgraph, compilers, symbolTable, start, end))
            {
                break;
            }

            if (tooManyErrors() || forcedToStop()) break;

            // C: context-free above this line...

            resolveInheritance(sources, igraph, dgraph, symbolTable, sourceList, sourcePath, resources, swcContext, start, end);
            addGeneratedSources(sources, igraph, dgraph, resources, symbolTable, configuration, start, end);

            start = end;
            end = sources.size();

            if (start < end)
            {
                continue;
            }

            if (!sortInheritance(sources, units, igraph))
            {
                break;
            }

            if (!parse2(sources, compilers, symbolTable))
            {
                break;
            }

            if (tooManyErrors() || forcedToStop()) break;

            if (!analyze(sources, compilers, symbolTable, 1))
            {
                break;
            }

            if (tooManyErrors() || forcedToStop()) break;

            resolveNamespace(sources, igraph, dgraph, symbolTable, sourceList, sourcePath, resources, swcContext, 0, end);
            addGeneratedSources(sources, igraph, dgraph, resources, symbolTable, configuration, 0, end);

            start = end;
            end = sources.size();

            if (start < end)
            {
                continue;
            }

            if (!analyze(sources, compilers, symbolTable, 2))
            {
                break;
            }

            if (tooManyErrors() || forcedToStop()) break;

            resolveType(sources, units, igraph, dgraph, symbolTable, sourceList, sourcePath, resources, swcContext);

            final CompilerConfiguration config = (configuration != null) ? configuration.getCompilerConfiguration() : null;
            if (config != null && config.strict())
            {
                resolveImportStatements(sources, units, sourcePath, swcContext);
            }

            // C: If --coach is turned on, do resolveExpression() here...
            if (config != null && (config.strict() || config.warnings()))
            {
                resolveExpression(sources, units, igraph, dgraph, symbolTable, sourceList,
                                  sourcePath, resources, swcContext, configuration);
            }

            start = end;
            end = sources.size();

            if (start < end)
            {
                continue;
            }

            if (!analyze(sources, compilers, symbolTable, 3))
            {
                break;
            }

            if (tooManyErrors() || forcedToStop()) break;

            if (!analyze(sources, compilers, symbolTable, 4))
            {
                break;
            }

            if (tooManyErrors() || forcedToStop()) break;

            if (!generate(sources, units, compilers, symbolTable))
            {
                break;
            }

            if (tooManyErrors() || forcedToStop()) break;

            markDone(sources, units);

            if (!postprocess(sources, units, compilers, symbolTable))
            {
                break;
            }

            if (tooManyErrors() || forcedToStop()) break;

            resolveExpression(sources, units, igraph, dgraph, symbolTable, sourceList, sourcePath, resources, swcContext, configuration);
            addGeneratedSources(sources, igraph, dgraph, resources, symbolTable, configuration, 0, end);

            start = end;
            end = sources.size();
        }

        adjustQNames(units, igraph, symbolTable);
    }

    /**
     * CompilerAPI.batch2() is the default algorithm (@see CompilerAPI.batch1()).
     *
     * It tries to release resources (such as the syntax tree) early by allowing sources
     * to reach generate() as soon as possible, once all their dependencies have been met.
     */
    private static void batch2(List<Source> sources, List<CompilationUnit> units,
                               DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph,
                               SymbolTable symbolTable, flex2.compiler.SubCompiler[] compilers, SourceList sourceList,
                               SourcePath sourcePath, ResourceContainer resources, CompilerSwcContext swcContext,
                               Configuration configuration)
    {
        Benchmark benchmark = ThreadLocalToolkit.getBenchmark();
        int benchmarkCompilingDetails = benchmark == null ? -1 : configuration.getBenchmarkCompilerDetails();

        if (benchmarkCompilingDetails > 4)
        {
            benchmark.benchmark2(
                    ThreadLocalToolkit.getLocalizationManager().getLocalizedTextString(new BatchTime("start", "")), true);
        }

        CompilerConfiguration config = (configuration != null) ? configuration.getCompilerConfiguration() : null;
        List<Source> targets = new ArrayList<Source>(sources.size());

        units.clear();
        for (int i = 0, size = sources.size(); i < size; i++)
        {
            Source s = sources.get(i);
            if (s != null && s.isCompiled())
            {
                units.add(s.getCompilationUnit());
            }
            else
            {
                units.add(null);
            }
        }

        if (benchmarkCompilingDetails > 4)
        {
            benchmark.benchmark2(
                    ThreadLocalToolkit.getLocalizationManager().getLocalizedTextString(new BatchTime("init units", "")));
        }

        while (nextSource(sources, igraph, dgraph, targets, symbolTable, configuration) > 0)
        {
            int postprocessCount = 0;

            // 1. targets.size() == sources.size()
            // 2. targets.get(i) == sources.get(i) or targets.get(i) == null
            for (int i = 0, size = targets.size(); i < size; i++)
            {
                Source s = targets.get(i);
                if (s == null) continue;

                int w = getCompilationUnitWorkflow(s);

                if ((w & preprocess) == 0)
                {
                    // C: it returns false if it errors. There is no need to catch that. It's okay to
                    //    keep going because findSources() takes into account of errors.
                    preprocess(sources, compilers, i, i + 1, symbolTable.getSuppressWarningsIncremental());

                    if (benchmarkCompilingDetails > 4)
                    {
                        benchmark.benchmark2(
                                ThreadLocalToolkit.getLocalizationManager()
                                .getLocalizedTextString(
                                        new BatchTime("preprocess", s.getNameForReporting())));
                    }
                }
                else if ((w & parse1) == 0)
                {
                    parse1(sources, units, igraph, dgraph, compilers, symbolTable, i, i + 1);
                    resolveInheritance(sources, igraph, dgraph, symbolTable, sourceList, sourcePath, resources, swcContext, i, i + 1);
                    addGeneratedSources(sources, igraph, dgraph, resources, symbolTable, configuration, i, i + 1);

                    if (benchmarkCompilingDetails > 4)
                    {
                        ThreadLocalToolkit.getBenchmark().benchmark2(
                                ThreadLocalToolkit.getLocalizationManager().
                                getLocalizedTextString(
                                        new BatchTime("parse1", s.getNameForReporting())));
                    }
                }
                else if ((w & parse2) == 0)
                {
                    parse2(sources, compilers, symbolTable, i, i + 1);
                    addGeneratedSources(sources, igraph, dgraph, resources, symbolTable, configuration, i, i + 1);

                    if (benchmarkCompilingDetails > 4)
                    {
                        ThreadLocalToolkit.getBenchmark().benchmark2(
                                ThreadLocalToolkit.getLocalizationManager().
                                getLocalizedTextString(
                                        new BatchTime("parse2", s.getNameForReporting())));
                    }
                }
                else if ((w & analyze1) == 0)
                {
                    // analyze1
                    analyze(sources, compilers, symbolTable, i, i + 1, 1);
                    resolveNamespace(sources, igraph, dgraph, symbolTable, sourceList, sourcePath, resources, swcContext, i, i + 1);
                    addGeneratedSources(sources, igraph, dgraph, resources, symbolTable, configuration, i, i + 1);

                    if (benchmarkCompilingDetails > 4)
                    {
                        ThreadLocalToolkit.getBenchmark().benchmark2(
                                ThreadLocalToolkit.getLocalizationManager().
                                getLocalizedTextString(
                                        new BatchTime("analyze1", s.getNameForReporting())));
                    }
                }
                else if ((w & analyze2) == 0)
                {
                    // analyze2
                    analyze(sources, compilers, symbolTable, i, i + 1, 2);
                    resolveType(sources, units, igraph, dgraph, symbolTable, sourceList, sourcePath, resources, swcContext, i, i + 1);

                    if (config.strict())
                    {
                        resolveImportStatements(sources, units, sourcePath, swcContext, i, i + 1);
                    }

                    // C: we don't need this batch1-based memory optimization.
                    // if (config.strict() || config.coach())
                    {
                        resolveExpression(sources, units, igraph, dgraph, symbolTable, sourceList, sourcePath, resources,
                                          swcContext, configuration, i, i + 1);
                    }

                    if (benchmarkCompilingDetails > 4)
                    {
                        ThreadLocalToolkit.getBenchmark().benchmark2(
                                ThreadLocalToolkit.getLocalizationManager().
                                getLocalizedTextString(
                                        new BatchTime("analyze2", s.getNameForReporting())));
                    }
                }
                else if ((w & analyze3) == 0)
                {
                    // analyze3
                    analyze(sources, compilers, symbolTable, i, i + 1, 3);

                    if (benchmarkCompilingDetails > 4)
                    {
                        ThreadLocalToolkit.getBenchmark().benchmark2(
                                ThreadLocalToolkit.getLocalizationManager().
                                getLocalizedTextString(
                                        new BatchTime("analyze3", s.getNameForReporting())));
                    }
                }
                else if ((w & analyze4) == 0)
                {
                    // analyze4
                    analyze(sources, compilers, symbolTable, i, i + 1, 4);

                    if (benchmarkCompilingDetails > 4)
                    {
                        ThreadLocalToolkit.getBenchmark().benchmark2(
                                ThreadLocalToolkit.getLocalizationManager().
                                getLocalizedTextString(
                                        new BatchTime("analyze4", s.getNameForReporting())));
                    }
                }
                else if ((w & generate) == 0)
                {
                    // generate
                    generate(sources, units, compilers, symbolTable, i, i + 1);
                    addGeneratedSources(sources, igraph, dgraph, resources, symbolTable, configuration, i, i + 1);
                    resolveExpression(sources, units, igraph, dgraph, symbolTable, sourceList, sourcePath, resources, swcContext, configuration, i, i + 1);
                    markDone(sources, units, i, i + 1);

                    if (benchmarkCompilingDetails > 4)
                    {
                        ThreadLocalToolkit.getBenchmark().benchmark2(
                                ThreadLocalToolkit.getLocalizationManager().
                                getLocalizedTextString(
                                        new BatchTime("generate", s.getNameForReporting())));
                    }
                }

                if (tooManyErrors() || forcedToStop()) break;

                if ((w & generate) != 0)
                {
                    // postprocess
                    postprocess(sources, units, compilers, symbolTable, i, i + 1);
                    resolveExpression(sources, units, igraph, dgraph, symbolTable, sourceList, sourcePath, resources, swcContext, configuration, i, i + 1);

                    postprocessCount++;

                    if (benchmarkCompilingDetails > 4)
                    {
                        ThreadLocalToolkit.getBenchmark().benchmark2(
                                ThreadLocalToolkit.getLocalizationManager().
                                getLocalizedTextString(
                                        new BatchTime("postprocess", s.getNameForReporting())));
                    }
                }

                if (tooManyErrors() || forcedToStop()) break;
            }

            // If all of them are doing postprocessing and they're not resolving and bringing in more source files,
            // we can call the compilation done and it should exit the loop.
            if ((postprocessCount == targets.size() && sources.size() == targets.size()) || tooManyErrors() || forcedToStop())
            {
                break;
            }
        }

        adjustQNames(units, igraph, symbolTable);
    }

    private static int nextSource(List<Source> sources, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph,
                                  List<Source> targets, SymbolTable symbolTable, Configuration configuration)
    {
        int count = 0, isDone = 0;
        boolean strict = configuration.getCompilerConfiguration().strict();
        boolean warnings = configuration.getCompilerConfiguration().warnings();
        int factor = configuration.getCompilerConfiguration().factor();

        // The notDoneList is used to debug which files are not being completed on a pass
        // thru the source files. To turn on the debugging uncomment the uses of "notDoneList"
        // in this method.
//        HashMap notDoneList = new HashMap(sources.size());
        targets.clear();

        // if 'targets' is smaller than 'sources', fill it up.
        for (int i = targets.size(), size = sources.size(); i < size; i++)
        {
            targets.add(null);
        }

        // Map notOkay = new HashMap();
        Set<String> processed = new HashSet<String>();

        for (int i = sources.size() - 1; i >= 0; i--)
        {
            Source s = sources.get(i);
//            if (notDoneList.get(s.getName()) == null)
//            {
//                notDoneList.put(s.getName(), s);
//            }
            CompilationUnit u = s != null ? s.getCompilationUnit() : null;
            int w = getCompilationUnitWorkflow(s);

            if (w == 0 || (w & preprocess) == 0 || (w & parse1) == 0)
            {
                // anything before 'parse2' requires no dependencies
                boolean okay = s.getLogger() == null || s.getLogger().errorCount() == 0;

                if (okay)
                {
                    targets.set(i, s);
                    count++;
                }
                /*
                else
                {
                    notOkay.put(s, "1");
                }
                */
            }
            else if ((w & parse2) == 0)
            {
                boolean okay = ((s.getLogger() == null || s.getLogger().errorCount() == 0) &&
                                check(u, INHERITANCE, u.inheritance, symbolTable, parse2));

                if (okay)
                {
                    targets.set(i, s);
                    count++;
                }
            }
            else if ((w & analyze1) == 0)
            {
                boolean okay = (s.getLogger() == null || s.getLogger().errorCount() == 0);

                if (okay)
                {
                    targets.set(i, s);
                    count++;
                }
            }
            else if ((w & analyze2) == 0)
            {
                // analyze1 --> analyze2? focus on inheritance and namespaces
                //
                // 1. get their workflow values... must be greater than or equal to analyze2.
                // 2. CompilationUnit.typeinfo must be present.
                // 3. error count must be zero.

                boolean okay =  ((s.getLogger() == null || s.getLogger().errorCount() == 0) &&
                                 checkInheritance(u, u.inheritance, symbolTable, analyze2, processed) &&
                                 check(u, NAMESPACES, u.namespaces, symbolTable, analyze2));
                processed.clear();

                if (okay)
                {
                    targets.set(i, s);
                    count++;
                }
                /*
                else
                {
                    notOkay.put(s, "2");
                }
                */
            }
            else if ((w & analyze3) == 0)
            {
                // analyze2 --> analyze3? focus on types, expressions and namespaces
                //
                // 1. get their workflow values... must be greater than or equal to analyze3.
                // 2. CompilationUnit.typeinfo must be present.
                // 3. error count must be zero.

                boolean okay = ((s.getLogger() == null || s.getLogger().errorCount() == 0) &&
                                checkInheritance(u, u.inheritance, symbolTable, analyze3, processed) &&
                                check(u, TYPES, u.types, symbolTable, analyze2) &&
                                check(u, NAMESPACES, u.namespaces, symbolTable, analyze3) &&
                                ((!strict && !warnings) || check(u, EXPRESSIONS, u.expressions, symbolTable, analyze2)));
                processed.clear();

                if (okay)
                {
                    targets.set(i, s);
                    count++;
                }
                /*
                else
                {
                    notOkay.put(s, "3");
                }
                */
            }
            else if ((w & analyze4) == 0)
            {
                // analyze3 --> analyze4?
                //
                // 1. get their workflow values... must be greater than or equal to analyze4.
                // 3. error count must be zero.

                boolean okay = ((s.getLogger() == null || s.getLogger().errorCount() == 0) &&
                                checkInheritance(u, u.inheritance, symbolTable, analyze4, processed) &&
                                check(u, NAMESPACES, u.namespaces, symbolTable, analyze4) &&
                                checkDeep(u, TYPES, u.types, symbolTable, processed) &&
                                ((!strict && !warnings) || checkDeep(u, EXPRESSIONS, u.expressions, symbolTable, processed)));
                processed.clear();

                if (okay)
                {
                    targets.set(i, s);
                    count++;
                }
                /*
                else
                {
                    notOkay.put(s, "4");
                }
                */
            }
            else if ((w & generate) == 0)
            {
                // analyze4 --> generate
                //
                // 1. error count must be zero.

                if ((s.getLogger() == null) || (s.getLogger().errorCount() == 0))
                {
                    targets.set(i, s);
                    count++;
                }
                /*
                else
                {
                    notOkay.put(s, "5");
                }
                */
            }
            else
            {
                isDone = (s.getLogger() == null || s.getLogger().errorCount() == 0) ? isDone + 1 : isDone;
//                if ((s.getLogger() == null || s.getLogger().errorCount() == 0))
//                {
//                    notDoneList.remove(s.getName());
//                }
            }
        }

        if (count > 0)
        {
            boolean[] bits = new boolean[targets.size()];
            double maxBudget = 100, budget = 0;

            // Preferences
            //
            // 1. SubCompiler.generate()
            // 2. SubCompiler.analyze3()
            // 3. SubCompiler.analyze4()
            // 4. SubCompiler.analyze1()
            // 5. SubCompiler.preprocess()
            // 6. SubCompiler.analyze2() for .abc
            // 7. SubCompiler.parse2() for .abc
            // 8. SubCompiler.parse1() for .abc
            // 9. SubCompiler.analyze2() for .as and .mxml
            // 10. SubCompiler.parse2() for .as and .mxml
            // 11. SubCompiler.parse1() for .as and .mxml


            // 1. SubCompiler.generate()
            for (int i = targets.size() - 1; i >= 0 && budget < maxBudget; i--)
            {
                Source s = targets.get(i);
                if (s == null) continue;

                int w = getCompilationUnitWorkflow(s);
                if (w != 0 &&
                    (w & preprocess) != 0 &&
                    (w & parse1) != 0 &&
                    (w & parse2) != 0 &&
                    (w & analyze1) != 0 &&
                    (w & analyze2) != 0 &&
                    (w & analyze3) != 0 &&
                    (w & analyze4) != 0 &&
                    (w & generate) == 0)
                {
                    bits[i] = true;
                }
            }

            // 2. SubCompiler.analyze3()
            for (int i = targets.size() - 1; i >= 0 && budget < maxBudget; i--)
            {
                Source s = targets.get(i);
                if (s == null) continue;

                int w = getCompilationUnitWorkflow(s);
                if (w != 0 &&
                    (w & preprocess) != 0 &&
                    (w & parse1) != 0 &&
                    (w & parse2) != 0 &&
                    (w & analyze1) != 0 &&
                    (w & analyze2) != 0 &&
                    (w & analyze3) == 0)
                {
                    bits[i] = true;
                }
            }

            // 3. SubCompiler.analyze4()
            for (int i = targets.size() - 1; i >= 0 && budget < maxBudget; i--)
            {
                Source s = targets.get(i);
                if (s == null) continue;

                int w = getCompilationUnitWorkflow(s);
                if (w != 0 &&
                    (w & preprocess) != 0 &&
                    (w & parse1) != 0 &&
                    (w & parse2) != 0 &&
                    (w & analyze1) != 0 &&
                    (w & analyze2) != 0 &&
                    (w & analyze3) != 0 &&
                    (w & analyze4) == 0)
                {
                    bits[i] = true;
                }
            }

            // 4. SubCompiler.analyze1()
            for (int i = targets.size() - 1; i >= 0 && budget < maxBudget; i--)
            {
                Source s = targets.get(i);
                if (s == null) continue;

                int w = getCompilationUnitWorkflow(s);
                if (w != 0 &&
                    (w & preprocess) != 0 &&
                    (w & parse1) != 0 &&
                    (w & parse2) != 0 &&
                    (w & analyze1) == 0)
                {
                    bits[i] = true;
                }
            }

            // 5. SubCompiler.preprocess()
            for (int i = targets.size() - 1; i >= 0 && budget < maxBudget; i--)
            {
                Source s = targets.get(i);
                if (s == null) continue;

                int w = getCompilationUnitWorkflow(s);
                if (w == 0)
                {
                    bits[i] = true;
                }
            }

            // 6. SubCompiler.analyze2() for .abc
            for (int i = targets.size() - 1; i >= 0 && budget < maxBudget; i--)
            {
                Source s = targets.get(i);
                if (s == null) continue;

                int w = getCompilationUnitWorkflow(s);
                if (w != 0 &&
                    (w & preprocess) != 0 &&
                    (w & parse1) != 0 &&
                    (w & parse2) != 0 &&
                    (w & analyze1) != 0 &&
                    (w & analyze2) == 0)
                {
                    if (MimeMappings.ABC.equals(s.getMimeType()))
                    {
                        bits[i] = true;
                    }
                }
            }

            // 7. SubCompiler.parse2() for .abc
            for (int i = targets.size() - 1; i >= 0 && budget < maxBudget; i--)
            {
                Source s = targets.get(i);
                if (s == null) continue;

                int w = getCompilationUnitWorkflow(s);
                if (w != 0 &&
                    (w & preprocess) != 0 &&
                    (w & parse1) != 0 &&
                    (w & parse2) == 0)
                {
                    if (MimeMappings.ABC.equals(s.getMimeType()))
                    {
                        bits[i] = true;
                    }
                }
            }

            // 8. SubCompiler.parse1() for .abc
            for (int i = targets.size() - 1; i >= 0 && budget < maxBudget; i--)
            {
                Source s = targets.get(i);
                if (s == null) continue;

                int w = getCompilationUnitWorkflow(s);
                if (w != 0 &&
                    (w & preprocess) != 0 &&
                    (w & parse1) == 0)
                {
                    if (MimeMappings.ABC.equals(s.getMimeType()))
                    {
                        bits[i] = true;
                    }
                }
            }

            // 9. SubCompiler.analyze2() for .as and .mxml
            for (int i = targets.size() - 1; i >= 0 && budget < maxBudget; i--)
            {
                Source s = targets.get(i);
                if (s == null) continue;

                int w = getCompilationUnitWorkflow(s);
                if (w != 0 &&
                    (w & preprocess) != 0 &&
                    (w & parse1) != 0 &&
                    (w & parse2) != 0 &&
                    (w & analyze1) != 0 &&
                    (w & analyze2) == 0)
                {
                    if (!MimeMappings.ABC.equals(s.getMimeType()))
                    {
                        budget += calculateBudget(s, factor);
                        bits[i] = true;
                    }
                }
            }

            // 10. SubCompiler.parse2() for .as and .mxml
            for (int i = targets.size() - 1; i >= 0 && budget < maxBudget; i--)
            {
                Source s = targets.get(i);
                if (s == null) continue;

                int w = getCompilationUnitWorkflow(s);
                if (w != 0 &&
                    (w & preprocess) != 0 &&
                    (w & parse1) != 0 &&
                    (w & parse2) == 0)
                {
                    if (!MimeMappings.ABC.equals(s.getMimeType()))
                    {
                        budget += calculateBudget(s, factor);
                        bits[i] = true;
                    }
                }
            }

            // 11. SubCompiler.parse1() for .as and .mxml
            for (int i = targets.size() - 1; i >= 0 && budget < maxBudget; i--)
            {
                Source s = targets.get(i);
                if (s == null) continue;

                int w = getCompilationUnitWorkflow(s);
                if (w != 0 &&
                    (w & preprocess) != 0 &&
                    (w & parse1) == 0)
                {
                    if (!MimeMappings.ABC.equals(s.getMimeType()))
                    {
                        budget += calculateBudget(s, factor);
                        bits[i] = true;
                    }
                }
            }

            count = 0;
            for (int i = 0, size = bits.length; i < size; i++)
            {
                if (!bits[i])
                {
                    targets.set(i, null);
                }
                else
                {
                    count++;
                }
            }
        }
        else if (count == 0 && isDone == sources.size())
        {
            // successful... start postprocessing. batch2() won't call nextSource() again if postprocess()
            // stops generating new Sources...
            targets.clear();
            targets.addAll(sources);
            count = targets.size();
        }
        else if (count == 0 && isDone != sources.size())
        {
            // problem...
            //
            // 1. detect circular inheritance
            // 2. what else?
//            for (Iterator iter = notDoneList.entrySet().iterator(); iter.hasNext();)
//            {
//                Entry entry = (Entry)iter.next();
//                System.out.println("Did not finish compiling " + entry.getKey().toString());
//            }
            detectCycles(sources, igraph);
            assert ThreadLocalToolkit.errorCount() > 0 : "There is a problem in one of the compiler algorithms. Please use --conservative=true to compile. Also, please file a bug report.";
        }

        // C: sources.size() == targets.size() when this returns.
        return count;
    }

    private static double calculateBudget(Source s, int factor)
    {
        String mimeType = s.getMimeType();

        if (MimeMappings.MXML.equals(mimeType))
        {
            return s.size() * 4.5 / factor;
        }
        else if (MimeMappings.AS.equals(mimeType))
        {
            return s.size() / factor;
        }
        else
        {
            return 0;
        }
    }

    /**
     * Calculate a mask that tracks a class of types'
     * progress through the workflow.
     * @param type_class - the type class.
     * @pre type_class must be INHERITANCE, NAMESPACES, TYPES, or EXPRESSIONS.
     * @param workflow - the desired workflow state.
     * @pre workflow must be parse2, analyze2, analyze3, or analyze4.
     * @return a bit mask with a bit set to the type class/workflow pair's position in a CompilationUnit's checkBits flag.
     * @see check, which calls this method and sets flags in checkBits
     * @see checkDeep, which calls this method and sets flags in checkBits
     * @see unitsReset, which clears flags in checkBits when a CompilationUnit hasn't finished compiling.
     */
    private static int calculateCheckBitsMask(int type_class, int workflow)
    {
    	//  Compute the base shift in the flag for
    	//  this type class.  Each type class has
    	//  four flag bits, and the shift is zero-based.
    	assert(INHERITANCE == type_class || NAMESPACES == type_class || TYPES == type_class || EXPRESSIONS == type_class);
        int type_class_base_shift = (type_class - 1) * 4;
        //  The four available bit positions each track
        //  a specific workflow phase.
        int workflow_offset = 0;

        switch (workflow)
        {
            case parse2: workflow_offset = 0; break;
            case analyze2: workflow_offset = 1; break;
            case analyze3: workflow_offset = 2; break;
            case analyze4: workflow_offset = 3; break;
            default: assert false;
        }

        return 1 << (type_class_base_shift + workflow_offset);
    }

    private static boolean check(CompilationUnit unit, int typesId, Set<Name> types, SymbolTable symbolTable, int workflow)
    {
        int mask = calculateCheckBitsMask(typesId, workflow);

        if ((unit.checkBits & mask) > 0)
        {
            return true;
        }

        for (Iterator<Name> i = types.iterator(); i.hasNext();)
        {
            Name name = i.next();

            if (name instanceof QName)
            {
                QName qName = (QName) name;
                Source s = symbolTable.findSourceByQName(qName);
                CompilationUnit u = (s != null) ? s.getCompilationUnit() : null;

                // a compilation unit should not have itself as the dependency.
                // let's continue and let the compiler catch the problem later.
                if (unit == u)
                {
                    continue;
                }

                // workflow
                if (u == null || (u.getWorkflow() & workflow) == 0)
                {
                    return false;
                }

                // type info
                if (u == null || u.typeInfo == null)
                {
                    return false;
                }

                // error count
                if (s.getLogger() != null && s.getLogger().errorCount() > 0)
                {
                    return false;
                }
            }
        }

        unit.checkBits |= mask;
        return true;
    }

    // For CompilationUnit.inheritance
    private static boolean checkInheritance(CompilationUnit unit, Set<Name> types, SymbolTable symbolTable, int workflow, Set<String> processed)
    {
        // 1. inheritance

        // Don't short circuit if the CompilationUnit has already been
        // checked, because we still need to check the rest of the
        // inheritance tree.  This is due to possibility that there is
        // an mxml document, which has been reset, higher up the
        // chain.  We want to return false in that case, so we don't
        // let the CompilationUnit continue to the next phase until
        // the mxml document catches back up.

        processed.add(unit.getSource().getName());

        if (!check(unit, INHERITANCE, types, symbolTable, workflow))
        {
            return false;
        }

        for (Iterator<Name> i = types.iterator(); i.hasNext();)
        {
            Name name = i.next();

            if (name instanceof QName)
            {
                QName qName = (QName) name;
                Source s = symbolTable.findSourceByQName(qName);
                CompilationUnit u = (s != null) ? s.getCompilationUnit() : null;

                if (u == null)
                {
                    return false;
                }

                // a compilation unit should not have itself as the dependency.
                // let's continue and let the compiler catch the problem later.
                if (unit == u || processed.contains(s.getName()))
                {
                    continue;
                }

                if (!checkInheritance(u, u.inheritance, symbolTable, workflow, processed))
                {
                    return false;
                }
            }
        }

        return true;
    }

    // For CompilationUnit.types and CompilationUnit.expressions
    private static boolean checkDeep(CompilationUnit unit, int typesId, Set<Name> types, SymbolTable symbolTable, Set<String> processed)
    {
        // 3. types, 4. expressions
        int mask = calculateCheckBitsMask(typesId, analyze3);

        if ((unit.checkBits & mask) > 0)
        {
            return true;
        }

        processed.add(unit.getSource().getName());

        if (!check(unit, typesId, types, symbolTable, analyze3))
        {
            return false;
        }

        for (Iterator<Name> i = types.iterator(); i.hasNext();)
        {
            Name name = i.next();

            if (name instanceof QName)
            {
                QName qName = (QName) name;
                Source s = symbolTable.findSourceByQName(qName);
                CompilationUnit u = (s != null) ? s.getCompilationUnit() : null;

                if (u == null)
                {
                    return false;
                }

                // a compilation unit should not have itself as the dependency.
                // let's continue and let the compiler catch the problem later.
                if (unit == u || processed.contains(s.getName()))
                {
                    continue;
                }

                if (!checkDeep(u, INHERITANCE, u.inheritance, symbolTable, processed))
                {
                    return false;
                }

                if (!checkDeep(u, TYPES, u.types, symbolTable, processed))
                {
                    return false;
                }

                if (!checkDeep(u, EXPRESSIONS, u.expressions, symbolTable, processed))
                {
                    return false;
                }
            }
        }

        unit.checkBits |= mask;
        return true;
    }

    private static int getCompilationUnitWorkflow(Source s)
    {
        if (!s.isPreprocessed())
        {
            return 0;
        }
        else if (s.getCompilationUnit() == null || (s.getCompilationUnit().getWorkflow() & parse1) == 0)
        {
            return preprocess;
        }
        else
        {
            return s.getCompilationUnit().getWorkflow();
        }
    }

    private static void batch(List<Source> sources, List<CompilationUnit> units, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph, SymbolTable symbolTable,
                              SubCompiler[] compilers, SourceList sourceList, SourcePath sourcePath, ResourceContainer resources,
                              CompilerSwcContext swcContext, Configuration configuration, boolean useFileSpec)
        throws CompilerException
    {
        do
        {
            units.clear();
            if (useFileSpec || configuration.getCompilerConfiguration().useConservativeAlgorithm())
            {
                batch1(sources, units, igraph, dgraph, symbolTable, compilers, sourceList, sourcePath, resources, swcContext, configuration);
            }
            else
            {
                batch2(sources, units, igraph, dgraph, symbolTable, compilers, sourceList, sourcePath, resources, swcContext, configuration);
            }
			symbolTable.perCompileData.reuse();

            if (swcContext.errorLocations().size() > 0)
            {
                for (Iterator it = swcContext.errorLocations().iterator(); it.hasNext();)
                {
                    ThreadLocalToolkit.log(new IncompatibleSWCArchive((String) it.next()));
                }
            }

            if (ThreadLocalToolkit.errorCount() > 0)
            {
                throw new CompilerException();
            }

            if (forcedToStop()) break;
        }
        while (unitsReset(units) > 0);
    }

    public static List<CompilationUnit>
                       compileSwc(FileSpec fileSpec,
                                  Collection<Source> classes,
                                  SourcePath sourcePath,
                                  ResourceContainer resources,
                                  ResourceBundlePath bundlePath,
                                  CompilerSwcContext swcContext,
                                  SymbolTable symbolTable,
                                  NameMappings nameMappings,
                                  Configuration configuration,
                                  SubCompiler[] compilers,
                                  PreLink preLink,
                                  Map licenseMap)
        throws CompilerException
    {
        return compile(fileSpec,
                       null,
                       classes,
                       sourcePath,
                       resources,
                       bundlePath,
                       swcContext,
                       symbolTable,
                       nameMappings,
                       configuration,
                       compilers,
                       preLink,
                       licenseMap,
                       new ArrayList<Source>());
    }

    public static List<CompilationUnit>
                       compile(FileSpec fileSpec,
                               SourceList sourceList,
                               SourcePath sourcePath,
                               ResourceContainer resources,
                               ResourceBundlePath bundlePath,
                               CompilerSwcContext swcContext,
                               SymbolTable symbolTable,
                               NameMappings nameMappings,
                               Configuration configuration,
                               SubCompiler[] compilers,
                               PreLink preLink,
                               Map licenseMap)
        throws CompilerException
    {
        return compile(fileSpec,
                       sourceList,
                       null,
                       sourcePath,
                       resources,
                       bundlePath,
                       swcContext,
                       symbolTable,
                       nameMappings,
                       configuration,
                       compilers,
                       preLink,
                       licenseMap,
                       new ArrayList<Source>());
    }

    // full compilation
    public static List<CompilationUnit>
                       compile(FileSpec fileSpec,
                               SourceList sourceList,
                               Collection<Source> classes,
                               SourcePath sourcePath,
                               ResourceContainer resources,
                               ResourceBundlePath bundlePath,
                               CompilerSwcContext swcContext,
                               NameMappings nameMappings,
                               Configuration configuration,
                               SubCompiler[] compilers,
                               PreLink preLink,
                               Map licenseMap,
                               List<Source> sources)
        throws CompilerException
    {
        return compile(fileSpec,
                       sourceList,
                       classes,
                       sourcePath,
                       resources,
                       bundlePath,
                       swcContext,
                       new SymbolTable(configuration),
                       nameMappings,
                       configuration,
                       compilers,
                       preLink,
                       licenseMap,
                       sources);
    }

    // incremental compilation
    public static List<CompilationUnit>
                       compile(FileSpec fileSpec,
                               SourceList sourceList,
                               Collection<Source> classes,
                               SourcePath sourcePath,
                               ResourceContainer resources,
                               ResourceBundlePath bundlePath,
                               CompilerSwcContext swcContext,
                               SymbolTable symbolTable,
                               NameMappings nameMappings,
                               Configuration configuration,
                               SubCompiler[] compilers,
                               PreLink preLink,
                               Map licenseMap,
                               List<Source> sources)
        throws CompilerException
    {
        Set<IPreCompileExtension> extensions = 
            ExtensionManager.getPreCompileExtensions( configuration.getCompilerConfiguration().getExtensionsConfiguration().getExtensionMappings() );
        for ( IPreCompileExtension extension : extensions )
        {
            extension.run( fileSpec, sourceList, classes, sourcePath, resources, bundlePath, swcContext,
                           new SymbolTable(configuration), configuration, compilers, preLink, licenseMap,
                           sources );
        }
        
        if ( configuration.getCompilerConfiguration().getJavaProfilerClass() != null )
        {
            macromedia.asc.util.ProfileController.setProfiler(configuration.getCompilerConfiguration().getJavaProfilerClass());
            macromedia.asc.util.ProfileController.startAllocationRecording();
            macromedia.asc.util.ProfileController.startCPUProfiling(true); // sampling mode
        }
        
        // C: display any SourcePath-related warnings before starting to compile.
        if (sourcePath != null)
        {
            ThreadLocalToolkit.getPathResolver().addSinglePathResolver(sourcePath);
            sourcePath.displayWarnings();
        }

        ThreadLocalToolkit.setCompatibilityVersion(configuration.getCompatibilityVersion());

        StandardDefs standardDefs = StandardDefs.getStandardDefs(configuration.getFramework());
        ThreadLocalToolkit.setStandardDefs(standardDefs);

        LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();

        if (configuration.getBenchmarkCompilerDetails() > 0 &&
                ThreadLocalToolkit.getBenchmark() != null)
        {
            ThreadLocalToolkit.getBenchmark().benchmark2(l10n.getLocalizedTextString(new CompileTime("Start")), true);
        }

        ProgressMeter meter = ThreadLocalToolkit.getProgressMeter();

        if (meter != null)
        {
            meter.start();
        }

        List<CompilationUnit> units = new ArrayList<CompilationUnit>();
        DependencyGraph<CompilationUnit> igraph = new DependencyGraph<CompilationUnit>();
        DependencyGraph<Source> dgraph = null; // new DependencyGraph();

        boolean useFileSpec = false;

        // based on the starting source file, retrieve a list of dependent files.
        if (fileSpec != null)
        {
            sources.addAll(fileSpec.retrieveSources());
            useFileSpec = sources.size() > 0;
        }

        if (sourceList != null)
        {
            sources.addAll(sourceList.retrieveSources());
        }

        // C: This is here for SWC compilation.
        if (classes != null)
        {
            for (Source source : classes)
            {
                // source might have already been added if it's in the SourceList.
                if (!sources.contains(source))
                {
                    sources.add(source);
                }
            }

            useFileSpec = useFileSpec || classes.size() > 0;
        }

        // add the sources to the dependency graphs as vertices.
        addVerticesToGraphs(sources, igraph, dgraph);

        if (configuration.getBenchmarkCompilerDetails() > 0 &&
                ThreadLocalToolkit.getBenchmark() != null)
        {
            ThreadLocalToolkit.getBenchmark().benchmark2(l10n.getLocalizedTextString(new CompileTime("addVerticesToGraphs")), true);
        }

        try
        {
            getCommonBuiltinClasses(sources, igraph, dgraph, symbolTable, sourceList, sourcePath, resources, swcContext);

            if (configuration.getBenchmarkCompilerDetails() > 0 &&
                    ThreadLocalToolkit.getBenchmark() != null)
            {
                ThreadLocalToolkit.getBenchmark().benchmark2(l10n.getLocalizedTextString(new CompileTime("GetCommonBuiltInClassesTime")), true);
            }

            //    build unit list
            batch(sources, units, igraph, dgraph, symbolTable, compilers, sourceList, sourcePath, resources, swcContext, configuration, useFileSpec);

            if (configuration.getBenchmarkCompilerDetails() > 0 &&
                    ThreadLocalToolkit.getBenchmark() != null)
            {
                ThreadLocalToolkit.getBenchmark().benchmark2(l10n.getLocalizedTextString(new CompileTime("batch")));

            }

            // enterprise messaging classes referenced by the messaging config file
            getMessagingClasses(sources, igraph, dgraph, symbolTable, sourceList, sourcePath, resources, swcContext, configuration);

            if (configuration.getBenchmarkCompilerDetails() > 0 &&
                    ThreadLocalToolkit.getBenchmark() != null)
            {
                ThreadLocalToolkit.getBenchmark().benchmark2(l10n.getLocalizedTextString(new CompileTime("getMessagingClasses")), true);
            }

            // unconditionally includes classes specified by --includes.
            getIncludeClasses(sources, igraph, dgraph, symbolTable, sourceList, sourcePath, resources, swcContext, configuration);

            if (configuration.getBenchmarkCompilerDetails() > 0 &&
                    ThreadLocalToolkit.getBenchmark() != null)
            {
                ThreadLocalToolkit.getBenchmark().benchmark2(l10n.getLocalizedTextString(new CompileTime("GetIncludeClassesTime")), true);
            }

            // backward compatibility
            getIncludeResources(sources, igraph, dgraph, bundlePath, symbolTable, swcContext, configuration);

            if (configuration.getBenchmarkCompilerDetails() > 0 &&
                    ThreadLocalToolkit.getBenchmark() != null)
            {
                ThreadLocalToolkit.getBenchmark().benchmark2(l10n.getLocalizedTextString(new CompileTime("GetIncludeResourcesTime")), true);
            }

            // getMessagingClasses, and getIncludeClasses may produce errors. check them...
            if (ThreadLocalToolkit.errorCount() > 0)
            {
                throw new CompilerException();
            }

            if (forcedToStop()) return units;

            // compile additional sources before running prelink so that all metadata-fed lists
            // contributing to codegen (i.e. mixins) are complete
            batch(sources, units, igraph, dgraph, symbolTable, compilers, sourceList, sourcePath, resources, swcContext, configuration, useFileSpec);

            if (configuration.getBenchmarkCompilerDetails() > 0 &&
                    ThreadLocalToolkit.getBenchmark() != null)
            {
                ThreadLocalToolkit.getBenchmark().benchmark2(l10n.getLocalizedTextString(new CompileTime("batch")), true);

            }

            if (forcedToStop()) return units;

            // PreLink

            int count = 0; // just in case something impossibly odd happens,
            if (preLink != null)  // don't wedge the compiler forever.
            {
                // run the prelink step (repeatedly until we've found all nested style dependencies...)
                boolean runPrelink = true;
                while (runPrelink && count++ < 1000)
                {
                    runPrelink = preLink.run(sources, units, fileSpec, sourceList, sourcePath, bundlePath, resources, symbolTable, swcContext, nameMappings, configuration);
                    if (!runPrelink)
                    {
                        // Add synthetic link-in units now that we've found all of our sources
                        preLink.postRun(sources, units, resources, symbolTable, swcContext, nameMappings, configuration);
                    }

                    if (configuration.getBenchmarkCompilerDetails() > 0 &&
                            ThreadLocalToolkit.getBenchmark() != null)
                    {
                        ThreadLocalToolkit.getBenchmark().benchmark2(l10n.getLocalizedTextString(new CompileTime("PreLinkTime")), true);
                    }

                    // prelink also may produce errors
                    if (ThreadLocalToolkit.errorCount() > 0)
                    {
                        throw new CompilerException();
                    }

                    // prelink introduces more sources, so we compile again
                    batch(sources, units, igraph, dgraph, symbolTable, compilers, sourceList, sourcePath, resources, swcContext, configuration, useFileSpec);

                    if (configuration.getBenchmarkCompilerDetails() > 0 &&
                            ThreadLocalToolkit.getBenchmark() != null)
                    {
                        ThreadLocalToolkit.getBenchmark().benchmark2(l10n.getLocalizedTextString(new CompileTime("batch")), true);
                    }

                    if (forcedToStop()) return units;
                }
            }

            // loader classes, licensing classes, extra classes

            count = 0; // just in case something impossibly odd happens,
            while (++count < 1000) // don't wedge the compiler forever.
            {
                int numSources = sources.size();
                getExtraSources(sources, igraph, dgraph, sourceList, sourcePath, resources, bundlePath, symbolTable, swcContext,
                                configuration, licenseMap);

                if (configuration.getBenchmarkCompilerDetails() > 0 &&
                        ThreadLocalToolkit.getBenchmark() != null)
                {
                    ThreadLocalToolkit.getBenchmark().benchmark2(l10n.getLocalizedTextString(new CompileTime("GetExtraSourcesTime")), true);
                }

                // getExtraSources may produce errors. check them...
                if (ThreadLocalToolkit.errorCount() > 0)
                {
                    throw new CompilerException();
                }

                // getExtraSources pulls in more classes, compile again
                batch(sources, units, igraph, dgraph, symbolTable, compilers, sourceList, sourcePath, resources, swcContext, configuration, useFileSpec);

                if (configuration.getBenchmarkCompilerDetails() > 0 &&
                        ThreadLocalToolkit.getBenchmark() != null)
                {
                    ThreadLocalToolkit.getBenchmark().benchmark2(l10n.getLocalizedTextString(new CompileTime("batch")), true);

                }

                if (sources.size() == numSources)
                {
                    break;
                }

                if (forcedToStop()) return units;
            }

            checkResourceBundles(sources, symbolTable);
            assert count < 1000;
        }
        finally
        {
            if (ThreadLocalToolkit.getBenchmark() != null)
            {
                ThreadLocalToolkit.getBenchmark().benchmark(l10n.getLocalizedTextString(new OutputTime(sources.size())));
            }

            // must close swc file handles...
            swcContext.close();
            symbolTable.cleanClassTable();
            symbolTable.adjustProgress();

            if (meter != null)
            {
                meter.end();
            }
        }

        return units;
    }

    private static final MultiName[] multiNames = new MultiName[]
    {
        new MultiName(SymbolTable.OBJECT),
        new MultiName(SymbolTable.CLASS),
        new MultiName(SymbolTable.FUNCTION),
        new MultiName(SymbolTable.BOOLEAN),
        new MultiName(SymbolTable.NUMBER),
        new MultiName(SymbolTable.STRING),
        new MultiName(SymbolTable.ARRAY),
        new MultiName(SymbolTable.INT),
        new MultiName(SymbolTable.UINT),
        new MultiName(SymbolTable.NAMESPACE),
        new MultiName(SymbolTable.REGEXP),
        new MultiName(SymbolTable.XML),
        new MultiName(SymbolTable.XML_LIST),
    };

    private static void getCommonBuiltinClasses(List<Source> sources, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph,
                                                SymbolTable symbolTable, SourceList sourceList, SourcePath sourcePath,
                                                ResourceContainer resources, CompilerSwcContext swcContext)
    {
        for (int i = 0, size = multiNames.length; i < size; i++)
        {
            QName qName = resolveMultiName("builtin", multiNames[i], sources, sourceList, sourcePath, resources, swcContext, symbolTable);
            if (qName != null)
            {
                Source tailSource = symbolTable.findSourceByQName(qName);
                addVertexToGraphs(tailSource, tailSource.getCompilationUnit(), igraph, dgraph);
            }
        }
    }

    private static void getMessagingClasses(List<Source> sources, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph,
                                            SymbolTable symbolTable, SourceList sourceList, SourcePath sourcePath,
                                            ResourceContainer resources, CompilerSwcContext swcContext,
                                            Configuration configuration)
    {
        // The enterprise messaging config file may refer to some classes. We want to load them up-front.
        ServicesDependenciesWrapper services = configuration.getCompilerConfiguration().getServicesDependencies();
        if (services != null)
        {
            for (Iterator i = services.getChannelClasses().iterator(); i.hasNext();)
            {
                String clientType = (String) i.next();

                if (clientType != null)
                {
                    QName qName = resolveMultiName("messaging", new MultiName(NameFormatter.toColon(clientType)), sources,
                                                   sourceList, sourcePath, resources, swcContext, symbolTable);

                    if (qName == null)
                    {
                        ThreadLocalToolkit.log(new ChannelDefinitionNotFound(clientType),
                                               configuration.getCompilerConfiguration().getServices().getNameForReporting());
                    }
                    else
                    {
                        Source s = symbolTable.findSourceByQName(qName);
                        addVertexToGraphs(s, s.getCompilationUnit(), igraph, dgraph);
                    }
                }
            }
        }
    }

    /**
     * reset non-internal units that have failed to produce bytecode.
     * NOTE: contract is that all units from non-internal sources will eventually produce either bytecode or an error,
     * after a finite number of resets.
     */
    private static int unitsReset(List<CompilationUnit> units)
    {
        int resetCount = 0;
        for (int i = 0, n = units.size(); i < n; i++)
        {
            CompilationUnit unit = units.get(i);
            Source source = unit.getSource();

            if (!source.isInternal() && !source.isCompiled())
            {
                unit.reset();
                resetCount++;
            }
            else if (!source.isInternal())
            {
                unit.checkBits = 0;
            }
        }
        return resetCount;
    }

    /**
     * Report cached SWC sources, which have been obsoleted by a newer
     * definition from another SWC.
     */
    private static void reportObsoletedSwcSources(CompilerSwcContext swcContext, 
                                                  LocalizationManager l10n,
                                                  Logger logger)
    {
        for (Entry<Source, String> entry : swcContext.getObsoletedSources().entrySet())
        {
            Source obsoletedSource = entry.getKey();
            String obsoletedSourceName = obsoletedSource.getName();
            String newLocation = entry.getValue();
            String message = l10n.getLocalizedTextString(new SwcDefinitionObsoleted(newLocation));
            logger.needsCompilation(obsoletedSourceName, message);
        }
    }

    /**
     * Report cached SWC sources, which will be shadowed by a Source
     * in the source path, source list, or resource container.
     */
    private static void reportShadowedSwcSources(Set<Source> swcSources, SourceList sourceList,
                                                 SourcePath sourcePath, ResourceContainer resources,
                                                 LocalizationManager l10n, Logger logger,
                                                 Set<Source> sources)
    {
        for (Source source : swcSources)
        {
            CompilationUnit compilationUnit = source.getCompilationUnit();

            for (QName qName : compilationUnit.topLevelDefinitions)
            {
                Source newSource = null;

                if (sourceList != null)
                {
                    newSource = sourceList.findSource(qName.getNamespace(), qName.getLocalPart());
                }

                if ((newSource == null) && (sourcePath != null))
                {
                    try
                    {
                        newSource = sourcePath.findSource(qName.getNamespace(), qName.getLocalPart());
                    }
                    catch (CompilerException compilerException)
                    {
                        // handle this downstream.
                    }
                }

                if ((newSource == null) && (resources != null))
                {
                    newSource = resources.findSource(qName.getNamespace(), qName.getLocalPart());
                }

                if ((newSource != null) &&
                    (newSource != source) &&
                    (newSource.getLastModified() != source.getLastModified()))
                {
                    String message = l10n.getLocalizedTextString(new SwcDefinitionObsoleted(newSource.getName()));
                    logger.needsCompilation(source.getName(), message);
                    sources.remove(source);
                }
            }
        }
    }

    /**
     * For use by application compilations.
     */
    public static int validateCompilationUnits(FileSpec fileSpec, SourceList sourceList, SourcePath sourcePath,
                                               ResourceBundlePath bundlePath, ResourceContainer resources,
                                               CompilerSwcContext swcContext, ContextStatics perCompileData,
                                               Configuration configuration)
    {
        return validateCompilationUnits(fileSpec, sourceList, sourcePath, bundlePath, resources, swcContext,
                                        null, perCompileData, configuration);
    }

    /**
     * For use by library compilations.
     */
    public static int validateCompilationUnits(FileSpec fileSpec, SourceList sourceList, SourcePath sourcePath,
                                               ResourceBundlePath bundlePath, ResourceContainer resources,
                                               CompilerSwcContext swcContext, Map<String, Source> includedClasses,
                                               ContextStatics perCompileData, Configuration configuration)
    {
        final LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();

        final boolean strict = configuration.getCompilerConfiguration().strict();

        final Map<String, Source>
                  updated                     = new HashMap<String, Source>(), // VirtualFile.getName() -> Source
                  updatedWithStableSignature  = new HashMap<String, Source>(), // VirtualFile.getName() -> Source
                  affected                    = new HashMap<String, Source>(); // VirtualFile.getName() -> Source

        final Map<QName, Source> deleted = new HashMap<QName, Source>();

        final Map<String, String> reasons = new HashMap<String, String>(); // VirtualFile.getName() -> String
        final Map<QName, Source> qNames = new HashMap<QName, Source>();

        final Set<String> includeUpdated      = new HashSet<String>(),         // VirtualFile.getName()
                  resourceDelegates           = new HashSet<String>(),         // VirtualFile.getNameForReporting()
                  namespaces                  = new HashSet<String>();

        final Map<QName, Map<String, Source>> dependents = new HashMap<QName, Map<String, Source>>();

        Set<Source> swcSources = swcContext.cachedSources();
        Context ascContext = null;

        if (perCompileData != null)
        {
            ascContext = new Context(perCompileData);
        }

        // put all the Source objects together
        final Set<Source> sources = new HashSet<Source>();
        {
            sources.addAll(swcSources);
            if (fileSpec != null)
                sources.addAll(fileSpec.sources());
            if (sourceList != null)
                sources.addAll(sourceList.sources().values());
            if (sourcePath != null)
                sources.addAll(sourcePath.sources().values());
            if (bundlePath != null)
                sources.addAll(bundlePath.sources().values());
            if (includedClasses != null)
                sources.addAll(includedClasses.values());
        }

        // build a dependency graph
        for (Source source : sources)
        {
            if (source.getName() == null)
            {
                continue;
            }

            CompilationUnit u = source.getCompilationUnit();

            if (u == null)
            {
                continue;
            }

            // collect the names of all the update file includes...
            for (Iterator j = source.getUpdatedFileIncludes(); j != null && j.hasNext();)
            {
                VirtualFile f = (VirtualFile) j.next();
                includeUpdated.add(f.getNameForReporting());
            }

            // register QName --> VirtualFile.getName()
            for (QName qName : u.topLevelDefinitions)
            {
                qNames.put(qName, source);
                dependents.put(qName, new HashMap<String, Source>());
            }
        }

        for (Source source : resources.sources().values())
        {
            if (source.getName() == null)
            {
                continue;
            }

            CompilationUnit u = source.getCompilationUnit();

            if (u == null)
            {
                continue;
            }

            // register QName --> VirtualFile.getName()
            for (QName qName : u.topLevelDefinitions)
            {
                qNames.put(qName, source);
            }
        }

        // setup inheritance-based dependencies...
        for (Source source : sources)
        {
            if (source == null) continue;

            CompilationUnit u = source.getCompilationUnit();
            if (u == null) continue;

            addDependents(source, u.inheritance, dependents);
            addDependents(source, u.namespaces, dependents);
            addDependents(source, u.types, dependents);
            addDependents(source, u.expressions, dependents);
        }

        Logger logger = ThreadLocalToolkit.getLogger();

        // if any of the Source objects in ResourceContainer is bad, obsolete the originating Source.
        for (Source source : resources.sources().values())
        {
            CompilationUnit u = source.getCompilationUnit();
            if (source.hasError() ||
                (u != null && !u.isDone() && !u.hasTypeInfo) ||
                source.isUpdated() ||
                (u != null && u.hasAssets() && u.getAssets().isUpdated()))
            {
                resourceDelegates.add(source.getNameForReporting());
                source.removeCompilationUnit();
            }
        }

        reportObsoletedSwcSources(swcContext, l10n, logger);
        reportShadowedSwcSources(swcSources, sourceList, sourcePath, resources, l10n, logger, sources);

        // identify obsolete CompilationUnit
        //   - NotFullyCompiled
        //   - SourceNoLongerExists
        //   - SourceFileUpdated
        //   - AssedUpdated
        for (Iterator<Source> iterator = sources.iterator(); iterator.hasNext();)
        {
            Source s = iterator.next();
            CompilationUnit u = s.getCompilationUnit();

            // Sources for internal classes like Object never reach the done state or have typeInfo.
            if (s.hasError() ||
                (!s.isInternal() && (u != null && !u.isDone() && !u.hasTypeInfo)) ||
                resourceDelegates.contains(s.getName()))
            {
                affected.put(s.getName(), s);
                reasons.put(s.getName(), l10n.getLocalizedTextString(new NotFullyCompiled()));
                iterator.remove();
            }
            else if (!s.exists())
            {
                updated.put(s.getName(), s);
                reasons.put(s.getName(), l10n.getLocalizedTextString(new SourceNoLongerExists()));

                if (u != null)
                {
                    for (QName qName : u.topLevelDefinitions)
                    {
                        namespaces.add(qName.toString());
                        deleted.put(qName, s);
                    }
                }

                iterator.remove();
            }
            else if (s.isUpdated())
            {
                // signature optimization:
                //     read the old signature from the incremental cache
                //     generate a new signature from the current source
                //     compare -- if stable, we don't have to recompile dependencies
                boolean signatureIsStable = false;
                if ((u != null) &&
                    (!configuration.getCompilerConfiguration().getDisableIncrementalOptimizations()) &&
                    // skip MXML sources:
                    //      MXML is too complicated to parse/codegen at this point in
                    //      order to generate and compare a new checksum
                    (!s.getMimeType().equals(MimeMappings.MXML)))
                {
                    final Long persistedCRC = u.getSignatureChecksum();
                    if (persistedCRC != null)
                    {
                        assert (s.getMimeType().equals(MimeMappings.ABC) ||
                                s.getMimeType().equals(MimeMappings.AS));

                        //TODO if we calculate a new checksum that does not match,
                        //     can we store this checksum and not recompute it later?
                        final Long currentCRC = computeSignatureChecksum(configuration, s);
                        signatureIsStable = (currentCRC != null) &&
                                            (persistedCRC.compareTo(currentCRC) == 0);

                        // if (SignatureExtension.debug)
                        // {
                        //     final String name = u.getSource().getName();
                        //     SignatureExtension.debug("*** FILE UPDATED: Signature "
                        //                                    + (signatureIsStable ? "IS" : "IS NOT")
                        //                                    + " stable ***");
                        //     SignatureExtension.debug("PERSISTED CRC32: " + persistedCRC + "\t--> " + name);
                        //     SignatureExtension.debug("CURRENT   CRC32: " + currentCRC   + "\t--> " + name);
                        // }
                    }
                }

                // if the class signature is stable (it has not changed since the last compile)
                // then we can invalidate and recompile the updated unit alone
                // otherwise we default to a chain reaction, invalidating _all_ dependent units
                if (signatureIsStable)
                {
                    updatedWithStableSignature.put(s.getName(), s);
                }
                else
                {
                    updated.put(s.getName(), s);
                }

                reasons.put(s.getName(), l10n.getLocalizedTextString(new SourceFileUpdated()));
                iterator.remove();
            }
            else if (u != null && u.hasAssets() && u.getAssets().isUpdated())
            {
                updated.put(s.getName(), s);
                reasons.put(s.getName(), l10n.getLocalizedTextString(new AssetUpdated()));
                iterator.remove();
            }
        }

        // permanently remove the deleted Source objects from SourcePath
        //
        // Note: this step is currently necessary because the location-updating loop that follows iterates over
        // 'sources', which has had deleted entries remove. So here we iterate directly over the deleted
        // entries. (Note also that 'reasons' already has an entry for this source.)
        //
        for (Source source : deleted.values())
        {
            if (source.isSourcePathOwner())
            {
                SourcePath sp = (SourcePath) source.getOwner();
                sp.removeSource(source);

                if (ascContext != null)
                {
                    CompilationUnit u = source.getCompilationUnit();

                    if (u != null)
                    {
                        for (QName defName : u.topLevelDefinitions)
                        {
                            ascContext.removeUserDefined(defName.toString());
                        }
                    }
                }
            }
        }

        // Examine each Source object in SourcePath or ResourceBundlePath...
        // if a Source object in SourcePath or ResourceBundlePath is no longer the
        // first choice according to findFile, it should be removed... i.e. look for ambiguous sources
        // - NotSourcePathFirstPreference
        for (Iterator<Source> iterator = sources.iterator(); iterator.hasNext();)
        {
            Source s = iterator.next();

            if (s.isSourcePathOwner() || s.isResourceBundlePathOwner())
            {
                SourcePathBase sp = (SourcePathBase) s.getOwner();
                if (!sp.checkPreference(s))
                {
                    affected.put(s.getName(), s);
                    reasons.put(s.getName(), l10n.getLocalizedTextString(new NotSourcePathFirstPreference()));
                    iterator.remove();
                }
            }
        }

        // invalidate the compilation unit if its dependencies are updated or not cached.
        // - DependencyUpdated
        // - DependencyNotCached
        // - InvalidImportStatement
        for (Iterator<Source> iterator = sources.iterator(); iterator.hasNext();)
        {
            Source s = iterator.next();
            CompilationUnit u = s.getCompilationUnit();
            if (u == null) continue;

            Set<Name> dependencies = new HashSet<Name>();
            dependencies.addAll(u.inheritance);
            dependencies.addAll(u.namespaces);
            dependencies.addAll(u.expressions);
            dependencies.addAll(u.types);

            // Every CompilationUnit has "Object" at the top of it's
            // inheritance chain.  As a result, in
            // As3Compiler.analyze2(), we call inheritSlots() on
            // Object's frame, which unfortunately includes lots of
            // other builtins, like String, Number, Namespace, etc.
            // By inheriting slots for these other builtins, they are
            // not reported as unresolved, so they are not recorded as
            // dependencies.  When switching between airglobal.swc and
            // playerglobal.swc in the same workspace, the builtins
            // change, so we need to check for that.  We use
            // "Namespace" to represent the set of builtins.  See
            // SDK-25206.
            dependencies.add(new QName("", "Namespace"));
            boolean valid = true;

            for (Name dependentName : dependencies)
            {
                QName qName = toQName(dependentName);

                if (qName != null)
                {
                    Source dependentSource = qNames.get(qName);

                    if (dependentSource != null)
                    {
                        CompilationUnit dependentCompilationUnit = dependentSource.getCompilationUnit();

                        if (u.hasTypeInfo && !dependentCompilationUnit.hasTypeInfo && !dependentSource.isInternal())
                        {
                            reasons.put(s.getName(), l10n.getLocalizedTextString(new DependencyNotCached(dependentName.toString())));
                            valid = false;
                        }
                        else
                        {
                            // If the dependency hasn't been updated with
                            // a stable signature, check that the two
                            // ObjectValues references the same Slot.  If
                            // they are not, then the referencing
                            // CompilationUnit needs to be recompiled.
                            if (!updatedWithStableSignature.containsKey(dependentSource.getName()) &&
                                (ascContext != null) &&
                                u.hasTypeInfo &&
                                dependentCompilationUnit.hasTypeInfo &&
                                referencesDifferentSlots(ascContext, u.typeInfo, qName, dependentCompilationUnit.typeInfo))
                            {
                                reasons.put(s.getName(), l10n.getLocalizedTextString(new DependencyUpdated(dependentName.toString())));
                                valid = false;
                            }
                        }
                    }
                    else if (u.hasTypeInfo)
                    {
                        reasons.put(s.getName(), l10n.getLocalizedTextString(new DependencyNotCached(dependentName.toString())));
                        valid = false;
                    }
                }

                if (!valid)
                {
                    affected.put(s.getName(), s);
                    iterator.remove();
                    break;
                }
            }

            if (!swcSources.contains(s))
            {
                // only check the following when strict is enabled.
                valid = valid && strict;

                for (Iterator k = u.importPackageStatements.iterator(); valid && k.hasNext();)
                {
                    String packageName = (String) k.next();

                    if (!hasPackage(sourcePath, swcContext, packageName))
                    {
                        affected.put(s.getName(), s);
                        reasons.put(s.getName(), l10n.getLocalizedTextString(new InvalidImportStatement(packageName)));
                        iterator.remove();
                        namespaces.add(packageName);
                        valid = false;
                        break;
                    }
                }

                for (Iterator k = u.importDefinitionStatements.iterator(); valid && k.hasNext();)
                {
                    QName defName = (QName) k.next();

                    if (!hasDefinition(sourcePath, swcContext, defName))
                    {
                        affected.put(s.getName(), s);
                        reasons.put(s.getName(), l10n.getLocalizedTextString(new InvalidImportStatement(defName.toString())));
                        iterator.remove();
                        namespaces.add(defName.toString());
                        valid = false;
                        break;
                    }
                }
            }
        }

        // - DependentFileModified
        if (strict)
        {
            Map<String, Source> updatedAndAffected = new HashMap<String, Source>(updated);
            updatedAndAffected.putAll(affected);

            for (Source source : updatedAndAffected.values())
            {
                dependentFileModified(source, dependents, updated, affected, reasons, sources);
            }
        }

        for (Iterator<String> i = includeUpdated.iterator(); i.hasNext();)
        {
            ThreadLocalToolkit.getLogger().includedFileUpdated(i.next());
        }

        int affectedCount = affected.size();
        logReasonAndRemoveCompilationUnit(affected, reasons, includeUpdated, swcContext);
        logReasonAndRemoveCompilationUnit(updated, reasons, includeUpdated, swcContext);


        // If a source was updated with a stable signature, then we need to seed ASCs userDefined
        // with the definitions from that source.  This is because we will recompile only the source with the stable
        // signature, and none of it's dependents.  Those dependencies will point at the old TypeValues,
        // but new TypeValues will be created when we recompile the source because they weren't in userDefined.  By putting
        // the old TypeValues in userDefined, when the Source is recompiled it will reuse that same TypeValue
        // instance, instead of creating a new one.
        // We do not have to do this for the updated or affected maps, because anything in those will force
        // their dependencies to be recompiled.
        seedUserDefined(updatedWithStableSignature.values(), ascContext, perCompileData);

        logReasonAndRemoveCompilationUnit(updatedWithStableSignature, reasons, includeUpdated, swcContext);

		// if a compilation unit becomes obsolete, its satellite compilation units in ResourceContainer
		// must go away too.
		for (Source s : resources.sources().values())
		{
			if (s != null)
			{
				String name = s.getNameForReporting();
				if (affected.containsKey(name) || updated.containsKey(name))
				{
					s.removeCompilationUnit();
				}
			}
		}

        affected.clear();

        // validate multinames
        // - MultiNameMeaningChanged
        for (Iterator<Source> iterator = sources.iterator(); iterator.hasNext();)
        {
            Source s = iterator.next();
            CompilationUnit u = s.getCompilationUnit();
            if (u == null) continue;

            for (Entry<MultiName, QName> entry : u.inheritanceHistory.entrySet())
            {
                MultiName multiName = entry.getKey();
                QName qName = entry.getValue();

                try
                {
                    if (!validateMultiName(multiName, qName, sourcePath))
                    {
                        affected.put(s.getName(), s);
                        reasons.put(s.getName(), l10n.getLocalizedTextString(new MultiNameMeaningChanged(multiName, qName)));
                        iterator.remove();
                    }
                }
                catch (CompilerException ex)
                {
                    affected.put(s.getName(), s);
                    reasons.put(s.getName(), ex.getMessage());
                    iterator.remove();
                }
            }
        }

        affectedCount += affected.size();

        // remove CompilationUnits from affected Map
        logReasonAndRemoveCompilationUnit(affected, reasons, includeUpdated, swcContext);

		// if a compilation unit becomes obsolete, its satellite compilation units in ResourceContainer
		// must go away too.
		for (Source s : resources.sources().values())
		{
			if (s != null)
			{
				String name = s.getNameForReporting();
				if (affected.containsKey(name))
				{
					s.removeCompilationUnit();
				}
			}
		}

        // refresh the state of ResourceContainer
        resources.refresh();

        // finally, remove the deleted namespaces from SymbolTable...
        if (perCompileData != null)
        {
            for (String ns : namespaces)
            {
                perCompileData.removeNamespace(ns);
            }
        }

        final int updateCount = updated.size() + updatedWithStableSignature.size();
        if (updateCount + affectedCount > 0)
        {
            ThreadLocalToolkit.log(new FilesChangedAffected(updateCount, affectedCount));
        }

        // Any sources left are valid and if they have type info, we
        // need to seed ASC's userDefined with them, so we don't end
        // up with multiple TypeValue copies floating around.  The
        // global SWC cache requires this to be run.
        seedUserDefined(sources, ascContext, perCompileData);

        if (configuration.getBenchmarkCompilerDetails() > 0 &&
            ThreadLocalToolkit.getBenchmark() != null)
        {
            ThreadLocalToolkit.getBenchmark().benchmark2("validateCompilationUnits");
        }

        int count = updateCount + affectedCount;

        return count;
    }

    private static void addDependents(Source source, Set<Name> dependencies,
                                      Map<QName, Map<String, Source>> dependents)
    {
        for (Name name : dependencies)
        {
            QName qName = toQName(name);

            if (qName != null)
            {
                Map<String, Source> sourceMap = dependents.get(qName);

                if (sourceMap != null)
                {
                    sourceMap.put(source.getName(), source);
                }
            }
        }
    }

    private static QName toQName(Name name)
    {
        QName result = null;

        if (name instanceof QName)
        {
            result = (QName) name;
        }
        else if (name instanceof MultiName)
        {
            MultiName multiName = (MultiName) name;
            
            if (multiName.getNumQNames() == 1)
            {
                result = multiName.getQName(0);
            }
        }

        return result;
    }

    private static void dependentFileModified(Source affectedSource,
                                              Map<QName, Map<String, Source>> dependents,
                                              Map<String, Source> updated,
                                              Map<String, Source> affected,
                                              Map<String, String> reasons,
                                              Set<Source> sources)
    {
        LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
        CompilationUnit compilationUnit = affectedSource.getCompilationUnit();

        if (compilationUnit != null)
        {
            for (QName qName : compilationUnit.topLevelDefinitions)
            {
                if (dependents.containsKey(qName))
                {
                    for (Entry<String, Source> dependentEntry : dependents.get(qName).entrySet())
                    {
                        if (!updated.containsKey(dependentEntry.getKey()) &&
                            !affected.containsKey(dependentEntry.getKey()))
                        {
                            affected.put(dependentEntry.getKey(), dependentEntry.getValue());
                            reasons.put(dependentEntry.getKey(),
                                        l10n.getLocalizedTextString(new DependentFileModified(affectedSource.getName())));

                            sources.remove(dependentEntry.getValue());
                            dependentFileModified(dependentEntry.getValue(), dependents, updated, affected, reasons, sources);
                        }
                    }
                }
            }
        }
    }

    /**
     * Helper for validateCompilationUnits(). Removes the CompilationUnit for sources in map,
     * and logs the reasons.
     */
    private static void logReasonAndRemoveCompilationUnit(final Map<String, Source> map,
                                                          final Map<String, String> reasons,
                                                          final Set<String> includeUpdated,
                                                          CompilerSwcContext compilerSwcContext)
    {
        Logger logger = ThreadLocalToolkit.getLogger();

        for (Entry<String, Source> entry : map.entrySet())
        {
            String name = entry.getKey();
            Source s = entry.getValue();

            for (Iterator j = s.getFileIncludes(); j.hasNext();)
            {
                VirtualFile f = (VirtualFile) j.next();
                if (!includeUpdated.contains(f.getNameForReporting()))
                {
                    ThreadLocalToolkit.getLogger().includedFileAffected(f.getNameForReporting());
                }
            }

            CompilationUnit compilationUnit = s.getCompilationUnit();

            if (compilationUnit != null)
            {
                for (QName topLevelDefinition : compilationUnit.topLevelDefinitions)
                {
                    SwcScript swcScript = compilerSwcContext.getCachedScript(topLevelDefinition);

                    // Make sure the SwcScript's cached CompilationUnit isn't reused.
                    if (swcScript != null)
                    {
                        CompilationUnit swcScriptCompilationUnit = swcScript.getCompilationUnit();

                        if (swcScriptCompilationUnit != null)
                        {
                            // SwcContext's getSource() has the side effect of
                            // copying cached type information into a new
                            // Source object, so we need to clean that up too.
                            swcScriptCompilationUnit.getSource().removeCompilationUnit();
                            swcScript.setCompilationUnit(null);
                        }
                    }
                }
            }

            // It might be tempting to only call
            // removeCompilationUnit() if the compilationUnit is not
            // null, but it does more than just remove the
            // compilationUnit.
            s.removeCompilationUnit();

            logger.needsCompilation(s.getName(), reasons.get(s.getName()));
        }
    }

    /**
     * Returns true if the Slot referenced by the two ObjectValue's isn't the same.
     */
    private static boolean referencesDifferentSlots(Context ascContext, ObjectValue referencingTypeInfo,
                                                    QName qName, ObjectValue referencedTypeInfo)
    {
        boolean result = false;
        int kind = Tokens.GET_TOKEN;
        String localPart = qName.getLocalPart().intern();
        ObjectValue namespace = ascContext.getNamespace(qName.getNamespace().intern());
        
        if (referencingTypeInfo.hasName(ascContext, kind, localPart, namespace) &&
            referencedTypeInfo.hasName(ascContext, kind, localPart, namespace))
        {
            int referencingIndex = referencingTypeInfo.getSlotIndex(ascContext, kind, localPart, namespace);
            int referencedIndex = referencedTypeInfo.getSlotIndex(ascContext, kind, localPart, namespace);

            if (referencingIndex != referencedIndex)
            {
                Slot referencingSlot = referencingTypeInfo.getSlot(ascContext, referencingIndex);
                Slot referencedSlot = referencedTypeInfo.getSlot(ascContext, referencedIndex);

                // Types are stored in VariableSlot's as opposed to MethodSlot's.
                if ((referencingSlot instanceof VariableSlot) &&
                    (referencedSlot instanceof VariableSlot) &&
                    (referencingSlot.getValue() != referencedSlot.getValue()))
                {
                    result = true;
                }
            }
        }


        return result;
    }

    /**
     * This method is used to populate ASC's userDefined Map with the typeInfo from a set of sources.
     */
    private static void seedUserDefined(Collection<Source> sources, Context ascContext, ContextStatics perCompileData)
    {
        for (Source s : sources)
        {
            CompilationUnit u = s.getCompilationUnit();

            if ((u != null) && u.hasTypeInfo)
            {
				ObjectValue frame = u.typeInfo;
                
                for (QName topLevelDefinition : u.topLevelDefinitions)
                {
                    String name = topLevelDefinition.getLocalPart().intern();
                    ObjectValue namespace = ascContext.getNamespace(topLevelDefinition.getNamespace().intern());

                    if (frame.hasName(ascContext, Tokens.GET_TOKEN, name, namespace))
                    {
                        int slotId = frame.getSlotIndex(ascContext, Tokens.GET_TOKEN, name, namespace);
                        Slot slot = frame.getSlot(ascContext, slotId);

                        if (slot != null)
                        {
                            int implicitId = frame.getImplicitIndex(ascContext, slotId, Tokens.EMPTY_TOKEN);

                            if ((slotId != implicitId) && (slot instanceof VariableSlot))
                            {
                                Slot implicitSlot = frame.getSlot(ascContext, implicitId);
                                TypeValue typeValue = implicitSlot.getType().getTypeValue();
                                assert topLevelDefinition.toString().equals(typeValue.name.toString()) : 
                                "topLevelDefinition = " + topLevelDefinition + ", typeValue = " + typeValue.name.toString();
                                perCompileData.userDefined.put(typeValue.name.toString(), typeValue);
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * Runs the parser over a Source and returns the SignatureChecksum. The Source is copied.
     */
    private static Long computeSignatureChecksum(Configuration configuration, final Source source)
    {
        assert (configuration != null);

        //TODO It would be nice to cache this; it cannot (?) be static, however,
        //     as the Configuration changes. Solution would be a static Map or some fancy logic?
        // temporary compiler to get a syntax tree, for signature generation
        final As3Compiler asc = new As3Compiler(configuration.getCompilerConfiguration());
        asc.addCompilerExtension(SignatureExtension.getInstance());

        // create a new CompilationUnit if no error occur
        // then grab the signature if no signature error occur
        CompilationUnit u = null;

        // this is needed by Source.Resolver.resolve().
        ThreadLocalToolkit.setCompatibilityVersion(configuration.getCompatibilityVersion());

        // this swallows any parse errors -- they will get thrown when the file is
        // officially reparsed for compilation
        final Logger original = ThreadLocalToolkit.getLogger();
        ThreadLocalToolkit.setLogger(new LocalLogger(null));
        {
            final Source tmpSource = asc.preprocess(
                           Source.newSource(source.getBackingFile(),      source.getFileTime(),
                                            source.getPathRoot(),         source.getRelativePath(),
                                            source.getShortName(),        source.getOwner(),
                                            source.isInternal(),          source.isRoot(),
                                            source.isDebuggable(),        source.getFileIncludesSet(),
                                            source.getFileIncludeTimes(), source.getLogger()));

            // HACK: Forcefully disable any chance of signatures getting emitted to
            //       the filesystem -- since this code should be as fast as possible.
            //       Don't worry though, it WILL happen later during re-compilation.
            final String tmp = SignatureExtension.signatureDirectory;
            SignatureExtension.signatureDirectory = null;
            {
                u = asc.parse1(tmpSource, new SymbolTable(configuration));
            }
            SignatureExtension.signatureDirectory = tmp;
        }
        ThreadLocalToolkit.setLogger(original);

        return ((u != null) ? u.getSignatureChecksum() : null);
    }


    private static boolean validateMultiName(MultiName multiName, QName qName, SourcePath sourcePath)
        throws CompilerException
    {
        for (int i = 0, length = multiName.namespaceURI.length; i < length; i++)
        {
            String ns = multiName.namespaceURI[i];
            String name = multiName.localPart;

            // C: findSource() may do a Source.copy()... we don't need Source.copy() in this case.
            Source s = (sourcePath != null) ? sourcePath.findSource(ns, name) : null;
            CompilationUnit u = (s != null) ? s.getCompilationUnit() : null;

            if (u != null)
            {
                ns = u.topLevelDefinitions.first().getNamespace();
            }

            if (s != null && !(qName.getNamespace().equals(ns) && qName.getLocalPart().equals(name)))
            {
                return false;
            }
        }

        return true;
    }

    private static void addVerticesToGraphs(List<Source> sources, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph)
    {
        for (int i = 0, size = sources.size(); i < size; i++)
        {
            Source s = sources.get(i);
            if (s != null)
            {
                addVertexToGraphs(s, s.getCompilationUnit(), igraph, dgraph);
            }
        }
    }

    private static void addVertexToGraphs(Source s, CompilationUnit u, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph)
    {
        String name = s.getName();

        if (u != null || igraph.get(name) == null)
        {
            igraph.put(name, u);
        }

        if (!igraph.containsVertex(name))
        {
            igraph.addVertex(new Vertex<String,CompilationUnit>(name));
        }

        if (dgraph != null)
        {
            dgraph.put(name, s);
            if (!dgraph.containsVertex(name))
            {
                dgraph.addVertex(new Vertex<String,Source>(name));
            }
        }
    }

    private static boolean preprocess(List<Source> sources, flex2.compiler.SubCompiler[] compilers,
                                      int start, int end, boolean suppressWarnings)
    {
        boolean result = true;

        for (int i = start; i < end; i++)
        {
            Source s = sources.get(i);
            if (s.isPreprocessed())
            {
                continue;
            }

            if ((s = preprocess(s, compilers, suppressWarnings)) == null)
            {
                result = false;
            }
            else
            {
                sources.set(i, s);
            }

            if (tooManyErrors())
            {
                ThreadLocalToolkit.log(new TooManyErrors());
                break;
            }

            if (forcedToStop())
            {
                ThreadLocalToolkit.log(new ForcedToStop());
                break;
            }
        }

        return result;
    }

    /**
     * use this to display warnings from the compilation unit list when nothing needs to be recompiled.
     */
    public static void displayWarnings(List units)
    {
        for (int i = 0, size = units == null ? 0 : units.size(); i < size; i++)
        {
            CompilationUnit u = (CompilationUnit) units.get(i);
            Source s = (u != null) ? u.getSource() : null;

            if (s != null && s.getLogger() != null && s.getLogger().warningCount() > 0 && !s.getLogger().isConnected())
            {
                s.getLogger().displayWarnings(ThreadLocalToolkit.getLogger());
            }
        }
    }

    static Source preprocess(Source s, flex2.compiler.SubCompiler[] compilers, boolean suppressWarnings)
    {
        if (!s.isCompiled())
        {
            // C: A fresh or healthy Source should not have a Logger.
            if (s.getLogger() != null && s.getLogger().warningCount() > 0 && !s.getLogger().isConnected() && !suppressWarnings)
            {
                s.getLogger().displayWarnings(ThreadLocalToolkit.getLogger());
            }

            flex2.compiler.SubCompiler c = getCompiler(s, compilers);
            if (c != null)
            {
                Logger original = ThreadLocalToolkit.getLogger();
                // assert !(original instanceof LocalLogger);

                LocalLogger local = new LocalLogger(original, s);
                local.setLocalizationManager(ThreadLocalToolkit.getLocalizationManager());
                s.setLogger(local);
                ThreadLocalToolkit.setLogger(local);

                s = c.preprocess(s);

                ThreadLocalToolkit.setLogger(original);

                if (local.errorCount() > 0)
                {
                    if (s != null)
                    {
                        s.disconnectLogger();
                    }

                    s = null;
                }
                else
                {
                    s.setPreprocessed();
                }
            }
            else
            {
                s = null;
            }
        }

        return s;
    }

    private static boolean parse1(List<Source> sources, List<CompilationUnit> units, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph,
                                 flex2.compiler.SubCompiler[] compilers, SymbolTable symbolTable,
                                 int start, int end)
    {
        boolean result = true;

        for (int i = start; i < end; i++)
        {
            Source s = sources.get(i);
            CompilationUnit u;

            if ((u = parse1(s, compilers, symbolTable)) == null)
            {
                result = false;
                s.disconnectLogger();
            }

            for (int j = units.size(); j < i + 1; j++)
            {
                units.add(null);
            }

            units.set(i, u);

            addVertexToGraphs(s, u, igraph, dgraph);

            calculateProgress(sources, symbolTable);

            if (tooManyErrors())
            {
                ThreadLocalToolkit.log(new TooManyErrors());
                break;
            }

            if (forcedToStop())
            {
                ThreadLocalToolkit.log(new ForcedToStop());
                break;
            }
        }

        return result;
    }

    private static CompilationUnit parse1(Source s, flex2.compiler.SubCompiler[] compilers, SymbolTable symbolTable)
    {
        if (s.isCompiled())
        {
            return s.getCompilationUnit();
        }

        CompilationUnit u = null;
        flex2.compiler.SubCompiler c = getCompiler(s, compilers);
        if (c != null)
        {
            Logger original = ThreadLocalToolkit.getLogger(), local = s.getLogger();
            ThreadLocalToolkit.setLogger(local);

            u = c.parse1(s, symbolTable);

            // reset the logger to the original one...
            ThreadLocalToolkit.setLogger(original);

            if (local.errorCount() == 0)
            {
                symbolTable.registerQNames(u.topLevelDefinitions, u.getSource());

                u.setState(CompilationUnit.SyntaxTree);
                u.setWorkflow(preprocess);
                u.setWorkflow(parse1);
            }
        }

        return u;
    }

    private static boolean parse2(List<Source> sources, flex2.compiler.SubCompiler[] compilers,
                                  SymbolTable symbolTable, int start, int end)
    {
        boolean result = true;

        for (int i = start; i < end; i++)
        {
            Source source = sources.get(i);
            CompilationUnit u = source.getCompilationUnit();

            if ((u.getWorkflow() & parse2) != 0)
            {
                continue;
            }

            if (!parse2(u, compilers, symbolTable))
            {
                result = false;
                u.getSource().disconnectLogger();
            }

            calculateProgress(sources, symbolTable);

            if (tooManyErrors())
            {
                ThreadLocalToolkit.log(new TooManyErrors());
                break;
            }

            if (forcedToStop())
            {
                ThreadLocalToolkit.log(new ForcedToStop());
                break;
            }
        }

        return result;
    }

    private static boolean parse2(List<Source> sources, flex2.compiler.SubCompiler[] compilers, SymbolTable symbolTable)
    {
        return parse2(sources, compilers, symbolTable, 0, sources.size());
    }

    private static boolean parse2(CompilationUnit u, flex2.compiler.SubCompiler[] compilers, SymbolTable symbolTable)
    {
        Source s = u.getSource();

        if (!s.isCompiled())
        {
            flex2.compiler.SubCompiler c = getCompiler(s, compilers);
            if (c != null)
            {
                // C: may use CompilationUnit to reference the local logger so as to minimize
                //    the number of creations...
                Logger original = ThreadLocalToolkit.getLogger(), local = s.getLogger();
                ThreadLocalToolkit.setLogger(local);

                c.parse2(u, symbolTable);
                u.setWorkflow(parse2);
                ThreadLocalToolkit.setLogger(original);

                if (local.errorCount() > 0)
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
        }

        return true;
    }

    private static boolean analyze(List<Source> sources, flex2.compiler.SubCompiler[] compilers,
                                   SymbolTable symbolTable, int phase)
    {
        return analyze(sources, compilers, symbolTable, 0, sources.size(), phase);
    }

    private static boolean analyze(List<Source> sources, flex2.compiler.SubCompiler[] compilers,
                                   SymbolTable symbolTable, int start, int end, int phase)
    {
        boolean result = true;

        for (int i = start; i < end; i++)
        {
            Source source = sources.get(i);
            CompilationUnit u = source.getCompilationUnit();

            if ((phase == 1 && (u.getWorkflow() & analyze1) != 0) ||
                (phase == 2 && (u.getWorkflow() & analyze2) != 0) ||
                (phase == 3 && (u.getWorkflow() & analyze3) != 0) ||
                (phase == 4 && (u.getWorkflow() & analyze4) != 0))
            {
                continue;
            }

            if (!analyze(u, compilers, symbolTable, phase))
            {
                result = false;
                u.getSource().disconnectLogger();
            }

            calculateProgress(sources, symbolTable);

            // C: make sure that Source and CompilationUnit always point to each other.
            assert u.getSource().getCompilationUnit() == u;

            if (tooManyErrors())
            {
                ThreadLocalToolkit.log(new TooManyErrors());
                break;
            }

            if (forcedToStop())
            {
                ThreadLocalToolkit.log(new ForcedToStop());
                break;
            }
        }

        return result;
    }

    private static boolean analyze(CompilationUnit u, flex2.compiler.SubCompiler[] compilers, SymbolTable symbolTable,
                                   int phase)
    {
        Source s = u.getSource();

        if (!s.isCompiled())
        {
            flex2.compiler.SubCompiler c = getCompiler(s, compilers);

            if (c != null)
            {
                // C: may use CompilationUnit to reference the local logger so as to minimize
                //    the number of creations...
                Logger original = ThreadLocalToolkit.getLogger(), local = s.getLogger();
                ThreadLocalToolkit.setLogger(local);

                if (phase == 1)
                {
                    c.analyze1(u, symbolTable);

                    if (local.errorCount() == 0)
                    {
                        // C: check u.topLevelDefinitions...
                        if (s.isSourcePathOwner() || s.isSourceListOwner())
                        {
                            int size = u.topLevelDefinitions.size();
                            if (size > 1)
                            {
                                ThreadLocalToolkit.log(new MoreThanOneDefinition(u.topLevelDefinitions), s);
                            }
                            else if (size < 1)
                            {
                                ThreadLocalToolkit.log(new MustHaveOneDefinition(), s);
                            }
                            else if (s.isSourcePathOwner())
                            {
                                SourcePath owner = (SourcePath) s.getOwner();

                                String[] packages = owner.checkPackageNameDirectoryName(s);
                                if (packages != null)
                                {
                                    ThreadLocalToolkit.log(new WrongPackageName(packages[0], packages[1]), s);
                                }

                                String[] classes = owner.checkClassNameFileName(s);
                                if (classes != null)
                                {
                                    ThreadLocalToolkit.log(new WrongDefinitionName(classes[0], classes[1]), s);
                                }
                            }
                            else if (s.isSourceListOwner())
                            {
                                SourceList owner = (SourceList) s.getOwner();

                                String[] packages = owner.checkPackageNameDirectoryName(s);
                                if (packages != null)
                                {
                                    ThreadLocalToolkit.log(new WrongPackageName(packages[0], packages[1]), s);
                                }

                                String[] classes = owner.checkClassNameFileName(s);
                                if (classes != null)
                                {
                                    ThreadLocalToolkit.log(new WrongDefinitionName(classes[0], classes[1]), s);
                                }
                            }
                        }

                        // symbolTable.registerQNames(u.topLevelDefinitions, u.getSource());
                    }

                    u.setWorkflow(analyze1);
                }
                else if (phase == 2)
                {
                    c.analyze2(u, symbolTable);
                    u.setWorkflow(analyze2);
                }
                else if (phase == 3)
                {
                    c.analyze3(u, symbolTable);
                    u.setWorkflow(analyze3);
                }
                else // phase == 4
                {
                    c.analyze4(u, symbolTable);
                    u.setWorkflow(analyze4);
                }

                ThreadLocalToolkit.setLogger(original);

                if (local.errorCount() > 0)
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
        }

        return true;
    }

    private static void resolveInheritance(List<Source> sources, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph,
                                           SymbolTable symbolTable, SourceList sourceList, SourcePath sourcePath,
                                           ResourceContainer resources, CompilerSwcContext swcContext, int start, int end)
    {
        Set<QName> qNames = new HashSet<QName>();

        for (int i = start; i < end; i++)
        {
            Source source = sources.get(i);
            CompilationUnit u = source.getCompilationUnit();

            if (u == null || u.inheritance.size() == 0)
            {
                continue;
            }

            qNames.clear();

            String head = source.getName();
            String name = source.getNameForReporting();

            for (Iterator<Name> iterator = u.inheritance.iterator(); iterator.hasNext();)
            {
                Name unresolved = iterator.next();

                if (unresolved instanceof MultiName)
                {
                    MultiName mName = (MultiName) unresolved;
                    QName qName = resolveMultiName(name, mName, sources, sourceList, sourcePath, resources, swcContext, symbolTable);

                    if (qName != null)
                    {
                        Source tailSource = symbolTable.findSourceByQName(qName);
                        String tail = tailSource.getName();
                        addVertexToGraphs(tailSource, tailSource.getCompilationUnit(), igraph, dgraph);
                        addEdgeToGraphs(igraph, dgraph, head, tail);
                        qNames.add(qName);
                        u.inheritanceHistory.put(mName, qName);
                        iterator.remove();
                    }
                }
            }

            if (qNames.size() > 0)
            {
                u.inheritance.addAll(qNames);
            }
        }
    }

    private static void resolveNamespace(List<Source> sources, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph,
                                         SymbolTable symbolTable, SourceList sourceList, SourcePath sourcePath,
                                         ResourceContainer resources, CompilerSwcContext swcContext, int start, int end)
    {
        Set<QName> qNames = new HashSet<QName>();

        for (int i = start; i < end; i++)
        {
            Source source = sources.get(i);
            CompilationUnit u = source.getCompilationUnit();

            if (u.namespaces.size() == 0)
            {
                continue;
            }

            qNames.clear();

            String head = source.getName();
            String name = u.getSource().getNameForReporting();

            for (Iterator<Name> iterator = u.namespaces.iterator(); iterator.hasNext();)
            {
                Name unresolved = iterator.next();

                if (unresolved instanceof MultiName)
                {
                    MultiName mName = (MultiName) unresolved;
                    QName qName = resolveMultiName(name, mName, sources, sourceList, sourcePath, resources, swcContext, symbolTable);

                    if (qName != null)
                    {
                        Source tailSource = symbolTable.findSourceByQName(qName);
                        String tail = tailSource.getName();
                        addVertexToGraphs(tailSource, tailSource.getCompilationUnit(), igraph, dgraph);
                        addEdgeToGraphs(null, dgraph, head, tail);
                        qNames.add(qName);
                        u.namespaceHistory.put(mName, qName);
                        iterator.remove();
                    }
                }
            }

            if (qNames.size() > 0)
            {
                u.namespaces.addAll(qNames);
            }
        }
    }

    // this will be set by asdoc. if true source from disk will be preferred over source from swc
    private static boolean skipTimestampCheck = false;
    
    private static int findDefinition(List<Source> sources, SourceList sourceList, SourcePathBase sourcePath,
                                      ResourceContainer resources, CompilerSwcContext swcContext,
                                      String namespaceURI, String localPart)
        throws CompilerException
    {
        Source s = (sourceList != null) ? sourceList.findSource(namespaceURI, localPart) : null;

        if (s == null)
        {
            s = (sourcePath != null) ? sourcePath.findSource(namespaceURI, localPart) : null;
        }

        if (s == null)
        {
            s = (resources != null) ? resources.findSource(namespaceURI, localPart) : null;
        }

        Source swcSource = (swcContext != null) ? swcContext.getSource(namespaceURI, localPart) : null;

        // No sense recompiling the same source file again.
        if ((swcSource != null) &&
            ((s == null) ||
             ((s.getLastModified() == swcSource.getLastModified() && !skipTimestampCheck) &&
              ((s.getCompilationUnit() == null) ||
               (!s.getCompilationUnit().hasTypeInfo)))))
        {
            s = swcSource;
        }

        if (s != null)
        {
            int where = sources.indexOf(s);
            if (where == -1)
            {
                sources.add(s);
                return sources.size() - 1;
            }
            else
            {
                return where;
            }
        }
        else
        {
            return -1;
        }
    }

    private static int findResourceBundle(List<Source> sources, SourceList sourceList, SourcePathBase sourcePath, CompilerSwcContext swcContext,
                                          String[] locales, String namespaceURI, String localPart)
        throws CompilerException
    {
        Source s1, s2, s3;
        VirtualFile o1, o2, o3;
        ResourceFile rf1, rf2, rf3;

        s1 = (sourceList != null) ? sourceList.findSource(namespaceURI, localPart) : null;
        o1 = (s1 != null) ? s1.getBackingFile() : null;

        // already compiled. return...
        if (o1 instanceof InMemoryFile)
        {
            return findResourceBundleHelper(sources, s1);
        }

        rf1 = (ResourceFile) o1;

        if (rf1 != null && rf1.complete())
        {
            return findResourceBundleHelper(sources, s1);
        }
        else
        {
            // rf1 == null || !rf1.complete(), must get rf2...
            s2 = (sourcePath != null) ? sourcePath.findSource(namespaceURI, localPart) : null;
            o2 = (s2 != null) ? s2.getBackingFile() : null;

            // already compiled. return...
            if (rf1 == null && o2 instanceof InMemoryFile)
            {
                return findResourceBundleHelper(sources, s2);
            }
            else if (o2 instanceof InMemoryFile)
            {
                o2 = null;
            }

            rf2 = (ResourceFile) o2;

            if (rf1 != null)
            {
                rf1.merge(rf2);
            }
            else
            {
                rf1 = rf2;
                s1 = s2;
            }
        }

        if (rf1 != null && rf1.complete())
        {
            return findResourceBundleHelper(sources, s1);
        }
        else
        {
            // rf1 == null || !rf1.complete(), must get rf3...
            s3 = (swcContext != null) ? swcContext.getResourceBundle(locales, namespaceURI, localPart) : null;
            o3 = (s3 != null) ? s3.getBackingFile() : null;

            // already compiled. return...
            if (rf1 == null && o3 instanceof InMemoryFile)
            {
                return findResourceBundleHelper(sources, s3);
            }
            else if (o3 instanceof InMemoryFile)
            {
                o3 = null;
            }

            rf3 = (ResourceFile) o3;

            if (rf1 != null)
            {
                rf1.merge(rf3);
            }
            else
            {
                rf1 = rf3;
                s1 = s3;
            }
        }

        return findResourceBundleHelper(sources, s1);
    }

    private static int findResourceBundleHelper(List<Source> sources, Source s)
    {
        if (s != null)
        {
            int where = sources.indexOf(s);
            if (where == -1)
            {
                sources.add(s);
                return sources.size() - 1;
            }
            else
            {
                return where;
            }
        }
        else
        {
            return -1;
        }
    }

    private static boolean hasPackage(SourcePath sourcePath, CompilerSwcContext swcContext, String packageName)
    {
        // C: This should check with "sources" before SourcePath and CompilerSwcContext... or check with
        //    FileSpec and SourceList, not "sources"... will fix it asap...
        boolean hasPackage = (sourcePath != null) && sourcePath.hasPackage(packageName);

        if (!hasPackage && swcContext != null)
        {
            hasPackage = swcContext.hasPackage(packageName);
        }

        return hasPackage;
    }

    private static boolean hasDefinition(SourcePath sourcePath, CompilerSwcContext swcContext, QName defName)
    {
        boolean hasDefinition = (sourcePath != null) && sourcePath.hasDefinition(defName);

        if (!hasDefinition && swcContext != null)
        {
            hasDefinition = swcContext.hasDefinition(defName);
        }

        return hasDefinition;
    }

    private static boolean sortInheritance(List<Source> sources, final List<CompilationUnit> units, final DependencyGraph<CompilationUnit> graph)
    {
        assert sources.size() == units.size();
        boolean success = true;
        final List<CompilationUnit> tsort = new ArrayList<CompilationUnit>(units.size());

        Algorithms.topologicalSort(graph, new Visitor<Vertex<String,CompilationUnit>>()
        {
            public void visit(Vertex<String,CompilationUnit> v)
            {
                String name = v.getWeight();
                CompilationUnit u = graph.get(name);
                assert u != null : name;
                tsort.add(u);
            }
        });

        if (units.size() > tsort.size())
        {
            for (int i = 0, size = units.size(); i < size; i++)
            {
                CompilationUnit u = units.get(i);
                if (!tsort.contains(u))
                {
                    ThreadLocalToolkit.log(new CircularInheritance(), u.getSource());
                    success = false;
                }
            }
            assert !success;
        }
        else
        {
            sources.clear();
            units.clear();
            for (int i = 0, size = tsort.size(); i < size; i++)
            {
                CompilationUnit u = tsort.get(i);
                sources.add(u.getSource());
                units.add(u);
            }
        }

        return success;
    }

    private static boolean detectCycles(List<Source> sources, final DependencyGraph<CompilationUnit> graph)
    {
        final Map<String, Source> tsort = new HashMap<String, Source>(sources.size());

        for (int i = 0, size = sources.size(); i < size; i++)
        {
            Source s = sources.get(i);
            tsort.put(s.getName(), s);
        }

        Algorithms.topologicalSort(graph, new Visitor<Vertex<String,CompilationUnit>>()
        {
            public void visit(Vertex<String,CompilationUnit> v)
            {
                String name = v.getWeight();
                tsort.remove(name);
            }
        });

        if (tsort.size() > 0)
        {
            for (Iterator<String> i = tsort.keySet().iterator(); i.hasNext();)
            {
                String name = i.next();
                Source s = tsort.get(name);
                if (!s.hasError())
                {
                    ThreadLocalToolkit.log(new CircularInheritance(), name);
                }
            }

            return true;
        }
        else
        {
            return false;
        }
    }

    private static void addGeneratedSources(List<Source> sources, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph,
                                            ResourceContainer resources, SymbolTable symbolTable,
                                            Configuration configuration, int start, int end)
    {
        for (int i = start; i < end; i++)
        {
            Source source = sources.get(i);
            CompilationUnit u = source.getCompilationUnit();
            if (u != null)
            {
                Map<QName, Source> generatedSources = u.getGeneratedSources();
                if (generatedSources != null)
                {
                    for (Entry<QName, Source> entry : generatedSources.entrySet())
                    {
                        QName qName = entry.getKey();
                        MultiName mN = new MultiName(qName.getNamespace(), qName.getLocalPart());
                        Source gSource = entry.getValue();
                        String gName = gSource.getName();

                        if (!igraph.containsVertex(gName))
                        {
                            gSource = resources.addResource(gSource);
                            addVertexToGraphs(gSource, gSource.getCompilationUnit(), igraph, dgraph);
                            sources.add(gSource);

                            // C: This is similar to CompilerAPI.resolveMultiName(). The resolveMultiName() method does more
                            //    than adding Source objects to "sources".
                            symbolTable.registerMultiName(mN, qName);
                            symbolTable.registerQName(qName, gSource);
                        }

                        // C: If we manually add to CompilationUnit.expressions, we must add MultiName instances,
                        //    otherwise, incremental compilation will lose the dependency because the multiname
                        //    qname mapping isn't in expressionHistory.
                        u.expressions.add(mN);
                    }

                    u.clearGeneratedSources();
                }

                @SuppressWarnings("unchecked")
                Map<String, VirtualFile> cssArchiveFiles = (Map<String, VirtualFile>) u.getContext().getAttribute(CompilerContext.CSS_ARCHIVE_FILES);
                if (cssArchiveFiles != null && cssArchiveFiles.size() > 0)
                {
                    configuration.addCSSArchiveFiles(cssArchiveFiles);
                }

                @SuppressWarnings("unchecked")
                Map<String, VirtualFile> l10nArchiveFiles = (Map<String, VirtualFile>) u.getContext().getAttribute(CompilerContext.L10N_ARCHIVE_FILES);
                if (l10nArchiveFiles != null && l10nArchiveFiles.size() > 0)
                {
                    configuration.addL10nArchiveFiles(l10nArchiveFiles);
                }
            }
        }
    }

    private static void resolveType(List<Source> sources, List<CompilationUnit> units, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph, SymbolTable symbolTable,
                                    SourceList sourceList, SourcePath sourcePath, ResourceContainer resources, CompilerSwcContext swcContext)
    {
        resolveType(sources, units, igraph, dgraph, symbolTable, sourceList, sourcePath, resources, swcContext, 0, units.size());
    }

    private static void resolveType(List<Source> sources, List<CompilationUnit> units, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph,
                                    SymbolTable symbolTable, SourceList sourceList, SourcePath sourcePath,
                                    ResourceContainer resources, CompilerSwcContext swcContext, int start, int end)
    {
        Set<QName> qNames = new HashSet<QName>();

        for (int i = start; i < end; i++)
        {
            Source s = sources.get(i);
            CompilationUnit u = (s != null) ? s.getCompilationUnit() : units.get(i);

            if ((u.getWorkflow() & resolveType) != 0 || u.types.size() == 0)
            {
                continue;
            }

            qNames.clear();

            String head = u.getSource().getName();
            String name = u.getSource().getNameForReporting();

            for (Iterator<Name> iterator = u.types.iterator(); iterator.hasNext();)
            {
                Name unresolved = iterator.next();

                if (unresolved instanceof MultiName)
                {
                    MultiName mName = (MultiName) unresolved;
                    QName qName = resolveMultiName(name, mName, sources, sourceList, sourcePath, resources, swcContext, symbolTable);

                    if (qName != null)
                    {
                        Source tailSource = symbolTable.findSourceByQName(qName);
                        String tail = tailSource.getName();
                        addVertexToGraphs(tailSource, tailSource.getCompilationUnit(), igraph, dgraph);
                        addEdgeToGraphs(null, dgraph, head, tail);
                        qNames.add(qName);
                        u.typeHistory.put(mName, qName);
                        iterator.remove();
                    }
                }
            }

            if (qNames.size() > 0)
            {
                u.types.addAll(qNames);
            }
        }

        for (int i = start; i < end; i++)
        {
            Source s = sources.get(i);
            CompilationUnit u = (s != null) ? s.getCompilationUnit() : units.get(i);

            if ((u.getWorkflow() & resolveType) != 0)
            {
                continue;
            }
            else
            {
                u.setWorkflow(resolveType);
                if (u.namespaces.size() == 0)
                {
                    continue;
                }
            }

            qNames.clear();

            String head = u.getSource().getName();
            String name = u.getSource().getNameForReporting();

            for (Iterator<Name> iterator = u.namespaces.iterator(); iterator.hasNext();)
            {
                Name unresolved = iterator.next();

                if (unresolved instanceof MultiName)
                {
                    MultiName mName = (MultiName) unresolved;
                    QName qName = resolveMultiName(name, mName, sources, sourceList, sourcePath, resources, swcContext, symbolTable);

                    if (qName != null)
                    {
                        Source tailSource = symbolTable.findSourceByQName(qName);
                        String tail = tailSource.getName();
                        addVertexToGraphs(tailSource, tailSource.getCompilationUnit(), igraph, dgraph);
                        addEdgeToGraphs(null, dgraph, head, tail);
                        qNames.add(qName);
                        u.namespaceHistory.put(mName, qName);
                        iterator.remove();
                    }
                }
            }

            if (qNames.size() > 0)
            {
                u.namespaces.addAll(qNames);
            }
        }
    }

    private static void resolveImportStatements(List<Source> sources, List<CompilationUnit> units,
                                                SourcePath sourcePath,
                                                CompilerSwcContext swcContext)
    {
        resolveImportStatements(sources, units, sourcePath, swcContext, 0, units.size());
    }

    private static void resolveImportStatements(List<Source> sources, List<CompilationUnit> units,
                                                SourcePath sourcePath,
                                                CompilerSwcContext swcContext,
                                                int start, int end)
    {
        for (int i = start; i < end; i++)
        {
            Source s = sources.get(i);
            CompilationUnit u = (s != null) ? s.getCompilationUnit() : units.get(i);

            if ((u.getWorkflow() & resolveImportStatements) != 0)
            {
                continue;
            }
            else
            {
                u.setWorkflow(resolveImportStatements);
            }

            for (Iterator k = u.importPackageStatements.iterator(); k.hasNext();)
            {
                String packageName = (String) k.next();

                if (!hasPackage(sourcePath, swcContext, packageName))
                {
                    k.remove();
                }
            }

            for (Iterator k = u.importDefinitionStatements.iterator(); k.hasNext();)
            {
                QName defName = (QName) k.next();

                if (!hasDefinition(sourcePath, swcContext, defName))
                {
                    k.remove();
                }
            }
        }
    }

    private static void resolveExpression(List<Source> sources, List<CompilationUnit> units, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph, SymbolTable symbolTable,
                                          SourceList sourceList, SourcePath sourcePath, ResourceContainer resources,
                                          CompilerSwcContext swcContext, Configuration configuration)
    {
        resolveExpression(sources, units, igraph, dgraph, symbolTable, sourceList, sourcePath, resources, swcContext,
                          configuration, 0, units.size());
    }

    private static void resolveExpression(List<Source> sources, List<CompilationUnit> units, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph, SymbolTable symbolTable,
                                          SourceList sourceList, SourcePath sourcePath, ResourceContainer resources,
                                          CompilerSwcContext swcContext, Configuration configuration,
                                          int start, int end)
    {
        Set<QName> qNames = new HashSet<QName>();

        for (int i = start; i < end; i++)
        {
            Source s = sources.get(i);
            CompilationUnit u = (s != null) ? s.getCompilationUnit() : units.get(i);

            if (u.expressions.size() == 0)
            {
                continue;
            }

            qNames.clear();

            String head = u.getSource().getName();
            String name = u.getSource().getNameForReporting();

            for (Iterator<Name> iterator = u.expressions.iterator(); iterator.hasNext();)
            {
                Name unresolved = iterator.next();

                if (unresolved instanceof MultiName)
                {
                    MultiName mName = (MultiName) unresolved;
                    QName qName = resolveMultiName(name, mName, sources, sourceList, sourcePath, resources, swcContext, symbolTable);

                    if (qName != null)
                    {
                        Source tailSource = symbolTable.findSourceByQName(qName);
                        String tail = tailSource.getName();
                        addVertexToGraphs(tailSource, tailSource.getCompilationUnit(), igraph, dgraph);
                        addEdgeToGraphs(null, dgraph, head, tail);
                        qNames.add(qName);
                        u.expressionHistory.put(mName, qName);
                    }
                    else
                    {
                        // ASC doesn't seem to care about unresolved expression deps too much.
                        // This list seems to have a lot of false positives (i.e. generated local methods?)
                        // so the warning is contingent on an advanced config var.
                        if (configuration.getCompilerConfiguration().showDependencyWarnings())
                        {
                            ThreadLocalToolkit.log(new UnableToResolveDependency(mName.getLocalPart()), u.getSource());
                        }
                    }

                    // Due to the false positives, we have to remove
                    // the MultiName, even if it wasn't resolved
                    // successfully.  Otherwise, the false positive
                    // will lead to unnecessary global SWC cache
                    // invalidations in validationCompilationUnits().
                    iterator.remove();
                }
            }

            if (qNames.size() > 0)
            {
                u.expressions.addAll(qNames);
            }
        }
    }

    // e.g. head = mx.core.Application (subclass), tail = mx.containers.Container (superclass), 'head' needs 'tail'
    private static void addEdgeToGraphs(DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph, String head, String tail)
    {
        if (igraph != null)
        {
            if (!head.equals(tail) && !igraph.dependencyExists(head, tail))
            {
                igraph.addDependency(head, tail);
            }
        }

        if (dgraph != null)
        {
            if (!head.equals(tail) && !dgraph.dependencyExists(head, tail))
            {
                dgraph.addDependency(head, tail);
            }
        }
    }

    private static void adjustQNames(List<CompilationUnit> units, DependencyGraph<CompilationUnit> igraph, SymbolTable symbolTable)
    {
        // C: A temporary fix for the issue when the true QName of the top level definition in a source file
        //    from the classpath is not known until the source file is parsed...
        for (int i = 0, size = units.size(); i < size; i++)
        {
            CompilationUnit u = units.get(i);

            if (u != null && u.isDone() && (u.getWorkflow() & adjustQNames) == 0)
            {
                for (Name name : u.inheritance)
                {
                    if (name instanceof QName)
                    {
                        QName qName = (QName) name;
                        adjustQName(qName, igraph, symbolTable);
                    }
                }

                for (Name name : u.namespaces)
                {
                    if (name instanceof QName)
                    {
                        QName qName = (QName) name;
                        adjustQName(qName, igraph, symbolTable);
                    }
                }

                for (Name name : u.types)
                {
                    if (name instanceof QName)
                    {
                        QName qName = (QName) name;
                        adjustQName(qName, igraph, symbolTable);
                    }
                }

                for (Name name : u.expressions)
                {
                    if (name instanceof QName)
                    {
                        QName qName = (QName) name;
                        adjustQName(qName, igraph, symbolTable);
                    }
                }

                u.setWorkflow(adjustQNames);
            }
        }
    }

    private static void adjustQName(QName qName, DependencyGraph<CompilationUnit> igraph, SymbolTable symbolTable)
    {
        Source s = symbolTable.findSourceByQName(qName);
        CompilationUnit u = igraph.get(s == null ? null : s.getName());
        if (u != null && (u.getSource().isSourcePathOwner() || u.getSource().isSourceListOwner()) &&
            u.topLevelDefinitions.size() == 1)
        {
            QName def = u.topLevelDefinitions.last();
            if (qName.getLocalPart().equals(def.getLocalPart()) && !qName.getNamespace().equals(def.getNamespace()))
            {
                qName.setNamespace( def.getNamespace() );
            }
        }
    }

    // C: making this method public is only temporary...
    public static QName resolveMultiName(MultiName multiName, List<Source> sources, SourceList sourceList, SourcePath sourcePath,
                                         ResourceContainer resources, CompilerSwcContext swcContext, SymbolTable symbolTable)
    {
        return resolveMultiName(null, multiName, sources, sourceList, sourcePath, resources, swcContext, symbolTable);
    }

    private static QName resolveMultiName(String nameForReporting, MultiName multiName, List<Source> sources, SourceList sourceList,
                                          SourcePath sourcePath, ResourceContainer resources, CompilerSwcContext swcContext,
                                          SymbolTable symbolTable)
    {
        QName qName = symbolTable.isMultiNameResolved(multiName), qName2 = null;
        Source source = null, source2 = null;
        boolean hasAmbiguity = false;

        if (qName != null)
        {
            return qName;
        }

        String[] namespaceURI = multiName.getNamespace();
        String localPart = multiName.getLocalPart();

        for (int j = 0, length = namespaceURI.length; j < length; j++)
        {
            Source s = symbolTable.findSourceByQName(namespaceURI[j], localPart);
            int where = -1;

            if (s == null)
            {
                try
                {
                    where = findDefinition(sources, sourceList, sourcePath, resources, swcContext, namespaceURI[j], localPart);
                }
                catch (CompilerException ex)
                {
                    ThreadLocalToolkit.logError(ex.getMessage());
                }

                if (where != -1)
                {
                    s = sources.get(where);
                }
            }

            if (s != null)
            {
                if (qName == null)
                {
                    qName = new QName(namespaceURI[j], localPart);
                    source = s;

                    // C: comment out the break statement to enforce ambiguity checks...
                    // break;
                }
                else if (!qName.equals(namespaceURI[j], localPart))
                {
                    hasAmbiguity = true;
                    qName2 = new QName(namespaceURI[j], localPart);
                    source2 = s;
                    break;
                }
            }
        }

        if (hasAmbiguity)
        {
            CompilerMessage msg = new AmbiguousMultiname(qName, source.getName(), qName2, source2.getName());

            // C: The MultiName representation does not carry a line number. It looks like it'll improve
            //    error reporting if the AS compiler also tells this method where it found the reference.
            if (nameForReporting != null)
            {
                ThreadLocalToolkit.log(msg, nameForReporting);
            }
            else
            {
                ThreadLocalToolkit.log(msg);
            }

            return null;
        }
        else if (source != null)
        {
            symbolTable.registerMultiName(multiName, qName);
            symbolTable.registerQName(qName, source);
        }

        return qName;
    }

    public static QName[] resolveResourceBundleName(String rbName, List<Source> sources, SourceList sourceList,
                                                    SourcePathBase sourcePath, ResourceContainer resources, CompilerSwcContext swcContext,
                                                    SymbolTable symbolTable, String[] locales)
    {
        QName[] qNames = symbolTable.isResourceBundleResolved(rbName);
        if (qNames != null)
        {
            return qNames;
        }

        Source source = symbolTable.findSourceByResourceBundleName(rbName);
        if (source == null)
        {
            int where = -1;
            QName bundleName = new QName(rbName);
            String namespaceURI = bundleName.getNamespace();
            String localPart = bundleName.getLocalPart();

            try
            {
                where = findResourceBundle(sources, sourceList, sourcePath, swcContext, locales, namespaceURI, localPart);
            }
            catch (CompilerException ex)
            {
                ThreadLocalToolkit.logError(ex.getMessage());
            }

            if (where != -1)
            {
                source = sources.get(where);
                qNames = new QName[locales == null ? 0 : locales.length];

                for (int i = 0, length = qNames.length; i < length; i++)
                {
                    qNames[i] = new QName(namespaceURI, locales[i] + "$" + localPart + I18nUtils.CLASS_SUFFIX);
                }
            }
        }

        symbolTable.register(rbName, qNames, source);

        return qNames;
    }

    private static boolean generate(List<Source> sources, List<CompilationUnit> units, flex2.compiler.SubCompiler[] compilers, SymbolTable symbolTable)
    {
        return generate(sources, units, compilers, symbolTable, 0, units.size());
    }

    private static boolean generate(List<Source> sources, List<CompilationUnit> units, flex2.compiler.SubCompiler[] compilers, SymbolTable symbolTable,
                                    int start, int end)
    {
        boolean result = true;

        for (int i = start; i < end; i++)
        {
            Source s = sources.get(i);
            CompilationUnit u = (s != null) ? s.getCompilationUnit() : units.get(i);

            if ((u.getWorkflow() & generate) != 0)
            {
                continue;
            }
            else
            {
                u.setWorkflow(generate);
            }

            if (!u.isBytecodeAvailable() && !generate(u, compilers, symbolTable))
            {
                result = false;
                u.getSource().disconnectLogger();
            }

            calculateProgress(sources, symbolTable);

            if (tooManyErrors())
            {
                ThreadLocalToolkit.log(new TooManyErrors());
                break;
            }

            if (forcedToStop())
            {
                ThreadLocalToolkit.log(new ForcedToStop());
                break;
            }
        }

        return result;
    }

    private static boolean generate(CompilationUnit u, flex2.compiler.SubCompiler[] compilers, SymbolTable symbolTable)
    {
        Source s = u.getSource();
        if (!s.isCompiled())
        {
            flex2.compiler.SubCompiler c = getCompiler(s, compilers);
            if (c != null)
            {
                // C: may use CompilationUnit to reference the local logger so as to minimize
                //    the number of creations...
                Logger original = ThreadLocalToolkit.getLogger(), local = s.getLogger();
                ThreadLocalToolkit.setLogger(local);

                c.generate(u, symbolTable);
                if (u.bytes.size() > 0)
                {
                    u.setState(CompilationUnit.abc);
                }

                ThreadLocalToolkit.setLogger(original);

                if (local.errorCount() > 0)
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
        }

        return true;
    }

    private static boolean postprocess(List<Source> sources, List<CompilationUnit> units, flex2.compiler.SubCompiler[] compilers, SymbolTable symbolTable)
    {
        return postprocess(sources, units, compilers, symbolTable, 0, units.size());
    }

    private static boolean postprocess(List<Source> sources, List<CompilationUnit> units, flex2.compiler.SubCompiler[] compilers, SymbolTable symbolTable,
                                       int start, int end)
    {
        boolean result = true;

        for (int i = start; i < end; i++)
        {
            Source s = sources.get(i);
            CompilationUnit u = (s != null) ? s.getCompilationUnit() : units.get(i);

            if (!postprocess(u, compilers, symbolTable))
            {
                result = false;
                u.getSource().disconnectLogger();
            }

            if (tooManyErrors())
            {
                ThreadLocalToolkit.log(new TooManyErrors());
                break;
            }

            if (forcedToStop())
            {
                ThreadLocalToolkit.log(new ForcedToStop());
                break;
            }
        }

        return result;
    }

    private static boolean postprocess(CompilationUnit u, flex2.compiler.SubCompiler[] compilers, SymbolTable symbolTable)
    {
        Source s = u.getSource();
        if (!s.isCompiled())
        {
            flex2.compiler.SubCompiler c = getCompiler(s, compilers);
            if (c != null)
            {
                Logger original = ThreadLocalToolkit.getLogger(), local = s.getLogger();
                ThreadLocalToolkit.setLogger(local);

                c.postprocess(u, symbolTable);

                ThreadLocalToolkit.setLogger(original);

                if (local.errorCount() > 0)
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
        }

        return true;
    }

    private static void getIncludeClasses(List<Source> sources, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph, SymbolTable symbolTable,
                                          SourceList sourceList, SourcePath sourcePath, ResourceContainer resources,
                                          CompilerSwcContext swcContext, Configuration configuration)
    {
        Set<String> includes = new LinkedHashSet<String>();
        includes.addAll( configuration.getIncludes() );
        for (Iterator<FrameInfo> it = configuration.getFrameList().iterator(); it.hasNext();)
        {
            FramesConfiguration.FrameInfo f = it.next();
            includes.addAll( f.frameClasses );
        }
        for (Iterator<String> it = includes.iterator(); it.hasNext();)
        {
            String className = it.next();
            MultiName mName = new MultiName(className);
            QName qName = resolveMultiName("configuration", mName, sources, sourceList, sourcePath, resources, swcContext, symbolTable);

            if (qName != null)
            {
                Source tailSource = symbolTable.findSourceByQName(qName);
                addVertexToGraphs(tailSource, tailSource.getCompilationUnit(), igraph, dgraph);
            }
            else
            {
                ThreadLocalToolkit.log(new UnableToResolveClass("include", className));
            }
        }
    }

    private static void getIncludeResources(List<Source> sources, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph, ResourceBundlePath bundlePath,
                                            SymbolTable symbolTable, CompilerSwcContext swcContext, Configuration configuration)
    {
        Map resourceIncludes = swcContext.getResourceIncludes();
        String[] locales = configuration.getCompilerConfiguration().getLocales();

        for (Iterator it = resourceIncludes.keySet().iterator(); it.hasNext();)
        {
            String rbName = NameFormatter.toColon((String) it.next());
            QName[] qNames = resolveResourceBundleName(rbName, sources, null, bundlePath,
                                                       null, swcContext, symbolTable, locales);
            if (qNames != null)
            {
                Source source = symbolTable.findSourceByResourceBundleName(rbName);
                addVertexToGraphs(source, source.getCompilationUnit(), igraph, dgraph);

                for (int i = 0; i < qNames.length; i++)
                {
                    configuration.getIncludes().add(qNames[i].toString());
                }
            }
        }
    }

    private static void getExtraSources(List<Source> sources, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph,
                                        SourceList sourceList, SourcePath sourcePath, ResourceContainer resources,
                                        ResourceBundlePath bundlePath, SymbolTable symbolTable, CompilerSwcContext swcContext,
                                        Configuration configuration, Map licenseMap)
    {
        getExtraSources(sources, igraph, dgraph, sourceList, sourcePath, resources, bundlePath, symbolTable, swcContext, 0,
                        sources.size(), configuration, licenseMap);
    }

    private static void getExtraSources(List<Source> sources, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph,
                                        SourceList sourceList, SourcePath sourcePath, ResourceContainer resources,
                                        ResourceBundlePath bundlePath, SymbolTable symbolTable,
                                        CompilerSwcContext swcContext, int start, int end, Configuration configuration,
                                        Map licenseMap)
    {
        for (int i = start; i < end; i++)
        {
            Source s = sources.get(i);
            CompilationUnit u = (s != null) ? s.getCompilationUnit() : null;

            if (u != null)
            {
                getExtraSources(u, sources, igraph, dgraph, sourceList, sourcePath, resources, bundlePath, symbolTable, swcContext,
                                configuration, licenseMap);
            }
        }
    }

    private static void getExtraSources(CompilationUnit u, List<Source> sources, DependencyGraph<CompilationUnit> igraph, DependencyGraph<Source> dgraph,
                                        SourceList sourceList, SourcePath sourcePath, ResourceContainer resources,
                                        ResourceBundlePath bundlePath, SymbolTable symbolTable, CompilerSwcContext swcContext,
                                        Configuration configuration, Map licenseMap)
    {
        if ((u.getWorkflow() & extraSources) != 0) return;

        if (u.loaderClass != null)
        {
            String className = u.loaderClass;
            MultiName mName = new MultiName(className);
            QName qName = resolveMultiName(u.getSource().getNameForReporting(), mName, sources, sourceList, sourcePath,
                                           resources, swcContext, symbolTable);

            if (qName != null)
            {
                Source tailSource = symbolTable.findSourceByQName(qName);
                addVertexToGraphs(tailSource, tailSource.getCompilationUnit(), igraph, dgraph);
            }
            else
            {
                ThreadLocalToolkit.log(new UnableToResolveClass("factoryClass", className));
            }
        }

        configuration.getResourceBundles().addAll(u.resourceBundleHistory);
        boolean processResourceBundles = configuration.getCompilerConfiguration().useResourceBundleMetadata() && u.resourceBundleHistory.size() > 0;

        if (processResourceBundles)
        {
            String[] locales = configuration.getCompilerConfiguration().getLocales();

            for (Iterator it = u.resourceBundleHistory.iterator(); it.hasNext();)
            {
                String rbName = NameFormatter.toColon((String) it.next());
                Source source = null;
                QName[] qNames = resolveResourceBundleName(rbName, sources, null, bundlePath,
                                                           null, swcContext, symbolTable, locales);
                if (qNames != null)
                {
                    source = symbolTable.findSourceByResourceBundleName(rbName);
                    addVertexToGraphs(source, source.getCompilationUnit(), igraph, dgraph);
                    continue;
                }

                MultiName mName = new MultiName(rbName);
                QName qName = resolveMultiName(u.getSource().getNameForReporting(), mName, sources, null, sourcePath,
                                               null, null, symbolTable);
                if (qName != null)
                {
                    source = symbolTable.findSourceByQName(qName);
                    addVertexToGraphs(source, source.getCompilationUnit(), igraph, dgraph);

                    symbolTable.register(rbName, qNames, source);
                    continue;
                }

                mName = new MultiName(rbName + I18nUtils.CLASS_SUFFIX);
                qName = resolveMultiName(u.getSource().getNameForReporting(), mName, sources, null, null,
                                         null, swcContext, symbolTable);
                if (qName != null)
                {
                    source = symbolTable.findSourceByQName(qName);
                    addVertexToGraphs(source, source.getCompilationUnit(), igraph, dgraph);

                    symbolTable.register(rbName, qNames, source);
                }
                else if (locales.length == 1)
                {
                    ThreadLocalToolkit.log(new UnableToResolveResourceBundleForLocale(rbName, locales[0]));
                }
                else if (locales.length > 1)
                {
                    ThreadLocalToolkit.log(new UnableToResolveResourceBundle(rbName));
                }
            }
        }

        // ToDo: For Apache Flex remove this section since there is no longer a license.
        if ((u.licensedClassReqs != null) && (u.licensedClassReqs.size() > 0))
        {
            for (Iterator it = u.licensedClassReqs.entrySet().iterator(); it.hasNext();)
            {
                Map.Entry e = (Map.Entry) it.next();
                String id = (String) e.getKey();
                String handler = (String) e.getValue();

                if (!hasValidLicense(licenseMap, id))
                {
                    MultiName mName = new MultiName(handler);
                    QName qName = resolveMultiName(u.getSource().getNameForReporting(), mName, sources, sourceList,
                                                   sourcePath, resources, swcContext, symbolTable);
                    configuration.getIncludes().add(handler);
                    configuration.getExterns().remove(handler);   // don't let them try to extern it

                    if (qName != null)
                    {
                        // if the license is missing, we still may be able to be in
                        // a "demo" mode under control of the license handler
                        Source tailSource = symbolTable.findSourceByQName(qName);
                        addVertexToGraphs(tailSource, tailSource.getCompilationUnit(), igraph, dgraph);
                    }
                    else
                    {
                        // no license, no handler, no SWF
                        ThreadLocalToolkit.log(new UnableToResolveClass("RequiresLicense handler", handler));
                    }
                }
                else
                {
                    // if there is a license and the license handler is unconditionally added, remove it.
                    configuration.getIncludes().remove(handler);
                    configuration.getExterns().add(handler);
                }
            }
        }

        if ((u.extraClasses != null) && (u.extraClasses.size() > 0))
        {
            for (Iterator it = u.extraClasses.iterator(); it.hasNext();)
            {
                String className = (String) it.next();
                MultiName mName = new MultiName(className);
                QName qName = resolveMultiName(u.getSource().getNameForReporting(), mName, sources, sourceList,
                                               sourcePath, resources, swcContext, symbolTable);

                if (qName != null)
                {
                    Source tailSource = symbolTable.findSourceByQName(qName);
                    addVertexToGraphs(tailSource, tailSource.getCompilationUnit(), igraph, dgraph);
                }
                else
                {
                    ThreadLocalToolkit.log(new UnableToResolveNeededClass(className));
                }
            }
        }

        u.setWorkflow(extraSources);
    }

    private static void checkResourceBundles(List<Source> sources, SymbolTable symbolTable)
            throws CompilerException
    {
        for (Iterator<Source> iterator = sources.iterator(); iterator.hasNext();)
        {
            Source s = iterator.next();
            CompilationUnit u = (s != null) ? s.getCompilationUnit() : null;
            if (u != null && u.resourceBundleHistory.size() > 0)
            {
                for (Iterator it = u.resourceBundleHistory.iterator(); it.hasNext();)
                {
                    String rbName = (String) it.next();
                    Source rbSource = symbolTable.findSourceByResourceBundleName(rbName);
                    if (rbSource != null)
                    {
                        CompilationUnit rbUnit = rbSource.getCompilationUnit();
                        for (int j = 0, size = rbUnit == null ? 0 : rbUnit.topLevelDefinitions.size(); j < size; j++)
                        {
                            u.resourceBundles.add(rbUnit.topLevelDefinitions.get(j).toString());
                        }
                    }
                }
            }
        }

        if (ThreadLocalToolkit.errorCount() > 0)
        {
            throw new CompilerException();
        }
    }

    private static boolean hasValidLicense(Map licenseMap, String id)
    {    	
    	// For Apache Flex there is no license.
    	return true;
    }

    private static void markDone(List<Source> sources, List<CompilationUnit> units)
    {
        markDone(sources, units, 0, units.size());
    }

    private static void markDone(List<Source> sources, List<CompilationUnit> units, int start, int end)
    {
        for (int i = start; i < end; i++)
        {
            Source s = sources.get(i);
            CompilationUnit u = (s != null) ? s.getCompilationUnit() : units.get(i);
            // C: There are requirements a CompilationUnit must meet before this marks the unit as Done.
            //    1. is the bytecode available?
            //    2. how about assets??
            if (u.getSource().isCompiled())
            {
                u.setState(CompilationUnit.Done);
            }
        }
    }

    private static flex2.compiler.SubCompiler getCompiler(Source source, flex2.compiler.SubCompiler[] compilers)
    {
        for (int i = 0, length = source == null || compilers == null ? 0 : compilers.length; i < length; i++)
        {
            if (compilers[i].isSupported(source.getMimeType()))
            {
                return compilers[i];
            }
        }
        return null;
    }

    /**
     * builds a list of VirtualFiles from list of path strings.
     */
    public static List<VirtualFile> getVirtualFileList(List<? extends Object> files)
        throws ConfigurationException
    {
        return new ArrayList<VirtualFile>(fileSetFromPaths(files, false, null, null));
    }

    /**
     * builds a list of VirtualFiles from list of path strings. Directories are scanned recursively, using mimeTypes
     * (if not null) as a filter.
     */
    public static List<VirtualFile> getVirtualFileList(Collection<? extends Object> paths, Set mimeTypes)
        throws ConfigurationException
    {
        return new ArrayList<VirtualFile>(fileSetFromPaths(paths, true, mimeTypes, null));
    }

    /**
     * list[0] --> List for FileSpec
     * list[1] --> List for SourceList
     */
    public static List<VirtualFile>[] getVirtualFileList(Collection<? extends Object> paths, Collection<VirtualFile> stylesheets, Set mimeTypes, List<File> directories)
        throws ConfigurationException
    {
        return getVirtualFileList(paths, stylesheets, mimeTypes, directories, null);
    }

    public static List<VirtualFile>[] getVirtualFileList(Collection<? extends Object> paths, Collection<VirtualFile> stylesheets, Set mimeTypes, List<File> directories,
            Collection<? extends Object> excludedPaths) throws ConfigurationException
	{
        //TODO this function should really be cleaned up to use Array.newInstance and
        //     List<List<VirtualFile>> instead of an array, so that we can get compile-time type-checks
        @SuppressWarnings("unchecked")
        List<VirtualFile>[] array = new List[2];

        array[0] = new ArrayList<VirtualFile>();
        array[1] = new ArrayList<VirtualFile>();

        if(excludedPaths != null) {
            LinkedList tempExcludedPaths = new LinkedList();
            Iterator iterator = excludedPaths.iterator();
            while (iterator.hasNext())
            {
                String path = (String)iterator.next();
                VirtualFile file = getVirtualFile(path);
                tempExcludedPaths.add(file);
            }

            excludedPaths = tempExcludedPaths;
        }

		List<VirtualFile> list = new ArrayList<VirtualFile>(fileSetFromPaths(paths, true, mimeTypes, null, excludedPaths));
		for (int i = 0, len = list == null ? 0 : list.size(); i < len; i++)
		{
			VirtualFile f = list.get(i);
			array[(SourceList.calculatePathRoot(f, directories) == null) ? 0 : 1].add(f);
		}
		for (Iterator<VirtualFile> j = stylesheets.iterator(); j.hasNext(); )
		{
			VirtualFile f = j.next();
			array[(SourceList.calculatePathRoot(f, directories) == null) ? 0 : 1].add(f);
		}

        return array;
    }

    public static List<VirtualFile>[] getVirtualFileList(Set<VirtualFile> fileSet, List<File> directories)
    {
        //TODO this function should really be cleaned up to use Array.newInstance and
        //     List<List<VirtualFile>> instead of an array, so that we can get compile-time type-checks
        @SuppressWarnings("unchecked")
        List<VirtualFile>[] array = new List[2];
        array[0] = new ArrayList<VirtualFile>();
        array[1] = new ArrayList<VirtualFile>();

        for (VirtualFile f : fileSet)
        {
            array[(SourceList.calculatePathRoot(f, directories) == null) ? 0 : 1].add(f);
        }

        return array;
    }

	private static Set<VirtualFile> fileSetFromPaths(Collection<? extends Object> paths, boolean recurse, Set mimeTypes, Set<VirtualFile> fileSet)
    throws ConfigurationException
    {
	    return fileSetFromPaths(paths, recurse, mimeTypes, fileSet, null);
    }

	/**
	 * Build a set of virtual files by scanning a mix of file and directory paths.
	 * @param paths a list of path strings.
	 * @param recurse if true, directories are recursively scanned. If not, they're just added to the returned set
	 * @param mimeTypes if non-null, this filters the files found in scanned directories (but not top-level, i.e.
	 * explicitly given files)
	 * @param fileSet if non-null, files are added to this set and a reference ts returned. If null, a new Set is created.
	 * @param excludedPaths This is only set via asdoc, its for -exclude-sources option.
	 */
	private static Set<VirtualFile> fileSetFromPaths(Collection<? extends Object> paths, boolean recurse, Set mimeTypes, Set<VirtualFile> fileSet, Collection<? extends Object> excludedPaths)
		throws ConfigurationException
	{
		boolean topLevel;
		if (topLevel = (fileSet == null))
		{
			fileSet = new HashSet<VirtualFile>(paths.size());
		}
		for (Iterator<? extends Object> iter = paths.iterator(); iter.hasNext(); )
		{
			Object next = iter.next();
			VirtualFile file;
			if (next instanceof VirtualFile)
			{
				file = (VirtualFile) next;
			}
			else
			{
				String path = (next instanceof File) ? ((File)next).getAbsolutePath() : (String)next;

				file = getVirtualFile(path);

                if(excludedPaths != null && excludedPaths.contains(file)) {
                    excludedPaths.remove(file);
                    file = null;
                }
			}

			if (file != null)
			{
				if (recurse && file.isDirectory())
				{
					File dir = FileUtil.openFile(file.getName());
					if (dir == null)
					{
						throw new ConfigurationException.IOError(file.getName());
					}
                    fileSetFromPaths(Arrays.asList(dir.listFiles()), true, mimeTypes, fileSet, excludedPaths);
                }
                else if (topLevel || mimeTypes == null || mimeTypes.contains(file.getMimeType()))
                {
                    fileSet.add(file);
                }
            }
        }
        return fileSet;
    }

    public static VirtualFile getVirtualFile(String path) throws ConfigurationException
    {
        return getVirtualFile(path, true);
    }

    /**
     * Create virtual file for given file and throw configuration exception if not possible
     */
    public static VirtualFile getVirtualFile(String path, boolean reportError) throws ConfigurationException
    {
        VirtualFile result;
        File file = FileUtil.openFile(path);

        if (file != null && FileUtils.exists(file))
        {
            result = new LocalFile(FileUtil.getCanonicalFile(file));
        }
        else
        {
            PathResolver resolver = ThreadLocalToolkit.getPathResolver();
            result = resolver.resolve(path);

            if (result == null && reportError)
            {
                throw new ConfigurationException.IOError(path);
            }
        }

        return result;
    }

    /**
     * Encode movie; produce binary output
     *
     * @param movie
     * @throws java.io.IOException
     */
    public static void encode(Configuration configuration, Movie movie, OutputStream out) throws IOException
    {
        // TODO PERFORMANCE:
        // We create a TagEncoder, writes everything to the TagEncoder, and then copy the
        // result to the intended output stream. There is no reason for the copy. TagEncoder
        // contains a "protected SwfEncoder writer", and SwfEncoder extends RandomAccessBuffer,
        // which extends ByteArrayOutputStream -- this writer would need to be replaced with
        // some other object that can accept an OutputStream in its constructor. The point is
        // to eliminate the extra buffers, and just always write directly to the intended target.
        // - mikemo
        final boolean useCompression = configuration.getCompilerConfiguration().useCompression();
        TagEncoder encoder = configuration.generateSizeReport() ? new TagEncoderReporter() : new TagEncoder();        
        new MovieEncoder(encoder).export(movie, useCompression);
        encoder.writeTo(out);
        generateSizeReport(configuration, movie, encoder);

        if (ThreadLocalToolkit.getBenchmark() != null)
        {
            LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
            if (l10n != null)
            ThreadLocalToolkit.getBenchmark().benchmark(l10n.getLocalizedTextString(new SWFEncoding()));
        }
    }

    public static void encode(ConsoleApplication app, OutputStream out) throws IOException
    {
        List abcList = app.getABCs();
        for (int i = 0, size = abcList.size(); i < size; i++)
        {
            out.write((byte[]) abcList.get(i));
        }

        if (ThreadLocalToolkit.getBenchmark() != null)
        {
            LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
            if (l10n != null)
            ThreadLocalToolkit.getBenchmark().benchmark(l10n.getLocalizedTextString(new SWFEncoding()));
        }
    }

    private static void generateSizeReport(Configuration config, Movie movie, TagEncoder encoder)
    {
        if (config.generateSizeReport() && movie instanceof SimpleMovie && 
        		encoder instanceof TagEncoderReporter)
        {
            String report = ((TagEncoderReporter)encoder).getSizeReport();
            ((SimpleMovie)movie).setSizeReport(report);
            String fileName = config.getSizeReportFileName();
            
            if (fileName != null)
            {
	            try
	            {
	                FileUtil.writeFile(fileName, report);
	            }
	            catch (Exception ex)
	            {
	                ThreadLocalToolkit.log( new UnableToWriteSizeReport( fileName ) );
	            }
            }
        }
    }
    
    /**
     * @see flex2.compiler.PersistenceStore
     */
    public static void persistCompilationUnits(Configuration configuration,
            FileSpec fileSpec, SourceList sourceList, SourcePath sourcePath,
            ResourceContainer resources, ResourceBundlePath bundlePath,
            int checksum, String description, RandomAccessFile f)
        throws IOException
    {
        persistCompilationUnits(configuration, fileSpec, sourceList, sourcePath, resources, bundlePath, null, null,
                                checksum, checksum, checksum, checksum, null, null,
                                description, f);
    }

    /**
     * @see flex2.compiler.PersistenceStore
     */
    public static void persistCompilationUnits(Configuration configuration,
            FileSpec fileSpec, SourceList sourceList, SourcePath sourcePath,
            ResourceContainer resources, ResourceBundlePath bundlePath,
            List sources, List units, int checksums[],
            Map<QName, Long> swcDefSignatureChecksums,
            Map<String, Long> swcFileChecksums,
            Map<String, Long> archiveFileChecksums,
            String description, RandomAccessFile f) throws IOException
    {
        persistCompilationUnits(configuration, fileSpec, sourceList, sourcePath, resources, bundlePath,
                sources, units,
                checksums[0], checksums[1], checksums[2], checksums[3],
                swcDefSignatureChecksums, swcFileChecksums,
                archiveFileChecksums, description, f);
    }

    /**
     * @see flex2.compiler.PersistenceStore
     */
    public static void persistCompilationUnits(Configuration configuration, FileSpec fileSpec, SourceList sourceList, SourcePath sourcePath,
            ResourceContainer resources, ResourceBundlePath bundlePath,
            List sources, List units,
            int checksum, int cmd_checksum, int linker_checksum, int swc_checksum,
            Map<QName, Long> swcDefSignatureChecksums,
            Map<String, Long> swcFileChecksums,
            String description, RandomAccessFile f)
        throws IOException
   {
        persistCompilationUnits(configuration, fileSpec, sourceList, sourcePath,
                resources, bundlePath,
                sources, units,
                checksum, cmd_checksum, linker_checksum, swc_checksum,
                swcDefSignatureChecksums, swcFileChecksums, null,
                description, f);
   }

    /**
     * @see flex2.compiler.PersistenceStore
     */
    public static void persistCompilationUnits(Configuration configuration, FileSpec fileSpec, SourceList sourceList, SourcePath sourcePath,
                                               ResourceContainer resources, ResourceBundlePath bundlePath,
                                               List sources, List units,
                                               int checksum, int cmd_checksum, int linker_checksum, int swc_checksum,
                                               Map<QName, Long> swcDefSignatureChecksums,
                                               Map<String, Long> swcFileChecksums,
                                               Map<String, Long> archiveFileChecksums,
                                               String description, RandomAccessFile f)
        throws IOException
    {
        PersistenceStore store = new PersistenceStore(configuration, f);
        int count = -1;
        try
        {
            count = store.write(fileSpec, sourceList, sourcePath, resources, bundlePath, sources, units,
                                checksum, cmd_checksum, linker_checksum, swc_checksum,
                                swcDefSignatureChecksums, swcFileChecksums, archiveFileChecksums, description);
        }
        finally
        {
            if (count != -1 && ThreadLocalToolkit.getBenchmark() != null)
            {
                LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
                if (l10n == null)
                {
                    // set up for localizing messages
                    l10n = new LocalizationManager();
                    l10n.addLocalizer( new XLRLocalizer() );
                    l10n.addLocalizer( new ResourceBundleLocalizer() );
                    ThreadLocalToolkit.setLocalizationManager(l10n);
                }
                if (ThreadLocalToolkit.getLogger() == null)
                {
                    // this is called by flex builder running outside the OEM api.
                    flex2.compiler.CompilerAPI.useConsoleLogger();
                }
                ThreadLocalToolkit.getBenchmark().benchmark(l10n.getLocalizedTextString(new PersistingCompilationUnits(count)));
            }
        }
    }

    /**
     * Used by flex2.tools.oem.Library.
     */
    public static void loadCompilationUnits(Configuration configuration, FileSpec fileSpec, SourceList sourceList, SourcePath sourcePath,
                ResourceContainer resources, ResourceBundlePath bundlePath,
                List sources, List<CompilationUnit> units,
                int[] checksums, Map<QName, Long> swcDefSignatureChecksums, Map<String, Long> swcFileChecksums,
                RandomAccessFile f, String cacheName) throws IOException
    {
        loadCompilationUnits(configuration, fileSpec, sourceList, sourcePath,
                             resources, bundlePath, sources, units, checksums,
                             swcDefSignatureChecksums, swcFileChecksums, null, f, cacheName, null);
    }

    /**
     * Appears to be unused.
     */
    public static void loadCompilationUnits(Configuration configuration, FileSpec fileSpec, SourceList sourceList, SourcePath sourcePath,
                                            ResourceContainer resources, ResourceBundlePath bundlePath,
                                            int checksum, RandomAccessFile f, String cacheName)
        throws IOException
    {
        loadCompilationUnits(configuration, fileSpec, sourceList, sourcePath, resources, bundlePath, null, null,
                             new int[] {checksum, checksum, checksum, checksum}, null, null, null, f, cacheName, null);
    }

    /**
     * Used by flex2.tools.oem.Application.
     */
    public static void loadCompilationUnits(Configuration configuration, FileSpec fileSpec, SourceList sourceList, SourcePath sourcePath,
                                            ResourceContainer resources, ResourceBundlePath bundlePath,
                                            List sources, List units,
                                            int[] checksums, Map<QName, Long> swcDefSignatureChecksums, Map swcFileChecksums,
                                            RandomAccessFile f, String cacheName, FontManager fontManager)
        throws IOException
    {
        loadCompilationUnits(configuration, fileSpec, sourceList, sourcePath, resources, bundlePath, sources, units,
                             checksums, swcDefSignatureChecksums, swcFileChecksums, null, f, cacheName, null);
    }

    /**
     * Used by flex2.tools.Mxmlc and flex2.tools.Compc.
     */
    public static void loadCompilationUnits(Configuration configuration, FileSpec fileSpec, SourceList sourceList, SourcePath sourcePath,
                                            ResourceContainer resources, ResourceBundlePath bundlePath,
                                            List sources, List units,
                                            int[] checksums,
                                            Map<QName, Long> swcDefSignatureChecksums, Map swcFileChecksums,
                                            Map<String, Long> archiveFileChecksums,
                                            RandomAccessFile f, String cacheName, FontManager fontManager)
        throws IOException
    {
        LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
        PersistenceStore store = new PersistenceStore(configuration, f, fontManager);
        int count = -1;
        try
        {
            if ((count = store.read(fileSpec, sourceList, sourcePath, resources, bundlePath, sources, units,
                                    checksums, swcDefSignatureChecksums, swcFileChecksums, archiveFileChecksums)) < 0)
            {
                throw new IOException(l10n.getLocalizedTextString(new FailedToMatchCacheFile(cacheName)));
            }
        }
        finally
        {
            if (count >= 0 && ThreadLocalToolkit.getBenchmark() != null)
            {
                ThreadLocalToolkit.getBenchmark().benchmark(l10n.getLocalizedTextString(new LoadingCompilationUnits(count)));
            }
        }
    }

    private static boolean tooManyErrors()
    {
        return ThreadLocalToolkit.errorCount() > 100;
    }

    public static boolean forcedToStop()
    {
        CompilerControl cc = ThreadLocalToolkit.getCompilerControl();
        return (cc != null && cc.getStatus() == CompilerControl.STOP);
    }

    private static void calculateProgress(List<Source> sources, SymbolTable symbolTable)
    {
        symbolTable.tick++;
        int total = sources.size() * 12;
        double p = (double) symbolTable.tick / (double) total;
        int percent = (int) (p * 100);

        if (percent > 100)
        {
            percent = 100;
        }

        if (percent > symbolTable.currentPercentage)
        {
            symbolTable.currentPercentage = percent;
            ProgressMeter meter = ThreadLocalToolkit.getProgressMeter();

            if (meter != null)
            {
                meter.percentDone(percent);
            }
        }
    }

    /**
     * Useful when debugging batch issues.
     */
    @SuppressWarnings("unused")
    private static String workflowToString(int workflow)
    {
        String result;

        if ((workflow & extraSources) >= 1)
        {
            result = "extraSources";
        }
        else if ((workflow & adjustQNames) >= 1)
        {
            result = "adjustQNames";
        }
        else if ((workflow & resolveImportStatements) >= 1)
        {
            result = "resolveImportStatements";
        }
        else if ((workflow & generate) >= 1)
        {
            result = "generate";
        }
        else if ((workflow & resolveType) >= 1)
        {
            result = "resolveType";
        }
        else if ((workflow & analyze4) >= 1)
        {
            result = "analyze4";
        }
        else if ((workflow & analyze3) >= 1)
        {
            result = "analyze3";
        }
        else if ((workflow & analyze2) >= 1)
        {
            result = "analyze2";
        }
        else if ((workflow & analyze1) >= 1)
        {
            result = "analyze1";
        }
        else if ((workflow & parse2) >= 1)
        {
            result = "parse2";
        }
        else if ((workflow & parse1) >= 1)
        {
            result = "parse1";
        }
        else if ((workflow & preprocess) >= 1)
        {
            result = "preprocess";
        }
        else
        {
            result = "before preprocessed";
        }

        return result;
    }

    // error messages

    public static class UnableToSetHeadless extends CompilerMessage.CompilerWarning
    {
        private static final long serialVersionUID = 3008724815757107600L;

        public UnableToSetHeadless()
        {
            super();
        }
    }

    public static class IncompatibleSWCArchive extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 1741319866432830221L;

        public IncompatibleSWCArchive(String swc)
        {
            super();
            this.swc = swc;
        }

        public final String swc;
    }

    public static class OutputTime extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = -6051351911183837367L;

        public OutputTime(int size)
        {
            super();
            this.size = size;
        }

        public final int size;
    }

    public static class NotFullyCompiled extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 4136933749063866830L;

        public NotFullyCompiled()
        {
            super();
        }
    }

    public static class SourceNoLongerExists extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = -2704778045668485048L;

        public SourceNoLongerExists()
        {
            super();
        }
    }

    public static class SourceFileUpdated extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = -5950312800861211191L;

        public SourceFileUpdated()
        {
            super();
        }
    }

    public static class AssetUpdated extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 4010801229607993419L;

        public AssetUpdated()
        {
            super();
        }
    }

    public static class SwcDefinitionObsoleted extends CompilerMessage.CompilerInfo
    {
        public final String newLocation;

        public SwcDefinitionObsoleted(String newLocation)
        {
            super();
            this.newLocation = newLocation;
        }
    }

    public static class DependencyNotCached extends CompilerMessage.CompilerInfo
    {
        public final String dependency;

        public DependencyNotCached(String dependency)
        {
            super();
            this.dependency = dependency;
        }
    }

    public static class NotSourcePathFirstPreference extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = -9215808965455458278L;

        public NotSourcePathFirstPreference()
        {
            super();
        }
    }

    public static class DependentFileNoLongerExists extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 4566054497729698471L;

        public DependentFileNoLongerExists(String location)
        {
            super();
            this.location = location;
        }

        public final String location;
    }

    public static class InvalidImportStatement extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = -6431103025897195931L;

        public InvalidImportStatement(String defName)
        {
            super();
            this.defName = defName;
        }

        public final String defName;
    }

    public static class DependentFileModified extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = -3397344779921936416L;

        public DependentFileModified(String location)
        {
            super();
            this.location = location;
        }

        public final String location;
    }

    public static class MultiNameMeaningChanged extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = -2003160838933415991L;
        public MultiNameMeaningChanged(MultiName multiName, QName qName)
        {
            super();
            this.multiName = multiName;
            this.qName = qName;
        }

        public final MultiName multiName;
        public final QName qName;
    }

    public static class FilesChangedAffected extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 567632711113318088L;

        public FilesChangedAffected(int updateCount, int count)
        {
            super();
            this.updateCount = updateCount;
            this.count = count;
        }

        public final int updateCount, count;
    }

    public static class MoreThanOneDefinition extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 4656607717787554720L;

        public MoreThanOneDefinition(List topLevelDefinitions)
        {
            super();
            this.topLevelDefinitions = topLevelDefinitions;
        }

        public final List topLevelDefinitions;
    }

    public static class MustHaveOneDefinition extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -3136994771425079174L;

        public MustHaveOneDefinition()
        {
            super();
        }
    }

    public static class WrongPackageName extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -2915859996892576941L;

        public WrongPackageName(String pathPackage, String defPackage)
        {
            super();
            this.pathPackage = pathPackage;
            this.defPackage = defPackage;
        }

        public final String pathPackage, defPackage;
    }

    public static class WrongDefinitionName extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -6793666173106638874L;

        public WrongDefinitionName(String pathName, String defName)
        {
            super();
            this.pathName = pathName;
            this.defName = defName;
        }

        public final String pathName, defName;
    }

    public static class CircularInheritance extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 2395431275577572954L;

        public CircularInheritance()
        {
            super();
        }
    }

    public static class DependencyUpdated extends CompilerMessage.CompilerWarning
    {
        public final String dependency;

        public DependencyUpdated(String dependency)
        {
            super();
            this.dependency = dependency;
        }
    }

    public static class UnableToResolveDependency extends CompilerMessage.CompilerWarning
    {
        private static final long serialVersionUID = -5981015158191974877L;

        public UnableToResolveDependency(String localPart)
        {
            super();
            this.localPart = localPart;
        }

        public final String localPart;
    }

    public static class AmbiguousMultiname extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -3521126109099117806L;
        public AmbiguousMultiname(QName qName1, String source1, QName qName2, String source2)
        {
            super();
            this.qName1 = qName1;
            this.source1 = source1;
            this.qName2 = qName2;
            this.source2 = source2;
        }

        public final QName qName1, qName2;
        public final String source1, source2;
    }

    public static class SWFEncoding extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 5936641849426685640L;

        public SWFEncoding()
        {
            super();
        }
    }

    public static class PersistingCompilationUnits extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 3560732877476940286L;

        public PersistingCompilationUnits(int count)
        {
            super();
            this.count = count;
        }

        public final int count;
    }

    public static class FailedToMatchCacheFile extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 555051683127823122L;

        public FailedToMatchCacheFile(String cacheName)
        {
            super();
            this.cacheName = cacheName;
        }

        public final String cacheName;
    }

    public static class LoadingCompilationUnits extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 6116416220246580099L;

        public LoadingCompilationUnits(int count)
        {
            super();
            this.count = count;
        }

        public final int count;
    }

    public static class ChannelDefinitionNotFound extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 5848003710927048218L;

        public ChannelDefinitionNotFound(String clientType)
        {
            super();
            this.clientType = clientType;
        }

        public final String clientType;
    }

    public static class TooManyErrors extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 3209927829940607725L;

        public TooManyErrors()
        {
            super();
        }
    }

    public static class ForcedToStop extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = -8162250327019786018L;

        public ForcedToStop()
        {
            super();
        }
    }

    public static class UnableToWriteSizeReport extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 9098665499898450430L;
        public UnableToWriteSizeReport(String fileName)
        {
            super();
            this.fileName = fileName;
        }
        public final String fileName;
    }
    
    public static class UnableToResolveClass extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 9098665492278450430L;
        public UnableToResolveClass(String type, String className)
        {
            super();
            this.type = type;
            this.className = className;
        }

        public final String type;
        public final String className;
    }

    public static class UnableToResolveNeededClass extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 7916145250681811567L;

        public UnableToResolveNeededClass(String className)
        {
            super();
            this.className = className;
        }

        public final String className;
    }

    public static class UnableToResolveResourceBundle extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = 8772827635337487217L;

        public UnableToResolveResourceBundle(String bundleName)
        {
            super();
            this.bundleName = bundleName;
        }

        public final String bundleName;
    }

    public static class UnableToResolveResourceBundleForLocale extends CompilerMessage.CompilerError
    {
        private static final long serialVersionUID = -8272953403512518246L;
        public UnableToResolveResourceBundleForLocale(String bundleName, String locale)
        {
            super();
            this.bundleName = bundleName;
            this.locale = locale;
        }

        public final String bundleName;
        public final String locale;
    }

    public static class BatchTime extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = -1020248542254534482L;
        public BatchTime(String phase, String sourceName)
        {
            super();
            this.phase = phase;
            this.sourceName = sourceName;
        }

        public final String phase;
        public final String sourceName;
    }

    public static class CompileTime extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = -4940316315109571708L;

        public CompileTime(String phase)
        {
            super();
            this.phase = phase;
        }

        public final String phase;
    }

	static String constructClassName(String namespaceURI, String localPart)
	{
		return (namespaceURI.length() == 0) ? localPart : new StringBuilder(namespaceURI.length() + localPart.length() + 1).append(namespaceURI).append(":").append(localPart).toString();
	}

    public static void setSkipTimestampCheck(boolean skipTimestampCheck)
    {
        CompilerAPI.skipTimestampCheck = skipTimestampCheck;
    }
}
