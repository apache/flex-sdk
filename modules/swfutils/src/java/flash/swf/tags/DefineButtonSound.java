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
import flash.swf.types.SoundInfo;

import java.util.Iterator;
import java.util.ArrayList;

/**
 * This class represents a DefineButtonSound SWF tag.
 *
 * @author Clement Wong
 */
public class DefineButtonSound extends Tag
{
    public DefineButtonSound()
	{
		super(stagDefineButtonSound);
	}

    public void visit(TagHandler h)
	{
		h.defineButtonSound(this);
	}

	public Iterator<Tag> getReferences()
    {
        ArrayList<Tag> list = new ArrayList<Tag>(5);
        list.add(button);
        if (sound0 != null)
            list.add(sound0);
        if (sound1 != null)
            list.add(sound1);
        if (sound2 != null)
            list.add(sound2);
        if (sound3 != null)
            list.add(sound3);
        return list.iterator();
    }

	public DefineTag sound0;
	public SoundInfo info0;
	public DefineTag sound1;
	public SoundInfo info1;
	public DefineTag sound2;
	public SoundInfo info2;
	public DefineTag sound3;
	public SoundInfo info3;

    public DefineButton button;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof DefineButtonSound))
        {
            DefineButtonSound defineButtonSound = (DefineButtonSound) object;

            // [ed] don't compare button because that would be infinite recursion
            if ( equals(defineButtonSound.sound0, this.sound0) &&
                 equals(defineButtonSound.info0, this.info0) &&
                 equals(defineButtonSound.sound1, this.sound1) &&
                 equals(defineButtonSound.info1, this.info1) &&
                 equals(defineButtonSound.sound2, this.sound2) &&
                 equals(defineButtonSound.info2, this.info2) &&
                 equals(defineButtonSound.sound3, this.sound3) &&
                 equals(defineButtonSound.info3, this.info3))
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
