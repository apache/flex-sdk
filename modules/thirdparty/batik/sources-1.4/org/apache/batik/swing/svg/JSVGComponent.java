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
package org.apache.flex.forks.batik.swing.svg;

import java.awt.event.MouseWheelEvent;

/**
 * Concrete version of {@link org.apache.flex.forks.batik.swing.svg.AbstractJSVGComponent}.
 *
 * This class is used for JDKs &gt;= 1.4, which have MouseWheelEvent
 * support.  For JDKs &lt; 1.4, the file
 * sources-1.3/org/apache/batik/swing/gvt/JSVGComponent defines a
 * version of this class that does support MouseWheelEvents.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: JSVGComponent.java 475477 2006-11-15 22:44:28Z cam $
 */
public class JSVGComponent extends AbstractJSVGComponent {

    /**
     * Creates a new AbstractJSVGComponent.
     * @param ua a SVGUserAgent instance or null.
     * @param eventsEnabled Whether the GVT tree should be reactive
     *        to mouse and key events.
     * @param selectableText Whether the text should be selectable.
     */
    public JSVGComponent(SVGUserAgent ua, boolean eventsEnabled,
                         boolean selectableText) {
        super(ua, eventsEnabled, selectableText);
    }

    /**
     * Creates an instance of Listener.
     */
    protected Listener createListener() {
        return new ExtendedSVGListener();
    }

    /**
     * To hide the listener methods.
     */
    protected class ExtendedSVGListener
            extends SVGListener {

        /**
         * Dispatches the event to the GVT tree.
         */
        protected void dispatchMouseWheelMoved(final MouseWheelEvent e) {
            if (!isInteractiveDocument) {
                super.dispatchMouseWheelMoved(e);
                return;
            }

            if (updateManager != null && updateManager.isRunning()) {
                updateManager.getUpdateRunnableQueue().invokeLater
                    (new Runnable() {
                        public void run() {
                            eventDispatcher.mouseWheelMoved(e);
                        }
                    });
            }
        }
    }
}
