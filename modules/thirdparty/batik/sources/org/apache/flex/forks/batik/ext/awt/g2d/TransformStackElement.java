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
package org.apache.flex.forks.batik.ext.awt.g2d;

import java.awt.geom.AffineTransform;

/**
 * Contains a description of an elementary transform stack element,
 * such as a rotate or translate. A transform stack element has a
 * type and a value, which is an array of double values.<br>
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @author <a href="mailto:paul_evenblij@compuware.com">Paul Evenblij</a>
 * @version $Id: TransformStackElement.java 478249 2006-11-22 17:29:37Z dvholten $
 */
public abstract class TransformStackElement implements Cloneable{

    /**
     * Transform type
     */
    private TransformType type;

    /**
     * Value
     */
    private double[] transformParameters;

    /**
     * @param type transform type
     * @param transformParameters parameters for transform
     */
    protected TransformStackElement(TransformType type,
                                    double[] transformParameters){
        this.type = type;
        this.transformParameters = transformParameters;
    }

    /**
     * @return an object which is a deep copy of this one
     */
    public Object clone() {
        TransformStackElement newElement = null;

        // start with a shallow copy to get our implementations right
        try {
            newElement = (TransformStackElement) super.clone();
        } catch(java.lang.CloneNotSupportedException ex) {}

        // now deep copy the parameter array
        double[] transformParameters = new double[this.transformParameters.length];
        System.arraycopy(this.transformParameters, 0, transformParameters, 0, transformParameters.length);
        newElement.transformParameters = transformParameters;
        return newElement;
    }

    /*
     * Factory methods
     */

    public static TransformStackElement createTranslateElement(double tx,
                                                               double ty){
        return new TransformStackElement(TransformType.TRANSLATE,
                                         new double[]{ tx, ty }) {
                boolean isIdentity(double[] parameters) {
                    return parameters[0] == 0 && parameters[1] == 0;
                }
            };
    }

    public static TransformStackElement createRotateElement(double theta){
        return new TransformStackElement(TransformType.ROTATE,
                                         new double[]{ theta }) {
                boolean isIdentity(double[] parameters) {
                    return Math.cos(parameters[0]) == 1;
                }
            };
    }

    public static TransformStackElement createScaleElement(double scaleX,
                                                           double scaleY){
        return new TransformStackElement(TransformType.SCALE,
                                         new double[]{ scaleX, scaleY }) {
                boolean isIdentity(double[] parameters) {
                    return parameters[0] == 1 && parameters[1] == 1;
                }
            };
    }

    public static TransformStackElement createShearElement(double shearX,
                                                           double shearY){
        return new TransformStackElement(TransformType.SHEAR,
                                         new double[]{ shearX, shearY }) {
                boolean isIdentity(double[] parameters) {
                    return parameters[0] == 0 && parameters[1] == 0;
                }
            };
    }

    public static TransformStackElement createGeneralTransformElement
        (AffineTransform txf){
        double[] matrix = new double[6];
        txf.getMatrix(matrix);
        return new TransformStackElement(TransformType.GENERAL, matrix) {
                boolean isIdentity(double[] m) {
                    return (m[0] == 1 && m[2] == 0 && m[4] == 0 &&
                            m[1] == 0 && m[3] == 1 && m[5] == 0);
                }
            };
    }

    /**
     * Implementation should determine if the parameter list represents
     * an identity transform, for the instance transform type.
     */
    abstract boolean isIdentity(double[] parameters);

    /**
     * @return true iff this transform is the identity transform
     */
    public boolean isIdentity() {
        return isIdentity(transformParameters);
    }

    /**
     * @return array of values containing this transform element's parameters
     */
    public double[] getTransformParameters(){
        return transformParameters;
    }

    /**
     * @return this transform type
     */
    public TransformType getType(){
        return type;
    }

    /*
     * Concatenation utility. Requests this transform stack element
     * to concatenate with the input stack element. Only elements
     * of the same types are concatenated. For example, if this
     * element represents a translation, it will concatenate with
     * another translation, but not with any other kind of
     * stack element.
     * @param stackElement element to be concatenated with this one.
     * @return true if the input stackElement was concatenated with
     *         this one. False otherwise.
     */
    public boolean concatenate(TransformStackElement stackElement){
        boolean canConcatenate = false;

        if(type.toInt() == stackElement.type.toInt()){
            canConcatenate = true;
            switch(type.toInt()){
            case TransformType.TRANSFORM_TRANSLATE:
                transformParameters[0] += stackElement.transformParameters[0];
                transformParameters[1] += stackElement.transformParameters[1];
                break;
            case TransformType.TRANSFORM_ROTATE:
                transformParameters[0] += stackElement.transformParameters[0];
                break;
            case TransformType.TRANSFORM_SCALE:
                transformParameters[0] *= stackElement.transformParameters[0];
                transformParameters[1] *= stackElement.transformParameters[1];
                break;
            case TransformType.TRANSFORM_GENERAL:
                transformParameters
                    = matrixMultiply(transformParameters,
                                     stackElement.transformParameters);
                break;
            default:
                canConcatenate = false;
            }
        }

        return canConcatenate;
    }

    /**
     *  Multiplies two 2x3 matrices of double precision values
     */
    private double[] matrixMultiply(double[] matrix1, double[] matrix2) {
        double[] product = new double[6];
        AffineTransform transform1 = new AffineTransform(matrix1);
        transform1.concatenate(new AffineTransform(matrix2));
        transform1.getMatrix(product);
        return product;
    }

}
