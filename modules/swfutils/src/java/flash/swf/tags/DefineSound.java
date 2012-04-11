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
 * Represents a DefineSound SWF tag.
 *
 * @author Clement Wong
 */
public class DefineSound extends DefineTag
{
	public DefineSound()
	{
		super(stagDefineSound);
	}

    public void visit(TagHandler h)
	{
		h.defineSound(this);
	}

	public int format;
	public int rate;
	public int size;
	public int type;
	public long sampleCount; // U32
	public byte[] data;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof DefineSound))
        {
            DefineSound defineSound = (DefineSound) object;

            if ( (defineSound.format == this.format) &&
                 (defineSound.rate == this.rate) &&
                 (defineSound.size == this.size) &&
                 (defineSound.type == this.type) &&
                 (defineSound.sampleCount == this.sampleCount) &&
                 Arrays.equals(defineSound.data, this.data) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
