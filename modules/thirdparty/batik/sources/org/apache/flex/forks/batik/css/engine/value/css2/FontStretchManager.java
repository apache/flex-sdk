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
package org.apache.flex.forks.batik.css.engine.value.css2;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.apache.flex.forks.batik.css.engine.StyleMap;
import org.apache.flex.forks.batik.css.engine.value.IdentifierManager;
import org.apache.flex.forks.batik.css.engine.value.StringMap;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.ValueConstants;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.util.CSSConstants;

/**
 * This class provides a manager for the 'font-stretch' property values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: FontStretchManager.java,v 1.8 2005/03/27 08:58:31 cam Exp $
 */
public class FontStretchManager extends IdentifierManager {
    
    /**
     * The identifier values.
     */
    protected final static StringMap values = new StringMap();
    static {
	values.put(CSSConstants.CSS_ALL_VALUE,
                   ValueConstants.ALL_VALUE);
	values.put(CSSConstants.CSS_CONDENSED_VALUE,
                   ValueConstants.CONDENSED_VALUE);
	values.put(CSSConstants.CSS_EXPANDED_VALUE,
                   ValueConstants.EXPANDED_VALUE);
	values.put(CSSConstants.CSS_EXTRA_CONDENSED_VALUE,
                   ValueConstants.EXTRA_CONDENSED_VALUE);
	values.put(CSSConstants.CSS_EXTRA_EXPANDED_VALUE,
                   ValueConstants.EXTRA_EXPANDED_VALUE);
	values.put(CSSConstants.CSS_NARROWER_VALUE,
                   ValueConstants.NARROWER_VALUE);
	values.put(CSSConstants.CSS_NORMAL_VALUE,
                   ValueConstants.NORMAL_VALUE);
	values.put(CSSConstants.CSS_SEMI_CONDENSED_VALUE,
                   ValueConstants.SEMI_CONDENSED_VALUE);
	values.put(CSSConstants.CSS_SEMI_EXPANDED_VALUE,
                   ValueConstants.SEMI_EXPANDED_VALUE);
	values.put(CSSConstants.CSS_ULTRA_CONDENSED_VALUE,
                   ValueConstants.ULTRA_CONDENSED_VALUE);
	values.put(CSSConstants.CSS_ULTRA_EXPANDED_VALUE,
                   ValueConstants.ULTRA_EXPANDED_VALUE);
	values.put(CSSConstants.CSS_WIDER_VALUE,
                   ValueConstants.WIDER_VALUE);
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#isInheritedProperty()}.
     */
    public boolean isInheritedProperty() {
	return true;
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#getPropertyName()}.
     */
    public String getPropertyName() {
	return CSSConstants.CSS_FONT_STRETCH_PROPERTY;
    }
    
    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#getDefaultValue()}.
     */
    public Value getDefaultValue() {
        return ValueConstants.NORMAL_VALUE;
    }

    /**
     * Implements {@link
     * ValueManager#computeValue(CSSStylableElement,String,CSSEngine,int,StyleMap,Value)}.
     */
    public Value computeValue(CSSStylableElement elt,
                              String pseudo,
                              CSSEngine engine,
                              int idx,
                              StyleMap sm,
                              Value value) { 
        if (value == ValueConstants.NARROWER_VALUE) {
            sm.putParentRelative(idx, true);

            CSSStylableElement p = CSSEngine.getParentCSSStylableElement(elt);
            if (p == null) {
                return ValueConstants.SEMI_CONDENSED_VALUE;
            }
            Value v = engine.getComputedStyle(p, pseudo, idx);
            if (v == ValueConstants.NORMAL_VALUE) {
                return ValueConstants.SEMI_CONDENSED_VALUE;
            }
            if (v == ValueConstants.CONDENSED_VALUE) {
                return ValueConstants.EXTRA_CONDENSED_VALUE;
            }
            if (v == ValueConstants.EXPANDED_VALUE) {
                return ValueConstants.SEMI_EXPANDED_VALUE;
            }
            if (v == ValueConstants.SEMI_EXPANDED_VALUE) {
                return ValueConstants.NORMAL_VALUE;
            }
            if (v == ValueConstants.SEMI_CONDENSED_VALUE) {
                return ValueConstants.CONDENSED_VALUE;
            }
            if (v == ValueConstants.EXTRA_CONDENSED_VALUE) {
                return ValueConstants.ULTRA_CONDENSED_VALUE;
            }
            if (v == ValueConstants.EXTRA_EXPANDED_VALUE) {
                return ValueConstants.EXPANDED_VALUE;
            }
            if (v == ValueConstants.ULTRA_CONDENSED_VALUE) {
                return ValueConstants.ULTRA_CONDENSED_VALUE;
            }
            return ValueConstants.EXTRA_EXPANDED_VALUE;
        } else if (value == ValueConstants.WIDER_VALUE) {
            sm.putParentRelative(idx, true);

            CSSStylableElement p = CSSEngine.getParentCSSStylableElement(elt);
            if (p == null) {
                return ValueConstants.SEMI_CONDENSED_VALUE;
            }
            Value v = engine.getComputedStyle(p, pseudo, idx);
            if (v == ValueConstants.NORMAL_VALUE) {
                return ValueConstants.SEMI_EXPANDED_VALUE;
            }
            if (v == ValueConstants.CONDENSED_VALUE) {
                return ValueConstants.SEMI_CONDENSED_VALUE;
            }
            if (v == ValueConstants.EXPANDED_VALUE) {
                return ValueConstants.EXTRA_EXPANDED_VALUE;
            }
            if (v == ValueConstants.SEMI_EXPANDED_VALUE) {
                return ValueConstants.EXPANDED_VALUE;
            }
            if (v == ValueConstants.SEMI_CONDENSED_VALUE) {
                return ValueConstants.NORMAL_VALUE;
            }
            if (v == ValueConstants.EXTRA_CONDENSED_VALUE) {
                return ValueConstants.CONDENSED_VALUE;
            }
            if (v == ValueConstants.EXTRA_EXPANDED_VALUE) {
                return ValueConstants.ULTRA_EXPANDED_VALUE;
            }
            if (v == ValueConstants.ULTRA_CONDENSED_VALUE) {
                return ValueConstants.EXTRA_CONDENSED_VALUE;
            }
            return ValueConstants.ULTRA_EXPANDED_VALUE;
        }
        return value;
    }

    /**
     * Implements {@link IdentifierManager#getIdentifiers()}.
     */
    public StringMap getIdentifiers() {
        return values;
    }
}
