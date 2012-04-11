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

import java.util.List;

import flash.swf.tags.DefineTag;

/**
 * A value object for button record data.
 *
 * @author Clement Wong
 */
public class ButtonRecord
{
	public boolean hitTest;
	public boolean down;
	public boolean over;
	public boolean up;

    public DefineTag characterRef;
	public int placeDepth;
	public Matrix placeMatrix;
	
    /** only valid if this record is in a DefineButton2 */
	public CXFormWithAlpha colorTransform;
	public List filters;
	public int blendMode = -1; // -1 ==> not set

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof ButtonRecord)
        {
            ButtonRecord buttonRecord = (ButtonRecord) object;

            if ( (buttonRecord.hitTest == this.hitTest) &&
                 (buttonRecord.down == this.down) &&
                 (buttonRecord.over == this.over) &&
                 (buttonRecord.up == this.up) &&
                 (buttonRecord.blendMode == this.blendMode) &&
                 compareFilters(buttonRecord.filters, this.filters) &&
                 ( ( (buttonRecord.characterRef == null) && (this.characterRef == null) ) ||
                   ( (buttonRecord.characterRef != null) && (this.characterRef != null) &&
                     buttonRecord.characterRef.equals(this.characterRef) ) ) &&
                 (buttonRecord.placeDepth == this.placeDepth) &&
                 ( ( (buttonRecord.placeMatrix == null) && (this.placeMatrix == null) ) ||
                   ( (buttonRecord.placeMatrix != null) && (this.placeMatrix != null) &&
                     buttonRecord.placeMatrix.equals(this.placeMatrix) ) ) &&
                 ( ( (buttonRecord.colorTransform == null) && (this.colorTransform == null) ) ||
                   ( (buttonRecord.colorTransform != null) && (this.colorTransform != null) &&
                     buttonRecord.colorTransform.equals(this.colorTransform) ) ) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

    private boolean compareFilters(List filterList1, List filterList2)
    {
    	if (filterList1 == filterList2) return true;
    	if (filterList1 == null || filterList2 == null) return false;
    	if (filterList1.size() != filterList2.size()) return false;
    	for (int i = 0, size = filterList1.size(); i < size; i++)
    	{
    		// TODO: should really be comparing content...
    		if (filterList1.get(i) != filterList2.get(i))
    		{
    			return false;
    		}
    	}
    	return true;
    }
    
    public String getFlags()
    {
        StringBuilder b = new StringBuilder();
        if (blendMode != -1) b.append("hasBlendMode,");
        if (filters != null) b.append("hasFilterList,");
        if (hitTest) b.append("hitTest,");
        if (down) b.append("down,");
        if (over) b.append("over,");
        if (up) b.append("up,");
        if (b.length() > 0)
            b.setLength(b.length()-1);
        return b.toString();
    }
}
