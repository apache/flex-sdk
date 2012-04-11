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

package flash.swf.tags;

import flash.swf.Tag;

/**
 * A common base class for most Define* SWF tags.
 */
public abstract class DefineTag extends Tag
{
    public DefineTag(int code)
    {
        super(code);
    }

    /** the export name of this symbol, or null if the symbol is not exported */
    public String name;
    private int id;
    public static final int PRIME=1000003;
    public int getID()
    {
        return id;
    }

    public void setID(int id)
    {
        this.id = id;
    }

    public String toString()
    {
        return name != null ? name : super.toString();
    }

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof DefineTag))
        {
            DefineTag defineTag = (DefineTag) object;

            if ( equals(defineTag.name, this.name) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

    public int hashCode()
    {
        int hashCode = super.hashCode();

        if (name != null)
        {
            hashCode ^= name.hashCode()<<1;
        }

        return hashCode;
    }
}
