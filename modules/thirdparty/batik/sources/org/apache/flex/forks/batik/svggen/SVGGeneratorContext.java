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

import java.awt.Color;
import java.awt.Composite;
import java.awt.Font;
import java.awt.Paint;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.Stroke;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;

import java.util.Locale;

import org.w3c.dom.Document;

/**
 * This class contains all non graphical contextual information that
 * are needed by the {@link org.apache.flex.forks.batik.svggen.SVGGraphics2D} to
 * generate SVG from Java 2D primitives.
 * You can subclass it to change the defaults.
 *
 * @see org.apache.flex.forks.batik.svggen.SVGGraphics2D#SVGGraphics2D(SVGGeneratorContext,boolean)
 * @author <a href="mailto:cjolif@ilog.fr">Christophe Jolif</a>
 * @version $Id: SVGGeneratorContext.java 478176 2006-11-22 14:50:50Z dvholten $
 */
public class SVGGeneratorContext implements ErrorConstants {
    // this fields are package access for read-only purpose

    /**
     * Factory used by this Graphics2D to create Elements
     * that make the SVG DOM Tree
     */
    Document domFactory;

    /**
     * Handler that defines how images are referenced in the
     * generated SVG fragment. This allows different strategies
     * to be used to handle images.
     * @see org.apache.flex.forks.batik.svggen.ImageHandler
     * @see org.apache.flex.forks.batik.svggen.ImageHandlerBase64Encoder
     * @see org.apache.flex.forks.batik.svggen.ImageHandlerPNGEncoder
     * @see org.apache.flex.forks.batik.svggen.ImageHandlerJPEGEncoder
     */
    ImageHandler imageHandler;

    /**
     * Generic image handler. This allows more sophisticated
     * image handling strategies than the <tt>ImageHandler</tt>
     * interfaces.
     */
    GenericImageHandler genericImageHandler;

    /**
     * To deal with Java 2D extension (custom java.awt.Paint for example).
     */
    ExtensionHandler extensionHandler;

    /**
     * To generate consitent ids.
     */
    SVGIDGenerator idGenerator;

    /**
     * To set style.
     */
    StyleHandler styleHandler;

    /**
     * The comment to insert at generation time.
     */
    String generatorComment;

    /**
     * The error handler.
     */
    ErrorHandler errorHandler;

    /**
     * Do we accept SVG Fonts generation?
     */
    boolean svgFont = false;

    /**
     * GraphicContextDefaults
     */
    GraphicContextDefaults gcDefaults;

    /**
     * Number of decimal places to use in output values.
     * 3 decimal places are used by default.
     */
    int precision = 4;

    /**
     * Current double value formatter
     */
    protected DecimalFormat decimalFormat = decimalFormats[precision];

    /**
     * Class to describe the GraphicContext defaults to
     * be used. Note that this class does *not* contain
     * a default for the initial transform, as this
     * transform *has to be identity* for the SVGGraphics2D
     * to operate (the TransformStacks operation is based
     * on that assumption. See the DOMTreeManager class).
     */
    public static class GraphicContextDefaults {
        protected Paint paint;
        protected Stroke stroke;
        protected Composite composite;
        protected Shape clip;
        protected RenderingHints hints;
        protected Font font;
        protected Color background;

        public void setStroke(Stroke stroke){
            this.stroke = stroke;
        }

        public Stroke getStroke(){
            return stroke;
        }

        public void setComposite(Composite composite){
            this.composite = composite;
        }

        public Composite getComposite(){
            return composite;
        }

        public void setClip(Shape clip){
            this.clip = clip;
        }

        public Shape getClip(){
            return clip;
        }

        public void setRenderingHints(RenderingHints hints){
            this.hints = hints;
        }

        public RenderingHints getRenderingHints(){
            return hints;
        }

        public void setFont(Font font){
            this.font = font;
        }

        public Font getFont(){
            return font;
        }

        public void setBackground(Color background){
            this.background = background;
        }

        public Color getBackground(){
            return background;
        }

        public void setPaint(Paint paint){
            this.paint = paint;
        }

        public Paint getPaint(){
            return paint;
        }
    }

    /**
     * Builds an instance of <code>SVGGeneratorContext</code> with the given
     * <code>domFactory</code> but let the user set later the other contextual
     * information. Please note that none of the parameter below should be
     * <code>null</code>.
     * @see #setIDGenerator
     * @see #setExtensionHandler
     * @see #setImageHandler
     * @see #setStyleHandler
     * @see #setErrorHandler
     */
    protected SVGGeneratorContext(Document domFactory) {
        setDOMFactory(domFactory);
    }

    /**
     * Creates an instance of <code>SVGGeneratorContext</code> with the
     * given <code>domFactory</code> and with the default values for the
     * other information.
     * @see org.apache.flex.forks.batik.svggen.SVGIDGenerator
     * @see org.apache.flex.forks.batik.svggen.DefaultExtensionHandler
     * @see org.apache.flex.forks.batik.svggen.ImageHandlerBase64Encoder
     * @see org.apache.flex.forks.batik.svggen.DefaultStyleHandler
     * @see org.apache.flex.forks.batik.svggen.DefaultErrorHandler
     */
    public static SVGGeneratorContext createDefault(Document domFactory) {
        SVGGeneratorContext ctx = new SVGGeneratorContext(domFactory);
        ctx.setIDGenerator(new SVGIDGenerator());
        ctx.setExtensionHandler(new DefaultExtensionHandler());
        ctx.setImageHandler(new ImageHandlerBase64Encoder());
        ctx.setStyleHandler(new DefaultStyleHandler());
        ctx.setComment("Generated by the Batik Graphics2D SVG Generator");
        ctx.setErrorHandler(new DefaultErrorHandler());
        return ctx;
    }

    /**
     * Returns the set of defaults which should be used for the
     * GraphicContext.
     */
    public final GraphicContextDefaults getGraphicContextDefaults(){
        return gcDefaults;
    }

    /**
     * Sets the default to be used for the graphic context.
     * Note that gcDefaults may be null and that any of its attributes
     * may be null.
     */
    public final void setGraphicContextDefaults(GraphicContextDefaults gcDefaults){
        this.gcDefaults = gcDefaults;
    }

    /**
     * Returns the {@link org.apache.flex.forks.batik.svggen.SVGIDGenerator} that
     * has been set.
     */
    public final SVGIDGenerator getIDGenerator() {
        return idGenerator;
    }

    /**
     * Sets the {@link org.apache.flex.forks.batik.svggen.SVGIDGenerator}
     * to be used. It should not be <code>null</code>.
     */
    public final void setIDGenerator(SVGIDGenerator idGenerator) {
        if (idGenerator == null)
            throw new SVGGraphics2DRuntimeException(ERR_ID_GENERATOR_NULL);
        this.idGenerator = idGenerator;
    }

    /**
     * Returns the DOM Factory that
     * has been set.
     */
    public final Document getDOMFactory() {
        return domFactory;
    }

    /**
     * Sets the DOM Factory
     * to be used. It should not be <code>null</code>.
     */
    public final void setDOMFactory(Document domFactory) {
        if (domFactory == null)
            throw new SVGGraphics2DRuntimeException(ERR_DOM_FACTORY_NULL);
        this.domFactory = domFactory;
    }

    /**
     * Returns the {@link org.apache.flex.forks.batik.svggen.ExtensionHandler} that
     * has been set.
     */
    public final ExtensionHandler getExtensionHandler() {
        return extensionHandler;
    }

    /**
     * Sets the {@link org.apache.flex.forks.batik.svggen.ExtensionHandler}
     * to be used. It should not be <code>null</code>.
     */
    public final void setExtensionHandler(ExtensionHandler extensionHandler) {
        if (extensionHandler == null)
            throw new SVGGraphics2DRuntimeException(ERR_EXTENSION_HANDLER_NULL);
        this.extensionHandler = extensionHandler;
    }

    /**
     * Returns the {@link org.apache.flex.forks.batik.svggen.ImageHandler} that
     * has been set.
     */
    public final ImageHandler getImageHandler() {
        return imageHandler;
    }

    /**
     * Sets the {@link org.apache.flex.forks.batik.svggen.ImageHandler}
     * to be used. It should not be <code>null</code>.
     */
    public final void setImageHandler(ImageHandler imageHandler) {
        if (imageHandler == null)
            throw new SVGGraphics2DRuntimeException(ERR_IMAGE_HANDLER_NULL);
        this.imageHandler = imageHandler;
        this.genericImageHandler = new SimpleImageHandler(imageHandler);
    }

    /**
     * Sets the {@link org.apache.flex.forks.batik.svggen.GenericImageHandler}
     * to be used.
     */
    public final void setGenericImageHandler(GenericImageHandler genericImageHandler){
        if (genericImageHandler == null){
            throw new SVGGraphics2DRuntimeException(ERR_IMAGE_HANDLER_NULL);
        }
        this.imageHandler = null;
        this.genericImageHandler = genericImageHandler;
    }

    /**
     * Returns the {@link org.apache.flex.forks.batik.svggen.StyleHandler} that
     * has been set.
     */
    public final StyleHandler getStyleHandler() {
        return styleHandler;
    }

    /**
     * Sets the {@link org.apache.flex.forks.batik.svggen.StyleHandler}
     * to be used. It should not be <code>null</code>.
     */
    public final void setStyleHandler(StyleHandler styleHandler) {
        if (styleHandler == null)
            throw new SVGGraphics2DRuntimeException(ERR_STYLE_HANDLER_NULL);
        this.styleHandler = styleHandler;
    }

    /**
     * Returns the comment to be generated in the SVG file.
     */
    public final String getComment() {
        return generatorComment;
    }

    /**
     * Sets the comment to be used. It can be <code>null</code> if you
     * want to disable it.
     */
    public final void setComment(String generatorComment) {
        this.generatorComment = generatorComment;
    }

    /**
     * Returns the {@link org.apache.flex.forks.batik.svggen.ErrorHandler} that
     * has been set.
     */
    public final ErrorHandler getErrorHandler() {
        return errorHandler;
    }

    /**
     * Sets the {@link org.apache.flex.forks.batik.svggen.ErrorHandler}
     * to be used. It should not be <code>null</code>.
     */
    public final void setErrorHandler(ErrorHandler errorHandler) {
        if (errorHandler == null)
            throw new SVGGraphics2DRuntimeException(ERR_ERROR_HANDLER_NULL);
        this.errorHandler = errorHandler;
    }

    /**
     * Returns <code>true</code> if we should generate SVG Fonts for
     * texts.
     */
    public final boolean isEmbeddedFontsOn() {
        return svgFont;
    }

    /**
     * Sets if we should generate SVG Fonts for texts. Default value
     * is <code>false</code>.
     */
    public final void setEmbeddedFontsOn(boolean svgFont) {
        this.svgFont = svgFont;
    }

    /**
     * Returns the current precision used by this context
     */
    public final int getPrecision() {
        return precision;
    }

    /**
     * Sets the precision used by this context. The precision controls
     * the number of decimal places used in floating point values
     * output by the SVGGraphics2D generator.
     * Note that the precision is clipped to the [0,12] range.
     */
    public final void setPrecision(int precision) {
        if (precision < 0) {
            this.precision = 0;
        } else if (precision > 12) {
            this.precision = 12;
        } else {
            this.precision = precision;
        }
        decimalFormat = decimalFormats[this.precision];
    }

    /**
     * Converts the input double value to a string with a number of
     * decimal places controlled by the precision attribute.
     */
    public final String doubleString(double value) {
        double absvalue = Math.abs(value);
        // above 10e7 we do not output decimals as anyway
        // in scientific notation they were not available
        if (absvalue >= 10e7 || (int)value == value) {
            return Integer.toString((int)value);
        }
        // under 10e-3 we have to put decimals
        else {
            return decimalFormat.format(value);
        }
    }

    protected static DecimalFormatSymbols dsf
        = new DecimalFormatSymbols(Locale.US);

    protected static DecimalFormat[] decimalFormats = new DecimalFormat[13];

    static {
        decimalFormats[0] = new DecimalFormat("#", dsf);

        String format = "#.";
        for (int i=1; i<decimalFormats.length; i++) {
            format += "#";
            decimalFormats[i] = new DecimalFormat(format, dsf);
        }
    }

}
