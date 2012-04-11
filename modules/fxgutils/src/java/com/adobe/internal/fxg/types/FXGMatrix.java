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
package com.adobe.internal.fxg.types;

import com.adobe.internal.fxg.dom.transforms.MatrixNode;

import flash.swf.SwfConstants;
import flash.swf.types.Matrix;

/**
 * Utility class to help with matrix transformation for coordinate transformation.
 * 
 * @author Sujata Das
 */
public class FXGMatrix
{

    /** x-axis scaling */
	public double a;
	
	/** x-axis skew */
    public double b;
    
    /** y-axis skew */
    public double c;
    
    /** y-axis scaling */
    public double d;
    
    /** x-axis translation */
    public double tx;
    
    /** y-axis translation */
    public double ty;
    
    //constructor
    /**
     * Instantiates a new fXG matrix.
     * 
     * @param a the a
     * @param b the b
     * @param c the c
     * @param d the d
     * @param tx the tx
     * @param ty the ty
     */
    public FXGMatrix(double a, double b, double c, double d, double tx, double ty)
    {
        this.a = a;
        this.b = b;
        this.c = c;
        this.d = d;
        this.tx = tx;
        this.ty = ty;
    }
    
    /**
     * Instantiates a new identity matrix.
     */
    public FXGMatrix()
    {
        this.identity();
    }

    /**
     * Instantiates a new fXG matrix with a given matrix node.
     * 
     * @param m the m
     */
    public FXGMatrix(MatrixNode m)
    {
        this.a = m.a;
        this.b = m.b;
        this.c = m.c;
        this.d = m.d;
        this.tx = m.tx;
        this.ty = m.ty;
    }

    /**
     * Set the current matrix to be identity matrix.
     */
    public void identity() 
    {
        this.a = 1;
        this.b = 0;
        this.c = 0;
        this.d = 1;
        this.tx = 0;
        this.ty = 0;        
    }
    
    /** 
     * Concatenates matrix m to the current matrix.
     * 
     * @param m the matrix
     */
    public void concat(FXGMatrix m)
    {
        // Matrix multiplication 
        double new_a = a * m.a + b * m.c;
        double new_b = a * m.b + b * m.d;
        double new_c = c * m.a + d * m.c;
        double new_d = c * m.b + d * m.d;
        double new_tx = tx * m.a + ty * m.c + m.tx;
        double new_ty = tx * m.b + ty * m.d + m.ty;

        a  = new_a;
        b  = new_b;
        c  = new_c;
        d  = new_d;
        tx = new_tx;
        ty = new_ty;        
    }
    
    /** 
     * Concatenates a rotation matrix with rotation angle to the current 
     * matrix.
     * 
     * @param angle the angle.
     */
    public void rotate(double angle)
    {
        double cos = Math.cos(angle*Math.PI/180.0);
        double sin = Math.sin(angle*Math.PI/180.0);
        FXGMatrix newM = new FXGMatrix(cos, sin, -sin, cos, 0, 0);
        this.concat (newM);
    }
    
    /** 
     * Concatenates a scaling matrix with scale factors scaleX and scaleY to 
     * the current matrix.
     * 
     * @param scaleX the scaling x
     * @param scaleY the scaling y
     */
    public void scale(double scaleX, double scaleY)
    {
        FXGMatrix newM = new FXGMatrix(scaleX, 0, 0, scaleY, 0, 0);
        this.concat (newM);     
    }
    
    /** 
     * Concatenates a transaltion matrix with translations (dx, dy) to the 
     * current matrix.
     * 
     * @param dx the translation x
     * @param dy the translation y
     */
    public void translate(double dx, double dy)
    {
        tx += dx;
        ty += dy;
    }
    
    /** 
     * Creates a matrix from the discrete transform parameters
     * 
     * @param scaleX the scaling x
     * @param scaleY the scaling y
     * @param rotation the rotation
     * @param tx the translation x
     * @param ty the translation y
     * @return the matrix
     */
    public static FXGMatrix convertToMatrix(double scaleX, double scaleY, double rotation, double tx, double ty)
    {
        FXGMatrix m = new FXGMatrix();
        m.scale (scaleX, scaleY);
        m.rotate (rotation);
        m.translate(tx, ty);        
        return m;
    }

    /**
     * Returns a SWF Matrix data type that is equivalent to the current matrix.
     * 
     * @return the matrix
     */
    public Matrix toSWFMatrix()
    {
        
        /*SWF matrices need to be invertible - check if it is invertible
         * disabled it for now - other apps seem to allow it
        FXGMatrix newm = new FXGMatrix(a, b, c, d, tx, ty);
        if (!newm.invert())
            throw new FXGException("MatrixNotInvertible");
        */
        
        Matrix sm = new Matrix();
        if (b != 0 || c != 0)
            sm.hasRotate = true;        
        if (a != 0 || d != 0)
            sm.hasScale = true;
        sm.scaleX = (int) (a * SwfConstants.FIXED_POINT_MULTIPLE);
        sm.scaleY =  (int) (d * SwfConstants.FIXED_POINT_MULTIPLE);
        sm.rotateSkew0 = (int) (b * SwfConstants.FIXED_POINT_MULTIPLE);
        sm.rotateSkew1 =  (int) (c * SwfConstants.FIXED_POINT_MULTIPLE);
        sm.translateX = (int) (tx * SwfConstants.TWIPS_PER_PIXEL);
        sm.translateY = (int) (ty * SwfConstants.TWIPS_PER_PIXEL);
        
        return sm;        
    }
    
    /**
     * Set matrix attribute values with values in this FXGMatrix object.
     * @param node - the matrix node whose attribute values will be updated.
     */
    public void setMatrixNodeValue(MatrixNode node)
    {
        node.a = this.a;
        node.b = this.b;
        node.c = this.c;
        node.d = this.d;
        node.tx = this.tx;
        node.ty = this.ty;
    }
    
}
