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

/**
 * Abstract class from which all event-like timing specifier classes derive.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: EventLikeTimingSpecifier.java 475477 2006-11-15 22:44:28Z cam $
 */
public abstract class EventLikeTimingSpecifier extends OffsetTimingSpecifier {

    /**
     * Creates a new EventLikeTimingSpecifier object.
     */
    public EventLikeTimingSpecifier(TimedElement owner, boolean isBegin,
                                    float offset) {
        super(owner, isBegin, offset);
    }

    /**
     * Returns whether this timing specifier is event-like (i.e., if it is
     * an eventbase, accesskey or a repeat timing specifier).
     */
    public boolean isEventCondition() {
        return true;
    }

    /**
     * Invoked to resolve an event-like timing specifier into an instance time.
     */
    public abstract void resolve(Event e);
}
