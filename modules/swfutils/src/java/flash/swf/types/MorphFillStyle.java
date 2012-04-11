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

import flash.swf.tags.DefineTag;

/**
 * A value object for morph fill style data.
 *
 * @author Clement Wong
 */
public class MorphFillStyle
{
    public static final int FILL_BITS = 0x40;
    
	public int type;
    /** colors as ints: 0xAARRGGBB */
	public int startColor;
	public int endColor;
	public Matrix startGradientMatrix;
	public Matrix endGradientMatrix;
	public MorphGradRecord[] gradRecords;
    public DefineTag bitmap;
	public Matrix startBitmapMatrix;
	public Matrix endBitmapMatrix;

	// MorphFillStyle for DefineMorphShape2
	public int ratio1, ratio2;

    public boolean hasBitmapId()
    {
        return ((type & FILL_BITS) != 0);
    }

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof MorphFillStyle)
        {
            MorphFillStyle morphFillStyle = (MorphFillStyle) object;

            if ( (morphFillStyle.type == this.type) &&
                 (morphFillStyle.startColor == this.startColor) &&
                 (morphFillStyle.endColor == this.endColor) &&
                 (morphFillStyle.ratio1 == this.ratio1) &&
                 (morphFillStyle.ratio2 == this.ratio2) &&
                 ( ( (morphFillStyle.startGradientMatrix == null) && (this.startGradientMatrix == null) ) ||
                   ( (morphFillStyle.startGradientMatrix != null) && (this.startGradientMatrix != null) &&
                     morphFillStyle.startGradientMatrix.equals(this.startGradientMatrix) ) ) &&
                 ( ( (morphFillStyle.endGradientMatrix == null) && (this.endGradientMatrix == null) ) ||
                   ( (morphFillStyle.endGradientMatrix != null) && (this.endGradientMatrix != null) &&
                     morphFillStyle.endGradientMatrix.equals(this.endGradientMatrix) ) ) &&
                 Arrays.equals(morphFillStyle.gradRecords, this.gradRecords) &&
                 ( ( (morphFillStyle.bitmap == null) && (this.bitmap == null) ) ||
                   ( (morphFillStyle.bitmap != null) && (this.bitmap != null) &&
                     morphFillStyle.bitmap.equals(this.bitmap) ) ) &&
                 ( ( (morphFillStyle.startBitmapMatrix == null) && (this.startBitmapMatrix == null) ) ||
                   ( (morphFillStyle.startBitmapMatrix != null) && (this.startBitmapMatrix != null) &&
                     morphFillStyle.startBitmapMatrix.equals(this.startBitmapMatrix) ) ) &&
                 ( ( (morphFillStyle.endBitmapMatrix == null) && (this.endBitmapMatrix == null) ) ||
                   ( (morphFillStyle.endBitmapMatrix != null) && (this.endBitmapMatrix != null) &&
                     morphFillStyle.endBitmapMatrix.equals(this.endBitmapMatrix) ) ) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
