/*

   Copyright 2001,2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.dom.svg;

import org.w3c.dom.DOMException;
import org.w3c.flex.forks.dom.svg.SVGRect;

public class SVGOMRect implements SVGRect{
    float x;
    float y;
    float w;
    float h;
    public SVGOMRect() { x = y = w = h = 0; }
    public SVGOMRect(float x, float y, float w, float h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }
    
    public float getX( ) { return x; }
    public void  setX( float x ) throws DOMException { this.x = x; }
    public float getY( ) { return y; }
    public void  setY( float y ) throws DOMException { this.y = y; }
    public float getWidth( ) { return w; }
    public void  setWidth( float width ) throws DOMException { this.w = width; }
    public float getHeight( ) { return h; }
    public void  setHeight( float height ) throws DOMException { this.h = height; }
}
