/*

   Copyright 2001-2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.bridge;

import java.awt.geom.Rectangle2D;
import java.util.Map;

import org.apache.flex.forks.batik.ext.awt.image.Light;
import org.apache.flex.forks.batik.ext.awt.image.renderable.DiffuseLightingRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.w3c.dom.Element;

/**
 * Bridge class for the &lt;feDiffuseLighting> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGFeDiffuseLightingElementBridge.java,v 1.16 2004/08/18 07:12:33 vhardy Exp $
 */
public class SVGFeDiffuseLightingElementBridge
    extends AbstractSVGLightingElementBridge {


    /**
     * Constructs a new bridge for the &lt;feDiffuseLighting> element.
     */
    public SVGFeDiffuseLightingElementBridge() {}

    /**
     * Returns 'feDiffuseLighting'.
     */
    public String getLocalName() {
        return SVG_FE_DIFFUSE_LIGHTING_TAG;
    }

    /**
     * Creates a <tt>Filter</tt> primitive according to the specified
     * parameters.
     *
     * @param ctx the bridge context to use
     * @param filterElement the element that defines a filter
     * @param filteredElement the element that references the filter
     * @param filteredNode the graphics node to filter
     *
     * @param inputFilter the <tt>Filter</tt> that represents the current
     *        filter input if the filter chain.
     * @param filterRegion the filter area defined for the filter chain
     *        the new node will be part of.
     * @param filterMap a map where the mediator can map a name to the
     *        <tt>Filter</tt> it creates. Other <tt>FilterBridge</tt>s
     *        can then access a filter node from the filterMap if they
     *        know its name.
     */
    public Filter createFilter(BridgeContext ctx,
                               Element filterElement,
                               Element filteredElement,
                               GraphicsNode filteredNode,
                               Filter inputFilter,
                               Rectangle2D filterRegion,
                               Map filterMap) {

        // 'surfaceScale' attribute - default is 1
        float surfaceScale
            = convertNumber(filterElement, SVG_SURFACE_SCALE_ATTRIBUTE, 1);

        // 'diffuseConstant' attribute - default is 1
        float diffuseConstant
            = convertNumber(filterElement, SVG_DIFFUSE_CONSTANT_ATTRIBUTE, 1);

        // 'kernelUnitLength' attribute
        // <!> FIXME: Why is it ignored ???

        // extract the light definition from the filterElement's children list
        Light light = extractLight(filterElement, ctx);

        // 'kernelUnitLength' attribute
        double [] kernelUnitLength = convertKernelUnitLength(filterElement);

        // 'in' attribute
        Filter in = getIn(filterElement,
                          filteredElement,
                          filteredNode,
                          inputFilter,
                          filterMap,
                          ctx);
        if (in == null) {
            return null; // disable the filter
        }

        // Default region is the size of in (if in is SourceGraphic or
        // SourceAlpha it will already include a pad/crop to the
        // proper filter region size).
        Rectangle2D defaultRegion = in.getBounds2D();
        Rectangle2D primitiveRegion
            = SVGUtilities.convertFilterPrimitiveRegion(filterElement,
                                                        filteredElement,
                                                        filteredNode,
                                                        defaultRegion,
                                                        filterRegion,
                                                        ctx);
        Filter filter = new DiffuseLightingRable8Bit(in,
                                                     primitiveRegion,
                                                     light,
                                                     diffuseConstant,
                                                     surfaceScale,
                                                     kernelUnitLength);

        // handle the 'color-interpolation-filters' property
        handleColorInterpolationFilters(filter, filterElement);

        // update the filter Map
        updateFilterMap(filterElement, filter, filterMap);

        return filter;
    }
}
