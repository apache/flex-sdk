/*

   Copyright 2003 The Apache Software Foundation 

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
package org.w3c.flex.forks.dom.svg;

/**
 * This interface must be implemented in order to call Java code from
 * an SVG document.
 *
 * A <code>EventListenerInitializer</code> instance is called when
 * a 'script' element's 'type' attribute value is 'application/java-archive' and when
 * the manifest of the jar file referenced by the 'xlink:href' attribute contains
 * a 'SVG-Handler-Class' entry.  The value of this entry must be the classname of the
 * <code>EventListenerInitializer</code> to call.
 *
 * This classes implementing this interface must have a default
 * constructor.
 *
 * @version $Id: EventListenerInitializer.java,v 1.2 2005/03/27 08:58:37 cam Exp $
 */
public interface EventListenerInitializer {

    /**
     * This method is called by the SVG viewer
     * when the scripts are loaded to register
     * the listener needed.
     * @param doc The current document.
     */
    public void initializeEventListeners(SVGDocument doc);
}
