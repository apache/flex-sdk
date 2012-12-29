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
 * September 18, 2005
 *   Translated IDL to Java.
 *   Placed interface in org.apache.flex.forks.batik.dom.svg12 for the time being.
 *   Added javadocs.
 */
package org.apache.flex.forks.batik.dom.svg12;

import org.w3c.dom.events.EventTarget;

/**
 * Interface for a global scripting object for an SVG document.
 * Eventually will move to org.w3c.dom.svg (or some such package).
 *
 * @version $Id: SVGGlobal.java 498740 2007-01-22 18:35:57Z dvholten $
 */
public interface SVGGlobal extends Global {

//     /**
//      * Gets the document.
//      */
//     Document getDocument();
//
//     /**
//      * Returns the parent global scripting object.
//      */
//     Global getParent();
//
//     /**
//      * Returns the current location loaded by the user agent.
//      */
//     String getLocation();
//
//     /**
//      * Move to a new document.
//      */
//     void gotoLocation(String newURL);
//
//     /**
//      * Parses an XML fragment.
//      */
//     Node parseXML(String source, Document document);
//
//     /**
//      * Serializes a DOM node.
//      */
//     String printNode(Node node);
//
//     /**
//      * Timer method.
//      */
//     SVGTimer createTimer(long delay, long interval, boolean start);
//
//     /**
//      * Creates a URLRequest object.
//      */
//     URLRequest createURLRequest();
//
//     /**
//      * Creates a Connection object.
//      */
//     Connection createConnection();

    /**
     * Starts mouse capture.
     */
    void startMouseCapture(EventTarget target, boolean sendAll,
                           boolean autoRelease);

    /**
     * Stops mouse capture.
     */
    void stopMouseCapture();

//     /**
//      * Creates a FileDialog object.
//      */
//     FileDialog createFileDialog();
//
//     /**
//      * Creates an SVGEventFilter object.
//      */
//     SVGEventFilter createEventFilter();
//
//     /**
//      * Sets a client-side persistent value.
//      */
//     void setPersistentValue(String name, String value);
//
//     /**
//      * Gets a client-side persistent value.
//      */
//     String getPersistentValue(String name);
}
