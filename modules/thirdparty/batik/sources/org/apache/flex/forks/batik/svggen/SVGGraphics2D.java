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

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.GraphicsConfiguration;
import java.awt.Image;
import java.awt.Paint;
import java.awt.Shape;
import java.awt.Stroke;
import java.awt.font.GlyphVector;
import java.awt.font.TextAttribute;
import java.awt.font.TextLayout;
import java.awt.geom.AffineTransform;
import java.awt.geom.NoninvertibleTransformException;
import java.awt.image.BufferedImage;
import java.awt.image.BufferedImageOp;
import java.awt.image.ImageObserver;
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderableImage;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.text.AttributedCharacterIterator;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import org.apache.flex.forks.batik.ext.awt.g2d.AbstractGraphics2D;
import org.apache.flex.forks.batik.ext.awt.g2d.GraphicContext;

import org.w3c.dom.Document;
import org.w3c.dom.DocumentFragment;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * This implementation of the java.awt.Graphics2D abstract class
 * allows users to generate SVG (Scalable Vector Graphics) content
 * from Java code.
 *
 * SVGGraphics2D generates a DOM tree whose root is obtained through
 * the getRoot method. Refer to the DOMTreeManager and DOMGroupManager
 * documentation for details on the structure of the generated
 * DOM tree.
 *
 * The SVGGraphics2D class can produce a DOM tree using any implementation
 * that conforms to the W3C DOM 1.0 specification (see http://www.w3.org).
 * At construction time, the SVGGraphics2D must be given a org.w3.dom.Document
 * instance that is used as a factory to create the various nodes in the
 * DOM tree it generates.
 *
 * The various graphic context attributes (e.g., AffineTransform,
 * Paint) are managed by a GraphicContext object.
 *
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: SVGGraphics2D.java 501495 2007-01-30 18:00:36Z dvholten $
 * @see                org.apache.flex.forks.batik.ext.awt.g2d.GraphicContext
 * @see                org.apache.flex.forks.batik.svggen.DOMTreeManager
 * @see                org.apache.flex.forks.batik.svggen.DOMGroupManager
 * @see                org.apache.flex.forks.batik.svggen.ImageHandler
 * @see                org.apache.flex.forks.batik.svggen.ExtensionHandler
 * @see                org.w3c.dom.Document
 */
public class SVGGraphics2D extends AbstractGraphics2D
    implements Cloneable, SVGSyntax, ErrorConstants {

    /*
     * Constants definitions
     */
    public static final String DEFAULT_XML_ENCODING = "ISO-8859-1";

    /**
     * Controls the policy for grouping nodes. Once the number of attributes
     * overridden by a child element is greater than DEFAULT_MAX_GC_OVERRIDES,
     * a new group is created.
     *
     * @see org.apache.flex.forks.batik.svggen.DOMTreeManager
     */
    public static final int DEFAULT_MAX_GC_OVERRIDES = 3;


    /**
     * The DOMTreeManager manages the process of creating
     * and growing the SVG tree. This SVGGraphics2D relies on
     * the DOMTreeManager to process attributes based on the
     * GraphicContext state and create groups when needed.
     */
    protected DOMTreeManager domTreeManager;

    /**
     * The DOMGroupManager manages additions to the current group
     * node associated for this Graphics2D object. Once a group
     * is complete, the group manager appends it to the DOM tree
     * through the DOMTreeManager.
     * Note that each SVGGraphics2D instance has its own DOMGroupManager
     * (i.e., its own current group) but that all SVGGraphics2D
     * originating from the same SVGGraphics2D through various
     * createGraphics calls share the same DOMTreeManager.
     */
    protected DOMGroupManager domGroupManager;

    /**
     * Contains some information for SVG generation.
     */
    protected SVGGeneratorContext generatorCtx;

    /**
     * Used to convert Java 2D API Shape objects to equivalent SVG
     * elements
     */
    protected SVGShape shapeConverter;

    /**
     * SVG Canvas size
     */
    protected Dimension svgCanvasSize;

    /**
     * Used to create proper font metrics
     */
    protected Graphics2D fmg;

    {
        BufferedImage bi
            = new BufferedImage(1, 1, BufferedImage.TYPE_INT_ARGB);

        fmg = bi.createGraphics();
    }

    /**
     * @return SVG Canvas size, as set in the root svg element
     */
    public final Dimension getSVGCanvasSize(){
        return svgCanvasSize;
    }

    /**
     * Set the Canvas size, this is used to set the width and
     * height attributes on the outermost 'svg' element.
     * @param svgCanvasSize SVG Canvas size. May be null (equivalent
     * to 100%, 100%)
     */
    public final void setSVGCanvasSize(Dimension svgCanvasSize) {
        this.svgCanvasSize = new Dimension(svgCanvasSize);
    }

    /**
     * @return the SVGGeneratorContext used by this SVGGraphics2D instance.
     */
    public final SVGGeneratorContext getGeneratorContext() {
        return generatorCtx;
    }

    /**
     * @return the SVGShape used by this SVGGraphics2D instance to
     *         turn Java2D shapes into SVG Shape objects.
     */
    public final SVGShape getShapeConverter() {
        return shapeConverter;
    }

    /**
     * @return the DOMTreeManager used by this SVGGraphics2D instance
     */
    public final DOMTreeManager getDOMTreeManager(){
        return domTreeManager;
    }

    /**
     * Set a DOM Tree manager for the SVGGraphics2D.
     * @param treeMgr the new DOM Tree manager this SVGGraphics2D should use
     */
     protected final void setDOMTreeManager(DOMTreeManager treeMgr) {
        this.domTreeManager = treeMgr;
        generatorCtx.genericImageHandler.setDOMTreeManager(domTreeManager);
    }

     /**
     * @return the DOMGroupManager used by this SVGGraphics2D instance
     */
    protected final DOMGroupManager getDOMGroupManager(){
        return domGroupManager;
    }

    /**
     * Set a new DOM Group manager for this SVGGraphics2D.
     * @param groupMgr the new DOM Group manager this SVGGraphics2D should use
     */
     protected final void setDOMGroupManager(DOMGroupManager groupMgr) {
        this.domGroupManager = groupMgr;
    }

    /**
     * @return the Document used as a DOM object factory by this
     *         SVGGraphics2D instance
     */
    public final Document getDOMFactory(){
        return generatorCtx.domFactory;
    }

    /**
     * @return the ImageHandler used by this SVGGraphics2D instance
     */
    public final ImageHandler getImageHandler(){
        return generatorCtx.imageHandler;
    }

    /**
     * @return the GenericImageHandler used by this SVGGraphics2D instance
     */
    public final GenericImageHandler getGenericImageHandler(){
        return generatorCtx.genericImageHandler;
    }

    /**
     * @return the extension handler used by this SVGGraphics2D instance
     */
    public final ExtensionHandler getExtensionHandler(){
        return generatorCtx.extensionHandler;
    }

    /**
     * @param extensionHandler new extension handler this SVGGraphics2D
     *        should use
     */
    public final void setExtensionHandler(ExtensionHandler extensionHandler) {
        generatorCtx.setExtensionHandler(extensionHandler);
    }

    /**
     * @param domFactory Factory which will produce Elements for the DOM tree
     *        this Graphics2D generates.
     * @exception SVGGraphics2DRuntimeException if domFactory is null.
     */
    public SVGGraphics2D(Document domFactory) {
        this(SVGGeneratorContext.createDefault(domFactory), false);
    }

    /**
     * @param domFactory Factory which will produce Elements for the DOM tree
     *                   this Graphics2D generates.
     * @param imageHandler defines how images are referenced in the
     *                     generated SVG fragment
     * @param extensionHandler defines how Java 2D API extensions map
     *                         to SVG Nodes.
     * @param textAsShapes if true, all text is turned into SVG shapes in the
     *        convertion. No SVG text is output.
     *
     * @exception SVGGraphics2DRuntimeException if domFactory is null.
     */
    public SVGGraphics2D(Document domFactory,
                         ImageHandler imageHandler,
                         ExtensionHandler extensionHandler,
                         boolean textAsShapes) {
        this(buildSVGGeneratorContext(domFactory,
                                      imageHandler,
                                      extensionHandler),
             textAsShapes);
    }

    /**
     * Helper method to create an <tt>SVGGeneratorContext</tt> from the
     * constructor parameters.
     */
    public static SVGGeneratorContext
        buildSVGGeneratorContext(Document domFactory,
                                 ImageHandler imageHandler,
                                 ExtensionHandler extensionHandler){

        SVGGeneratorContext generatorCtx = new SVGGeneratorContext(domFactory);
        generatorCtx.setIDGenerator(new SVGIDGenerator());
        generatorCtx.setExtensionHandler(extensionHandler);
        generatorCtx.setImageHandler(imageHandler);
        generatorCtx.setStyleHandler(new DefaultStyleHandler());
        generatorCtx.setComment("Generated by the Batik Graphics2D SVG Generator");
        generatorCtx.setErrorHandler(new DefaultErrorHandler());

        return generatorCtx;
    }

    /**
     * Creates a new SVGGraphics2D object.
     * @param generatorCtx the <code>SVGGeneratorContext</code> instance
     * that will provide all useful information to the generator.
     * @param textAsShapes if true, all text is turned into SVG shapes in the
     *        convertion. No SVG text is output.
     *
     * @exception SVGGraphics2DRuntimeException if generatorContext is null.
     */
    public SVGGraphics2D(SVGGeneratorContext generatorCtx,
                         boolean textAsShapes) {
        super(textAsShapes);

        if (generatorCtx == null)
            // no error handler here as we don't have the ctx...
            throw new SVGGraphics2DRuntimeException(ERR_CONTEXT_NULL);

        setGeneratorContext(generatorCtx);
    }

    /**
     * Sets an non null <code>SVGGeneratorContext</code>.
     */
    protected void setGeneratorContext(SVGGeneratorContext generatorCtx) {
        this.generatorCtx = generatorCtx;

        this.gc = new GraphicContext(new AffineTransform());

        SVGGeneratorContext.GraphicContextDefaults gcDefaults =
            generatorCtx.getGraphicContextDefaults();

        if(gcDefaults != null){
            if(gcDefaults.getPaint() != null){
                gc.setPaint(gcDefaults.getPaint());
            }
            if(gcDefaults.getStroke() != null){
                gc.setStroke(gcDefaults.getStroke());
            }
            if(gcDefaults.getComposite() != null){
                gc.setComposite(gcDefaults.getComposite());
            }
            if(gcDefaults.getClip() != null){
                gc.setClip(gcDefaults.getClip());
            }
            if(gcDefaults.getRenderingHints() != null){
                gc.setRenderingHints(gcDefaults.getRenderingHints());
            }
            if(gcDefaults.getFont() != null){
                gc.setFont(gcDefaults.getFont());
            }
            if(gcDefaults.getBackground() != null){
                gc.setBackground(gcDefaults.getBackground());
            }
        }

        this.shapeConverter = new SVGShape(generatorCtx);
        this.domTreeManager = new DOMTreeManager(gc,
                                                 generatorCtx,
                                                 DEFAULT_MAX_GC_OVERRIDES);
        this.domGroupManager = new DOMGroupManager(gc, domTreeManager);
        this.domTreeManager.addGroupManager(domGroupManager);
        generatorCtx.genericImageHandler.setDOMTreeManager(domTreeManager);
    }

    /**
     * This constructor is used in create()
     *
     * @see #create
     */
    public SVGGraphics2D(SVGGraphics2D g) {
        super(g);
        this.generatorCtx = g.generatorCtx;
        this.gc.validateTransformStack();
        this.shapeConverter = g.shapeConverter;
        this.domTreeManager = g.domTreeManager;
        this.domGroupManager = new DOMGroupManager(this.gc, this.domTreeManager);
        this.domTreeManager.addGroupManager(this.domGroupManager);
    }

    /**
     * @param svgFileName name of the file where SVG content
     *        should be written
     */
    public void stream(String svgFileName) throws SVGGraphics2DIOException {
        stream(svgFileName, false);
    }

    /**
     * @param svgFileName name of the file where SVG content
     *        should be written
     * @param useCss defines whether the output SVG should use CSS style
     * properties as opposed to plain attributes.
     */
    public void stream(String svgFileName, boolean useCss)
        throws SVGGraphics2DIOException {
        try {
            OutputStreamWriter writer =
                new OutputStreamWriter(new FileOutputStream(svgFileName),
                                       DEFAULT_XML_ENCODING);
            stream(writer, useCss);
            writer.flush();
            writer.close();
        } catch (SVGGraphics2DIOException io) {
            // this one as already been handled in stream(Writer, boolean)
            // method => rethrow it in all cases
            throw io;
        } catch (IOException e) {
            generatorCtx.errorHandler.
                handleError(new SVGGraphics2DIOException(e));
        }
    }

    /**
     * @param writer used to writer out the SVG content
     */
    public void stream(Writer writer) throws SVGGraphics2DIOException {
        stream(writer, false);
    }

    /**
     * @param writer used to writer out the SVG content
     * @param useCss defines whether the output SVG should use CSS
     * @param escaped defines if the characters will be escaped
     * style properties as opposed to plain attributes.
     */
    public void stream(Writer writer, boolean useCss, boolean escaped)
        throws SVGGraphics2DIOException {
        Element svgRoot = getRoot();
        stream(svgRoot, writer, useCss, escaped);
    }

    /**
     * @param writer used to writer out the SVG content
     * @param useCss defines whether the output SVG should use CSS
     * style properties as opposed to plain attributes.
     */
    public void stream(Writer writer, boolean useCss)
        throws SVGGraphics2DIOException {
        Element svgRoot = getRoot();
        stream(svgRoot, writer, useCss, false);
    }

    /**
     * @param svgRoot root element to stream out
     */
    public void stream(Element svgRoot, Writer writer)
        throws SVGGraphics2DIOException {
        stream(svgRoot, writer, false, false);
    }

    /**
     * @param svgRoot root element to stream out
     * @param writer output
     * @param useCss defines whether the output SVG should use CSS style
     * @param escaped defines if the characters will be escaped
     * properties as opposed to plain attributes.
     */
    public void stream(Element svgRoot, Writer writer, boolean useCss, boolean escaped)
        throws SVGGraphics2DIOException {
        Node rootParent = svgRoot.getParentNode();
        Node nextSibling = svgRoot.getNextSibling();

        try {
            //
            // Enforce that the default and xlink namespace
            // declarations appear on the root element
            //
            svgRoot.setAttributeNS(XMLNS_NAMESPACE_URI,
                                   XMLNS_PREFIX,
                                   SVG_NAMESPACE_URI);

            svgRoot.setAttributeNS(XMLNS_NAMESPACE_URI,
                                   XMLNS_PREFIX + ":" + XLINK_PREFIX,
                                   XLINK_NAMESPACE_URI);

            DocumentFragment svgDocument =
                svgRoot.getOwnerDocument().createDocumentFragment();
            svgDocument.appendChild(svgRoot);

            if (useCss)
                SVGCSSStyler.style(svgDocument);

            XmlWriter.writeXml(svgDocument, writer, escaped);
            writer.flush();
        } catch (SVGGraphics2DIOException e) {
            // this catch prevents from catching an SVGGraphics2DIOException
            // and wrapping it again in another SVGGraphics2DIOException
            // as would do the second catch (XmlWriter throws SVGGraphics2DIO
            // Exception but flush throws IOException)
            generatorCtx.errorHandler.
                handleError(e);
        } catch (IOException io) {
            generatorCtx.errorHandler.
                handleError(new SVGGraphics2DIOException(io));
        } finally {
            // Restore the svgRoot to its original tree position
            if (rootParent != null) {
                if (nextSibling == null) {
                    rootParent.appendChild(svgRoot);
                } else {
                    rootParent.insertBefore(svgRoot, nextSibling);
                }
            }
        }
    }

    /**
     * Invoking this method will return a set of definition element that
     * contain all the definitions referenced by the attributes generated by
     * the various converters. This also resets the converters.
     */
    public java.util.List getDefinitionSet(){
        return domTreeManager.getDefinitionSet();
    }

    /**
     * Invoking this method will return a reference to the topLevelGroup
     * Element managed by this object. It will also cause this object
     * to start working with a new topLevelGroup.
     *
     * @return top level group
     */
    public Element getTopLevelGroup(){
        return getTopLevelGroup(true);
    }

    /**
     * Invoking this method will return a reference to the topLevelGroup
     * Element managed by this object. It will also cause this object
     * to start working with a new topLevelGroup.
     *
     * @param includeDefinitionSet if true, the definition set is included and
     *        the converters are reset (i.e., they start with an empty set
     *        of definitions).
     * @return top level group
     */
    public Element getTopLevelGroup(boolean includeDefinitionSet){
        return domTreeManager.getTopLevelGroup(includeDefinitionSet);
    }

    /**
     * Sets the topLevelGroup to the input element. This will throw an exception
     * if the input element is not of type 'g' or if it is null.
     */
    public void setTopLevelGroup(Element topLevelGroup){
        domTreeManager.setTopLevelGroup(topLevelGroup);
    }

    /**
     * @return the svg root node of the SVG document associated with this
     *         object
     */
    public Element getRoot(){
        return getRoot(null);
    }

    /**
     * This version of the getRoot method will append the input svgRoot
     * and set its attributes.
     *
     * @param svgRoot an SVG element underwhich the content should
     *        be appended.
     * @return the svg root node of the SVG document associated with
     *         this object.
     */
    public Element getRoot(Element svgRoot) {
        svgRoot = domTreeManager.getRoot(svgRoot);
        if (svgCanvasSize != null){
            svgRoot.setAttributeNS(null, SVG_WIDTH_ATTRIBUTE,  String.valueOf( svgCanvasSize.width ) );
            svgRoot.setAttributeNS(null, SVG_HEIGHT_ATTRIBUTE, String.valueOf( svgCanvasSize.height) );
        }
        return svgRoot;
    }

    /**
     * Creates a new <code>Graphics</code> object that is
     * a copy of this <code>Graphics</code> object.
     * @return     a new graphics context that is a copy of
     *             this graphics context.
     */
    public Graphics create(){
        return new SVGGraphics2D(this);
    }


    /**
     * Sets the paint mode of this graphics context to alternate between
     * this graphics context's current color and the new specified color.
     * This specifies that logical pixel operations are performed in the
     * XOR mode, which alternates pixels between the current color and
     * a specified XOR color.
     * <p>
     * When drawing operations are performed, pixels which are the
     * current color are changed to the specified color, and vice versa.
     * <p>
     * Pixels that are of colors other than those two colors are changed
     * in an unpredictable but reversible manner; if the same figure is
     * drawn twice, then all pixels are restored to their original values.
     * @param     c1 the XOR alternation color
     */
    public void setXORMode(Color c1) {
        generatorCtx.errorHandler.
            handleError(new SVGGraphics2DRuntimeException(ERR_XOR));
    }

    /**
     * Gets the font metrics for the specified font.
     * @return    the font metrics for the specified font.
     * @param     f the specified font
     * @see       java.awt.Graphics#getFont
     * @see       java.awt.FontMetrics
     * @see       java.awt.Graphics#getFontMetrics()
     */
    public FontMetrics getFontMetrics(Font f){
        return fmg.getFontMetrics(f);
    }

    /**
     * Copies an area of the component by a distance specified by
     * <code>dx</code> and <code>dy</code>. From the point specified
     * by <code>x</code> and <code>y</code>, this method
     * copies downwards and to the right.  To copy an area of the
     * component to the left or upwards, specify a negative value for
     * <code>dx</code> or <code>dy</code>.
     * If a portion of the source rectangle lies outside the bounds
     * of the component, or is obscured by another window or component,
     * <code>copyArea</code> will be unable to copy the associated
     * pixels. The area that is omitted can be refreshed by calling
     * the component's <code>paint</code> method.
     * @param       x the <i>x</i> coordinate of the source rectangle.
     * @param       y the <i>y</i> coordinate of the source rectangle.
     * @param       width the width of the source rectangle.
     * @param       height the height of the source rectangle.
     * @param       dx the horizontal distance to copy the pixels.
     * @param       dy the vertical distance to copy the pixels.
     */
    public void copyArea(int x, int y, int width, int height,
                         int dx, int dy){
        // No-op
    }

    /**
     * Draws as much of the specified image as is currently available.
     * The image is drawn with its top-left corner at
     * (<i>x</i>,&nbsp;<i>y</i>) in this graphics context's coordinate
     * space. Transparent pixels in the image do not affect whatever
     * pixels are already there.
     * <p>
     * This method returns immediately in all cases, even if the
     * complete image has not yet been loaded, and it has not been dithered
     * and converted for the current output device.
     * <p>
     * If the image has not yet been completely loaded, then
     * <code>drawImage</code> returns <code>false</code>. As more of
     * the image becomes available, the process that draws the image notifies
     * the specified image observer.
     * @param    img the specified image to be drawn.
     * @param    x   the <i>x</i> coordinate.
     * @param    y   the <i>y</i> coordinate.
     * @param    observer    object to be notified as more of
     *                          the image is converted.
     * @see      java.awt.Image
     * @see      java.awt.image.ImageObserver
     * @see      java.awt.image.ImageObserver#imageUpdate(java.awt.Image, int, int, int, int, int)
     */
    public boolean drawImage(Image img, int x, int y,
                             ImageObserver observer) {
        Element imageElement =
            getGenericImageHandler().createElement(getGeneratorContext());
        AffineTransform xform = getGenericImageHandler().handleImage(
                                                         img, imageElement,
                                                         x, y,
                                                         img.getWidth(null),
                                                         img.getHeight(null),
                                                         getGeneratorContext());

        if (xform == null) {
            domGroupManager.addElement(imageElement);
        } else {
            AffineTransform inverseTransform = null;
            try {
                inverseTransform = xform.createInverse();
            } catch(NoninvertibleTransformException e) {
                // This should never happen since handleImage
                // always returns invertible transform
                throw new SVGGraphics2DRuntimeException(ERR_UNEXPECTED);
            }
            gc.transform(xform);
            domGroupManager.addElement(imageElement);
            gc.transform(inverseTransform);
        }
        return true;
    }

    /**
     * Draws as much of the specified image as has already been scaled
     * to fit inside the specified rectangle.
     * <p>
     * The image is drawn inside the specified rectangle of this
     * graphics context's coordinate space, and is scaled if
     * necessary. Transparent pixels do not affect whatever pixels
     * are already there.
     * <p>
     * This method returns immediately in all cases, even if the
     * entire image has not yet been scaled, dithered, and converted
     * for the current output device.
     * If the current output representation is not yet complete, then
     * <code>drawImage</code> returns <code>false</code>. As more of
     * the image becomes available, the process that draws the image notifies
     * the image observer by calling its <code>imageUpdate</code> method.
     * <p>
     * A scaled version of an image will not necessarily be
     * available immediately just because an unscaled version of the
     * image has been constructed for this output device.  Each size of
     * the image may be cached separately and generated from the original
     * data in a separate image production sequence.
     * @param    img    the specified image to be drawn.
     * @param    x      the <i>x</i> coordinate.
     * @param    y      the <i>y</i> coordinate.
     * @param    width  the width of the rectangle.
     * @param    height the height of the rectangle.
     * @param    observer    object to be notified as more of
     *                          the image is converted.
     * @see      java.awt.Image
     * @see      java.awt.image.ImageObserver
     * @see      java.awt.image.ImageObserver#imageUpdate(java.awt.Image, int, int, int, int, int)
     */
    public boolean drawImage(Image img, int x, int y,
                             int width, int height,
                             ImageObserver observer){
        Element imageElement =
            getGenericImageHandler().createElement(getGeneratorContext());
        AffineTransform xform
            = getGenericImageHandler().handleImage(
                                       img, imageElement,
                                       x, y,
                                       width, height,
                                       getGeneratorContext());

        if (xform == null) {
            domGroupManager.addElement(imageElement);
        } else {
            AffineTransform inverseTransform = null;
            try {
                inverseTransform = xform.createInverse();
            } catch(NoninvertibleTransformException e) {
                // This should never happen since handleImage
                // always returns invertible transform
                throw new SVGGraphics2DRuntimeException(ERR_UNEXPECTED);
            }
            gc.transform(xform);
            domGroupManager.addElement(imageElement);
            gc.transform(inverseTransform);
        }
        return true;
    }

    /**
     * Disposes of this graphics context and releases
     * any system resources that it is using.
     * A <code>Graphics</code> object cannot be used after
     * <code>dispose</code>has been called.
     * <p>
     * When a Java program runs, a large number of <code>Graphics</code>
     * objects can be created within a short time frame.
     * Although the finalization process of the garbage collector
     * also disposes of the same system resources, it is preferable
     * to manually free the associated resources by calling this
     * method rather than to rely on a finalization process which
     * may not run to completion for a long period of time.
     * <p>
     * Graphics objects which are provided as arguments to the
     * <code>paint</code> and <code>update</code> methods
     * of components are automatically released by the system when
     * those methods return. For efficiency, programmers should
     * call <code>dispose</code> when finished using
     * a <code>Graphics</code> object only if it was created
     * directly from a component or another <code>Graphics</code> object.
     * @see         java.awt.Graphics#finalize
     * @see         java.awt.Component#paint
     * @see         java.awt.Component#update
     * @see         java.awt.Component#getGraphics
     * @see         java.awt.Graphics#create()
     */
    public void dispose() {
        this.domTreeManager.removeGroupManager(this.domGroupManager);
    }

    /**
     * Strokes the outline of a <code>Shape</code> using the settings of the
     * current <code>Graphics2D</code> context.  The rendering attributes
     * applied include the <code>Clip</code>, <code>Transform</code>,
     * <code>Paint</code>, <code>Composite</code> and
     * <code>Stroke</code> attributes.
     * @param s the <code>Shape</code> to be rendered
     * @see #setStroke(Stroke)
     * @see #setPaint(Paint)
     * @see java.awt.Graphics#setColor
     * @see #setTransform(AffineTransform)
     * @see #setClip(Shape)
     * @see #setComposite(java.awt.Composite)
     */
    public void draw(Shape s) {
        // Only BasicStroke can be converted to an SVG attribute equivalent.
        // If the GraphicContext's Stroke is not an instance of BasicStroke,
        // then the stroked outline is filled.
        Stroke stroke = gc.getStroke();
        if (stroke instanceof BasicStroke) {
            Element svgShape = shapeConverter.toSVG(s);
            if (svgShape != null) {
                domGroupManager.addElement(svgShape, DOMGroupManager.DRAW);
            }
        } else {
            Shape strokedShape = stroke.createStrokedShape(s);
            fill(strokedShape);
        }
    }


    /**
     * Renders an image, applying a transform from image space into user space
     * before drawing.
     * The transformation from user space into device space is done with
     * the current <code>Transform</code> in the <code>Graphics2D</code>.
     * The specified transformation is applied to the image before the
     * transform attribute in the <code>Graphics2D</code> context is applied.
     * The rendering attributes applied include the <code>Clip</code>,
     * <code>Transform</code>, and <code>Composite</code> attributes.
     * Note that no rendering is done if the specified transform is
     * noninvertible.
     * @param img the <code>Image</code> to be rendered
     * @param xform the transformation from image space into user space
     * @param obs the {@link ImageObserver}
     * to be notified as more of the <code>Image</code>
     * is converted
     * @return <code>true</code> if the <code>Image</code> is
     * fully loaded and completely rendered;
     * <code>false</code> if the <code>Image</code> is still being loaded.
     * @see #setTransform(AffineTransform)
     * @see #setComposite(java.awt.Composite)
     * @see #setClip(Shape)
     */
    public boolean drawImage(Image img,
                             AffineTransform xform,
                             ImageObserver obs){
        boolean retVal = true;

        if (xform == null) {
            retVal = drawImage(img, 0, 0, null);
        } else if(xform.getDeterminant() != 0){
            AffineTransform inverseTransform = null;
            try{
                inverseTransform = xform.createInverse();
            }   catch(NoninvertibleTransformException e){
                // Should never happen since we checked the
                // matrix determinant
                throw new SVGGraphics2DRuntimeException(ERR_UNEXPECTED);
            }

            gc.transform(xform);
            retVal = drawImage(img, 0, 0, null);
            gc.transform(inverseTransform);
        } else {
            AffineTransform savTransform = new AffineTransform(gc.getTransform());
            gc.transform(xform);
            retVal = drawImage(img, 0, 0, null);
            gc.setTransform(savTransform);
        }

        return retVal;

    }


    /**
     * Renders a <code>BufferedImage</code> that is
     * filtered with a
     * {@link BufferedImageOp}.
     * The rendering attributes applied include the <code>Clip</code>,
     * <code>Transform</code>
     * and <code>Composite</code> attributes.  This is equivalent to:
     * <pre>
     * img1 = op.filter(img, null);
     * drawImage(img1, new AffineTransform(1f,0f,0f,1f,x,y), null);
     * </pre>
     * @param op the filter to be applied to the image before rendering
     * @param img the <code>BufferedImage</code> to be rendered
     * @param x the x coordinate in user space where the upper left
     *          corner of the image is rendered
     * @param y the y coordinate in user space where the upper left
     *          corner of the image is rendered
     * @see #setTransform(AffineTransform)
     * @see #setComposite(java.awt.Composite)
     * @see #setClip(Shape)
     */
    public void drawImage(BufferedImage img,
                          BufferedImageOp op,
                          int x,
                          int y){
        //
        // Only convert if the input image is of type sRGB
        // non-premultiplied
        //
        /*if(img.getType() == BufferedImage.TYPE_INT_ARGB){
            //
            // There are two special cases: AffineTransformOp and
            // ColorConvertOp. If the input op is not one of these
            // two, then SVGBufferedImageOp is requested to map the
            // filter to an SVG equivalent.
            //
            if(op instanceof AffineTransformOp){
                AffineTransformOp transformOp = (AffineTransformOp)op;
                AffineTransform transform = transformOp.getTransform();

                if(transform.getDeterminant() != 0){
                    AffineTransform inverseTransform = null;
                    try{
                        inverseTransform = transform.createInverse();
                    }catch(NoninvertibleTransformException e){
                        // This should never happen since we checked the
                        // matrix determinant
                        throw new SVGGraphics2DRuntimeException(ERR_UNEXPECTED);
                    }
                    gc.transform(transform);
                    drawImage(img, x, y, null);
                    gc.transform(inverseTransform);
                }
                else{
                    AffineTransform savTransform =
                    new AffineTransform(gc.getTransform());
                    gc.transform(transform);
                    drawImage(img, x, y, null);
                    gc.setTransform(savTransform);
                }
            }
            else if(op instanceof ColorConvertOp){
                img = op.filter(img, null);
                drawImage(img, x, y, null);
            }
            else{
                //
                // Try and convert to an SVG filter
                //
                SVGFilterDescriptor filterDesc =
                domTreeManager.getFilterConverter().toSVG(op, null);
                if(filterDesc != null){
                //
                // Because other filters may be needed to represent the
                // composite that applies to this image, a group is created that
                // contains the image element.
                //
                Element imageElement =
                getDOMFactory().
                createElementNS(SVG_NAMESPACE_URI, SVG_IMAGE_TAG);
                getImageHandler().handleImage((Image)img, imageElement,
                generatorCtx);
                imageElement.setAttributeNS(null, SVG_X_ATTRIBUTE,
                Integer.toString(x));
                imageElement.setAttributeNS(null, SVG_Y_ATTRIBUTE,
                Integer.toString(y));
                imageElement.setAttributeNS(null, SVG_WIDTH_ATTRIBUTE,
                Integer.toString(img.getWidth(null)));
                imageElement.setAttributeNS(null, SVG_HEIGHT_ATTRIBUTE,
                Integer.toString(img.getHeight(null)));
                imageElement.setAttributeNS(null, SVG_FILTER_ATTRIBUTE,
                filterDesc.getFilterValue());
                Element imageGroup = generatorCtx.domFactory.createElementNS(SVG_NAMESPACE_URI,
                SVG_G_TAG);
                imageGroup.appendChild(imageElement);

                    domGroupManager.addElement(imageGroup);
                }
                else{
                    //
                    // Could not convert to an equivalent SVG filter:
                    // filter now and draw resulting image
                    //
                    img = op.filter(img, null);
                    drawImage(img, x, y, null);
                }
            }
        }
        else{*/
            //
            // Input image is not sRGB non premultiplied.
            // Do not try conversion: apply filter and paint
            //
        img = op.filter(img, null);
        drawImage(img, x, y, null);
            // }
    }


    /**
     * Renders a {@link RenderedImage},
     * applying a transform from image
     * space into user space before drawing.
     * The transformation from user space into device space is done with
     * the current <code>Transform</code> in the <code>Graphics2D</code>.
     * The specified transformation is applied to the image before the
     * transform attribute in the <code>Graphics2D</code> context is applied.
     * The rendering attributes applied include the <code>Clip</code>,
     * <code>Transform</code>, and <code>Composite</code> attributes. Note
     * that no rendering is done if the specified transform is
     * noninvertible.
     * @param img the image to be rendered
     * @param trans2 the transformation from image space into user space
     * @see #setTransform(AffineTransform)
     * @see #setComposite(java.awt.Composite)
     * @see #setClip(Shape)
     */
    public void drawRenderedImage(RenderedImage img,
                                  AffineTransform trans2) {

        Element image =
            getGenericImageHandler().createElement(getGeneratorContext());
        AffineTransform trans1
            = getGenericImageHandler().handleImage(
                                       img, image,
                                       img.getMinX(),
                                       img.getMinY(),
                                       img.getWidth(),
                                       img.getHeight(),
                                       getGeneratorContext());

        AffineTransform xform;

        // Concatenate the transformation we receive from the imageHandler
        // to the user-supplied one. Be aware that both may be null.
        if (trans2 == null) {
            xform = trans1;
        } else {
            if(trans1 == null) {
                xform = trans2;
             } else {
                xform = new AffineTransform(trans2);
                xform.concatenate(trans1);
            }
        }

        if(xform == null) {
            domGroupManager.addElement(image);
        } else if(xform.getDeterminant() != 0){
            AffineTransform inverseTransform = null;
            try{
                inverseTransform = xform.createInverse();
            }catch(NoninvertibleTransformException e){
                // This should never happen since we checked
                // the matrix determinant
                throw new SVGGraphics2DRuntimeException(ERR_UNEXPECTED);
            }
            gc.transform(xform);
            domGroupManager.addElement(image);
            gc.transform(inverseTransform);
        } else {
            AffineTransform savTransform = new AffineTransform(gc.getTransform());
            gc.transform(xform);
            domGroupManager.addElement(image);
            gc.setTransform(savTransform);
        }
    }

    /**
     * Renders a
     * {@link RenderableImage},
     * applying a transform from image space into user space before drawing.
     * The transformation from user space into device space is done with
     * the current <code>Transform</code> in the <code>Graphics2D</code>.
     * The specified transformation is applied to the image before the
     * transform attribute in the <code>Graphics2D</code> context is applied.
     * The rendering attributes applied include the <code>Clip</code>,
     * <code>Transform</code>, and <code>Composite</code> attributes. Note
     * that no rendering is done if the specified transform is
     * noninvertible.
     * <p>
     * Rendering hints set on the <code>Graphics2D</code> object might
     * be used in rendering the <code>RenderableImage</code>.
     * If explicit control is required over specific hints recognized by a
     * specific <code>RenderableImage</code>, or if knowledge of which hints
     * are used is required, then a <code>RenderedImage</code> should be
     * obtained directly from the <code>RenderableImage</code>
     * and rendered using
     * {@link #drawRenderedImage(RenderedImage, AffineTransform)}.
     * @param img the image to be rendered
     * @param trans2 the transformation from image space into user space
     * @see #setTransform(AffineTransform)
     * @see #setComposite(java.awt.Composite)
     * @see #setClip(Shape)
     * @see #drawRenderedImage
     */
    public void drawRenderableImage(RenderableImage img,
                                    AffineTransform trans2){

        Element image =
            getGenericImageHandler().createElement(getGeneratorContext());

        AffineTransform trans1 =
            getGenericImageHandler().handleImage(
                                     img, image,
                                     img.getMinX(),
                                     img.getMinY(),
                                     img.getWidth(),
                                     img.getHeight(),
                                     getGeneratorContext());

        AffineTransform xform;

        // Concatenate the transformation we receive from the imageHandler
        // to the user-supplied one. Be aware that both may be null.
        if (trans2 == null) {
            xform = trans1;
        } else {
            if(trans1 == null) {
                xform = trans2;
             } else {
                xform = new AffineTransform(trans2);
                xform.concatenate(trans1);
            }
        }

        if (xform == null) {
            domGroupManager.addElement(image);
        } else if(xform.getDeterminant() != 0){
            AffineTransform inverseTransform = null;
            try{
                inverseTransform = xform.createInverse();
            }catch(NoninvertibleTransformException e){
                // This should never happen because we checked the
                // matrix determinant
                throw new SVGGraphics2DRuntimeException(ERR_UNEXPECTED);
            }
            gc.transform(xform);
            domGroupManager.addElement(image);
            gc.transform(inverseTransform);
        } else {
            AffineTransform savTransform = new AffineTransform(gc.getTransform());
            gc.transform(xform);
            domGroupManager.addElement(image);
            gc.setTransform(savTransform);
        }
    }


    /**
     * Renders the text specified by the specified <code>String</code>,
     * using the current <code>Font</code> and <code>Paint</code> attributes
     * in the <code>Graphics2D</code> context.
     * The baseline of the first character is at position
     * (<i>x</i>,&nbsp;<i>y</i>) in the User Space.
     * The rendering attributes applied include the <code>Clip</code>,
     * <code>Transform</code>, <code>Paint</code>, <code>Font</code> and
     * <code>Composite</code> attributes. For characters in script systems
     * such as Hebrew and Arabic, the glyphs can be rendered from right to
     * left, in which case the coordinate supplied is the location of the
     * leftmost character on the baseline.
     * @param s the <code>String</code> to be rendered
     * @param x the x coordinate where the <code>String</code>
     *          should be rendered
     * @param y the y coordinate where the <code>String</code>
     *          should be rendered
     * @see #setPaint(Paint)
     * @see java.awt.Graphics#setColor
     * @see java.awt.Graphics#setFont
     * @see #setTransform(AffineTransform)
     * @see #setComposite(java.awt.Composite)
     * @see #setClip(Shape)
     */
    public void drawString(String s, float x, float y) {
        if (textAsShapes)  {
            GlyphVector gv = getFont().
                createGlyphVector(getFontRenderContext(), s);
            drawGlyphVector(gv, x, y);
            return;
        }

        if (generatorCtx.svgFont) {
            // record that the font is being used to draw this
            // string, this is so that the SVG Font element will
            // only create glyphs for the characters that are
            // needed
            domTreeManager.gcConverter.
                getFontConverter().recordFontUsage(s, getFont());
        }

        // Account for the font transform if there is one
        AffineTransform savTxf = getTransform();
        AffineTransform txtTxf = transformText(x, y);

        Element text =
            getDOMFactory().createElementNS(SVG_NAMESPACE_URI, SVG_TEXT_TAG);
        text.setAttributeNS(null, SVG_X_ATTRIBUTE, generatorCtx.doubleString(x));
        text.setAttributeNS(null, SVG_Y_ATTRIBUTE, generatorCtx.doubleString(y));

        text.setAttributeNS(XML_NAMESPACE_URI,
                            XML_SPACE_QNAME,
                            XML_PRESERVE_VALUE);
        text.appendChild(getDOMFactory().createTextNode(s));
        domGroupManager.addElement(text, DOMGroupManager.FILL);

        if (txtTxf != null){
            this.setTransform(savTxf);
        }
    }

    private AffineTransform transformText(float x, float y) {
        AffineTransform txtTxf = null;
        Font font = getFont();
        if (font != null){
            txtTxf = font.getTransform();
            if (txtTxf != null && !txtTxf.isIdentity()){
                //
                // The additional transform applies about the text's origin
                //
                AffineTransform t = new AffineTransform();
                t.translate(x, y);
                t.concatenate(txtTxf);
                t.translate(-x, -y);
                this.transform(t);
            } else {
                txtTxf = null;
            }
        }
        return txtTxf;
    }

    /**
     * Renders the text of the specified iterator, using the
     * <code>Graphics2D</code> context's current <code>Paint</code>. The
     * iterator must specify a font
     * for each character. The baseline of the
     * first character is at position (<i>x</i>,&nbsp;<i>y</i>) in the
     * User Space.
     * The rendering attributes applied include the <code>Clip</code>,
     * <code>Transform</code>, <code>Paint</code>, and
     * <code>Composite</code> attributes.
     * For characters in script systems such as Hebrew and Arabic,
     * the glyphs can be rendered from right to left, in which case the
     * coordinate supplied is the location of the leftmost character
     * on the baseline.<br />
     *
     *
     * @param ati the iterator whose text is to be rendered
     * @param x the x coordinate where the iterator's text is to be rendered
     * @param y the y coordinate where the iterator's text is to be rendered
     * @see #setPaint(Paint)
     * @see java.awt.Graphics#setColor
     * @see #setTransform(AffineTransform)
     * @see #setComposite(java.awt.Composite)
     * @see #setClip(Shape)
     */
    public void drawString(AttributedCharacterIterator ati, float x, float y) {
        if ((textAsShapes) || (usesUnsupportedAttributes(ati))) {
            TextLayout layout = new TextLayout(ati, getFontRenderContext());
            layout.draw(this, x, y);
            return;
        }
        // first we want if there is more than one run in this
        // ati. This will be used to decide if we create tspan
        // Elements under the text Element or not
        boolean multiSpans = false;
        if (ati.getRunLimit() < ati.getEndIndex()) multiSpans = true;

        // create the parent text Element
        Element text = getDOMFactory().createElementNS(SVG_NAMESPACE_URI,
                                                       SVG_TEXT_TAG);
        text.setAttributeNS(null, SVG_X_ATTRIBUTE,
                            generatorCtx.doubleString(x));
        text.setAttributeNS(null, SVG_Y_ATTRIBUTE,
                            generatorCtx.doubleString(y));
        text.setAttributeNS(XML_NAMESPACE_URI, XML_SPACE_QNAME,
                            XML_PRESERVE_VALUE);

        Font  baseFont  = getFont();
        Paint basePaint = getPaint();

        // now iterate through all the runs
        char ch = ati.first();

        setTextElementFill   (ati);
        setTextFontAttributes(ati, baseFont);

        SVGGraphicContext textGC;
        textGC = domTreeManager.getGraphicContextConverter().toSVG(gc);
        domGroupManager.addElement(text, DOMGroupManager.FILL);
        textGC.getContext().put(SVG_STROKE_ATTRIBUTE, SVG_NONE_VALUE);
        textGC.getGroupContext().put(SVG_STROKE_ATTRIBUTE, SVG_NONE_VALUE);

        boolean firstSpan = true;
        AffineTransform savTxf = getTransform();
        AffineTransform txtTxf = null;
        while (ch != AttributedCharacterIterator.DONE) {
            // first get the text Element or create a child Element if
            // we used tspans
            Element tspan = text;
            if (multiSpans) {
                tspan = getDOMFactory().createElementNS
                    (SVG_NAMESPACE_URI, SVG_TSPAN_TAG);
                text.appendChild(tspan);
            }

            // decorate the tspan Element :
            setTextElementFill(ati);
            boolean resetTransform = setTextFontAttributes(ati, baseFont);

            // management of font attributes
            if (resetTransform || firstSpan) {
                // Account for the font transform if there is one
                txtTxf = transformText(x, y);
                firstSpan = false;
            }

            // retrieve the current span of text for the run
            int start = ati.getIndex();
            int end   = ati.getRunLimit()-1;

            StringBuffer buf = new StringBuffer( end - start );
            buf.append(ch);

            for (int i=start; i<end; i++) {
                ch = ati.next();
                buf.append(ch);
            }

            String s = buf.toString();
            if (generatorCtx.isEmbeddedFontsOn()) {
                // record that the font is being used to draw this
                // string, this is so that the SVG Font element will
                // only create glyphs for the characters that are
                // needed
                getDOMTreeManager().getGraphicContextConverter().
                    getFontConverter().recordFontUsage(s, getFont());
            }

            // This must come after registering font usage other
            // wise it doesn't know what chars were used.
            SVGGraphicContext elementGC;
            elementGC = domTreeManager.gcConverter.toSVG(gc);
            elementGC.getGroupContext().put(SVG_STROKE_ATTRIBUTE,
                                            SVG_NONE_VALUE);

            SVGGraphicContext deltaGC;
            deltaGC = DOMGroupManager.processDeltaGC(elementGC, textGC);

            // management of underline, strike attributes, etc..
            setTextElementAttributes(deltaGC, ati);

            domTreeManager.getStyleHandler().
                setStyle(tspan, deltaGC.getContext(),
                         domTreeManager.getGeneratorContext());

            tspan.appendChild(getDOMFactory().createTextNode(s));
            if ((resetTransform || firstSpan) && (txtTxf != null)) {
                this.setTransform(savTxf);
            }
            ch = ati.next();  // get first char of next run.
        }
        setFont(baseFont);
        setPaint(basePaint);
    }

    /**
     * Fills the interior of a <code>Shape</code> using the settings of the
     * <code>Graphics2D</code> context. The rendering attributes applied
     * include the <code>Clip</code>, <code>Transform</code>,
     * <code>Paint</code>, and <code>Composite</code>.
     * @param s the <code>Shape</code> to be filled
     * @see #setPaint(Paint)
     * @see java.awt.Graphics#setColor
     * @see #setTransform(AffineTransform)
     * @see #setComposite(java.awt.Composite)
     * @see #setClip(Shape)
     */
    public void fill(Shape s) {
        Element svgShape = shapeConverter.toSVG(s);
        if (svgShape != null) {
            domGroupManager.addElement(svgShape, DOMGroupManager.FILL);
        }
    }

    /** Set the Element Font and Size attributes, depending on the
     * AttributedCharacterIterator attributes.
     */
    private boolean setTextFontAttributes(AttributedCharacterIterator ati,
                                          Font baseFont) {
        boolean resetTransform = false;
        if ((ati.getAttribute(TextAttribute.FONT) != null) ||
            (ati.getAttribute(TextAttribute.FAMILY) != null) ||
            (ati.getAttribute(TextAttribute.WEIGHT) != null) ||
            (ati.getAttribute(TextAttribute.POSTURE) != null) ||
            (ati.getAttribute(TextAttribute.SIZE) != null)) {
            Map m = ati.getAttributes();
            Font f = baseFont.deriveFont(m);
            setFont(f);
            resetTransform = true;
        }

        return resetTransform;
    }

    /** Set the Element attributes, depending on the AttributedCharacterIterator attributes.
     *  The following attributes are set :
     *  <ul>
     *  <li>underline</li>
     *  <li>weight (bold or plain)</li>
     *  <li>style (italic or normal)</li>
     *  <li>justification (start, end, or middle)</li>
     *  </ul>
     */
    private void setTextElementFill(AttributedCharacterIterator ati) {
        if (ati.getAttribute(TextAttribute.FOREGROUND) != null) {
            Color color = (Color)ati.getAttribute(TextAttribute.FOREGROUND);
            setPaint(color);
        }
    }

    private void setTextElementAttributes(SVGGraphicContext tspanGC,
                                          AttributedCharacterIterator ati) {
        String decoration = "";
        if (isUnderline(ati))
            decoration += CSS_UNDERLINE_VALUE + " ";
        if (isStrikeThrough(ati))
            decoration += CSS_LINE_THROUGH_VALUE + " ";
        int len = decoration.length();
        if (len != 0)
            tspanGC.getContext().put(CSS_TEXT_DECORATION_PROPERTY,
                                     decoration.substring(0, len-1));
    }

    /** Return true if the AttributedCharacterIterator is bold (at its current position).
     */
    private boolean isBold(AttributedCharacterIterator ati) {
        Object weight = ati.getAttribute(TextAttribute.WEIGHT);
        if (weight == null)
            return false;
        if (weight.equals(TextAttribute.WEIGHT_REGULAR))
            return false;
        if (weight.equals(TextAttribute.WEIGHT_DEMILIGHT))
            return false;
        if (weight.equals(TextAttribute.WEIGHT_EXTRA_LIGHT))
            return false;
        if (weight.equals(TextAttribute.WEIGHT_LIGHT))
            return false;
        return true;
    }

    /** Return true if the AttributedCharacterIterator is italic (at
     * its current position).
     */
    private boolean isItalic(AttributedCharacterIterator ati) {
        Object attr = ati.getAttribute(TextAttribute.POSTURE);
        if (TextAttribute.POSTURE_OBLIQUE.equals(attr)) return true;
        return false;
    }

    /** Return true if the AttributedCharacterIterator is underlined
     * (at its current position).
     */
    private boolean isUnderline(AttributedCharacterIterator ati) {
        Object attr = ati.getAttribute(TextAttribute.UNDERLINE);
        if (TextAttribute.UNDERLINE_ON.equals(attr)) return true;
        // What to do about UNDERLINE_LOW_*?  Right now we don't
        // draw them since we can't really model them...
        else return false;
    }

    /** Return true if the AttributedCharacterIterator is striked
     * through (at its current position).
     */
    private boolean isStrikeThrough(AttributedCharacterIterator ati) {
        Object attr = ati.getAttribute(TextAttribute.STRIKETHROUGH);
        if (TextAttribute.STRIKETHROUGH_ON.equals(attr)) return true;
        return false;
    }

    /**
     * Returns the device configuration associated with this
     * <code>Graphics2D</code>.
     */
    public GraphicsConfiguration getDeviceConfiguration(){
        // TO BE DONE.
        return null;
    }

    /* This is the list of attributes that can't currently be
     * supported by drawString(AttributedCharacterIterator).
     * For accuracy if any of these are present then the
     * text is drawn as outlines.
     */
    protected Set unsupportedAttributes;
    {
        unsupportedAttributes = new HashSet();
        unsupportedAttributes.add(TextAttribute.BACKGROUND);
        unsupportedAttributes.add(TextAttribute.BIDI_EMBEDDING);
        unsupportedAttributes.add(TextAttribute.CHAR_REPLACEMENT);
        unsupportedAttributes.add(TextAttribute.JUSTIFICATION);
        unsupportedAttributes.add(TextAttribute.RUN_DIRECTION);
        unsupportedAttributes.add(TextAttribute.SUPERSCRIPT);
        unsupportedAttributes.add(TextAttribute.SWAP_COLORS);
        unsupportedAttributes.add(TextAttribute.TRANSFORM);
        unsupportedAttributes.add(TextAttribute.WIDTH);
    }

    /**
     * This method let's users indicate that they don't care that
     * certain text attributes will not be properly converted to
     * SVG, in exchange when those attributes are used they will
     * get real SVG text instead of paths.
     *
     * @param attrs The set of attrs to treat as unsupported, and
     *              if present cause text to be drawn as paths.
     *              If null ACI text will be rendered as text
     *              (unless 'textAsShapes' is set).
     */
    public void setUnsupportedAttributes(Set attrs) {
        if (attrs == null) unsupportedAttributes = null;
        else               unsupportedAttributes = new HashSet(attrs);
    }

    public boolean usesUnsupportedAttributes(AttributedCharacterIterator aci){
        if (unsupportedAttributes == null) return false;

        Set      allAttrs = aci.getAllAttributeKeys();
        Iterator iter     = allAttrs.iterator();
        while (iter.hasNext()) {
            if (unsupportedAttributes.contains(iter.next())) {
                return true;
            }
        }
        return false;
    }

}
