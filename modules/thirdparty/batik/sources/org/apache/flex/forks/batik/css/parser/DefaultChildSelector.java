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
package org.apache.flex.forks.batik.css.parser;

import org.w3c.flex.forks.css.sac.Selector;
import org.w3c.flex.forks.css.sac.SimpleSelector;

/**
 * This class provides an implementation of the
 * {@link org.w3c.flex.forks.css.sac.DescendantSelector} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DefaultChildSelector.java,v 1.3 2004/08/18 07:13:02 vhardy Exp $
 */
public class DefaultChildSelector extends AbstractDescendantSelector {

    /**
     * Creates a new DefaultChildSelector object.
     */
    public DefaultChildSelector(Selector ancestor, SimpleSelector simple) {
	super(ancestor, simple);
    }

    /**
     * <b>SAC</b>: Implements {@link
     * org.w3c.flex.forks.css.sac.Selector#getSelectorType()}.
     */
    public short getSelectorType() {
	return SAC_CHILD_SELECTOR;
    }

    /**
     * Returns a representation of the selector.
     */
    public String toString() {
	SimpleSelector s = getSimpleSelector();
	if (s.getSelectorType() == SAC_PSEUDO_ELEMENT_SELECTOR) {
	    return "" + getAncestorSelector() + s;
	}
	return getAncestorSelector() + " > " + s;
    }
}
