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
package org.apache.flex.forks.batik.ext.awt.geom;

import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.FlatteningPathIterator;
import java.awt.geom.PathIterator;
import java.awt.geom.Point2D;
import java.util.List;
import java.util.ArrayList;

/**
 * Utilitiy class for length calculations of paths.
 * <p>
 *   PathLength is a utility class for calculating the length
 *   of a path, the location of a point at a particular length
 *   along the path, and the angle of the tangent to the path
 *   at a given length.
 * </p>
 * <p>
 *   It uses a FlatteningPathIterator to create a flattened version
 *   of the Path. This means the values returned are not always
 *   exact (in fact, they rarely are), but in most cases they
 *   are reasonably accurate.
 * </p>
 *
 * @author <a href="mailto:dean.jackson@cmis.csiro.au">Dean Jackson</a>
 * @version $Id: PathLength.java 489226 2006-12-21 00:05:36Z cam $
 */
public class PathLength {

    /**
     * The path to use for calculations.
     */
    protected Shape path;

    /**
     * The list of flattened path segments.
     */
    protected List segments;

    /**
     * Array where the index is the index of the original path segment
     * and the value is the index of the first of the flattened segments
     * in {@link #segments} that corresponds to that original path segment.
     */
    protected int[] segmentIndexes;

    /**
     * Cached copy of the path length.
     */
    protected float pathLength;

    /**
     * Whether this path been flattened yet.
     */
    protected boolean initialised;

    /**
     * Creates a new PathLength object for the specified {@link Shape}.
     * @param path The Path (or Shape) to use.
     */
    public PathLength(Shape path) {
        setPath(path);
    }

    /**
     * Returns the path to use for calculations.
     * @return Path used in calculations.
     */
    public Shape getPath() {
        return path;
    }

    /**
     * Sets the path to use for calculations.
     * @param v Path to be used in calculations.
     */
    public void setPath(Shape v) {
        this.path = v;
        initialised = false;
    }

    /**
     * Returns the length of the path used by this PathLength object.
     * @return The length of the path.
     */
    public float lengthOfPath() {
        if (!initialised) {
            initialise();
        }
        return pathLength;
    }

    /**
     * Flattens the path and determines the path length.
     */
    protected void initialise() {
        pathLength = 0f;

        PathIterator pi = path.getPathIterator(new AffineTransform());
        SingleSegmentPathIterator sspi = new SingleSegmentPathIterator();
        segments = new ArrayList(20);
        List indexes = new ArrayList(20);
        int index = 0;
        int origIndex = -1;
        float lastMoveX = 0f;
        float lastMoveY = 0f;
        float currentX = 0f;
        float currentY = 0f;
        float[] seg = new float[6];
        int segType;

        segments.add(new PathSegment(PathIterator.SEG_MOVETO, 0f, 0f, 0f,
                                     origIndex));

        while (!pi.isDone()) {
            origIndex++;
            indexes.add(new Integer(index));
            segType = pi.currentSegment(seg);
            switch (segType) {
                case PathIterator.SEG_MOVETO:
                    segments.add(new PathSegment(segType, seg[0], seg[1],
                                                 pathLength, origIndex));
                    currentX = seg[0];
                    currentY = seg[1];
                    lastMoveX = currentX;
                    lastMoveY = currentY;
                    index++;
                    pi.next();
                    break;
                case PathIterator.SEG_LINETO:
                    pathLength += Point2D.distance(currentX, currentY, seg[0],
                                                   seg[1]);
                    segments.add(new PathSegment(segType, seg[0], seg[1],
                                                 pathLength, origIndex));
                    currentX = seg[0];
                    currentY = seg[1];
                    index++;
                    pi.next();
                    break;
                case PathIterator.SEG_CLOSE:
                    pathLength += Point2D.distance(currentX, currentY,
                                                   lastMoveX, lastMoveY);
                    segments.add(new PathSegment(PathIterator.SEG_LINETO,
                                                 lastMoveX, lastMoveY,
                                                 pathLength, origIndex));
                    currentX = lastMoveX;
                    currentY = lastMoveY;
                    index++;
                    pi.next();
                    break;
                default:
                    sspi.setPathIterator(pi, currentX, currentY);
                    FlatteningPathIterator fpi =
                        new FlatteningPathIterator(sspi, 0.01f);
                    while (!fpi.isDone()) {
                        segType = fpi.currentSegment(seg);
                        if (segType == PathIterator.SEG_LINETO) {
                            pathLength += Point2D.distance(currentX, currentY,
                                                           seg[0], seg[1]);
                            segments.add(new PathSegment(segType, seg[0],
                                                         seg[1], pathLength,
                                                         origIndex));
                            currentX = seg[0];
                            currentY = seg[1];
                            index++;
                        }
                        fpi.next();
                    }
            }
        }
        segmentIndexes = new int[indexes.size()];
        for (int i = 0; i < segmentIndexes.length; i++) {
            segmentIndexes[i] = ((Integer) indexes.get(i)).intValue();
        }
        initialised = true;
    }

    /**
     * Returns the number of segments in the path.
     */
    public int getNumberOfSegments() {
        if (!initialised) {
            initialise();
        }
        return segmentIndexes.length;
    }

    /**
     * Returns the length at the start of the segment given by the specified
     * index.
     */
    public float getLengthAtSegment(int index) {
        if (!initialised) {
            initialise();
        }
        if (index <= 0) {
            return 0;
        }
        if (index >= segmentIndexes.length) {
            return pathLength;
        }
        PathSegment seg = (PathSegment) segments.get(segmentIndexes[index]);
        return seg.getLength();
    }

    /**
     * Returns the index of the segment at the given distance along the path.
     */
    public int segmentAtLength(float length) {
        int upperIndex = findUpperIndex(length);
        if (upperIndex == -1) {
            // Length is off the end of the path.
            return -1;
        }

        if (upperIndex == 0) {
            // Length was probably zero, so return the upper segment.
            PathSegment upper = (PathSegment) segments.get(upperIndex);
            return upper.getIndex();
        }

        PathSegment lower = (PathSegment) segments.get(upperIndex - 1);
        return lower.getIndex();
    }

    /**
     * Returns the point that is the given proportion along the path segment
     * given by the specified index.
     */
    public Point2D pointAtLength(int index, float proportion) {
        if (!initialised) {
            initialise();
        }
        if (index < 0 || index >= segmentIndexes.length) {
            return null;
        }
        PathSegment seg = (PathSegment) segments.get(segmentIndexes[index]);
        float start = seg.getLength();
        float end;
        if (index == segmentIndexes.length - 1) {
            end = pathLength;
        } else {
            seg = (PathSegment) segments.get(segmentIndexes[index + 1]);
            end = seg.getLength();
        }
        return pointAtLength(start + (end - start) * proportion);
    }

    /**
     * Returns the point that is at the given length along the path.
     * @param length The length along the path
     * @return The point at the given length
     */
    public Point2D pointAtLength(float length) {
        int upperIndex = findUpperIndex(length);
        if (upperIndex == -1) {
            // Length is off the end of the path.
            return null;
        }

        PathSegment upper = (PathSegment) segments.get(upperIndex);

        if (upperIndex == 0) {
            // Length was probably zero, so return the upper point.
            return new Point2D.Float(upper.getX(), upper.getY());
        }

        PathSegment lower = (PathSegment) segments.get(upperIndex - 1);

        // Now work out where along the line would be the length.
        float offset = length - lower.getLength();

        // Compute the slope.
        double theta = Math.atan2(upper.getY() - lower.getY(),
                                  upper.getX() - lower.getX());

        float xPoint = (float) (lower.getX() + offset * Math.cos(theta));
        float yPoint = (float) (lower.getY() + offset * Math.sin(theta));

        return new Point2D.Float(xPoint, yPoint);
    }

    /**
     * Returns the slope of the path at the specified length.
     * @param index The segment number
     * @param proportion The proportion along the given segment
     * @return the angle in radians, in the range [-{@link Math#PI},
     *         {@link Math#PI}].
     */
    public float angleAtLength(int index, float proportion) {
        if (!initialised) {
            initialise();
        }
        if (index < 0 || index >= segmentIndexes.length) {
            return 0f;
        }
        PathSegment seg = (PathSegment) segments.get(segmentIndexes[index]);
        float start = seg.getLength();
        float end;
        if (index == segmentIndexes.length - 1) {
            end = pathLength;
        } else {
            seg = (PathSegment) segments.get(segmentIndexes[index + 1]);
            end = seg.getLength();
        }
        return angleAtLength(start + (end - start) * proportion);
    }

    /**
     * Returns the slope of the path at the specified length.
     * @param length The length along the path
     * @return the angle in radians, in the range [-{@link Math#PI},
     *         {@link Math#PI}].
     */
    public float angleAtLength(float length) {
        int upperIndex = findUpperIndex(length);
        if (upperIndex == -1) {
            // Length is off the end of the path.
            return 0f;
        }

        PathSegment upper = (PathSegment) segments.get(upperIndex);

        if (upperIndex == 0) {
            // Length was probably zero, so return the angle between the first
            // and second segments.
            upperIndex = 1;
        }

        PathSegment lower = (PathSegment) segments.get(upperIndex - 1);

        // Compute the slope.
        return (float) Math.atan2(upper.getY() - lower.getY(),
                                  upper.getX() - lower.getX());
    }

    /**
     * Returns the index of the path segment that bounds the specified
     * length along the path.
     * @param length The length along the path
     * @return The path segment index, or -1 if there is not such segment
     */
    public int findUpperIndex(float length) {
        if (!initialised) {
            initialise();
        }

        if (length < 0 || length > pathLength) {
            // Length is outside the path, so return -1.
            return -1;
        }

        // Find the two segments that are each side of the length.
        int lb = 0;
        int ub = segments.size() - 1;
        while (lb != ub) {
            int curr = (lb + ub) >> 1;
            PathSegment ps = (PathSegment) segments.get(curr);
            if (ps.getLength() >= length) {
                ub = curr;
            } else {
                lb = curr + 1;
            }
        }
        for (;;) {
            PathSegment ps = (PathSegment) segments.get(ub);
            if (ps.getSegType() != PathIterator.SEG_MOVETO
                    || ub == segments.size() - 1) {
                break;
            }
            ub++;
        }

        int upperIndex = -1;
        int currentIndex = 0;
        int numSegments = segments.size();
        while (upperIndex <= 0 && currentIndex < numSegments) {
            PathSegment ps = (PathSegment) segments.get(currentIndex);
            if (ps.getLength() >= length
                    && ps.getSegType() != PathIterator.SEG_MOVETO) {
                upperIndex = currentIndex;
            }
            currentIndex++;
        }
        return upperIndex;
    }

    /**
     * A {@link PathIterator} that returns only the next path segment from
     * another {@link PathIterator}.
     */
    protected static class SingleSegmentPathIterator implements PathIterator {

        /**
         * The path iterator being wrapped.
         */
        protected PathIterator it;

        /**
         * Whether the single segment has been passed.
         */
        protected boolean done;

        /**
         * Whether the generated move command has been returned.
         */
        protected boolean moveDone;

        /**
         * The x coordinate of the next move command.
         */
        protected double x;

        /**
         * The y coordinate of the next move command.
         */
        protected double y;

        /**
         * Sets the path iterator to use and the initial SEG_MOVETO command
         * to return before it.
         */
        public void setPathIterator(PathIterator it, double x, double y) {
            this.it = it;
            this.x = x;
            this.y = y;
            done = false;
            moveDone = false;
        }

        public int currentSegment(double[] coords) {
            int type = it.currentSegment(coords);
            if (!moveDone) {
                coords[0] = x;
                coords[1] = y;
                return SEG_MOVETO;
            }
            return type;
        }

        public int currentSegment(float[] coords) {
            int type = it.currentSegment(coords);
            if (!moveDone) {
                coords[0] = (float) x;
                coords[1] = (float) y;
                return SEG_MOVETO;
            }
            return type;
        }

        public int getWindingRule() {
            return it.getWindingRule();
        }

        public boolean isDone() {
            return done || it.isDone();
        }

        public void next() {
            if (!done) {
                if (!moveDone) {
                    moveDone = true;
                } else {
                    it.next();
                    done = true;
                }
            }
        }
    }

    /**
     * A single path segment in the flattened version of the path.
     * This is a local helper class. PathSegment-objects are stored in
     * the {@link PathLength#segments} - list.
     * This is used as an immutable value-object.
     */
    protected static class PathSegment {

        /**
         * The path segment type.
         */
        protected final int segType;

        /**
         * The x coordinate of the path segment.
         */
        protected float x;

        /**
         * The y coordinate of the path segment.
         */
        protected float y;

        /**
         * The length of the path segment, accumulated from the start.
         */
        protected float length;

        /**
         * The index of the original path segment this flattened segment is a
         * part of.
         */
        protected int index;

        /**
         * Creates a new PathSegment with the specified parameters.
         * @param segType The segment type
         * @param x The x coordinate
         * @param y The y coordinate
         * @param len The segment length
         * @param idx The index of the original path segment this flattened
         *            segment is a part of
         */
        PathSegment(int segType, float x, float y, float len, int idx) {
            this.segType = segType;
            this.x = x;
            this.y = y;
            this.length = len;
            this.index = idx;
        }

        /**
         * Returns the segment type.
         */
        public int getSegType() {
            return segType;
        }

        /**
         * Returns the x coordinate of the path segment.
         */
        public float getX() {
            return x;
        }

        /**
         * Sets the x coordinate of the path segment.
         */
        public void setX(float v) {
            x = v;
        }

        /**
         * Returns the y coordinate of the path segment.
         */
        public float getY() {
            return y;
        }

        /**
         * Sets the y coordinate of the path segment.
         */
        public void setY(float v) {
            y = v;
        }

        /**
         * Returns the length of the path segment.
         */
        public float getLength() {
            return length;
        }

        /**
         * Sets the length of the path segment.
         */
        public void setLength(float v) {
            length = v;
        }

        /**
         * Returns the segment index.
         */
        public int getIndex() {
            return index;
        }

        /**
         * Sets the segment index.
         */
        public void setIndex(int v) {
            index = v;
        }
    }
}
