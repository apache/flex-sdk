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
package org.apache.flex.forks.batik.dom.svg12;

import java.net.URL;

import org.apache.flex.forks.batik.css.engine.CSSContext;
import org.apache.flex.forks.batik.css.engine.CSSEngine;
import org.apache.flex.forks.batik.css.engine.SVG12CSSEngine;
import org.apache.flex.forks.batik.css.engine.value.ShorthandManager;
import org.apache.flex.forks.batik.css.engine.value.ValueManager;
import org.apache.flex.forks.batik.css.parser.ExtendedParser;
import org.apache.flex.forks.batik.dom.AbstractDocument;
import org.apache.flex.forks.batik.dom.AbstractStylableDocument;
import org.apache.flex.forks.batik.dom.GenericElement;
import org.apache.flex.forks.batik.dom.GenericElementNS;
import org.apache.flex.forks.batik.dom.svg.SVGDOMImplementation;
import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.dom.util.HashTable;
import org.apache.flex.forks.batik.dom.util.DOMUtilities;
import org.apache.flex.forks.batik.util.SVG12Constants;


import org.w3c.flex.forks.css.sac.InputSource;
import org.w3c.dom.Document;
import org.w3c.dom.DocumentType;
import org.w3c.dom.DOMImplementation;
import org.w3c.dom.DOMException;
import org.w3c.dom.Element;

/**
 * This class implements the {@link DOMImplementation} interface.
 * It provides support the SVG 1.2 documents.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVG12DOMImplementation.java,v 1.3 2005/02/22 09:13:02 cam Exp $
 */
public class SVG12DOMImplementation
    extends    SVGDOMImplementation {
    
    /**
     * Creates a new SVGDOMImplementation object.
     */
    public SVG12DOMImplementation() {
        factories = svg12Factories;
        registerFeature("CSS",            "2.0");
        registerFeature("StyleSheets",    "2.0");
        registerFeature("SVG",            new String[] {"1.0", "1.1", "1.2"});
        registerFeature("SVGEvents",      new String[] {"1.0", "1.1", "1.2"});
    }

    public CSSEngine createCSSEngine(AbstractStylableDocument doc, 
                                     CSSContext               ctx,
                                     ExtendedParser      ep,
                                     ValueManager     [] vms, 
                                     ShorthandManager [] sms) {
        URL durl = ((SVGOMDocument)doc).getURLObject();
        CSSEngine result = new SVG12CSSEngine(doc, durl, ep, vms, sms, ctx);

        URL url = getClass().getResource("resources/UserAgentStyleSheet.css");
        if (url != null) {
            InputSource is = new InputSource(url.toString());
            result.setUserAgentStyleSheet
                (result.parseStyleSheet(is, url, "all"));
        }

        return result;
    }

    /**
     * <b>DOM</b>: Implements {@link
     * DOMImplementation#createDocument(String,String,DocumentType)}.
     */
    public Document createDocument(String namespaceURI,
                                   String qualifiedName,
                                   DocumentType doctype)
        throws DOMException {
        Document result = new SVGOMDocument(doctype, this);
        // BUG 32108: return empty document if qualifiedName is null.
        if (qualifiedName != null)
            result.appendChild(result.createElementNS(namespaceURI,
                                                      qualifiedName));
        return result;
    }

    /**
     * Implements the behavior of Document.createElementNS() for this
     * DOM implementation.
     */
    public Element createElementNS(AbstractDocument document,
                                   String           namespaceURI,
                                   String           qualifiedName) {
        if (namespaceURI == null) 
            return new GenericElement(qualifiedName.intern(), document);

        if (SVG12Constants.SVG_NAMESPACE_URI.equals(namespaceURI)) {
            String name = DOMUtilities.getLocalName(qualifiedName);
            ElementFactory ef = (ElementFactory)factories.get(name);
            if (ef != null)
                return ef.create(DOMUtilities.getPrefix(qualifiedName),
                                 document);
        }
        return new GenericElementNS(namespaceURI.intern(),
                                    qualifiedName.intern(),
                                    document);
    }

    // The element factories /////////////////////////////////////////////////

    /**
     * The SVG element factories.
     */
    protected static HashTable svg12Factories = new HashTable(svg11Factories);

    static {
        svg12Factories.put(SVG12Constants.SVG_FLOW_DIV_TAG,
                           new FlowDivElementFactory());

        svg12Factories.put(SVG12Constants.SVG_FLOW_LINE_TAG,
                           new FlowLineElementFactory());

        svg12Factories.put(SVG12Constants.SVG_FLOW_PARA_TAG,
                           new FlowParaElementFactory());

        svg12Factories.put(SVG12Constants.SVG_FLOW_REGION_BREAK_TAG,
                           new FlowRegionBreakElementFactory());

        svg12Factories.put(SVG12Constants.SVG_FLOW_REGION_TAG,
                           new FlowRegionElementFactory());

        svg12Factories.put(SVG12Constants.SVG_FLOW_REGION_EXCLUDE_TAG,
                           new FlowRegionExcludeElementFactory());

        svg12Factories.put(SVG12Constants.SVG_FLOW_ROOT_TAG,
                           new FlowRootElementFactory());

        svg12Factories.put(SVG12Constants.SVG_FLOW_SPAN_TAG,
                           new FlowSpanElementFactory());

        svg12Factories.put(SVG12Constants.SVG_MULTI_IMAGE_TAG,
                           new MultiImageElementFactory());

        svg12Factories.put(SVG12Constants.SVG_SOLID_COLOR_TAG,
                           new SolidColorElementFactory());

        svg12Factories.put(SVG12Constants.SVG_SUB_IMAGE_TAG,
                           new SubImageElementFactory());

        svg12Factories.put(SVG12Constants.SVG_SUB_IMAGE_REF_TAG,
                           new SubImageRefElementFactory());

    }

    /**
     * To create a 'flowDiv' element.
     */
    protected static class FlowDivElementFactory 
        implements ElementFactory {
        public FlowDivElementFactory() {
        }
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFlowDivElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'flowLine' element.
     */
    protected static class FlowLineElementFactory 
        implements ElementFactory {
        public FlowLineElementFactory() {
        }
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFlowLineElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'flowPara' element.
     */
    protected static class FlowParaElementFactory 
        implements ElementFactory {
        public FlowParaElementFactory() {
        }
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFlowParaElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'flowRegionBreak' element.
     */
    protected static class FlowRegionBreakElementFactory 
        implements ElementFactory {
        public FlowRegionBreakElementFactory() {
        }
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFlowRegionBreakElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'flowRegion' element.
     */
    protected static class FlowRegionElementFactory 
        implements ElementFactory {
        public FlowRegionElementFactory() {
        }
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFlowRegionElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'flowRegion' element.
     */
    protected static class FlowRegionExcludeElementFactory 
        implements ElementFactory {
        public FlowRegionExcludeElementFactory() {
        }
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFlowRegionExcludeElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'flowRoot' element.
     */
    protected static class FlowRootElementFactory 
        implements ElementFactory {
        public FlowRootElementFactory() {
        }
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFlowRootElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'flowSpan' element.
     */
    protected static class FlowSpanElementFactory 
        implements ElementFactory {
        public FlowSpanElementFactory() {
        }
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMFlowSpanElement(prefix, (AbstractDocument)doc);
        }
    }
    /**
     * To create a 'multiImage' element.
     */
    protected static class MultiImageElementFactory 
        implements ElementFactory {
        public MultiImageElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMMultiImageElement
                (prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'solidColor' element.
     */
    protected static class SolidColorElementFactory 
        implements ElementFactory {
        public SolidColorElementFactory() {
        }
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMSolidColorElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'subImage' element.
     */
    protected static class SubImageElementFactory 
        implements ElementFactory {
        public SubImageElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMSubImageElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * To create a 'SubImageRef' element.
     */
    protected static class SubImageRefElementFactory 
        implements ElementFactory {
        public SubImageRefElementFactory() {}
        /**
         * Creates an instance of the associated element type.
         */
        public Element create(String prefix, Document doc) {
            return new SVGOMSubImageRefElement(prefix, (AbstractDocument)doc);
        }
    }

    /**
     * The default instance of this class.
     */
    protected final static DOMImplementation DOM_IMPLEMENTATION =
        new SVG12DOMImplementation();

    /**
     * Returns the default instance of this class.
     */
    public static DOMImplementation getDOMImplementation() {
        return DOM_IMPLEMENTATION;
    }
}
