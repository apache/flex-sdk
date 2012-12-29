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

import java.awt.Shape;

/**
 * An event which indicates that a selection is being made or has been made.
 *
 * @author <a href="mailto:bill.haneman@ireland.sun.com">Bill Haneman</a>
 * @author <a href="mailto:tkormann@ilog.fr">Thierry Kormann</a>
 * @version $Id: SelectionEvent.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SelectionEvent {

    /**
     * The id for the "selection changing" event.
     * (Selection process is under way)
     */
    public static final int SELECTION_CHANGED = 1;

    /**
     * The id for the "selection cleared" event.
     */
    public static final int SELECTION_CLEARED = 3;

    /**
     * The id for the "selection started" event.
     */
    public static final int SELECTION_STARTED = 4;

    /**
     * The id for the "selection completed" event.
     * (Selection process is complete).
     */
    public static final int SELECTION_DONE = 2;

    /** The shape enclosing the selection */
    protected Shape highlightShape;

    /** The object which composes the selection */
    protected Object selection;

    /** The event type of the current selection event */
    protected int id;

    /**
     * Constructs a new graphics node paint event.
     * @param selection the selection
     * @param id the id of this event
     * @param highlightShape a user-space shape enclosing the selection.
     */
    public SelectionEvent(Object selection, int id, Shape highlightShape ) {
        this.id = id;
        this.selection = selection;
        this.highlightShape = highlightShape;
    }

    /**
     * Returns a shape in user space that encloses the current selection.
     */
    public Shape getHighlightShape() {
        return highlightShape;
    }

    /**
     * Returns the selection associated with this event.
     * Only guaranteed current for events of type SELECTION_DONE.
     */
    public Object getSelection() {
        return selection;
    }

    /**
     * Returns the event's selection event type.
     * @see org.apache.flex.forks.batik.gvt.event.SelectionEvent#SELECTION_CHANGED
     * @see org.apache.flex.forks.batik.gvt.event.SelectionEvent#SELECTION_CLEARED
     * @see org.apache.flex.forks.batik.gvt.event.SelectionEvent#SELECTION_DONE
     */
    public int getID() {
        return id;
    }
}
