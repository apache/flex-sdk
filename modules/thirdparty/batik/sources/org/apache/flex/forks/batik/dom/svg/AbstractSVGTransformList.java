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
package org.apache.flex.forks.batik.dom.svg;

import java.awt.geom.AffineTransform;

import org.apache.flex.forks.batik.parser.ParseException;
import org.apache.flex.forks.batik.parser.TransformListHandler;
import org.apache.flex.forks.batik.parser.TransformListParser;

import org.w3c.dom.DOMException;
import org.w3c.dom.svg.SVGException;
import org.w3c.dom.svg.SVGMatrix;
import org.w3c.dom.svg.SVGTransform;
import org.w3c.dom.svg.SVGTransformList;

/**
 * This class is the implementation of
 * <code>SVGTransformList</code>.
 *
 * @author <a href="mailto:nicolas.socheleau@bitflash.com">Nicolas Socheleau</a>
 * @version $Id: AbstractSVGTransformList.java 498484 2007-01-21 23:13:31Z cam $
 */
public abstract class AbstractSVGTransformList
    extends AbstractSVGList
    implements SVGTransformList {

    /**
     * Separator for a point list.
     */
    public static final String SVG_TRANSFORMATION_LIST_SEPARATOR
        = "";

    /**
     * Return the separator between transform in the list.
     */
    protected String getItemSeparator() {
        return SVG_TRANSFORMATION_LIST_SEPARATOR;
    }

    /**
     * Create an SVGException when the checkItemType fails.
     * @return SVGException
     */
    protected abstract SVGException createSVGException(short type,
                                                       String key,
                                                       Object[] args);

    /**
     * <b>DOM</b>: Implements {@link SVGTransformList#initialize(SVGTransform)}.
     */
    public SVGTransform initialize(SVGTransform newItem)
            throws DOMException, SVGException {
        return (SVGTransform) initializeImpl(newItem);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTransformList#getItem(int)}.
     */
    public SVGTransform getItem(int index) throws DOMException {
        return (SVGTransform) getItemImpl(index);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGTransformList#insertItemBefore(SVGTransform,int)}.
     */
    public SVGTransform insertItemBefore(SVGTransform newItem, int index)
            throws DOMException, SVGException {
        return (SVGTransform) insertItemBeforeImpl(newItem, index);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGTransformList#replaceItem(SVGTransform,int)}.
     */
    public SVGTransform replaceItem(SVGTransform newItem, int index)
            throws DOMException, SVGException {
        return (SVGTransform) replaceItemImpl(newItem, index);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTransformList#removeItem(int)}.
     */
    public SVGTransform removeItem(int index) throws DOMException {
        return (SVGTransform) removeItemImpl(index);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTransformList#appendItem(SVGTransform)}.
     */
    public SVGTransform appendItem(SVGTransform newItem)
            throws DOMException, SVGException {
        return (SVGTransform) appendItemImpl(newItem);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGTransformList#createSVGTransformFromMatrix(SVGMatrix)}.
     */
    public SVGTransform createSVGTransformFromMatrix(SVGMatrix matrix) {
        SVGOMTransform transform = new SVGOMTransform();
        transform.setMatrix(matrix);
        return transform;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGTransformList#consolidate()}.
     */
    public SVGTransform consolidate() {
        revalidate();

        int size = itemList.size();
        if (size == 0) {
            return null;
        } else if (size == 1) {
            return getItem(0);
        }

        SVGTransformItem t = (SVGTransformItem) getItemImpl(0);
        AffineTransform at = (AffineTransform) t.affineTransform.clone();

        for (int i = 1; i < size; i++) {
            t = (SVGTransformItem) getItemImpl(i);
            at.concatenate(t.affineTransform);
        }
        SVGOMMatrix matrix = new SVGOMMatrix(at);
        return initialize(createSVGTransformFromMatrix(matrix));
    }

    /**
     * Returns an {@link AffineTransform} that represents the same transform
     * as that specified by this transform list.
     */
    public AffineTransform getAffineTransform() {
        AffineTransform at = new AffineTransform();
        for (int i = 0; i < getNumberOfItems(); i++) {
            SVGTransformItem item = (SVGTransformItem) getItem(i);
            at.concatenate(item.affineTransform);
        }
        return at;
    }

    /**
     * Creates a new {@link SVGItem} object from the given {@link SVGTransform}.
     */
    protected SVGItem createSVGItem(Object newItem) {
        return new SVGTransformItem((SVGTransform) newItem);
    }

    /**
     * Parse the attribute associated with this SVGTransformList.
     *
     * @param value the transform list attribute value
     * @param handler transform list handler
     */
    protected void doParse(String value, ListHandler handler)
            throws ParseException {

        TransformListParser transformListParser = new TransformListParser();
        TransformListBuilder builder = new TransformListBuilder(handler);
        transformListParser.setTransformListHandler(builder);
        transformListParser.parse(value);
    }

    /**
     * Asserts that the given item is an {@link SVGTransformList}.
     */
    protected void checkItemType(Object newItem) {
        if (!(newItem instanceof SVGTransform)) {
            createSVGException(SVGException.SVG_WRONG_TYPE_ERR,
                               "expected.transform", null);
        }
    }

    /**
     * An {@link SVGTransform} in the list.
     */
    protected class SVGTransformItem
            extends AbstractSVGTransform
            implements SVGItem {

        /**
         * Whether the transform value specifies only an x value, no y value.
         */
        protected boolean xOnly;

        /**
         * Whether the rotation transform value specifies only an angle.
         */
        protected boolean angleOnly;

        /**
         * List the item belongs to.
         */
        protected AbstractSVGList parent;

        /**
         * String representation of the item.
         *
         * This is a cached representation of the
         * item while it is not changed.
         */
        protected String itemStringValue;

        /**
         * Creates a new, uninitialized SVGTransformItem.
         */
        protected SVGTransformItem() {
        }

        /**
         * Creates a new SVGTransformItem from the given {@link SVGTransform}.
         */
        protected SVGTransformItem(SVGTransform transform) {
            assign(transform);
        }

        /**
         * Notifies the parent list that this item has changed.  This also
         * discards the cached representation of the item.
         */
        protected void resetAttribute() {
            if (parent != null) {
                itemStringValue = null;
                parent.itemChanged();
            }
        }

        /**
         * Assigns a parent list to this item.
         * @param list The list the item belongs.
         */
        public void setParent(AbstractSVGList list) {
            parent = list;
        }

        /**
         * Returns the parent list of this item.
         */
        public AbstractSVGList getParent() {
            return parent;
        }

        /**
         * Returns the cached representation of the item if valid, otherwise
         * recomputes the String representation of the item.
         */
        public String getValueAsString() {
            if (itemStringValue == null) {
                itemStringValue = getStringValue();
            }
            return itemStringValue;
        }

        /**
         * Copies the values from the given {@link SVGTransform} into this
         * {@link SVGTransformItem}.
         */
        public void assign(SVGTransform transform) {
            type = transform.getType();
            SVGMatrix matrix = transform.getMatrix();
            switch (type) {
                case SVGTransform.SVG_TRANSFORM_TRANSLATE:
                    setTranslate(matrix.getE(), matrix.getF());
                    break;
                case SVGTransform.SVG_TRANSFORM_SCALE:
                    setScale(matrix.getA(), matrix.getD());
                    break;
                case SVGTransform.SVG_TRANSFORM_ROTATE:
                    if (matrix.getE() == 0.0f) {
                        rotate(transform.getAngle());
                    } else {
                        angleOnly = false;
                        if (matrix.getA() == 1.0f) {
                            setRotate(transform.getAngle(),
                                      matrix.getE(), matrix.getF());
                        } else if (transform instanceof AbstractSVGTransform) {
                            AbstractSVGTransform internal =
                                (AbstractSVGTransform) transform;
                            setRotate(internal.getAngle(),
                                      internal.getX(), internal.getY());
                        } else {
                            // XXX Should extract the angle, x and y from the
                            //     matrix.
                        }
                    }
                    break;
                case SVGTransform.SVG_TRANSFORM_SKEWX:
                    setSkewX(transform.getAngle());
                    break;
                case SVGTransform.SVG_TRANSFORM_SKEWY:
                    setSkewY(transform.getAngle());
                    break;
                case SVGTransform.SVG_TRANSFORM_MATRIX:
                    setMatrix(matrix);
                    break;
            }
        }

        /**
         * Sets the transform to be an x translation.
         */
        protected void translate(float x) {
            xOnly = true;
            setTranslate(x, 0.0f);
        }

        /**
         * Sets the transform to be rotation.
         */
        protected void rotate(float angle) {
            angleOnly = true;
            setRotate(angle, 0.0f, 0.0f);
        }

        /**
         * Sets the transform to be an x scale.
         */
        protected void scale(float x) {
            xOnly = true;
            setScale(x, x);
        }

        /**
         * Sets the transform to be a matrix transform.
         */
        protected void matrix(float a, float b, float c,
                              float d, float e, float f) {
            setMatrix(new SVGOMMatrix(new AffineTransform(a, b, c, d, e, f)));
        }

        /**
         * <b>DOM</b>: Implements {@link SVGTransform#setMatrix(SVGMatrix)}.
         */
        public void setMatrix(SVGMatrix matrix) {
            super.setMatrix(matrix);
            resetAttribute();
        }

        /**
         * <b>DOM</b>: Implements {@link SVGTransform#setTranslate(float,float)}.
         */
        public void setTranslate(float tx, float ty) {
            super.setTranslate(tx, ty);
            resetAttribute();
        }

        /**
         * <b>DOM</b>: Implements {@link SVGTransform#setScale(float,float)}.
         */
        public void setScale(float sx, float sy) {
            super.setScale(sx, sy);
            resetAttribute();
        }

        /**
         * <b>DOM</b>: Implements {@link
         * SVGTransform#setRotate(float,float,float)}.
         */
        public void setRotate(float angle, float cx, float cy) {
            super.setRotate(angle, cx, cy);
            resetAttribute();
        }

        /**
         * <b>DOM</b>: Implements {@link SVGTransform#setSkewX(float)}.
         */
        public void setSkewX(float angle) {
            super.setSkewX(angle);
            resetAttribute();
        }

        /**
         * <b>DOM</b>: Implements {@link SVGTransform#setSkewY(float)}.
         */
        public void setSkewY(float angle) {
            super.setSkewY(angle);
            resetAttribute();
        }

        /**
         * Creates the {@link SVGMatrix} used to store the transform.
         */
        protected SVGMatrix createMatrix() {
            return new AbstractSVGMatrix() {
                protected AffineTransform getAffineTransform() {
                    return SVGTransformItem.this.affineTransform;
                }
                public void setA(float a) throws DOMException {
                    SVGTransformItem.this.type = SVGTransform.SVG_TRANSFORM_MATRIX;
                    super.setA(a);
                    SVGTransformItem.this.resetAttribute();
                }
                public void setB(float b) throws DOMException {
                    SVGTransformItem.this.type = SVGTransform.SVG_TRANSFORM_MATRIX;
                    super.setB(b);
                    SVGTransformItem.this.resetAttribute();
                }
                public void setC(float c) throws DOMException {
                    SVGTransformItem.this.type = SVGTransform.SVG_TRANSFORM_MATRIX;
                    super.setC(c);
                    SVGTransformItem.this.resetAttribute();
                }
                public void setD(float d) throws DOMException {
                    SVGTransformItem.this.type = SVGTransform.SVG_TRANSFORM_MATRIX;
                    super.setD(d);
                    SVGTransformItem.this.resetAttribute();
                }
                public void setE(float e) throws DOMException {
                    SVGTransformItem.this.type = SVGTransform.SVG_TRANSFORM_MATRIX;
                    super.setE(e);
                    SVGTransformItem.this.resetAttribute();
                }
                public void setF(float f) throws DOMException {
                    SVGTransformItem.this.type = SVGTransform.SVG_TRANSFORM_MATRIX;
                    super.setF(f);
                    SVGTransformItem.this.resetAttribute();
                }
            };
        }

        /**
         * Returns the string representation of this transform.
         */
        protected String getStringValue(){
            StringBuffer buf = new StringBuffer();
            switch(type) {
                case SVGTransform.SVG_TRANSFORM_TRANSLATE:
                    buf.append("translate(");
                    buf.append((float) affineTransform.getTranslateX());
                    if (!xOnly) {
                        buf.append(' ');
                        buf.append((float) affineTransform.getTranslateY());
                    }
                    buf.append(')');
                    break;
                case SVGTransform.SVG_TRANSFORM_ROTATE:
                    buf.append("rotate(");
                    buf.append(angle);
                    if (!angleOnly) {
                        buf.append(' ');
                        buf.append(x);
                        buf.append(' ');
                        buf.append(y);
                    }
                    buf.append(')');
                    break;
                case SVGTransform.SVG_TRANSFORM_SCALE:
                    buf.append("scale(");
                    buf.append((float) affineTransform.getScaleX());
                    if (!xOnly) {
                        buf.append(' ');
                        buf.append((float) affineTransform.getScaleY());
                    }
                    buf.append(')');
                    break;
                case SVGTransform.SVG_TRANSFORM_SKEWX:
                    buf.append("skewX(");
                    buf.append(angle);
                    buf.append(')');
                    break;
                case SVGTransform.SVG_TRANSFORM_SKEWY:
                    buf.append("skewY(");
                    buf.append(angle);
                    buf.append(')');
                    break;
                case SVGTransform.SVG_TRANSFORM_MATRIX:
                    buf.append("matrix(");
                    double[] matrix = new double[6];
                    affineTransform.getMatrix(matrix);
                    for(int i = 0; i < 6; i++) {
                        if (i != 0) {
                            buf.append(' ');
                        }
                        buf.append((float) matrix[i]);
                    }
                    buf.append(')');
                    break;
            }
            return buf.toString();
        }
    }

    /**
     * Helper class to interface the {@link TransformListParser} and the
     * {@link ListHandler}.
     */
    protected class TransformListBuilder implements TransformListHandler {

        /**
         * The {@link ListHandler} to pass newly created
         * {@link SVGTransformItem} objects to.
         */
        protected ListHandler listHandler;

        /**
         * Creates a new TransformListBuilder.
         */
        public TransformListBuilder(ListHandler listHandler) {
            this.listHandler = listHandler;
        }

        /**
         * Implements {@link TransformListHandler#startTransformList()}.
         */
        public void startTransformList() throws ParseException {
            listHandler.startList();
        }

        /**
         * Implements {@link
         * TransformListHandler#matrix(float,float,float,float,float,float)}.
         */
        public void matrix(float a, float b, float c, float d, float e, float f)
                throws ParseException {
            SVGTransformItem item  = new SVGTransformItem();
            item.matrix(a, b, c, d, e, f);
            listHandler.item(item);
        }

        /**
         * Implements {@link TransformListHandler#rotate(float)}.
         */
        public void rotate(float theta) throws ParseException {
            SVGTransformItem item = new SVGTransformItem();
            item.rotate(theta);
            listHandler.item(item);
        }

        /**
         * Implements {@link TransformListHandler#rotate(float,float,float)}.
         */
        public void rotate(float theta, float cx, float cy)
                throws ParseException {
            SVGTransformItem item = new SVGTransformItem();
            item.setRotate(theta, cx, cy);
            listHandler.item(item);
        }

        /**
         * Implements {@link TransformListHandler#translate(float)}.
         */
        public void translate(float tx) throws ParseException {
            SVGTransformItem item = new SVGTransformItem();
            item.translate(tx);
            listHandler.item(item);
        }

        /**
         * Implements {@link TransformListHandler#translate(float,float)}.
         */
        public void translate(float tx, float ty) throws ParseException {
            SVGTransformItem item = new SVGTransformItem();
            item.setTranslate(tx, ty);
            listHandler.item(item);
        }

        /**
         * Implements {@link TransformListHandler#scale(float)}.
         */
        public void scale(float sx) throws ParseException {
            SVGTransformItem item  = new SVGTransformItem();
            item.scale(sx);
            listHandler.item(item);
        }

        /**
         * Implements {@link TransformListHandler#scale(float,float)}.
         */
        public void scale(float sx, float sy) throws ParseException {
            SVGTransformItem item = new SVGTransformItem();
            item.setScale(sx, sy);
            listHandler.item(item);
        }

        /**
         * Implements {@link TransformListHandler#skewX(float)}.
         */
        public void skewX(float skx) throws ParseException {
            SVGTransformItem item = new SVGTransformItem();
            item.setSkewX(skx);
            listHandler.item(item);
        }

        /**
         * Implements {@link TransformListHandler#skewY(float)}.
         */
        public void skewY(float sky) throws ParseException {
            SVGTransformItem item  = new SVGTransformItem();
            item.setSkewY(sky);
            listHandler.item(item);
        }

        /**
         * Implements {@link TransformListHandler#endTransformList()}.
         */
        public void endTransformList() throws ParseException {
            listHandler.endList();
        }
    }
}
