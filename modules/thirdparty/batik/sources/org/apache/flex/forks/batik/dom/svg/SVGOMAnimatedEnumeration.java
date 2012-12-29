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

import org.apache.flex.forks.batik.anim.values.AnimatableStringValue;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.dom.anim.AnimationTarget;

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.svg.SVGAnimatedEnumeration;

/**
 * This class provides an implementation of the {@link
 * SVGAnimatedEnumeration} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMAnimatedEnumeration.java 527382 2007-04-11 04:31:58Z cam $
 */
public class SVGOMAnimatedEnumeration extends AbstractSVGAnimatedValue
                                      implements SVGAnimatedEnumeration {
    
    /**
     * The values in this enumeration.
     */
    protected String[] values;

    /**
     * The default value, if the attribute is not specified.
     */
    protected short defaultValue;

    /**
     * Whether the current base value is valid.
     */
    protected boolean valid;

    /**
     * The current base value.
     */
    protected short baseVal;

    /**
     * The current animated value.
     */
    protected short animVal;

    /**
     * Whether the value is changing.
     */
    protected boolean changing;

    /**
     * Creates a new SVGOMAnimatedEnumeration.
     * @param elt The associated element.
     * @param ns The attribute's namespace URI.
     * @param ln The attribute's local name.
     * @param val The values in this enumeration.
     * @param def The default value to use.
     */
    public SVGOMAnimatedEnumeration(AbstractElement elt,
                                    String ns,
                                    String ln,
                                    String[] val,
                                    short def) {
        super(elt, ns, ln);
        values = val;
        defaultValue = def;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedEnumeration#getBaseVal()}.
     */
    public short getBaseVal() {
        if (!valid) {
            update();
        }
        return baseVal;
    }

    /**
     * Returns the base value as a string.
     */
    public String getBaseValAsString() {
        if (!valid) {
            update();
        }
        return values[baseVal];
    }

    /**
     * Updates the base value from the attribute.
     */
    protected void update() {
        String val = element.getAttributeNS(namespaceURI, localName);
        if (val.length() == 0) {
            baseVal = defaultValue;
        } else {
            baseVal = getEnumerationNumber(val);
        }
        valid = true;
    }

    /**
     * Returns the enumeration number of the specified string.
     */
    protected short getEnumerationNumber(String s) {
        for (short i = 0; i < values.length; i++) {
            if (s.equals(values[i])) {
                return i;
            }
        }
        return 0;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * SVGAnimatedEnumeration#setBaseVal(short)}.
     */
    public void setBaseVal(short baseVal) throws DOMException {
        if (baseVal >= 0 && baseVal < values.length) {
            try {
                this.baseVal = baseVal;
                valid = true;
                changing = true;
                element.setAttributeNS(namespaceURI, localName,
                                       values[baseVal]);
            } finally {
                changing = false;
            }
        }
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedEnumeration#getAnimVal()}.
     */
    public short getAnimVal() {
        if (hasAnimVal) {
            return animVal;
        }
        if (!valid) {
            update();
        }
        return baseVal;
    }

    /**
     * Gets the current animated value, throwing an exception if the attribute
     * is malformed.
     */
    public short getCheckedVal() {
        if (hasAnimVal) {
            return animVal;
        }
        if (!valid) {
            update();
        }
        if (baseVal == 0) {
            throw new LiveAttributeException
                (element, localName,
                 LiveAttributeException.ERR_ATTRIBUTE_MALFORMED,
                 getBaseValAsString());
        }
        return baseVal;
    }

    /**
     * Returns the base value of the attribute as an {@link AnimatableValue}.
     */
    public AnimatableValue getUnderlyingValue(AnimationTarget target) {
        return new AnimatableStringValue(target, getBaseValAsString());
    }

    /**
     * Called when an Attr node has been added.
     */
    public void attrAdded(Attr node, String newv) {
        if (!changing) {
            valid = false;
        }
        fireBaseAttributeListeners();
        if (!hasAnimVal) {
            fireAnimatedAttributeListeners();
        }
    }

    /**
     * Updates the animated value with the given {@link AnimatableValue}.
     */
    protected void updateAnimatedValue(AnimatableValue val) {
        if (val == null) {
            hasAnimVal = false;
        } else {
            hasAnimVal = true;
            this.animVal =
                getEnumerationNumber(((AnimatableStringValue) val).getString());
            fireAnimatedAttributeListeners();
        }
        fireAnimatedAttributeListeners();
    }

    /**
     * Called when an Attr node has been modified.
     */
    public void attrModified(Attr node, String oldv, String newv) {
        if (!changing) {
            valid = false;
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
            valid = false;
        }
        fireBaseAttributeListeners();
        if (!hasAnimVal) {
            fireAnimatedAttributeListeners();
        }
    }
}
