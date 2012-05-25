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
import org.apache.flex.forks.batik.css.engine.value.AbstractValueFactory;
import org.apache.flex.forks.batik.css.engine.value.ShorthandManager;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.util.CSSConstants;
import org.w3c.flex.forks.css.sac.LexicalUnit;
import org.w3c.dom.DOMException;

/**
 * This class represents an object which provide support for the
 * 'marker' shorthand properties.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: MarkerShorthandManager.java,v 1.6 2005/03/27 08:58:31 cam Exp $
 */
public class MarkerShorthandManager
    extends AbstractValueFactory
    implements ShorthandManager {
    
    /**
     * Implements {@link ValueManager#getPropertyName()}.
     */
    public String getPropertyName() {
	return CSSConstants.CSS_MARKER_PROPERTY;
    }
    
    /**
     * Implements {@link ShorthandManager#setValues(CSSEngine,ShorthandManager.PropertyHandler,LexicalUnit,boolean)}.
     */
    public void setValues(CSSEngine eng,
                          ShorthandManager.PropertyHandler ph,
                          LexicalUnit lu,
                          boolean imp)
        throws DOMException {
        ph.property(CSSConstants.CSS_MARKER_END_PROPERTY, lu, imp);
        ph.property(CSSConstants.CSS_MARKER_MID_PROPERTY, lu, imp);
        ph.property(CSSConstants.CSS_MARKER_START_PROPERTY, lu, imp);
    }
}
