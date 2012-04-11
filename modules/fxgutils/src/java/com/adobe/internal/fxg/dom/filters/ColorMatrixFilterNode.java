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

package com.adobe.internal.fxg.dom.filters;

import java.util.StringTokenizer;

import com.adobe.fxg.FXGException;
import com.adobe.internal.fxg.dom.DOMParserHelper;

import static com.adobe.fxg.FXGConstants.*;

/**
 * @author Peter Farland
 */
public class ColorMatrixFilterNode extends AbstractFilterNode
{
    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------
    
    /**
     * A 4 x 5 matrix transformation for RGBA. Matrix is in row major order
     * with each row comprising of srcR, srcG, srcB, srcA, 1. The first five
     * values apply to Red, the next five to Green, and so forth.
     */
    public float[] matrix = new float[] {1,0,0,0,0,
                                         0,1,0,0,0,
                                         0,0,1,0,0,
                                         0,0,0,1,0};

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * @return The unqualified name of a ColorMatrixFilter node, without tag
     * markup.
     */
    public String getNodeName()
    {
        return FXG_COLORMATRIXFILTER_ELEMENT;
    }

    /** 
     * Set color transform properties. Delegates to the parent class
     * to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>matrix</b> : A comma-delimited list of 20 doubles that comprise 
     * a 4x5 matrix applied to the rendered element.  The matrix is in row 
     * major order - that is, the first five elements are multiplied by the 
     * vector [srcR,srcG,srcB,srcA,1] to determine the output red value, 
     * the second five determine the output green value, etc. </li>
     * </ul>
     * </p>
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     * 
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.AbstractFXGNode#setAttribute(java.lang.String, java.lang.String)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_MATRIX_ATTRIBUTE.equals(name))
            matrix = get4x5FloatMatrix(value);
        else
            super.setAttribute(name, value);
    }

    //--------------------------------------------------------------------------
    //
    // Helper Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Convert a comma delimited String of 20 numbers to an array of 20 float
     * values representing a 4 x 5 color transform matrix.
     */
    protected float[] get4x5FloatMatrix(String value)
    {
        byte index = 0;
        float[] result = new float[20];
        StringTokenizer tokenizer = new StringTokenizer(value, ",", false);
        try{
            while (tokenizer.hasMoreTokens() && index < 20)
            {
                String token = tokenizer.nextToken();
                float f = DOMParserHelper.parseFloat(this, token);
                result[index++] = f;
            }
        }
        catch(FXGException e)
        {
            throw new FXGException(getStartLine(), getStartColumn(), "InvalidColorMatrix", value);
        }                
        return result;
    }
}
