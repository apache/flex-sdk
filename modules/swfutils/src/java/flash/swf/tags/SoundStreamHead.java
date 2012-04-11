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
 * This represents a SoundStreamHead SWF tag.
 *
 * @author Clement Wong
 */
public class SoundStreamHead extends Tag
{
    public static final int sndCompressNone = 0;
    public static final int sndCompressADPCM = 1;
    public static final int sndCompressMP3 = 2;
    public static final int sndCompressNoneI = 3;

	public SoundStreamHead(int code)
	{
		super(code);
	}

    public void visit(TagHandler h)
	{
        if (code == stagSoundStreamHead)
		    h.soundStreamHead(this);
        else
            h.soundStreamHead2(this);
	}

	public int playbackRate;
	public int playbackSize;
	public int playbackType;
	public int compression;
	public int streamRate;
	public int streamSize;
	public int streamType;
	public int streamSampleCount;
	public int latencySeek;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof SoundStreamHead))
        {
            SoundStreamHead soundStreamHead = (SoundStreamHead) object;

            if ((soundStreamHead.playbackRate == this.playbackRate) &&
                (soundStreamHead.playbackSize == this.playbackSize) &&
                (soundStreamHead.playbackType == this.playbackType) &&
                (soundStreamHead.compression == this.compression) &&
                (soundStreamHead.streamRate == this.streamRate) &&
                (soundStreamHead.streamSize == this.streamSize) &&
                (soundStreamHead.streamType == this.streamType) &&
                (soundStreamHead.streamSampleCount == this.streamSampleCount) &&
                (soundStreamHead.latencySeek == this.latencySeek))
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
