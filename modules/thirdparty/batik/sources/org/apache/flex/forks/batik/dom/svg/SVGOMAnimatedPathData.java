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

import java.util.ArrayList;
import java.util.Iterator;

import org.apache.flex.forks.batik.anim.values.AnimatablePathDataValue;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.dom.anim.AnimationTarget;

import org.apache.flex.forks.batik.parser.ParseException;
import org.apache.flex.forks.batik.parser.PathArrayProducer;

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.svg.SVGAnimatedPathData;
import org.w3c.dom.svg.SVGException;
import org.w3c.dom.svg.SVGPathSeg;
import org.w3c.dom.svg.SVGPathSegList;

/**
 * This class is the implementation of the {@link SVGAnimatedPathData}
 * interface.
 *
 * @author <a href="mailto:nicolas.socheleau@bitflash.com">Nicolas Socheleau</a>
 * @author <a href="mailto:andrest@world-affair.com">Andres Toussaint</a>
 * @version $Id: SVGOMAnimatedPathData.java 527382 2007-04-11 04:31:58Z cam $
 */
public class SVGOMAnimatedPathData
    extends AbstractSVGAnimatedValue
    implements SVGAnimatedPathData {

    /**
     * Whether the list is changing.
     */
    protected boolean changing;

    /**
     * The base path data value.
     */
    protected BaseSVGPathSegList pathSegs;

    /**
     * The normalized base path data value.
     */
    protected NormalizedBaseSVGPathSegList normalizedPathSegs;

    /**
     * The animated path data value.
     */
    protected AnimSVGPathSegList animPathSegs;

//     /**
//      * The normalized animated base path data value.
//      */
//     protected NormalizedAnimSVGPathSegList normalizedPathSegs;

    /**
     * Default value for the 'd' attribute.
     */
    protected String defaultValue;

    /**
     * Creates a new SVGOMAnimatedPathData.
     * @param elt The associated element.
     * @param ns The attribute's namespace URI.
     * @param ln The attribute's local name.
     * @param defaultValue The default value if the attribute is not specified.
     */
    public SVGOMAnimatedPathData(AbstractElement elt,
                                 String ns,
                                 String ln,
                                 String defaultValue) {
        super(elt, ns, ln);
        this.defaultValue = defaultValue;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGAnimatedPathData#getAnimatedNormalizedPathSegList()}.
     */
    public SVGPathSegList getAnimatedNormalizedPathSegList() {
        throw new UnsupportedOperationException
            ("SVGAnimatedPathData.getAnimatedNormalizedPathSegList is not implemented"); // XXX
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGAnimatedPathData#getAnimatedPathSegList()}.
     */
    public SVGPathSegList getAnimatedPathSegList() {
        if (animPathSegs == null) {
            animPathSegs = new AnimSVGPathSegList();
        }
        return animPathSegs;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGAnimatedPathData#getNormalizedPathSegList()}.
     * <p>
     *   Returns the SVGPathSegList mapping the normalized static 'd' attribute
     *   of the element.
     * </p>
     * <p>
     *   A normalized path is composed only of absolute moveto, lineto and
     *   cubicto path segments (M, L and C). Using this subset, the path
     *   description can be represented with fewer segment types. Be aware that
     *   the normalized 'd' attribute will be a larger String that the original.
     * </p>
     * <p>
     *   Relative values are transformed into absolute, quadratic curves are
     *   promoted to cubic curves, and arcs are converted into one or more
     *   cubic curves (one per quadrant).
     * </p>
     * <p>
     *   Modifications to the normalized SVGPathSegList will result
     *   in substituting the original path with a set of normalized path
     *   segments.
     * </p>
     * @return a path segment list containing the normalized version of the path.
     */
    public SVGPathSegList getNormalizedPathSegList() {
        if (normalizedPathSegs == null) {
            normalizedPathSegs = new NormalizedBaseSVGPathSegList();
        }
        return normalizedPathSegs;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGAnimatedPathData#getPathSegList()}.
     */
    public SVGPathSegList getPathSegList() {
        if (pathSegs == null) {
            pathSegs = new BaseSVGPathSegList();
        }
        return pathSegs;
    }

    /**
     * Throws an exception if the path data is malformed.
     */
    public void check() {
        if (!hasAnimVal) {
            if (pathSegs == null) {
                pathSegs = new BaseSVGPathSegList();
            }
            pathSegs.revalidate();
            if (pathSegs.missing) {
                throw new LiveAttributeException
                    (element, localName,
                     LiveAttributeException.ERR_ATTRIBUTE_MISSING, null);
            }
            if (pathSegs.malformed) {
                throw new LiveAttributeException
                    (element, localName,
                     LiveAttributeException.ERR_ATTRIBUTE_MALFORMED,
                     pathSegs.getValueAsString());
            }
        }
    }

    /**
     * Returns the base value of the attribute as an {@link AnimatableValue}.
     */
    public AnimatableValue getUnderlyingValue(AnimationTarget target) {
        SVGPathSegList psl = getPathSegList();
        PathArrayProducer pp = new PathArrayProducer();
        SVGAnimatedPathDataSupport.handlePathSegList(psl, pp);
        return new AnimatablePathDataValue(target, pp.getPathCommands(),
                                           pp.getPathParameters());
    }

    /**
     * Updates the animated value with the given {@link AnimatableValue}.
     */
    protected void updateAnimatedValue(AnimatableValue val) {
        if (val == null) {
            hasAnimVal = false;
        } else {
            hasAnimVal = true;
            AnimatablePathDataValue animPath = (AnimatablePathDataValue) val;
            if (animPathSegs == null) {
                animPathSegs = new AnimSVGPathSegList();
            }
            animPathSegs.setAnimatedValue(animPath.getCommands(),
                                          animPath.getParameters());
        }
        fireAnimatedAttributeListeners();
    }

    /**
     * Called when an Attr node has been added.
     */
    public void attrAdded(Attr node, String newv) {
        if (!changing) {
            if (pathSegs != null) {
                pathSegs.invalidate();
            }
            if (normalizedPathSegs != null) {
                normalizedPathSegs.invalidate();
            }
        }
        fireBaseAttributeListeners();
        if (!hasAnimVal) {
            fireAnimatedAttributeListeners();
        }
    }

    /**
     * Called when an Attr node has been modified.
     */
    public void attrModified(Attr node, String oldv, String newv) {
        if (!changing) {
            if (pathSegs != null) {
                pathSegs.invalidate();
            }
            if (normalizedPathSegs != null) {
                normalizedPathSegs.invalidate();
            }
        }
        fireBaseAttributeListeners();
        if (!hasAnimVal) {
            fireAnimatedAttributeListeners();
        }
    }

    /**
     * Called when an Attr node has been removed.
     */
    public void attrRemoved(Attr node, String oldv) {
        if (!changing) {
            if (pathSegs != null) {
                pathSegs.invalidate();
            }
            if (normalizedPathSegs != null) {
                normalizedPathSegs.invalidate();
            }
        }
        fireBaseAttributeListeners();
        if (!hasAnimVal) {
            fireAnimatedAttributeListeners();
        }
    }

    /**
     * {@link SVGPathSegList} implementation for the base path data value.
     */
    public class BaseSVGPathSegList extends AbstractSVGPathSegList {

        /**
         * Whether the attribute is missing.
         */
        protected boolean missing;

        /**
         * Whether the attribute is malformed.
         */
        protected boolean malformed;

        /**
         * Create a DOMException.
         */
        protected DOMException createDOMException(short type, String key,
                                                  Object[] args) {
            return element.createDOMException(type, key, args);
        }

        /**
         * Create a SVGException.
         */
        protected SVGException createSVGException(short type, String key,
                                                  Object[] args) {
            return ((SVGOMElement)element).createSVGException(type, key, args);
        }

        /**
         * Returns the value of the DOM attribute containing the path data.
         */
        protected String getValueAsString() {
            Attr attr = element.getAttributeNodeNS(namespaceURI, localName);
            if (attr == null) {
                return defaultValue;
            }
            return attr.getValue();
        }

        /**
         * Sets the DOM attribute value containing the path data.
         */
        protected void setAttributeValue(String value) {
            try {
                changing = true;
                element.setAttributeNS(namespaceURI, localName, value);
            } finally {
                changing = false;
            }
        }

        /**
         * Resets the value of the associated attribute.
         */
        protected void resetAttribute() {
            super.resetAttribute();
            missing = false;
            malformed = false;
        }

        /**
         * Appends the string representation of the given {@link SVGItem} to
         * the DOM attribute.  This is called in response to an append to
         * the list.
         */
        protected void resetAttribute(SVGItem item) {
            super.resetAttribute(item);
            missing = false;
            malformed = false;
        }

        /**
         * Initializes the list, if needed.
         */
        protected void revalidate() {
            if (valid) {
                return;
            }

            valid = true;
            missing = false;
            malformed = false;

            String s = getValueAsString();
            if (s == null) {
                missing = true;
                return;
            }
            try {
                ListBuilder builder = new ListBuilder();

                doParse(s, builder);

                if (builder.getList() != null) {
                    clear(itemList);
                }
                itemList = builder.getList();
            } catch (ParseException e) {
                itemList = new ArrayList(1);
                malformed = true;
            }
        }
    }

    /**
     * {@link SVGPathSegList} implementation for the normalized version of the
     * base path data value.
     */
    public class NormalizedBaseSVGPathSegList
            extends AbstractSVGNormPathSegList {

        /**
         * Whether the attribute is missing.
         */
        protected boolean missing;

        /**
         * Whether the attribute is malformed.
         */
        protected boolean malformed;

        /**
         * Create a DOMException.
         */
        protected DOMException createDOMException(short type, String key,
                                                  Object[] args) {
            return element.createDOMException(type, key, args);
        }

        /**
         * Create a SVGException.
         */
        protected SVGException createSVGException(short type, String key,
                                                  Object[] args) {
            return ((SVGOMElement)element).createSVGException(type, key, args);
        }

        /**
         * Returns the value of the DOM attribute containing the path data.
         */
        protected String getValueAsString() throws SVGException {
            Attr attr = element.getAttributeNodeNS(namespaceURI, localName);
            if (attr == null) {
                return defaultValue;
            }
            return attr.getValue();
        }

        /**
         * Sets the DOM attribute value containing the path data.
         */
        protected void setAttributeValue(String value) {
            try {
                changing = true;
                element.setAttributeNS(namespaceURI, localName, value);
            } finally {
                changing = false;
            }
        }

        /**
         * Initializes the list, if needed.
         */
        protected void revalidate() {
            if (valid) {
                return;
            }

            valid = true;
            missing = false;
            malformed = false;

            String s = getValueAsString();
            if (s == null) {
                missing = true;
                return;
            }
            try {
                ListBuilder builder = new ListBuilder();

                doParse(s, builder);

                if (builder.getList() != null) {
                    clear(itemList);
                }
                itemList = builder.getList();
            } catch (ParseException e) {
                itemList = new ArrayList(1);
                malformed = true;
            }
        }
    }

    /**
     * {@link SVGPathSegList} implementation for the animated path data value.
     */
    public class AnimSVGPathSegList extends AbstractSVGPathSegList {

        /**
         * Creates a new AnimSVGPathSegList.
         */
        public AnimSVGPathSegList() {
            itemList = new ArrayList(1);
        }

        /**
         * Create a DOMException.
         */
        protected DOMException createDOMException(short type, String key,
                                                  Object[] args) {
            return element.createDOMException(type, key, args);
        }

        /**
         * Create a SVGException.
         */
        protected SVGException createSVGException(short type, String key,
                                                  Object[] args) {
            return ((SVGOMElement)element).createSVGException(type, key, args);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGPathSegList#getNumberOfItems()}.
         */
        public int getNumberOfItems() {
            if (hasAnimVal) {
                return super.getNumberOfItems();
            }
            return getPathSegList().getNumberOfItems();
        }

        /**
         * <b>DOM</b>: Implements {@link SVGPathSegList#getItem(int)}.
         */
        public SVGPathSeg getItem(int index) throws DOMException {
            if (hasAnimVal) {
                return super.getItem(index);
            }
            return getPathSegList().getItem(index);
        }

        /**
         * Returns the value of the DOM attribute containing the point list.
         */
        protected String getValueAsString() {
            if (itemList.size() == 0) {
                return "";
            }
            StringBuffer sb = new StringBuffer( itemList.size() * 8 );
            Iterator i = itemList.iterator();
            if (i.hasNext()) {
                sb.append(((SVGItem) i.next()).getValueAsString());
            }
            while (i.hasNext()) {
                sb.append(getItemSeparator());
                sb.append(((SVGItem) i.next()).getValueAsString());
            }
            return sb.toString();
        }

        /**
         * Sets the DOM attribute value containing the point list.
         */
        protected void setAttributeValue(String value) {
        }

        /**
         * <b>DOM</b>: Implements {@link SVGPathSegList#clear()}.
         */
        public void clear() throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.pathseg.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGPathSegList#initialize(SVGPathSeg)}.
         */
        public SVGPathSeg initialize(SVGPathSeg newItem)
                throws DOMException, SVGException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.pathseg.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link
         * SVGPathSegList#insertItemBefore(SVGPathSeg, int)}.
         */
        public SVGPathSeg insertItemBefore(SVGPathSeg newItem, int index)
                throws DOMException, SVGException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.pathseg.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link
         * SVGPathSegList#replaceItem(SVGPathSeg, int)}.
         */
        public SVGPathSeg replaceItem(SVGPathSeg newItem, int index)
                throws DOMException, SVGException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.pathseg.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGPathSegList#removeItem(int)}.
         */
        public SVGPathSeg removeItem(int index) throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.pathseg.list", null);
        }

        /**
         * <b>DOM</b>: Implements {@link SVGPathSegList#appendItem(SVGPathSeg)}.
         */
        public SVGPathSeg appendItem(SVGPathSeg newItem) throws DOMException {
            throw element.createDOMException
                (DOMException.NO_MODIFICATION_ALLOWED_ERR,
                 "readonly.pathseg.list", null);
        }

        /**
         * Pass by reference integer for use by newItem.
         */
        private int[] parameterIndex = new int[1];

        /**
         * Creates a new SVGPathSegItem from the given path command and array
         * of parameter values.
         */
        protected SVGPathSegItem newItem(short command, float[] parameters,
                                         int[] j) {
            switch (command) {
                case SVGPathSeg.PATHSEG_ARC_ABS:
                case SVGPathSeg.PATHSEG_ARC_REL:
                    return new SVGPathSegArcItem
                        (command, PATHSEG_LETTERS[command],
                         parameters[j[0]++],
                         parameters[j[0]++],
                         parameters[j[0]++],
                         parameters[j[0]++] != 0,
                         parameters[j[0]++] != 0,
                         parameters[j[0]++],
                         parameters[j[0]++]);
                case SVGPathSeg.PATHSEG_CLOSEPATH:
                    return new SVGPathSegItem
                        (command, PATHSEG_LETTERS[command]);
                case SVGPathSeg.PATHSEG_CURVETO_CUBIC_ABS:
                case SVGPathSeg.PATHSEG_CURVETO_CUBIC_REL:
                    return new SVGPathSegCurvetoCubicItem
                        (command, PATHSEG_LETTERS[command],
                         parameters[j[0]++],
                         parameters[j[0]++],
                         parameters[j[0]++],
                         parameters[j[0]++],
                         parameters[j[0]++],
                         parameters[j[0]++]);
                case SVGPathSeg.PATHSEG_CURVETO_CUBIC_SMOOTH_ABS:
                case SVGPathSeg.PATHSEG_CURVETO_CUBIC_SMOOTH_REL:
                    return new SVGPathSegCurvetoCubicSmoothItem
                        (command, PATHSEG_LETTERS[command],
                         parameters[j[0]++],
                         parameters[j[0]++],
                         parameters[j[0]++],
                         parameters[j[0]++]);
                case SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_ABS:
                case SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_REL:
                    return new SVGPathSegCurvetoQuadraticItem
                        (command, PATHSEG_LETTERS[command],
                         parameters[j[0]++],
                         parameters[j[0]++],
                         parameters[j[0]++],
                         parameters[j[0]++]);
                case SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_SMOOTH_ABS:
                case SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_SMOOTH_REL:
                    return new SVGPathSegCurvetoQuadraticSmoothItem
                        (command, PATHSEG_LETTERS[command],
                         parameters[j[0]++],
                         parameters[j[0]++]);
                case SVGPathSeg.PATHSEG_LINETO_ABS:
                case SVGPathSeg.PATHSEG_LINETO_REL:
                case SVGPathSeg.PATHSEG_MOVETO_ABS:
                case SVGPathSeg.PATHSEG_MOVETO_REL:
                    return new SVGPathSegMovetoLinetoItem
                        (command, PATHSEG_LETTERS[command],
                         parameters[j[0]++],
                         parameters[j[0]++]);
                case SVGPathSeg.PATHSEG_LINETO_HORIZONTAL_REL:
                case SVGPathSeg.PATHSEG_LINETO_HORIZONTAL_ABS:
                    return new SVGPathSegLinetoHorizontalItem
                        (command, PATHSEG_LETTERS[command],
                         parameters[j[0]++]);
                case SVGPathSeg.PATHSEG_LINETO_VERTICAL_REL:
                case SVGPathSeg.PATHSEG_LINETO_VERTICAL_ABS:
                    return new SVGPathSegLinetoVerticalItem
                        (command, PATHSEG_LETTERS[command],
                         parameters[j[0]++]);
            }
            return null;
        }

        /**
         * Sets the animated value.
         */
        protected void setAnimatedValue(short[] commands, float[] parameters) {
            int size = itemList.size();
            int i = 0;
            int[] j = parameterIndex;
            j[0] = 0;
            while (i < size && i < commands.length) {
                SVGPathSeg s = (SVGPathSeg) itemList.get(i);
                if (s.getPathSegType() != commands[i]) {
                    s = newItem(commands[i], parameters, j);
                } else {
                    switch (commands[i]) {
                        case SVGPathSeg.PATHSEG_ARC_ABS:
                        case SVGPathSeg.PATHSEG_ARC_REL: {
                            SVGPathSegArcItem ps = (SVGPathSegArcItem) s;
                            ps.r1 = parameters[j[0]++];
                            ps.r2 = parameters[j[0]++];
                            ps.angle = parameters[j[0]++];
                            ps.largeArcFlag = parameters[j[0]++] != 0;
                            ps.sweepFlag = parameters[j[0]++] != 0;
                            ps.x = parameters[j[0]++];
                            ps.y = parameters[j[0]++];
                            break;
                        }
                        case SVGPathSeg.PATHSEG_CLOSEPATH:
                            // Nothing to update.
                            break;
                        case SVGPathSeg.PATHSEG_CURVETO_CUBIC_ABS:
                        case SVGPathSeg.PATHSEG_CURVETO_CUBIC_REL: {
                            SVGPathSegCurvetoCubicItem ps =
                                (SVGPathSegCurvetoCubicItem) s;
                            ps.x1 = parameters[j[0]++];
                            ps.y1 = parameters[j[0]++];
                            ps.x2 = parameters[j[0]++];
                            ps.y2 = parameters[j[0]++];
                            ps.x = parameters[j[0]++];
                            ps.y = parameters[j[0]++];
                            break;
                        }
                        case SVGPathSeg.PATHSEG_CURVETO_CUBIC_SMOOTH_ABS:
                        case SVGPathSeg.PATHSEG_CURVETO_CUBIC_SMOOTH_REL: {
                            SVGPathSegCurvetoCubicSmoothItem ps =
                                (SVGPathSegCurvetoCubicSmoothItem) s;
                            ps.x2 = parameters[j[0]++];
                            ps.y2 = parameters[j[0]++];
                            ps.x = parameters[j[0]++];
                            ps.y = parameters[j[0]++];
                            break;
                        }
                        case SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_ABS:
                        case SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_REL: {
                            SVGPathSegCurvetoQuadraticItem ps =
                                (SVGPathSegCurvetoQuadraticItem) s;
                            ps.x1 = parameters[j[0]++];
                            ps.y1 = parameters[j[0]++];
                            ps.x = parameters[j[0]++];
                            ps.y = parameters[j[0]++];
                            break;
                        }
                        case SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_SMOOTH_ABS:
                        case SVGPathSeg.PATHSEG_CURVETO_QUADRATIC_SMOOTH_REL: {
                            SVGPathSegCurvetoQuadraticSmoothItem ps =
                                (SVGPathSegCurvetoQuadraticSmoothItem) s;
                            ps.x = parameters[j[0]++];
                            ps.y = parameters[j[0]++];
                            break;
                        }
                        case SVGPathSeg.PATHSEG_LINETO_ABS:
                        case SVGPathSeg.PATHSEG_LINETO_REL:
                        case SVGPathSeg.PATHSEG_MOVETO_ABS:
                        case SVGPathSeg.PATHSEG_MOVETO_REL: {
                            SVGPathSegMovetoLinetoItem ps =
                                (SVGPathSegMovetoLinetoItem) s;
                            ps.x = parameters[j[0]++];
                            ps.y = parameters[j[0]++];
                            break;
                        }
                        case SVGPathSeg.PATHSEG_LINETO_HORIZONTAL_REL:
                        case SVGPathSeg.PATHSEG_LINETO_HORIZONTAL_ABS: {
                            SVGPathSegLinetoHorizontalItem ps =
                                (SVGPathSegLinetoHorizontalItem) s;
                            ps.x = parameters[j[0]++];
                            break;
                        }
                        case SVGPathSeg.PATHSEG_LINETO_VERTICAL_REL:
                        case SVGPathSeg.PATHSEG_LINETO_VERTICAL_ABS: {
                            SVGPathSegLinetoVerticalItem ps =
                                (SVGPathSegLinetoVerticalItem) s;
                            ps.y = parameters[j[0]++];
                            break;
                        }
                    }
                }
                i++;
            }
            while (i < commands.length) {
                appendItemImpl(newItem(commands[i], parameters, j));
                i++;
            }
            while (size > commands.length) {
                removeItemImpl(--size);
            }
        }

        /**
         * Resets the value of the associated attribute.  Does nothing, since
         * there is no attribute for an animated value.
         */
        protected void resetAttribute() {
        }

        /**
         * Resets the value of the associated attribute.  Does nothing, since
         * there is no attribute for an animated value.
         */
        protected void resetAttribute(SVGItem item) {
        }

        /**
         * Initializes the list, if needed.  Does nothing, since there is no
         * attribute to read the list from.
         */
        protected void revalidate() {
            valid = true;
        }
    }
}
