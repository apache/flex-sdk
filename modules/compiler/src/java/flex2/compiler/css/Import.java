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
 * Value object used to represent a CSS value and the line number
 * where it came from.
 *
 * @author Paul Reilly
 */
public class Import
{
    private String value;
    private int lineNumber;

    public Import(String value, int lineNumber)
    {
        this.value = value;
        this.lineNumber = lineNumber;
    }

    public boolean equals(Object object)
    {
        boolean result = false;

        if (object instanceof Import)
        {
            Import importObject = (Import) object;

            if (importObject.getValue().equals(value))
            {
                result = true;
            }
        }

        return result;
    }

    public int getLineNumber()
    {
        return lineNumber;
    }

    public String getValue()
    {
        return value;
    }

    public int hashCode()
    {
        return value.hashCode();
    }
}
