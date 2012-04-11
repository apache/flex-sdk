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
import flash.swf.TagValues;
import flash.swf.types.CXForm;
import flash.swf.types.ClipActions;
import flash.swf.types.Filter;
import flash.swf.types.Matrix;

import java.util.List;

/**
 * This is the place command.  The encoded form can be PlaceObject or
 * PlaceObject2.
 *
 * @author Clement Wong
 */
public class PlaceObject extends Tag
{
    public int flags;
    private static final int HAS_CLIP_ACTION = 1 << 7;
    private static final int HAS_CLIP_DEPTH = 1 << 6;
    private static final int HAS_NAME = 1 << 5;
    private static final int HAS_RATIO = 1 << 4;
    private static final int HAS_CXFORM = 1 << 3;
    private static final int HAS_MATRIX = 1 << 2;
    private static final int HAS_CHARACTER = 1 << 1;
    private static final int HAS_MOVE = 1 << 0;

    public int flags2;
    private static final int HAS_IMAGE = 1 << 4;
    private static final int HAS_CLASS_NAME = 1 << 3;
    private static final int HAS_CACHE_AS_BITMAP = 1 << 2;
    private static final int HAS_BLEND_MODE = 1 << 1;
    private static final int HAS_FILTER_LIST = 1 << 0;

    public int ratio;
    public String name;
    public int clipDepth;
    public ClipActions clipActions;
    public int depth;
    public Matrix matrix;
    public CXForm colorTransform;
    public DefineTag ref;
    public List<Filter> filters;
    public int blendMode;
    public String className;

    public PlaceObject(int code)
    {
        super(code);
    }

    public PlaceObject(Matrix m, DefineTag ref, int depth, String name)
    {
        super(TagValues.stagPlaceObject2);
        this.depth = depth;
        setMatrix(m);
        setRef(ref);
        setName(name);
    }

    public PlaceObject(DefineTag ref, int depth)
    {
        super(TagValues.stagPlaceObject2);
        this.depth = depth;
        setRef(ref);
    }

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof PlaceObject))
        {
            PlaceObject placeObject = (PlaceObject) object;

            // not comparing filters list
            if ( (placeObject.flags == this.flags) &&
                 (placeObject.flags2 == this.flags2) &&
                 (placeObject.ratio == this.ratio) &&
                 equals(placeObject.name, this.name) &&
                 (placeObject.clipDepth == this.clipDepth) &&
                 equals(placeObject.clipActions, this.clipActions) &&
                 (placeObject.depth == this.depth) &&
                 equals(placeObject.matrix, this.matrix) &&
                 equals(placeObject.colorTransform, this.colorTransform) &&
                 equals(placeObject.ref, this.ref) &&
                 (placeObject.blendMode == this.blendMode) &&
                 equals(placeObject.className, this.className) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

    public int hashCode() {
      int hashCode = super.hashCode();
      hashCode += DefineTag.PRIME * flags;
      hashCode += DefineTag.PRIME * ratio;
      if (name!=null) {
        hashCode += name.hashCode();
      }
      hashCode += DefineTag.PRIME * depth;
      return hashCode;
    }


    public void visit(TagHandler h)
    {
        if (code == stagPlaceObject)
            h.placeObject(this);
        else if (code == stagPlaceObject2)
            h.placeObject2(this);
        else // if (code == stagPlaceObject3)
            h.placeObject3(this);
    }

    public Tag getSimpleReference()
    {
        return hasCharID()? ref : null;
    }

    public void setRef(DefineTag ref)
    {
        if (ref == null)
            throw new NullPointerException();
        this.ref = ref;
        flags = ref != null ? flags|HAS_CHARACTER : flags&~HAS_CHARACTER;
    }

    public void setMatrix(Matrix m)
    {
        this.matrix = m;
        flags = m != null ? flags|HAS_MATRIX : flags&~HAS_MATRIX;
    }

    public boolean hasClipAction()
    {
        return (flags & HAS_CLIP_ACTION) != 0;
    }

    public boolean hasClipDepth()
    {
        return (flags & HAS_CLIP_DEPTH) != 0;
    }

    public void setClipDepth(int clipDepth)
    {
        this.clipDepth = clipDepth;
        flags |= HAS_CLIP_DEPTH;
    }

    public boolean hasName()
    {
        return (flags & HAS_NAME) != 0;
    }

    public boolean hasRatio()
    {
        return (flags & HAS_RATIO) != 0;
    }

    public void setRatio(int ratio)
    {
        this.ratio = ratio;
        flags |= HAS_RATIO;
    }

    public boolean hasCharID()
    {
        return (flags & HAS_CHARACTER) != 0;
    }

    public boolean hasMove()
    {
        return (flags & HAS_MOVE) != 0;
    }

    public boolean hasMatrix()
    {
        return (flags & HAS_MATRIX) != 0;
    }

    public boolean hasCxform()
    {
        return (flags & HAS_CXFORM) != 0;
    }

    public boolean hasFilterList()
    {
        return (flags2 & HAS_FILTER_LIST) != 0;
    }

    public void setFilterList(List<Filter> value)
    {
        filters = value;
        flags2 = value != null ? flags2|HAS_FILTER_LIST : flags2&~HAS_FILTER_LIST;
    }

    public boolean hasBlendMode()
    {
        return (flags2 & HAS_BLEND_MODE) != 0;
    }

    public void setBlendMode(int value)
    {
        blendMode = value;
        flags2 = value != 0 ? flags2|HAS_BLEND_MODE : flags2&~HAS_BLEND_MODE;
    }

    public boolean hasCacheAsBitmap()
    {
        return (flags2 & HAS_CACHE_AS_BITMAP) != 0;
    }

    public void setCacheAsBitmap(boolean value)
    {
        flags2 = value ? flags2|HAS_CACHE_AS_BITMAP : flags2&~HAS_CACHE_AS_BITMAP;
    }

    public void setCxform(CXForm cxform)
    {
        this.colorTransform = cxform;
        flags = cxform != null ? flags|HAS_CXFORM : flags&~HAS_CXFORM;
    }

    public void setName(String instanceName)
    {
        this.name = instanceName;
        flags = instanceName != null ? flags|HAS_NAME : flags&~HAS_NAME;
    }

    public void setClipActions(ClipActions actions)
    {
        clipActions = actions;
        flags = actions != null ? flags|HAS_CLIP_ACTION : flags&~HAS_CLIP_ACTION;
    }

    public void setClassName(String className)
    {
        this.className = className;
        flags2 = className != null ? flags2|HAS_CLASS_NAME : flags2&~HAS_CLASS_NAME;
    }

    public boolean hasClassName()
    {
        return (flags2 & HAS_CLASS_NAME) != 0;
    }

    public void setHasImage(boolean value)
    {
        flags2 = value ? flags2|HAS_IMAGE : flags2&~HAS_IMAGE;
    }

    public boolean hasImage()
    {
        return (flags2 & HAS_IMAGE) != 0;
    }

}
