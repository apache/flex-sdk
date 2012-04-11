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

/**
 * Represents a DefineVideoStream SWF tag.
 *
 * @author Clement Wong
 */
public class DefineVideoStream extends DefineTag
{
	public DefineVideoStream()
	{
		super(stagDefineVideoStream);
	}

    public void visit(TagHandler h)
	{
		h.defineVideoStream(this);
	}

	public int numFrames;
	public int width;
	public int height;
	public int deblocking;
	public boolean smoothing;
	public int codecID;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof DefineVideoStream))
        {
            DefineVideoStream defineVideoStream = (DefineVideoStream) object;

            if ( (defineVideoStream.numFrames == this.numFrames) &&
                 (defineVideoStream.width == this.width) &&
                 (defineVideoStream.height == this.height) &&
                 (defineVideoStream.deblocking == this.deblocking) &&
                 (defineVideoStream.smoothing == this.smoothing) &&
                 (defineVideoStream.codecID == this.codecID) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
