/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.ext.awt.color;

import java.awt.color.ColorSpace;
import java.awt.color.ICC_ColorSpace;
import java.awt.color.ICC_Profile;

/**
 * This class extends the ICCColorSpace class by providing
 * convenience methods to convert to sRGB using various
 * methods, forcing a givent intent, such as perceptual or
 * relative colorimetric.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: ICCColorSpaceExt.java 504084 2007-02-06 11:24:46Z dvholten $
 */
public class ICCColorSpaceExt extends ICC_ColorSpace {
    public static final int PERCEPTUAL = 0;
    public static final int RELATIVE_COLORIMETRIC = 1;
    public static final int ABSOLUTE_COLORIMETRIC = 2;
    public static final int SATURATION = 3;
    public static final int AUTO = 4;

    static final ColorSpace sRGB = ColorSpace.getInstance(ColorSpace.CS_sRGB);
    int intent;

    public ICCColorSpaceExt(ICC_Profile p, int intent){
        super(p);

        this.intent = intent;
        switch(intent){
        case AUTO:
        case RELATIVE_COLORIMETRIC:
        case ABSOLUTE_COLORIMETRIC:
        case SATURATION:
        case PERCEPTUAL:
            break;
        default:
            throw new IllegalArgumentException();
        }

        /**
         * Apply the requested intent into the profile
         */
        if(intent != AUTO){
            byte[] hdr = p.getData(ICC_Profile.icSigHead);
            hdr[ICC_Profile.icHdrRenderingIntent] = (byte)intent;
        }
    }

    /**
     * Returns the sRGB value obtained by forcing the
     * conversion method to the intent passed to the
     * constructor
     */
    public float[] intendedToRGB(float[] values){
        switch(intent){
            case ABSOLUTE_COLORIMETRIC:
            return absoluteColorimetricToRGB(values);
            case PERCEPTUAL:
            case AUTO:
            return perceptualToRGB(values);
            case RELATIVE_COLORIMETRIC:
            return relativeColorimetricToRGB(values);
            case SATURATION:
            return saturationToRGB(values);
            default:
            throw new Error("invalid intent:" + intent );
        }
    }

    /**
     * Perceptual conversion is the method implemented by the
     * base class's toRGB method
     */
    public float[] perceptualToRGB(float[] values){
        return toRGB(values);
    }

    /**
     * Relative colorimetric needs to happen through CIEXYZ
     * conversion
     */
    public float[] relativeColorimetricToRGB(float[] values){
        float[] ciexyz = toCIEXYZ(values);
        return sRGB.fromCIEXYZ(ciexyz);
    }

    /**
     * Absolute colorimetric. NOT IMPLEMENTED.
     * Temporarily returns same as perceptual
     */
    public float[] absoluteColorimetricToRGB(float[] values){
        return perceptualToRGB(values);
    }

    /**
     * Saturation. NOT IMPLEMENTED. Temporarily returns same
     * as perceptual.
     */
    public float[] saturationToRGB(float[] values){
        return perceptualToRGB(values);
    }
}
