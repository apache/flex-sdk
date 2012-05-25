/*

   Copyright 2001  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.parser;

/**
 * This class provides an adapter for PointsHandler.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: DefaultPointsHandler.java,v 1.3 2004/08/18 07:14:46 vhardy Exp $
 */
public class DefaultPointsHandler implements PointsHandler {
    /**
     * The only instance of this class.
     */
    public final static DefaultPointsHandler INSTANCE
        = new DefaultPointsHandler();

    /**
     * This class does not need to be instantiated.
     */
    protected DefaultPointsHandler() {
    }

    /**
     * Implements {@link PointsHandler#startPoints()}.
     */
    public void startPoints() throws ParseException {
    }

    /**
     * Implements {@link PointsHandler#point(float,float)}.
     */
    public void point(float x, float y) throws ParseException {
    }

    /**
     * Implements {@link PointsHandler#endPoints()}.
     */
    public void endPoints() throws ParseException {
    }
}
