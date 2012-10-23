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
package org.apache.flex.forks.batik.parser;

/**
 * This interface must be implemented and then registred as the
 * handler of a <code>PreserveAspectRatioParser</code> instance
 * in order to be notified of parsing events.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: FragmentIdentifierHandler.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface FragmentIdentifierHandler
    extends PreserveAspectRatioHandler,
            TransformListHandler {

    /**
     * Invoked when the fragment identifier starts.
     * @exception ParseException if an error occured while processing the
     *                           fragment identifier
     */
    void startFragmentIdentifier() throws ParseException;

    /**
     * Invoked when an ID has been parsed.
     * @param s The string that represents the parsed ID.
     * @exception ParseException if an error occured while processing the
     *                           fragment identifier
     */
    void idReference(String s) throws ParseException;

    /**
     * Invoked when 'viewBox(x,y,width,height)' has been parsed.
     * @param x x coordinate of the viewbox
     * @param y y coordinate of the viewbox
     * @param width width of the viewbox
     * @param height height of the viewbox
     * @exception ParseException if an error occured while processing the
     *                           fragment identifier
     */
    void viewBox(float x, float y, float width, float height)
        throws ParseException;

    /**
     * Invoked when a view target specification starts.
     * @exception ParseException if an error occured while processing the
     *                           fragment identifier
     */
    void startViewTarget() throws ParseException;

    /**
     * Invoked when a identifier has been parsed within a view target
     * specification.
     * @param name the target name.
     * @exception ParseException if an error occured while processing the
     *                           fragment identifier
     */
    void viewTarget(String name) throws ParseException;

    /**
     * Invoked when a view target specification ends.
     * @exception ParseException if an error occured while processing the
     *                           fragment identifier
     */
    void endViewTarget() throws ParseException;

    /**
     * Invoked when a 'zoomAndPan' specification has been parsed.
     * @param magnify true if 'magnify' has been parsed.
     * @exception ParseException if an error occured while processing the
     *                           fragment identifier
     */
    void zoomAndPan(boolean magnify);

    /**
     * Invoked when the fragment identifier ends.
     * @exception ParseException if an error occured while processing the
     *                           fragment identifier
     */
    void endFragmentIdentifier() throws ParseException;
}
