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
import org.w3c.dom.DOMException;

/**
 * This interface represents the values for properties like 'fill',
 * 'flood-color'...
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGValue.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface SVGValue extends Value {
    
    /**
     * Returns the paint type, if this object represents a SVGPaint.
     */
    short getPaintType() throws DOMException;

    /**
     * Returns the URI of the paint, if this object represents a SVGPaint.
     */
    String getUri() throws DOMException;

    /**
     * Returns the color type, if this object represents a SVGColor.
     */
    short getColorType() throws DOMException;

    /**
     * Returns the color profile, if this object represents a SVGColor.
     */
    String getColorProfile() throws DOMException;

    /**
     * Returns the number of colors, if this object represents a SVGColor.
     */
    int getNumberOfColors() throws DOMException;

    /**
     * Returns the color at the given index, if this object represents
     * a SVGColor.
     */
    float getColor(int i) throws DOMException;
}
