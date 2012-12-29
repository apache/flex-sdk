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
package org.apache.flex.forks.batik.dom.svg;

import org.w3c.dom.DOMException;
import org.w3c.dom.svg.SVGRect;

/**
 * An implementation of {@link SVGRect} that is not associated with an
 * attribute.
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas DeWeese</a>
 * @version $Id: SVGOMRect.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGOMRect implements SVGRect {

    /**
     * The rect's x coordinate.
     */
    protected float x;

    /**
     * The rect's y coordinate.
     */
    protected float y;

    /**
     * The rect's width.
     */
    protected float w;

    /**
     * The rect's height.
     */
    protected float h;

    /**
     * Creates a new SVGOMRect with all values set to zero.
     */
    public SVGOMRect() {
    }

    /**
     * Creates a new SVGOMRect with the specified position and dimensions.
     */
    public SVGOMRect(float x, float y, float w, float h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }
    
    /**
     * <b>DOM</b>: Implements {@link SVGRect#getX()}.
     */
    public float getX() {
        return x;
    }
    
    /**
     * <b>DOM</b>: Implements {@link SVGRect#setX(float)}.
     */
    public void setX(float x) throws DOMException {
        this.x = x;
    }
    
    /**
     * <b>DOM</b>: Implements {@link SVGRect#getY()}.
     */
    public float getY() {
        return y;
    }
    
    /**
     * <b>DOM</b>: Implements {@link SVGRect#setY(float)}.
     */
    public void setY(float y) throws DOMException {
        this.y = y;
    }
    
    /**
     * <b>DOM</b>: Implements {@link SVGRect#getWidth()}.
     */
    public float getWidth() {
        return w;
    }
    
    /**
     * <b>DOM</b>: Implements {@link SVGRect#setWidth(float)}.
     */
    public void setWidth(float width) throws DOMException {
        this.w = width;
    }
    
    /**
     * <b>DOM</b>: Implements {@link SVGRect#getHeight()}.
     */
    public float getHeight() {
        return h;
    }
    
    /**
     * <b>DOM</b>: Implements {@link SVGRect#setHeight(float)}.
     */
    public void setHeight(float height) throws DOMException {
        this.h = height;
    }
}
