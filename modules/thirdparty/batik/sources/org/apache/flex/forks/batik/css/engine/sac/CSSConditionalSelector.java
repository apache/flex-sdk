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

import org.w3c.css.sac.Condition;
import org.w3c.css.sac.ConditionalSelector;
import org.w3c.css.sac.SimpleSelector;
import org.w3c.dom.Element;

/**
 * This class provides an implementation of the
 * {@link org.w3c.css.sac.ConditionalSelector} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: CSSConditionalSelector.java 501495 2007-01-30 18:00:36Z dvholten $
 */
public class CSSConditionalSelector
    implements ConditionalSelector,
               ExtendedSelector {

    /**
     * The simple selector.
     */
    protected SimpleSelector simpleSelector;

    /**
     * The condition.
     */
    protected Condition condition;

    /**
     * Creates a new ConditionalSelector object.
     */
    public CSSConditionalSelector(SimpleSelector s, Condition c) {
        simpleSelector = s;
        condition      = c;
    }

    /**
     * Indicates whether some other object is "equal to" this one.
     * @param obj the reference object with which to compare.
     */
    public boolean equals(Object obj) {
        if (obj == null || (obj.getClass() != getClass())) {
            return false;
        }
        CSSConditionalSelector s = (CSSConditionalSelector)obj;
        return (s.simpleSelector.equals(simpleSelector) &&
                s.condition.equals(condition));
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.Selector#getSelectorType()}.
     */
    public short getSelectorType() {
        return SAC_CONDITIONAL_SELECTOR;
    }

    /**
     * Tests whether this selector matches the given element.
     */
    public boolean match(Element e, String pseudoE) {
        return ((ExtendedSelector)getSimpleSelector()).match(e, pseudoE) &&
               ((ExtendedCondition)getCondition()).match(e, pseudoE);
    }

    /**
     * Fills the given set with the attribute names found in this selector.
     */
    public void fillAttributeSet(Set attrSet) {
        ((ExtendedSelector)getSimpleSelector()).fillAttributeSet(attrSet);
        ((ExtendedCondition)getCondition()).fillAttributeSet(attrSet);
    }

    /**
     * Returns the specificity of this selector.
     */
    public int getSpecificity() {
        return ((ExtendedSelector)getSimpleSelector()).getSpecificity() +
               ((ExtendedCondition)getCondition()).getSpecificity();
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.ConditionalSelector#getSimpleSelector()}.
     */
    public SimpleSelector getSimpleSelector() {
        return simpleSelector;
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.css.sac.ConditionalSelector#getCondition()}.
     */
    public Condition getCondition() {
        return condition;
    }

    /**
     * Returns a representation of the selector.
     */
    public String toString() {
        return String.valueOf( simpleSelector ) + condition;
    }
}
