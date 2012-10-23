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
package org.apache.flex.forks.batik.transcoder;

import java.awt.Dimension;
import java.awt.geom.AffineTransform;
import java.awt.geom.Dimension2D;
import java.awt.geom.Rectangle2D;
import java.util.LinkedList;
import java.util.List;
import java.util.StringTokenizer;

import org.apache.flex.forks.batik.bridge.BaseScriptingEnvironment;
import org.apache.flex.forks.batik.bridge.BridgeContext;
import org.apache.flex.forks.batik.bridge.BridgeException;
import org.apache.flex.forks.batik.bridge.DefaultScriptSecurity;
import org.apache.flex.forks.batik.bridge.GVTBuilder;
import org.apache.flex.forks.batik.bridge.NoLoadScriptSecurity;
import org.apache.flex.forks.batik.bridge.RelaxedScriptSecurity;
import org.apache.flex.forks.batik.bridge.SVGUtilities;
import org.apache.flex.forks.batik.bridge.ScriptSecurity;
import org.apache.flex.forks.batik.bridge.UserAgent;
import org.apache.flex.forks.batik.bridge.UserAgentAdapter;
import org.apache.flex.forks.batik.bridge.ViewBox;
import org.apache.flex.forks.batik.bridge.svg12.SVG12BridgeContext;
import org.apache.flex.forks.batik.dom.svg.SAXSVGDocumentFactory;
import org.apache.flex.forks.batik.dom.svg.SVGDOMImplementation;
import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.dom.util.DocumentFactory;
import org.apache.flex.forks.batik.gvt.CanvasGraphicsNode;
import org.apache.flex.forks.batik.gvt.CompositeGraphicsNode;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.transcoder.keys.BooleanKey;
import org.apache.flex.forks.batik.transcoder.keys.FloatKey;
import org.apache.flex.forks.batik.transcoder.keys.LengthKey;
import org.apache.flex.forks.batik.transcoder.keys.Rectangle2DKey;
import org.apache.flex.forks.batik.transcoder.keys.StringKey;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.SVGConstants;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.Document;
import org.w3c.dom.svg.SVGSVGElement;

/**
 * This class may be the base class of all transcoders which take an
 * SVG document as input and which need to build a DOM tree. The
 * <tt>SVGAbstractTranscoder</tt> uses several different hints that
 * guide it's behaviour:<br/>
 *
 * <ul>
 *   <li><tt>KEY_WIDTH, KEY_HEIGHT</tt> can be used to specify how to scale the
 *       SVG image</li>
 * </ul>
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: SVGAbstractTranscoder.java 591555 2007-11-03 05:53:15Z cam $
 */
public abstract class SVGAbstractTranscoder extends XMLAbstractTranscoder {
    /**
     * Value used as a default for the default font-family hint
     */
    public static final String DEFAULT_DEFAULT_FONT_FAMILY
        = "Arial, Helvetica, sans-serif";

    /**
     * Current area of interest.
     */
    protected Rectangle2D curAOI;

    /**
     * Transform needed to render the current area of interest
     */
    protected AffineTransform curTxf;

    /**
     * Current GVT Tree, i.e., the GVT tree representing the page
     * being printed currently.
     */
    protected GraphicsNode root;

    /**
     * Current bridge context
     */
    protected BridgeContext ctx;

    /**
     * Current gvt builder
     */
    protected GVTBuilder builder;

    /**
     * Image's width and height (init to 400x400).
     */
    protected float width=400, height=400;

    /** The user agent dedicated to an SVG Transcoder. */
    protected UserAgent userAgent;

    protected SVGAbstractTranscoder() {
        userAgent = createUserAgent();

        hints.put(KEY_DOCUMENT_ELEMENT_NAMESPACE_URI,
                  SVGConstants.SVG_NAMESPACE_URI);
        hints.put(KEY_DOCUMENT_ELEMENT,
                  SVGConstants.SVG_SVG_TAG);
        hints.put(KEY_DOM_IMPLEMENTATION,
                  SVGDOMImplementation.getDOMImplementation());
        hints.put(KEY_MEDIA,
                  "screen");
        hints.put(KEY_DEFAULT_FONT_FAMILY,
                  DEFAULT_DEFAULT_FONT_FAMILY);
        hints.put(KEY_EXECUTE_ONLOAD,
                  Boolean.FALSE);
        hints.put(KEY_ALLOWED_SCRIPT_TYPES,
                  DEFAULT_ALLOWED_SCRIPT_TYPES);
    }


    protected UserAgent createUserAgent() {
        return new SVGAbstractTranscoderUserAgent();
    }

    /**
     * Creates a <tt>DocumentFactory</tt> that is used to create an SVG DOM
     * tree. The specified DOM Implementation is ignored and the Batik
     * SVG DOM Implementation is automatically used.
     *
     * @param domImpl the DOM Implementation (not used)
     * @param parserClassname the XML parser classname
     */
    protected DocumentFactory createDocumentFactory(DOMImplementation domImpl,
                                                    String parserClassname) {
        return new SAXSVGDocumentFactory(parserClassname);
    }

    public void transcode(TranscoderInput input, TranscoderOutput output)
            throws TranscoderException {

        super.transcode(input, output);

        if (ctx != null)
            ctx.dispose();
    }
    /**
     * Transcodes the specified Document as an image in the specified output.
     *
     * @param document the document to transcode
     * @param uri the uri of the document or null if any
     * @param output the ouput where to transcode
     * @exception TranscoderException if an error occured while transcoding
     */
    protected void transcode(Document document,
                             String uri,
                             TranscoderOutput output)
            throws TranscoderException {

        if ((document != null) &&
            !(document.getImplementation() instanceof SVGDOMImplementation)) {
            DOMImplementation impl;
            impl = (DOMImplementation)hints.get(KEY_DOM_IMPLEMENTATION);
            // impl = SVGDOMImplementation.getDOMImplementation();
            document = DOMUtilities.deepCloneDocument(document, impl);
            if (uri != null) {
                ParsedURL url = new ParsedURL(uri);
                ((SVGOMDocument)document).setParsedURL(url);
            }
        }

        if (hints.containsKey(KEY_WIDTH))
            width = ((Float)hints.get(KEY_WIDTH)).floatValue();
        if (hints.containsKey(KEY_HEIGHT))
            height = ((Float)hints.get(KEY_HEIGHT)).floatValue();


        SVGOMDocument svgDoc = (SVGOMDocument)document;
        SVGSVGElement root = svgDoc.getRootElement();
        ctx = createBridgeContext(svgDoc);

        // build the GVT tree
        builder = new GVTBuilder();
        // flag that indicates if the document is dynamic
        boolean isDynamic =
            hints.containsKey(KEY_EXECUTE_ONLOAD) &&
             ((Boolean)hints.get(KEY_EXECUTE_ONLOAD)).booleanValue();

        GraphicsNode gvtRoot;
        try {
            if (isDynamic)
                ctx.setDynamicState(BridgeContext.DYNAMIC);

            gvtRoot = builder.build(ctx, svgDoc);

            // dispatch an 'onload' event if needed
            if (ctx.isDynamic()) {
                BaseScriptingEnvironment se;
                se = new BaseScriptingEnvironment(ctx);
                se.loadScripts();
                se.dispatchSVGLoadEvent();
                if (hints.containsKey(KEY_SNAPSHOT_TIME)) {
                    float t =
                        ((Float) hints.get(KEY_SNAPSHOT_TIME)).floatValue();
                    ctx.getAnimationEngine().setCurrentTime(t);
                } else if (ctx.isSVG12()) {
                    float t = SVGUtilities.convertSnapshotTime(root, null);
                    ctx.getAnimationEngine().setCurrentTime(t);
                }
            }
        } catch (BridgeException ex) {
            ex.printStackTrace();
            throw new TranscoderException(ex);
        }

        // get the 'width' and 'height' attributes of the SVG document
        float docWidth = (float)ctx.getDocumentSize().getWidth();
        float docHeight = (float)ctx.getDocumentSize().getHeight();

        setImageSize(docWidth, docHeight);

        // compute the preserveAspectRatio matrix
        AffineTransform Px;

        // take the AOI into account if any
        if (hints.containsKey(KEY_AOI)) {
            Rectangle2D aoi = (Rectangle2D)hints.get(KEY_AOI);
            // transform the AOI into the image's coordinate system
            Px = new AffineTransform();
            double sx = width / aoi.getWidth();
            double sy = height / aoi.getHeight();
            double scale = Math.min(sx,sy);
            Px.scale(scale, scale);
            double tx = -aoi.getX() + (width/scale - aoi.getWidth())/2;
            double ty = -aoi.getY() + (height/scale -aoi.getHeight())/2;
            Px.translate(tx, ty);
            // take the AOI transformation matrix into account
            // we apply first the preserveAspectRatio matrix
            curAOI = aoi;
        } else {
            String ref = new ParsedURL(uri).getRef();

            // XXX Update this to use the animated value of 'viewBox' and
            //     'preserveAspectRatio'.
            String viewBox = root.getAttributeNS
                (null, SVGConstants.SVG_VIEW_BOX_ATTRIBUTE);

            if ((ref != null) && (ref.length() != 0)) {
                Px = ViewBox.getViewTransform(ref, root, width, height, ctx);
            } else if ((viewBox != null) && (viewBox.length() != 0)) {
                String aspectRatio = root.getAttributeNS
                    (null, SVGConstants.SVG_PRESERVE_ASPECT_RATIO_ATTRIBUTE);
                Px = ViewBox.getPreserveAspectRatioTransform
                    (root, viewBox, aspectRatio, width, height, ctx);
            } else {
                // no viewBox has been specified, create a scale transform
                float xscale, yscale;
                xscale = width/docWidth;
                yscale = height/docHeight;
                float scale = Math.min(xscale,yscale);
                Px = AffineTransform.getScaleInstance(scale, scale);
            }

            curAOI = new Rectangle2D.Float(0, 0, width, height);
        }

        CanvasGraphicsNode cgn = getCanvasGraphicsNode(gvtRoot);
        if (cgn != null) {
            cgn.setViewingTransform(Px);
            curTxf = new AffineTransform();
        } else {
            curTxf = Px;
        }

        this.root = gvtRoot;
    }

    protected CanvasGraphicsNode getCanvasGraphicsNode(GraphicsNode gn) {
        if (!(gn instanceof CompositeGraphicsNode))
            return null;
        CompositeGraphicsNode cgn = (CompositeGraphicsNode)gn;
        List children = cgn.getChildren();
        if (children.size() == 0)
            return null;
        gn = (GraphicsNode)children.get(0);
        if (!(gn instanceof CanvasGraphicsNode))
            return null;
        return (CanvasGraphicsNode)gn;
    }

    /**
     * Factory method for constructing an configuring a
     * BridgeContext so subclasses can insert new/modified
     * bridges in the context.
     * @param doc the SVG document to create the BridgeContext for
     * @return the newly instantiated BridgeContext
     */
    protected BridgeContext createBridgeContext(SVGOMDocument doc) {
        return createBridgeContext(doc.isSVG12() ? "1.2" : "1.x");
    }

    /**
     * Creates the default SVG 1.0/1.1 BridgeContext. Subclass this method to provide
     * customized bridges. This method is provided for historical reasons. New applications
     * should use {@link #createBridgeContext(String)} instead.
     * @return the newly instantiated BridgeContext
     * @see #createBridgeContext(String)
     */
    protected BridgeContext createBridgeContext() {
        return createBridgeContext("1.x");
    }

    /**
     * Creates the BridgeContext. Subclass this method to provide customized bridges. For example,
     * Apache FOP uses this method to register special bridges for optimized text painting.
     * @param svgVersion the SVG version in use (ex. "1.0", "1.x" or "1.2")
     * @return the newly instantiated BridgeContext
     */
    protected BridgeContext createBridgeContext(String svgVersion) {
        if ("1.2".equals(svgVersion)) {
            return new SVG12BridgeContext(userAgent);
        } else {
            return new BridgeContext(userAgent);
        }
    }

    /**
     * Sets document size according to the hints.
     * Global variables width and height are modified.
     *
     * @param docWidth Width of the document.
     * @param docHeight Height of the document.
     */
    protected void setImageSize(float docWidth, float docHeight) {

        // Compute the image's width and height according the hints
        float imgWidth = -1;
        if (hints.containsKey(KEY_WIDTH)) {
            imgWidth = ((Float)hints.get(KEY_WIDTH)).floatValue();
        }
        float imgHeight = -1;
        if (hints.containsKey(KEY_HEIGHT)) {
            imgHeight = ((Float)hints.get(KEY_HEIGHT)).floatValue();
        }

        if (imgWidth > 0 && imgHeight > 0) {
            width = imgWidth;
            height = imgHeight;
        } else if (imgHeight > 0) {
            width = (docWidth * imgHeight) / docHeight;
            height = imgHeight;
        } else if (imgWidth > 0) {
            width = imgWidth;
            height = (docHeight * imgWidth) / docWidth;
        } else {
            width = docWidth;
            height = docHeight;
        }

        // Limit image size according to the maximuxm size hints.
        float imgMaxWidth = -1;
        if (hints.containsKey(KEY_MAX_WIDTH)) {
            imgMaxWidth = ((Float)hints.get(KEY_MAX_WIDTH)).floatValue();
        }
        float imgMaxHeight = -1;
        if (hints.containsKey(KEY_MAX_HEIGHT)) {
            imgMaxHeight = ((Float)hints.get(KEY_MAX_HEIGHT)).floatValue();
        }

        if ((imgMaxHeight > 0) && (height > imgMaxHeight)) {
            width = (docWidth * imgMaxHeight) / docHeight;
            height = imgMaxHeight;
        }
        if ((imgMaxWidth > 0) && (width > imgMaxWidth)) {
            width = imgMaxWidth;
            height = (docHeight * imgMaxWidth) / docWidth;
        }
    }


    // --------------------------------------------------------------------
    // Keys definition
    // --------------------------------------------------------------------

    /**
     * The image width key.
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_WIDTH</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">Float</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">The width of the top most svg element</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Specify the width of the image to create.</TD></TR>
     * </TABLE> */
    public static final TranscodingHints.Key KEY_WIDTH
        = new LengthKey();

    /**
     * The image height key.
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_HEIGHT</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">Float</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">The height of the top most svg element</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Specify the height of the image to create.</TD></TR>
     * </TABLE> */
    public static final TranscodingHints.Key KEY_HEIGHT
        = new LengthKey();

    /**
     * The maximum width of the image key.
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_MAX_WIDTH</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">Float</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">The width of the top most svg element</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Specify the maximum width of the image to create.
     * The value will set the maximum width of the image even when
     * bigger width is specified in a document or set with KEY_WIDTH.
     * </TD></TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_MAX_WIDTH
        = new LengthKey();

    /**
     * The maximux height of the image key.
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_MAX_HEIGHT</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">Float</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">The height of the top most svg element</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Specify the maximum height of the image to create.
     * The value will set the maximum height of the image even when
     * bigger height is specified in a document or set with KEY_HEIGHT.
     * </TD></TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_MAX_HEIGHT
        = new LengthKey();

    /**
     * The area of interest key.
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_AOI</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">Rectangle2D</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">The document's size</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Specify the area of interest to render. The
     * rectangle coordinates must be specified in pixels and in the
     * document coordinates system.</TD></TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_AOI
        = new Rectangle2DKey();

    /**
     * The language key.
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_LANGUAGE</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">String</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">"en"</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Specify the preferred language of the document.
     * </TD></TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_LANGUAGE
        = new StringKey();

    /**
     * The media key.
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_MEDIA</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">String</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">"screen"</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Specify the media to use with CSS.
     * </TD></TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_MEDIA
        = new StringKey();

    /**
     * The default font-family key.
     *
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_DEFAULT_FONT_FAMILY</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">String</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">"Arial, Helvetica, sans-serif"</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Controls the default
     * value used by the CSS engine for the font-family property
     * when that property is unspecified.Specify the media to use with CSS.
     * </TD></TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_DEFAULT_FONT_FAMILY
        = new StringKey();

    /**
     * The alternate stylesheet key.
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_ALTERNATE_STYLESHEET</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">String</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">null</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Specify the alternate style sheet title.
     * </TD></TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_ALTERNATE_STYLESHEET
        = new StringKey();

    /**
     * The user stylesheet URI key.
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_USER_STYLESHEET_URI</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">String</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">null</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Specify the user style sheet.</TD></TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_USER_STYLESHEET_URI
        = new StringKey();

    /**
     * The number of millimeters in each pixel key.
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_PIXEL_UNIT_TO_MILLIMETER</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">Float</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">0.264583</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Specify the size of a px CSS unit in millimeters.
     * </TD></TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_PIXEL_UNIT_TO_MILLIMETER
        = new FloatKey();

    /**
     * The pixel to millimeter conversion factor key.
     * @deprecated As of Batik Version 1.5b3
     * @see #KEY_PIXEL_UNIT_TO_MILLIMETER
     *
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_PIXEL_TO_MM</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">Float</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">0.264583</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Specify the size of a px CSS unit in millimeters.
     * </TD></TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_PIXEL_TO_MM
        = KEY_PIXEL_UNIT_TO_MILLIMETER;

    /**
     * The 'onload' execution key.
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_EXECUTE_ONLOAD</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">Boolean</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">false</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Specify if scripts added on the 'onload' event
     * attribute must be invoked.</TD></TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_EXECUTE_ONLOAD
        = new BooleanKey();

    /**
     * The snapshot time key.
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_SNAPSHOT_TIME</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">Float</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">0</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Specifies the document time to seek to before
     * rasterization.  Only applies if {@link #KEY_EXECUTE_ONLOAD} is
     * set to <code>true</code>.</TD></TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_SNAPSHOT_TIME
        = new FloatKey();

    /**
     * The set of supported script languages (i.e., the set of possible
     * values for the &lt;script&gt; tag's type attribute).
     *
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_ALLOWED_SCRIPT_TYPES</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">String (Comma separated values)</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">text/ecmascript, application/java-archive</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">Specifies the allowed values for the type attribute
     * in the &lt;script&gt; element. This is a comma separated list. The
     * special value '*' means that all script types are allowed.
     * </TD></TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_ALLOWED_SCRIPT_TYPES
        = new StringKey();

    /**
     * Default value for the KEY_ALLOWED_SCRIPT_TYPES key
     */
    public static final String DEFAULT_ALLOWED_SCRIPT_TYPES
        = SVGConstants.SVG_SCRIPT_TYPE_ECMASCRIPT + ", "
        + SVGConstants.SVG_SCRIPT_TYPE_APPLICATION_ECMASCRIPT + ", "
        + SVGConstants.SVG_SCRIPT_TYPE_JAVASCRIPT + ", "
        + SVGConstants.SVG_SCRIPT_TYPE_APPLICATION_JAVASCRIPT + ", "
        + SVGConstants.SVG_SCRIPT_TYPE_JAVA;

    /**
     * Controls whether or not scripts can only be loaded from the
     * same location as the document which references them.
     *
     * <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="1">
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Key: </TH>
     * <TD VALIGN="TOP">KEY_CONSTRAIN_SCRIPT_ORIGIN</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Value: </TH>
     * <TD VALIGN="TOP">boolean</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Default: </TH>
     * <TD VALIGN="TOP">true</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Required: </TH>
     * <TD VALIGN="TOP">No</TD></TR>
     * <TR>
     * <TH VALIGN="TOP" ALIGN="RIGHT"><P ALIGN="RIGHT">Description: </TH>
     * <TD VALIGN="TOP">When set to true, script elements referencing
     * files from a different origin (server) than the document containing
     * the script element will not be loaded. When set to true, script elements
     * may reference script files from any origin.
     * </TD></TR>
     * </TABLE>
     */
    public static final TranscodingHints.Key KEY_CONSTRAIN_SCRIPT_ORIGIN
        = new BooleanKey();


    /**
     * A user agent implementation for <tt>PrintTranscoder</tt>.
     */
    protected class SVGAbstractTranscoderUserAgent extends UserAgentAdapter {
        /**
         * Vector containing the allowed script types
         */
        protected List scripts;

        public SVGAbstractTranscoderUserAgent() {
            addStdFeatures();
        }

        /**
         * Return the rendering transform.
         */
        public AffineTransform getTransform() {
            return SVGAbstractTranscoder.this.curTxf;
        }

        /**
         * Return the rendering transform.
         */
        public void setTransform(AffineTransform at) {
            SVGAbstractTranscoder.this.curTxf = at;
        }

        /**
         * Returns the default size of this user agent (400x400).
         */
        public Dimension2D getViewportSize() {
            return new Dimension((int)SVGAbstractTranscoder.this.width,
                                 (int)SVGAbstractTranscoder.this.height);
        }

        /**
         * Displays the specified error message using the <tt>ErrorHandler</tt>.
         */
        public void displayError(String message) {
            try {
                SVGAbstractTranscoder.this.handler.error
                    (new TranscoderException(message));
            } catch (TranscoderException ex) {
                throw new RuntimeException( ex.getMessage() );
            }
        }

        /**
         * Displays the specified error using the <tt>ErrorHandler</tt>.
         */
        public void displayError(Exception e) {
            try {
                e.printStackTrace();
                SVGAbstractTranscoder.this.handler.error
                    (new TranscoderException(e));
            } catch (TranscoderException ex) {
                throw new RuntimeException( ex.getMessage() );
            }
        }

        /**
         * Displays the specified message using the <tt>ErrorHandler</tt>.
         */
        public void displayMessage(String message) {
            try {
                SVGAbstractTranscoder.this.handler.warning
                    (new TranscoderException(message));
            } catch (TranscoderException ex) {
                throw new RuntimeException( ex.getMessage() );
            }
        }

        /**
         * Returns the pixel to millimeter conversion factor specified in the
         * <tt>TranscodingHints</tt> or 0.26458333 if not specified.
         */
        public float getPixelUnitToMillimeter() {
            Object obj = SVGAbstractTranscoder.this.hints.get
                (KEY_PIXEL_UNIT_TO_MILLIMETER);
            if (obj != null) {
                return ((Float)obj).floatValue();
            }

            return super.getPixelUnitToMillimeter();
        }

        /**
         * Returns the user language specified in the
         * <tt>TranscodingHints</tt> or "en" (english) if any.
         */
        public String getLanguages() {
            if (SVGAbstractTranscoder.this.hints.containsKey(KEY_LANGUAGE)) {
                return (String)SVGAbstractTranscoder.this.hints.get
                    (KEY_LANGUAGE);
            }

            return super.getLanguages();
        }

        /**
         * Returns this user agent's CSS media.
         */
        public String getMedia() {
            String s = (String)hints.get(KEY_MEDIA);
            if (s != null) return s;

            return super.getMedia();
        }

        /**
         * Returns the default font family.
         */
        public String getDefaultFontFamily() {
            String s = (String)hints.get(KEY_DEFAULT_FONT_FAMILY);
            if (s != null) return s;

            return super.getDefaultFontFamily();
        }

        /**
         * Returns this user agent's alternate style-sheet title.
         */
        public String getAlternateStyleSheet() {
            String s = (String)hints.get(KEY_ALTERNATE_STYLESHEET);
            if (s != null)
                return s;

            return super.getAlternateStyleSheet();
        }

        /**
         * Returns the user stylesheet specified in the
         * <tt>TranscodingHints</tt> or null if any.
         */
        public String getUserStyleSheetURI() {
            String s = (String)SVGAbstractTranscoder.this.hints.get
                (KEY_USER_STYLESHEET_URI);
            if (s != null)
                return s;

            return super.getUserStyleSheetURI();
        }

        /**
         * Returns the XML parser to use from the TranscodingHints.
         */
        public String getXMLParserClassName() {
            String s = (String)SVGAbstractTranscoder.this.hints.get
                (KEY_XML_PARSER_CLASSNAME);
            if (s != null)
                return s;

            return super.getXMLParserClassName();
        }

        /**
         * Returns true if the XML parser must be in validation mode, false
         * otherwise.
         */
        public boolean isXMLParserValidating() {
            Boolean b = (Boolean)SVGAbstractTranscoder.this.hints.get
                (KEY_XML_PARSER_VALIDATING);
            if (b != null)
                return b.booleanValue();

            return super.isXMLParserValidating();
        }

        /**
         * Returns the security settings for the given script
         * type, script url and document url
         *
         * @param scriptType type of script, as found in the
         *        type attribute of the &lt;script&gt; element.
         * @param scriptPURL url for the script, as defined in
         *        the script's xlink:href attribute. If that
         *        attribute was empty, then this parameter should
         *        be null
         * @param docPURL url for the document into which the
         *        script was found.
         */
        public ScriptSecurity getScriptSecurity(String scriptType,
                                                ParsedURL scriptPURL,
                                                ParsedURL docPURL){
            if (scripts == null){
                computeAllowedScripts();
            }

            if (!scripts.contains(scriptType)) {
                return new NoLoadScriptSecurity(scriptType);
            }


            boolean constrainOrigin = true;

            if (SVGAbstractTranscoder.this.hints.containsKey
                (KEY_CONSTRAIN_SCRIPT_ORIGIN)) {
                constrainOrigin =
                    ((Boolean)SVGAbstractTranscoder.this.hints.get
                     (KEY_CONSTRAIN_SCRIPT_ORIGIN)).booleanValue();
            }

            if (constrainOrigin) {
                return new DefaultScriptSecurity
                    (scriptType,scriptPURL,docPURL);
            } else {
                return new RelaxedScriptSecurity
                    (scriptType,scriptPURL,docPURL);
            }
        }

        /**
         * Helper method. Builds a Vector containing the allowed
         * values for the &lt;script&gt; element's type attribute.
         */
        protected void computeAllowedScripts(){
            scripts = new LinkedList();
            if (!SVGAbstractTranscoder.this.hints.containsKey
                (KEY_ALLOWED_SCRIPT_TYPES)) {
                return;
            }

            String allowedScripts
                = (String)SVGAbstractTranscoder.this.hints.get
                (KEY_ALLOWED_SCRIPT_TYPES);

            StringTokenizer st = new StringTokenizer(allowedScripts, ",");
            while (st.hasMoreTokens()) {
                scripts.add(st.nextToken());
            }
        }

    }
}
