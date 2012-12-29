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

import java.util.ArrayList;

import org.apache.flex.forks.batik.dom.svg12.XBLOMContentElement;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * A class to handle content selection when the includes attribute is not
 * present.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: DefaultContentSelector.java 475477 2006-11-15 22:44:28Z cam $
 */
public class DefaultContentSelector extends AbstractContentSelector {

    /**
     * The selected nodes.
     */
    protected SelectedNodes selectedContent;

    /**
     * Creates a new XPathSubsetContentSelector object.
     */
    public DefaultContentSelector(ContentManager cm,
                                  XBLOMContentElement content,
                                  Element bound) {
        super(cm, content, bound);
    }

    /**
     * Returns a list of nodes that were matched by the given selector
     * string.
     */
    public NodeList getSelectedContent() {
        if (selectedContent == null) {
            selectedContent = new SelectedNodes();
        }
        return selectedContent;
    }

    /**
     * Forces this selector to update its selected nodes list.
     * Returns true if the selected node list needed updating.
     * This assumes that the previous content elements in this
     * shadow tree (in document order) have up-to-date selectedContent
     * lists.
     */
    boolean update() {
        if (selectedContent == null) {
            selectedContent = new SelectedNodes();
            return true;
        }
        return selectedContent.update();
    }

    /**
     * Implementation of NodeList that contains the nodes that matched
     * this selector.
     */
    protected class SelectedNodes implements NodeList {

        /**
         * The selected nodes.
         */
        protected ArrayList nodes = new ArrayList(10);

        /**
         * Creates a new SelectedNodes object.
         */
        public SelectedNodes() {
            update();
        }

        protected boolean update() {
            ArrayList oldNodes = (ArrayList) nodes.clone();
            nodes.clear();
            for (Node n = boundElement.getFirstChild(); n != null; n = n.getNextSibling()) {
                if (isSelected(n)) {
                    continue;
                }
                nodes.add(n);
            }
            int nodesSize = nodes.size();
            if (oldNodes.size() != nodesSize) {
                return true;
            }
            for (int i = 0; i < nodesSize; i++) {
                if (oldNodes.get(i) != nodes.get(i)) {
                    return true;
                }
            }
            return false;
        }

        /**
         * <b>DOM</b>: Implements {@link org.w3c.dom.NodeList#item(int)}.
         */
        public Node item(int index) {
            if (index < 0 || index >= nodes.size()) {
                return null;
            }
            return (Node) nodes.get(index);
        }

        /**
         * <b>DOM</b>: Implements {@link org.w3c.dom.NodeList#getLength()}.
         */
        public int getLength() {
            return nodes.size();
        }
    }
}
