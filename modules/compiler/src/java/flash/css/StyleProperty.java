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

package flash.css;

/**
 * A simpler version of <code>Descriptor</code>, which doesn't
 * have any W3C SAC dependencies.
 */
public class StyleProperty
{
    private String name;
    private Object value;
    private String path;
    private int lineNumber;

    public StyleProperty(String name, Object value, String path, int lineNumber)
    {
        this.name = name;
        this.value = value;
        assert path != null;
        this.path = path;
        this.lineNumber = lineNumber;
    }

    public String getPath()
    {
        return path;
    }

    public int getLineNumber()
    {
        return lineNumber;
    }

    public String getName()
    {
        return name;
    }

    /**
     * Can be a String, a flex2.compiler.mxml.rep.AtEmbed, or a
     * flex2.compiler.css.Reference.
     */
    public Object getValue()
    {
        return value;
    }

    public String toString()
    {
        return name + ":" + value + ";";
    }
}
