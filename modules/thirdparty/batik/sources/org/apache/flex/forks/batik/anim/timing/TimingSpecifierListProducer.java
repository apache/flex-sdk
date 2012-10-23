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

import java.util.Calendar;
import java.util.LinkedList;

import org.apache.flex.forks.batik.parser.DefaultTimingSpecifierListHandler;
import org.apache.flex.forks.batik.parser.TimingSpecifierListParser;

/**
 * A {@link org.apache.flex.forks.batik.parser.TimingSpecifierListHandler} that creates
 * {@link TimingSpecifier}s.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: TimingSpecifierListProducer.java 475477 2006-11-15 22:44:28Z cam $
 */
public class TimingSpecifierListProducer
        extends DefaultTimingSpecifierListHandler {

    /**
     * The list of parsed timing specifiers.
     */
    protected LinkedList timingSpecifiers = new LinkedList();

    /**
     * The owner TimedElement used when creating the TimingSpecifiers.
     */
    protected TimedElement owner;

    /**
     * Whether the created TimingSpecifiers should be begin times.
     */
    protected boolean isBegin;

    /**
     * Creates a new TimingSpecifierListProducer.
     */
    public TimingSpecifierListProducer(TimedElement owner, boolean isBegin) {
        this.owner = owner;
        this.isBegin = isBegin;
    }

    /**
     * Returns an array of the parsed TimingSpecifiers.
     */
    public TimingSpecifier[] getTimingSpecifiers() {
        return (TimingSpecifier[]) timingSpecifiers.toArray(new TimingSpecifier[0]);
    }

    /**
     * Parses a timing specifier list.
     */
    public static TimingSpecifier[] parseTimingSpecifierList
            (TimedElement owner, boolean isBegin, String spec,
             boolean useSVG11AccessKeys, boolean useSVG12AccessKeys) {
        TimingSpecifierListParser p =
            new TimingSpecifierListParser(useSVG11AccessKeys,
                                          useSVG12AccessKeys);
        TimingSpecifierListProducer pp =
            new TimingSpecifierListProducer(owner, isBegin);
        p.setTimingSpecifierListHandler(pp);
        p.parse(spec);
        TimingSpecifier[] specs = pp.getTimingSpecifiers();
        return specs;
    }

    // TimingSpecifierHandler ////////////////////////////////////////////////

    /**
     * Invoked when an offset value timing specifier is parsed.
     */
    public void offset(float offset) {
        TimingSpecifier ts = new OffsetTimingSpecifier(owner, isBegin, offset);
        timingSpecifiers.add(ts);
    }

    /**
     * Invoked when a syncbase value timing specifier is parsed.
     */
    public void syncbase(float offset, String syncbaseID,
                         String timeSymbol) {
        TimingSpecifier ts = new SyncbaseTimingSpecifier
            (owner, isBegin, offset, syncbaseID, timeSymbol.charAt(0) == 'b');
        timingSpecifiers.add(ts);
    }

    /**
     * Invoked when an eventbase value timing specifier is parsed.
     */
    public void eventbase(float offset, String eventbaseID,
                          String eventType) {
        TimingSpecifier ts = new EventbaseTimingSpecifier
            (owner, isBegin, offset, eventbaseID, eventType);
        timingSpecifiers.add(ts);
    }

    /**
     * Invoked when a repeat value timing specifier with no iteration
     * is parsed.
     */
    public void repeat(float offset, String syncbaseID) {
        TimingSpecifier ts = new RepeatTimingSpecifier
            (owner, isBegin, offset, syncbaseID);
        timingSpecifiers.add(ts);
    }

    /**
     * Invoked when a repeat value timing specifier with an iteration
     * is parsed.
     */
    public void repeat(float offset, String syncbaseID,
                       int repeatIteration) {
        TimingSpecifier ts = new RepeatTimingSpecifier
            (owner, isBegin, offset, syncbaseID, repeatIteration);
        timingSpecifiers.add(ts);
    }

    /**
     * Invoked when an accesskey value timing specifier is parsed.
     */
    public void accesskey(float offset, char key) {
        TimingSpecifier ts = new AccesskeyTimingSpecifier
            (owner, isBegin, offset, key);
        timingSpecifiers.add(ts);
    }

    /**
     * Invoked when an SVG 1.2 accessKey value timing specifier is parsed.
     */
    public void accessKeySVG12(float offset, String keyName) {
        TimingSpecifier ts = new AccesskeyTimingSpecifier
            (owner, isBegin, offset, keyName);
        timingSpecifiers.add(ts);
    }

    /**
     * Invoked when a media marker value timing specifier is parsed.
     */
    public void mediaMarker(String syncbaseID, String markerName) {
        TimingSpecifier ts = new MediaMarkerTimingSpecifier
            (owner, isBegin, syncbaseID, markerName);
        timingSpecifiers.add(ts);
    }

    /**
     * Invoked when a wallclock value timing specifier is parsed.
     */
    public void wallclock(Calendar time) {
        TimingSpecifier ts = new WallclockTimingSpecifier(owner, isBegin, time);
        timingSpecifiers.add(ts);
    }

    /**
     * Invoked when an indefinite value timing specifier is parsed.
     */
    public void indefinite() {
        TimingSpecifier ts = new IndefiniteTimingSpecifier(owner, isBegin);
        timingSpecifiers.add(ts);
    }
}
