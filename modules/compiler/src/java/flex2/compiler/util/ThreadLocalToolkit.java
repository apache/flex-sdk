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

import flash.localization.LocalizationManager;
import flex2.compiler.ILocalizableMessage;
import flex2.compiler.Logger;
import flex2.compiler.Source;
import flex2.compiler.common.PathResolver;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.tools.oem.ProgressMeter;

import java.util.HashMap;
import java.util.Map;

/**
 * A utility class that contains all the thread local variables used
 * by the compiler.  These are mostly conveniences so that the
 * variables don't have to be passed around to all the corners of the
 * compiler via method parameters.  These represent potential memory
 * leaks, though.  All the variables should be cleared at the end of a
 * compilation.  Otherwise, if the thread used for compilation
 * changes, lots of memory will be leaked with the old thread.
 *
 * @author Clement Wong
 */
public final class ThreadLocalToolkit
{
    private static ThreadLocal<Logger> logger = new ThreadLocal<Logger>();
    private static ThreadLocal<PathResolver> resolver = new ThreadLocal<PathResolver>();
    private static ThreadLocal<Map<String, VirtualFile>> resolved = new ThreadLocal<Map<String, VirtualFile>>();
    private static ThreadLocal<Benchmark> stopWatch = new ThreadLocal<Benchmark>();
    private static ThreadLocal<LocalizationManager> localization = new ThreadLocal<LocalizationManager>();
    private static ThreadLocal<MimeMappings> mimeMappings = new ThreadLocal<MimeMappings>();
    private static ThreadLocal<ProgressMeter> progressMeter = new ThreadLocal<ProgressMeter>();
    private static ThreadLocal<CompilerControl> compilerControl = new ThreadLocal<CompilerControl>();
    private static ThreadLocal<StandardDefs> standardDefs = new ThreadLocal<StandardDefs>();
    private static ThreadLocal<Integer> compatibilityVersion = new ThreadLocal<Integer>();

    //----------------------
    // LocalizationManager
    //----------------------

    public static LocalizationManager getLocalizationManager()
    {
        return localization.get();
    }

    public static void setLocalizationManager(LocalizationManager mgr)
    {
        localization.set( mgr );
    }

    //---------------
    // PathResolver
    //---------------

    public static void setPathResolver(PathResolver r)
    {
        resolver.set(r);
    }

    public static void resetResolvedPaths()
    {
        resolved.set(null);
    }

    public static PathResolver getPathResolver()
    {
        return resolver.get();
    }

    public static void addResolvedPath(String path, VirtualFile virtualFile)
    {
        Map<String, VirtualFile> resolvedMap = resolved.get();
        if (resolvedMap == null)
        {
            resolvedMap = new HashMap<String, VirtualFile>();
            resolved.set(resolvedMap);
        }

        resolvedMap.put(path, virtualFile);
    }

    public static VirtualFile getResolvedPath(String path)
    {
        Map<String, VirtualFile> resolvedMap = resolved.get();
        assert resolvedMap != null;
        return (VirtualFile) resolvedMap.get(path);
    }

    //---------------
    // Benchmarking
    //---------------

    public static void setBenchmark(Benchmark b)
    {
        stopWatch.set(b);
    }

    public static Benchmark getBenchmark()
    {
        return stopWatch.get();
    }

    public static void resetBenchmark()
    {
        Benchmark b = stopWatch.get();
        if (b != null)
        {
            b.start();
        }
    }

    //---------------
    // MimeMappings
    //---------------

    public static void setMimeMappings(MimeMappings mappings)
    {
        mimeMappings.set(mappings);
    }
    
    static MimeMappings getMimeMappings()
    {
        return mimeMappings.get();
    }
    
    //----------------
    // ProgressMeter
    //----------------

    public static void setProgressMeter(ProgressMeter meter)
    {
        progressMeter.set(meter);
    }
    
    public static ProgressMeter getProgressMeter()
    {
        return progressMeter.get();
    }

    //-------------------
    // Compiler Control
    //-------------------
    
    public static void setCompilerControl(CompilerControl cc)
    {
        compilerControl.set(cc);
    }
    
    public static CompilerControl getCompilerControl()
    {
        return compilerControl.get();
    }

    //----------------
    // Standard Defs
    //----------------
    public static void setStandardDefs(StandardDefs defs)
    {
        standardDefs.set(defs);
    }

    public static StandardDefs getStandardDefs()
    {
        StandardDefs defs = standardDefs.get();
        if (defs == null)
        {
            defs = StandardDefs.getStandardDefs("halo");
            setStandardDefs(defs);
        }

        return defs;
    }

    //---------
    // Logger
    //---------

    public static void setLogger(Logger logger)
    {
        ThreadLocalToolkit.logger.set(logger);
        if (logger != null)
        {
            logger.setLocalizationManager( getLocalizationManager() );
        }
    }

    public static Logger getLogger()
    {
        return logger.get();
    }

    //---------
    // CompatibilityVersion
    //---------

    public static void setCompatibilityVersion(Integer compatibilityVersion)
    {
        ThreadLocalToolkit.compatibilityVersion.set(compatibilityVersion);
    }

    public static Integer getCompatibilityVersion()
    {
        assert compatibilityVersion.get() != null : "Entry point missing setCompatibilityVersion()";
        return compatibilityVersion.get();
    }

    //--------------------------------------------------------------------------
    //
    // Logging Methods
    //
    //--------------------------------------------------------------------------
    
    public static int errorCount()
    {
        Logger l = logger.get();
        if (l != null)
        {
            return l.errorCount();
        }
        else
        {
            return 0;
        }
    }

    public static int warningCount()
    {
        Logger l = logger.get();
        if (l != null)
        {
            return l.warningCount();
        }
        else
        {
            return 0;
        }
    }

    public static void logInfo(String info)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logInfo(info);
        }
        else
        {
            System.out.println(info);
        }
    }

    public static void logDebug(String debug)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logDebug(debug);
        }
        else
        {
            System.err.println(debug);
        }
    }

    public static void logWarning(String warning)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logWarning(warning);
        }
        else
        {
            System.err.println(warning);
        }
    }

    public static void logError(String error)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logError(error);
        }
        else
        {
            System.err.println(error);
        }
    }

    public static void logInfo(String path, String info)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logInfo(path, info);
        }
        else
        {
            System.out.println(path + ":" + info);
        }
    }

    public static void logDebug(String path, String debug)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logDebug(path, debug);
        }
        else
        {
            System.err.println(path + ":" + debug);
        }
    }

    public static void logWarning(String path, String warning)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logWarning(path, warning);
        }
        else
        {
            System.err.println(path + ":" + warning);
        }
    }

    public static void logWarning(String path, String warning, int errorCode)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logWarning(path, warning, errorCode);
        }
        else
        {
            System.err.println(path + ":" + warning);
        }
    }

    public static void logError(String path, String error)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logError(path, error);
        }
        else
        {
            System.err.println(path + ":" + error);
        }
    }

    public static void logError(String path, String error, int errorCode)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logError(path, error, errorCode);
        }
        else
        {
            System.err.println(path + ":" + error);
        }
    }

    public static void logInfo(String path, int line, String info)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logInfo(path, line, info);
        }
        else
        {
            System.out.println(path + ": line " + line + " - " + info);
        }
    }

    public static void logDebug(String path, int line, String debug)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logDebug(path, line, debug);
        }
        else
        {
            System.err.println(path + ": line " + line + " - " + debug);
        }
    }

    public static void logWarning(String path, int line, String warning)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logWarning(path, line, warning);
        }
        else
        {
            System.err.println(path + ": line " + line + " - " + warning);
        }
    }

    public static void logError(String path, int line, String error)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logError(path, line, error);
        }
        else
        {
            System.err.println(path + ": line " + line + " - " + error);
        }
    }

    public static void logInfo(String path, int line, int col, String info)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logInfo(path, line, col, info);
        }
        else
        {
            System.out.println(path + ": line " + line + ", col " + col + " - " + info);
        }
    }

    public static void logDebug(String path, int line, int col, String debug)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logDebug(path, line, col, debug);
        }
        else
        {
            System.err.println(path + ": line " + line + ", col " + col + " - " + debug);
        }
    }

    public static void logWarning(String path, int line, int col, String warning)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logWarning(path, line, col, warning);
        }
        else
        {
            System.err.println(path + ": line " + line + ", col " + col + " - " + warning);
        }
    }

    public static void logError(String path, int line, int col, String error)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logError(path, line, col, error);
        }
        else
        {
            System.err.println(path + ": line " + line + ", col " + col + " - " + error);
        }
    }

    public static void logWarning(String path, int line, int col, String warning, String source)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logWarning(path, line, col, warning, source);
        }
        else
        {
            System.err.println(path + ": line " + line + ", col " + col + " - " + warning);
            System.err.println(source);
        }
    }

    public static void logWarning(String path, int line, int col, String warning, String source, int errorCode)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logWarning(path, line, col, warning, source, errorCode);
        }
        else
        {
            System.err.println(path + ": line " + line + ", col " + col + " - " + warning);
            System.err.println(source);
        }
    }

    public static void logError(String path, int line, int col, String error, String source)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logError(path, line, col, error, source);
        }
        else
        {
            System.err.println(path + ": line " + line + ", col " + col + " - " + error);
            System.err.println(source);
        }
    }

    public static void logError(String path, int line, int col, String error, String source, int errorCode)
    {
        Logger l = logger.get();
        if (l != null)
        {
            l.logError(path, line, col, error, source, errorCode);
        }
        else
        {
            System.err.println(path + ": line " + line + ", col " + col + " - " + error);
            System.err.println(source);
        }
    }

    /**
     * avoid passthrough ctors in CompilerMessages
     */
    public static void log(CompilerMessage m, String path, int line, int column)
    {
        m.path = path;
        m.line = line;
        m.column = column;
        log(m);
    }

    public static void log(CompilerMessage m, String path, int line, int column, String source)
    {
        m.path = path;
        m.line = line;
        m.column = column;
        log((ILocalizableMessage) m, source);
    }

    /**
     *
     */
    public static void log(CompilerMessage m, String path, int line)
    {
        log(m, path, line, -1);
    }

    public static void log(CompilerMessage m, String path)
    {
        log(m, path, -1, -1);
    }

    public static void log(CompilerMessage m, Source s, int line)
    {
        m.path = s.getNameForReporting();
        m.line = line;
        log(m);
    }

    public static void log(CompilerMessage m, Source s, int line, int column)
    {
        m.path = s.getNameForReporting();
        m.line = line;
        m.column = column;
        log(m);
    }

    public static void log(CompilerMessage m, Source s)
    {
        m.path = s.getNameForReporting();
        log(m);
    }

    public static void log( ILocalizableMessage m )
    {
        Logger logger = getLogger();

        if (logger != null)
        {
            logger.log( m );
        }
    }

    public static void log( ILocalizableMessage m, String source)
    {
        Logger logger = getLogger();

        if (logger != null)
        {
            logger.log( m, source );
        }
    }

}
