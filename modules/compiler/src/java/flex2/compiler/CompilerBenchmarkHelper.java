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

import flex2.compiler.util.PerformanceData;
import flash.util.Trace;

/**
 * Helper class to keep track of the compilation times for each sub-compilation
 * phase, such as parse1, parse2, etc. While source compilation phases may
 * happen at different times, an individual phase for a given source is expected
 * to be completed before moving onto another phase.
 */
public class CompilerBenchmarkHelper
{
    /**
     * Index into 2nd dimension of array. Part of compile phase.
     */
    public static final int PREPROCESS = 0;
    public static final int PARSE1 = 1;
    public static final int PARSE2 = 2;
    public static final int ANALYZE1 = 3;
    public static final int ANALYZE2 = 4;
    public static final int ANALYZE3 = 5;
    public static final int ANALYZE4 = 6;
    public static final int GENERATE = 7;
    public static final int POSTPROCESS = 8;

    /**
     * Compile times in milliseconds. Indexed by compile phase constants.
     */
    private PerformanceData[] compileTimes;
    private long startTime;
    private String compilerName;

    /**
     * Constructor.
     * 
     * @param compilerName The name of the compiler of which this helper is
     *        associated.
     */
    public CompilerBenchmarkHelper(String compilerName)
    {
        this.compilerName = compilerName;
    }

    /**
     * Initializes a new array of PerformanceData benchmarks for the phases
     * of compilation.
     */
    public void initBenchmarks()
    {
        if (compileTimes == null)
        {
            compileTimes = new PerformanceData[POSTPROCESS + 1];
        }

        for (int j = 0; j <= POSTPROCESS; j++)
        {
            if (compileTimes[j] == null)
            {
                compileTimes[j] = new PerformanceData();
            }
            else
            {
                compileTimes[j].invocationCount = 0;
                compileTimes[j].totalTime = 0;
            }
        }
    }

    /**
     * Returns an array of PerformanceData benchmarks for each compilation
     * phase. The position of a phase in the array is fixed. See the public
     * static constants above for a phase's index.
     *  
     * @return PerformanceData[] array of compilation phase benchmarks.
     */
    public PerformanceData[] getBenchmarks()
    {
        return compileTimes;
    }

    /**
     * Call at the start of a compile phase to reset the start time. While
     * sources compilation phases may happen at different times, an individual
     * phase for a given source is expected to be completed before moving onto
     * another phase (for either the same or more likely another source).
     * 
     * @param phase is the compiler phase beginning (PREPROCESS, etc..)
     * @param source is the name of the "file" being compiled
     */
    public void startPhase(int phase, String source)
    {
        if (Trace.phase)
        {
            // phase trace will print a trace message when we enter each phase.
            // Note the abc compiler requires a special flag, as it can be too
            // verbose
            String name = (compilerName == null) ? "unknown" : compilerName;
            boolean isabc = name.equals("abc");
            if (isabc == false || Trace.phaseabc)
            {
                // trace the compiler name and file name
                Trace.trace("Start compiler " + name + " phase[" + getPhaseName(phase) + "] with: " + source);
            }
        }
        startTime = System.currentTimeMillis();
    }

    /**
     * Call at the end of a compile phase to record the times.
     * 
     * @param phase
     */
    public void endPhase(int phase)
    {
        if (compileTimes != null && phase >= PREPROCESS && phase <= POSTPROCESS)
        {
            compileTimes[phase].invocationCount++;
            compileTimes[phase].totalTime += System.currentTimeMillis() - startTime;
        }
    }

    /**
     * Dumps the total time spent in each phase for the associated compiler, as
     * well as the total time (all in milliseconds).
     * 
     * @param logger Logger
     */
    public void logBenchmarks(Logger logger)
    {
        logger.logInfo("Compiler: " + compilerName);
        long totalTime = 0;
        for (int i = 0; i < compileTimes.length; i++)
        {
            // Log each phase time for this compiler as "phaseName: 0"
            logger.logInfo(getPhaseName(i) + ": " + compileTimes[i].totalTime);
            totalTime += compileTimes[i].totalTime;
        }
        logger.logInfo("Total: " + totalTime);
    }

    /**
     * Calculate difference in total time between to helpers. Copies the
     * invocationCount over without subtracting
     * 
     * @param benchmark times to subtract from this.comipleTimes
     * @return (this) - (other)
     */
    public PerformanceData[] subtract(final CompilerBenchmarkHelper other)
    {
        PerformanceData[] ret = new PerformanceData[POSTPROCESS + 1];
        try
        {
            for (int i = PREPROCESS; i <= POSTPROCESS; ++i)
            {
                ret[i] = new PerformanceData();
                ret[i].invocationCount = this.compileTimes[i].invocationCount;
                ret[i].totalTime = this.compileTimes[i].totalTime - other.compileTimes[i].totalTime;
            }
        }
        catch (Exception e)
        {
            System.err.println("error " + e.getMessage());
        }
        return ret;
    }

    /**
     * Returns the name of the phase as a String for a given int.
     * 
     * @param phase the phase as an int
     * @return String the phase name
     */
    private static String getPhaseName(int phase)
    {
        String result = null;

        switch (phase)
        {
            case PREPROCESS:
                result = "preprocess";
                break;
            case PARSE1:
                result = "parse1";
                break;
            case PARSE2:
                result = "parse2";
                break;
            case ANALYZE1:
                result = "analyze1";
                break;
            case ANALYZE2:
                result = "analyze2";
                break;
            case ANALYZE3:
                result = "analyze3";
                break;
            case ANALYZE4:
                result = "analyze4";
                break;
            case GENERATE:
                result = "generate";
                break;
            case POSTPROCESS:
                result = "postprocess";
                break;
            default:
                result = null;
                break;
        }

        return result;
    }
}

