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
 * A class to handle the 'indefinite' SMIL timing specifier.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: IndefiniteTimingSpecifier.java 580338 2007-09-28 13:13:46Z cam $
 */
public class IndefiniteTimingSpecifier extends TimingSpecifier {

    /**
     * Creates a new IndefiniteTimingSpecifier object.
     */
    public IndefiniteTimingSpecifier(TimedElement owner, boolean isBegin) {
        super(owner, isBegin);
    }
    
    /**
     * Returns a string representation of this timing specifier.
     */
    public String toString() {
        return "indefinite";
    }

    /**
     * Initializes this timing specifier by adding the initial instance time
     * to the owner's instance time list or setting up any event listeners.
     */
    public void initialize() {
        if (!isBegin) {
            // Only end instance lists get an 'indefinite' instance time from
            // an indefinite timing specifier.
            InstanceTime instance =
                new InstanceTime(this, TimedElement.INDEFINITE, false);
            owner.addInstanceTime(instance, isBegin);
        }
    }

    /**
     * Returns whether this timing specifier is event-like (i.e., if it is
     * an eventbase, accesskey or a repeat timing specifier).
     */
    public boolean isEventCondition() {
        return false;
    }
}
