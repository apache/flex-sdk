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

import java.awt.Rectangle;
import java.awt.image.BufferedImageOp;
import java.awt.image.RescaleOp;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 * Utility class that converts a RescaleOp object into
 * an SVG filter descriptor. The SVG filter corresponding
 * to a RescaleOp is an feComponentTransfer, with a type
 * set to 'linear', the slopes equal to the RescapeOp
 * scaleFactors and the intercept equal to the RescapeOp
 * offsets.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGRescaleOp.java 476924 2006-11-19 21:13:26Z dvholten $
 * @see                org.apache.flex.forks.batik.svggen.SVGBufferedImageOp
 */
public class SVGRescaleOp extends AbstractSVGFilterConverter {

    /**
     * @param generatorContext used to build Elements
     */
    public SVGRescaleOp(SVGGeneratorContext generatorContext) {
        super(generatorContext);
    }

    /**
     * Converts a Java 2D API BufferedImageOp into
     * a set of attribute/value pairs and related definitions
     *
     * @param filter BufferedImageOp filter to be converted
     * @param filterRect Rectangle, in device space, that defines the area
     *        to which filtering applies. May be null, meaning that the
     *        area is undefined.
     * @return descriptor of the attributes required to represent
     *         the input filter
     * @see org.apache.flex.forks.batik.svggen.SVGFilterDescriptor
     */
    public SVGFilterDescriptor toSVG(BufferedImageOp filter,
                                     Rectangle filterRect) {
        if(filter instanceof RescaleOp)
            return toSVG((RescaleOp)filter);
        else
            return null;
    }

    /**
     * @param rescaleOp the RescaleOp to be converted
     * @return a description of the SVG filter corresponding to
     *         rescaleOp. The definition of the feComponentTransfer
     *         filter in put in feComponentTransferDefSet
     */
    public SVGFilterDescriptor toSVG(RescaleOp rescaleOp) {
        // Reuse definition if rescaleOp has already been converted
        SVGFilterDescriptor filterDesc =
            (SVGFilterDescriptor)descMap.get(rescaleOp);

        Document domFactory = generatorContext.domFactory;

        if (filterDesc == null) {
            //
            // First time filter is converted: create its corresponding
            // SVG filter
            //
            Element filterDef = domFactory.createElementNS(SVG_NAMESPACE_URI,
                                                           SVG_FILTER_TAG);
            Element feComponentTransferDef =
                domFactory.createElementNS(SVG_NAMESPACE_URI,
                                           SVG_FE_COMPONENT_TRANSFER_TAG);

            // Append transfer function for each component, setting
            // the attributes corresponding to the scale and offset.
            // Because we are using a RescaleOp as a BufferedImageOp,
            // the scaleFactors must be either:
            // + 1, in which case the same scale is applied to the
            //   Red, Green and Blue components,
            // + 3, in which case the scale factors apply to the
            //   Red, Green and Blue components
            // + 4, in which case the scale factors apply to the
            //   Red, Green, Blue and Alpha components
            float[] offsets = rescaleOp.getOffsets(null);
            float[] scaleFactors = rescaleOp.getScaleFactors(null);
            if(offsets.length != scaleFactors.length)
                throw new SVGGraphics2DRuntimeException(ERR_SCALE_FACTORS_AND_OFFSETS_MISMATCH);

            if(offsets.length != 1 &&
               offsets.length != 3 &&
               offsets.length != 4)
                throw new SVGGraphics2DRuntimeException(ERR_ILLEGAL_BUFFERED_IMAGE_RESCALE_OP);

            Element feFuncR = domFactory.createElementNS(SVG_NAMESPACE_URI,
                                                         SVG_FE_FUNC_R_TAG);
            Element feFuncG = domFactory.createElementNS(SVG_NAMESPACE_URI,
                                                         SVG_FE_FUNC_G_TAG);
            Element feFuncB = domFactory.createElementNS(SVG_NAMESPACE_URI,
                                                         SVG_FE_FUNC_B_TAG);
            Element feFuncA = null;
            String type = SVG_LINEAR_VALUE;

            if(offsets.length == 1){
                String slope = doubleString(scaleFactors[0]);
                String intercept = doubleString(offsets[0]);
                feFuncR.setAttributeNS(null, SVG_TYPE_ATTRIBUTE, type);
                feFuncG.setAttributeNS(null, SVG_TYPE_ATTRIBUTE, type);
                feFuncB.setAttributeNS(null, SVG_TYPE_ATTRIBUTE, type);
                feFuncR.setAttributeNS(null, SVG_SLOPE_ATTRIBUTE, slope);
                feFuncG.setAttributeNS(null, SVG_SLOPE_ATTRIBUTE, slope);
                feFuncB.setAttributeNS(null, SVG_SLOPE_ATTRIBUTE, slope);
                feFuncR.setAttributeNS(null, SVG_INTERCEPT_ATTRIBUTE, intercept);
                feFuncG.setAttributeNS(null, SVG_INTERCEPT_ATTRIBUTE, intercept);
                feFuncB.setAttributeNS(null, SVG_INTERCEPT_ATTRIBUTE, intercept);
            }
            else if(offsets.length >= 3){
                feFuncR.setAttributeNS(null, SVG_TYPE_ATTRIBUTE, type);
                feFuncG.setAttributeNS(null, SVG_TYPE_ATTRIBUTE, type);
                feFuncB.setAttributeNS(null, SVG_TYPE_ATTRIBUTE, type);
                feFuncR.setAttributeNS(null, SVG_SLOPE_ATTRIBUTE,
                                       doubleString(scaleFactors[0]));
                feFuncG.setAttributeNS(null, SVG_SLOPE_ATTRIBUTE,
                                       doubleString(scaleFactors[1]));
                feFuncB.setAttributeNS(null, SVG_SLOPE_ATTRIBUTE,
                                       doubleString(scaleFactors[2]));
                feFuncR.setAttributeNS(null, SVG_INTERCEPT_ATTRIBUTE,
                                       doubleString(offsets[0]));
                feFuncG.setAttributeNS(null, SVG_INTERCEPT_ATTRIBUTE,
                                       doubleString(offsets[1]));
                feFuncB.setAttributeNS(null, SVG_INTERCEPT_ATTRIBUTE,
                                       doubleString(offsets[2]));

                if(offsets.length == 4){
                    feFuncA = domFactory.createElementNS(SVG_NAMESPACE_URI,
                                                         SVG_FE_FUNC_A_TAG);
                    feFuncA.setAttributeNS(null, SVG_TYPE_ATTRIBUTE, type);
                    feFuncA.setAttributeNS(null, SVG_SLOPE_ATTRIBUTE,
                                         doubleString(scaleFactors[3]));
                    feFuncA.setAttributeNS(null, SVG_INTERCEPT_ATTRIBUTE,
                                         doubleString(offsets[3]));
                }
            }

            feComponentTransferDef.appendChild(feFuncR);
            feComponentTransferDef.appendChild(feFuncG);
            feComponentTransferDef.appendChild(feFuncB);
            if(feFuncA != null)
                feComponentTransferDef.appendChild(feFuncA);

            filterDef.appendChild(feComponentTransferDef);

            filterDef.
                setAttributeNS(null, SVG_ID_ATTRIBUTE,
                               generatorContext.idGenerator.
                               generateID(ID_PREFIX_FE_COMPONENT_TRANSFER));

            //
            // Create a filter descriptor
            //

            // Process filter attribute
//            StringBuffer filterAttrBuf = new StringBuffer(URL_PREFIX);
//            filterAttrBuf.append(SIGN_POUND);
//            filterAttrBuf.append(filterDef.getAttributeNS(null, SVG_ID_ATTRIBUTE));
//            filterAttrBuf.append(URL_SUFFIX);

            String filterAttrBuf = URL_PREFIX + SIGN_POUND + filterDef.getAttributeNS(null, SVG_ID_ATTRIBUTE) + URL_SUFFIX;

            filterDesc = new SVGFilterDescriptor(filterAttrBuf, filterDef);

            defSet.add(filterDef);
            descMap.put(rescaleOp, filterDesc);
        }

        return filterDesc;
    }
}
