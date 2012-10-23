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

package org.apache.flex.forks.batik.gvt.event;

import java.util.EventListener;

/**
 * The listener interface for receiving selection events.
 *
 * @author <a href="mailto:bill.haneman@ireland.sun.com">Bill Haneman</a>
 * @version $Id: SelectionListener.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface SelectionListener extends EventListener {

    /**
     * Invoked when a selection has changed.
     * @param evt the selection change event
     */
    void selectionChanged(SelectionEvent evt);

    /**
     * Invoked when a selection is done.
     * @param evt the selection change event
     */
    void selectionDone(SelectionEvent evt);

    /**
     * Invoked when a selection is cleared.
     * @param evt the selection change event
     */
    void selectionCleared(SelectionEvent evt);

    /**
     * Invoked when a selection started.
     * @param evt the selection change event
     */
    void selectionStarted(SelectionEvent evt);

}
