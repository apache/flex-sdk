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
package org.apache.flex.forks.batik.svggen;

import org.apache.flex.forks.batik.util.SVGConstants;

import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.HashSet;

import org.w3c.dom.Element;

/**
 * The <code>DefaultStyleHandler</code> class provides the default
 * way to style an SVG <code>Element</code>.
 *
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @version $Id: DefaultStyleHandler.java 479559 2006-11-27 09:46:16Z dvholten $
 */
public class DefaultStyleHandler implements StyleHandler, SVGConstants {
    
    /**
     * Static initializer for which attributes should be ignored on
     * some elements.
     * Map-key is a string like 'SVG_RECT_TAG' ,
     * map-entry is a set of strings, which denote font-attributes to ignore.
     * The set is shared by all map-entries.
     */
    static Map ignoreAttributes = new HashMap();

    static {
        // this is just used for read-only 'contains'-tests
        Set textAttributes = new HashSet( );
        textAttributes.add(SVG_FONT_SIZE_ATTRIBUTE);
        textAttributes.add(SVG_FONT_FAMILY_ATTRIBUTE);
        textAttributes.add(SVG_FONT_STYLE_ATTRIBUTE);
        textAttributes.add(SVG_FONT_WEIGHT_ATTRIBUTE);

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
        while (iter.hasNext()) {
            String styleName = (String)iter.next();
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
        Set s = (Set)ignoreAttributes.get(tagName);
        if (s == null) {
            return true;
        } else {
            return !s.contains(styleName);
        }
    }
}
