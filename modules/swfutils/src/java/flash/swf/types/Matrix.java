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

import flash.swf.SwfEncoder;

/**
 * A value object for matrix data.
 *
 * @author Clement Wong
 */
public class Matrix
{
    public boolean hasScale;
	public int scaleX;
	public int scaleY;
	public boolean hasRotate;
	public int rotateSkew0;
	public int rotateSkew1;
	public int translateX;
	public int translateY;

    public Matrix()
    {
    }

    public Matrix(int translateX, int translateY)
    {
        this.translateX = translateX;
        this.translateY = translateY;
    }

    public Matrix(int translateX, int translateY, double scaleX, double scaleY)
    {
        this.translateX = translateX;
        this.translateY = translateY;
        setScale(scaleX, scaleY);
    }

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof Matrix)
        {
            Matrix matrix = (Matrix) object;

            if ( (matrix.hasScale == this.hasScale) &&
                 (matrix.scaleX == this.scaleX) &&
                 (matrix.scaleY == this.scaleY) &&
                 (matrix.hasRotate == this.hasRotate) &&
                 (matrix.rotateSkew0 == this.rotateSkew0) &&
                 (matrix.rotateSkew1 == this.rotateSkew1) &&
                 (matrix.translateX == this.translateX) &&
                 (matrix.translateY == this.translateY) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

    public String toString()
    {
        StringBuilder b = new StringBuilder();

        if (hasScale)
        {
            b.append("s");
            b.append((float)(scaleX/65536.0)).append(",").append((float)(scaleY/65536.0));
            b.append(" ");
        }

        if (hasRotate)
        {
            b.append("r");
            b.append((float)(rotateSkew0/65536.0)).append(",").append((float)(rotateSkew1/65536.0));
            b.append(" " );
        }

        b.append("t");
        b.append(translateX).append(",").append(translateY);

        return b.toString();
    }

    public int nTranslateBits()
    {
        return SwfEncoder.minBits(SwfEncoder.maxNum(translateX, translateY, 0, 0), 1);
    }

    public int nRotateBits()
    {
        return SwfEncoder.minBits(SwfEncoder.maxNum(rotateSkew0, rotateSkew1,0,0), 1);
    }

    public int nScaleBits()
    {
        return SwfEncoder.minBits(SwfEncoder.maxNum(scaleX, scaleY,0,0), 1);
    }

    public void setRotate(double r0, double r1)
    {
        hasRotate = true;
        rotateSkew0 = (int)(65536*r0);
        rotateSkew1 = (int)(65536*r1);
    }

    public void setScale(double x, double y)
    {
        hasScale = true;
        scaleX = (int)(65536*x);
        scaleY = (int)(65536*y);
    }
/*
    public int xformx(int x, int y)
    {
        return (int)(x*(scaleX/65536.0) + y*(rotateSkew1/65536.0) + translateX);
    }
    public int xformy(int x, int y)
    {
        return (int)(x*(rotateSkew0/65536.0) + y*(scaleY/65536.0) + translateY);
    }

    public Rect xformRect(Rect in)
    {
        int xmin = xformx(in.xMin, in.yMin);
        int ymin = xformy(in.xMin, in.yMin);
        int xmax = xformx(in.xMin, in.yMin);
        int ymax = xformy(in.xMin, in.yMin);

        Rect out = new Rect();
        out.xMin = xmin < xmax ? xmin : xmax;
        out.yMin = ymin < ymax ? ymin : ymax;
        out.xMax = xmin > xmax ? xmin : xmax;
        out.yMax = ymin > ymax ? ymin : ymax;

        return out;
    } */
}
