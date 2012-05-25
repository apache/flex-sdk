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
import org.apache.flex.forks.batik.css.engine.value.AbstractValueManager;
import org.apache.flex.forks.batik.css.engine.value.ListValue;
import org.apache.flex.forks.batik.css.engine.value.StringMap;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.ValueConstants;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.util.CSSConstants;
import org.w3c.flex.forks.css.sac.LexicalUnit;
import org.w3c.dom.DOMException;
import org.w3c.dom.css.CSSPrimitiveValue;

/**
 * This class provides a manager for the 'text-decoration' property values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: TextDecorationManager.java,v 1.5 2005/03/27 08:58:31 cam Exp $
 */
public class TextDecorationManager extends AbstractValueManager {
    
    /**
     * The identifier values.
     */
    protected final static StringMap values = new StringMap();
    static {
	values.put(CSSConstants.CSS_BLINK_VALUE,
                   ValueConstants.BLINK_VALUE);
	values.put(CSSConstants.CSS_LINE_THROUGH_VALUE,
                   ValueConstants.LINE_THROUGH_VALUE);
	values.put(CSSConstants.CSS_OVERLINE_VALUE,
                   ValueConstants.OVERLINE_VALUE);
	values.put(CSSConstants.CSS_UNDERLINE_VALUE,
                   ValueConstants.UNDERLINE_VALUE);
    }

    /**
     * Implements {@link ValueManager#isInheritedProperty()}.
     */
    public boolean isInheritedProperty() {
	return false;
    }

    /**
     * Implements {@link ValueManager#getPropertyName()}.
     */
    public String getPropertyName() {
	return CSSConstants.CSS_TEXT_DECORATION_PROPERTY;
    }
    
    /**
     * Implements {@link ValueManager#getDefaultValue()}.
     */
    public Value getDefaultValue() {
        return ValueConstants.NONE_VALUE;
    }

    /**
     * Implements {@link ValueManager#createValue(LexicalUnit,CSSEngine)}.
     */
    public Value createValue(LexicalUnit lu, CSSEngine engine)
        throws DOMException {
	switch (lu.getLexicalUnitType()) {
	case LexicalUnit.SAC_INHERIT:
	    return ValueConstants.INHERIT_VALUE;

	case LexicalUnit.SAC_IDENT:
            if (lu.getStringValue().equalsIgnoreCase
                (CSSConstants.CSS_NONE_VALUE)) {
                return ValueConstants.NONE_VALUE;
	    }
            ListValue lv = new ListValue(' ');
            do {
                if (lu.getLexicalUnitType() == LexicalUnit.SAC_IDENT) {
                    String s = lu.getStringValue().toLowerCase().intern();
                    Object obj = values.get(s);
                    if (obj == null) {
                        throw createInvalidIdentifierDOMException
                            (lu.getStringValue());
                    }
                    lv.append((Value)obj);
                    lu = lu.getNextLexicalUnit();
                } else {
                    throw createInvalidLexicalUnitDOMException
                        (lu.getLexicalUnitType());
                }
                
            } while (lu != null);
            return lv;
        }
        throw createInvalidLexicalUnitDOMException
            (lu.getLexicalUnitType());
    }

    /**
     * Implements {@link
     * ValueManager#createStringValue(short,String,CSSEngine)}.
     */
    public Value createStringValue(short type, String value, CSSEngine engine)
	throws DOMException {
	if (type != CSSPrimitiveValue.CSS_IDENT) {
            throw createInvalidStringTypeDOMException(type);
	}
        if (!value.equalsIgnoreCase(CSSConstants.CSS_NONE_VALUE)) {
            throw createInvalidIdentifierDOMException(value);
        }
	return ValueConstants.NONE_VALUE;
    }

}
