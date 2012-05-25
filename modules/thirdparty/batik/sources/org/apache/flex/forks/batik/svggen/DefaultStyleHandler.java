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
package org.apache.flex.forks.batik.svggen;

import org.apache.flex.forks.batik.util.SVGConstants;

import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;
import java.util.Vector;

import org.w3c.dom.Element;

/**
 * The <code>DefaultStyleHandler</code> class provides the default
 * way to style an SVG <code>Element</code>.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @version $Id: DefaultStyleHandler.java,v 1.5 2004/08/18 07:14:59 vhardy Exp $
 */
public class DefaultStyleHandler implements StyleHandler, SVGConstants {
    /**
     * Static initializer for which attributes should be ignored on
     * some elements.
     */
    static HashMap ignoreAttributes = new HashMap();

    static {
        Vector textAttributes = new Vector();
        textAttributes.addElement(SVG_FONT_SIZE_ATTRIBUTE);
        textAttributes.addElement(SVG_FONT_FAMILY_ATTRIBUTE);
        textAttributes.addElement(SVG_FONT_STYLE_ATTRIBUTE);
        textAttributes.addElement(SVG_FONT_WEIGHT_ATTRIBUTE);

        ignoreAttributes.put(SVG_RECT_TAG, textAttributes);
        ignoreAttributes.put(SVG_CIRCLE_TAG, textAttributes);
        ignoreAttributes.put(SVG_ELLIPSE_TAG, textAttributes);
        ignoreAttributes.put(SVG_POLYGON_TAG, textAttributes);
        ignoreAttributes.put(SVG_POLYGON_TAG, textAttributes);
        ignoreAttributes.put(SVG_LINE_TAG, textAttributes);
        ignoreAttributes.put(SVG_PATH_TAG, textAttributes);
    }

    /**
     * Sets the style described by <code>styleMap</code> on the given
     * <code>element</code>. That is sets the xml attributes with their
     * styled value.
     * @param element the SVG <code>Element</code> to be styled.
     * @param styleMap the <code>Map</code> containing pairs of style
     * property names, style values.
     */
    public void setStyle(Element element, Map styleMap,
                         SVGGeneratorContext generatorContext) {
        String tagName = element.getTagName();
        Iterator iter = styleMap.keySet().iterator();
        String styleName = null;
        while (iter.hasNext()) {
            styleName = (String)iter.next();
            if (element.getAttributeNS(null, styleName).length() == 0){
                if (appliesTo(styleName, tagName)) {
                    element.setAttributeNS(null, styleName,
                                           (String)styleMap.get(styleName));
                }
            }
        }
    }

    /**
     * Controls whether or not a given attribute applies to a particular 
     * element.
     */
    protected boolean appliesTo(String styleName, String tagName) {
        Vector v = (Vector)ignoreAttributes.get(tagName);
        if (v == null) {
            return true;
        } else {
            return !v.contains(styleName);
        }
    }
}
