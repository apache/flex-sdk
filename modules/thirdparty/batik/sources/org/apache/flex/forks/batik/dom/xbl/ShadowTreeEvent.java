/*
 * Copyright (c) 2005 World Wide Web Consortium,
 *
 * (Massachusetts Institute of Technology, European Research Consortium for
 * Informatics and Mathematics, Keio University). All Rights Reserved. This
 * work is distributed under the W3C(r) Software License [1] in the hope that
 * it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 * [1] http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231
 *
 * Modifications:
 *
 * September 10, 2005
 *   Placed interface in org.apache.flex.forks.batik.dom.xbl for the time being.
 *   Added javadocs.
 */
package org.apache.flex.forks.batik.dom.xbl;

import org.w3c.dom.events.Event;

/**
 * Interface for shadow tree related events.
 * Eventually will move to org.w3c.dom.xbl (or some such package).
 *
 * @version $Id: ShadowTreeEvent.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public interface ShadowTreeEvent extends Event {
    XBLShadowTreeElement getXblShadowTree();
    void initShadowTreeEvent(String typeArg,
                             boolean canBubbleArg,
                             boolean cancelableArg,
                             XBLShadowTreeElement xblShadowTreeArg);
    void initShadowTreeEventNS(String namespaceURIArg,
                               String typeArg,
                               boolean canBubbleArg,
                               boolean cancelableArg,
                               XBLShadowTreeElement xblShadowTreeArg);
}
