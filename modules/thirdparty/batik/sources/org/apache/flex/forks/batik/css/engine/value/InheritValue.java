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
package org.apache.flex.forks.batik.css.engine.value;

import org.w3c.dom.css.CSSValue;

/**
 * This singleton class represents the 'inherit' value.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: InheritValue.java,v 1.4 2004/08/18 07:12:53 vhardy Exp $
 */
public class InheritValue extends AbstractValue {
    /**
     * The only instance of this class.
     */
    public final static InheritValue INSTANCE = new InheritValue();
    
    /**
     * Creates a new InheritValue object.
     */
    protected InheritValue() {
    }

    /**
     *  A string representation of the current value. 
     */
    public String getCssText() {
	return "inherit";
    }

    /**
     * A code defining the type of the value. 
     */
    public short getCssValueType() {
	return CSSValue.CSS_INHERIT;
    }

    /**
     * Returns a printable representation of this object.
     */
    public String toString() {
        return getCssText();
    }
}
