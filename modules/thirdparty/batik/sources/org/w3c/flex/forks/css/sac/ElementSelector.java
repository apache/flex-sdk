/*
 * Copyright (c) 1999 World Wide Web Consortium,
 * (Massachusetts Institute of Technology, Institut National de
 * Recherche en Informatique et en Automatique, Keio University). All
 * Rights Reserved. This program is distributed under the W3C's Software
 * Intellectual Property License. This program is distributed in the
 * hope that it will be useful, but WITHOUT ANY WARRANTY; without even
 * the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.
 * See W3C License http://www.w3.org/Consortium/Legal/ for more details.
 *
 * $Id: ElementSelector.java,v 1.2 2000/11/10 17:14:20 hillion Exp $
 */
package org.w3c.flex.forks.css.sac;

/**
 * @version $Revision: 1.2 $
 * @author  Philippe Le Hegaret
 * @see Selector#SAC_ELEMENT_NODE_SELECTOR
 */
public interface ElementSelector extends SimpleSelector {

    /**
     * Returns the
     * <a href="http://www.w3.org/TR/REC-xml-names/#dt-NSName">namespace
     * URI</a> of this element selector.
     * <p><code>NULL</code> if this element selector can match any namespace.</p>
     */
    public String getNamespaceURI();

    /**
     * Returns the
     * <a href="http://www.w3.org/TR/REC-xml-names/#NT-LocalPart">local part</a>
     * of the
     * <a href="http://www.w3.org/TR/REC-xml-names/#ns-qualnames">qualified
     * name</a> of this element.
     * <p><code>NULL</code> if this element selector can match any element.</p>
     * </ul>
     */
    public String getLocalName();
}
