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

import java.awt.Shape;
import java.io.IOException;
import java.io.Reader;

/**
 * This class produces a polygon shape from a reader.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AWTPolygonProducer.java 475477 2006-11-15 22:44:28Z cam $
 */
public class AWTPolygonProducer extends AWTPolylineProducer {
    /**
     * Utility method for creating an ExtendedGeneralPath.
     * @param r The reader used to read the path specification.
     * @param wr The winding rule to use for creating the path.
     */
    public static Shape createShape(Reader r, int wr)
        throws IOException,
               ParseException {
        PointsParser p = new PointsParser();
        AWTPolygonProducer ph = new AWTPolygonProducer();

        ph.setWindingRule(wr);
        p.setPointsHandler(ph);
        p.parse(r);

        return ph.getShape();
    }

    /**
     * Implements {@link PointsHandler#endPoints()}.
     */
    public void endPoints() throws ParseException {
        path.closePath();
    }
}
