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
package org.apache.flex.forks.batik.extension.svg;

import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.DomExtension;
import org.apache.flex.forks.batik.dom.ExtensibleDOMImplementation;
import org.apache.flex.forks.batik.dom.svg.SVGDOMImplementation;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 * This is a Service interface for classes that want to extend the
 * functionality of the Dom, to support new tags in the rendering tree.
 *
 * @author <a href="mailto:thomas.deweese@kodak.com">Thomas DeWeese</a>
 * @version $Id: BatikDomExtension.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public class BatikDomExtension
    implements DomExtension, BatikExtConstants {

    /**
     * Return the priority of this Extension.  Extensions are
     * registered from lowest to highest priority.  So if for some
     * reason you need to come before/after another existing extension
     * make sure your priority is lower/higher than theirs.
     */
    public float getPriority() { return 1.0f; }

    /**
     * This should return the individual or company name responsible
     * for the this implementation of the extension.
     */
    public String getAuthor() {
        return "Thomas DeWeese";
    }

    /**
     * This should contain a contact address (usually an e-mail address).
     */
    public String getContactAddress() {
        return "deweese@apache.org";
    }

    /**
     * This should return a URL where information can be obtained on
     * this extension.
     */
    public String getURL() {
        return "http://xml.apache.org/batik";
    }

    /**
     * Human readable description of the extension.
     * Perhaps that should be a resource for internationalization?
     * (although I suppose it could be done internally)
     */
    public String getDescription() {
        return "Example extension to standard SVG shape tags";
    }

    /**
     * This method should update the DomContext with support
     * for the tags in this extension.  In some rare cases it may
     * be necessary to replace existing tag handlers, although this
     * is discouraged.
     *
     * @param di The ExtensibleDOMImplementation to register the
     *           extension elements with.
     */
    public void registerTags(ExtensibleDOMImplementation di) {
        di.registerCustomElementFactory
            (BATIK_EXT_NAMESPACE_URI,
             BATIK_EXT_REGULAR_POLYGON_TAG,
             new BatikRegularPolygonElementFactory());

        di.registerCustomElementFactory
            (BATIK_EXT_NAMESPACE_URI,
             BATIK_EXT_STAR_TAG,
             new BatikStarElementFactory());

        di.registerCustomElementFactory
            (BATIK_EXT_NAMESPACE_URI,
             BATIK_EXT_HISTOGRAM_NORMALIZATION_TAG,
             new BatikHistogramNormalizationElementFactory());

        di.registerCustomElementFactory
            (BATIK_EXT_NAMESPACE_URI,
             BATIK_EXT_COLOR_SWITCH_TAG,
             new ColorSwitchElementFactory());

        di.registerCustomElementFactory
            (BATIK_12_NAMESPACE_URI,
             BATIK_EXT_FLOW_TEXT_TAG,
             new FlowTextElementFactory());

        di.registerCustomElementFactory
            (BATIK_12_NAMESPACE_URI,
             BATIK_EXT_FLOW_DIV_TAG,
             new FlowDivElementFactory());

        di.registerCustomElementFactory
            (BATIK_12_NAMESPACE_URI,
             BATIK_EXT_FLOW_PARA_TAG,
             new FlowParaElementFactory());

        di.registerCustomElementFactory
            (BATIK_12_NAMESPACE_URI,
             BATIK_EXT_FLOW_REGION_BREAK_TAG,
             new FlowRegionBreakElementFactory());

        di.registerCustomElementFactory
            (BATIK_12_NAMESPACE_URI,
             BATIK_EXT_FLOW_REGION_TAG,
             new FlowRegionElementFactory());

        di.registerCustomElementFactory
            (BATIK_12_NAMESPACE_URI,
             BATIK_EXT_FLOW_LINE_TAG,
             new FlowLineElementFactory());

        di.registerCustomElementFactory
            (BATIK_12_NAMESPACE_URI,
             BATIK_EXT_FLOW_SPAN_TAG,
             new FlowSpanElementFactory());
    }

    /**
     * To create a 'regularPolygon' element.
     */
    protected static class BatikRegularPolygonElementFactory
        implements ExtensibleDOMImplementation.ElementFactory {
        public BatikRegularPolygonElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new BatikRegularPolygonElement
                (prefix, (AbstractDocument)doc);
        }
    }


    /**
     * To create a 'star' element.
     */
    protected static class BatikStarElementFactory
        implements ExtensibleDOMImplementation.ElementFactory {
        public BatikStarElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new BatikStarElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'histogramNormalization' element.
     */
    protected static class BatikHistogramNormalizationElementFactory
        implements ExtensibleDOMImplementation.ElementFactory {
        public BatikHistogramNormalizationElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new BatikHistogramNormalizationElement
                (prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'colorSwitch' element.
     */
    protected static class ColorSwitchElementFactory
        implements ExtensibleDOMImplementation.ElementFactory {
        public ColorSwitchElementFactory() {
        }
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new ColorSwitchElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'flowText' element.
     */
    protected static class FlowTextElementFactory
        implements SVGDOMImplementation.ElementFactory {
        public FlowTextElementFactory() {
        }
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new FlowTextElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'flowDiv' element.
     */
    protected static class FlowDivElementFactory
        implements SVGDOMImplementation.ElementFactory {
        public FlowDivElementFactory() {
        }
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new FlowDivElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'flowPara' element.
     */
    protected static class FlowParaElementFactory
        implements SVGDOMImplementation.ElementFactory {
        public FlowParaElementFactory() {
        }
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new FlowParaElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'flowRegionBreak' element.
     */
    protected static class FlowRegionBreakElementFactory
        implements SVGDOMImplementation.ElementFactory {
        public FlowRegionBreakElementFactory() {
        }
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new FlowRegionBreakElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'flowRegion' element.
     */
    protected static class FlowRegionElementFactory
        implements SVGDOMImplementation.ElementFactory {
        public FlowRegionElementFactory() {
        }
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new FlowRegionElement(prefix, (AbstractDocument)doc);
        }
     }

    /**
     * To create a 'flowLine' element.
     */
    protected static class FlowLineElementFactory
        implements SVGDOMImplementation.ElementFactory {
        public FlowLineElementFactory() {
        }
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new FlowLineElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'flowSpan' element.
     */
    protected static class FlowSpanElementFactory
        implements SVGDOMImplementation.ElementFactory {
        public FlowSpanElementFactory() {
        }
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new FlowSpanElement(prefix, (AbstractDocument)doc);
        }
    }
}


