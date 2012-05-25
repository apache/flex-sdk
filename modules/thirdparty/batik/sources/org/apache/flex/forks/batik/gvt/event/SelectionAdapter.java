/*

   Copyright 2005 The Apache Software Foundation 

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

package org.apache.flex.forks.batik.gvt.event;

/**
 * Adapter for the listener interface for receiving selection events.
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: SelectionAdapter.java,v 1.2 2005/03/27 08:58:34 cam Exp $
 */
public class SelectionAdapter implements SelectionListener {
    /**
     * Invoked when a selection has changed.
     * @param evt the selection change event
     */
    public void selectionChanged(SelectionEvent evt) { }

    /**
     * Invoked when a selection is done.
     * @param evt the selection change event
     */
    public void selectionDone(SelectionEvent evt) { }

    /**
     * Invoked when a selection is cleared.
     * @param evt the selection change event
     */
    public void selectionCleared(SelectionEvent evt) { }

    /**
     * Invoked when a selection started.
     * @param evt the selection change event
     */
    public void selectionStarted(SelectionEvent evt) { }
};



