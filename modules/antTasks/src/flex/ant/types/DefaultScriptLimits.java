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

package flex.ant.types;

import flex.ant.config.OptionSource;
import flex.ant.config.OptionSpec;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.DynamicAttribute;
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.FlexInteger;

/**
 * Implements &lt;default-script-limits&gt;.
 */
public class DefaultScriptLimits implements DynamicAttribute, OptionSource
{
    public static OptionSpec spec = new OptionSpec("default-script-limits");

    private int rec = -1;
    private int exe = -1;

    public void setDynamicAttribute(String name, String value)
    {
        int intVal = new FlexInteger(value).intValue();

        if (name.equals("max-recursion-depth"))
            rec = intVal;
        else if (name.equals("max-execution-time"))
            exe = intVal;
        else
            throw new BuildException("The <default-script-limits> type doesn't support the \""
                    + name + "\" attribute.");

        if (intVal < 0)
            throw new BuildException(name + "attribute must be a positive integer!");
    }

    public void addToCommandline(Commandline cmdl)
    {
        if (rec == -1)
            throw new BuildException("max-recursion-depth attribute must be set!");
        else if (exe == -1)
            throw new BuildException("max-execution-time attribute must be set!");
        else {
            cmdl.createArgument().setValue("-" + spec.getFullName());
            cmdl.createArgument().setValue(String.valueOf(rec));
            cmdl.createArgument().setValue(String.valueOf(exe));
        }
    }

} //End of DefaultScriptLimits
