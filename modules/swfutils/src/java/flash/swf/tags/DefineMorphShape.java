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
import flash.swf.types.Shape;
import flash.swf.types.MorphFillStyle;
import flash.swf.types.MorphLineStyle;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

/**
 * Represents a DefineMorphShape SWF tag.
 *
 * @author Clement Wong
 */
public class DefineMorphShape extends DefineTag
{
	public DefineMorphShape(int code)
	{
		super(code);
	}

    public void visit(TagHandler h)
	{
    	if (code == stagDefineMorphShape)
    		h.defineMorphShape(this);
    	else // if (code == stagDefineMorphShape2)
    		h.defineMorphShape2(this);
	}

	public Iterator<Tag> getReferences()
    {
        // This is yucky.
        List<Tag> refs = new LinkedList<Tag>();

        if (startEdges != null)
            startEdges.getReferenceList(refs);
        
        if (endEdges != null)
            endEdges.getReferenceList(refs);

        if (fillStyles != null)
        {
            for (int i = 0; i < fillStyles.length; i++)
            {
                MorphFillStyle style = fillStyles[i];
                if (style != null && style.hasBitmapId() && style.bitmap != null)
                {
                    refs.add(style.bitmap);
                }
            }
        }

        return refs.iterator();
    }

	public Rect startBounds;
	public Rect endBounds;
	public Rect startEdgeBounds;
	public Rect endEdgeBounds;
	public int reserved;
	public boolean usesNonScalingStrokes;
	public boolean usesScalingStrokes;
	public MorphFillStyle[] fillStyles;
	public MorphLineStyle[] lineStyles;
	public Shape startEdges;
	public Shape endEdges;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof DefineMorphShape))
        {
            DefineMorphShape defineMorphShape = (DefineMorphShape) object;

            if ( defineMorphShape.code == this.code &&
            	 equals(defineMorphShape.startBounds, this.startBounds) &&
                 equals(defineMorphShape.endBounds, this.endBounds) &&
                 equals(defineMorphShape.fillStyles, this.fillStyles) &&
                 equals(defineMorphShape.lineStyles,  this.lineStyles) &&
                 equals(defineMorphShape.startEdges, this.startEdges) &&
                 equals(defineMorphShape.endEdges, this.endEdges) )
            {
                isEqual = true;
            	if (this.code == stagDefineMorphShape2)
            	{
            		isEqual = equals(defineMorphShape.startEdgeBounds, this.startEdgeBounds) &&
            				  equals(defineMorphShape.endEdgeBounds, this.endEdgeBounds) &&
            				  defineMorphShape.usesNonScalingStrokes == this.usesNonScalingStrokes &&
            				  defineMorphShape.usesScalingStrokes == this.usesScalingStrokes;
            	}
            }
        }

        return isEqual;
    }
}
