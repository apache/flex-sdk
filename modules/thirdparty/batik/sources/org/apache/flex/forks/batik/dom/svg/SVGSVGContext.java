/*

   Copyright 2004 The Apache Software Foundation 

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

import java.util.List;

import org.w3c.flex.forks.dom.svg.SVGRect;
import org.w3c.dom.Element;

/**
 * Context class for svg:svg elements.
 *
 * Eventually this interface will likely have a number of other
 * methods but for now it will have methods to do intersection
 * and enclosure checking.
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: SVGSVGContext.java,v 1.3 2005/03/27 08:58:32 cam Exp $
 */
public interface SVGSVGContext extends SVGContext {

    /**
     * Returns a List of all the DOM elements that intersect
     * <tt>svgRect</tt> that are below <tt>end</tt> in the
     * rendering order.
     */
    public List getIntersectionList(SVGRect svgRect, Element end);

    /**
     * Returns a List of all the DOM elements that are encosed in
     * <tt>svgRect</tt> that are below <tt>end</tt> in the
     * rendering order.
     */
    public List getEnclosureList   (SVGRect rect, Element end );

    /**
     * Returns true if the given DOM element intersects
     * <tt>svgRect</tt>.
     */
    public boolean       checkIntersection (Element element, SVGRect rect );

    /**
     * Returns true if the given DOM element is enclosed in the
     * <tt>svgRect</tt>.
     */
    public boolean       checkEnclosure (Element element, SVGRect rect );

    /**
     * Used to inform the user agent that the text selection should be
     * cleared.
     */
    public void deselectAll();

};
