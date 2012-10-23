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
 * A class to handle media marker SMIL timing specifiers.  This class
 * of timing specifier is currently unused.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: MediaMarkerTimingSpecifier.java 475477 2006-11-15 22:44:28Z cam $
 */
public class MediaMarkerTimingSpecifier extends TimingSpecifier {

    /**
     * The ID of the media element.
     */
    protected String syncbaseID;

    /**
     * The media element.
     */
    protected TimedElement mediaElement;

    /**
     * The media marker name.
     */
    protected String markerName;

    /**
     * The instance time.
     */
    protected InstanceTime instance;

    /**
     * Creates a new MediaMarkerTimingSpecifier object.
     */
    public MediaMarkerTimingSpecifier(TimedElement owner, boolean isBegin,
                                      String syncbaseID, String markerName) {
        super(owner, isBegin);
        this.syncbaseID = syncbaseID;
        this.markerName = markerName;
        this.mediaElement = owner.getTimedElementById(syncbaseID);
    }
    
    /**
     * Returns a string representation of this timing specifier.
     */
    public String toString() {
        return syncbaseID + ".marker(" + markerName + ")";
    }

    /**
     * Returns whether this timing specifier is event-like (i.e., if it is
     * an eventbase, accesskey or a repeat timing specifier).
     */
    public boolean isEventCondition() {
        return false;
    }
}
