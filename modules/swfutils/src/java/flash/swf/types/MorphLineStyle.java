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
 * A value object for morph line style data.
 *
 * @author Clement Wong
 */
public class MorphLineStyle
{
    public int startWidth;
	public int endWidth;

	// MorphLineStyle2
	public int startCapsStyle;
	public int jointStyle;
	public boolean hasFill;
	public boolean noHScale;
	public boolean noVScale;
	public boolean pixelHinting;
	public boolean noClose;
	public int endCapsStyle;
	public int miterLimit;

	public MorphFillStyle fillType;
	// end MorphLineStyle2
	
    /** colors as ints: 0xAARRGGBB */
	public int startColor;
	public int endColor;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof MorphLineStyle)
        {
            MorphLineStyle morphLineStyle = (MorphLineStyle) object;

            if ( (morphLineStyle.startWidth == this.startWidth) &&
                 (morphLineStyle.endWidth == this.endWidth) &&
                 
                 (morphLineStyle.startCapsStyle == this.startCapsStyle) &&
                 (morphLineStyle.jointStyle == this.jointStyle) &&
                 (morphLineStyle.hasFill == this.hasFill) &&
                 (morphLineStyle.noHScale == this.noHScale) &&
                 (morphLineStyle.noVScale == this.noVScale) &&
                 (morphLineStyle.pixelHinting == this.pixelHinting) &&
                 (morphLineStyle.noClose == this.noClose) &&
                 (morphLineStyle.endCapsStyle == this.endCapsStyle) &&
                 (morphLineStyle.miterLimit == this.miterLimit) &&
                 morphLineStyle.fillType.equals(this.fillType) &&
                 
                 (morphLineStyle.startColor == this.startColor) &&
                 (morphLineStyle.endColor == this.endColor) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }    
}
