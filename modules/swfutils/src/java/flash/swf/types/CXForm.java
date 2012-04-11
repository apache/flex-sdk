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

import flash.swf.SwfEncoder;

/**
 * A value object for CXForm data.
 *
 * @author Clement Wong
 */
public class CXForm
{
    public boolean hasAdd;
	public boolean hasMult;

	public int redMultTerm;
	public int greenMultTerm;
	public int blueMultTerm;
	public int redAddTerm;
	public int greenAddTerm;
	public int blueAddTerm;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof CXForm)
        {
            CXForm cxForm = (CXForm) object;

            if ( (cxForm.hasAdd == this.hasAdd) &&
                 (cxForm.hasMult == this.hasMult) &&
                 (cxForm.redMultTerm == this.redMultTerm) &&
                 (cxForm.greenMultTerm == this.greenMultTerm) &&
                 (cxForm.blueMultTerm == this.blueMultTerm) &&
                 (cxForm.redAddTerm == this.redAddTerm) &&
                 (cxForm.greenAddTerm == this.greenAddTerm) &&
                 (cxForm.blueAddTerm == this.blueAddTerm) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

	public String toString()
	{
		return redMultTerm + "r" + (redAddTerm>=0 ? "+" : "") + redAddTerm + " " +
				greenMultTerm + "g" + (greenAddTerm>=0 ? "+" : "") + greenAddTerm + " " +
				blueMultTerm + "b" + (blueAddTerm>=0 ? "+" : "") + blueAddTerm;
	}

    public int nbits()
    {
        // two step process to find maximum value of 6 numbers because "FSWFStream::MaxNum" takes only 4 arguments
        int max = SwfEncoder.maxNum(redMultTerm, greenMultTerm, blueMultTerm, redAddTerm);
        max = SwfEncoder.maxNum(greenAddTerm, blueAddTerm, max, 0);
        return SwfEncoder.minBits(max, 1);
    }
}
