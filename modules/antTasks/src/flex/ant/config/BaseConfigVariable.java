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

import org.apache.tools.ant.types.Commandline;

/**
 * Provides a base class for <code>ConfigVariable</code> and
 * <code>RepeatableConfigVariable</code>. This abstract class encapsulates all
 * of the functionality that any ConfigVariable must have that does not
 * involve "setting" it.
 *
 * Consumers of this class must implement the <code>addToCommandline</code>
 * method.
 */
public abstract class BaseConfigVariable implements OptionSource
{
    /**
     * The <code>OptionSpec</code> describing the names that this <code>ConfigVariable</code> should match.
     */
    protected final OptionSpec spec;

    /**
     * Create a Configuration Variable with the specified <code>OptionSpec</code>.
     */
    protected BaseConfigVariable(OptionSpec spec)
    {
        this.spec = spec;
    }

    /**
     * Adds arguments to the end of <code>cmdl</code> corresponding to the state of this variable.
     *
     * @param cmld The Commandline object to which arguments correspond to this option should be added
     */
    public abstract void addToCommandline(Commandline cmdl);

    /**
     * @return the OptionSpec associated with this instance.
     */
    public OptionSpec getSpec()
    {
        return spec;
    }

    /**
     * Returns the result of calling matches() on <code>spec</code> with <code>option</code> as the argument.
     *
     * @return true of <code>option</code> matches <code>spec</code>, and false otherwise.
     */
    public boolean matches(String option)
    {
        return spec.matches(option);
    }
}
