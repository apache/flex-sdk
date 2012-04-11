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
 * Extends ConfigVariable to support setting boolean configuration
 * options.  Values of "true", "yes", and "on" are supported.
 */
public final class ConfigBoolean extends ConfigVariable
{
    private boolean enabled;
    private boolean isSet;

    public ConfigBoolean(OptionSpec spec)
    {
        super(spec);

        this.enabled = false;
        this.isSet = false;
    }

    public ConfigBoolean(OptionSpec spec, boolean enabled)
    {
        super(spec);
        this.set(enabled);
    }

    public void set(boolean value)
    {
        this.enabled = value;
        this.isSet = true;
    }

    public void set(String value)
    {
        this.enabled = parseValue(value);
        this.isSet = true;
    }

    public boolean isSet() { return isSet; }

    public void addToCommandline(Commandline cmdl)
    {
        if (isSet)
            cmdl.createArgument(true).setValue("-" + spec.getFullName() + "=" + enabled);
    }

    private boolean parseValue(String value)
    {
        return value.toLowerCase().matches("\\s*(true|yes|on)\\s*");
    }
    
} //End of ConfigBoolean
