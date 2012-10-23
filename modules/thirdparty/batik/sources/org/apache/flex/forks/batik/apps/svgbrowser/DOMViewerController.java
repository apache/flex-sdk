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
package org.apache.flex.forks.batik.apps.svgbrowser;

import org.apache.flex.forks.batik.swing.gvt.Overlay;

import org.w3c.dom.Document;
import org.w3c.dom.Node;

/**
 * Provides the information needed for the DOMViewer to show and edit the
 * document.
 *
 * @version $Id$
 */
public interface DOMViewerController {

    /**
     * Performs the document update.
     *
     * @param r The runnable that contains the update
     */
    void performUpdate(Runnable r);

    /**
     * Creates the ElementSelectionManager to manage the selection overlay on
     * the canvas.
     *
     * @return ElementSelectionManager
     */
    ElementOverlayManager createSelectionManager();

    /**
     * Removes the given selection overlay from the canvas.
     *
     * @param selectionOverlay
     *            The given selection overlay
     */
    void removeSelectionOverlay(Overlay selectionOverlay);

    /**
     * Gets the document for the DOMViewer to show.
     *
     * @return the document
     */
    Document getDocument();

    /**
     * Selects the given node in the DOMViewer's document tree.
     *
     * @param node
     *            The node to select
     */
    void selectNode(Node node);

    /**
     * Checks whether the DOMViewer should be allowed to edit the document.
     *
     * @return True for non static documents, when UpdateManager is available
     */
    boolean canEdit();
}
