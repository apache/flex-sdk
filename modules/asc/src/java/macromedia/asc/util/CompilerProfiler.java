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

public interface CompilerProfiler
{
    /**
     *  Initialize the profiler.
     */
    public void initialize();

    /**
     *  Start allocation recording.
     *  @param sampling_delta - record every Nth allocation.
     *     Zero value records every allocation.
     *  @param threshold - record every allocation over the threshold.
     *     Zero value disables threshold-based recording.
     */
    public void startAllocationRecording(int sampling_delta, int threshold);

    /**
     *  Start CPU profiling.
     *  @param sample - use sample-based profiling.
     *    false value is interpreted by the implementation
     *    (often interpreted as exact profiling).
     */
    public void startCPUProfiling(boolean use_sampling_mode);
      
    /**
     *  Advance the memory allocation generation.
     */
    public void advanceGeneration(String description);

    /**
     *  Save a snapshot.
     *  @return a file path to the snapshot.
     */
    public String captureSnapshot();

    /**
     * Annotate a snapshot.
     * @param snapshot_file - file path to the snapshot.
     * @param annotation - the desired annoation.
     * @see captureSnapshot(), which returns the relevant file path.
     * @return true if the annotation succeeded.
     */
    public boolean annotateSnapshot(String snapshot_file, String annoation);
}
