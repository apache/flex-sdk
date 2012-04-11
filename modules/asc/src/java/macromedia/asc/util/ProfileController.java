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

package macromedia.asc.util;

public class ProfileController
{

    /** 
     *  The profiler implemention.
     */
    static CompilerProfiler m_profiler = null;

    /**
     *  The profiler may be null because it wasn't 
     *  specified, or because initialization failed.
     */
    static boolean initialization_failed = false;

    /**
     *  Initialize the profiler.
     *  @param profiler_class - the name of the profiler class.
     */
    public static void setProfiler(String profiler_class)
    {	
        if ( null == m_profiler )
        {
            try
            {
                m_profiler = (CompilerProfiler)Class.forName(profiler_class).newInstance();
                m_profiler.initialize();
            }
            catch ( Throwable profiler_exception )
            {
                initialization_failed = true;
                
                // TODO: better logging!
                System.err.println("Unable to instantiate profiler " + profiler_class + " due to:");
                profiler_exception.printStackTrace();   		
            }
        }
    }

    /**
     *  Begin CPU profiling.
     *  @param use_sampling_mode - when set, use sampling instead of tracing (recommended)
     */
    public static void startCPUProfiling(boolean use_sampling_mode)
    {
        if ( m_profiler != null )
        {
            m_profiler.startCPUProfiling(use_sampling_mode);
        }
    }

    /**
     *  Begin recording allocations.
     */
    public static void startAllocationRecording()
    {
        if ( m_profiler != null )
        {
            m_profiler.startAllocationRecording(10, 4*1024);
        }
    }

    /**
     *  Tell the profiler we're performing a specific processing phase.
     *  @param description - description of the new phase.
     */
    public static void newPhase(String description)
    {
        if ( m_profiler != null )
        {
            m_profiler.advanceGeneration(description);
        }
    }

    /**
     * Take a snapshot of the profiler's results.
     * @return the name of the profile dump file.
     */
    public static String captureSnapshot()
    {
        String result = new String();
        if ( m_profiler != null )
        {
            result = m_profiler.captureSnapshot();
        }
        
        return result;
    }

    /**
     * Annotate a snapshot (optional operation)
     * @param snapshot_file - the snapshot file.
     * @param annotation - the annotation.
     * @return true if the operation succeeded.
     */
    public static boolean annotateSnapshot(String snapshot_file, String annotation)
    {
        boolean result = false;
        if ( m_profiler != null && snapshot_file != null )
        {
            result = m_profiler.annotateSnapshot(snapshot_file, annotation);
        }
        
        return result;
    }

    public static boolean isInitialized()
    {
        return m_profiler != null;
    }

}
