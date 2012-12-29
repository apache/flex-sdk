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

import org.apache.flex.forks.batik.css.engine.value.IdentifierManager;
import org.apache.flex.forks.batik.css.engine.value.StringMap;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.util.CSSConstants;
import org.apache.flex.forks.batik.util.SVGTypes;

/**
 * This class provides a manager for the 'alignment-baseline' property values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AlignmentBaselineManager.java 478160 2006-11-22 13:35:06Z dvholten $
 */
public class AlignmentBaselineManager extends IdentifierManager {

    /**
     * The identifier values.
     */
    protected static final StringMap values = new StringMap();
    static {
        values.put(CSSConstants.CSS_AFTER_EDGE_VALUE,
                   SVGValueConstants.AFTER_EDGE_VALUE);
        values.put(CSSConstants.CSS_ALPHABETIC_VALUE,
                   SVGValueConstants.ALPHABETIC_VALUE);
        values.put(CSSConstants.CSS_AUTO_VALUE,
                   SVGValueConstants.AUTO_VALUE);
        values.put(CSSConstants.CSS_BASELINE_VALUE,
                   SVGValueConstants.BASELINE_VALUE);
        values.put(CSSConstants.CSS_BEFORE_EDGE_VALUE,
                   SVGValueConstants.BEFORE_EDGE_VALUE);
        values.put(CSSConstants.CSS_HANGING_VALUE,
                   SVGValueConstants.HANGING_VALUE);
        values.put(CSSConstants.CSS_IDEOGRAPHIC_VALUE,
                   SVGValueConstants.IDEOGRAPHIC_VALUE);
        values.put(CSSConstants.CSS_MATHEMATICAL_VALUE,
                   SVGValueConstants.MATHEMATICAL_VALUE);
        values.put(CSSConstants.CSS_MIDDLE_VALUE,
                   SVGValueConstants.MIDDLE_VALUE);
        values.put(CSSConstants.CSS_TEXT_AFTER_EDGE_VALUE,
                   SVGValueConstants.TEXT_AFTER_EDGE_VALUE);
        values.put(CSSConstants.CSS_TEXT_BEFORE_EDGE_VALUE,
                   SVGValueConstants.TEXT_BEFORE_EDGE_VALUE);
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#isInheritedProperty()}.
     */
    public boolean isInheritedProperty() {
        return false;
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
        return false;
    }

    /**
     * Implements {@link ValueManager#getPropertyType()}.
     */
    public int getPropertyType() {
        return SVGTypes.TYPE_IDENT;
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#getPropertyName()}.
     */
    public String getPropertyName() {
        return CSSConstants.CSS_ALIGNMENT_BASELINE_PROPERTY;
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#getDefaultValue()}.
     */
    public Value getDefaultValue() {
        return SVGValueConstants.AUTO_VALUE;
    }

    /**
     * Implements {@link IdentifierManager#getIdentifiers()}.
     */
    public StringMap getIdentifiers() {
        return values;
    }
}
