/*

   Copyright 2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.dom.svg;

import java.awt.geom.AffineTransform;

import org.w3c.flex.forks.dom.svg.SVGMatrix;
import org.w3c.flex.forks.dom.svg.SVGTransform;

/**
 * Abstract implementation for SVGTransform.
 *
 * This is the base implementation for SVGTransform
 * 
 * @author nicolas.socheleau@bitflash.com
 * @version $Id :$
 */
public abstract class AbstractSVGTransform implements SVGTransform {

    /**
     * Type of the transformation.
     * 
     * By default, the type is unknown
     */
    protected short type = SVG_TRANSFORM_UNKNOWN;

    /**
     * AffineTranform associated to the SVGTransform
     *
     * Java2D representation of the SVGTransform.
     */
    protected AffineTransform affineTransform;

    /**
     * Angle associated to the transform.
     * This value is not necessary since the AffineTransform
     * will contain it but it is easier to have it than
     * extracting it from the AffineTransform.
     */
    protected float angle;

    protected float x;

    protected float y;

    /**
     * Create a SVGMatrix associated to the transform.
     *
     * @return SVGMatrix representing the transformation
     */
    protected abstract SVGMatrix createMatrix();

    /**
     * Default constructor.
     */
    protected AbstractSVGTransform(){
    }

    /**
     */
    protected void setType(short type){
        this.type = type;
    }

    protected float getX(){
        return x;
    }

    protected float getY(){
        return y;
    }

    /**
     */
    public short getType( ){
        return type;
    }

    /**
     */
    public SVGMatrix getMatrix( ){
        return createMatrix();
    }
    /**
     */
    public float getAngle( ){
        return angle;
    }
    /**
     */
    public void setMatrix ( SVGMatrix matrix ){
        type = SVG_TRANSFORM_MATRIX;
        affineTransform = new AffineTransform(matrix.getA(),matrix.getB(),matrix.getC(),
                                              matrix.getD(),matrix.getE(),matrix.getF());
    }
    /**
     */
    public void setTranslate ( float tx, float ty ){
        type = SVG_TRANSFORM_TRANSLATE;
        affineTransform = AffineTransform.getTranslateInstance(tx,ty);
    }
    /**
     */
    public void setScale ( float sx, float sy ){
        type = SVG_TRANSFORM_SCALE;
        affineTransform = AffineTransform.getScaleInstance(sx,sy);
    }
    /**
     */
    public void setRotate ( float angle, float cx, float cy ){
        type = SVG_TRANSFORM_ROTATE;
        affineTransform = AffineTransform.getRotateInstance(Math.toRadians(angle),cx,cy);
        this.angle = angle;
        this.x = cx;
        this.y = cy;
    }
    /**
     */
    public void setSkewX ( float angle ){
        type = SVG_TRANSFORM_SKEWX;
        affineTransform = new AffineTransform(1.0,Math.tan(Math.toRadians(angle)),0.0,
                                              1.0,0.0,0.0);
        this.angle = angle;
    }
    /**
     */
    public void setSkewY ( float angle ){
        type = SVG_TRANSFORM_SKEWY;
        this.angle = angle;
        affineTransform = new AffineTransform(1.0,0.0,Math.tan(Math.toRadians(angle)),
                                              1.0,0.0,0.0);
    }

}

