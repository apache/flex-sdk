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

/**
 * Base class to be used for sub-compilers.
 */
public abstract class AbstractSubCompiler implements SubCompiler
{
    protected CompilerBenchmarkHelper benchmarkHelper;
    protected CompilerBenchmarkHelper benchmarkEmbeddedHelper;	// used by compilers that have embedded compilers

    /**
     * @return accumulated performance data since initBenchmarks() was called.
     * @see initBenchmarks
     */
    public PerformanceData[] getBenchmarks()
    {
    	PerformanceData[] ret = null;
    	if (benchmarkHelper==null)
    	{
    		ret = new PerformanceData[0];
    	}
    	else if (benchmarkEmbeddedHelper != null)
    	{
    		// subtract out the part contributed by the embedded compilers, as we will 
    		// report that separately
    		ret = benchmarkHelper.subtract(benchmarkEmbeddedHelper);
    	}
    	else
        {
            ret = benchmarkHelper.getBenchmarks();
        }
        return ret;
    }
    
  /**
   * @return accumulated performance data for embedded compiler, if any
   * @see getBenchmarks
   */
    public PerformanceData[] getEmbeddedBenchmarks()
    {
    	PerformanceData[] ret = null;
    	if (benchmarkEmbeddedHelper != null)
    	{
    		ret = benchmarkEmbeddedHelper.getBenchmarks();
    	}
    	return ret;
    }

    /**
     * Reset benchmark performance data.
     */
    public void initBenchmarks()
    {
        benchmarkHelper = new CompilerBenchmarkHelper(getName());
        benchmarkHelper.initBenchmarks();
        benchmarkEmbeddedHelper=null;		// normally not used. compilers with embedded compilers must 
        								// override initBenchmarks()
    }
    
    /**
     * receive a compiler helper from outside.
     * This is typically used when an "outer" compiler wants to benchmark an embedded compiler
     * @param helper is the helper passed into us
     * @param isEmb is true if the helper being set is the embedded one, false if the main one
     */
    public void setHelper(CompilerBenchmarkHelper helper, boolean isEmbedded)
    {
    	if (isEmbedded)
    		benchmarkEmbeddedHelper = helper;
    	else
    		benchmarkHelper = helper;	
    }

    /**
     * Report benchmark information to the given Logger.
     * @param logger The Logger to receive benchmarking information.
     */
    public void logBenchmarks(Logger logger)
    {
        if (benchmarkHelper != null)
            benchmarkHelper.logBenchmarks(logger);
        if (benchmarkEmbeddedHelper != null)
        {
        	benchmarkEmbeddedHelper.logBenchmarks(logger);
        }
    }
}
