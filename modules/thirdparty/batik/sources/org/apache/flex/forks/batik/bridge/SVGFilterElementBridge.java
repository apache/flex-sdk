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
package org.apache.flex.forks.batik.bridge;

import java.awt.geom.Rectangle2D;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.dom.util.XLinkSupport;
import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.ext.awt.image.renderable.FilterChainRable;
import org.apache.flex.forks.batik.ext.awt.image.renderable.FilterChainRable8Bit;
import org.apache.flex.forks.batik.ext.awt.image.renderable.PadRable8Bit;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * Bridge class for the &lt;filter> element.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGFilterElementBridge.java,v 1.20 2004/11/18 01:46:53 deweese Exp $
 */
public class SVGFilterElementBridge extends AbstractSVGBridge
    implements FilterBridge, ErrorConstants {

    /**
     * Constructs a new bridge for the &lt;filter> element.
     */
    public SVGFilterElementBridge() {}

    /**
     * Returns 'filter'.
     */
    public String getLocalName() {
        return SVG_FILTER_TAG;
    }

    /**
     * Creates a <tt>Filter</tt> according to the specified parameters.
     *
     * @param ctx the bridge context to use
     * @param filterElement the element that defines the filter
     * @param filteredElement the element that references the filter element
     * @param filteredNode the graphics node to filter
     */
    public Filter createFilter(BridgeContext ctx,
                               Element filterElement,
                               Element filteredElement,
                               GraphicsNode filteredNode) {

        // get filter chain region
        Rectangle2D filterRegion = SVGUtilities.convertFilterChainRegion
            (filterElement, filteredElement, filteredNode, ctx);

        // make the initial source as a RenderableImage
        Filter sourceGraphic = filteredNode.getGraphicsNodeRable(true);
        // Pad out to filterRegion
        sourceGraphic = new PadRable8Bit(sourceGraphic, filterRegion, 
                                         PadMode.ZERO_PAD);

        // build a FilterChainRable8Bit
        FilterChainRable filterChain
            = new FilterChainRable8Bit(sourceGraphic, filterRegion);

        // 'filterRes' attribute - default is implementation specific
        float [] filterRes = SVGUtilities.convertFilterRes(filterElement, ctx);
        filterChain.setFilterResolutionX((int)filterRes[0]);
        filterChain.setFilterResolutionY((int)filterRes[1]);

        // Create a map for filter nodes to advertise themselves as
        // named source
        Map filterNodeMap = new HashMap(11);
        filterNodeMap.put(SVG_SOURCE_GRAPHIC_VALUE, sourceGraphic);


        Filter in = buildFilterPrimitives(filterElement,
                                          filterRegion,
                                          filteredElement,
                                          filteredNode,
                                          sourceGraphic,
                                          filterNodeMap,
                                          ctx);
        if ((in == null) || (in == sourceGraphic)) {
            return null; // no filter primitives found, disable the filter.
        } else {
            filterChain.setSource(in);
            return filterChain;
        }
    }

    /**
     * Builds the filter primitives of filter chain of the specified
     * filter element and returns the last filter primitive
     * created. Filter primitives can be children of the filter or
     * defined on one of its 'ancestor' (linked with the xlink:href
     * attribute).
     *
     * @param filterElement the filter element
     * @param filterRegion the filter chain region
     * @param filteredElement the filtered element
     * @param filteredNode the filtered node
     * @param in the input Filter
     * @param filterNodeMap the map used by named filter primitives
     * @param ctx the bridge context
     * @return the last filter primitive created
     */
    protected static Filter buildFilterPrimitives(Element filterElement,
                                                  Rectangle2D filterRegion,
                                                  Element filteredElement,
                                                  GraphicsNode filteredNode,
                                                  Filter in,
                                                  Map filterNodeMap,
                                                  BridgeContext ctx) {

        List refs = new LinkedList();
        for (;;) {
            Filter newIn = buildLocalFilterPrimitives(filterElement,
                                                      filterRegion,
                                                      filteredElement,
                                                      filteredNode,
                                                      in,
                                                      filterNodeMap,
                                                      ctx);
            if (newIn != in) {
                return newIn; // filter primitives found, exit
            }
            String uri = XLinkSupport.getXLinkHref(filterElement);
            if (uri.length() == 0) {
                return in; // no xlink:href found, exit
            }
            // check if there is circular dependencies
            SVGOMDocument doc = (SVGOMDocument)filterElement.getOwnerDocument();
            URL url;
            try {
                url = new URL(doc.getURLObject(), uri);
            } catch (MalformedURLException ex) {
                throw new BridgeException(filterElement,
                                          ERR_URI_MALFORMED,
                                          new Object[] {uri});

            }
            if (contains(refs, url)) {
                throw new BridgeException(filterElement,
                                          ERR_XLINK_HREF_CIRCULAR_DEPENDENCIES,
                                          new Object[] {uri});
            }
            refs.add(url);
            filterElement = ctx.getReferencedElement(filterElement, uri);
        }
    }

    /**
     * Builds the filter primitives of filter chain of the specified
     * filter element and returns the last filter primitive
     * created or 'in' if no filter primitive has been specified.
     *
     * @param filterElement the filter element
     * @param filterRegion the filter chain region
     * @param filteredElement the filtered element
     * @param filteredNode the filtered node
     * @param in the input Filter
     * @param filterNodeMap the map used by named filter primitives
     * @param ctx the bridge context
     * @return the last filter primitive created or 'in'
     */
    protected static
        Filter buildLocalFilterPrimitives(Element filterElement,
                                          Rectangle2D filterRegion,
                                          Element filteredElement,
                                          GraphicsNode filteredNode,
                                          Filter in,
                                          Map filterNodeMap,
                                          BridgeContext ctx) {

        for (Node n = filterElement.getFirstChild();
             n != null;
             n = n.getNextSibling()) {

            if (n.getNodeType() != Node.ELEMENT_NODE) {
                continue; // skip node that is not an Element
            }
            Element e = (Element)n;
            Bridge bridge = ctx.getBridge(e);
            if (bridge == null || !(bridge instanceof FilterPrimitiveBridge)) {
                continue;
            }
            FilterPrimitiveBridge filterBridge = (FilterPrimitiveBridge)bridge;
            Filter filterNode = filterBridge.createFilter(ctx,
                                                          e,
                                                          filteredElement,
                                                          filteredNode,
                                                          in,
                                                          filterRegion,
                                                          filterNodeMap);
            if (filterNode == null) {
                return null; // disable the filter if a primitive is null
            } else {
                in = filterNode;
            }
        }
        return in;
    }

    /**
     * Returns true if the specified list of URLs contains the specified url.
     *
     * @param urls the list of URLs
     * @param key the url to search for
     */
    private static boolean contains(List urls, URL key) {
        Iterator iter = urls.iterator();
        while (iter.hasNext()) {
            URL url = (URL)iter.next();
            if (url.sameFile(key) && url.getRef().equals(key.getRef())) {
                return true;
            }
        }
        return false;
    }
}
