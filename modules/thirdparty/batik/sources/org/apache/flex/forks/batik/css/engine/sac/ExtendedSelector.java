/*

   Copyright 1999-2003  The Apache Software Foundation 

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

import org.w3c.flex.forks.css.sac.Selector;
import org.w3c.dom.Element;

/**
 * This interface extends the {@link org.w3c.flex.forks.css.sac.Selector}.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ExtendedSelector.java,v 1.4 2004/10/30 18:38:04 deweese Exp $
 */
public interface ExtendedSelector extends Selector {

    /**
     * Tests whether this selector matches the given element.
     */
    boolean match(Element e, String pseudoE);

    /**
     * Returns the specificity of this selector.
     */
    int getSpecificity();

    /**
     * Fills the given set with the attribute names found in this selector.
     */
    void fillAttributeSet(Set attrSet);
}
