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

package com.adobe.internal.fxg.dom;


import java.util.List;

import com.adobe.fxg.FXGException;
import com.adobe.internal.fxg.dom.transforms.ColorTransformNode;
import com.adobe.internal.fxg.dom.types.BlendMode;
import com.adobe.internal.fxg.dom.types.MaskType;
import com.adobe.internal.fxg.dom.types.ScalingGrid;
import com.adobe.internal.fxg.types.FXGMatrix;

/**
 * A simple context holding inheritable graphic transformation information to be
 * used for placing a symbol on stage.
 * 
 * @author Peter Farland
 */
public class GraphicContext implements Cloneable
{
    private FXGMatrix transform;

    /**
     * Instantiates a new graphic context.
     */
    public GraphicContext()
    {
    }

    /** The blend mode. */
    public BlendMode blendMode;
    
    /** The mask type. */
    public MaskType maskType;
    
    /** The filters. */
    public List<FilterNode> filters;
    
    /** The color transform. */
    public ColorTransformNode colorTransform;
    
    /** The scaling grid. */
    public ScalingGrid scalingGrid;

    /**
     * Gets the transform. If transform is null, create a new instance.
     * 
     * @return the transform
     */
    public FXGMatrix getTransform()
    {
        if (transform == null)
            transform = new FXGMatrix();

        return transform;
    }

    /**
     * Sets the transform.
     * 
     * @param matrix the new transform
     */
    public void setTransform(FXGMatrix matrix)
    {
    	transform = matrix;
    }
    
    /**
     * Adds the filters.
     * 
     * @param list the list
     */
    public void addFilters(List<FilterNode> list)
    {
        if (filters == null)
            filters = list;
        else
            filters.addAll(list);
    }

    /**
     * Make a copy of the current object.
     * 
     * @return the cloned object
     */
    public Object clone()
    {
        GraphicContext copy = null;
        try
        {
            copy = (GraphicContext)super.clone();
            copy.transform = null;
            if (colorTransform != null)
                copy.colorTransform = (ColorTransformNode)colorTransform.clone();
            copy.maskType = maskType;
            copy.blendMode = blendMode;
            copy.scalingGrid = scalingGrid;
        }
        catch (CloneNotSupportedException e)
        {
            throw new FXGException("InternalProcessingError", e);
        }
        return copy;
    }
}
