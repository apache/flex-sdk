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
package org.apache.flex.forks.batik.dom.svg;

import java.net.URL;

import org.apache.flex.forks.batik.css.dom.CSSOMSVGViewCSS;
import org.apache.flex.forks.batik.css.engine.CSSContext;
import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.css.engine.value.ShorthandManager;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.css.parser.ExtendedParser;
import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.AbstractStylableDocument;
import org.apache.flex.forks.batik.dom.ExtensibleDOMImplementation;
import org.apache.flex.forks.batik.dom.GenericDocumentType;
import org.apache.flex.forks.batik.dom.events.DOMTimeEvent;
import org.apache.flex.forks.batik.dom.events.DocumentEventSupport;
import org.apache.flex.forks.batik.dom.util.CSSStyleDeclarationFactory;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.dom.util.HashTable;
import org.apache.flex.forks.batik.i18n.LocalizableSupport;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.SVGConstants;

import org.w3c.css.sac.InputSource;
import org.w3c.dom.DOMException;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.DocumentType;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.css.CSSStyleDeclaration;
import org.w3c.dom.css.CSSStyleSheet;
import org.w3c.dom.css.ViewCSS;
import org.w3c.dom.events.Event;
import org.w3c.dom.stylesheets.StyleSheet;

/**
 * This class implements the {@link DOMImplementation} interface.
 * It provides support the SVG 1.1 documents.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGDOMImplementation.java 578768 2007-09-24 11:53:45Z cam $
 */
public class SVGDOMImplementation
    extends    ExtensibleDOMImplementation
    implements CSSStyleDeclarationFactory {

    /**
     * The SVG namespace uri.
     */
    public static final String SVG_NAMESPACE_URI =
        SVGConstants.SVG_NAMESPACE_URI;

    /**
     * The error messages bundle class name.
     */
    protected static final String RESOURCES =
        "org.apache.flex.forks.batik.dom.svg.resources.Messages";

    protected HashTable factories;

    /**
     * Returns the default instance of this class.
     */
    public static DOMImplementation getDOMImplementation() {
        return DOM_IMPLEMENTATION;
    }

    /**
     * Creates a new SVGDOMImplementation object.
     */
    public SVGDOMImplementation() {
        factories = svg11Factories;
        registerFeature("CSS",            "2.0");
        registerFeature("StyleSheets",    "2.0");
        registerFeature("SVG",            new String[] {"1.0", "1.1"});
        registerFeature("SVGEvents",      new String[] {"1.0", "1.1"});
    }

    protected void initLocalizable() {
        localizableSupport = new LocalizableSupport
            (RESOURCES, getClass().getClassLoader());
    }

    public CSSEngine createCSSEngine(AbstractStylableDocument doc,
                                     CSSContext               ctx,
                                     ExtendedParser           ep,
                                     ValueManager     []      vms,
                                     ShorthandManager []      sms) {

        ParsedURL durl = ((SVGOMDocument)doc).getParsedURL();
        CSSEngine result = new SVGCSSEngine(doc, durl, ep, vms, sms, ctx);

        URL url = getClass().getResource("resources/UserAgentStyleSheet.css");
        if (url != null) {
            ParsedURL purl = new ParsedURL(url);
            InputSource is = new InputSource(purl.toString());
            result.setUserAgentStyleSheet
                (result.parseStyleSheet(is, purl, "all"));
        }

        return result;
    }

    /**
     * Creates a ViewCSS.
     */
    public ViewCSS createViewCSS(AbstractStylableDocument doc) {
        return new CSSOMSVGViewCSS(doc.getCSSEngine());
    }

    /**
     * <b>DOM</b>: Implements {@link
     * DOMImplementation#createDocumentType(String,String,String)}.
     */
    public DocumentType createDocumentType(String qualifiedName,
                                           String publicId,
                                           String systemId) {
        return new GenericDocumentType(qualifiedName, publicId, systemId);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * DOMImplementation#createDocument(String,String,DocumentType)}.
     */
    public Document createDocument(String namespaceURI,
                                   String qualifiedName,
                                   DocumentType doctype)
        throws DOMException {
        Document result = new SVGOMDocument(doctype, this);
        // BUG 32108: return empty document if qualifiedName is null.
        if (qualifiedName != null)
            result.appendChild(result.createElementNS(namespaceURI,
                                                      qualifiedName));
        return result;
    }

    // DOMImplementationCSS /////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.css.DOMImplementationCSS#createCSSStyleSheet(String,String)}.
     */
    public CSSStyleSheet createCSSStyleSheet(String title, String media) {
        throw new UnsupportedOperationException
            ("DOMImplementationCSS.createCSSStyleSheet is not implemented"); // XXX
    }

    // CSSStyleDeclarationFactory ///////////////////////////////////////////

    /**
     * Creates a style declaration.
     * @return a CSSOMStyleDeclaration instance.
     */
    public CSSStyleDeclaration createCSSStyleDeclaration() {
        throw new UnsupportedOperationException
            ("CSSStyleDeclarationFactory.createCSSStyleDeclaration is not implemented"); // XXX
    }

    // StyleSheetFactory /////////////////////////////////////////////

    /**
     * Creates a stylesheet from the data of an xml-stylesheet
     * processing instruction or return null.
     */
    public StyleSheet createStyleSheet(Node n, HashTable attrs) {
        throw new UnsupportedOperationException
            ("StyleSheetFactory.createStyleSheet is not implemented"); // XXX
    }

    /**
     * Returns the user-agent stylesheet.
     */
    public CSSStyleSheet getUserAgentStyleSheet() {
        throw new UnsupportedOperationException
            ("StyleSheetFactory.getUserAgentStyleSheet is not implemented"); // XXX
    }

    /**
     * Implements the behavior of Document.createElementNS() for this
     * DOM implementation.
     */
    public Element createElementNS(AbstractDocument document,
                                   String           namespaceURI,
                                   String           qualifiedName) {
        if (SVGConstants.SVG_NAMESPACE_URI.equals(namespaceURI)) {
            String name = DOMUtilities.getLocalName(qualifiedName);
            ElementFactory ef = (ElementFactory)factories.get(name);
            if (ef != null)
                return ef.create(DOMUtilities.getPrefix(qualifiedName),
                                 document);
            throw document.createDOMException
                (DOMException.NOT_FOUND_ERR, "invalid.element",
                 new Object[] { namespaceURI, qualifiedName });
        }

        return super.createElementNS(document, namespaceURI, qualifiedName);
    }

    /**
     * Creates an DocumentEventSupport object suitable for use with
     * this implementation.
     */
    public DocumentEventSupport createDocumentEventSupport() {
        DocumentEventSupport result =  new DocumentEventSupport();
        result.registerEventFactory("SVGEvents",
                                    new DocumentEventSupport.EventFactory() {
                                            public Event createEvent() {
                                                return new SVGOMEvent();
                                            }
                                        });
        result.registerEventFactory("TimeEvent",
                                    new DocumentEventSupport.EventFactory() {
                                            public Event createEvent() {
                                                return new DOMTimeEvent();
                                            }
                                        });
        return result;
    }

    // The element factories /////////////////////////////////////////////////

    /**
     * The SVG element factories.
     */
    protected static HashTable svg11Factories = new HashTable();

    static {
        svg11Factories.put(SVGConstants.SVG_A_TAG,
                           new AElementFactory());

        svg11Factories.put(SVGConstants.SVG_ALT_GLYPH_TAG,
                           new AltGlyphElementFactory());

        svg11Factories.put(SVGConstants.SVG_ALT_GLYPH_DEF_TAG,
                           new AltGlyphDefElementFactory());

        svg11Factories.put(SVGConstants.SVG_ALT_GLYPH_ITEM_TAG,
                           new AltGlyphItemElementFactory());

        svg11Factories.put(SVGConstants.SVG_ANIMATE_TAG,
                           new AnimateElementFactory());

        svg11Factories.put(SVGConstants.SVG_ANIMATE_COLOR_TAG,
                           new AnimateColorElementFactory());

        svg11Factories.put(SVGConstants.SVG_ANIMATE_MOTION_TAG,
                           new AnimateMotionElementFactory());

        svg11Factories.put(SVGConstants.SVG_ANIMATE_TRANSFORM_TAG,
                           new AnimateTransformElementFactory());

        svg11Factories.put(SVGConstants.SVG_CIRCLE_TAG,
                           new CircleElementFactory());

        svg11Factories.put(SVGConstants.SVG_CLIP_PATH_TAG,
                           new ClipPathElementFactory());

        svg11Factories.put(SVGConstants.SVG_COLOR_PROFILE_TAG,
                           new ColorProfileElementFactory());

        svg11Factories.put(SVGConstants.SVG_CURSOR_TAG,
                           new CursorElementFactory());

        svg11Factories.put(SVGConstants.SVG_DEFINITION_SRC_TAG,
                           new DefinitionSrcElementFactory());

        svg11Factories.put(SVGConstants.SVG_DEFS_TAG,
                           new DefsElementFactory());

        svg11Factories.put(SVGConstants.SVG_DESC_TAG,
                           new DescElementFactory());

        svg11Factories.put(SVGConstants.SVG_ELLIPSE_TAG,
                           new EllipseElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_BLEND_TAG,
                           new FeBlendElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_COLOR_MATRIX_TAG,
                           new FeColorMatrixElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_COMPONENT_TRANSFER_TAG,
                           new FeComponentTransferElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_COMPOSITE_TAG,
                           new FeCompositeElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_CONVOLVE_MATRIX_TAG,
                           new FeConvolveMatrixElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_DIFFUSE_LIGHTING_TAG,
                           new FeDiffuseLightingElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_DISPLACEMENT_MAP_TAG,
                           new FeDisplacementMapElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_DISTANT_LIGHT_TAG,
                           new FeDistantLightElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_FLOOD_TAG,
                           new FeFloodElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_FUNC_A_TAG,
                           new FeFuncAElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_FUNC_R_TAG,
                           new FeFuncRElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_FUNC_G_TAG,
                           new FeFuncGElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_FUNC_B_TAG,
                           new FeFuncBElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_GAUSSIAN_BLUR_TAG,
                           new FeGaussianBlurElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_IMAGE_TAG,
                           new FeImageElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_MERGE_TAG,
                           new FeMergeElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_MERGE_NODE_TAG,
                           new FeMergeNodeElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_MORPHOLOGY_TAG,
                           new FeMorphologyElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_OFFSET_TAG,
                           new FeOffsetElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_POINT_LIGHT_TAG,
                           new FePointLightElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_SPECULAR_LIGHTING_TAG,
                           new FeSpecularLightingElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_SPOT_LIGHT_TAG,
                           new FeSpotLightElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_TILE_TAG,
                           new FeTileElementFactory());

        svg11Factories.put(SVGConstants.SVG_FE_TURBULENCE_TAG,
                           new FeTurbulenceElementFactory());

        svg11Factories.put(SVGConstants.SVG_FILTER_TAG,
                           new FilterElementFactory());

        svg11Factories.put(SVGConstants.SVG_FONT_TAG,
                           new FontElementFactory());

        svg11Factories.put(SVGConstants.SVG_FONT_FACE_TAG,
                           new FontFaceElementFactory());

        svg11Factories.put(SVGConstants.SVG_FONT_FACE_FORMAT_TAG,
                           new FontFaceFormatElementFactory());

        svg11Factories.put(SVGConstants.SVG_FONT_FACE_NAME_TAG,
                           new FontFaceNameElementFactory());

        svg11Factories.put(SVGConstants.SVG_FONT_FACE_SRC_TAG,
                           new FontFaceSrcElementFactory());

        svg11Factories.put(SVGConstants.SVG_FONT_FACE_URI_TAG,
                           new FontFaceUriElementFactory());

        svg11Factories.put(SVGConstants.SVG_FOREIGN_OBJECT_TAG,
                           new ForeignObjectElementFactory());

        svg11Factories.put(SVGConstants.SVG_G_TAG,
                           new GElementFactory());

        svg11Factories.put(SVGConstants.SVG_GLYPH_TAG,
                           new GlyphElementFactory());

        svg11Factories.put(SVGConstants.SVG_GLYPH_REF_TAG,
                           new GlyphRefElementFactory());

        svg11Factories.put(SVGConstants.SVG_HKERN_TAG,
                           new HkernElementFactory());

        svg11Factories.put(SVGConstants.SVG_IMAGE_TAG,
                           new ImageElementFactory());

        svg11Factories.put(SVGConstants.SVG_LINE_TAG,
                           new LineElementFactory());

        svg11Factories.put(SVGConstants.SVG_LINEAR_GRADIENT_TAG,
                           new LinearGradientElementFactory());

        svg11Factories.put(SVGConstants.SVG_MARKER_TAG,
                           new MarkerElementFactory());

        svg11Factories.put(SVGConstants.SVG_MASK_TAG,
                           new MaskElementFactory());

        svg11Factories.put(SVGConstants.SVG_METADATA_TAG,
                           new MetadataElementFactory());

        svg11Factories.put(SVGConstants.SVG_MISSING_GLYPH_TAG,
                           new MissingGlyphElementFactory());

        svg11Factories.put(SVGConstants.SVG_MPATH_TAG,
                           new MpathElementFactory());

        svg11Factories.put(SVGConstants.SVG_PATH_TAG,
                           new PathElementFactory());

        svg11Factories.put(SVGConstants.SVG_PATTERN_TAG,
                           new PatternElementFactory());

        svg11Factories.put(SVGConstants.SVG_POLYGON_TAG,
                           new PolygonElementFactory());

        svg11Factories.put(SVGConstants.SVG_POLYLINE_TAG,
                           new PolylineElementFactory());

        svg11Factories.put(SVGConstants.SVG_RADIAL_GRADIENT_TAG,
                           new RadialGradientElementFactory());

        svg11Factories.put(SVGConstants.SVG_RECT_TAG,
                           new RectElementFactory());

        svg11Factories.put(SVGConstants.SVG_SET_TAG,
                           new SetElementFactory());

        svg11Factories.put(SVGConstants.SVG_SCRIPT_TAG,
                           new ScriptElementFactory());

        svg11Factories.put(SVGConstants.SVG_STOP_TAG,
                           new StopElementFactory());

        svg11Factories.put(SVGConstants.SVG_STYLE_TAG,
                           new StyleElementFactory());

        svg11Factories.put(SVGConstants.SVG_SVG_TAG,
                           new SvgElementFactory());

        svg11Factories.put(SVGConstants.SVG_SWITCH_TAG,
                           new SwitchElementFactory());

        svg11Factories.put(SVGConstants.SVG_SYMBOL_TAG,
                           new SymbolElementFactory());

        svg11Factories.put(SVGConstants.SVG_TEXT_TAG,
                           new TextElementFactory());

        svg11Factories.put(SVGConstants.SVG_TEXT_PATH_TAG,
                           new TextPathElementFactory());

        svg11Factories.put(SVGConstants.SVG_TITLE_TAG,
                           new TitleElementFactory());

        svg11Factories.put(SVGConstants.SVG_TREF_TAG,
                           new TrefElementFactory());

        svg11Factories.put(SVGConstants.SVG_TSPAN_TAG,
                           new TspanElementFactory());

        svg11Factories.put(SVGConstants.SVG_USE_TAG,
                           new UseElementFactory());

        svg11Factories.put(SVGConstants.SVG_VIEW_TAG,
                           new ViewElementFactory());

        svg11Factories.put(SVGConstants.SVG_VKERN_TAG,
                           new VkernElementFactory());
    }

    /**
     * To create a 'a' element.
     */
    protected static class AElementFactory implements ElementFactory {
        public AElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMAElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'altGlyph' element.
     */
    protected static class AltGlyphElementFactory implements ElementFactory {
        public AltGlyphElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMAltGlyphElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'altGlyphDef' element.
     */
    protected static class AltGlyphDefElementFactory
        implements ElementFactory {
        public AltGlyphDefElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMAltGlyphDefElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'altGlyphItem' element.
     */
    protected static class AltGlyphItemElementFactory
        implements ElementFactory {
        public AltGlyphItemElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMAltGlyphItemElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'animate' element.
     */
    protected static class AnimateElementFactory implements ElementFactory {
        public AnimateElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMAnimateElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'animateColor' element.
     */
    protected static class AnimateColorElementFactory
        implements ElementFactory {
        public AnimateColorElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMAnimateColorElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'animateMotion' element.
     */
    protected static class AnimateMotionElementFactory
        implements ElementFactory {
        public AnimateMotionElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMAnimateMotionElement(prefix,
                                                 (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'animateTransform' element.
     */
    protected static class AnimateTransformElementFactory
        implements ElementFactory {
        public AnimateTransformElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMAnimateTransformElement(prefix,
                                                    (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'circle' element.
     */
    protected static class CircleElementFactory implements ElementFactory {
        public CircleElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMCircleElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'clip-path' element.
     */
    protected static class ClipPathElementFactory implements ElementFactory {
        public ClipPathElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMClipPathElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'color-profile' element.
     */
    protected static class ColorProfileElementFactory
        implements ElementFactory {
        public ColorProfileElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMColorProfileElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'cursor' element.
     */
    protected static class CursorElementFactory implements ElementFactory {
        public CursorElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMCursorElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'definition-src' element.
     */
    protected static class DefinitionSrcElementFactory
        implements ElementFactory {
        public DefinitionSrcElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMDefinitionSrcElement(prefix,
                                                 (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'defs' element.
     */
    protected static class DefsElementFactory implements ElementFactory {
        public DefsElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMDefsElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'desc' element.
     */
    protected static class DescElementFactory implements ElementFactory {
        public DescElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMDescElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create an 'ellipse' element.
     */
    protected static class EllipseElementFactory implements ElementFactory {
        public EllipseElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMEllipseElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feBlend' element.
     */
    protected static class FeBlendElementFactory implements ElementFactory {
        public FeBlendElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEBlendElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feColorMatrix' element.
     */
    protected static class FeColorMatrixElementFactory
        implements ElementFactory {
        public FeColorMatrixElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEColorMatrixElement(prefix,
                                                 (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feComponentTransfer' element.
     */
    protected static class FeComponentTransferElementFactory
        implements ElementFactory {
        public FeComponentTransferElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEComponentTransferElement(prefix,
                                                       (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feComposite' element.
     */
    protected static class FeCompositeElementFactory
        implements ElementFactory {
        public FeCompositeElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFECompositeElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feConvolveMatrix' element.
     */
    protected static class FeConvolveMatrixElementFactory
        implements ElementFactory {
        public FeConvolveMatrixElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEConvolveMatrixElement(prefix,
                                                    (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feDiffuseLighting' element.
     */
    protected static class FeDiffuseLightingElementFactory
        implements ElementFactory {
        public FeDiffuseLightingElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEDiffuseLightingElement(prefix,
                                                     (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feDisplacementMap' element.
     */
    protected static class FeDisplacementMapElementFactory
        implements ElementFactory {
        public FeDisplacementMapElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEDisplacementMapElement(prefix,
                                                     (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feDistantLight' element.
     */
    protected static class FeDistantLightElementFactory
        implements ElementFactory {
        public FeDistantLightElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEDistantLightElement(prefix,
                                                  (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feFlood' element.
     */
    protected static class FeFloodElementFactory implements ElementFactory {
        public FeFloodElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEFloodElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feFuncA' element.
     */
    protected static class FeFuncAElementFactory implements ElementFactory {
        public FeFuncAElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEFuncAElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feFuncR' element.
     */
    protected static class FeFuncRElementFactory implements ElementFactory {
        public FeFuncRElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEFuncRElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feFuncG' element.
     */
    protected static class FeFuncGElementFactory implements ElementFactory {
        public FeFuncGElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEFuncGElement(prefix, (AbstractDocument)doc);
        }
    }


    /**
     * To create a 'feFuncB' element.
     */
    protected static class FeFuncBElementFactory
        implements ElementFactory {
        public FeFuncBElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEFuncBElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feGaussianBlur' element.
     */
    protected static class FeGaussianBlurElementFactory
        implements ElementFactory {
        public FeGaussianBlurElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEGaussianBlurElement(prefix,
                                                  (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feImage' element.
     */
    protected static class FeImageElementFactory implements ElementFactory {
        public FeImageElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEImageElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feMerge' element.
     */
    protected static class FeMergeElementFactory
        implements ElementFactory {
        public FeMergeElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEMergeElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feMergeNode' element.
     */
    protected static class FeMergeNodeElementFactory
        implements ElementFactory {
        public FeMergeNodeElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEMergeNodeElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feMorphology' element.
     */
    protected static class FeMorphologyElementFactory
        implements ElementFactory {
        public FeMorphologyElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEMorphologyElement(prefix,
                                                (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feOffset' element.
     */
    protected static class FeOffsetElementFactory implements ElementFactory {
        public FeOffsetElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEOffsetElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'fePointLight' element.
     */
    protected static class FePointLightElementFactory
        implements ElementFactory {
        public FePointLightElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFEPointLightElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feSpecularLighting' element.
     */
    protected static class FeSpecularLightingElementFactory
        implements ElementFactory {
        public FeSpecularLightingElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFESpecularLightingElement(prefix,
                                                      (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feSpotLight' element.
     */
    protected static class FeSpotLightElementFactory
        implements ElementFactory {
        public FeSpotLightElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFESpotLightElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feTile' element.
     */
    protected static class FeTileElementFactory implements ElementFactory {
        public FeTileElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFETileElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'feTurbulence' element
     */
    protected static class FeTurbulenceElementFactory
        implements ElementFactory{
        public FeTurbulenceElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFETurbulenceElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'filter' element.
     */
    protected static class FilterElementFactory implements ElementFactory {
        public FilterElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFilterElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'font' element.
     */
    protected static class FontElementFactory implements ElementFactory {
        public FontElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFontElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'font-face' element.
     */
    protected static class FontFaceElementFactory implements ElementFactory {
        public FontFaceElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFontFaceElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'font-face-format' element.
     */
    protected static class FontFaceFormatElementFactory
        implements ElementFactory {
        public FontFaceFormatElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFontFaceFormatElement(prefix,
                                                  (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'font-face-name' element.
     */
    protected static class FontFaceNameElementFactory
        implements ElementFactory {
        public FontFaceNameElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFontFaceNameElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'font-face-src' element.
     */
    protected static class FontFaceSrcElementFactory
        implements ElementFactory {
        public FontFaceSrcElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFontFaceSrcElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'font-face-uri' element.
     */
    protected static class FontFaceUriElementFactory
        implements ElementFactory {
        public FontFaceUriElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFontFaceUriElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'foreignObject' element.
     */
    protected static class ForeignObjectElementFactory
        implements ElementFactory {
        public ForeignObjectElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMForeignObjectElement(prefix,
                                                 (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'g' element.
     */
    protected static class GElementFactory implements ElementFactory {
        public GElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMGElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'glyph' element.
     */
    protected static class GlyphElementFactory implements ElementFactory {
        public GlyphElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMGlyphElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'glyphRef' element.
     */
    protected static class GlyphRefElementFactory implements ElementFactory {
        public GlyphRefElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMGlyphRefElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'hkern' element.
     */
    protected static class HkernElementFactory implements ElementFactory {
        public HkernElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMHKernElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'image' element.
     */
    protected static class ImageElementFactory implements ElementFactory {
        public ImageElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMImageElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'line' element.
     */
    protected static class LineElementFactory implements ElementFactory {
        public LineElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMLineElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'linearGradient' element.
     */
    protected static class LinearGradientElementFactory
        implements ElementFactory {
        public LinearGradientElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMLinearGradientElement(prefix,
                                                  (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'marker' element.
     */
    protected static class MarkerElementFactory implements ElementFactory {
        public MarkerElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMMarkerElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'mask' element.
     */
    protected static class MaskElementFactory implements ElementFactory {
        public MaskElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMMaskElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'metadata' element.
     */
    protected static class MetadataElementFactory implements ElementFactory {
        public MetadataElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMMetadataElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'missing-glyph' element.
     */
    protected static class MissingGlyphElementFactory
        implements ElementFactory {
        public MissingGlyphElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMMissingGlyphElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'mpath' element.
     */
    protected static class MpathElementFactory implements ElementFactory {
        public MpathElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMMPathElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'path' element.
     */
    protected static class PathElementFactory implements ElementFactory {
        public PathElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMPathElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'pattern' element.
     */
    protected static class PatternElementFactory implements ElementFactory {
        public PatternElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMPatternElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'polygon' element.
     */
    protected static class PolygonElementFactory implements ElementFactory {
        public PolygonElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMPolygonElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'polyline' element.
     */
    protected static class PolylineElementFactory implements ElementFactory {
        public PolylineElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMPolylineElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'radialGradient' element.
     */
    protected static class RadialGradientElementFactory
        implements ElementFactory {
        public RadialGradientElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMRadialGradientElement(prefix,
                                                  (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'rect' element.
     */
    protected static class RectElementFactory implements ElementFactory {
        public RectElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMRectElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'script' element.
     */
    protected static class ScriptElementFactory implements ElementFactory {
        public ScriptElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMScriptElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'set' element.
     */
    protected static class SetElementFactory implements ElementFactory {
        public SetElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMSetElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'stop' element.
     */
    protected static class StopElementFactory implements ElementFactory {
        public StopElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMStopElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'style' element.
     */
    protected static class StyleElementFactory implements ElementFactory {
        public StyleElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMStyleElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create an 'svg' element.
     */
    protected static class SvgElementFactory implements ElementFactory {
        public SvgElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMSVGElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'switch' element.
     */
    protected static class SwitchElementFactory implements ElementFactory {
        public SwitchElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMSwitchElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'symbol' element.
     */
    protected static class SymbolElementFactory implements ElementFactory {
        public SymbolElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMSymbolElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'text' element.
     */
    protected static class TextElementFactory implements ElementFactory {
        public TextElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMTextElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'textPath' element.
     */
    protected static class TextPathElementFactory implements ElementFactory {
        public TextPathElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMTextPathElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'title' element.
     */
    protected static class TitleElementFactory implements ElementFactory {
        public TitleElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMTitleElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'tref' element.
     */
    protected static class TrefElementFactory implements ElementFactory {
        public TrefElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMTRefElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'tspan' element.
     */
    protected static class TspanElementFactory implements ElementFactory {
        public TspanElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMTSpanElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'use' element.
     */
    protected static class UseElementFactory implements ElementFactory {
        public UseElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMUseElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'view' element.
     */
    protected static class ViewElementFactory implements ElementFactory {
        public ViewElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMViewElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'vkern' element.
     */
    protected static class VkernElementFactory implements ElementFactory {
        public VkernElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMVKernElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * The default instance of this class.
     */
    protected static final DOMImplementation DOM_IMPLEMENTATION =
        new SVGDOMImplementation();

}
