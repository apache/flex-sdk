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
import java.awt.image.ByteLookupTable;
import java.awt.image.LookupOp;
import java.awt.image.LookupTable;
import java.util.Arrays;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 * Utility class that converts a LookupOp object into
 * an SVG filter descriptor. The SVG filter corresponding
 * to a LookupOp is an feComponentTransfer, with a type
 * set to 'table', the tableValues set to the content
 * of the lookup table.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGLookupOp.java 501495 2007-01-30 18:00:36Z dvholten $
 * @see                org.apache.flex.forks.batik.svggen.SVGBufferedImageOp
 */
public class SVGLookupOp extends AbstractSVGFilterConverter {

    /**
     * Gamma for linear to sRGB convertion
     */
    private static final double GAMMA = 1.0/2.4;

    /**
     * Lookup table for linear to sRGB value
     * forward and backward mapping
     */
    private static final int[] linearToSRGBLut = new int[256];
    private static final int[] sRGBToLinear = new int[256];

    static {
        for(int i=0; i<256; i++) {
            // linear to sRGB
            float value = i/255f;
            if (value <= 0.0031308) {
                value *= 12.92f;
            } else {
                value = 1.055f * ((float) Math.pow(value, GAMMA)) - 0.055f;
            }
            linearToSRGBLut[i] = Math.round(value*255);

            // sRGB to linear
            value = i/255f;
            if(value <= 0.04045){
                value /= 12.92f;
            } else {
                value = (float)Math.pow((value + 0.055f)/1.055f, 1/GAMMA);
            }

            sRGBToLinear[i] = Math.round(value*255);
        }
    }

    /**
     * @param generatorContext used to build Elements
     */
    public SVGLookupOp(SVGGeneratorContext generatorContext) {
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
        if (filter instanceof LookupOp)
            return toSVG((LookupOp)filter);
        else
            return null;
    }

    /**
     * @param lookupOp the LookupOp to be converted
     * @return a description of the SVG filter corresponding to
     *         lookupOp. The definition of the feComponentTransfer
     *         filter in put in feComponentTransferDefSet
     */
    public SVGFilterDescriptor toSVG(LookupOp lookupOp) {
        // Reuse definition if lookupOp has already been converted
        SVGFilterDescriptor filterDesc =
            (SVGFilterDescriptor)descMap.get(lookupOp);

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
            // Because we are using a LookupOp as a BufferedImageOp,
            // the number of lookup table must be:
            // + 1, in which case the same lookup is applied to the
            //   Red, Green and Blue components,
            // + 3, in which case the lookup tables apply to the
            //   Red, Green and Blue components
            // + 4, in which case the lookup tables apply to the
            //   Red, Green, Blue and Alpha components
            String[] lookupTables = convertLookupTables(lookupOp);

            Element feFuncR = domFactory.createElementNS(SVG_NAMESPACE_URI,
                                                         SVG_FE_FUNC_R_TAG);
            Element feFuncG = domFactory.createElementNS(SVG_NAMESPACE_URI,
                                                         SVG_FE_FUNC_G_TAG);
            Element feFuncB = domFactory.createElementNS(SVG_NAMESPACE_URI,
                                                         SVG_FE_FUNC_B_TAG);
            Element feFuncA = null;
            String type = SVG_TABLE_VALUE;

            if(lookupTables.length == 1){
                feFuncR.setAttributeNS(null, SVG_TYPE_ATTRIBUTE, type);
                feFuncG.setAttributeNS(null, SVG_TYPE_ATTRIBUTE, type);
                feFuncB.setAttributeNS(null, SVG_TYPE_ATTRIBUTE, type);
                feFuncR.setAttributeNS(null, SVG_TABLE_VALUES_ATTRIBUTE,
                                       lookupTables[0]);
                feFuncG.setAttributeNS(null, SVG_TABLE_VALUES_ATTRIBUTE,
                                       lookupTables[0]);
                feFuncB.setAttributeNS(null, SVG_TABLE_VALUES_ATTRIBUTE,
                                       lookupTables[0]);
            }
            else if(lookupTables.length >= 3){
                feFuncR.setAttributeNS(null, SVG_TYPE_ATTRIBUTE, type);
                feFuncG.setAttributeNS(null, SVG_TYPE_ATTRIBUTE, type);
                feFuncB.setAttributeNS(null, SVG_TYPE_ATTRIBUTE, type);
                feFuncR.setAttributeNS(null, SVG_TABLE_VALUES_ATTRIBUTE,
                                       lookupTables[0]);
                feFuncG.setAttributeNS(null, SVG_TABLE_VALUES_ATTRIBUTE,
                                       lookupTables[1]);
                feFuncB.setAttributeNS(null, SVG_TABLE_VALUES_ATTRIBUTE,
                                       lookupTables[2]);

                if(lookupTables.length == 4){
                    feFuncA = domFactory.createElementNS(SVG_NAMESPACE_URI,
                                                         SVG_FE_FUNC_A_TAG);
                    feFuncA.setAttributeNS(null, SVG_TYPE_ATTRIBUTE, type);
                    feFuncA.setAttributeNS(null, SVG_TABLE_VALUES_ATTRIBUTE,
                                           lookupTables[3]);
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
            descMap.put(lookupOp, filterDesc);
        }

        return filterDesc;
    }

    /**
     * Converts the filter's LookupTable into an array of corresponding SVG
     * table strings
     */
    private String[] convertLookupTables(LookupOp lookupOp){
        LookupTable lookupTable = lookupOp.getTable();
        int nComponents = lookupTable.getNumComponents();

        if((nComponents != 1) && (nComponents != 3) && (nComponents != 4))
            throw new SVGGraphics2DRuntimeException(ERR_ILLEGAL_BUFFERED_IMAGE_LOOKUP_OP);

        StringBuffer[] lookupTableBuf = new StringBuffer[nComponents];
        for(int i=0; i<nComponents; i++)
            lookupTableBuf[i] = new StringBuffer();

        if(!(lookupTable instanceof ByteLookupTable)){
            int[] src = new int[nComponents];
            int[] dest= new int[nComponents];
            int offset = lookupTable.getOffset();

            // Offsets are used for constrained sources. Therefore,
            // the lookup values should never be used under offset.
            // There is no SVG equivalent for this behavior.
            // These values are mapped to identity.
            for(int i=0; i<offset; i++){
                // Fill in string buffers
                for(int j=0; j<nComponents; j++){
                    // lookupTableBuf[j].append(Integer.toString(i));
                    lookupTableBuf[j].append(doubleString(i/255.0)).append(SPACE);
                }
            }

            for(int i=offset; i<=255; i++){
                // Fill in source array
                Arrays.fill( src, i );

                // Get destination values
                lookupTable.lookupPixel(src, dest);

                // Fill in string buffers
                for(int j=0; j<nComponents; j++){
                    lookupTableBuf[j].append(doubleString( dest[j]/255.0) ).append(SPACE);
                }
            }
        }
        else{
            byte[] src = new byte[nComponents];
            byte[] dest = new byte[nComponents];

            int offset = lookupTable.getOffset();

            // Offsets are used for constrained sources. Therefore,
            // the lookup values should never be used under offset.
            // There is no SVG equivalent for this behavior.
            // These values are mapped to identity.
            for(int i=0; i<offset; i++){
                // Fill in string buffers
                for(int j=0; j<nComponents; j++){
                    // lookupTableBuf[j].append(Integer.toString(i));
                    lookupTableBuf[j].append( doubleString(i/255.0) ).append(SPACE);
                }
            }
            for(int i=0; i<=255; i++){
                // Fill in source array
                Arrays.fill( src, (byte)(0xff & i) );

                // Get destination values
                ((ByteLookupTable)lookupTable).lookupPixel(src, dest);

                // Fill in string buffers
                for(int j=0; j<nComponents; j++){
                    lookupTableBuf[j].append( doubleString( (0xff & dest[j])/255.0) ).append(SPACE);
                }
            }
        }

        String[] lookupTables = new String[nComponents];
        for(int i=0; i<nComponents; i++)
            lookupTables[i] = lookupTableBuf[i].toString().trim();

        /*for(int i=0; i<lookupTables.length; i++){
            System.out.println(lookupTables[i]);
            }*/

        return lookupTables;
    }
}
