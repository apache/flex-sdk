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
package org.apache.flex.forks.batik.parser;

import java.awt.geom.AffineTransform;
import java.io.Reader;

/**
 * This class provides an implementation of the PathHandler that initializes
 * an AffineTransform from the value of a 'transform' attribute.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AWTTransformProducer.java 501495 2007-01-30 18:00:36Z dvholten $
 */
public class AWTTransformProducer implements TransformListHandler {
    /**
     * The value of the current affine transform.
     */
    protected AffineTransform affineTransform;

    /**
     * Utility method for creating an AffineTransform.
     * @param r The reader used to read the transform specification.
     */
    public static AffineTransform createAffineTransform(Reader r)
        throws ParseException {
        TransformListParser p = new TransformListParser();
        AWTTransformProducer th = new AWTTransformProducer();

        p.setTransformListHandler(th);
        p.parse(r);

        return th.getAffineTransform();
    }

    /**
     * Utility method for creating an AffineTransform.
     * @param s The transform specification.
     */
    public static AffineTransform createAffineTransform(String s)
        throws ParseException {
        TransformListParser p = new TransformListParser();
        AWTTransformProducer th = new AWTTransformProducer();

        p.setTransformListHandler(th);
        p.parse(s);

        return th.getAffineTransform();
    }

    /**
     * Returns the AffineTransform object initialized during the last parsing.
     * @return the transform or null if this handler has not been used by
     *         a parser.
     */
    public AffineTransform getAffineTransform() {
        return affineTransform;
    }

    /**
     * Implements {@link TransformListHandler#startTransformList()}.
     */
    public void startTransformList() throws ParseException {
        affineTransform = new AffineTransform();
    }

    /**
     * Implements {@link
     * TransformListHandler#matrix(float,float,float,float,float,float)}.
     */
    public void matrix(float a, float b, float c, float d, float e, float f)
        throws ParseException {
        affineTransform.concatenate(new AffineTransform(a, b, c, d, e, f));
    }

    /**
     * Implements {@link TransformListHandler#rotate(float)}.
     */
    public void rotate(float theta) throws ParseException {
        affineTransform.concatenate
            (AffineTransform.getRotateInstance( Math.toRadians( theta ) ));
    }

    /**
     * Implements {@link TransformListHandler#rotate(float,float,float)}.
     */
    public void rotate(float theta, float cx, float cy) throws ParseException {
        AffineTransform at
            = AffineTransform.getRotateInstance( Math.toRadians( theta ), cx, cy);
        affineTransform.concatenate(at);
    }

    /**
     * Implements {@link TransformListHandler#translate(float)}.
     */
    public void translate(float tx) throws ParseException {
        AffineTransform at = AffineTransform.getTranslateInstance(tx, 0);
        affineTransform.concatenate(at);
    }

    /**
     * Implements {@link TransformListHandler#translate(float,float)}.
     */
    public void translate(float tx, float ty) throws ParseException {
        AffineTransform at = AffineTransform.getTranslateInstance(tx, ty);
        affineTransform.concatenate(at);
    }

    /**
     * Implements {@link TransformListHandler#scale(float)}.
     */
    public void scale(float sx) throws ParseException {
        affineTransform.concatenate(AffineTransform.getScaleInstance(sx, sx));
    }

    /**
     * Implements {@link TransformListHandler#scale(float,float)}.
     */
    public void scale(float sx, float sy) throws ParseException {
        affineTransform.concatenate(AffineTransform.getScaleInstance(sx, sy));
    }

    /**
     * Implements {@link TransformListHandler#skewX(float)}.
     */
    public void skewX(float skx) throws ParseException {
        affineTransform.concatenate
            (AffineTransform.getShearInstance(Math.tan( Math.toRadians( skx ) ), 0));
    }

    /**
     * Implements {@link TransformListHandler#skewY(float)}.
     */
    public void skewY(float sky) throws ParseException {
        affineTransform.concatenate
            (AffineTransform.getShearInstance(0, Math.tan( Math.toRadians( sky ) )));
    }

    /**
     * Implements {@link TransformListHandler#endTransformList()}.
     */
    public void endTransformList() throws ParseException {
    }
}
