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

import flash.swf.TagHandler;
import flash.swf.Tag;

import java.util.*;

/**
 * This represents a SymbolClass SWF tag.
 *
 * @author Clement Wong
 */
public class SymbolClass extends Tag
{
	public SymbolClass()
	{
		super(stagSymbolClass);
	}

    public void visit(TagHandler h)
	{
		h.symbolClass(this);
	}

	public Iterator<Tag> getReferences()
    {
		return class2tag.values().iterator();
    }

    public Map<String, Tag> class2tag = new HashMap<String, Tag>();
	public String topLevelClass;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof SymbolClass))
        {
            SymbolClass symbolClasses = (SymbolClass) object;

            if ( equals(symbolClasses.class2tag, this.class2tag) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
