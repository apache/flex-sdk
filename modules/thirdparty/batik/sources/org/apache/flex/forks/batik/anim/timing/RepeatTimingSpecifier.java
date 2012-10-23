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
package org.apache.flex.forks.batik.anim.timing;

import org.w3c.dom.events.Event;
import org.w3c.dom.smil.TimeEvent;

/**
 * A class to handle repeat event SMIL timing specifiers.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: RepeatTimingSpecifier.java 475477 2006-11-15 22:44:28Z cam $
 */
public class RepeatTimingSpecifier extends EventbaseTimingSpecifier {

    /**
     * The repeat iteration.
     */
    protected int repeatIteration;

    /**
     * Whether a repeat iteration was specified.
     */
    protected boolean repeatIterationSpecified;

    /**
     * Creates a new RepeatTimingSpecifier object without a repeat iteration.
     */
    public RepeatTimingSpecifier(TimedElement owner, boolean isBegin,
                                 float offset, String syncbaseID) {
        super(owner, isBegin, offset, syncbaseID,
              owner.getRoot().getRepeatEventName());
    }

    /**
     * Creates a new RepeatTimingSpecifier object with a repeat iteration.
     */
    public RepeatTimingSpecifier(TimedElement owner, boolean isBegin,
                                 float offset, String syncbaseID,
                                 int repeatIteration) {
        super(owner, isBegin, offset, syncbaseID,
              owner.getRoot().getRepeatEventName());
        this.repeatIteration = repeatIteration;
        this.repeatIterationSpecified = true;
    }
    
    /**
     * Returns a string representation of this timing specifier.
     */
    public String toString() {
        return (eventbaseID == null ? "" : eventbaseID + ".") + "repeat"
            + (repeatIterationSpecified ? "(" + repeatIteration + ")" : "")
            + (offset != 0 ? super.toString() : "");
    }

    // EventListener /////////////////////////////////////////////////////////

    /**
     * Handles an event fired on the eventbase element.
     */
    public void handleEvent(Event e) {
        TimeEvent evt = (TimeEvent) e;
        if (!repeatIterationSpecified || evt.getDetail() == repeatIteration) {
            super.handleEvent(e);
        }
    }
}
