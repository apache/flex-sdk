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

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * Describes a set of SVG hints
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGHintsDescriptor.java,v 1.7 2004/08/18 07:15:07 vhardy Exp $
 * @see             org.apache.flex.forks.batik.svggen.SVGRenderingHints
 */
public class SVGHintsDescriptor implements SVGDescriptor, SVGSyntax {
    private String colorInterpolation;
    private String colorRendering;
    private String textRendering;
    private String shapeRendering;
    private String imageRendering;

    /**
     * Constructor
     */
    public SVGHintsDescriptor(String colorInterpolation,
                              String colorRendering,
                              String textRendering,
                              String shapeRendering,
                              String imageRendering){
        if(colorInterpolation == null ||
           colorRendering == null ||
           textRendering == null ||
           shapeRendering == null ||
           imageRendering == null)
            throw new SVGGraphics2DRuntimeException(ErrorConstants.ERR_HINT_NULL);

        this.colorInterpolation = colorInterpolation;
        this.colorRendering = colorRendering;
        this.textRendering = textRendering;
        this.shapeRendering = shapeRendering;
        this.imageRendering = imageRendering;
    }

    public Map getAttributeMap(Map attrMap) {
        if (attrMap == null)
            attrMap = new HashMap();

        attrMap.put(SVG_COLOR_INTERPOLATION_ATTRIBUTE, colorInterpolation);
        attrMap.put(SVG_COLOR_RENDERING_ATTRIBUTE, colorRendering);
        attrMap.put(SVG_TEXT_RENDERING_ATTRIBUTE, textRendering);
        attrMap.put(SVG_SHAPE_RENDERING_ATTRIBUTE, shapeRendering);
        attrMap.put(SVG_IMAGE_RENDERING_ATTRIBUTE, imageRendering);

        return attrMap;
    }

    public List getDefinitionSet(List defSet) {
        if (defSet == null)
            defSet = new LinkedList();

        return defSet;
    }
}
