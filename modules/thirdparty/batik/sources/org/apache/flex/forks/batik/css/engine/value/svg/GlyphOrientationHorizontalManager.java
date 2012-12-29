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

import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.util.CSSConstants;

/**
 * This class provides a manager for the 'glyph-orientation-horizontal'
 * property values.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: GlyphOrientationHorizontalManager.java 475685 2006-11-16 11:16:05Z cam $
 */
public class GlyphOrientationHorizontalManager
    extends GlyphOrientationManager {
    
    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#getPropertyName()}.
     */
    public String getPropertyName() {
        return CSSConstants.CSS_GLYPH_ORIENTATION_HORIZONTAL_PROPERTY;
    }
    
    /**
     * Implements {@link
     * org.apache.flex.forks.batik.css.engine.value.ValueManager#getDefaultValue()}.
     */
    public Value getDefaultValue() {
        return SVGValueConstants.ZERO_DEGREE;
    }
}
