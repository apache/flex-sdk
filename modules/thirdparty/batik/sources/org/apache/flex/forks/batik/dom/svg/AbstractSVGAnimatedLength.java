/*

   Copyright 2002-2003  The Apache Software Foundation 

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

import org.apache.flex.forks.batik.parser.UnitProcessor;
import org.w3c.dom.Attr;
import org.w3c.flex.forks.dom.svg.SVGAnimatedLength;
import org.w3c.flex.forks.dom.svg.SVGLength;

/**
 * This class provides an implementation of the {@link
 * SVGAnimatedLength} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractSVGAnimatedLength.java,v 1.8 2004/08/18 07:13:13 vhardy Exp $
 */
public abstract class AbstractSVGAnimatedLength
    implements SVGAnimatedLength,
               LiveAttributeValue {

    /**
     * This constant represents horizontal lengths.
     */
    public final static short HORIZONTAL_LENGTH =
        UnitProcessor.HORIZONTAL_LENGTH;

    /**
     * This constant represents vertical lengths.
     */
    public final static short VERTICAL_LENGTH =
        UnitProcessor.VERTICAL_LENGTH;

    /**
     * This constant represents other lengths.
     */
    public final static short OTHER_LENGTH =
        UnitProcessor.OTHER_LENGTH;

    /**
     * The associated element.
     */
    protected AbstractElement element;

    /**
     * The attribute's namespace URI.
     */
    protected String namespaceURI;

    /**
     * The attribute's local name.
     */
    protected String localName;

    /**
     * This length's direction.
     */
    protected short direction;

    /**
     * The base value.
     */
    protected BaseSVGLength baseVal;

    /**
     * Whether the value is changing.
     */
    protected boolean changing;

    /**
     * Creates a new SVGAnimatedLength.
     * @param elt The associated element.
     * @param ns The attribute's namespace URI.
     * @param ln The attribute's local name.
     * @param dir The length's direction.
     */
    protected AbstractSVGAnimatedLength(AbstractElement elt,
                                        String ns,
                                        String ln,
                                        short dir) {
        element = elt;
        namespaceURI = ns;
        localName = ln;
        direction = dir;
    }

    /**
     * Returns the default value to use when the associated attribute
     * was not specified.
     */
    protected abstract String getDefaultValue();

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedLength#getBaseVal()}.
     */
    public SVGLength getBaseVal() {
        if (baseVal == null) {
            baseVal = new BaseSVGLength(direction);
        }
        return baseVal;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedLength#getAnimVal()}.
     */
    public SVGLength getAnimVal() {
        throw new RuntimeException("!!! TODO: getAnimVal()");
    }

    /**
     * Called when an Attr node has been added.
     */
    public void attrAdded(Attr node, String newv) {
        if (!changing && baseVal != null) {
            baseVal.invalidate();
        }
    }

    /**
     * Called when an Attr node has been modified.
     */
    public void attrModified(Attr node, String oldv, String newv) {
        if (!changing && baseVal != null) {
            baseVal.invalidate();
        }
    }

    /**
     * Called when an Attr node has been removed.
     */
    public void attrRemoved(Attr node, String oldv) {
        if (!changing && baseVal != null) {
            baseVal.invalidate();
        }
    }

    /**
     * This class represents the SVGLength returned by getBaseVal().
     */
    protected class BaseSVGLength extends AbstractSVGLength {

        /**
         * Whether this length is valid.
         */
        protected boolean valid;
        
        /**
         * Creates a new BaseSVGLength.
         */
        public BaseSVGLength(short direction) {
            super(direction);
        }

        /**
         * Invalidates this length.
         */
        public void invalidate() {
            valid = false;
        }

        /**
         * Resets the value of the associated attribute.
         */
        protected void reset() {
            try {
                changing = true;
                String value = getValueAsString();
                element.setAttributeNS(namespaceURI, localName, value);
            } finally {
                changing = false;
            }
        }

        /**
         * Initializes the length, if needed.
         */
        protected void revalidate() {
            if (valid) {
                return;
            }

            String s = null;

            Attr attr = element.getAttributeNodeNS(namespaceURI, localName);

            if (attr == null) {
                s = getDefaultValue();
            }
            else{
                s = attr.getValue();
            }

            parse(s);

            valid = true;
        }

        /**
         */
        protected SVGOMElement getAssociatedElement(){
            return (SVGOMElement)element;
        }
    }
}
