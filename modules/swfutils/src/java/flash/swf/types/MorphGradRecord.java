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

/**
 * A value object for morph grad record data.
 *
 * @author Clement Wong
 */
public class MorphGradRecord
{
    public int startRatio;
    public int endRatio;

    /** colors as ints: 0xAARRGGBB */
	public int startColor;
	public int endColor;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof MorphGradRecord)
        {
            MorphGradRecord morphGradRecord = (MorphGradRecord) object;

            if ( (morphGradRecord.startRatio == this.startRatio) &&
                 (morphGradRecord.startColor == this.startColor) &&
                 (morphGradRecord.endRatio == this.endRatio) &&
                 (morphGradRecord.endColor == this.endColor) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }    
}
