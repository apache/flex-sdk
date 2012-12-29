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
package org.apache.flex.forks.batik.gvt.text;

import java.awt.geom.GeneralPath;
import java.awt.geom.Point2D;

import org.apache.flex.forks.batik.ext.awt.geom.PathLength;

/**
 * A text path describes a path along which some text will be rendered.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: TextPath.java 475477 2006-11-15 22:44:28Z cam $
 */
public class TextPath {

    private PathLength pathLength;
    private float startOffset;

    /**
     * Constructs a TextPath based on the specified path.
     *
     * @param path The general path along which text is to be laid.
     */
    public TextPath(GeneralPath path) {
        pathLength = new PathLength(path);
        startOffset = 0;
    }

    /**
     * Sets the offset along the path where the first glyph should be rendered.
     *
     * @param startOffset An offset from the start of the path.
     */
    public void setStartOffset(float startOffset) {
        this.startOffset = startOffset;
    }

    /**
     * Returns the start offset of this text path.
     *
     * @return The start offset of this text path.
     */
    public float getStartOffset() {
        return startOffset;
    }

    /**
     * Returns the total length of the path.
     *
     * @return The lenght of the path.
     */
    public float lengthOfPath() {
        return pathLength.lengthOfPath();
    }

    /**
     * Returns the angle at the specified length
     * along the path.
     *
     * @param length The length along the path.
     * @return The angle.
     */
    public float angleAtLength(float length) {
        return pathLength.angleAtLength(length);
    }

    /**
     * Returns the point that is at the specified length
     * along the path.
     *
     * @param length The length along the path.
     * @return The point.
     */
    public Point2D pointAtLength(float length) {
        return pathLength.pointAtLength(length);
    }
}
