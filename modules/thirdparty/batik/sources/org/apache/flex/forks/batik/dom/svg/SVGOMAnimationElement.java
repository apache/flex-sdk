/*

   Copyright 2001-2003  The Apache Software Foundation 

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
import org.w3c.dom.DOMException;
import org.w3c.flex.forks.dom.svg.SVGAnimatedBoolean;
import org.w3c.flex.forks.dom.svg.SVGAnimationElement;
import org.w3c.flex.forks.dom.svg.SVGElement;
import org.w3c.flex.forks.dom.svg.SVGStringList;

/**
 * This class provides an implementation of the SVGAnimationElement interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGOMAnimationElement.java,v 1.5 2004/08/18 07:13:14 vhardy Exp $
 */
public abstract class SVGOMAnimationElement
    extends SVGOMElement
    implements SVGAnimationElement {
    
    /**
     * Creates a new SVGOMAnimationElement.
     */
    protected SVGOMAnimationElement() {
    }

    /**
     * Creates a new SVGOMAnimationElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    protected SVGOMAnimationElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);

    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimationElement#getTargetElement()}.
     */
    public SVGElement getTargetElement() {
        throw new RuntimeException("!!! TODO: getTargetElement()");
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimationElement#getStartTime()}.
     */
    public float getStartTime() {
        throw new RuntimeException("!!! TODO: getStartTime()");
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimationElement#getCurrentTime()}.
     */
    public float getCurrentTime() {
        throw new RuntimeException("!!! TODO: getCurrentTime()");
    }

    /**
     * <b>DOM</b>: Implements {@link SVGAnimationElement#getSimpleDuration()}.
     */
    public float getSimpleDuration() throws DOMException {
        throw new RuntimeException("!!! TODO: getSimpleDuration()");
    }

    // ElementTimeControl ////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.smil.ElementTimeControl#beginElement()}.
     */
    public boolean beginElement() throws DOMException {
        throw new RuntimeException("!!! TODO: beginElement()");
    }
    
    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.smil.ElementTimeControl#beginElementAt(float)}.
     */
    public boolean beginElementAt(float offset) throws DOMException {
        throw new RuntimeException("!!! TODO: beginElementAt()");
    }
    
    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.smil.ElementTimeControl#endElement()}.
     */
    public boolean endElement() throws DOMException {
        throw new RuntimeException("!!! TODO: endElement()");
    }
    
    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.smil.ElementTimeControl#endElementAt(float)}.
     */
    public boolean endElementAt(float offset) throws DOMException {
        throw new RuntimeException("!!! TODO: endElementAt(float)");
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
}
