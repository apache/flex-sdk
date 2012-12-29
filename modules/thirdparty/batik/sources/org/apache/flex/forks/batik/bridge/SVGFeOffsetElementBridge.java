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
package org.apache.flex.forks.batik.bridge;

import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.util.Map;

import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.renderable.AffineRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PadRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PadRable8Bit;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.w3c.dom.Element;

/**
 * Bridge class for the &lt;feOffset> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGFeOffsetElementBridge.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGFeOffsetElementBridge
    extends AbstractSVGFilterPrimitiveElementBridge {

    /**
     * Constructs a new bridge for the &lt;feOffset> element.
     */
    public SVGFeOffsetElementBridge() {}

    /**
     * Returns 'feOffset'.
     */
    public String getLocalName() {
        return SVG_FE_OFFSET_TAG;
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

        float dx = convertNumber(filterElement, SVG_DX_ATTRIBUTE, 0, ctx);
        float dy = convertNumber(filterElement, SVG_DY_ATTRIBUTE, 0, ctx);
        AffineTransform at = AffineTransform.getTranslateInstance(dx, dy);

        // feOffset is a point operation. Therefore, to take the
        // filter primitive region into account, only a pad operation
        // on the input is required.
        PadRable pad = new PadRable8Bit(in, primitiveRegion, PadMode.ZERO_PAD);
        Filter filter = new AffineRable8Bit(pad, at);
        filter = new PadRable8Bit(filter, primitiveRegion, PadMode.ZERO_PAD);

        // handle the 'color-interpolation-filters' property
        handleColorInterpolationFilters(filter, filterElement);

        // update the filter Map
        updateFilterMap(filterElement, filter, filterMap);

        return filter;
    }
}
