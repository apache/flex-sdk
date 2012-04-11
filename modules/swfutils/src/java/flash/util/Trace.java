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

package flash.util;

import java.util.Date;

/**
 * Primitive run-time tracing class.
 * <p>
 * Code as follows:
 * <pre>
 * if (Trace.foo)
 *     Trace.trace("trace msg"...);
 * </pre>
 * Enable as follows:
 * <p>
 * java -Dtrace.foo -Dtrace.foo2 -Dtrace.foo3 or -Dtrace.all
 * <p>
 * Special flags:<p>
 * -Dtrace.flex                -- enables all tracing<p>
 * -Dtrace.foo                   -- enables tracing on foo subsystem<p>
 * -Dtrace.timeStamp             -- timeStamp all output lines<p>
 * -Dtrace.caller                -- print the Class:method caller<p>
 * -Dtrace.stackLines=10         -- print 10 stack lines<p>
 * -Dtrace.stackPrefix=java.lang -- print the stack up to java.lang<p>
 * <p>
 * Add new xxx members as desired.
 */
public class Trace
{
    public static final boolean all = (System.getProperty("trace.flex") != null);
    
    public static final boolean phase = all || (System.getProperty("trace.phase") != null);
    public static final boolean phaseabc = all || (System.getProperty("trace.phaseabc") != null); 
    //public static final boolean phasex = all || (System.getProperty("trace.phasex") != null);
    
    //public static final boolean asc = all || (System.getProperty("trace.asc") != null);
    public static final boolean accessible = all || (System.getProperty("trace.accessible") != null);
	public static final boolean asdoc = all || (System.getProperty("trace.asdoc") != null);		
    //public static final boolean benchmark = all || (System.getProperty("trace.benchmark") != null);
    public static final boolean cache = all || (System.getProperty("trace.cache") != null);
    //public static final boolean compileTime = all || (System.getProperty("trace.compileTime") != null);
    public static final boolean css = all || (System.getProperty("trace.css") != null);
    public static final boolean dependency = all || (System.getProperty("trace.dependency") != null);
    public static final boolean config = all || (System.getProperty("trace.config") != null);
    public static final boolean embed = all || (System.getProperty("trace.embed") != null);
    //public static final boolean embedx = all || (System.getProperty("trace.embedx") != null);
    public static final boolean error = all || (System.getProperty("trace.error") != null);
    public static final boolean font = all || (System.getProperty("trace.font") != null);
    public static final boolean font_cubic = all || (System.getProperty("trace.font.cubic") != null);
    //public static final boolean image = all || (System.getProperty("trace.image") != null);
    //public static final boolean lib = all || (System.getProperty("trace.lib") != null);
    public static final boolean license = all || (System.getProperty("trace.license") != null);
    //public static final boolean linker = all || (System.getProperty("trace.linker") != null);
    public static final boolean mxml = all || (System.getProperty("trace.mxml") != null);
    //public static final boolean parser = all || (System.getProperty("trace.parser") != null);
    public static final boolean profiler = all || (System.getProperty("trace.profiler") != null);
    //public static final boolean schema = all || (System.getProperty("trace.schema") != null);
    public static final boolean swc = all || (System.getProperty("trace.swc") != null);
    //public static final boolean swf = all || (System.getProperty("trace.swf") != null);
    public static final boolean pathResolver = all || (System.getProperty("trace.pathResolver") != null);
    public static final boolean binding = all || (System.getProperty("trace.binding") != null);

    // print just the stack caller
    public static final boolean caller = (System.getProperty("trace.caller") != null);
    // print stack up to the prefix
    public static final String stackPrefix = System.getProperty("trace.stackPrefix");

    // print this number of stack lines
    public static int stackLines = 0;
    static {
        try {
            stackLines = Integer.parseInt(System.getProperty("trace.stackLines"));
        } catch (NumberFormatException e) {
        }
    }
    // print a timestamp with each line
    public static final boolean timeStamp = (System.getProperty("trace.timeStamp") != null);
    // print a timestamp on each line in milliseconds
    public static final boolean timeStampMs = (System.getProperty("trace.timeStampMs") != null);
    // print a timestamp on each line in "relative" millisconds (first print will be zero)
    public static final boolean timeStampMsRel = (System.getProperty("trace.timeStampMsRel") != null);
    
    // print debug information related to the swc-checksum option
    public static final boolean swcChecksum = all || (System.getProperty("trace.swcChecksum") != null);
    
    private static long t0=0; // used with timeStampMsRel
    /**
     * Write the string as a line to the trace stream. If the
     * "stack" property is enabled, then the caller's stack call
     * is also shown in the date.
     */
    public static void trace(String str) {
        if (timeStamp)
            System.err.print(new Date());
        
        if (timeStampMs || timeStampMsRel)
        {
        	if (timeStampMsRel && (t0 == 0))
        		t0 = System.currentTimeMillis();
        
        	System.err.print((System.currentTimeMillis() - t0) + " ");
        }

        if(caller)
            System.err.print(ExceptionUtil.getCallAt(new Throwable(), 1) + " ");

        System.err.println(str);

        if (stackLines > 0)
            System.err.println(ExceptionUtil.getStackTraceLines(new Throwable(), stackLines));
        else if (stackPrefix != null)
            System.err.println(ExceptionUtil.getStackTraceUpTo(new Throwable(), stackPrefix));
    }
    /** Reset the relative clock to zero
     * Only has an effect when -Dtrace.timeStampMsRel is enabled
     */
    public static void resetRel() {
    	trace("Relative clock will reset to zero");
    	t0 = 0;
    	trace("Relative clock new reset");	// print two message, so we have before and after time
    }

}

