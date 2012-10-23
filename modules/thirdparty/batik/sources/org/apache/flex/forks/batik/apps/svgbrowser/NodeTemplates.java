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
package org.apache.flex.forks.batik.apps.svgbrowser;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import org.apache.flex.forks.batik.util.SVGConstants;
import org.w3c.dom.Node;

/**
 * Provides basic xml representation and description for most commonly used
 * nodes.
 *
 * @version $Id$
 */
public class NodeTemplates {

    // Node template descriptions provide basic information on node properties,
    // such as: xml represenation (suffix "Value"), element name
    // (suffix "Name"), element type (suffix "Type"), element category
    // (suffix "Category"), element description (suffix "Description").
    // Base node name on which these suffixes are appended is read from the
    // class members ending with "MemberName".

    // Example:
    // public static String rectMemberName = "rectElement";
    // Other class members that describe this node should be declared as:
    // rectElementValue = "...", rectElementType = "...", rectElementName =
    // "...", rectElementCategory = "..." and rectElementDescription = "..."

    // Suffixes
    public static final String VALUE = "Value";

    public static final String NAME = "Name";

    public static final String TYPE = "Type";

    public static final String DESCRIPTION = "Description";

    public static final String CATEGORY = "Category";

    // Categories
    public static final String BASIC_SHAPES = "Basic Shapes";

    public static final String LINKING = "Linking";

    public static final String TEXT = "Text";

    public static final String ANIMATION = "Animation";

    public static final String CLIP_MASK_COMPOSITE = "Clipping, Masking and Compositing";

    public static final String COLOR = "Color";

    public static final String INTERACTIVITY = "Interactivity";

    public static final String FONTS = "Fonts";

    public static final String DOCUMENT_STRUCTURE = "Document Structure";

    public static final String FILTER_EFFECTS = "Filter Effects";

    public static final String EXTENSIBILITY = "Extensibility";

    public static final String GRADIENTS_AND_PATTERNS = "Gradients and Patterns";

    public static final String PAINTING = "Painting: Filling, Stroking and Marker Symbols";

    public static final String METADATA = "Metadata";

    public static final String PATHS = "Paths";

    public static final String SCRIPTING = "Scripting";

    public static final String STYLING = "Styling";

    // Maps
    /**
     * Map with node template wrappers.
     */
    private Map nodeTemplatesMap = new HashMap();

    /**
     * List with all node categories.
     */
    private ArrayList categoriesList = new ArrayList();


    // Rect element
    public static String rectMemberName = "rectElement";

    public static String rectElementValue = "<rect width=\"0\" height=\"0\"/>";

    public static String rectElementName = SVGConstants.SVG_RECT_TAG;

    public static short rectElementType = Node.ELEMENT_NODE;

    public static String rectElementCategory = BASIC_SHAPES;

    public static String rectElementDescription = "Rect";

    // Circle element
    public static String circleMemberName = "circleElement";

    public static String circleElementValue = "<circle r=\"0\"/>";

    public static String circleElementName = SVGConstants.SVG_CIRCLE_TAG;

    public short circleElementType = Node.ELEMENT_NODE;

    public static String circleElementCategory = BASIC_SHAPES;

    public static String circleElementDescription = "Circle";

    // Line element
    public static String lineElementMemberName = "lineElement";

    public static String lineElementName = SVGConstants.SVG_LINE_TAG;

    public static String lineElementValue = "<line x1=\"0\" y1=\"0\" x2=\"0\" y2=\"0\"/>";

    public static short lineElementType = Node.ELEMENT_NODE;

    public static String lineElementCategory = BASIC_SHAPES;

    public static String lineElementDescription = "Text";

    // Path element
    public static String pathElementMemberName = "pathElement";

    public static String pathElementName = SVGConstants.SVG_PATH_TAG;

    public static String pathElementValue = "<path d=\"M0,0\"/>";

    public static short pathElementType = Node.ELEMENT_NODE;

    public static String pathElementCategory = PATHS;

    public static String pathElementDescription = "Path";

    // G element
    public static String groupElementMemberName = "groupElement";

    public static String groupElementName = SVGConstants.SVG_G_TAG;

    public static String groupElementValue = "<g/>";

    public static short groupElementType = Node.ELEMENT_NODE;

    public static String groupElementCategory = DOCUMENT_STRUCTURE;

    public static String groupElementDescription = "Group";

    // Ellipse element
    public static String ellipseElementMemberName = "ellipseElement";

    public static String ellipseElementName = SVGConstants.SVG_ELLIPSE_TAG;

    public static String ellipseElementValue = "<ellipse/>";

    public static short ellipseElementType = Node.ELEMENT_NODE;

    public static String ellipseElementCategory = BASIC_SHAPES;

    public static String ellipseElementDescription = "Ellipse";

    // Image element
    public static String imageElementMemberName = "imageElement";

    public static String imageElementName = SVGConstants.SVG_IMAGE_TAG;

    public static String imageElementValue = "<image xlink:href=\"file/c://\"/>";

    public static short imageElementType = Node.ELEMENT_NODE;

    public static String imageElementCategory = DOCUMENT_STRUCTURE;

    public static String imageElementDescription = "Image";

    // Polygon element
    public static String polygonElementMemberName = "polygonElement";

    public static String polygonElementName = SVGConstants.SVG_POLYGON_TAG;

    public static String polygonElementValue = "<polygon/>";

    public static short polygonElementType = Node.ELEMENT_NODE;

    public static String polygonElementCategory = BASIC_SHAPES;

    public static String polygonElementDescription = "Polygon";

    // Polyline element
    public static String polylineElementMemberName = "polylineElement";

    public static String polylineElementName = SVGConstants.SVG_POLYLINE_TAG;

    public static String polylineElementValue = "<polyline/>";

    public static short polylineElementType = Node.ELEMENT_NODE;

    public static String polylineElementCategory = BASIC_SHAPES;

    public static String polylineElementDescription = "Polyline";

    // Text element
    public static String textElementMemberName = "textElement";

    public static String textElementName = SVGConstants.SVG_TEXT_TAG;

    public static String textElementValue = "<text> </text>";

    public static short textElementType = Node.ELEMENT_NODE;

    public static String textElementCategory = TEXT;

    public static String textElementDescription = "Text";

    // TRef element
    public static String tRefElementMemberName = "tRefElement";

    public static String tRefElementName = SVGConstants.SVG_TREF_TAG;

    public static String tRefElementValue = "<tref/>";

    public static short tRefElementType = Node.ELEMENT_NODE;

    public static String tRefElementCategory = TEXT;

    public static String tRefElementDescription = "TRef";

    // TSpan element
    public static String tspanElementMemberName = "tspanElement";

    public static String tspanElementName = SVGConstants.SVG_TSPAN_TAG;

    public static String tspanElementValue = "<tspan/>";

    public static short tspanElementType = Node.ELEMENT_NODE;

    public static String tspanElementCategory = TEXT;

    public static String tspanElementDescription = "TSpan";

    // TextPath element
    public static String textPathElementMemberName = "textPathElement";

    public static String textPathElementName = SVGConstants.SVG_TEXT_PATH_TAG;

    public static String textPathElementValue = "<textPath/>";

    public static short textPathElementType = Node.ELEMENT_NODE;

    public static String textPathElementCategory = TEXT;

    public static String textPathElementDescription = "TextPath";

    // Svg element
    public static String svgElementMemberName = "svgElement";

    public static String svgElementName = SVGConstants.SVG_SVG_TAG;

    public static String svgElementValue = "<svg/>";

    public static short svgElementType = Node.ELEMENT_NODE;

    public static String svgElementCategory = DOCUMENT_STRUCTURE;

    public static String svgElementDescription = "svg";

    // FeBlend element
    public static String feBlendElementMemberName = "feBlendElement";

    public static String feBlendElementName = SVGConstants.SVG_FE_BLEND_TAG;

    public static String feBlendElementValue = "<feBlend/>";

    public static short feBlendElementType = Node.ELEMENT_NODE;

    public static String feBlendElementCategory = FILTER_EFFECTS;

    public static String feBlendElementDescription = "FeBlend";

    // FeColorMatrix element
    public static String feColorMatrixElementMemberName = "feColorMatrixElement";

    public static String feColorMatrixElementName = SVGConstants.SVG_FE_COLOR_MATRIX_TAG;

    public static String feColorMatrixElementValue = "<feColorMatrix/>";

    public static short feColorMatrixElementType = Node.ELEMENT_NODE;

    public static String feColorMatrixElementCategory = FILTER_EFFECTS;

    public static String feColorMatrixElementDescription = "FeColorMatrix";

    // FeComponentTransfer element
    public static String feComponentTransferElementMemberName = "feComponentTransferElement";

    public static String feComponentTransferElementName = SVGConstants.SVG_FE_COMPONENT_TRANSFER_TAG;

    public static String feComponentTransferElementValue = "<feComponentTransfer/>";

    public static short feComponentTransferElementType = Node.ELEMENT_NODE;

    public static String feComponentTransferElementCategory = FILTER_EFFECTS;

    public static String feComponentTransferElementDescription = "FeComponentTransfer";

    // FeComposite element
    public static String feCompositeElementMemberName = "feCompositeElement";

    public static String feCompositeElementName = SVGConstants.SVG_FE_COMPOSITE_TAG;

    public static String feCompositeElementValue = "<feComposite/>";

    public static short feCompositeElementType = Node.ELEMENT_NODE;

    public static String feCompositeElementCategory = FILTER_EFFECTS;

    public static String feCompositeElementDescription = "FeComposite";

    // FeConvolveMatrix element
    public static String feConvolveMatrixElementMemberName = "feConvolveMatrixElement";

    public static String feConvolveMatrixElementName = SVGConstants.SVG_FE_CONVOLVE_MATRIX_TAG;

    public static String feConvolveMatrixElementValue = "<feConvolveMatrix/>";

    public static short feConvolveMatrixElementType = Node.ELEMENT_NODE;

    public static String feConvolveMatrixElementCategory = FILTER_EFFECTS;

    public static String feConvolveMatrixElementDescription = "FeConvolveMatrix";

    // FeDiffuseLighting element
    public static String feDiffuseLightingElementMemberName = "feDiffuseLightingElement";

    public static String feDiffuseLightingElementName = SVGConstants.SVG_FE_DIFFUSE_LIGHTING_TAG;

    public static String feDiffuseLightingElementValue = "<feDiffuseLighting/>";

    public static short feDiffuseLightingElementType = Node.ELEMENT_NODE;

    public static String feDiffuseLightingElementCategory = FILTER_EFFECTS;

    public static String feDiffuseLightingElementDescription = "FeDiffuseLighting";

    // FeDisplacementMap element
    public static String feDisplacementMapElementMemberName = "feDisplacementMapElement";

    public static String feDisplacementMapElementName = SVGConstants.SVG_FE_DISPLACEMENT_MAP_TAG;

    public static String feDisplacementMapElementValue = "<feDisplacementMap/>";

    public static short feDisplacementMapElementType = Node.ELEMENT_NODE;

    public static String feDisplacementMapElementCategory = FILTER_EFFECTS;

    public static String feDisplacementMapElementDescription = "FeDisplacementMap";

    // FeDistantLight element
    public static String feDistantLightElementMemberName = "feDistantLightElement";

    public static String feDistantLightElementName = SVGConstants.SVG_FE_DISTANT_LIGHT_TAG;

    public static String feDistantLightElementValue = "<feDistantLight/>";

    public static short feDistantLightElementType = Node.ELEMENT_NODE;

    public static String feDistantLightElementCategory = FILTER_EFFECTS;

    public static String feDistantLightElementDescription = "FeDistantLight";

    // FeFlood element
    public static String feFloodElementMemberName = "feFloodElement";

    public static String feFloodElementName = SVGConstants.SVG_FE_FLOOD_TAG;

    public static String feFloodElementValue = "<feFlood/>";

    public static short feFloodElementType = Node.ELEMENT_NODE;

    public static String feFloodElementCategory = FILTER_EFFECTS;

    public static String feFloodElementDescription = "FeFlood";

    // FeFuncA element
    public static String feFuncAElementMemberName = "feFuncAElement";

    public static String feFuncAElementName = SVGConstants.SVG_FE_FUNC_A_TAG;

    public static String feFuncAElementValue = "<feFuncA/>";

    public static short feFuncAElementType = Node.ELEMENT_NODE;

    public static String feFuncAElementCategory = FILTER_EFFECTS;

    public static String feFuncAElementDescription = "FeFuncA";

    // FeFuncB element
    public static String feFuncBElementMemberName = "feFuncBElement";

    public static String feFuncBElementName = SVGConstants.SVG_FE_FUNC_B_TAG;

    public static String feFuncBElementValue = "<feFuncB/>";

    public static short feFuncBElementType = Node.ELEMENT_NODE;

    public static String feFuncBElementCategory = FILTER_EFFECTS;

    public static String feFuncBElementDescription = "FeFuncB";

    // FeFuncG element
    public static String feFuncGElementMemberName = "feFuncGElement";

    public static String feFuncGElementName = SVGConstants.SVG_FE_FUNC_G_TAG;

    public static String feFuncGElementValue = "<feFuncG/>";

    public static short feFuncGElementType = Node.ELEMENT_NODE;

    public static String feFuncGElementCategory = FILTER_EFFECTS;

    public static String feFuncGElementDescription = "FeFuncG";

    // FeFuncR element
    public static String feFuncRElementMemberName = "feFuncRElement";

    public static String feFuncRElementName = SVGConstants.SVG_FE_FUNC_R_TAG;

    public static String feFuncRElementValue = "<feFuncR/>";

    public static short feFuncRElementType = Node.ELEMENT_NODE;

    public static String feFuncRElementCategory = FILTER_EFFECTS;

    public static String feFuncRElementDescription = "FeFuncR";

    // FeGaussianBlur element
    public static String feGaussianBlurElementMemberName = "feGaussianBlurElement";

    public static String feGaussianBlurElementName = SVGConstants.SVG_FE_GAUSSIAN_BLUR_TAG;

    public static String feGaussianBlurElementValue = "<feGaussianBlur/>";

    public static short feGaussianBlurElementType = Node.ELEMENT_NODE;

    public static String feGaussianBlurElementCategory = FILTER_EFFECTS;

    public static String feGaussianBlurElementDescription = "FeGaussianBlur";

    // FeImage element
    public static String feImageElementMemberName = "feImageElement";

    public static String feImageElementName = SVGConstants.SVG_FE_IMAGE_TAG;

    public static String feImageElementValue = "<feImage/>";

    public static short feImageElementType = Node.ELEMENT_NODE;

    public static String feImageElementCategory = FILTER_EFFECTS;

    public static String feImageElementDescription = "FeImage";

    // FeMerge element
    public static String feMergeElementMemberName = "feImageElement";

    public static String feMergeElementName = SVGConstants.SVG_FE_MERGE_TAG;

    public static String feMergeElementValue = "<feMerge/>";

    public static short feMergeElementType = Node.ELEMENT_NODE;

    public static String feMergeElementCategory = FILTER_EFFECTS;

    public static String feMergeElementDescription = "FeMerge";

    // FeMergeNode element
    public static String feMergeNodeElementMemberName = "feMergeNodeElement";

    public static String feMergeNodeElementName = SVGConstants.SVG_FE_MERGE_NODE_TAG;

    public static String feMergeNodeElementValue = "<feMergeNode/>";

    public static short feMergeNodeElementType = Node.ELEMENT_NODE;

    public static String feMergeNodeElementCategory = FILTER_EFFECTS;

    public static String feMergeNodeElementDescription = "FeMergeNode";

    // FeMorphology element
    public static String feMorphologyElementMemberName = "feMorphologyElement";

    public static String feMorphologyElementName = SVGConstants.SVG_FE_MORPHOLOGY_TAG;

    public static String feMorphologyElementValue = "<feMorphology/>";

    public static short feMorphologyElementType = Node.ELEMENT_NODE;

    public static String feMorphologyElementCategory = FILTER_EFFECTS;

    public static String feMorphologyElementDescription = "FeMorphology";

    // FeOffset element
    public static String feOffsetElementMemberName = "feMorphologyElement";

    public static String feOffsetElementName = SVGConstants.SVG_FE_OFFSET_TAG;

    public static String feOffsetElementValue = "<feOffset/>";

    public static short feOffsetElementType = Node.ELEMENT_NODE;

    public static String feOffsetElementCategory = FILTER_EFFECTS;

    public static String feOffsetElementDescription = "FeOffset";

    // FePointLight element
    public static String fePointLightElementMemberName = "fePointLightElement";

    public static String fePointLightElementName = SVGConstants.SVG_FE_POINT_LIGHT_TAG;

    public static String fePointLightElementValue = "<fePointLight/>";

    public static short fePointLightElementType = Node.ELEMENT_NODE;

    public static String fePointLightElementCategory = FILTER_EFFECTS;

    public static String fePointLightElementDescription = "FePointLight";

    // FeSpecularLighting element
    public static String feSpecularLightingElementMemberName = "fePointLightElement";

    public static String feSpecularLightingElementName = SVGConstants.SVG_FE_SPECULAR_LIGHTING_TAG;

    public static String feSpecularLightingElementValue = "<feSpecularLighting/>";

    public static short feSpecularLightingElementType = Node.ELEMENT_NODE;

    public static String feSpecularLightingElementCategory = FILTER_EFFECTS;

    public static String feSpecularLightingElementDescription = "FeSpecularLighting";

    // FeSpotLight element
    public static String feSpotLightElementMemberName = "feSpotLightElement";

    public static String feSpotLightElementName = SVGConstants.SVG_FE_SPOT_LIGHT_TAG;

    public static String feSpotLightElementValue = "<feSpotLight/>";

    public static short feSpotLightElementType = Node.ELEMENT_NODE;

    public static String feSpotLightElementCategory = FILTER_EFFECTS;

    public static String feSpotLightElementDescription = "FeSpotLight";

    // FeTile element
    public static String feTileElementMemberName = "feTileElement";

    public static String feTileElementName = SVGConstants.SVG_FE_TILE_TAG;

    public static String feTileElementValue = "<feTile/>";

    public static short feTileElementType = Node.ELEMENT_NODE;

    public static String feTileElementCategory = FILTER_EFFECTS;

    public static String feTileElementDescription = "FeTile";

    // FeTurbulence element
    public static String feTurbulenceElementMemberName = "feTurbulenceElement";

    public static String feTurbulenceElementName = SVGConstants.SVG_FE_TURBULENCE_TAG;

    public static String feTurbulenceElementValue = "<feTurbulence/>";

    public static short feTurbulenceElementType = Node.ELEMENT_NODE;

    public static String feTurbulenceElementCategory = FILTER_EFFECTS;

    public static String feTurbulenceElementDescription = "FeTurbulence";

    // Filter element
    public static String filterElementMemberName = "filterElement";

    public static String filterElementName = SVGConstants.SVG_FILTER_TAG;

    public static String filterElementValue = "<filter/>";

    public static short filterElementType = Node.ELEMENT_NODE;

    public static String filterElementCategory = FILTER_EFFECTS;

    public static String filterElementDescription = "Filter";

//    // Text node
//    public static String textNodeMemberName = "textNode";
//
//    public static String textNodeName = "textNode";
//
//    public static String textNodeValue = " ";
//
//    public static short textNodeType = Node.TEXT_NODE;
//
//    public static String textNodeCategory = METADATA;
//
//    public static String textNodeDescription = "Text node";
//
//    // CDataSection node
//    public static String cdataSectionNodeMemberName = "cdataSectionNode";
//
//    public static String cdataSectionNodeName = "cdataSectionNode";
//
//    public static String cdataSectionNodeValue = " ";
//
//    public static short cdataSectionNodeType = Node.CDATA_SECTION_NODE;
//
//    public static String cdataSectionNodeCategory = METADATA;
//
//    public static String cdataSectionNodeDescription = "CDataSection";
//
//    // Comment node
//    public static String commentNodeMemberName = "commentNode";
//
//    public static String commentNodeName = "commentNode";
//
//    public static String commentNodeValue = " ";
//
//    public static short commentNodeType = Node.COMMENT_NODE;
//
//    public static String commentNodeCategory = METADATA;
//
//    public static String commentNodeDescription = "CommentNode";

    // A element
    public static String aElementMemberName = "aElement";

    public static String aElementName = SVGConstants.SVG_A_TAG;

    public static String aElementValue = "<a/>";

    public static short aElementType = Node.ELEMENT_NODE;

    public static String aElementCategory = LINKING;

    public static String aElementDescription = "A";

    // AltGlyph element
    public static String altGlyphElementMemberName = "altGlyphElement";

    public static String altGlyphElementName = SVGConstants.SVG_ALT_GLYPH_TAG;

    public static String altGlyphElementValue = "<altGlyph/>";

    public static short altGlyphElementType = Node.ELEMENT_NODE;

    public static String altGlyphElementCategory = TEXT;

    public static String altGlyphElementDescription = "AltGlyph";

    // AltGlyphDef element
    public static String altGlyphDefElementMemberName = "altGlyphDefElement";

    public static String altGlyphDefElementName = SVGConstants.SVG_ALT_GLYPH_DEF_TAG;

    public static String altGlyphDefElementValue = "<altGlyphDef/>";

    public static short altGlyphDefElementType = Node.ELEMENT_NODE;

    public static String altGlyphDefElementCategory = TEXT;

    public static String altGlyphDefElementDescription = "AltGlyphDef";

    // AltGlyphItem element
    public static String altGlyphItemElementMemberName = "altGlyphItemElement";

    public static String altGlyphItemElementName = SVGConstants.SVG_ALT_GLYPH_ITEM_TAG;

    public static String altGlyphItemElementValue = "<altGlyphItem/>";

    public static short altGlyphItemElementType = Node.ELEMENT_NODE;

    public static String altGlyphItemElementCategory = TEXT;

    public static String altGlyphItemElementDescription = "AltGlyphItem";

    // ClipPath element
    public static String clipPathElementMemberName = "clipPathElement";

    public static String clipPathElementName = SVGConstants.SVG_CLIP_PATH_TAG;

    public static String clipPathElementValue = "<clipPath/>";

    public static short clipPathElementType = Node.ELEMENT_NODE;

    public static String clipPathElementCategory = CLIP_MASK_COMPOSITE;

    public static String clipPathElementDescription = "ClipPath";

    // ColorProfile element
    public static String colorProfileElementMemberName = "colorProfileElement";

    public static String colorProfileElementName = SVGConstants.SVG_COLOR_PROFILE_TAG;

    public static String colorProfileElementValue = "<color-profile/>";

    public static short colorProfileElementType = Node.ELEMENT_NODE;

    public static String colorProfileElementCategory = COLOR;

    public static String colorProfileElementDescription = "ColorProfile";

    // Cursor element
    public static String cursorElementMemberName = "cursorElement";

    public static String cursorElementName = SVGConstants.SVG_CURSOR_TAG;

    public static String cursorElementValue = "<cursor/>";

    public static short cursorElementType = Node.ELEMENT_NODE;

    public static String cursorElementCategory = INTERACTIVITY;

    public static String cursorElementDescription = "Cursor";

    // DefinitionSrc element
    public static String definitionSrcElementMemberName = "definitionSrcElement";

    public static String definitionSrcElementName = SVGConstants.SVG_DEFINITION_SRC_TAG;

    public static String definitionSrcElementValue = "<definition-src/>";

    public static short definitionSrcElementType = Node.ELEMENT_NODE;

    public static String definitionSrcElementCategory = FONTS;

    public static String definitionSrcElementDescription = "DefinitionSrc";

    // Defs element
    public static String defsElementMemberName = "defsElement";

    public static String defsElementName = SVGConstants.SVG_DEFS_TAG;

    public static String defsElementValue = "<defs/>";

    public static short defsElementType = Node.ELEMENT_NODE;

    public static String defsElementCategory = DOCUMENT_STRUCTURE;

    public static String defsElementDescription = "Defs";

    // Desc element
    public static String descElementMemberName = "descElement";

    public static String descElementName = SVGConstants.SVG_DESC_TAG;

    public static String descElementValue = "<desc/>";

    public static short descElementType = Node.ELEMENT_NODE;

    public static String descElementCategory = DOCUMENT_STRUCTURE;

    public static String descElementDescription = "Desc";

    // ForeignObject element
    public static String foreignObjectElementMemberName = "foreignObjectElement";

    public static String foreignObjectElementName = SVGConstants.SVG_FOREIGN_OBJECT_TAG;

    public static String foreignObjectElementValue = "<foreignObject/>";

    public static short foreignObjectElementType = Node.ELEMENT_NODE;

    public static String foreignObjectElementCategory = EXTENSIBILITY;

    public static String foreignObjectElementDescription = "ForeignObject";

    // Glyph element
    public static String glyphElementMemberName = "glyphElement";

    public static String glyphElementName = SVGConstants.SVG_GLYPH_TAG;

    public static String glyphElementValue = "<glyph/>";

    public static short glyphElementType = Node.ELEMENT_NODE;

    public static String glyphElementCategory = FONTS;

    public static String glyphElementDescription = "Glyph";

    // GlyphRef element
    public static String glyphRefElementMemberName = "glyphRefElement";

    public static String glyphRefElementName = SVGConstants.SVG_GLYPH_REF_TAG;

    public static String glyphRefElementValue = "<glyphRef/>";

    public static short glyphRefElementType = Node.ELEMENT_NODE;

    public static String glyphRefElementCategory = TEXT;

    public static String glyphRefElementDescription = "GlyphRef";

    // Hkern element
    public static String hkernElementMemberName = "hkernElement";

    public static String hkernElementName = SVGConstants.SVG_HKERN_TAG;

    public static String hkernElementValue = "<hkern/>";

    public static short hkernElementType = Node.ELEMENT_NODE;

    public static String hkernElementCategory = FONTS;

    public static String hkernElementDescription = "Hkern";

    // LinearGradient element
    public static String linearGradientElementMemberName = "linearGradientElement";

    public static String linearGradientElementName = SVGConstants.SVG_LINEAR_GRADIENT_TAG;

    public static String linearGradientElementValue = "<linearGradient/>";

    public static short linearGradientElementType = Node.ELEMENT_NODE;

    public static String linearGradientElementCategory = GRADIENTS_AND_PATTERNS;

    public static String linearGradientElementDescription = "LinearGradient";

    // Marker element
    public static String markerElementMemberName = "markerElement";

    public static String markerElementName = SVGConstants.SVG_MARKER_TAG;

    public static String markerElementValue = "<marker/>";

    public static short markerElementType = Node.ELEMENT_NODE;

    public static String markerElementCategory = PAINTING;

    public static String markerElementDescription = "Marker";

    // Mask element
    public static String maskElementMemberName = "maskElement";

    public static String maskElementName = SVGConstants.SVG_MASK_TAG;

    public static String maskElementValue = "<mask/>";

    public static short maskElementType = Node.ELEMENT_NODE;

    public static String maskElementCategory = CLIP_MASK_COMPOSITE;

    public static String maskElementDescription = "Mask";

    // Metadata element
    public static String metadataElementMemberName = "metadataElement";

    public static String metadataElementName = SVGConstants.SVG_METADATA_TAG;

    public static String metadataElementValue = "<metadata/>";

    public static short metadataElementType = Node.ELEMENT_NODE;

    public static String metadataElementCategory = METADATA;

    public static String metadataElementDescription = "Metadata";

    // MissingGlyph element
    public static String missingGlyphElementMemberName = "missingGlyphElement";

    public static String missingGlyphElementName = SVGConstants.SVG_MISSING_GLYPH_TAG;

    public static String missingGlyphElementValue = "<missing-glyph/>";

    public static short missingGlyphElementType = Node.ELEMENT_NODE;

    public static String missingGlyphElementCategory = FONTS;

    public static String missingGlyphElementDescription = "MissingGlyph";

    // Mpath element
    public static String mpathElementMemberName = "mpathElement";

    public static String mpathElementName = SVGConstants.SVG_MPATH_TAG;

    public static String mpathElementValue = "<mpath/>";

    public static short mpathElementType = Node.ELEMENT_NODE;

    public static String mpathElementCategory = ANIMATION;

    public static String mpathElementDescription = "Mpath";

    // Pattern element
    public static String patternElementMemberName = "patternElement";

    public static String patternElementName = SVGConstants.SVG_PATTERN_TAG;

    public static String patternElementValue = "<pattern/>";

    public static short patternElementType = Node.ELEMENT_NODE;

    public static String patternElementCategory = GRADIENTS_AND_PATTERNS;

    public static String patternElementDescription = "Pattern";

    // RadialGradient element
    public static String radialGradientElementMemberName = "radialGradientElement";

    public static String radialGradientElementName = SVGConstants.SVG_RADIAL_GRADIENT_TAG;

    public static String radialGradientElementValue = "<radialGradient/>";

    public static short radialGradientElementType = Node.ELEMENT_NODE;

    public static String radialGradientElementCategory = GRADIENTS_AND_PATTERNS;

    public static String radialGradientElementDescription = "RadialGradient";

    // Script element
    public static String scriptElementMemberName = "scriptElement";

    public static String scriptElementName = SVGConstants.SVG_SCRIPT_TAG;

    public static String scriptElementValue = "<script/>";

    public static short scriptElementType = Node.ELEMENT_NODE;

    public static String scriptElementCategory = SCRIPTING;

    public static String scriptElementDescription = "script";

    // Set element
    public static String setElementMemberName = "setElement";

    public static String setElementName = SVGConstants.SVG_SET_TAG;

    public static String setElementValue = "<set attributeName=\"fill\" from=\"white\" to=\"black\" dur=\"1s\"/>";

    public static short setElementType = Node.ELEMENT_NODE;

    public static String setElementCategory = ANIMATION;

    public static String setElementDescription = "set";

    // Stop element
    public static String stopElementMemberName = "stopElement";

    public static String stopElementName = SVGConstants.SVG_STOP_TAG;

    public static String stopElementValue = "<stop/>";

    public static short stopElementType = Node.ELEMENT_NODE;

    public static String stopElementCategory = GRADIENTS_AND_PATTERNS;

    public static String stopElementDescription = "Stop";

    // Style element
    public static String styleElementMemberName = "styleElement";

    public static String styleElementName = SVGConstants.SVG_STYLE_TAG;

    public static String styleElementValue = "<style/>";

    public static short styleElementType = Node.ELEMENT_NODE;

    public static String styleElementCategory = STYLING;

    public static String styleElementDescription = "Style";

    // Switch element
    public static String switchElementMemberName = "switchElement";

    public static String switchElementName = SVGConstants.SVG_SWITCH_TAG;

    public static String switchElementValue = "<switch/>";

    public static short switchElementType = Node.ELEMENT_NODE;

    public static String switchElementCategory = DOCUMENT_STRUCTURE;

    public static String switchElementDescription = "Switch";

    // Symbol element
    public static String symbolElementMemberName = "symbolElement";

    public static String symbolElementName = SVGConstants.SVG_SYMBOL_TAG;

    public static String symbolElementValue = "<symbol/>";

    public static short symbolElementType = Node.ELEMENT_NODE;

    public static String symbolElementCategory = DOCUMENT_STRUCTURE;

    public static String symbolElementDescription = "Symbol";

    // Title element
    public static String titleElementMemberName = "titleElement";

    public static String titleElementName = SVGConstants.SVG_TITLE_TAG;

    public static String titleElementValue = "<title/>";

    public static short titleElementType = Node.ELEMENT_NODE;

    public static String titleElementCategory = DOCUMENT_STRUCTURE;

    public static String titleElementDescription = "Title";

    // Use element
    public static String useElementMemberName = "useElement";

    public static String useElementName = SVGConstants.SVG_USE_TAG;

    public static String useElementValue = "<use/>";

    public static short useElementType = Node.ELEMENT_NODE;

    public static String useElementCategory = DOCUMENT_STRUCTURE;

    public static String useElementDescription = "Use";

    // View element
    public static String viewElementMemberName = "viewElement";

    public static String viewElementName = SVGConstants.SVG_VIEW_TAG;

    public static String viewElementValue = "<view/>";

    public static short viewElementType = Node.ELEMENT_NODE;

    public static String viewElementCategory = LINKING;

    public static String viewElementDescription = "View";

    // Vkern element
    public static String vkernElementMemberName = "vkernElement";

    public static String vkernElementName = SVGConstants.SVG_VKERN_TAG;

    public static String vkernElementValue = "<vkern/>";

    public static short vkernElementType = Node.ELEMENT_NODE;

    public static String vkernElementCategory = FONTS;

    public static String vkernElementDescription = "Vkern";

    // Font element
    public static String fontElementMemberName = "fontElement";

    public static String fontElementName = SVGConstants.SVG_FONT_TAG;

    public static String fontElementValue = "<font/>";

    public static short fontElementType = Node.ELEMENT_NODE;

    public static String fontElementCategory = FONTS;

    public static String fontElementDescription = "Font";

    // FontFace element
    public static String fontFaceElementMemberName = "fontFaceElement";

    public static String fontFaceElementName = SVGConstants.SVG_FONT_FACE_TAG;

    public static String fontFaceElementValue = "<font-face/>";

    public static short fontFaceElementType = Node.ELEMENT_NODE;

    public static String fontFaceElementCategory = FONTS;

    public static String fontFaceElementDescription = "FontFace";

    // FontFaceFormat element
    public static String fontFaceFormatElementMemberName = "fontFaceFormatElement";

    public static String fontFaceFormatElementName = SVGConstants.SVG_FONT_FACE_FORMAT_TAG;

    public static String fontFaceFormatElementValue = "<font-face-format/>";

    public static short fontFaceFormatElementType = Node.ELEMENT_NODE;

    public static String fontFaceFormatElementCategory = FONTS;

    public static String fontFaceFormatElementDescription = "FontFaceFormat";

    // FontFaceName element
    public static String fontFaceNameElementMemberName = "fontFaceNameElement";

    public static String fontFaceNameElementName = SVGConstants.SVG_FONT_FACE_NAME_TAG;

    public static String fontFaceNameElementValue = "<font-face-name/>";

    public static short fontFaceNameElementType = Node.ELEMENT_NODE;

    public static String fontFaceNameElementCategory = FONTS;

    public static String fontFaceNameElementDescription = "FontFaceName";

    // FontFaceSrc element
    public static String fontFaceSrcElementMemberName = "fontFaceSrcElement";

    public static String fontFaceSrcElementName = SVGConstants.SVG_FONT_FACE_SRC_TAG;

    public static String fontFaceSrcElementValue = "<font-face-src/>";

    public static short fontFaceSrcElementType = Node.ELEMENT_NODE;

    public static String fontFaceSrcElementCategory = FONTS;

    public static String fontFaceSrcElementDescription = "FontFaceSrc";

    // FontFaceUri element
    public static String fontFaceUriElementMemberName = "fontFaceUriElement";

    public static String fontFaceUriElementName = SVGConstants.SVG_FONT_FACE_URI_TAG;

    public static String fontFaceUriElementValue = "<font-face-uri/>";

    public static short fontFaceUriElementType = Node.ELEMENT_NODE;

    public static String fontFaceUriElementCategory = FONTS;

    public static String fontFaceUriElementDescription = "FontFaceUri";

    // Animate element
    public static String animateElementMemberName = "fontFaceUriElement";

    public static String animateElementName = SVGConstants.SVG_ANIMATE_TAG;

    public static String animateElementValue = "<animate attributeName=\"fill\" from=\"white\" to=\"black\" dur=\"1s\"/>";

    public static short animateElementType = Node.ELEMENT_NODE;

    public static String animateElementCategory = ANIMATION;

    public static String animateElementDescription = "Animate";

    // AnimateColor element
    public static String animateColorElementMemberName = "animateColorElement";

    public static String animateColorElementName = SVGConstants.SVG_ANIMATE_COLOR_TAG;

    public static String animateColorElementValue = "<animateColor attributeName=\"fill\" from=\"white\" to=\"black\" dur=\"1s\"/>";

    public static short animateColorElementType = Node.ELEMENT_NODE;

    public static String animateColorElementCategory = ANIMATION;

    public static String animateColorElementDescription = "AnimateColor";

    // AnimateMotion element
    public static String animateMotionElementMemberName = "animateMotionElement";

    public static String animateMotionElementName = SVGConstants.SVG_ANIMATE_MOTION_TAG;

    public static String animateMotionElementValue = "<animateMotion dur=\"1s\" path=\"M0,0\"/>";

    public static short animateMotionElementType = Node.ELEMENT_NODE;

    public static String animateMotionElementCategory = ANIMATION;

    public static String animateMotionElementDescription = "AnimateMotion";

    // AnimateTransform element
    public static String animateTransformElementMemberName = "animateTransformElement";

    public static String animateTransformElementName = SVGConstants.SVG_ANIMATE_TRANSFORM_TAG;

    public static String animateTransformElementValue = "<animateTransform attributeName=\"transform\" type=\"rotate\" from=\"0\" to=\"0\" dur=\"1s\"/>";

    public static short animateTransformElementType = Node.ELEMENT_NODE;

    public static String animateTransformElementCategory = ANIMATION;

    public static String animateTransformElementDescription = "AnimateTransform";

    /**
     * Constructor.
     */
    public NodeTemplates() {
        // Initialize categories
        categoriesList.add(DOCUMENT_STRUCTURE);
        categoriesList.add(STYLING);
        categoriesList.add(PATHS);
        categoriesList.add(BASIC_SHAPES);
        categoriesList.add(TEXT);
        categoriesList.add(PAINTING);
        categoriesList.add(COLOR);
        categoriesList.add(GRADIENTS_AND_PATTERNS);
        categoriesList.add(CLIP_MASK_COMPOSITE);
        categoriesList.add(FILTER_EFFECTS);
        categoriesList.add(INTERACTIVITY);
        categoriesList.add(LINKING);
        categoriesList.add(SCRIPTING);
        categoriesList.add(ANIMATION);
        categoriesList.add(FONTS);
        categoriesList.add(METADATA);
        categoriesList.add(EXTENSIBILITY);

        // Initialize templates
        initializeTemplates();
    }

    /**
     * Initializes node templates.
     */
    private void initializeTemplates() {
        Field[] fields = getClass().getDeclaredFields();
        for (int i = 0; i < fields.length; i++) {
            Field currentField = fields[i];
            try {
                if (currentField.getType() == String.class
                        && currentField.getName().endsWith("MemberName")) {
                    boolean isAccessible = currentField.isAccessible();
                    currentField.setAccessible(true);
                    String baseFieldName = currentField.get(this).toString();
                    String nodeValue = getClass().getField(
                            baseFieldName + VALUE).get(this).toString();
                    String nodeName = getClass().getField(baseFieldName + NAME)
                            .get(this).toString();
                    short nodeType = ((Short) getClass().getField(
                            baseFieldName + TYPE).get(this)).shortValue();
                    String nodeDescription = getClass().getField(
                            baseFieldName + DESCRIPTION).get(this).toString();
                    String nodeCategory = getClass().getField(
                            baseFieldName + CATEGORY).get(this).toString();
                    NodeTemplateDescriptor desc = new NodeTemplateDescriptor(
                            nodeName, nodeValue, nodeType, nodeCategory,
                            nodeDescription);
                    nodeTemplatesMap.put(desc.getName(), desc);
                    currentField.setAccessible(isAccessible);
                }
            } catch (IllegalArgumentException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (SecurityException e) {
                e.printStackTrace();
            } catch (NoSuchFieldException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Wrapper for a node template. Provides the information on the node
     */
    public static class NodeTemplateDescriptor {

        /**
         * Node name.
         */
        private String name;

        /**
         * Node xml representation.
         */
        private String xmlValue;

        /**
         * Node type.
         */
        private short type;

        /**
         * Node category.
         */
        private String category;

        /**
         * Short node description.
         */
        private String description;

        /**
         * Constructor.
         */
        public NodeTemplateDescriptor(String name, String xmlValue, short type,
                String category, String description) {
            this.name = name;
            this.xmlValue = xmlValue;
            this.type = type;
            this.category = category;
            this.description = description;
        }

        public String getCategory() {
            return category;
        }

        public void setCategory(String category) {
            this.category = category;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public short getType() {
            return type;
        }

        public void setType(short type) {
            this.type = type;
        }

        public String getXmlValue() {
            return xmlValue;
        }

        public void setXmlValue(String xmlValue) {
            this.xmlValue = xmlValue;
        }
    }

    /**
     * Gets the categories list.
     *
     * @return categoriesList
     */
    public ArrayList getCategories() {
        return categoriesList;
    }

    /**
     * Map of objects describing node templates.
     *
     * @return nodeTemplatesMap
     */
    public Map getNodeTemplatesMap() {
        return nodeTemplatesMap;
    }
}
