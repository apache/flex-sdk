/*

   Copyright 2002-2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.css.engine;

import org.w3c.dom.DocumentFragment;
import org.w3c.dom.Element;

/**
 * This interface represents a DOM node which must be set as parent
 * of an imported node to allow a mecanism similar to the SVG <use>
 * element to work.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: CSSImportedElementRoot.java,v 1.4 2004/08/18 07:12:48 vhardy Exp $
 */
public interface CSSImportedElementRoot extends DocumentFragment {
    
    /**
     * Returns the parent of the imported element, from the CSS
     * point of view.
     */
    Element getCSSParentElement();

    /**
     * Returns true if the imported element is local to
     * the owning document.
     */
    boolean getIsLocal();
}
