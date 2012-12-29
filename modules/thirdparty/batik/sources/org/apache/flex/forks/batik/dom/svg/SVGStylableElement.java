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

import org.apache.flex.forks.batik.dom.anim.AnimationTargetListener;
import org.apache.flex.forks.batik.anim.values.AnimatableValue;
import org.apache.flex.forks.batik.css.dom.CSSOMSVGColor;
import org.apache.flex.forks.batik.css.dom.CSSOMSVGPaint;
import org.apache.flex.forks.batik.css.dom.CSSOMStoredStyleDeclaration;
import org.apache.flex.forks.batik.css.dom.CSSOMValue;
import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.CSSStylableElement;
import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.css.engine.StyleDeclarationProvider;
import org.apache.flex.forks.batik.css.engine.StyleMap;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.svg.SVGColorManager;
import org.apache.flex.forks.batik.css.engine.value.svg.SVGPaintManager;
import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.util.DoublyIndexedTable;
import org.apache.flex.forks.batik.util.ParsedURL;
import org.apache.flex.forks.batik.util.SVGTypes;

import org.w3c.dom.Attr;
import org.w3c.dom.DOMException;
import org.w3c.dom.Node;
import org.w3c.dom.css.CSSStyleDeclaration;
import org.w3c.dom.css.CSSValue;
import org.w3c.dom.svg.SVGAnimatedString;

/**
 * This class provides a common superclass for elements which implement
 * SVGStylable.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGStylableElement.java 592621 2007-11-07 05:58:12Z cam $
 */
public abstract class SVGStylableElement
    extends SVGOMElement
    implements CSSStylableElement {

    /**
     * Table mapping XML attribute names to TraitInformation objects.
     */
    protected static DoublyIndexedTable xmlTraitInformation;
    static {
        DoublyIndexedTable t =
            new DoublyIndexedTable(SVGOMElement.xmlTraitInformation);
        t.put(null, SVG_CLASS_ATTRIBUTE,
                new TraitInformation(true, SVGTypes.TYPE_CDATA));
        xmlTraitInformation = t;
    }

    /**
     * The computed style map.
     */
    protected StyleMap computedStyleMap;

    /**
     * The override style declaration for this element.
     */
    protected OverrideStyleDeclaration overrideStyleDeclaration;

    /**
     * The 'class' attribute value.
     */
    protected SVGOMAnimatedString className;

    /**
     * The 'style' attribute value.
     */
    protected StyleDeclaration style;

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
        initializeLiveAttributes();
    }

    /**
     * Initializes all live attributes for this element.
     */
    protected void initializeAllLiveAttributes() {
        super.initializeAllLiveAttributes();
        initializeLiveAttributes();
    }

    /**
     * Initializes the live attribute values of this element.
     */
    private void initializeLiveAttributes() {
        className = createLiveAnimatedString(null, SVG_CLASS_ATTRIBUTE);
    }

    /**
     * Returns the override style declaration for this element.
     */
    public CSSStyleDeclaration getOverrideStyle() {
        if (overrideStyleDeclaration == null) {
            CSSEngine eng = ((SVGOMDocument) getOwnerDocument()).getCSSEngine();
            overrideStyleDeclaration = new OverrideStyleDeclaration(eng);
        }
        return overrideStyleDeclaration;
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
     * @throws IllegalArgumentException when the result of getBaseURI()
     *         cannot be used as an URL.
     */
    public ParsedURL getCSSBase() {
        if (getXblBoundElement() != null) {
            return null;
        }
        String bu = getBaseURI();
        return bu == null ? null : new ParsedURL(bu);
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

    /**
     * Returns the object that gives access to the underlying
     * {@link org.apache.flex.forks.batik.css.engine.StyleDeclaration} for the override
     * style of this element.
     */
    public StyleDeclarationProvider getOverrideStyleDeclarationProvider() {
        return (StyleDeclarationProvider) getOverrideStyle();
    }

    // AnimationTarget ///////////////////////////////////////////////////////

    /**
     * Updates a property value in this target.
     */
    public void updatePropertyValue(String pn, AnimatableValue val) {
        CSSStyleDeclaration over = getOverrideStyle();
        if (val == null) {
            over.removeProperty(pn);
        } else {
            over.setProperty(pn, val.getCssText(), "");
        }
    }

    /**
     * Returns whether color interpolations should be done in linear RGB
     * color space rather than sRGB.
     */
    public boolean useLinearRGBColorInterpolation() {
        CSSEngine eng = ((SVGOMDocument) getOwnerDocument()).getCSSEngine();
        Value v = eng.getComputedStyle(this, null,
                                       SVGCSSEngine.COLOR_INTERPOLATION_INDEX);
        return v.getStringValue().charAt(0) == 'l';
    }

    /**
     * Adds a listener for changes to the given attribute value.
     */
    public void addTargetListener(String ns, String an, boolean isCSS,
                                  AnimationTargetListener l) {
        if (isCSS && svgContext != null) {
            ((SVGAnimationTargetContext) svgContext).addTargetListener(an, l);
        } else {
            super.addTargetListener(ns, an, isCSS, l);
        }
    }

    /**
     * Removes a listener for changes to the given attribute value.
     */
    public void removeTargetListener(String ns, String an, boolean isCSS,
                                     AnimationTargetListener l) {
        if (isCSS) {
            ((SVGAnimationTargetContext)svgContext).removeTargetListener(an, l);
        } else {
            super.removeTargetListener(ns, an, isCSS, l);
        }
    }

    // SVGStylable support ///////////////////////////////////////////////////

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.svg.SVGStylable#getStyle()}.
     */
    public CSSStyleDeclaration getStyle() {
        if (style == null) {
            CSSEngine eng = ((SVGOMDocument)getOwnerDocument()).getCSSEngine();
            style = new StyleDeclaration(eng);
            putLiveAttributeValue(null, SVG_STYLE_ATTRIBUTE, style);
        }
        return style;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGStylable#getPresentationAttribute(String)}.
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
        if (getAttributeNS(null, name).length() == 0) {
            return null;
        }
        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * org.w3c.dom.svg.SVGStylable#getClassName()}.
     */
    public SVGAnimatedString getClassName() {
        return className;
    }

    /**
     * Returns the table of TraitInformation objects for this element.
     */
    protected DoublyIndexedTable getTraitInformationTable() {
        return xmlTraitInformation;
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
        extends CSSOMStoredStyleDeclaration
        implements LiveAttributeValue,
                   CSSEngine.MainPropertyReceiver {

        /**
         * Whether the mutation comes from this object.
         */
        protected boolean mutate;

        /**
         * Creates a new StyleDeclaration.
         */
        public StyleDeclaration(CSSEngine eng) {
            super(eng);

            declaration = cssEngine.parseStyleDeclaration
                (SVGStylableElement.this,
                 getAttributeNS(null, SVG_STYLE_ATTRIBUTE));
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

        /**
         * Called when a property was changed.
         */
        public void propertyChanged(String name, String value, String prio)
            throws DOMException {
            boolean important = prio != null && prio.length() > 0;
            cssEngine.setMainProperties(SVGStylableElement.this,
                                        this, name, value, important);
            mutate = true;
            setAttributeNS(null, SVG_STYLE_ATTRIBUTE,
                           declaration.toString(cssEngine));
            mutate = false;
        }

        // MainPropertyReceiver //////////////////////////////////////////////

        /**
         * Sets a main property value in response to a shorthand property
         * being set.
         */
        public void setMainProperty(String name, Value v, boolean important) {
            int idx = cssEngine.getPropertyIndex(name);
            if (idx == -1)
                return;   // unknown property

            int i;
            for (i = 0; i < declaration.size(); i++) {
                if (idx == declaration.getIndex(i))
                    break;
            }
            if (i < declaration.size())
                declaration.put(i, v, idx, important);
            else
                declaration.append(v, idx, important);
        }
    }

    /**
     * This class is a CSSStyleDeclaration for the override style of
     * the element.
     */
    protected class OverrideStyleDeclaration
        extends CSSOMStoredStyleDeclaration {

        /**
         * Creates a new OverrideStyleDeclaration.
         */
        protected OverrideStyleDeclaration(CSSEngine eng) {
            super(eng);
            declaration = new org.apache.flex.forks.batik.css.engine.StyleDeclaration();
        }

        // ModificationHandler ///////////////////////////////////////////////

        /**
         * Called when the value text has changed.
         */
        public void textChanged(String text) throws DOMException {
            ((SVGOMDocument) ownerDocument).overrideStyleTextChanged
                (SVGStylableElement.this, text);
        }

        /**
         * Called when a property was removed.
         */
        public void propertyRemoved(String name) throws DOMException {
            ((SVGOMDocument) ownerDocument).overrideStylePropertyRemoved
                (SVGStylableElement.this, name);
        }

        /**
         * Called when a property was changed.
         */
        public void propertyChanged(String name, String value, String prio)
                throws DOMException {
            ((SVGOMDocument) ownerDocument).overrideStylePropertyChanged
                (SVGStylableElement.this, name, value, prio);
        }
    }
}
