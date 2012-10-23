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

/**
 * Concrete version of {@link org.apache.flex.forks.batik.swing.gvt.AbstractJGVTComponent}.
 *
 * This class is used for JDKs &lt; 1.4, which don't have MouseWheelEvent
 * support.  For JDKs &gt;= 1.4, the file
 * sources-1.4/org/apache/batik/swing/gvt/JGVTComponent defines a
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
     * @param eventEnabled Whether the GVT tree should be reactive
     *        to mouse and key events.
     * @param selectableText Whether the text should be selectable.
     *        if eventEnabled is false, this flag is ignored.
     */
    public JGVTComponent(boolean eventsEnabled,
                         boolean selectableText) {
        super(eventsEnabled, selectableText);
    }

    /**
     * To hide the listener methods.
     */
    protected class ExtendedListener extends Listener {
    }
}
