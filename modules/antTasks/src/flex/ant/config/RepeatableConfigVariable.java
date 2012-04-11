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
 * Provides a base class for Configuration Variables that can take on multiple values.
 *
 * Consumers of this class must implement the <code>add</code> method.
 */
public abstract class RepeatableConfigVariable extends BaseConfigVariable
{
    /**
     * Creates a <code>RepeatableConfigVariable</code> instance with the specified <code>OpitonSpec</code>.
     */
    protected RepeatableConfigVariable(OptionSpec spec)
    {
        super(spec);
    }

    /**
     * Adds <code>value</code> as a value to this <code>RepeatableConfigVariable</code>.
     *
     * @param value the value to this <code>RepeatableConfigVariable</code>
     */
    public abstract void add(String value);

    /**
     * Adds every String in <code>values</code> as a value of this <code>RepeatableConfigVariable</code> by calling the <code>add</code> method with each String as an argument.
     * @param values an array of Strings
     */
    public void addAll(String[] values)
    {
        for (int i = 0; i < values.length; i++)
            this.add(values[i]);
    }

} //End of RepeatableConfigVariable
