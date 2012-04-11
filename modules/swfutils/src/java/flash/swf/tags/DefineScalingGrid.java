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
import flash.swf.types.Rect;

/**
 * Represents a DefineScalingGrid SWF tag.
 *
 * @author Roger Gonzalez
 */
public class DefineScalingGrid extends Tag
{
    public DefineScalingGrid()
    {
        super(stagDefineScalingGrid);

    }
    public DefineScalingGrid( DefineTag tag )
    {
        this();
        assert tag instanceof DefineSprite || tag instanceof DefineButton;

        if (tag instanceof DefineSprite)
        {
            ((DefineSprite)tag).scalingGrid = this;
        }

    }
    public void visit(TagHandler h)
    {
        h.defineScalingGrid( this );
    }

	protected Tag getSimpleReference()
    {
        return scalingTarget;
    }

    public boolean equals( Object other )
    {
        return ((other instanceof DefineScalingGrid)
                && ((DefineScalingGrid)other).scalingTarget == scalingTarget )
                && ((DefineScalingGrid)other).rect.equals( rect );
    }

    public DefineTag scalingTarget;
    public Rect rect = new Rect();

}
