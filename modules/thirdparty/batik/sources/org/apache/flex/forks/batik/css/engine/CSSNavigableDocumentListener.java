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
package org.apache.flex.forks.batik.css.engine;

import org.w3c.dom.Attr;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * An interface for listeners of CSSNavigableDocument events.  The
 * events parallel the DOM events, but apply to the CSS view of
 * the tree rather than the actual DOM tree.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: CSSNavigableDocumentListener.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface CSSNavigableDocumentListener {

    /**
     * A node has been inserted into the CSSNavigableDocument tree.
     */
    void nodeInserted(Node newNode);

    /**
     * A node is about to be removed from the CSSNavigableDocument tree.
     */
    void nodeToBeRemoved(Node oldNode);

    /**
     * A subtree of the CSSNavigableDocument tree has been modified
     * in some way.
     */
    void subtreeModified(Node rootOfModifications);

    /**
     * Character data in the CSSNavigableDocument tree has been modified.
     */
    void characterDataModified(Node text);

    /**
     * An attribute has changed in the CSSNavigableDocument.
     */
    void attrModified(Element e, Attr attr, short attrChange,
                      String prevValue, String newValue);

    /**
     * The text of the override style declaration for this element has been
     * modified.
     */
    void overrideStyleTextChanged(CSSStylableElement e, String text);

    /**
     * A property in the override style declaration has been removed.
     */
    void overrideStylePropertyRemoved(CSSStylableElement e, String name);

    /**
     * A property in the override style declaration has been changed.
     */
    void overrideStylePropertyChanged(CSSStylableElement e, String name,
                                      String val, String prio);
}
