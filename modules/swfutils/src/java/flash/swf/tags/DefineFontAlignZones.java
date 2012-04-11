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

import java.util.Arrays;

import flash.swf.TagHandler;

/**
 * Represents a DefineFontAlignZones SWF tag.
 *
 * @author Brian Deitte
 */
public class DefineFontAlignZones extends DefineTag
{
    public DefineFontAlignZones()
    {
        super(stagDefineFontAlignZones);
    }

    public void visit(TagHandler h)
	{
		   h.defineFontAlignZones(this);
	}

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof DefineFontAlignZones))
        {
            DefineFontAlignZones alignZones = (DefineFontAlignZones)object;

            if (font.equals(alignZones.font) &&
                csmTableHint == alignZones.csmTableHint &&
                Arrays.equals(zoneTable, alignZones.zoneTable))
            {
                isEqual = true;
            }
        }
        return isEqual;
    }

    public DefineFont3 font;
    public int csmTableHint;
    public ZoneRecord[] zoneTable;
}
