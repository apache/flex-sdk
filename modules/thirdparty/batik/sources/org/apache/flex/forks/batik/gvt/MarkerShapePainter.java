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

import java.awt.Graphics2D;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.Arc2D;
import java.awt.geom.PathIterator;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.util.List;
import java.util.ArrayList;

import org.apache.flex.forks.batik.ext.awt.geom.ExtendedGeneralPath;
import org.apache.flex.forks.batik.ext.awt.geom.ExtendedPathIterator;
import org.apache.flex.forks.batik.ext.awt.geom.ExtendedShape;
import org.apache.flex.forks.batik.ext.awt.geom.ShapeExtender;

/**
 * A shape painter that can be used to paint markers on a shape.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: MarkerShapePainter.java 504084 2007-02-06 11:24:46Z dvholten $
 */
public class MarkerShapePainter implements ShapePainter {

    /**
     * The Shape to be painted.
     */
    protected ExtendedShape extShape;

    /**
     * Start Marker
     */
    protected Marker startMarker;

    /**
     * Middle Marker
     */
    protected Marker middleMarker;

    /**
     * End Marker
     */
    protected Marker endMarker;

    /**
     * Start marker proxy.
     */
    private ProxyGraphicsNode startMarkerProxy;

    /**
     * Middle marker proxy.
     */
    private ProxyGraphicsNode[] middleMarkerProxies;

    /**
     * End marker proxy.
     */
    private ProxyGraphicsNode endMarkerProxy;

    /**
     * Contains the various marker proxies.
     */
    private CompositeGraphicsNode markerGroup;

    /**
     * Internal Cache: Primitive bounds
     */
    private Rectangle2D dPrimitiveBounds;

    /**
     * Internal Cache: Geometry bounds
     */
    private Rectangle2D dGeometryBounds;

    /**
     * Constructs a new <tt>MarkerShapePainter</tt> that can be used to markers
     * on top of a shape.
     *
     * @param shape Shape to be painted by this painter.
     * Should not be null
     */
    public MarkerShapePainter(Shape shape) {
        if (shape == null) {
            throw new IllegalArgumentException();
        }
        if (shape instanceof ExtendedShape) {
            this.extShape = (ExtendedShape)shape;
        } else {
            this.extShape = new ShapeExtender(shape);
        }
    }

    /**
     * Paints the specified shape using the specified Graphics2D.
     *
     * @param g2d the Graphics2D to use
     */
     public void paint(Graphics2D g2d) {
         if (markerGroup == null) {
             buildMarkerGroup();
         }
         if (markerGroup.getChildren().size() > 0) {
             markerGroup.paint(g2d);
         }
     }

    /**
     * Returns the area painted by this shape painter.
     */
    public Shape getPaintedArea(){
         if (markerGroup == null) {
             buildMarkerGroup();
         }
        return markerGroup.getOutline();
    }

    /**
     * Returns the bounds of the area painted by this shape painter
     */
    public Rectangle2D getPaintedBounds2D(){
         if (markerGroup == null) {
             buildMarkerGroup();
         }
         return markerGroup.getPrimitiveBounds();
    }

    /**
     * Returns true if pt is in the area painted by this shape painter
     */
    public boolean inPaintedArea(Point2D pt){
         if (markerGroup == null) {
             buildMarkerGroup();
         }
         GraphicsNode gn = markerGroup.nodeHitAt(pt);
         return (gn != null);
    }

    /**
     * Returns the area covered by this shape painter (even if not painted).
     * This is always null for Markers.
     */
    public Shape getSensitiveArea() { return null; }

    /**
     * Returns the bounds of the area covered by this shape painte
     * (even if not painted). This is always null for Markers.
     */
    public Rectangle2D getSensitiveBounds2D() { return null; }

    /**
     * Returns true if pt is in the sensitive area.
     * This is always false for Markers.
     */
    public boolean inSensitiveArea(Point2D pt) { return false; }


    /**
     * Sets the Shape this shape painter is associated with.
     *
     * @param shape new shape this painter should be associated with.
     * Should not be null.
     */
    public void setShape(Shape shape){
        if (shape == null) {
            throw new IllegalArgumentException();
        }
        if (shape instanceof ExtendedShape) {
            this.extShape = (ExtendedShape)shape;
        } else {
            this.extShape = new ShapeExtender(shape);
        }

        this.startMarkerProxy = null;
        this.middleMarkerProxies = null;
        this.endMarkerProxy = null;
        this.markerGroup = null;
    }

    /**
     * Gets the Shape this shape painter is associated with as an
     * Extended Shape.
     *
     * @return shape associated with this painter */
    public ExtendedShape getExtShape(){
        return extShape;
    }

    /**
     * Gets the Shape this shape painter is associated with.
     *
     * @return shape associated with this painter
     */
    public Shape getShape(){
        return extShape;
    }

    /**
     * Returns the marker that shall be drawn at the first vertex of the given
     * shape.
     */
    public Marker getStartMarker(){
        return startMarker;
    }

    /**
     * Sets the marker that shall be drawn at the first vertex of the given
     * shape.
     *
     * @param startMarker the start marker
     */
    public void setStartMarker(Marker startMarker){
        this.startMarker = startMarker;
        this.startMarkerProxy = null;
        this.markerGroup = null;
    }

    /**
     * Returns the marker that shall be drawn at every other vertex (not the
     * first or the last one) of the given shape.
     */
    public Marker getMiddleMarker(){
        return middleMarker;
    }

    /**
     * Sets the marker that shall be drawn at every other vertex (not the first
     * or the last one) of the given shape.
     *
     * @param middleMarker the middle marker
     */
    public void setMiddleMarker(Marker middleMarker){
        this.middleMarker = middleMarker;
        this.middleMarkerProxies = null;
        this.markerGroup = null;
    }

    /**
     * Returns the marker that shall be drawn at the last vertex of the given
     * shape.
     */
    public Marker getEndMarker(){
        return endMarker;
    }

    /**
     * Sets the marker that shall be drawn at the last vertex of the given
     * shape.
     *
     * @param endMarker the end marker
     */
    public void setEndMarker(Marker endMarker){
        this.endMarker = endMarker;
        this.endMarkerProxy = null;
        this.markerGroup = null;
    }

    // ---------------------------------------------------------------------
    // Internal methods to build GraphicsNode according to the Marker
    // ---------------------------------------------------------------------

    /**
     * Builds a new marker group with the current set of markers.
     */
    protected void buildMarkerGroup(){
        if (startMarker != null && startMarkerProxy == null) {
            startMarkerProxy = buildStartMarkerProxy();
        }

        if (middleMarker != null && middleMarkerProxies == null) {
            middleMarkerProxies = buildMiddleMarkerProxies();
        }

        if (endMarker != null && endMarkerProxy == null) {
            endMarkerProxy = buildEndMarkerProxy();
        }

        CompositeGraphicsNode group = new CompositeGraphicsNode();
        List children = group.getChildren();
        if (startMarkerProxy != null) {
            children.add(startMarkerProxy);
        }

        if (middleMarkerProxies != null) {
            for(int i=0; i<middleMarkerProxies.length; i++){
                children.add(middleMarkerProxies[i]);
            }
        }

        if (endMarkerProxy != null) {
            children.add(endMarkerProxy);
        }

        markerGroup = group;
    }

    /**
     * Builds a proxy <tt>GraphicsNode</tt> for the input <tt>Marker</tt> to be
     * drawn at the start position
     */
    protected ProxyGraphicsNode buildStartMarkerProxy() {

        ExtendedPathIterator iter = getExtShape().getExtendedPathIterator();

        // Get initial point on the path
        double[] coords = new double[7];
        int segType = 0;

        if (iter.isDone()) {
            return null;
        }

        segType = iter.currentSegment(coords);
        if (segType != ExtendedPathIterator.SEG_MOVETO) {
            return null;
        }
        iter.next();

        Point2D markerPosition = new Point2D.Double(coords[0], coords[1]);

        // If the marker's orient property is NaN,
        // the slope needs to be computed
        double rotation = startMarker.getOrient();
        if (Double.isNaN(rotation)) {
            if (!iter.isDone()) {
                double[] next = new double[7];
                int nextSegType = 0;
                nextSegType = iter.currentSegment(next);
                if(nextSegType == PathIterator.SEG_CLOSE){
                    nextSegType = PathIterator.SEG_LINETO;
                    next[0] = coords[0];
                    next[1] = coords[1];
                }
                rotation = computeRotation(null, 0,  // no previous seg.
                                           coords, segType,    // segment ending on start point
                                           next, nextSegType); // segment out of start point

            }
        }

        // Now, compute the marker's proxy transform
        AffineTransform markerTxf = computeMarkerTransform(startMarker,
                                                           markerPosition,
                                                           rotation);

        ProxyGraphicsNode gn = new ProxyGraphicsNode();

        gn.setSource(startMarker.getMarkerNode());
        gn.setTransform(markerTxf);

        return gn;
    }

    /**
     * Builds a proxy <tt>GraphicsNode</tt> for the input <tt>Marker</tt> to be
     * drawn at the end position.
     */
    protected ProxyGraphicsNode buildEndMarkerProxy() {

        ExtendedPathIterator iter = getExtShape().getExtendedPathIterator();

        int nPoints = 0;

        // Get first point, in case the last segment on the
        // path is a close
        if (iter.isDone()) {
            return null;
        }

        double[] coords = new double[7];
        double[] moveTo = new double[2];
        int segType = 0;
        segType = iter.currentSegment(coords);
        if (segType != ExtendedPathIterator.SEG_MOVETO) {
            return null;
        }
        nPoints++;
        moveTo[0] = coords[0];
        moveTo[1] = coords[1];

        iter.next();

        // Now, get the last two points on the path
        double[] lastButOne = new double[7];
        double[] last = {coords[0], coords[1], coords[2],
                         coords[3], coords[4], coords[5], coords[6] };
        double[] tmp = null;
        int lastSegType = segType;
        int lastButOneSegType = 0;

        while (!iter.isDone()) {
            tmp = lastButOne;
            lastButOne = last;
            last = tmp;
            lastButOneSegType = lastSegType;

            lastSegType = iter.currentSegment(last);

            if (lastSegType == PathIterator.SEG_MOVETO) {
                moveTo[0] = last[0];
                moveTo[1] = last[1];
            } else if (lastSegType == PathIterator.SEG_CLOSE) {
                lastSegType = PathIterator.SEG_LINETO;
                last[0] = moveTo[0];
                last[1] = moveTo[1];
            }

            iter.next();
            nPoints++;
        }

        if (nPoints < 2) {
            return null;
        }

        // Turn the last segment into a position
        Point2D markerPosition = getSegmentTerminatingPoint(last, lastSegType);

        // If the marker's orient property is NaN,
        // the slope needs to be computed
        double rotation = endMarker.getOrient();
        if (Double.isNaN(rotation)) {
            rotation = computeRotation(lastButOne,
                                       lastButOneSegType,
                                       last, lastSegType,
                                       null, 0);
        }

        // Now, compute the marker's proxy transform
        AffineTransform markerTxf = computeMarkerTransform(endMarker,
                                                           markerPosition,
                                                           rotation);

        ProxyGraphicsNode gn = new ProxyGraphicsNode();

        gn.setSource(endMarker.getMarkerNode());
        gn.setTransform(markerTxf);

        return gn;
    }

    /**
     * Builds a proxy <tt>GraphicsNode</tt> for the input
     * <tt>Marker</tt> to be drawn at the middle positions
     */
    protected ProxyGraphicsNode[] buildMiddleMarkerProxies() {

        ExtendedPathIterator iter = getExtShape().getExtendedPathIterator();

        double[] prev = new double[7];
        double[] curr = new double[7];
        double[] next = new double[7], tmp = null;
        int prevSegType = 0, currSegType = 0, nextSegType = 0;

        // Get the first three points on the path
        if (iter.isDone()) {
            return null;
        }

        prevSegType = iter.currentSegment(prev);
        double[] moveTo = new double[2];

        if (prevSegType != PathIterator.SEG_MOVETO) {
            return null;
        }

        moveTo[0] = prev[0];
        moveTo[1] = prev[1];
        iter.next();

        if (iter.isDone()) {
            return null;
        }

        currSegType = iter.currentSegment(curr);

        if (currSegType == PathIterator.SEG_MOVETO) {
            moveTo[0] = curr[0];
            moveTo[1] = curr[1];
        } else if (currSegType == PathIterator.SEG_CLOSE) {
            currSegType = PathIterator.SEG_LINETO;
            curr[0] = moveTo[0];
            curr[1] = moveTo[1];
        }

        iter.next();

        List proxies = new ArrayList();
        while (!iter.isDone()) {
            nextSegType = iter.currentSegment(next);

            if (nextSegType == PathIterator.SEG_MOVETO) {
                moveTo[0] = next[0];
                moveTo[1] = next[1];
            } else if (nextSegType == PathIterator.SEG_CLOSE) {
                nextSegType = PathIterator.SEG_LINETO;
                next[0] = moveTo[0];
                next[1] = moveTo[1];
            }

            proxies.add(createMiddleMarker(prev, prevSegType,
                                                  curr, currSegType,
                                                  next, nextSegType));

            tmp = prev;
            prev = curr;
            prevSegType = currSegType;
            curr = next;
            currSegType = nextSegType;
            next = tmp;

            iter.next();
        }

        ProxyGraphicsNode [] gn = new ProxyGraphicsNode[proxies.size()];
        proxies.toArray( gn );

        return gn;
    }

    /**
     * Creates a ProxyGraphicsNode for a middle marker.
     */
    private ProxyGraphicsNode createMiddleMarker
        (double[] prev, int prevSegType,
         double[] curr, int currSegType,
         double[] next, int nextSegType) {

        // Turn the curr segment into a position
        Point2D markerPosition = getSegmentTerminatingPoint(curr, currSegType);

        // If the marker's orient property is NaN,
        // the slope needs to be computed
        double rotation = middleMarker.getOrient();
        if (Double.isNaN(rotation)) {
            rotation = computeRotation(prev, prevSegType,
                                       curr, currSegType,
                                       next, nextSegType);
        }

        // Now, compute the marker's proxy transform
        AffineTransform markerTxf = computeMarkerTransform(middleMarker,
                                                           markerPosition,
                                                           rotation);

        ProxyGraphicsNode gn = new ProxyGraphicsNode();

        gn.setSource(middleMarker.getMarkerNode());
        gn.setTransform(markerTxf);

        return gn;
    }

    /**
     * Returns the rotation according to the specified parameters in degrees.
     */
    private double computeRotation(double[] prev, int prevSegType,
                                   double[] curr, int currSegType,
                                   double[] next, int nextSegType){

        // Compute in slope, i.e., the slope of the segment
        // going into the current point
        double[] inSlope = computeInSlope(prev, prevSegType,
                                          curr, currSegType);

        // Compute out slope, i.e., the slope of the segment
        // going out of the current point
        double[] outSlope = computeOutSlope(curr, currSegType,
                                            next, nextSegType);

        if (inSlope == null) {
            inSlope = outSlope;
        }

        if (outSlope == null) {
            outSlope = inSlope;
        }

        if (inSlope == null) {
            return 0;
        }

        double dx = inSlope[0] + outSlope[0];
        double dy = inSlope[1] + outSlope[1];

        if (dx == 0 && dy == 0) {
            // The two vectors are exact opposites. There is no way to
            // know which direction to go (+90 or -90). Choose +90
            return Math.toDegrees( Math.atan2(inSlope[1], inSlope[0]) ) + 90;
        } else {
            return Math.toDegrees( Math.atan2(dy, dx) );
        }
    }

    /**
     * Returns dx/dy for the in slope.
     */
    private double[] computeInSlope(double[] prev, int prevSegType,
                                    double[] curr, int currSegType){

        // Compute point into which the slope runs
        Point2D currEndPoint = getSegmentTerminatingPoint(curr, currSegType);

        double dx = 0;
        double dy = 0;

        switch(currSegType){
        case PathIterator.SEG_LINETO: {
            // This is equivalent to a line from the previous segment's
            // terminating point and the current end point.
            Point2D prevEndPoint =
                getSegmentTerminatingPoint(prev, prevSegType);
            dx = currEndPoint.getX() - prevEndPoint.getX();
            dy = currEndPoint.getY() - prevEndPoint.getY();
        }
            break;
        case PathIterator.SEG_QUADTO:
            // If the current segment is a line, quad or cubic curve.
            // the slope is about equal to that of the line from the
            // last control point and the curEndPoint
            dx = currEndPoint.getX() - curr[0];
            dy = currEndPoint.getY() - curr[1];
            break;
        case PathIterator.SEG_CUBICTO:
            // If the current segment is a quad or cubic curve.
            // the slope is about equal to that of the line from the
            // last control point and the curEndPoint
            dx = currEndPoint.getX() - curr[2];
            dy = currEndPoint.getY() - curr[3];
            break;
        case ExtendedPathIterator.SEG_ARCTO: {
            // If the current segment is an ARCTO then we build the
            // arc and ask for it's end angle and get the tangent there.
            Point2D prevEndPoint =
                getSegmentTerminatingPoint(prev, prevSegType);
            boolean large   = (curr[3]!=0.);
            boolean goLeft = (curr[4]!=0.);
            Arc2D arc = ExtendedGeneralPath.computeArc
                (prevEndPoint.getX(), prevEndPoint.getY(),
                 curr[0], curr[1], curr[2],
                 large, goLeft, curr[5], curr[6]);
            double theta = arc.getAngleStart()+arc.getAngleExtent();
            theta = Math.toRadians(theta);
            dx = -arc.getWidth()/2.0*Math.sin(theta);
            dy = arc.getHeight()/2.0*Math.cos(theta);

            // System.out.println("In  Theta:  " + Math.toDegrees(theta) +
            //                    " Dx/Dy: " + dx + "/" + dy);
            if (curr[2] != 0) {
                double ang = Math.toRadians(-curr[2]);
                double sinA = Math.sin(ang);
                double cosA = Math.cos(ang);
                double tdx = dx*cosA - dy*sinA;
                double tdy = dx*sinA + dy*cosA;
                dx = tdx;
                dy = tdy;
            }
            // System.out.println("    Rotate: " + curr[2] +
            //                    " Dx/Dy: " + dx + "/" + dy);
            if (goLeft) {
                dx = -dx;
            } else {
                dy = -dy;
            }
            // System.out.println("    GoLeft? " + goLeft +
            //                    " Dx/Dy: " + dx + "/" + dy);
        }
            break;
        case PathIterator.SEG_CLOSE:
            // Should not have any close at this point
            throw new Error("should not have SEG_CLOSE here");
        case PathIterator.SEG_MOVETO:
            // Cannot compute the slope
        default:
            return null;
        }

        if (dx == 0 && dy == 0) {
            return null;
        }

        return normalize(new double[] { dx, dy });
    }

    /**
     * Returns dx/dy for the out slope.
     */
    private double[] computeOutSlope(double[] curr, int currSegType,
                                     double[] next, int nextSegType){

        Point2D currEndPoint = getSegmentTerminatingPoint(curr, currSegType);

        double dx = 0, dy = 0;

        switch(nextSegType){
        case PathIterator.SEG_CLOSE:
            // Should not happen at this point, because all close
            // segments have been replaced by lineTo segments.
            break;
        case PathIterator.SEG_CUBICTO:
        case PathIterator.SEG_LINETO:
        case PathIterator.SEG_QUADTO:
            // If the next segment is a line, quad or cubic curve.
            // the slope is about equal to that of the line from
            // curEndPoint and the first control point
            dx = next[0] - currEndPoint.getX();
            dy = next[1] - currEndPoint.getY();
            break;
        case ExtendedPathIterator.SEG_ARCTO: {
            // If the current segment is an ARCTO then we build the
            // arc and ask for it's end angle and get the tangent there.
            boolean large   = (next[3]!=0.);
            boolean goLeft = (next[4]!=0.);
            Arc2D arc = ExtendedGeneralPath.computeArc
                (currEndPoint.getX(), currEndPoint.getY(),
                 next[0], next[1], next[2],
                 large, goLeft, next[5], next[6]);
            double theta = arc.getAngleStart();
            theta = Math.toRadians(theta);
            dx = -arc.getWidth()/2.0*Math.sin(theta);
            dy = arc.getHeight()/2.0*Math.cos(theta);
            // System.out.println("Out Theta:  " + Math.toDegrees(theta) +
            //                    " Dx/Dy: " + dx + "/" + dy);
            if (next[2] != 0) {
                double ang = Math.toRadians(-next[2]);
                double sinA = Math.sin(ang);
                double cosA = Math.cos(ang);
                double tdx = dx*cosA - dy*sinA;
                double tdy = dx*sinA + dy*cosA;
                dx = tdx;
                dy = tdy;
            }
            // System.out.println("    Rotate: " + next[2] +
            //                    " Dx/Dy: " + dx + "/" + dy);

            if (goLeft) {
                dx = -dx;
            } else {
                dy = -dy;
            }
            // System.out.println("    GoLeft? " + goLeft +
            //                    " Dx/Dy: " + dx + "/" + dy);
        }
            break;
        case PathIterator.SEG_MOVETO:
            // Cannot compute the out slope
        default:
            return null;
        }

        if (dx == 0 && dy == 0) {
            return null;
        }

        return normalize(new double[] { dx, dy });
    }

    /**
     * Normalizes the input vector. This assumes an non-zero length
     */
    public double[] normalize(double[] v) {
        double n = Math.sqrt(v[0]*v[0]+v[1]*v[1]);
        v[0] /= n;
        v[1] /= n;
        return v;
    }

    /**
     * Computes the transform for the input marker, so that it is positioned at
     * the given position with the specified rotation
     */
    private AffineTransform computeMarkerTransform(Marker marker,
                                                   Point2D markerPosition,
                                                   double rotation) {
        Point2D ref = marker.getRef();
        /*AffineTransform txf =
            AffineTransform.getTranslateInstance(markerPosition.getX()
                                                 - ref.getX(),
                                                 markerPosition.getY()
                                                 - ref.getY());*/
        AffineTransform txf = new AffineTransform();

        txf.translate(markerPosition.getX() - ref.getX(),
                      markerPosition.getY() - ref.getY());

        if (!Double.isNaN(rotation)) {
            txf.rotate( Math.toRadians( rotation ), ref.getX(), ref.getY());
        }

        return txf;
    }

    /**
     * Extracts the terminating point, depending on the segment type.
     */
    protected Point2D getSegmentTerminatingPoint(double[] coords, int segType) {
        switch(segType){
        case PathIterator.SEG_CUBICTO:
            return new Point2D.Double(coords[4], coords[5]);
        case PathIterator.SEG_LINETO:
            return new Point2D.Double(coords[0], coords[1]);
        case PathIterator.SEG_MOVETO:
            return new Point2D.Double(coords[0], coords[1]);
        case PathIterator.SEG_QUADTO:
            return new Point2D.Double(coords[2], coords[3]);
        case ExtendedPathIterator.SEG_ARCTO:
            return new Point2D.Double(coords[5], coords[6]);
        case PathIterator.SEG_CLOSE:
        default:
            throw new Error( "invalid segmentType:" + segType );
            // Should never happen: close segments are replaced with lineTo
        }
    }
}
