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

import org.apache.flex.forks.batik.css.engine.value.IdentifierManager;
import org.apache.flex.forks.batik.css.engine.value.StringMap;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.util.CSSConstants;

/**
 * This class provides a manager for the 'pointer-events' property values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: PointerEventsManager.java,v 1.5 2004/12/03 12:20:16 deweese Exp $
 */
public class PointerEventsManager extends IdentifierManager {
    
    /**
     * The identifier values.
     */
    protected final static StringMap values = new StringMap();
    static {
	values.put(CSSConstants.CSS_ALL_VALUE,
                   SVGValueConstants.ALL_VALUE);
	values.put(CSSConstants.CSS_FILL_VALUE,
                   SVGValueConstants.FILL_VALUE);
	values.put(CSSConstants.CSS_FILLSTROKE_VALUE,
                   SVGValueConstants.FILLSTROKE_VALUE);
	values.put(CSSConstants.CSS_NONE_VALUE,
                   SVGValueConstants.NONE_VALUE);
	values.put(CSSConstants.CSS_PAINTED_VALUE,
                   SVGValueConstants.PAINTED_VALUE);
	values.put(CSSConstants.CSS_STROKE_VALUE,
                   SVGValueConstants.STROKE_VALUE);
	values.put(CSSConstants.CSS_VISIBLE_VALUE,
                   SVGValueConstants.VISIBLE_VALUE);
	values.put(CSSConstants.CSS_VISIBLEFILL_VALUE,
                   SVGValueConstants.VISIBLEFILL_VALUE);
	values.put(CSSConstants.CSS_VISIBLEFILLSTROKE_VALUE,
                   SVGValueConstants.VISIBLEFILLSTROKE_VALUE);
	values.put(CSSConstants.CSS_VISIBLEPAINTED_VALUE,
                   SVGValueConstants.VISIBLEPAINTED_VALUE);
	values.put(CSSConstants.CSS_VISIBLESTROKE_VALUE,
                   SVGValueConstants.VISIBLESTROKE_VALUE);
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
	return CSSConstants.CSS_POINTER_EVENTS_PROPERTY;
    }
    
    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#getDefaultValue()}.
     */
    public Value getDefaultValue() {
        return SVGValueConstants.VISIBLEPAINTED_VALUE;
    }

    /**
     * Implements {@link IdentifierManager#getIdentifiers()}.
     */
    public StringMap getIdentifiers() {
        return values;
    }
}
