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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import flash.swf.Tag;

/**
 * A value object for a shape with style data.
 *
 * @author Clement Wong
 */
public class ShapeWithStyle extends Shape
{
    public ArrayList<FillStyle> fillstyles;
	public ArrayList<LineStyle> linestyles;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if ( super.equals(object) && (object instanceof ShapeWithStyle) )
        {
            ShapeWithStyle shapeWithStyle = (ShapeWithStyle) object;

            if ( ( ( (shapeWithStyle.fillstyles == null) && (this.fillstyles == null) ) ||
                   ( (shapeWithStyle.fillstyles != null) && (this.fillstyles != null) &&
                     ArrayLists.equals( shapeWithStyle.fillstyles,
                                    this.fillstyles ) ) ) &&
                 ( ( (shapeWithStyle.linestyles == null) && (this.linestyles == null) ) ||
                   ( (shapeWithStyle.linestyles != null) && (this.linestyles != null) &&
                     ArrayLists.equals( shapeWithStyle.linestyles,
                                    this.linestyles ) ) ) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

    public void getReferenceList( List<Tag> refs )
    {
        super.getReferenceList(refs);

        if (fillstyles != null)
        {
            Iterator it = fillstyles.iterator();
            while (it.hasNext())
            {
                FillStyle style = (FillStyle) it.next();
    
                if (style.hasBitmapId() && style.bitmap != null)
                {
                    refs.add( style.bitmap );
                }
            }
        }
    }
}
