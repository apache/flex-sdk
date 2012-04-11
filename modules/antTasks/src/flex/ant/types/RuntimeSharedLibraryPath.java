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

import flex.ant.config.ConfigString;
import flex.ant.config.ConfigVariable;
import flex.ant.config.NestedAttributeElement;
import flex.ant.config.OptionSource;
import flex.ant.config.OptionSpec;
import java.util.ArrayList;
import java.util.Iterator;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.DynamicConfigurator;
import org.apache.tools.ant.types.Commandline;

/**
 * Supports the nested &lt;runtime-shared-library-path&gt; tag.
 */
public final class RuntimeSharedLibraryPath implements OptionSource, DynamicConfigurator
{
    private static final String RUNTIME_SHARED_LIBRARY_PATH = "-runtime-shared-library-path";
    private static final String PATH_ELEMENT = "path-element";

    private static OptionSpec urlSpec = new OptionSpec("url");

    private String pathElement;
    private ArrayList urlElements = new ArrayList();

    public RuntimeSharedLibraryPath()
    {
    }

    public void addToCommandline(Commandline commandLine)
    {
        commandLine.createArgument().setValue(RUNTIME_SHARED_LIBRARY_PATH);
        commandLine.createArgument().setValue(pathElement);

        Iterator it = urlElements.iterator();

        while (it.hasNext())
        {
            ((OptionSource) it.next()).addToCommandline(commandLine);
        }
    }

    public Object createDynamicElement(String name)
    {
        URLElement result;

        if (urlSpec.matches(name))
        {
            result = new URLElement();
            urlElements.add(result);
        }
        else
        {
            throw new BuildException("Invalid element: " + name);
        }

        return result;
    }

    public void setDynamicAttribute(String name, String value)
    {
        if (name.equals(PATH_ELEMENT))
        {
            pathElement = value;
        }
        else
        {
            throw new BuildException("The <rutime-shared-library-path> type doesn't support the \"" +
                                     name + "\" attribute.");
        }
    }
}
