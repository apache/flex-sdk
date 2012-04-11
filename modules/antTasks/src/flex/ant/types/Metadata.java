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
import flex.ant.config.ConfigString;
import flex.ant.config.NestedAttributeElement;
import flex.ant.config.OptionSpec;
import flex.ant.config.OptionSource;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.DynamicElement;
import org.apache.tools.ant.types.Commandline;

import java.util.ArrayList;
import java.util.Iterator;

/**
 * Supports the nested &lt;metadata&gt; tag.
 */
public final class Metadata implements OptionSource, DynamicElement
{
    private static OptionSpec ldSpec = new OptionSpec("metadata", "localized-description");
    private static OptionSpec ltSpec = new OptionSpec("metadata", "localized-title");

    private static OptionSpec coSpec = new OptionSpec("metadata", "contributor");
    private static OptionSpec crSpec = new OptionSpec("metadata", "creator");
    private static OptionSpec laSpec = new OptionSpec("metadata", "language");
    private static OptionSpec puSpec = new OptionSpec("metadata", "publisher");

    private final ConfigString date;
    private final ConfigString description;
    private final ConfigString title;

    private final ArrayList<NestedAttributeElement> nestedAttribs;
    private final FlexTask task;
    
    public Metadata ()
    {
        this(null);
    }

    public Metadata (FlexTask task)
    {
        date = new ConfigString(new OptionSpec("metadata", "date"));
        description = new ConfigString(new OptionSpec("metadata", "description"));
        title = new ConfigString(new OptionSpec("metadata", "title"));

        nestedAttribs = new ArrayList<NestedAttributeElement>();
        this.task = task;
    }

    /*=======================================================================*
     *  Attributes                                                           *
     *=======================================================================*/

    public void setDate(String value)
    {
        date.set(value);
    }

    public void setDescription(String value)
    {
        description.set(value);
    }

    public void setTitle(String value)
    {
        title.set(value);
    }

    /*=======================================================================*
     *  Nested Elements
     *=======================================================================*/

    public NestedAttributeElement createContributor()
    {
        return createElem("name", coSpec);
    }

    public NestedAttributeElement createCreator()
    {
        return createElem("name", crSpec);
    }

    public NestedAttributeElement createLanguage()
    {
        return createElem("code", laSpec);
    }

    public NestedAttributeElement createPublisher()
    {
        return createElem("name", puSpec);
    }

    public Object createDynamicElement(String name)
    {
        /*
         * Name is checked against getAlias() because both of these options
         * have prefixes. We don't want to allow something like:
         *
         * <metadata>
         *   <metadata.localized-title title="foo" lang="en" />
         * </metadata>
         */
        if (ldSpec.matches(name)) {
            return createElem(new String[] { "text", "lang" }, ldSpec);
        }
        else if (ltSpec.matches(name)) {
            return createElem(new String[] { "title", "lang" }, ltSpec);
        }
        else {
            throw new BuildException("Invalid element: " + name);
        }
    }

    private NestedAttributeElement createElem(String attrib, OptionSpec spec)
    {
        NestedAttributeElement e = new NestedAttributeElement(attrib, spec, task);
        nestedAttribs.add(e);
        return e;
    }

    private NestedAttributeElement createElem(String[] attribs, OptionSpec spec)
    {
        NestedAttributeElement e = new NestedAttributeElement(attribs, spec, task);
        nestedAttribs.add(e);
        return e;
    }

    /*=======================================================================*
     *  OptionSource interface                                               *
     *=======================================================================*/

    public void addToCommandline(Commandline cmdl)
    {
        date.addToCommandline(cmdl);
        description.addToCommandline(cmdl);
        title.addToCommandline(cmdl);

        Iterator<NestedAttributeElement> it = nestedAttribs.iterator();

        while (it.hasNext())
            ((OptionSource) it.next()).addToCommandline(cmdl);
    }

} //End of Metadata
