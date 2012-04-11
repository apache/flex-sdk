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

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * A utility class used to record how long certain tasks take to run.
 *
 * @author Clement Wong
 */
public class Benchmark
{
    public static final String PRECOMPILE = "precompile";
    public static final String POSTCOMPILE = "postcompile";

	private long start = 0;
	private long begin = 0;
    private long timeFilter = 0;

	public void start()
	{
		start = System.currentTimeMillis();
		begin = start;
	}

	public void benchmark(String message)
	{
		long currentTime = System.currentTimeMillis();
		if (start != 0)
		{
            ThreadLocalToolkit.log(new BenchmarkText(message, currentTime - start));                
		}
		start = currentTime;

		if (begin == 0)
		{
			begin = currentTime;
		}
	}

    public void benchmark2(String message)
    {
        benchmark2(message, false);
    }
    
    public void benchmark2(String message, boolean ignoreTimeFilter)
    {
        long currentTime = System.currentTimeMillis();
        if (start != 0)
        {
            long duration = currentTime - start;
            if (ignoreTimeFilter || duration >= timeFilter)
            {
                ThreadLocalToolkit.log(new BenchmarkTotalText(message, 
                        duration, 
                        currentTime - begin));                
            }
        }
        start = currentTime;

        if (begin == 0)
        {
            begin = currentTime;
        }
    }

    /**
     * Set the minimum time an event must take for it to be logged. Keeps small events from
     * being logged.
     * 
     * @param timeFilter time in milliseconds
     */
    public void setTimeFilter(long timeFilter)
    {
        this.timeFilter = timeFilter;
    }

    /**
     * Set the minimum time an event must take for it to be logged. Keeps small events from
     * being logged.
     * 
     * @return time in milliseconds
     */
    public long getTimeFilter()
    {
        return timeFilter;
    }
    
	public void totalTime()
	{
		ThreadLocalToolkit.log(new TotalTime(System.currentTimeMillis() - begin));
	}

    private Map<String, Long> startTimes;
    private Map<String, Long> durations;

    public boolean hasStarted(String id)
    {
        boolean result = false;

        if (startTimes != null)
        {
            result = startTimes.containsKey(id);
        }

        return result;
    }

    public long getTime(String id)
    {
        long result = -1;

        if (durations != null)
        {
            Long duration = durations.get(id);

            if (duration != null)
            {
                result = duration.longValue();
            }
        }

        return result;
    }

    public final long stopTime(String id)
    {
        return stopTime(id, true);
    }

    public final long stopTime(String id, boolean reset)
    {
        long currentTime = System.currentTimeMillis();
        Long startTimeObject = startTimes.remove(id);
        if (startTimeObject == null)
            throw new IllegalStateException("Call startTime before calling stopTime");
        long startTime = startTimeObject.longValue();
        long duration = currentTime - startTime;
        ThreadLocalToolkit.log(new BenchmarkID(id, duration));

        if (reset)
        {
            startTime(id);
        }

        if (durations == null)
        {
            durations = new HashMap<String, Long>();
        }

        durations.put(id, duration);

        return duration;
    }

    public final void startTime(String id)
    {
        if (startTimes == null)
        {
            startTimes = new HashMap<String, Long>();
        }

        startTimes.put(id, new Long(System.currentTimeMillis()));
    }

	/**
	 * @return peak memory usage in Mb
	 */
    public final long peakMemoryUsage()
    {
        return peakMemoryUsage(true);
    }

    public final long peakMemoryUsage(boolean display)
    {
	    MemoryUsage mem = getMemoryUsageInBytes();
	    long mbHeapUsed = (mem.heap / 1048576);
		long mbNonHeapUsed = (mem.nonHeap / 1048576);

	    if (display && mem.heap != 0 && mem.nonHeap != 0)
	    {
		    ThreadLocalToolkit.log(new MemoryUsage(mbHeapUsed, mbNonHeapUsed));
	    }

	    return mbHeapUsed + mbNonHeapUsed;
    }

	public final long peakMemoryUsageInBytes()
	{
	    return peakMemoryUsage(true);
	}

	public final long peakMemoryUsageInBytes(boolean display)
	{
		MemoryUsage mem = getMemoryUsageInBytes();

		if (display && mem.heap != 0 && mem.nonHeap != 0)
		{
			ThreadLocalToolkit.log(mem);
		}

		return mem.total;
	}

	/**
	 * @return peak memory usage in bytes
	 */
	public MemoryUsage getMemoryUsageInBytes()
	{
		long heapUsed = 0, nonHeapUsed = 0;

	    try
	    {
			ClassLoader contextClassLoader = Thread.currentThread().getContextClassLoader();
	        Class mfCls = Class.forName("java.lang.management.ManagementFactory", true, contextClassLoader);
	        Class mpCls = Class.forName("java.lang.management.MemoryPoolMXBean", true, contextClassLoader);
	        Class memCls = Class.forName("java.lang.management.MemoryUsage", true, contextClassLoader);
		    Class typeCls = Class.forName("java.lang.management.MemoryType", true, contextClassLoader);

	        Class[] emptyCls = new Class[] {};
	        Object[] emptyObj = new Object[] {};
	        Method getMemPoolMeth = mfCls.getMethod("getMemoryPoolMXBeans", emptyCls);
	        Method getPeakUsageMeth = mpCls.getMethod("getPeakUsage", emptyCls);
		    Method getTypeMeth = mpCls.getMethod("getType", emptyCls);
		    Field heapField = typeCls.getField("HEAP");
	        Method getUsedMeth = memCls.getMethod("getUsed", emptyCls);

	        List list = (List)getMemPoolMeth.invoke(null, emptyObj);
	        for (Iterator iterator = list.iterator(); iterator.hasNext();)
	        {
	            Object memPoolObj = iterator.next();
	            Object memUsageObj = getPeakUsageMeth.invoke(memPoolObj, emptyObj);
		        Object memTypeObj = getTypeMeth.invoke(memPoolObj, emptyObj);
		        Long used = (Long)getUsedMeth.invoke(memUsageObj, emptyObj);
		        if (heapField.get(typeCls) == memTypeObj)
		        {
		            heapUsed += used.longValue();
		        }
		        else
		        {
			        nonHeapUsed += used.longValue();
		        }
	        }

		    resetPeakMemoryUsage();
	    }
	    catch(Exception e)
	    {
	        // ignore, assume not using jdk 1.5
	    }

		return new MemoryUsage(heapUsed, nonHeapUsed);
	}

	private void resetPeakMemoryUsage()
	{
		try
		{
			ClassLoader contextClassLoader = Thread.currentThread().getContextClassLoader();
		    Class mfCls = Class.forName("java.lang.management.ManagementFactory", true, contextClassLoader);
		    Class mpCls = Class.forName("java.lang.management.MemoryPoolMXBean", true, contextClassLoader);

		    Class[] emptyCls = new Class[] {};
		    Object[] emptyObj = new Object[] {};
		    Method getMemPoolMeth = mfCls.getMethod("getMemoryPoolMXBeans", emptyCls);
			Method resetPeakUsageMeth = mpCls.getMethod("resetPeakUsage", emptyCls);

		    List list = (List)getMemPoolMeth.invoke(null, emptyObj);
		    for (Iterator iterator = list.iterator(); iterator.hasNext();)
		    {
		        Object memPoolObj = iterator.next();
			    resetPeakUsageMeth.invoke(memPoolObj, emptyObj);
		    }
		}
		catch(Exception e)
		{
		    // ignore, assume not using jdk 1.5
		}
	}

	public void captureMemorySnapshot()
	{		
	}
	
	// error messages

	public static class BenchmarkText extends CompilerMessage.CompilerInfo
	{
		private static final long serialVersionUID = -8135623655978440213L;
        public BenchmarkText(String message, long time)
		{
			super();
			this.message = message;
			this.time = time;
		}

		public final String message;
		public final long time;
	}

    public static class BenchmarkTotalText extends CompilerMessage.CompilerInfo
    {
        private static final long serialVersionUID = 4446977969005129123L;
        public BenchmarkTotalText(String message, long time, long total)
        {
            super();
            this.message = message;
            this.time = time;
            this.total = total;
        }

        public final String message;
        public final long time;
        public final long total;
    }

	public static class BenchmarkID extends CompilerMessage.CompilerInfo
	{
		private static final long serialVersionUID = -8665059678509053629L;
        public BenchmarkID(String id, long duration)
		{
			super();
			this.id = id;
			this.duration = duration;
		}

		public final String id;
		public final long duration;
	}

	public static class TotalTime extends CompilerMessage.CompilerInfo
	{
		private static final long serialVersionUID = -4183269812522994075L;

        public TotalTime(long time)
		{
			super();
			this.time = time;
		}

		public final long time;
	}

	public static class MemoryUsage extends CompilerMessage.CompilerInfo
	{
		private static final long serialVersionUID = -6475223071208094608L;

        public MemoryUsage(long heap, long nonHeap)
		{
			super();
			this.heap = heap;
			this.nonHeap = nonHeap;
			this.total = heap + nonHeap;
		}

		public long heap, nonHeap, total;

		public void add(MemoryUsage mem)
		{
			this.heap += mem.heap;
			this.nonHeap += mem.nonHeap;
			this.total += mem.total;
		}

		public void subtract(MemoryUsage mem)
		{
			this.heap -= mem.heap;
			this.nonHeap -= mem.nonHeap;
			this.total -= mem.total;
		}
	}
    
}
