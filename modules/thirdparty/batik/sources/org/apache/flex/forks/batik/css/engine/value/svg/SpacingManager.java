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
package org.apache.flex.forks.batik.css.engine.value.svg;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.value.LengthManager;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.util.CSSConstants;
import org.apache.flex.forks.batik.util.SVGTypes;

import org.w3c.css.sac.LexicalUnit;
import org.w3c.dom.DOMException;
import org.w3c.dom.css.CSSPrimitiveValue;

/**
 * This class provides a manager for the '*-spacing' property values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SpacingManager.java 475685 2006-11-16 11:16:05Z cam $
 */
public class SpacingManager extends LengthManager {
    
    /**
     * The handled property.
     */
    protected String property;

    /**
     * Creates a new SpacingManager.
     */
    public SpacingManager(String prop) {
        property = prop;
    }


    /**
     * Implements {@link ValueManager#isInheritedProperty()}.
     */
    public boolean isInheritedProperty() {
        return true;
    }

    /**
     * Implements {@link ValueManager#isAnimatableProperty()}.
     */
    public boolean isAnimatableProperty() {
        return true;
    }

    /**
     * Implements {@link ValueManager#isAdditiveProperty()}.
     */
    public boolean isAdditiveProperty() {
        return true;
    }

    /**
     * Implements {@link ValueManager#getPropertyType()}.
     */
    public int getPropertyType() {
        return SVGTypes.TYPE_SPACING_VALUE;
    }

    /**
     * Implements {@link ValueManager#getPropertyName()}.
     */
    public String getPropertyName() {
        return property;
    }
    
    /**
     * Implements {@link ValueManager#getDefaultValue()}.
     */
    public Value getDefaultValue() {
        return SVGValueConstants.NORMAL_VALUE;
    }

    /**
     * Implements {@link ValueManager#createValue(LexicalUnit,CSSEngine)}.
     */
    public Value createValue(LexicalUnit lu, CSSEngine engine)
        throws DOMException {
        switch (lu.getLexicalUnitType()) {
        case LexicalUnit.SAC_INHERIT:
            return SVGValueConstants.INHERIT_VALUE;

        case LexicalUnit.SAC_IDENT:
            if (lu.getStringValue().equalsIgnoreCase
                (CSSConstants.CSS_NORMAL_VALUE)) {
                return SVGValueConstants.NORMAL_VALUE;
            }
            throw createInvalidIdentifierDOMException(lu.getStringValue());
        }
        return super.createValue(lu, engine);
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
        if (value.equalsIgnoreCase(CSSConstants.CSS_NORMAL_VALUE)) {
            return SVGValueConstants.NORMAL_VALUE;
        }
        throw createInvalidIdentifierDOMException(value);
    }

    /**
     * Indicates the orientation of the property associated with
     * this manager.
     */
    protected int getOrientation() {
        return BOTH_ORIENTATION;
    }
}
