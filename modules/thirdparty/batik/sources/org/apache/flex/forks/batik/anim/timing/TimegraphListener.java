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

/**
 * An interface for listening to timing events in a timed document.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: TimegraphListener.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface TimegraphListener {

    /**
     * Invoked to indicate that a timed element has been added to the
     * document.
     */
    void elementAdded(TimedElement e);

    /**
     * Invoked to indicate that a timed element has been removed from the
     * document.
     */
    void elementRemoved(TimedElement e);

    /**
     * Invoked to indicate that a timed element has become active.
     * @param e the TimedElement that became active
     * @param t the time (in parent simple time) that the element became active
     */
    void elementActivated(TimedElement e, float t);

    /**
     * Invoked to indicate that a timed element has become inactive
     * and is filling.
     */
    void elementFilled(TimedElement e, float t);

    /**
     * Invoked to indicate that a timed element has become inactive
     * and is not filling.
     */
    void elementDeactivated(TimedElement e, float t);

    /**
     * Invoked to indivate that an interval was created for the given
     * timed element.
     */
    void intervalCreated(TimedElement e, Interval i);

    /**
     * Invoked to indivate that an interval was removed for the given
     * timed element.
     */
    void intervalRemoved(TimedElement e, Interval i);

    /**
     * Invoked to indivate that an interval's endpoints were changed.
     */
    void intervalChanged(TimedElement e, Interval i);

    /**
     * Invoked to indivate that the given interval began.
     * @param i the Interval that began, or null if no interval is
     *          active for the given timed element.
     */
    void intervalBegan(TimedElement e, Interval i);

    /**
     * Invoked to indicate that the given timed element began a repeat
     * iteration at the specified time.
     */
    void elementRepeated(TimedElement e, int i, float t);

    /**
     * Invoked to indicate that the list of instance times for the given
     * timed element has been updated.
     */
    void elementInstanceTimesChanged(TimedElement e, float isBegin);
}
