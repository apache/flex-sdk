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

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.FlexInteger;

/**
 * Extends ConfigVariable to add support for parsing values into
 * integers and reporting build exceptions when the value isn't an
 * integer.
 */
public class ConfigInt extends ConfigVariable
{
    private int value;
    private boolean isSet;

    public ConfigInt(OptionSpec option)
    {
        super(option);
        this.isSet = false;
    }

    public ConfigInt(OptionSpec option, int value)
    {
        super(option);
        set(value);
    }

    public void set(int value)
    {
        this.value = value;
        this.isSet = true;
    }

    public void set(String value)
    {
        int intVal;

        try {
            intVal = new FlexInteger(value).intValue();
        } catch (NumberFormatException e) {
            throw new BuildException("Not an integer: " + value);
        }

        this.value = intVal;
        this.isSet = true;
    }

    public boolean isSet() { return isSet; }

    public void addToCommandline(Commandline cmdl)
    {
        if (this.isSet) {
            cmdl.createArgument().setValue("-" + spec.getFullName());
            cmdl.createArgument().setValue(String.valueOf(this.value));
        }
    }

} //End of ConfigInt
