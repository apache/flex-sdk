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
 * This class provides a manager for the 'writing-mode' property values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: WritingModeManager.java 478283 2006-11-22 18:53:40Z dvholten $
 */
public class WritingModeManager extends IdentifierManager {

    /**
     * The identifier values.
     */
    protected static final StringMap values = new StringMap();
    static {
        values.put(CSSConstants.CSS_LR_VALUE,
                   SVGValueConstants.LR_VALUE);
        values.put(CSSConstants.CSS_LR_TB_VALUE,
                   SVGValueConstants.LR_TB_VALUE);
        values.put(CSSConstants.CSS_RL_VALUE,
                   SVGValueConstants.RL_VALUE);
        values.put(CSSConstants.CSS_RL_TB_VALUE,
                   SVGValueConstants.RL_TB_VALUE);
        values.put(CSSConstants.CSS_TB_VALUE,
                   SVGValueConstants.TB_VALUE);
        values.put(CSSConstants.CSS_TB_RL_VALUE,
                   SVGValueConstants.TB_RL_VALUE);
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#isInheritedProperty()}.
     */
    public boolean isInheritedProperty() {
        return true;
    }

    /**
     * Implements {@link ValueManager#isAnimatableProperty()}.
     */
    public boolean isAnimatableProperty() {
        return false;
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
        return CSSConstants.CSS_WRITING_MODE_PROPERTY;
    }

    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#getDefaultValue()}.
     */
    public Value getDefaultValue() {
        return SVGValueConstants.LR_TB_VALUE;
    }

    /**
     * Implements {@link IdentifierManager#getIdentifiers()}.
     */
    public StringMap getIdentifiers() {
        return values;
    }
}
