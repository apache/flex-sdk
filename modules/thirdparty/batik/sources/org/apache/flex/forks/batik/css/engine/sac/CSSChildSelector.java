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
package org.apache.flex.forks.batik.css.engine.sac;

import java.util.Set;

import org.w3c.css.sac.Selector;
import org.w3c.css.sac.SimpleSelector;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

/**
 * This class provides an implementation of the
 * {@link org.w3c.css.sac.DescendantSelector} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: CSSChildSelector.java 501495 2007-01-30 18:00:36Z dvholten $
 */
public class CSSChildSelector extends AbstractDescendantSelector {

    /**
     * Creates a new CSSChildSelector object.
     */
    public CSSChildSelector(Selector ancestor, SimpleSelector simple) {
        super(ancestor, simple);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.Selector#getSelectorType()}.
     */
    public short getSelectorType() {
        return SAC_CHILD_SELECTOR;
    }

    /**
     * Tests whether this selector matches the given element.
     */
    public boolean match(Element e, String pseudoE) {
        Node n = e.getParentNode();
        if (n != null && n.getNodeType() == Node.ELEMENT_NODE) {
            return ((ExtendedSelector)getAncestorSelector()).match((Element)n,
                                                                   null) &&
                   ((ExtendedSelector)getSimpleSelector()).match(e, pseudoE);
        }
        return false;
    }

    /**
     * Fills the given set with the attribute names found in this selector.
     */
    public void fillAttributeSet(Set attrSet) {
        ((ExtendedSelector)getAncestorSelector()).fillAttributeSet(attrSet);
        ((ExtendedSelector)getSimpleSelector()).fillAttributeSet(attrSet);
    }

    /**
     * Returns a representation of the selector.
     */
    public String toString() {
        SimpleSelector s = getSimpleSelector();
        if (s.getSelectorType() == SAC_PSEUDO_ELEMENT_SELECTOR) {
            return String.valueOf( getAncestorSelector() ) + s;
        }
        return getAncestorSelector() + " > " + s;
    }
}
