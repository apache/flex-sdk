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

package flash.swf.types;

import java.util.Arrays;

/**
 * A value object for sound info.
 *
 * @author Clement Wong
 */
public class SoundInfo
{
	public static final int UNINITIALIZED = -1;

	public boolean syncStop;
	public boolean syncNoMultiple;

	// they are unsigned, so if they're -1, they're not initialized.
	public long inPoint = UNINITIALIZED;
	public long outPoint = UNINITIALIZED;
	public int loopCount = UNINITIALIZED;

    /** pos44:32, leftLevel:16, rightLevel:16 */
	public long[] records = new long[0];

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof SoundInfo)
        {
            SoundInfo soundInfo = (SoundInfo) object;

            if ( (soundInfo.syncStop == this.syncStop) &&
                 (soundInfo.syncNoMultiple == this.syncNoMultiple) &&
                 (soundInfo.inPoint == this.inPoint) &&
                 (soundInfo.outPoint == this.outPoint) &&
                 (soundInfo.loopCount == this.loopCount) &&
                 Arrays.equals(soundInfo.records, this.records) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
