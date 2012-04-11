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
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.DynamicAttribute;
import org.apache.tools.ant.types.Commandline;

/**
 * Supports the nested URL based tags of RuntimeSharedLibraryPath.
 */
public class URLElement implements DynamicAttribute, OptionSource
{
    private static final String RSL_URL = "rsl-url";
    private static final String POLICY_FILE_URL = "policy-file-url";

    private String rslURL;
    private String policyFileURL;

    public void setDynamicAttribute(String name, String value)
    {
        if (name.equals(RSL_URL))
        {
            rslURL = value;
        }
        else if (name.equals(POLICY_FILE_URL))
        {
            policyFileURL = value;
        }
        else
        {
            throw new BuildException("The <url> type doesn't support the \"" +
                                     name + "\" attribute.");
        }
    }

    public void addToCommandline(Commandline commandLine)
    {
        if (rslURL != null)
        {
            commandLine.createArgument().setValue(rslURL);
        }

        if (policyFileURL != null)
        {
            commandLine.createArgument().setValue(policyFileURL);
        }
    }
}