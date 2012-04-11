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

import flex.ant.FlexTask;
import flex.ant.config.ConfigBoolean;
import flex.ant.config.ConfigString;
import flex.ant.config.ConfigVariable;
import flex.ant.config.NestedAttributeElement;
import flex.ant.config.OptionSpec;
import flex.ant.config.OptionSource;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.DynamicConfigurator;
import org.apache.tools.ant.types.Commandline;

import java.util.ArrayList;
import java.util.Iterator;

/**
 * Supports the nested &lt;fonts&gt; tag.
 */
public final class Fonts implements OptionSource, DynamicConfigurator
{
    /*
     * Use this defintion of lrSpec if you want to allow users to set the
     * compiler.fonts.languages.language-range by using a nested element named
     * languages.language-range:
     *
     * private static OptionSpec lrSpec = new OptionSpec("compiler.fonts.languages.language-range", "languages.language-range");
     *
     * Note that using this will no longer allow users to set the option by
     * using a language-range nested element.
     */
    private static OptionSpec lrSpec = new OptionSpec("compiler.fonts.languages", "language-range");
    private static OptionSpec maSpec = new OptionSpec("compiler.fonts", "managers");

    private final ConfigVariable[] attribs;

    private final ArrayList<NestedAttributeElement> nestedAttribs;
    private final FlexTask task;
    
    public Fonts()
    {
        this(null);
    }

    public Fonts(FlexTask task)
    {
        attribs = new ConfigVariable[] {
            new ConfigBoolean(new OptionSpec("compiler.fonts", "flash-type")),
            new ConfigBoolean(new OptionSpec("compiler.fonts", "advanced-anti-aliasing")),
            new ConfigString(new OptionSpec("compiler.fonts", "local-fonts-snapshot")),
            new ConfigString(new OptionSpec("compiler.fonts", "max-cached-fonts")),
            new ConfigString(new OptionSpec("compiler.fonts", "max-glyphs-per-face"))
        };

        nestedAttribs = new ArrayList<NestedAttributeElement>();
        this.task = task;
    }

    /*=======================================================================*
     *  Attributes                                                           *
     *=======================================================================*/

    public void setDynamicAttribute(String name, String value)
    {
        ConfigVariable var = null;

        for (int i = 0; i < attribs.length && var == null; i++) {
            if (attribs[i].matches(name))
                var = attribs[i];
        }

        if (var != null)
            var.set(value);
        else
            throw new BuildException("The <font> type doesn't support the \""
                                     + name + "\" attribute.");
    }

    /*=======================================================================*
     *  Nested Elements                                                      *
     *=======================================================================*/

    public Object createDynamicElement(String name)
    {
        if (lrSpec.matches(name)) {
            NestedAttributeElement e = new NestedAttributeElement(new String[] { "lang", "range" }, lrSpec, task);
            nestedAttribs.add(e);
            return e;
        }
        else {
            throw new BuildException("Invalid element: " + name);
        }
    }

    public NestedAttributeElement createManager()
    {
        NestedAttributeElement e = new NestedAttributeElement("class", maSpec, task);
        nestedAttribs.add(e);
        return e;
    }

    /*=======================================================================*
     *  OptionSource interface                                               *
     *=======================================================================*/

    public void addToCommandline(Commandline cmdl)
    {
        for (int i = 0; i < attribs.length; i++)
            attribs[i].addToCommandline(cmdl);

        Iterator<NestedAttributeElement> it = nestedAttribs.iterator();

        while (it.hasNext())
            ((OptionSource) it.next()).addToCommandline(cmdl);
    }

} //End of Fonts
