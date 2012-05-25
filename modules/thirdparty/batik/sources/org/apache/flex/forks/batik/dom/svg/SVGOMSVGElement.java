/*

   Copyright 2000-2004  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.dom.svg;

import java.awt.geom.AffineTransform;
import java.util.List;

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.util.XLinkSupport;
import org.apache.flex.forks.batik.dom.util.XMLSupport;
import org.apache.flex.forks.batik.dom.util.ListNodeList;

import org.w3c.dom.DOMException;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.css.CSSStyleDeclaration;
import org.w3c.dom.css.DocumentCSS;
import org.w3c.dom.css.ViewCSS;
import org.w3c.dom.events.DocumentEvent;
import org.w3c.dom.events.Event;
import org.w3c.dom.stylesheets.DocumentStyle;
import org.w3c.dom.stylesheets.StyleSheetList;
import org.w3c.flex.forks.dom.svg.SVGAngle;
import org.w3c.flex.forks.dom.svg.SVGAnimatedBoolean;
import org.w3c.flex.forks.dom.svg.SVGAnimatedLength;
import org.w3c.flex.forks.dom.svg.SVGAnimatedPreserveAspectRatio;
import org.w3c.flex.forks.dom.svg.SVGAnimatedRect;
import org.w3c.flex.forks.dom.svg.SVGElement;
import org.w3c.flex.forks.dom.svg.SVGException;
import org.w3c.flex.forks.dom.svg.SVGLength;
import org.w3c.flex.forks.dom.svg.SVGMatrix;
import org.w3c.flex.forks.dom.svg.SVGNumber;
import org.w3c.flex.forks.dom.svg.SVGPoint;
import org.w3c.flex.forks.dom.svg.SVGRect;
import org.w3c.flex.forks.dom.svg.SVGSVGElement;
import org.w3c.flex.forks.dom.svg.SVGStringList;
import org.w3c.flex.forks.dom.svg.SVGTransform;
import org.w3c.flex.forks.dom.svg.SVGViewSpec;
import org.w3c.dom.views.AbstractView;
import org.w3c.dom.views.DocumentView;

/**
 * This class implements {@link org.w3c.flex.forks.dom.svg.SVGSVGElement}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMSVGElement.java,v 1.31 2005/02/28 17:37:18 deweese Exp $
 */
public class SVGOMSVGElement
    extends    SVGStylableElement
    implements SVGSVGElement {

    /**
     * The attribute initializer.
     */
    protected final static AttributeInitializer attributeInitializer;
    static {
        attributeInitializer = new AttributeInitializer(7);
        attributeInitializer.addAttribute(XMLSupport.XMLNS_NAMESPACE_URI,
                                          null,
                                          "xmlns",
                                          SVG_NAMESPACE_URI);
        attributeInitializer.addAttribute(XMLSupport.XMLNS_NAMESPACE_URI,
                                          "xmlns",
                                          "xlink",
                                          XLinkSupport.XLINK_NAMESPACE_URI);
        attributeInitializer.addAttribute(null,
                                          null,
                                          SVG_PRESERVE_ASPECT_RATIO_ATTRIBUTE,
                                          "xMidYMid meet");
        attributeInitializer.addAttribute(null,
                                          null,
                                          SVG_ZOOM_AND_PAN_ATTRIBUTE,
                                          SVG_MAGNIFY_VALUE);
        attributeInitializer.addAttribute(null,
                                          null,
                                          SVG_VERSION_ATTRIBUTE,
                                          SVG_VERSION);
        attributeInitializer.addAttribute(null,
                                          null,
                                          SVG_CONTENT_SCRIPT_TYPE_ATTRIBUTE,
                                          "text/ecmascript");
        attributeInitializer.addAttribute(null,
                                          null,
                                          SVG_CONTENT_STYLE_TYPE_ATTRIBUTE,
                                          "text/css");
    }

    /**
     * Creates a new SVGOMSVGElement object.
     */
    protected SVGOMSVGElement() {
    }

    /**
     * Creates a new SVGOMSVGElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    public SVGOMSVGElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }

    /**
     * <b>DOM</b>: Implements {@link Node#getLocalName()}.
     */
    public String getLocalName() {
        return SVG_SVG_TAG;
    }

    /**
     * <b>DOM</b>: Implements {@link SVGSVGElement#getX()}.
     */
    public SVGAnimatedLength getX() {
        return getAnimatedLengthAttribute
            (null, SVG_X_ATTRIBUTE, SVG_RECT_X_DEFAULT_VALUE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGSVGElement#getY()}.
     */
    public SVGAnimatedLength getY() {
        return getAnimatedLengthAttribute
            (null, SVG_Y_ATTRIBUTE, SVG_SVG_Y_DEFAULT_VALUE,
             SVGOMAnimatedLength.VERTICAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGSVGElement#getWidth()}.
     */
    public SVGAnimatedLength getWidth() {
        return getAnimatedLengthAttribute
            (null, SVG_WIDTH_ATTRIBUTE, SVG_SVG_WIDTH_DEFAULT_VALUE,
             SVGOMAnimatedLength.HORIZONTAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGSVGElement#getHeight()}.
     */
    public SVGAnimatedLength getHeight() {
        return getAnimatedLengthAttribute
            (null, SVG_HEIGHT_ATTRIBUTE, SVG_SVG_HEIGHT_DEFAULT_VALUE,
             SVGOMAnimatedLength.VERTICAL_LENGTH);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGSVGElement#getContentScriptType()}.
     */
    public String getContentScriptType() {
        return getAttributeNS(null, SVG_CONTENT_SCRIPT_TYPE_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGSVGElement#setContentScriptType(String)}.
     */
    public void setContentScriptType(String type) {
        setAttributeNS(null, SVG_CONTENT_SCRIPT_TYPE_ATTRIBUTE, type);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGSVGElement#getContentStyleType()}.
     */
    public String getContentStyleType() {
        return getAttributeNS(null, SVG_CONTENT_STYLE_TYPE_ATTRIBUTE);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGSVGElement#setContentStyleType(String)}.
     */
    public void setContentStyleType(String type) {
        setAttributeNS(null, SVG_CONTENT_STYLE_TYPE_ATTRIBUTE, type);
    }

    /**
     * <b>DOM</b>: Implements {@link SVGSVGElement#getViewport()}.
     */
    public SVGRect getViewport() {
        SVGContext ctx = getSVGContext();
        return new SVGOMRect(0, 0, ctx.getViewportWidth(), 
                             ctx.getViewportHeight());
    } 

    public float getPixelUnitToMillimeterX( ) {
        return getSVGContext().getPixelUnitToMillimeter();
    }
    public float getPixelUnitToMillimeterY( ) {
        return getSVGContext().getPixelUnitToMillimeter();
    }
    public float getScreenPixelToMillimeterX( ) {
        return getSVGContext().getPixelUnitToMillimeter();
    }
    public float getScreenPixelToMillimeterY( ) {
        return getSVGContext().getPixelUnitToMillimeter();
    }
    public boolean getUseCurrentView( ) {
        throw new Error();
    }
    public void      setUseCurrentView( boolean useCurrentView )
        throws DOMException {
        throw new Error();
    }
    public SVGViewSpec getCurrentView( ) {
        throw new Error();
    }
    public float getCurrentScale( ) {
        AffineTransform scrnTrans = getSVGContext().getScreenTransform();
        if (scrnTrans != null)
            return (float)Math.sqrt(scrnTrans.getDeterminant());
        return 1;
    }
    public void setCurrentScale( float currentScale ) throws DOMException {
        SVGContext context = getSVGContext();
        AffineTransform scrnTrans = context.getScreenTransform();
        float scale = 1;
        if (scrnTrans != null)
            scale = (float)Math.sqrt(scrnTrans.getDeterminant());
        float delta = currentScale/scale;
        // The way currentScale, currentTranslate are defined
        // changing scale has no effect on translate.
        scrnTrans = new AffineTransform
            (scrnTrans.getScaleX()*delta, scrnTrans.getShearY()*delta,
             scrnTrans.getShearX()*delta, scrnTrans.getScaleY()*delta,
             scrnTrans.getTranslateX(), scrnTrans.getTranslateY());
        context.setScreenTransform(scrnTrans);
    }

    public SVGPoint getCurrentTranslate( ) {
        final SVGOMElement svgelt  = this;
        return new SVGPoint() {
                AffineTransform getScreenTransform() {
                    SVGContext context = svgelt.getSVGContext();
                    return context.getScreenTransform();
                }
                    
                public float getX() {
                    AffineTransform scrnTrans = getScreenTransform();
                    return (float)scrnTrans.getTranslateX();
                }
                public float getY() {
                    AffineTransform scrnTrans = getScreenTransform();
                    return (float)scrnTrans.getTranslateY();
                }
                public void setX(float newX) {
                    SVGContext context = svgelt.getSVGContext();
                    AffineTransform scrnTrans = context.getScreenTransform();
                    scrnTrans = new AffineTransform
                        (scrnTrans.getScaleX(), scrnTrans.getShearY(),
                         scrnTrans.getShearX(), scrnTrans.getScaleY(),
                         newX, scrnTrans.getTranslateY());
                    context.setScreenTransform(scrnTrans);
                }
                public void setY(float newY) {
                    SVGContext context = svgelt.getSVGContext();
                    AffineTransform scrnTrans = context.getScreenTransform();
                    scrnTrans = new AffineTransform
                        (scrnTrans.getScaleX(), scrnTrans.getShearY(),
                         scrnTrans.getShearX(), scrnTrans.getScaleY(),
                         scrnTrans.getTranslateX(), newY);
                    context.setScreenTransform(scrnTrans);
                }
                public SVGPoint matrixTransform ( SVGMatrix mat ) {
                    AffineTransform scrnTrans = getScreenTransform();
                    float x = (float)scrnTrans.getTranslateX();
                    float y = (float)scrnTrans.getTranslateY();
                    float newX = mat.getA()*x + mat.getC()*y + mat.getE();
                    float newY = mat.getB()*x + mat.getD()*y + mat.getF();
                    return new SVGOMPoint(newX, newY);
                }
            };
    }

    public int          suspendRedraw ( int max_wait_milliseconds ) {
        throw new Error();
    }
    public void          unsuspendRedraw ( int suspend_handle_id )
        throws DOMException {
        throw new Error();
    }
    public void          unsuspendRedrawAll (  ) {
        throw new Error();
    }
    public void          forceRedraw (  ) {
        throw new Error();
    }
    public void          pauseAnimations (  ) {
        throw new Error();
    }
    public void          unpauseAnimations (  ) {
        throw new Error();
    }
    public boolean       animationsPaused (  ) {
        throw new Error();
    }
    public float         getCurrentTime (  ) {
        throw new Error();
    }
    public void          setCurrentTime ( float seconds ) {
        throw new Error();
    }

    public NodeList      getIntersectionList ( SVGRect rect,
                                               SVGElement referenceElement ) {
        SVGSVGContext ctx = (SVGSVGContext)getSVGContext();
        List list = ctx.getIntersectionList(rect, referenceElement);
        return new ListNodeList(list);
    }

    public NodeList      getEnclosureList ( SVGRect rect,
                                            SVGElement referenceElement ) {
        SVGSVGContext ctx = (SVGSVGContext)getSVGContext();
        List list = ctx.getEnclosureList(rect, referenceElement);
        return new ListNodeList(list);
    }
    public boolean checkIntersection(SVGElement element, SVGRect rect) {
        SVGSVGContext ctx = (SVGSVGContext)getSVGContext();
        return ctx.checkIntersection(element, rect);
    }
    public boolean checkEnclosure(SVGElement element, SVGRect rect) {
        SVGSVGContext ctx = (SVGSVGContext)getSVGContext();
        return ctx.checkEnclosure(element, rect);
    }

    public void          deselectAll (  ) {
        ((SVGSVGContext)getSVGContext()).deselectAll();
    }

    /**
     * <b>DOM</b>: Implements {@link SVGSVGElement#createSVGNumber()}.
     */
    public SVGNumber createSVGNumber() {
        return new SVGNumber() {
                float value;
                public float getValue() {
                    return value;
                }
                public void setValue(float f) {
                    value = f;
                }
            };
    }

    /**
     * <b>DOM</b>: Implements {@link SVGSVGElement#createSVGLength()}.
     */
    public SVGLength createSVGLength() {
        return new SVGOMLength(this);
    }

    public SVGAngle               createSVGAngle (  ) {
        throw new Error();
    }

    /**
     * <b>DOM</b>: Implements {@link SVGSVGElement#createSVGPoint()}.
     */
    public SVGPoint createSVGPoint() {
        return new SVGOMPoint(0, 0);
    }

    public SVGMatrix              createSVGMatrix (  ) {
        return new AbstractSVGMatrix() {
                AffineTransform at = new AffineTransform();
                protected AffineTransform getAffineTransform() { return at; }
            };
    }
    public SVGRect                createSVGRect (  ) {
        return new SVGOMRect(0,0,0,0);
    }
    public SVGTransform createSVGTransform () {
        SVGOMTransform ret = new SVGOMTransform();
        ret.setType(SVGTransform.SVG_TRANSFORM_MATRIX);
        return ret;
    }
    public SVGTransform createSVGTransformFromMatrix ( SVGMatrix matrix ) {
        SVGOMTransform tr = new SVGOMTransform();
        tr.setMatrix(matrix);
        return tr;
    }
    public Element         getElementById ( String elementId ) {
        return ownerDocument.getChildElementById(this, elementId);
    }

    // SVGLocatable ///////////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGLocatable#getNearestViewportElement()}.
     */
    public SVGElement getNearestViewportElement() {
	return SVGLocatableSupport.getNearestViewportElement(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGLocatable#getFarthestViewportElement()}.
     */
    public SVGElement getFarthestViewportElement() {
	return SVGLocatableSupport.getFarthestViewportElement(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGLocatable#getBBox()}.
     */
    public SVGRect getBBox() {
	return SVGLocatableSupport.getBBox(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGLocatable#getCTM()}.
     */
    public SVGMatrix getCTM() {
	return SVGLocatableSupport.getCTM(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGLocatable#getScreenCTM()}.
     */
    public SVGMatrix getScreenCTM() {
	return SVGLocatableSupport.getScreenCTM(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGLocatable#getTransformToElement(SVGElement)}.
     */
    public SVGMatrix getTransformToElement(SVGElement element)
	throws SVGException {
	return SVGLocatableSupport.getTransformToElement(this, element);
    }

    // ViewCSS ////////////////////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.views.AbstractView#getDocument()}.
     */
    public DocumentView getDocument() {
        return (DocumentView)getOwnerDocument();
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.css.ViewCSS#getComputedStyle(Element,String)}.
     */
    public CSSStyleDeclaration getComputedStyle(Element elt,
                                                String pseudoElt) {
        AbstractView av = ((DocumentView)getOwnerDocument()).getDefaultView();
        return ((ViewCSS)av).getComputedStyle(elt, pseudoElt);
    }

    // DocumentEvent /////////////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.events.DocumentEvent#createEvent(String)}.
     */
    public Event createEvent(String eventType) throws DOMException {
        return ((DocumentEvent)getOwnerDocument()).createEvent(eventType);
    }

    // DocumentCSS ////////////////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.stylesheets.DocumentStyle#getStyleSheets()}.
     */
    public StyleSheetList getStyleSheets() {
        return ((DocumentStyle)getOwnerDocument()).getStyleSheets();
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.css.DocumentCSS#getOverrideStyle(Element,String)}.
     */
    public CSSStyleDeclaration getOverrideStyle(Element elt,
                                                String pseudoElt) {
        return ((DocumentCSS)getOwnerDocument()).getOverrideStyle(elt,
                                                                  pseudoElt);
    }

    // SVGLangSpace support //////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Returns the xml:lang attribute value.
     */
    public String getXMLlang() {
        return XMLSupport.getXMLLang(this);
    }

    /**
     * <b>DOM</b>: Sets the xml:lang attribute value.
     */
    public void setXMLlang(String lang) {
        setAttributeNS(XMLSupport.XML_NAMESPACE_URI,
                       XMLSupport.XML_LANG_ATTRIBUTE,
                       lang);
    }

    /**
     * <b>DOM</b>: Returns the xml:space attribute value.
     */
    public String getXMLspace() {
        return XMLSupport.getXMLSpace(this);
    }

    /**
     * <b>DOM</b>: Sets the xml:space attribute value.
     */
    public void setXMLspace(String space) {
        setAttributeNS(XMLSupport.XML_NAMESPACE_URI,
                       XMLSupport.XML_SPACE_ATTRIBUTE,
                       space);
    }

    // SVGZoomAndPan support ///////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGZoomAndPan#getZoomAndPan()}.
     */
    public short getZoomAndPan() {
        return SVGZoomAndPanSupport.getZoomAndPan(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGZoomAndPan#getZoomAndPan()}.
     */
    public void setZoomAndPan(short val) {
        SVGZoomAndPanSupport.setZoomAndPan(this, val);
    }

    // SVGFitToViewBox support ////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGFitToViewBox#getViewBox()}.
     */
    public SVGAnimatedRect getViewBox() {
        throw new RuntimeException(" !!! TODO: getViewBox()");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGFitToViewBox#getPreserveAspectRatio()}.
     */
    public SVGAnimatedPreserveAspectRatio getPreserveAspectRatio() {
        return SVGPreserveAspectRatioSupport.getPreserveAspectRatio(this);
    }

    // SVGExternalResourcesRequired support /////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGExternalResourcesRequired#getExternalResourcesRequired()}.
     */
    public SVGAnimatedBoolean getExternalResourcesRequired() {
        return SVGExternalResourcesRequiredSupport.
            getExternalResourcesRequired(this);
    }

    // SVGTests support ///////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTests#getRequiredFeatures()}.
     */
    public SVGStringList getRequiredFeatures() {
        return SVGTestsSupport.getRequiredFeatures(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTests#getRequiredExtensions()}.
     */
    public SVGStringList getRequiredExtensions() {
        return SVGTestsSupport.getRequiredExtensions(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTests#getSystemLanguage()}.
     */
    public SVGStringList getSystemLanguage() {
        return SVGTestsSupport.getSystemLanguage(this);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTests#hasExtension(String)}.
     */
    public boolean hasExtension(String extension) {
        return SVGTestsSupport.hasExtension(this, extension);
    }

    /**
     * Returns the AttributeInitializer for this element type.
     * @return null if this element has no attribute with a default value.
     */
    protected AttributeInitializer getAttributeInitializer() {
        return attributeInitializer;
    }

    /**
     * Returns a new uninitialized instance of this object's class.
     */
    protected Node newNode() {
        return new SVGOMSVGElement();
    }
}
