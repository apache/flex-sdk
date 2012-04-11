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

package flex2.compiler.swc;

/**
 * This represents a component within a SWC.
 *
 * @author Brian Deitte
 */
public class SwcComponent implements flex2.tools.oem.Component
{
    private String className;
    private String name;
    private String uri;
    protected String icon;   // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    private String docs;
    protected String preview;   // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    private String location;

    public SwcComponent()
    {
    }
    
    public SwcComponent(String className, String name, String uri)
    {
        this.className = className;
        this.name = name;
        this.uri = uri;
    }

    public String getClassName()
    {
        return className;
    }

    public void setClassName(String className)
    {
        this.className = className;
    }

    public String getName()
    {
        return name;
    }

    public void setName(String name)
    {
        this.name = name;
    }

    public String getUri()
    {
        return uri;
    }

    public void setUri(String uri)
    {
        this.uri = uri;
    }

    public String getIcon()
    {
        return icon;
    }

    public void setIcon(String icon)
    {
        this.icon = icon;
    }

    public String getDocs()
    {
        return docs;
    }

    public void setDocs(String docs)
    {
        this.docs = docs;
    }

    public String getPreview()
    {
        return preview;
    }

    public void setPreview(String preview)
    {
        this.preview = preview;
    }
    
    // C: note: 'location' is not an attribute of the <component> tag in catalog.xml.
    public void setLocation(String loc)
    {
    	this.location = loc;
    }

    // flex2.tools.oem.reflect.Component specific...
    // Do not use this method in the mxmlc/compc codepath.
	public String getLocation()
	{
		return location;
	}
}

