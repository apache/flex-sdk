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
package org.apache.flex.forks.batik.swing.gvt;

import java.awt.event.MouseWheelEvent;
import java.awt.event.MouseWheelListener;

/**
 * Concrete version of {@link org.apache.flex.forks.batik.swing.gvt.AbstractJGVTComponent}.
 *
 * This class is used for JDKs &gt;= 1.4, which have MouseWheelEvent
 * support.  For JDKs &lt; 1.4, the file
 * sources-1.3/org/apache/batik/swing/gvt/JGVTComponent defines a
 * version of this class that does support MouseWheelEvents.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: JGVTComponent.java 475477 2006-11-15 22:44:28Z cam $
 */
public class JGVTComponent extends AbstractJGVTComponent {

    /**
     * Creates a new JGVTComponent.
     */
    public JGVTComponent() {
    }

    /**
     * Creates a new JGVTComponent.
     * @param eventsEnabled Whether the GVT tree should be reactive
     *        to mouse and key events.
     * @param selectableText Whether the text should be selectable.
     *        if eventEnabled is false, this flag is ignored.
     */
    public JGVTComponent(boolean eventsEnabled,
                         boolean selectableText) {
        super(eventsEnabled, selectableText);
    }

    /**
     * Adds the AWT listeners.
     */
    protected void addAWTListeners() {
        super.addAWTListeners();
        addMouseWheelListener((ExtendedListener) listener);
    }

    /**
     * Creates an instance of Listener.
     * Override to provide a Listener that can listen for mouse wheel
     * events.
     */
    protected Listener createListener() {
        return new ExtendedListener();
    }

    /**
     * To hide the listener methods.
     */
    protected class ExtendedListener
        extends Listener
        implements MouseWheelListener {

        // MouseWheelListener ///////////////////////////////////////////////

        /**
         * Invoked when the mouse wheel has been scrolled.
         */
        public void mouseWheelMoved(MouseWheelEvent e) {
            /*selectInteractor(e);
            if (interactor != null) {
                interactor.mouseWheelMoved(e);
                deselectInteractor();
            } else*/ if (eventDispatcher != null) {
                dispatchMouseWheelMoved(e);
            }
        }

        /**
         * Dispatches the mouse event to the GVT tree.
         */
        protected void dispatchMouseWheelMoved(MouseWheelEvent e) {
            eventDispatcher.mouseWheelMoved(e);
        }
    }
}
