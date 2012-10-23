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

import java.util.EventObject;

import org.apache.flex.forks.batik.gvt.GraphicsNode;

/**
 * A low-level event for GraphicsNode.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: GraphicsNodeEvent.java 475477 2006-11-15 22:44:28Z cam $
 */
public class GraphicsNodeEvent extends EventObject {

    /** Indicates whether or not this event is consumed. */
    private boolean consumed = false;

    /** The ID of this event. */
    protected int id;

    /**
     * Constructs a new graphics node event with the specified source and ID.
     * @param source the graphics node where the event originated
     * @param id the id of this event
     */
    public GraphicsNodeEvent(GraphicsNode source, int id) {
        super(source);
        this.id = id;
    }

    /**
     * Returns the ID of this event.
     */
    public int getID() {
        return id;
    }

    /**
     * Returns the graphics node where the event is originated.
     */
    public GraphicsNode getGraphicsNode() {
        return (GraphicsNode) source;
    }

    /**
     * Consumes this event so that it will not be processed
     * in the default manner by the source which originated it.
     */
    public void consume() {
        consumed = true;
    }

    /**
     * Returns whether or not this event has been consumed.
     */
    public boolean isConsumed() {
        return consumed;
    }
}
