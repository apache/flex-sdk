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
 * Extends ConfigString by overriding addToCommandline to use +foo=bar
 * syntax to support appending the configuration option to any
 * existing values.
 */
public class ConfigAppendString extends ConfigString
{
    public ConfigAppendString(OptionSpec option)
    {
        super(option);
    }

    public ConfigAppendString(OptionSpec option, String value)
    {
        super(option, value);
    }

    public void addToCommandline(Commandline cmdl)
    {
        String value = value();

        if ((value != null) && (value.length() > 0))
        {
            cmdl.createArgument().setValue("+" + spec.getFullName() + "=" + value);
        }
    }
}
