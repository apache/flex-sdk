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

package flex2.compiler.css;

/**
 * This value object represents a ClassReference() or
 * PropertyReference() CSS function.  It is used as a
 * flash.css.StyleProperty value.
 *
 * @author Paul Reilly
 */
public class Reference
{
    private String value;
    private boolean isClassReference;
    private String path;
    private int lineNumber;

    public Reference(String value, boolean isClassReference, String path, int lineNumber)
    {
        this.value = value;
        this.isClassReference = isClassReference;
        this.path = path;
        this.lineNumber = lineNumber;
    }

    public int getLineNumber()
    {
        return lineNumber;
    }

    public String getPath()
    {
        return path;
    }

    public String getValue()
    {
        return value;
    }

    public boolean isClassReference()
    {
        return isClassReference;
    }

    /**
     * Used by Velocity templates, so that we don't have to test for
     * instances of Reference and if so, call getValue().
     */
    public String toString()
    {
        return value;
    }
}
