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

package flex2.compiler.i18n;

/**
 * Represents a ClassReference(...) resource value in a .properties file.
 * 
 * @author Gordon Smith
 */
public class ClassReference
{
    private String value;
    private int lineNumber;

    public ClassReference(String value, int lineNumber)
    {
        this.value = value;
        this.lineNumber = lineNumber;
    }

    public boolean equals(Object object)
    {
        boolean result = false;

        if (object instanceof ClassReference)
        {
            ClassReference classReferenceObject = (ClassReference)object;
           if (classReferenceObject.getValue().equals(value))
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
    
    public String toString()
    {
    	return value;
    }
}
