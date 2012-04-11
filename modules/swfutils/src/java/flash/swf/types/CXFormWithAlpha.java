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
 * This class extends CXForm by adding support for alpha.
 *
 * @author Clement Wong
 */
public class CXFormWithAlpha extends CXForm
{
    public int alphaMultTerm;
	public int alphaAddTerm;

    public int nbits()
    {
        // FFileWrite's MaxNum method takes only 4 arguments, so finding maximum value of 8 arguments takes three steps:
        int maxMult = SwfEncoder.maxNum(redMultTerm, greenMultTerm, blueMultTerm, alphaMultTerm);
        int maxAdd = SwfEncoder.maxNum(redAddTerm, greenAddTerm, blueAddTerm, alphaAddTerm);
        int maxValue = SwfEncoder.maxNum(maxMult, maxAdd, 0, 0);
        return SwfEncoder.minBits(maxValue, 1);
    }

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof CXFormWithAlpha))
        {
            CXFormWithAlpha cxFormWithAlpha = (CXFormWithAlpha) object;

            if ( (cxFormWithAlpha.alphaMultTerm == this.alphaMultTerm) &&
                 (cxFormWithAlpha.alphaAddTerm == this.alphaAddTerm) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

}
