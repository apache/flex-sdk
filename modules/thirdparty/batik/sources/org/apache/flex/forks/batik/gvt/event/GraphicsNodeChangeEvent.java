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

import org.apache.flex.forks.batik.gvt.GraphicsNode;

/**
 * An event which indicates that a change action occurred on a graphics node.
 *
 * @author <a href="mailto:deweese@apache.org">Thomas DeWeese</a>
 * @version $Id: GraphicsNodeChangeEvent.java 475477 2006-11-15 22:44:28Z cam $
 */
public class GraphicsNodeChangeEvent extends GraphicsNodeEvent {

    /**
     * The first number in the range of ids used for change events.
     */
    static final int CHANGE_FIRST = 9800;

    /**
     * The id for the "changeStarted" event. This change event occurs
     * when a change has started on a graphics node (but no changes have
     * occured on the graphics node it's self).
     */
    public static final int CHANGE_STARTED = CHANGE_FIRST;

    /**
     * The id for the "changeCompleted" event. This change event
     * occurs when a change has completed on a graphics node (all
     * changes have completed on the graphics node it's self).  
     */
    public static final int CHANGE_COMPLETED = CHANGE_FIRST+1;

    protected GraphicsNode changeSource;

    /**
     * Constructs a new graphics node event with the specified source and ID.
     * @param source the graphics node where the event originated
     * @param id the id of this event
     */
    public GraphicsNodeChangeEvent(GraphicsNode source, int id) {
        super(source, id);
    }
    public void setChangeSrc(GraphicsNode gn) { this.changeSource = gn; }
    public GraphicsNode getChangeSrc() { return changeSource; }
}
