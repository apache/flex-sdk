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
import flash.swf.types.Rect;
import flash.swf.types.ShapeWithStyle;

import java.util.Iterator;
import java.util.LinkedList;

/**
 * Represents a DefineShape SWF tag.
 *
 * @author Clement Wong
 */
public class DefineShape extends DefineTag
{
    public DefineShape(int code)
    {
        super(code);
    }

	public void visit(TagHandler h)
	{
        switch(code)
        {
        case stagDefineShape:
            h.defineShape(this);
            break;
        case stagDefineShape2:
            h.defineShape2(this);
            break;
        case stagDefineShape3:
            h.defineShape3(this);
            break;
        case stagDefineShape4:
            h.defineShape4(this);
            break;
        default:
            assert (false);
            break;
        }
	}

    public Iterator<Tag> getReferences()
    {
        LinkedList<Tag> refs = new LinkedList<Tag>();

        shapeWithStyle.getReferenceList( refs );

        return refs.iterator();
    }

	public Rect bounds;
	public ShapeWithStyle shapeWithStyle;
	public boolean usesFillWindingRule;
	public boolean usesNonScalingStrokes;
    public boolean usesScalingStrokes;
    public Rect edgeBounds;

    public DefineScalingGrid scalingGrid;
    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof DefineShape))
        {
            DefineShape defineShape = (DefineShape) object;

            if ( equals(defineShape.bounds, this.bounds) &&
                 equals(defineShape.shapeWithStyle, this.shapeWithStyle) &&
                 equals(defineShape.edgeBounds, this.edgeBounds) &&
                 (defineShape.usesFillWindingRule == this.usesFillWindingRule) &&
                 (defineShape.usesNonScalingStrokes == this.usesNonScalingStrokes) &&
                  (defineShape.usesScalingStrokes == this.usesScalingStrokes))
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

    public int hashCode() {
      int hashCode = super.hashCode();
      hashCode += DefineTag.PRIME * bounds.hashCode();
      if (shapeWithStyle.shapeRecords !=null) {
        hashCode += DefineTag.PRIME * shapeWithStyle.shapeRecords.size();
      }
      if (shapeWithStyle.linestyles !=null) {
        hashCode += DefineTag.PRIME * shapeWithStyle.linestyles.size();
      }
      return hashCode;
    }

}
