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
import flash.swf.TagHandler;

/**
 * This represents a RemoveObject SWF tag.
 *
 * @author Clement Wong
 */
public class RemoveObject extends Tag
{
	public RemoveObject(int code)
	{
		super(code);
	}

    public void visit(TagHandler h)
	{
        if (code == stagRemoveObject)
    		h.removeObject(this);
        else
            h.removeObject2(this);
	}

	public Tag getSimpleReference()
    {
        return ref;
    }

    public int depth;
    public DefineTag ref;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof RemoveObject))
        {
            RemoveObject removeObject = (RemoveObject) object;

            if ( (removeObject.depth == this.depth) &&
                 equals(removeObject.ref, this.ref) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
