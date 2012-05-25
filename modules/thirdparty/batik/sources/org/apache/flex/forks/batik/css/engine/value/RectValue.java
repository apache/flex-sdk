/*

   Copyright 2002  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.css.engine.value;

import org.w3c.dom.DOMException;
import org.w3c.dom.css.CSSPrimitiveValue;

/**
 * This class represents CSS rect values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: RectValue.java,v 1.3 2004/08/18 07:12:53 vhardy Exp $
 */
public class RectValue extends AbstractValue {
    
    /**
     * The top value.
     */
    protected Value top;

    /**
     * The right value.
     */
    protected Value right;

    /**
     * The bottom value.
     */
    protected Value bottom;

    /**
     * The left value.
     */
    protected Value left;

    /**
     * Creates a new Rect value.
     */
    public RectValue(Value t, Value r, Value b, Value l) {
	top = t;
	right = r;
	bottom = b;
	left = l;
    }

    /**
     * The type of the value.
     */
    public short getPrimitiveType() {
        return CSSPrimitiveValue.CSS_RECT;
    }

    /**
     *  A string representation of the current value. 
     */
    public String getCssText() {
	return "rect(" + top.getCssText() + ", "
	    +  right.getCssText() + ", "
	    +  bottom.getCssText() + ", "
	    +  left.getCssText() + ")";
    }

    /**
     * Implements {@link Value#getTop()}.
     */
    public Value getTop() throws DOMException {
        return top;
    }

    /**
     * Implements {@link Value#getRight()}.
     */
    public Value getRight() throws DOMException {
        return right;
    }

    /**
     * Implements {@link Value#getBottom()}.
     */
    public Value getBottom() throws DOMException {
        return bottom;
    }

    /**
     * Implements {@link Value#getLeft()}.
     */
    public Value getLeft() throws DOMException {
        return left;
    }

    /**
     * Returns a printable representation of this value.
     */
    public String toString() {
        return getCssText();
    }
}
