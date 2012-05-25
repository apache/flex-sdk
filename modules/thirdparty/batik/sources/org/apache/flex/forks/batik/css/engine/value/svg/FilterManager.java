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
package org.apache.flex.forks.batik.css.engine.value.svg;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.value.AbstractValueManager;
import org.apache.flex.forks.batik.css.engine.value.URIValue;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.util.CSSConstants;
import org.w3c.flex.forks.css.sac.LexicalUnit;
import org.w3c.dom.DOMException;
import org.w3c.dom.css.CSSPrimitiveValue;


/**
 * This class provides a factory for the 'filter' property values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: FilterManager.java,v 1.6 2005/03/27 08:58:31 cam Exp $
 */
public class FilterManager extends AbstractValueManager {
    
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
	return CSSConstants.CSS_FILTER_PROPERTY;
    }
    
    /**
     * Implements {@link ValueManager#getDefaultValue()}.
     */
    public Value getDefaultValue() {
        return SVGValueConstants.NONE_VALUE;
    }

    /**
     * Implements {@link ValueManager#createValue(LexicalUnit,CSSEngine)}.
     */
    public Value createValue(LexicalUnit lu, CSSEngine engine)
        throws DOMException {
	switch (lu.getLexicalUnitType()) {
	case LexicalUnit.SAC_INHERIT:
	    return SVGValueConstants.INHERIT_VALUE;

        case LexicalUnit.SAC_URI:
            return new URIValue(lu.getStringValue(),
                                resolveURI(engine.getCSSBaseURI(),
                                           lu.getStringValue()));

        case LexicalUnit.SAC_IDENT:
	    if (lu.getStringValue().equalsIgnoreCase
                (CSSConstants.CSS_NONE_VALUE)) {
		return SVGValueConstants.NONE_VALUE;
	    }
            throw createInvalidIdentifierDOMException(lu.getStringValue());
        }
        throw createInvalidLexicalUnitDOMException(lu.getLexicalUnitType());
    }

    /**
     * Implements {@link
     * ValueManager#createStringValue(short,String,CSSEngine)}.
     */
    public Value createStringValue(short type, String value, CSSEngine engine)
        throws DOMException {
	if (type == CSSPrimitiveValue.CSS_IDENT) {
            if (value.equalsIgnoreCase(CSSConstants.CSS_NONE_VALUE)) {
                return SVGValueConstants.NONE_VALUE;
            }
            throw createInvalidIdentifierDOMException(value);
	}
	if (type == CSSPrimitiveValue.CSS_URI) {
	    return new URIValue(value, 
                                resolveURI(engine.getCSSBaseURI(), value));
	}
        throw createInvalidStringTypeDOMException(type);
    }
}
