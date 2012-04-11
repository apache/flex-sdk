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

package com.adobe.internal.fxg.dom.transforms;

import static com.adobe.fxg.FXGConstants.*;

import com.adobe.fxg.FXGException;
import com.adobe.internal.fxg.dom.DOMParserHelper;

/**
 * The Class MatrixNode.
 * 
 * @author Peter Farland
 */
public class MatrixNode extends AbstractTransformNode
{
    //--------------------------------------------------------------------------
    //
    // Attributes
    //
    //--------------------------------------------------------------------------

    /** The top left coefficient of the matrix. */
    public double a = 1.0;
    
    /** The top center coefficient of the matrix. */
    public double b = 0.0;
    
    /** The center left coefficient of the matrix. */
    public double c = 0.0;
    
    /** The center center coefficient of the matrix. */
    public double d = 1.0;
    
    /** The top right coefficient of the matrix. */
    public double tx = 0.0;
    
    /** The center right coefficient of the matrix. */
    public double ty = 0.0;

    //--------------------------------------------------------------------------
    //
    // FXGNode Implementation
    //
    //--------------------------------------------------------------------------

    /**
     * Gets the node name.
     * 
     * @return The unqualified name of a Matrix node, without tag markup.
     */
    public String getNodeName()
    {
        return FXG_MATRIX_ELEMENT;
    }

    /**
     * Set matrix properties. Delegates to the parent 
     * class to process attributes that are not in the list below.
     * <p>Attributes include:
     * <ul>
     * <li><b>a</b> (Number): The top left coefficient of the matrix.</li>
     * <li><b>b</b> (Number): The top center coefficient of the matrix.</li>
     * <li><b>c</b> (Number): The center left coefficient of the matrix.</li>
     * <li><b>d</b> (Number): The center center coefficient of the matrix.</li>
     * <li><b>tx</b> (Number): The top right coefficient of the matrix.</li>
     * <li><b>ty</b> (Number): The center right coefficient of the matrix.</li>
     * </ul>
     * </p>
     * 
     * @param name - the unqualified attribute name.
     * @param value - the attribute value.
     * 
     * @throws FXGException if a value is out of the valid range.
     * @see com.adobe.internal.fxg.dom.transforms.AbstractTransformNode#setAttribute(java.lang.String, java.lang.String)
     */
    @Override
    public void setAttribute(String name, String value)
    {
        if (FXG_A_ATTRIBUTE.equals(name))
            a = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_B_ATTRIBUTE.equals(name))
            b = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_C_ATTRIBUTE.equals(name))
            c = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_D_ATTRIBUTE.equals(name))
            d = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_TX_ATTRIBUTE.equals(name))
            tx = DOMParserHelper.parseDouble(this, value, name);
        else if (FXG_TY_ATTRIBUTE.equals(name))
            ty = DOMParserHelper.parseDouble(this, value, name);
    }

}
