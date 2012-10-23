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
package org.apache.flex.forks.batik.css.dom;

import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.SVGCSSEngine;
import org.apache.flex.forks.batik.css.engine.value.Value;
import org.apache.flex.forks.batik.css.engine.value.svg.SVGColorManager;
import org.apache.flex.forks.batik.css.engine.value.svg.SVGPaintManager;
import org.w3c.dom.DOMException;
import org.w3c.dom.css.CSSRule;
import org.w3c.dom.css.CSSValue;

/**
 * This class represents a SVG style declaration.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: CSSOMSVGStyleDeclaration.java 475477 2006-11-15 22:44:28Z cam $
 */
public class CSSOMSVGStyleDeclaration extends CSSOMStyleDeclaration {
    
    /**
     * The CSS engine.
     */
    protected CSSEngine cssEngine;

    /**
     * Creates a new CSSOMSVGStyleDeclaration.
     */
    public CSSOMSVGStyleDeclaration(ValueProvider vp,
                                    CSSRule parent,
                                    CSSEngine eng) {
        super(vp, parent);
        cssEngine = eng;
    }

    /**
     * Creates the CSS value associated with the given property.
     */
    protected CSSValue createCSSValue(String name) {
        int idx = cssEngine.getPropertyIndex(name);
        if (idx > SVGCSSEngine.FINAL_INDEX) {
            if (cssEngine.getValueManagers()[idx] instanceof SVGPaintManager) {
                return new StyleDeclarationPaintValue(name);
            }
            if (cssEngine.getValueManagers()[idx] instanceof SVGColorManager) {
                return new StyleDeclarationColorValue(name);
            }
        } else {
            switch (idx) {
            case SVGCSSEngine.FILL_INDEX:
            case SVGCSSEngine.STROKE_INDEX:
                return new StyleDeclarationPaintValue(name);

            case SVGCSSEngine.FLOOD_COLOR_INDEX:
            case SVGCSSEngine.LIGHTING_COLOR_INDEX:
            case SVGCSSEngine.STOP_COLOR_INDEX:
                return new StyleDeclarationColorValue(name);
            }
        }
        return super.createCSSValue(name);
    }

    /**
     * This class represents a CSS value returned by this declaration.
     */
    public class StyleDeclarationColorValue
        extends CSSOMSVGColor
        implements CSSOMSVGColor.ValueProvider {
        
        /**
         * The property name.
         */
        protected String property;

        /**
         * Creates a new StyleDeclarationColorValue.
         */
        public StyleDeclarationColorValue(String prop) {
            super(null);
            valueProvider = this;
            setModificationHandler(new AbstractModificationHandler() {
                    protected Value getValue() {
                        return StyleDeclarationColorValue.this.getValue();
                    }
                    public void textChanged(String text) throws DOMException {
                        if (handler == null) {
                            throw new DOMException
                                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
                        }
                        String prio = getPropertyPriority(property);
                        CSSOMSVGStyleDeclaration.this.
                            handler.propertyChanged(property, text, prio);
                    }
                });

            property = prop;
        }

        // ValueProvider ///////////////////////////////

        /**
         * Returns the current value associated with this object.
         */
        public Value getValue() {
            return CSSOMSVGStyleDeclaration.this.
                valueProvider.getValue(property);
        }

    }

    /**
     * This class represents a CSS value returned by this declaration.
     */
    public class StyleDeclarationPaintValue
        extends CSSOMSVGPaint
        implements CSSOMSVGPaint.ValueProvider {
        
        /**
         * The property name.
         */
        protected String property;

        /**
         * Creates a new StyleDeclarationPaintValue.
         */
        public StyleDeclarationPaintValue(String prop) {
            super(null);
            valueProvider = this;
            setModificationHandler(new AbstractModificationHandler() {
                    protected Value getValue() {
                        return StyleDeclarationPaintValue.this.getValue();
                    }
                    public void textChanged(String text) throws DOMException {
                        if (handler == null) {
                            throw new DOMException
                                (DOMException.NO_MODIFICATION_ALLOWED_ERR, "");
                        }
                        String prio = getPropertyPriority(property);
                        CSSOMSVGStyleDeclaration.this.
                            handler.propertyChanged(property, text, prio);
                    }
                });

            property = prop;
        }

        // ValueProvider ///////////////////////////////

        /**
         * Returns the current value associated with this object.
         */
        public Value getValue() {
            return CSSOMSVGStyleDeclaration.this.
                valueProvider.getValue(property);
        }

    }
}
