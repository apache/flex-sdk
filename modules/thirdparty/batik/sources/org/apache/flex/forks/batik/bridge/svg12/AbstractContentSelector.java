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
package org.apache.flex.forks.batik.bridge.svg12;

import java.util.HashMap;

import org.apache.flex.forks.batik.dom.svg12.XBLOMContentElement;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * A base class for handlers of different XBL content element includes
 * attribute syntaxes.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AbstractContentSelector.java 475477 2006-11-15 22:44:28Z cam $
 */
public abstract class AbstractContentSelector {

    /**
     * The ContentManager object that owns this selector.
     */
    protected ContentManager contentManager;

    /**
     * The XBL content element.
     */
    protected XBLOMContentElement contentElement;

    /**
     * The bound element.
     */
    protected Element boundElement;

    /**
     * Creates a new AbstractContentSelector object.
     */
    public AbstractContentSelector(ContentManager cm,
                                   XBLOMContentElement content,
                                   Element bound) {
        contentManager = cm;
        contentElement = content;
        boundElement = bound;
    }

    /**
     * Returns a list of nodes that were matched by this selector.
     */
    public abstract NodeList getSelectedContent();

    /**
     * Forces this selector to update its selected nodes list.
     * Returns true if the selected node list needed updating.
     * This assumes that the previous content elements in this
     * shadow tree (in document order) have up-to-date selectedContent
     * lists.
     */
    abstract boolean update();

    /**
     * Returns true if the given node has already been selected
     * by a content element.
     */
    protected boolean isSelected(Node n) {
        return contentManager.getContentElement(n) != null;
    }

    /**
     * Map of selector languages to factories.
     */
    protected static HashMap selectorFactories = new HashMap();
    static {
        ContentSelectorFactory f1 = new XPathPatternContentSelectorFactory();
        ContentSelectorFactory f2 = new XPathSubsetContentSelectorFactory();
        selectorFactories.put(null, f1);
        selectorFactories.put("XPathPattern", f1);
        selectorFactories.put("XPathSubset", f2);
    }

    /**
     * Creates a new selector object.
     * @param content The content element using this selector.
     * @param bound The bound element whose children will be selected.
     * @param selector The selector string.
     */
    public static AbstractContentSelector createSelector
            (String selectorLanguage,
             ContentManager cm,
             XBLOMContentElement content,
             Element bound,
             String selector) {

        ContentSelectorFactory f =
            (ContentSelectorFactory) selectorFactories.get(selectorLanguage);
        if (f == null) {
            throw new RuntimeException
                ("Invalid XBL content selector language '"
                 + selectorLanguage
                 + "'");
        }
        return f.createSelector(cm, content, bound, selector);
    }

    /**
     * An interface for content selector factories.
     */
    protected static interface ContentSelectorFactory {

        /**
         * Creates a new selector object.
         */
        AbstractContentSelector createSelector(ContentManager cm,
                                               XBLOMContentElement content,
                                               Element bound,
                                               String selector);
    }

    /**
     * A factory for XPathSubsetContentSelector objects.
     */
    protected static class XPathSubsetContentSelectorFactory
            implements ContentSelectorFactory {

        /**
         * Creates a new XPathSubsetContentSelector object.
         */
        public AbstractContentSelector createSelector(ContentManager cm,
                                                      XBLOMContentElement content,
                                                      Element bound,
                                                      String selector) {
            return new XPathSubsetContentSelector(cm, content, bound, selector);
        }
    }

    /**
     * A factory for XPathPatternContentSelector objects.
     */
    protected static class XPathPatternContentSelectorFactory
            implements ContentSelectorFactory {

        /**
         * Creates a new XPathPatternContentSelector object.
         */
        public AbstractContentSelector createSelector(ContentManager cm,
                                                      XBLOMContentElement content,
                                                      Element bound,
                                                      String selector) {
            return new XPathPatternContentSelector(cm, content, bound, selector);
        }
    }
}
