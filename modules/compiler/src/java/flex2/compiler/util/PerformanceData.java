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

/**
 * Data to describe the performance of a class method.
 * 
 * Contains the number of times the method was called and the total
 * amount of time in the method.
 * 
 * @author dloverin
 */
public class PerformanceData
{
    /**
     * Number of time a method was invoked.
     */
    public long invocationCount;

    /**
     * Total amount of time (ms) in a method.
     */
    public long totalTime;
    
    
    public PerformanceData()
    {
        
    }
}
