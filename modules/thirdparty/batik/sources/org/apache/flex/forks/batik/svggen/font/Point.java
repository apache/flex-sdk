/*

   Copyright 2001  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.svggen.font;

/**
 * @version $Id: Point.java,v 1.3 2004/08/18 07:15:18 vhardy Exp $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public class Point {

    public int x = 0;
    public int y = 0;
    public boolean onCurve = true;
    public boolean endOfContour = false;
    public boolean touched = false;

    public Point(int x, int y, boolean onCurve, boolean endOfContour) {
        this.x = x;
        this.y = y;
        this.onCurve = onCurve;
        this.endOfContour = endOfContour;
    }
}
