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
import org.apache.tools.ant.DynamicAttribute;
import org.apache.tools.ant.types.Commandline;

import flex.ant.FlexTask;

/**
 * This class supports setting configuration option parameters via
 * child tag attributes.  For example:
 * </code>
 *     &lt;namespace uri="http://www.adobe.com/2006/mxml" manifest="${basedir}/manifest.xml"/&gt;
 * </code>
 */
public class NestedAttributeElement implements DynamicAttribute, OptionSource
{
    private final static String COMMA = ",";
    
    private String[] attribs;
    private String[] values;
    protected OptionSpec spec;
    private boolean valueHasComma;
    private FlexTask task;
    private boolean isAppend;
    
    // Although "append" is a special-case attribute, we still need to throw error if "append" is not
    // expected on the element.
    private final boolean allowAppendAttribute ;
    
    public NestedAttributeElement(String attrib, OptionSpec spec)
    {
        this(new String[] { attrib }, spec, null);
    }

    public NestedAttributeElement(String[] attribs, OptionSpec spec)
    {
        this(attribs, spec, null);
    }

    public NestedAttributeElement(String attrib, OptionSpec spec, FlexTask task)
    {
        this(new String[] { attrib }, spec, task);
    }

    public NestedAttributeElement(String[] attribs, OptionSpec spec, FlexTask task)
    {
        this(attribs, spec, task, false);
    }
    
    public NestedAttributeElement(String[] attribs, OptionSpec spec, FlexTask task, boolean allowAppend)
    {
        /*
         * Note: Do not try and be clever and sort attribs in order to increase
         * lookup time using binary search. The order of the attributes is
         * meaningful!
         */
        this.attribs = attribs;
        this.values = new String[attribs.length];
        this.spec = spec;
        this.task = task;
        this.allowAppendAttribute = allowAppend;
        this.isAppend = false;
    }
    
    public void addText(String value)
    {
        // if we have a task then replace any ant properties in the value.
        if (task != null)
            value = task.getProject().replaceProperties(value);

        values[0] = value;

        if (value.indexOf(COMMA) != -1)
        {
            valueHasComma = true;
        }
    }

    /**
     * Assign attribute value. If {@code name} is in the expected attribute list, the {@code value} will
     * be recorded. Otherwise, throw exception about unknown attribute.
     * <p>
     * "append" attribute is a special case. If <code>append="true"</code>, the command-line argument will
     * use <code>+=</code> instead of <code>=</code>.
     * @param name attribute name
     * @param value attribute value
     */
    public void setDynamicAttribute(String name, String value)
    {
    	if (allowAppendAttribute && name.equals("append")) {
        	isAppend = Boolean.parseBoolean(value);
        	return;
        }
    	
        boolean isSet = false;

        for (int i = 0; i < attribs.length && !isSet; i++) {
            if (attribs[i].equals(name)) {
                values[i] = value;
                isSet = true;
            } 
        }

        if (value.indexOf(COMMA) != -1)
        {
            valueHasComma = true;
        }

        if (!isSet)
            throw new BuildException("The <" + spec.getFullName()
                                     + "> type doesn't support the \""
                                     + name + "\" attribute.");
    }

    public void addToCommandline(Commandline cmdl)
    {
        if (valueHasComma)
        {
            cmdl.createArgument().setValue("-" + spec.getFullName());

            for (int i = 0; i < attribs.length; i++)
            {
                if (values[i] != null)
                {
                    cmdl.createArgument().setValue(values[i].replaceAll("\\s*,\\s*", COMMA));
                }
            }
        }
        else
        {
            StringBuilder stringBuffer = new StringBuilder();

            for (int i = 0; i < attribs.length; i++)
            {
                if (values[i] != null)
                {
                    stringBuffer.append(values[i]);

                    if ((i + 1) < attribs.length)
                    {
                        stringBuffer.append(COMMA);
                    }
                }
            }
            
            final String cmdLineArgument = String.format(
            		"-%s%s=%s", 
            		spec.getFullName(),
            		isAppend ? "+" : "",
    				stringBuffer);
			cmdl.createArgument().setValue(cmdLineArgument);
        }
    }
} 
