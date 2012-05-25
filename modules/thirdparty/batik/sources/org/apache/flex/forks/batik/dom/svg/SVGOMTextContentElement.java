/*

   Copyright 2000-2003  The Apache Software Foundation 

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

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.util.XMLSupport;
import org.w3c.dom.DOMException;
import org.w3c.flex.forks.dom.svg.SVGAnimatedBoolean;
import org.w3c.flex.forks.dom.svg.SVGAnimatedEnumeration;
import org.w3c.flex.forks.dom.svg.SVGAnimatedLength;
import org.w3c.flex.forks.dom.svg.SVGLength;
import org.w3c.flex.forks.dom.svg.SVGPoint;
import org.w3c.flex.forks.dom.svg.SVGRect;
import org.w3c.flex.forks.dom.svg.SVGStringList;

/**
 * This class provides a common superclass for all graphics elements.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMTextContentElement.java,v 1.13 2004/12/15 10:50:29 deweese Exp $
 */
public abstract class SVGOMTextContentElement
    extends    SVGStylableElement {

    /**
     * The 'lengthAdjust' attribute values.
     */
    protected final static String[] LENGTH_ADJUST_VALUES = {
        "",
        SVG_SPACING_ATTRIBUTE,
        SVG_SPACING_AND_GLYPHS_VALUE
    };

    /**
     * Creates a new SVGOMTextContentElement.
     */
    protected SVGOMTextContentElement() {
    }

    /**
     * Creates a new SVGOMTextContentElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    protected SVGOMTextContentElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);

    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#getTextLength()}.
     */
    public SVGAnimatedLength getTextLength() {
        SVGAnimatedLength result =
            (SVGAnimatedLength)getLiveAttributeValue
            (null, SVG_TEXT_LENGTH_ATTRIBUTE);
        if (result == null) {
            result = new AbstractSVGAnimatedLength
                (this, null, SVG_TEXT_LENGTH_ATTRIBUTE,
                 SVGOMAnimatedLength.HORIZONTAL_LENGTH) {
                    boolean usedDefault;

                    protected String getDefaultValue() {
                        usedDefault = true;
                        return ""+getComputedTextLength();
                    }

                    public SVGLength getBaseVal() {
                        if (baseVal == null) {
                            baseVal = new SVGTextLength(direction);
                        }
                        return baseVal;
                    }
                    
                    class SVGTextLength extends BaseSVGLength {
                        public SVGTextLength(short direction) {
                            super(direction);
                        }
                        protected void revalidate() {
                            usedDefault = false;

                            super.revalidate();

                            // Since the default value can change w/o notice
                            // always recompute it.
                            if (usedDefault) valid = false;
                        }
                    }
                };
            putLiveAttributeValue(null, SVG_TEXT_LENGTH_ATTRIBUTE,
                                  (LiveAttributeValue)result);
        }
        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#getLengthAdjust()}.
     */
    public SVGAnimatedEnumeration getLengthAdjust() {
        return getAnimatedEnumerationAttribute
            (null, SVG_LENGTH_ADJUST_ATTRIBUTE,
             LENGTH_ADJUST_VALUES, (short)1);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#getNumberOfChars()}.
     */
    public int getNumberOfChars() {
        return SVGTextContentSupport.getNumberOfChars(this);
        //throw new RuntimeException(" !!! SVGOMTextContentElement.getNumberOfChars()");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#getComputedTextLength()}.
     */
    public float getComputedTextLength() {
        return SVGTextContentSupport.getComputedTextLength(this);
        //throw new RuntimeException(" !!! SVGOMTextContentElement.getComputedTextLength()");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#getSubStringLength(int,int)}.
     */
    public float getSubStringLength(int charnum, int nchars)
        throws DOMException {
        return SVGTextContentSupport.getSubStringLength(this,charnum,nchars);
        //throw new RuntimeException(" !!! SVGOMTextContentElement.getSubStringLength()");
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#getStartPositionOfChar(int)}.
     */
    public SVGPoint getStartPositionOfChar(int charnum) throws DOMException {
        //throw new RuntimeException(" !!! SVGOMTextContentElement.getStartPositionOfChar()");
        return SVGTextContentSupport.getStartPositionOfChar(this,charnum);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#getEndPositionOfChar(int)}.
     */
    public SVGPoint getEndPositionOfChar(int charnum) throws DOMException {
        //throw new RuntimeException(" !!! SVGOMTextContentElement.getEndPositionOfChar()");
        return SVGTextContentSupport.getEndPositionOfChar(this,charnum);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#getExtentOfChar(int)}.
     */
    public SVGRect getExtentOfChar(int charnum) throws DOMException {
        //throw new RuntimeException(" !!! SVGOMTextContentElement.getExtentOfChar()");
        return SVGTextContentSupport.getExtentOfChar(this,charnum);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#getRotationOfChar(int)}.
     */
    public float getRotationOfChar(int charnum) throws DOMException {
        //throw new RuntimeException(" !!! SVGOMTextContentElement.getRotationOfChar()");
        return SVGTextContentSupport.getRotationOfChar(this,charnum);
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#getCharNumAtPosition(SVGPoint)}.
     */
    public int getCharNumAtPosition(SVGPoint point) {
        //throw new RuntimeException(" !!! SVGOMTextContentElement.getCharNumAtPosition()");
        return SVGTextContentSupport.getCharNumAtPosition(this,point.getX(),point.getY());
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGTextContentElement#selectSubString(int,int)}.
     */
    public void selectSubString(int charnum, int nchars)
        throws DOMException {
        SVGTextContentSupport.selectSubString(this,charnum, nchars);
        //throw new RuntimeException(" !!! SVGOMTextContentElement.getSubStringLength()");
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
}
