/*

   Copyright 2001-2004  The Apache Software Foundation 

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

import java.net.MalformedURLException;
import java.net.URL;

import org.apache.flex.forks.batik.css.dom.CSSOMSVGColor;
import org.apache.flex.forks.batik.css.dom.CSSOMSVGPaint;
import org.apache.flex.forks.batik.css.dom.CSSOMSVGStyleDeclaration;
import org.apache.flex.forks.batik.css.dom.CSSOMValue;
import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.css.engine.StyleMap;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.svg.SVGColorManager;
import org.apache.flex.forks.batik.css.engine.value.svg.SVGPaintManager;
import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.Node;
import org.w3c.dom.css.CSSStyleDeclaration;
import org.w3c.dom.css.CSSValue;
import org.w3c.flex.forks.dom.svg.SVGAnimatedString;

/**
 * This class provides a common superclass for elements which implement
 * SVGStylable.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGStylableElement.java,v 1.17 2005/02/22 09:13:01 cam Exp $
 */
public abstract class SVGStylableElement
    extends SVGOMElement
    implements CSSStylableElement {

    /**
     * The computed style map.
     */
    protected StyleMap computedStyleMap;

    /**
     * Creates a new SVGStylableElement object.
     */
    protected SVGStylableElement() {
    }

    /**
     * Creates a new SVGStylableElement object.
     * @param prefix The namespace prefix.
     * @param owner The owner document.
     */
    protected SVGStylableElement(String prefix, AbstractDocument owner) {
        super(prefix, owner);
    }
    
    // CSSStylableElement //////////////////////////////////////////
    
    /**
     * Returns the computed style of this element/pseudo-element.
     */
    public StyleMap getComputedStyleMap(String pseudoElement) {
        return computedStyleMap;
    }

    /**
     * Sets the computed style of this element/pseudo-element.
     */
    public void setComputedStyleMap(String pseudoElement, StyleMap sm) {
        computedStyleMap = sm;
    }

    /**
     * Returns the ID of this element.
     */
    public String getXMLId() {
        return getAttributeNS(null, "id");
    }

    /**
     * Returns the class of this element.
     */
    public String getCSSClass() {
        return getAttributeNS(null, "class");
    }

    /**
     * Returns the CSS base URL of this element.
     */
    public URL getCSSBase() {
        try {
            String bu = XMLBaseSupport.getCascadedXMLBase(this);
            if (bu == null) {
                return null;
            }
            return new URL(bu);
        } catch (MalformedURLException e) {
            // !!! TODO
            e.printStackTrace();
            throw new InternalError();
        }
    }

    /**
     * Tells whether this element is an instance of the given pseudo
     * class.
     */
    public boolean isPseudoInstanceOf(String pseudoClass) {
        if (pseudoClass.equals("first-child")) {
            Node n = getPreviousSibling();
            while (n != null && n.getNodeType() != ELEMENT_NODE) {
                n = n.getPreviousSibling();
            }
            return n == null;
        }
        return false;
    }

    // SVGStylable support ///////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link org.w3c.flex.forks.dom.svg.SVGStylable#getStyle()}.
     */
    public CSSStyleDeclaration getStyle() {
        CSSStyleDeclaration result =
            (CSSStyleDeclaration)getLiveAttributeValue(null,
                                                       SVG_STYLE_ATTRIBUTE);
        if (result == null) {
            CSSEngine eng = ((SVGOMDocument)getOwnerDocument()).getCSSEngine();
            result = new StyleDeclaration(eng);
        }
        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGStylable#getPresentationAttribute(String)}.
     */
    public CSSValue getPresentationAttribute(String name) {
        CSSValue result = (CSSValue)getLiveAttributeValue(null, name);
        if (result != null)
            return result;

        CSSEngine eng = ((SVGOMDocument)getOwnerDocument()).getCSSEngine();
        int idx = eng.getPropertyIndex(name);
        if (idx == -1) 
            return null;

        if (idx > SVGCSSEngine.FINAL_INDEX) {
            if (eng.getValueManagers()[idx] instanceof SVGPaintManager) {
                result = new PresentationAttributePaintValue(eng, name);
            }
            if (eng.getValueManagers()[idx] instanceof SVGColorManager) {
                result = new PresentationAttributeColorValue(eng, name);
            }
        } else {
            switch (idx) {
            case SVGCSSEngine.FILL_INDEX:
            case SVGCSSEngine.STROKE_INDEX:
                result = new PresentationAttributePaintValue(eng, name);
                break;
                
            case SVGCSSEngine.FLOOD_COLOR_INDEX:
            case SVGCSSEngine.LIGHTING_COLOR_INDEX:
            case SVGCSSEngine.STOP_COLOR_INDEX:
                result = new PresentationAttributeColorValue(eng, name);
                break;
                
            default:
                result = new PresentationAttributeValue(eng, name);
            }
        }
        putLiveAttributeValue(null, name, (LiveAttributeValue)result);
        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.flex.forks.dom.svg.SVGStylable#getClassName()}.
     */
    public SVGAnimatedString getClassName() {
        return getAnimatedStringAttribute(null, SVG_CLASS_ATTRIBUTE);
    }

    /**
     * To manage a presentation attribute value.
     */
    public class PresentationAttributeValue
        extends CSSOMValue
        implements LiveAttributeValue,
                   CSSOMValue.ValueProvider {

        /**
         * The CSS engine.
         */
        protected CSSEngine cssEngine;

        /**
         * The property name.
         */
        protected String property;

        /**
         * The value.
         */
        protected Value value;

        /**
         * Whether the mutation comes from this object.
         */
        protected boolean mutate;

        /**
         * Creates a new PresentationAttributeValue.
         */
        public PresentationAttributeValue(CSSEngine eng, String prop) {
            super(null);
            valueProvider = this;
            setModificationHandler(new AbstractModificationHandler() {
                    protected Value getValue() {
                        return PresentationAttributeValue.this.getValue();
                    }
                    public void textChanged(String text) throws DOMException {
                        value = cssEngine.parsePropertyValue
                            (SVGStylableElement.this, property, text);
                        mutate = true;
                        setAttributeNS(null, property, text);
                        mutate = false;
                    }
                });

            cssEngine = eng;
            property = prop;

            Attr attr = getAttributeNodeNS(null, prop);
            if (attr != null) {
                value = cssEngine.parsePropertyValue
                    (SVGStylableElement.this, prop, attr.getValue());
            }
        }

        // ValueProvider ///////////////////////////////

        /**
         * Returns the current value associated with this object.
         */
        public Value getValue() {
            if (value == null) {
                throw new DOMException(DOMException.INVALID_STATE_ERR, "");
            }
            return value;
        }

        // LiveAttributeValue //////////////////////////////////////

        /**
         * Called when an Attr node has been added.
         */
        public void attrAdded(Attr node, String newv) {
            if (!mutate) {
                value = cssEngine.parsePropertyValue
                    (SVGStylableElement.this, property, newv);
            }
        }

        /**
         * Called when an Attr node has been modified.
         */
        public void attrModified(Attr node, String oldv, String newv) {
            if (!mutate) {
                value = cssEngine.parsePropertyValue
                    (SVGStylableElement.this, property, newv);
            }
        }

        /**
         * Called when an Attr node has been removed.
         */
        public void attrRemoved(Attr node, String oldv) {
            if (!mutate) {
                value = null;
            }
        }
    }

    /**
     * To manage a presentation attribute SVGColor value.
     */
    public class PresentationAttributeColorValue
        extends CSSOMSVGColor
        implements LiveAttributeValue,
                   CSSOMSVGColor.ValueProvider {

        /**
         * The CSS engine.
         */
        protected CSSEngine cssEngine;

        /**
         * The property name.
         */
        protected String property;

        /**
         * The value.
         */
        protected Value value;

        /**
         * Whether the mutation comes from this object.
         */
        protected boolean mutate;

        /**
         * Creates a new PresentationAttributeColorValue.
         */
        public PresentationAttributeColorValue(CSSEngine eng, String prop) {
            super(null);
            valueProvider = this;
            setModificationHandler(new AbstractModificationHandler() {
                    protected Value getValue() {
                        return PresentationAttributeColorValue.this.getValue();
                    }
                    public void textChanged(String text) throws DOMException {
                        value = cssEngine.parsePropertyValue
                            (SVGStylableElement.this, property, text);
                        mutate = true;
                        setAttributeNS(null, property, text);
                        mutate = false;
                    }
                });

            cssEngine = eng;
            property = prop;

            Attr attr = getAttributeNodeNS(null, prop);
            if (attr != null) {
                value = cssEngine.parsePropertyValue
                    (SVGStylableElement.this, prop, attr.getValue());
            }
        }

        // ValueProvider ///////////////////////////////

        /**
         * Returns the current value associated with this object.
         */
        public Value getValue() {
            if (value == null) {
                throw new DOMException(DOMException.INVALID_STATE_ERR, "");
            }
            return value;
        }

        // LiveAttributeValue //////////////////////////////////////

        /**
         * Called when an Attr node has been added.
         */
        public void attrAdded(Attr node, String newv) {
            if (!mutate) {
                value = cssEngine.parsePropertyValue
                    (SVGStylableElement.this, property, newv);
            }
        }

        /**
         * Called when an Attr node has been modified.
         */
        public void attrModified(Attr node, String oldv, String newv) {
            if (!mutate) {
                value = cssEngine.parsePropertyValue
                    (SVGStylableElement.this, property, newv);
            }
        }

        /**
         * Called when an Attr node has been removed.
         */
        public void attrRemoved(Attr node, String oldv) {
            if (!mutate) {
                value = null;
            }
        }
    }

    /**
     * To manage a presentation attribute SVGPaint value.
     */
    public class PresentationAttributePaintValue
        extends CSSOMSVGPaint
        implements LiveAttributeValue,
                   CSSOMSVGPaint.ValueProvider {

        /**
         * The CSS engine.
         */
        protected CSSEngine cssEngine;

        /**
         * The property name.
         */
        protected String property;

        /**
         * The value.
         */
        protected Value value;

        /**
         * Whether the mutation comes from this object.
         */
        protected boolean mutate;

        /**
         * Creates a new PresentationAttributeColorValue.
         */
        public PresentationAttributePaintValue(CSSEngine eng, String prop) {
            super(null);
            valueProvider = this;
            setModificationHandler(new AbstractModificationHandler() {
                    protected Value getValue() {
                        return PresentationAttributePaintValue.this.getValue();
                    }
                    public void textChanged(String text) throws DOMException {
                        value = cssEngine.parsePropertyValue
                            (SVGStylableElement.this, property, text);
                        mutate = true;
                        setAttributeNS(null, property, text);
                        mutate = false;
                    }
                });


            cssEngine = eng;
            property = prop;

            Attr attr = getAttributeNodeNS(null, prop);
            if (attr != null) {
                value = cssEngine.parsePropertyValue
                    (SVGStylableElement.this, prop, attr.getValue());
            }
        }

        // ValueProvider ///////////////////////////////

        /**
         * Returns the current value associated with this object.
         */
        public Value getValue() {
            if (value == null) {
                throw new DOMException(DOMException.INVALID_STATE_ERR, "");
            }
            return value;
        }

        // LiveAttributeValue //////////////////////////////////////

        /**
         * Called when an Attr node has been added.
         */
        public void attrAdded(Attr node, String newv) {
            if (!mutate) {
                value = cssEngine.parsePropertyValue
                    (SVGStylableElement.this, property, newv);
            }
        }

        /**
         * Called when an Attr node has been modified.
         */
        public void attrModified(Attr node, String oldv, String newv) {
            if (!mutate) {
                value = cssEngine.parsePropertyValue
                    (SVGStylableElement.this, property, newv);
            }
        }

        /**
         * Called when an Attr node has been removed.
         */
        public void attrRemoved(Attr node, String oldv) {
            if (!mutate) {
                value = null;
            }
        }
    }

    /**
     * This class represents the 'style' attribute.
     */
    public class StyleDeclaration
        extends CSSOMSVGStyleDeclaration
        implements LiveAttributeValue,
                   CSSOMSVGStyleDeclaration.ValueProvider,
                   CSSOMSVGStyleDeclaration.ModificationHandler,
                   CSSEngine.MainPropertyReceiver {
        
        /**
         * The associated CSS object.
         */
        protected org.apache.flex.forks.batik.css.engine.StyleDeclaration declaration;

        /**
         * Whether the mutation comes from this object.
         */
        protected boolean mutate;

        /**
         * Creates a new StyleDeclaration.
         */
        public StyleDeclaration(CSSEngine eng) {
            super(null, null, eng);
            valueProvider = this;
            setModificationHandler(this);

            declaration = cssEngine.parseStyleDeclaration
                (SVGStylableElement.this,
                 getAttributeNS(null, SVG_STYLE_ATTRIBUTE));
        }

        // ValueProvider ////////////////////////////////////////

        /**
         * Returns the current value associated with this object.
         */
        public Value getValue(String name) {
            int idx = cssEngine.getPropertyIndex(name);
            for (int i = 0; i < declaration.size(); i++) {
                if (idx == declaration.getIndex(i)) {
                    return declaration.getValue(i);
                }
            }
            return null;
        }

        /**
         * Tells whether the given property is important.
         */
        public boolean isImportant(String name) {
            int idx = cssEngine.getPropertyIndex(name);
            for (int i = 0; i < declaration.size(); i++) {
                if (idx == declaration.getIndex(i)) {
                    return declaration.getPriority(i);
                }
            }
            return false;
        }

        /**
         * Returns the text of the declaration.
         */
        public String getText() {
            return declaration.toString(cssEngine);
        }

        /**
         * Returns the length of the declaration.
         */
        public int getLength() {
            return declaration.size();
        }

        /**
         * Returns the value at the given.
         */
        public String item(int idx) {
            return cssEngine.getPropertyName(declaration.getIndex(idx));
        }

        // LiveAttributeValue //////////////////////////////////////

        /**
         * Called when an Attr node has been added.
         */
        public void attrAdded(Attr node, String newv) {
            if (!mutate) {
                declaration = cssEngine.parseStyleDeclaration
                    (SVGStylableElement.this, newv);
            }
        }

        /**
         * Called when an Attr node has been modified.
         */
        public void attrModified(Attr node, String oldv, String newv) {
            if (!mutate) {
                declaration = cssEngine.parseStyleDeclaration
                    (SVGStylableElement.this, newv);
            }
        }

        /**
         * Called when an Attr node has been removed.
         */
        public void attrRemoved(Attr node, String oldv) {
            if (!mutate) {
                declaration =
                    new org.apache.flex.forks.batik.css.engine.StyleDeclaration();
            }
        }

        // ModificationHandler ////////////////////////////////////

        /**
         * Called when the value text has changed.
         */
        public void textChanged(String text) throws DOMException {
            declaration = cssEngine.parseStyleDeclaration
                (SVGStylableElement.this, text);
            mutate = true;
            setAttributeNS(null, SVG_STYLE_ATTRIBUTE, text);
            mutate = false;
        }

        /**
         * Called when a property was removed.
         */
        public void propertyRemoved(String name) throws DOMException {
            int idx = cssEngine.getPropertyIndex(name);
            for (int i = 0; i < declaration.size(); i++) {
                if (idx == declaration.getIndex(i)) {
                    declaration.remove(i);
                    mutate = true;
                    setAttributeNS(null, SVG_STYLE_ATTRIBUTE,
                                   declaration.toString(cssEngine));
                    mutate = false;
                    return;
                }
            }
        }

        public void setMainProperty(String name, Value v, boolean important) {
            int idx = cssEngine.getPropertyIndex(name);
            if (idx == -1) 
                return;   // unknown property

            int i=0;
            for (; i < declaration.size(); i++) {
                if (idx == declaration.getIndex(i))
                    break;
            }
            if (i < declaration.size()) 
                declaration.put(i, v, idx, important);
            else
                declaration.append(v, idx, important);
        }

        /**
         * Called when a property was changed.
         */
        public void propertyChanged(String name, String value, String prio)
            throws DOMException {
            boolean important = ((prio != null) && (prio.length() >0));
            cssEngine.setMainProperties(SVGStylableElement.this,
                                        this, name, value, important);
            mutate = true;
            setAttributeNS(null, SVG_STYLE_ATTRIBUTE,
                           declaration.toString(cssEngine));
            mutate = false;
        }
    }
}
