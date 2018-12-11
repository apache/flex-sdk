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
 * A value object for kerning record data.
 */
public class KerningRecord
{
    public int code1;
	public int code2;
	public int adjustment;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof KerningRecord)
        {
            KerningRecord kerningRecord = (KerningRecord) object;

            if ( (kerningRecord.code1 == this.code1) &&
                 (kerningRecord.code2 == this.code2) &&
                 (kerningRecord.adjustment == this.adjustment) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
