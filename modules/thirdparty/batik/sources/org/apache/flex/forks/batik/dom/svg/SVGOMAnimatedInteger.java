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

import org.apache.flex.forks.batik.anim.values.AnimatableIntegerValue;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.dom.anim.AnimationTarget;

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.svg.SVGAnimatedInteger;

/**
 * This class implements the {@link SVGAnimatedInteger} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMAnimatedInteger.java 490655 2006-12-28 05:19:44Z cam $
 */
public class SVGOMAnimatedInteger
        extends AbstractSVGAnimatedValue
        implements SVGAnimatedInteger {

    /**
     * The default value.
     */
    protected int defaultValue;

    /**
     * Whether the base value is valid.
     */
    protected boolean valid;

    /**
     * The current base value.
     */
    protected int baseVal;

    /**
     * The current animated value.
     */
    protected int animVal;

    /**
     * Whether the value is changing.
     */
    protected boolean changing;

    /**
     * Creates a new SVGOMAnimatedInteger.
     * @param elt The associated element.
     * @param ns The attribute's namespace URI.
     * @param ln The attribute's local name.
     * @param val The default value, if the attribute is not specified.
     */
    public SVGOMAnimatedInteger(AbstractElement elt,
                               String ns,
                               String ln,
                               int    val) {
        super(elt, ns, ln);
        defaultValue = val;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedInteger#getBaseVal()}.
     */
    public int getBaseVal() {
        if (!valid) {
            update();
        }
        return baseVal;
    }

    /**
     * Updates the base value from the attribute.
     */
    protected void update() {
        Attr attr = element.getAttributeNodeNS(namespaceURI, localName);
        if (attr == null) {
            baseVal = defaultValue;
        } else {
            baseVal = Integer.parseInt(attr.getValue());
        }
        valid = true;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedInteger#setBaseVal(int)}.
     */
    public void setBaseVal(int baseVal) throws DOMException {
        try {
            this.baseVal = baseVal;
            valid = true;
            changing = true;
            element.setAttributeNS(namespaceURI, localName,
                                   String.valueOf(baseVal));
        } finally {
            changing = false;
        }
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimatedInteger#getAnimVal()}.
     */
    public int getAnimVal() {
        if (hasAnimVal) {
            return animVal;
        }
        if (!valid) {
            update();
        }
        return baseVal;
    }

    /**
     * Returns the base value of the attribute as an {@link AnimatableValue}.
     */
    public AnimatableValue getUnderlyingValue(AnimationTarget target) {
        return new AnimatableIntegerValue(target, getBaseVal());
    }

    /**
     * Updates the animated value with the given {@link AnimatableValue}.
     */
    protected void updateAnimatedValue(AnimatableValue val) {
        if (val == null) {
            hasAnimVal = false;
        } else {
            hasAnimVal = true;
            this.animVal = ((AnimatableIntegerValue) val).getValue();
        }
        fireAnimatedAttributeListeners();
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
