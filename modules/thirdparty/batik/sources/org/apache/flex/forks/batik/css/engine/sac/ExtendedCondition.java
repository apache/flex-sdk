/*

   Copyright 2002  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.css.engine.sac;

import java.util.Set;

import org.w3c.flex.forks.css.sac.Condition;
import org.w3c.dom.Element;

/**
 * This interface provides additional features to the
 * {@link org.w3c.flex.forks.css.sac.Condition} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ExtendedCondition.java,v 1.4 2004/08/18 07:12:51 vhardy Exp $
 */
public interface ExtendedCondition extends Condition {

    /**
     * Tests whether this condition matches the given element.
     */
    boolean match(Element e, String pseudoE);

    /**
     * Returns the specificity of this condition.
     */
    int getSpecificity();

    /**
     * Fills the given set with the attribute names found in this selector.
     */
    void fillAttributeSet(Set attrSet);
}
