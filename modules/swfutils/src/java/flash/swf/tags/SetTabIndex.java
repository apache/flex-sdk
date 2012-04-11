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
import flash.swf.TagValues;
import flash.swf.TagHandler;

/**
 * This represents a SetTabIndex SWF tag.
 *
 * @author Edwin Smith
 */
public class SetTabIndex extends Tag
{
    public SetTabIndex(int depth, int index)
    {
        super(TagValues.stagSetTabIndex);
        this.depth = depth;
        this.index = index;
    }

    public void visit(TagHandler tagHandler)
	{
        tagHandler.setTabIndex(this);
	}

    final public int depth;
    final public int index;

    public boolean equals(Object object)
    {
        if (super.equals(object) && object instanceof SetTabIndex)
        {
            SetTabIndex other = (SetTabIndex) object;
            return other.depth == this.depth && other.index == this.index;
        }
        else
        {
            return false;
        }
    }
}
