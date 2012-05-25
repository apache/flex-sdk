/*

   Copyright 2000  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.dom;

import org.w3c.dom.DOMException;
import org.w3c.dom.Node;
import org.w3c.dom.Text;

/**
 * This class implements the {@link org.w3c.dom.Text} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractText.java,v 1.6 2005/02/22 09:12:58 cam Exp $
 */

public abstract class AbstractText
    extends    AbstractCharacterData
    implements Text {

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Text#splitText(int)}.
     */
    public Text splitText(int offset) throws DOMException {
	if (isReadonly()) {
	    throw createDOMException(DOMException.NO_MODIFICATION_ALLOWED_ERR,
				     "readonly.node",
				     new Object[] { new Integer(getNodeType()),
						    getNodeName() });
	}
	String v = getNodeValue();
	if (offset < 0 || offset >= v.length()) {
	    throw createDOMException(DOMException.INDEX_SIZE_ERR,
				     "offset",
				     new Object[] { new Integer(offset) });
	}
	Node n = getParentNode();
	if (n == null) {
	    throw createDOMException(DOMException.INDEX_SIZE_ERR,
				     "need.parent",
				     new Object[] {});
	}
	String t1 = v.substring(offset);
	Text t = createTextNode(t1);
	Node ns = getNextSibling();
	if (ns != null) {
	    n.insertBefore(t, ns);
	} else {
	    n.appendChild(t);
	}
	setNodeValue(v.substring(0, offset));
	return t;
    }

    /**
     * Creates a text node of the current type.
     */
    protected abstract Text createTextNode(String text);
}
