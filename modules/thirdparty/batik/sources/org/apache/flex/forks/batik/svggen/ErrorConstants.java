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

/**
 *
 * @version $Id: ErrorConstants.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public interface ErrorConstants {
    // general errors

    String ERR_UNEXPECTED =
        "unexpected exception";
    String ERR_CONTEXT_NULL =
        "generatorContext should not be null";

    /// image handling errors

    String ERR_IMAGE_DIR_NULL =
        "imageDir should not be null";
    String ERR_IMAGE_DIR_DOES_NOT_EXIST =
        "imageDir does not exist";
    String ERR_CANNOT_USE_IMAGE_DIR =
        "cannot convert imageDir to a URL value : ";
    String ERR_IMAGE_NULL =
        "image should not be null";
    String ERR_WRITE =
        "could not write image File ";
    String ERR_READ =
        "could not read image File ";
    String ERR_IMAGE_HANDLER_NOT_SUPPORTED =
        "imageHandler does not implement CachedImageHandler: ";

    // SVGGraphics2D errors

    String ERR_CANVAS_SIZE_NULL =
        "canvas size should not be null";
    String ERR_XOR =
        "XOR Mode is not supported by Graphics2D SVG Generator";
    String ERR_ACI =
        "AttributedCharacterIterator not supported yet";

    // XmlWriter
    String ERR_PROXY =
        "proxy should not be null";
    String INVALID_NODE =
        "Unable to write node of type ";

    // DOMGroup/TreeManager

    String ERR_GC_NULL = "gc should not be null";
    String ERR_DOMTREEMANAGER_NULL =
        "domTreeManager should not be null";
    String ERR_MAXGCOVERRIDES_OUTOFRANGE =
        "maxGcOverrides should be greater than zero";
    String ERR_TOP_LEVEL_GROUP_NULL =
        "topLevelGroup should not be null";
    String ERR_TOP_LEVEL_GROUP_NOT_G =
        "topLevelGroup should be a group <g>";

    // SVGClip/Font/Hint/Stroke descriptor
    String ERR_CLIP_NULL = "clipPathValue should not be null";
    String ERR_FONT_NULL =
        "none of the font description parameters should be null";
    String ERR_HINT_NULL =
        "none of the hints description parameters should be null";
    String ERR_STROKE_NULL =
        "none of the stroke description parameters should be null";

    // context
    String ERR_MAP_NULL = "context map(s) should not be null";
    String ERR_TRANS_NULL =
        "transformer stack should not be null";

    // SVGLookUp/RescaleOp
    String ERR_ILLEGAL_BUFFERED_IMAGE_LOOKUP_OP =
        "BufferedImage LookupOp should have 1, 3 or 4 lookup arrays";
    String ERR_SCALE_FACTORS_AND_OFFSETS_MISMATCH =
        "RescapeOp offsets and scaleFactor array length do not match";
    String ERR_ILLEGAL_BUFFERED_IMAGE_RESCALE_OP =
        "BufferedImage RescaleOp should have 1, 3 or 4 scale factors";


    // SVGGeneratorContext
    String ERR_DOM_FACTORY_NULL =
        "domFactory should not be null";
    String ERR_IMAGE_HANDLER_NULL =
        "imageHandler should not be null";
    String ERR_EXTENSION_HANDLER_NULL =
        "extensionHandler should not be null";
    String ERR_ID_GENERATOR_NULL =
        "idGenerator should not be null";
    String ERR_STYLE_HANDLER_NULL =
        "styleHandler should not be null";
    String ERR_ERROR_HANDLER_NULL =
        "errorHandler should not be null";
}
