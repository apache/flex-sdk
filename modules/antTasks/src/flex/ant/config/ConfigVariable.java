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

package flex.ant.config;


/**
 * Provides a base class for Configuration Variables that can be set with a
 * String value.
 *
 * Consumers of this class must implement the <code>set</code>
 * <code>isSet</code> methods.
 */
public abstract class ConfigVariable extends BaseConfigVariable
{
    /**
     * Create a <code>ConfigVariable</code> instance with the specified <code>OptionSpec</code>.
     */
    protected ConfigVariable(OptionSpec spec)
    {
        super(spec);
    }

    /**
     * Set the value of this <code>ConfigVariable</code>
     *
     * @param value the value (as a String) that this <code>ConfigVariable</code> should be set to.
     */
    public abstract void set(String value);

    /**
     * Predicate specifying whether this ConfigVariable has been set. Implementation depends on the implementation of <code>set</code>.
     *
     * @return true if this <code>ConfigVariable</code> has been set, false otherwise.
     */
    public abstract boolean isSet();

} //End of ConfigVariable

