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

package flash.swf.builder.types;

import flash.swf.SwfConstants;
import flash.swf.types.Matrix;

import java.awt.geom.AffineTransform;

/**
 * This class is used to construct a Matrix object from a
 * AffineTransform object.
 *
 * @author Peter Farland
 */
public final class MatrixBuilder
{
    private MatrixBuilder()
    {
    }

    public static Matrix build(AffineTransform at)
    {
        Matrix matrix = new Matrix();
        matrix.scaleX = (int)Math.rint(at.getScaleX() * SwfConstants.FIXED_POINT_MULTIPLE);
        matrix.scaleY = (int)Math.rint(at.getScaleY() * SwfConstants.FIXED_POINT_MULTIPLE);
        if (matrix.scaleX != 0 || matrix.scaleY != 0)
            matrix.hasScale = true;

        matrix.rotateSkew0 = (int)Math.rint(at.getShearY() * SwfConstants.FIXED_POINT_MULTIPLE); //Yes, these are supposed
        matrix.rotateSkew1 = (int)Math.rint(at.getShearX() * SwfConstants.FIXED_POINT_MULTIPLE); //to be flipped
        if (matrix.rotateSkew0 != 0 || matrix.rotateSkew1 != 0)
        {
            matrix.hasRotate = true;
            if ((at.getType() & AffineTransform.TYPE_MASK_ROTATION) != 0)
                matrix.hasScale = true; //A rotation operation in Flash requires both rotate and scale components, even if zero scale.
        }

        matrix.translateX = (int)Math.rint(at.getTranslateX() * SwfConstants.TWIPS_PER_PIXEL);
        matrix.translateY = (int)Math.rint(at.getTranslateY() * SwfConstants.TWIPS_PER_PIXEL);

        return matrix;
    }

    public static Matrix getTranslateInstance(double tx, double ty)
    {
        Matrix matrix = new Matrix();
        matrix.translateX = (int)Math.rint(tx * SwfConstants.TWIPS_PER_PIXEL);
        matrix.translateY = (int)Math.rint(ty * SwfConstants.TWIPS_PER_PIXEL);
        return matrix;
    }

}
