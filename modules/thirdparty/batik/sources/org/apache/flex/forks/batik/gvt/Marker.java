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
package org.apache.flex.forks.batik.gvt;

import java.awt.geom.Point2D;

/**
 * A Marker describes a GraphicsNode with a reference point that can be used to
 * position the Marker at a particular location and a particular policy for
 * rotating the marker when drawing it.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: Marker.java 475477 2006-11-15 22:44:28Z cam $ 
 */
public class Marker {

    /**
     * Rotation angle, about (0, 0) is user space. If orient is NaN then the
     * marker's x-axis should be aligned with the slope of the curve on the
     * point where the object is drawn 
     */
    protected double orient;

    /**
     * GraphicsNode this marker is associated to
     */
    protected GraphicsNode markerNode;

    /**
     * Reference point about which the marker should be drawn
     */
    protected Point2D ref;

    /**
     * Constructs a new marker.
     *
     * @param markerNode the graphics node that represents the marker
     * @param ref the reference point
     * @param orient the orientation of the marker
     */
    public Marker(GraphicsNode markerNode, Point2D ref, double orient){

        if (markerNode == null) {
            throw new IllegalArgumentException();
        }

        if (ref == null) {
            throw new IllegalArgumentException();
        }

        this.markerNode = markerNode;
        this.ref = ref;
        this.orient = orient;
    }

    /**
     * Returns the reference point of this marker.
     */
    public Point2D getRef(){
        return (Point2D)ref.clone();
    }

    /**
     * Returns the orientation of this marker.
     */
    public double getOrient(){
        return orient;
    }

    /**
     * Returns the <code>GraphicsNode</code> that draws this marker.
     */
    public GraphicsNode getMarkerNode(){
        return markerNode;
    }
}
