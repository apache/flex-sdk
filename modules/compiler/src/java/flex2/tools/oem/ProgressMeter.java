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

/**
 * The <code>ProgressMeter</code> interface lets you get periodic updates from the compiler
 * about the compilation progress.
 * 
 * <p>
 * Providing a progress meter to the compiler is optional. If you want to
 * know about compilation progress, you must implement this interface and provide an
 * instance of the implementation to the <code>Application.setProgressMeter()</code> and/or
 * <code>Library.setProgressMeter()</code> methods.
 * 
 * @version 2.0.1
 * @author Clement Wong
 */
public interface ProgressMeter
{
    /**
     * Notifies the caller that the compilation has begun. 
     */
    void start();
    
    /**
     * Notifies the caller that the compilation has ended.
     */
    void end();
    
    /**
     * Notifies the caller of the percentage of compilation done by the compiler.
     * @param n An integer. Valid values are <code>0</code> through <code>100</code>.
     */
    void percentDone(int n);
}
