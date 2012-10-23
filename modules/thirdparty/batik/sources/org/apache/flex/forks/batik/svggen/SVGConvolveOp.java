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
import java.awt.image.ConvolveOp;
import java.awt.image.Kernel;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 * Utility class that converts a ConvolveOp object into
 * an SVG filter descriptor.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGConvolveOp.java 476924 2006-11-19 21:13:26Z dvholten $
 * @see                org.apache.flex.forks.batik.svggen.SVGBufferedImageOp
 */
public class SVGConvolveOp extends AbstractSVGFilterConverter {
    /**
     * @param generatorContext used to build Elements
     */
    public SVGConvolveOp(SVGGeneratorContext generatorContext) {
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
                                     Rectangle filterRect){
        if(filter instanceof ConvolveOp)
            return toSVG((ConvolveOp)filter);
        else
            return null;
    }

    /**
     * @param convolveOp the ConvolveOp to be converted
     * @return a description of the SVG filter corresponding to
     *         convolveOp. The definition of the feConvolveMatrix
     *         filter in put in feConvolveMatrixDefSet
     */
    public SVGFilterDescriptor toSVG(ConvolveOp convolveOp){
        // Reuse definition if convolveOp has already been converted
        SVGFilterDescriptor filterDesc =
            (SVGFilterDescriptor)descMap.get(convolveOp);
        Document domFactory = generatorContext.domFactory;

        if (filterDesc == null) {
            //
            // First time filter is converted: create its corresponding
            // SVG filter
            //
            Kernel kernel = convolveOp.getKernel();
            Element filterDef =
                domFactory.createElementNS(SVG_NAMESPACE_URI, SVG_FILTER_TAG);
            Element feConvolveMatrixDef =
                domFactory.createElementNS(SVG_NAMESPACE_URI,
                                           SVG_FE_CONVOLVE_MATRIX_TAG);

            // Convert the kernel size
            feConvolveMatrixDef.setAttributeNS(null, SVG_ORDER_ATTRIBUTE,
                                             kernel.getWidth() + SPACE +
                                             kernel.getHeight());

            // Convert the kernel values
            float[] data = kernel.getKernelData(null);
            StringBuffer kernelMatrixBuf = new StringBuffer( data.length * 8 );
            for(int i=0; i<data.length; i++){
                kernelMatrixBuf.append(doubleString(data[i]));
                kernelMatrixBuf.append(SPACE);
            }

            feConvolveMatrixDef.
                setAttributeNS(null, SVG_KERNEL_MATRIX_ATTRIBUTE,
                               kernelMatrixBuf.toString().trim());

            filterDef.appendChild(feConvolveMatrixDef);

            filterDef.setAttributeNS(null, SVG_ID_ATTRIBUTE,
                                     generatorContext.idGenerator.
                                     generateID(ID_PREFIX_FE_CONVOLVE_MATRIX));

            // Convert the edge mode
            if(convolveOp.getEdgeCondition() == ConvolveOp.EDGE_NO_OP)
                feConvolveMatrixDef.setAttributeNS(null, SVG_EDGE_MODE_ATTRIBUTE,
                                                 SVG_DUPLICATE_VALUE);
            else
                feConvolveMatrixDef.setAttributeNS(null, SVG_EDGE_MODE_ATTRIBUTE,
                                                 SVG_NONE_VALUE);

            //
            // Create a filter descriptor
            //

            // Process filter attribute
            StringBuffer filterAttrBuf = new StringBuffer(URL_PREFIX);
            filterAttrBuf.append(SIGN_POUND);
            filterAttrBuf.append(filterDef.getAttributeNS(null, SVG_ID_ATTRIBUTE));
            filterAttrBuf.append(URL_SUFFIX);

            filterDesc = new SVGFilterDescriptor(filterAttrBuf.toString(),
                                                 filterDef);

            defSet.add(filterDef);
            descMap.put(convolveOp, filterDesc);
        }

        return filterDesc;
    }
}
