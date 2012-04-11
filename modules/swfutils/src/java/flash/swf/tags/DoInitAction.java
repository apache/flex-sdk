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
import flash.swf.types.ActionList;

/**
 * Represents a DefineInitAction SWF tag.  This is used by AS2.
 *
 * @author Clement Wong
 */
public class DoInitAction extends Tag
{
    public DoInitAction()
	{
		super(stagDoInitAction);
	}

    public DoInitAction(DefineSprite sprite)
    {
        this();
        this.sprite = sprite;
        sprite.initAction = this;
    }

    public void visit(TagHandler h)
	{
		h.doInitAction(this);
	}

	protected Tag getSimpleReference()
    {
        return sprite;
    }

    public DefineSprite sprite;
	public ActionList actionList;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof DoInitAction))
        {
            DoInitAction doInitAction = (DoInitAction) object;

            assert (doInitAction.sprite.initAction == doInitAction);

            // [paul] Checking that the sprite fields are equal would
            // lead to an infinite loop, because DefineSprite contains
            // a reference to it's DoInitAction.  Also don't compare
            // the order fields, because they are never the same.
            if ( equals(doInitAction.actionList, this.actionList))
            {
                isEqual = true;
            }
        }

        assert (sprite.initAction == this);

        return isEqual;
    }
}
