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
package org.apache.flex.forks.batik.ext.awt.image.renderable;

import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.awt.geom.Rectangle2D;
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderContext;
import java.awt.image.renderable.RenderableImage;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Vector;

import org.apache.flex.forks.batik.ext.awt.image.PadMode;
import org.apache.flex.forks.batik.ext.awt.image.rendered.CachableRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.PadRed;
import org.apache.flex.forks.batik.ext.awt.image.rendered.RenderedImageCachableRed;

/**
 * This is an abstract base class that takes care of most of the
 * normal issues surrounding the implementation of the RenderableImage
 * interface.  It tries to make no assumptions about the subclass
 * implementation.
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: AbstractRable.java 489226 2006-12-21 00:05:36Z cam $
 */
public abstract class AbstractRable implements Filter {

    protected Vector srcs;
    protected Map    props = new HashMap();
    protected long   stamp = 0;

    /**
     * void constructor. The subclass must call one of the
     * flavors of init before the object becomes usable.
     * This is useful when the proper parameters to the init
     * method need to be computed in the subclasses constructor.
     */
    protected AbstractRable() {
        srcs = new Vector();
    }

    /**
     * Construct an Abstract Rable from src.
     * @param src will be the first (and only) member of the srcs
     * Vector. The bounds of src are also used to set the bounds of
     * this renderable.
     */
    protected AbstractRable(Filter src) {
        init(src, null);
    }

    /**
     * Construct an Abstract Rable from src and props.
     * @param src will also be set as the first (and only) member of
     * the srcs Vector.
     * @param props use to initialize the properties on this renderable image.
     */
    protected AbstractRable(Filter src, Map props) {
        init(src, props);
    }

    /**
     * Construct an Abstract Rable from a list of sources.
     * @param srcs This is used to initialize the srcs Vector.
     * The bounds of this renderable will be the union of the bounds
     * of all the sources in srcs.  All the members of srcs must be
     * CacheableRable otherwise an error will be thrown.
     */
    protected AbstractRable(List srcs) {
        this(srcs, null);
    }

    /**
     * Construct an Abstract Rable from a list of sources, and bounds.
     * @param srcs This is used to initialize the srcs Vector.  All
     * the members of srcs must be CacheableRable otherwise an error
     * will be thrown.
     * @param props use to initialize the properties on this renderable image.
     */
    protected AbstractRable(List srcs, Map props) {
        init(srcs, props);
    }

    /**
     * Increments the time stamp.  This should be called when ever
     * the image changes in such a way that cached output should be
     * discarded.
     */
    public final void touch() { stamp++; }

      /**
       * Returns the current modification timestamp on this Renderable
       * node.  This value will change whenever cached output data becomes
       * invalid.
       * @return Current modification timestamp value.
       */
    public long getTimeStamp() { return stamp; }

    /**
     * Initialize an Abstract Rable from src, bounds and props.  This
     * can be called long after the object is constructed to reset the
     * state of the Renderable.
     * @param src will become the first (and only) member of the srcs Vector.
     */
    protected void init(Filter src) {
        touch();

        this.srcs   = new Vector(1);
        if (src != null) {
            this.srcs.add(src);
        }
    }

    /**
     * Initialize an Abstract Rable from src, bounds and props.  This
     * can be called long after the object is constructed to reset the
     * state of the Renderable.
     * @param src will also be set as the first (and only) member of
     * the srcs Vector.
     * @param props use to set the properties on this renderable image.
     * Always clears the current properties (even if null).
     */
    protected void init(Filter src, Map props) {
        init (src);
        if(props != null){
            this.props.putAll(props);
        }
    }

    /**
     * Initialize an Abstract Rable from a list of sources, and
     * possibly a bounds.  This can be called long after the object is
     * constructed to reset the state of the Renderable.
     * @param srcs Used the create a new srcs Vector (old sources are dropped).
     */
    protected void init(List srcs) {
        touch();
        this.srcs   = new Vector(srcs);
    }

    /**
     * Initialize an Abstract Rable from a list of sources, and
     * possibly a bounds.  This can be called long after the object is
     * constructed to reset the state of the Renderable.
     * @param srcs Used the create a new srcs Vector (old sources are dropped).
     * @param props use to set the properties on this renderable image.
     * Always clears the current properties (even if null).
     */
    protected void init(List srcs, Map props) {
        init (srcs);
        if(props != null)
            this.props.putAll(props);
    }

    public Rectangle2D getBounds2D() {
        Rectangle2D bounds = null;
        if (this.srcs.size() != 0) {
            Iterator i = srcs.iterator();
            Filter src = (Filter)i.next();
            bounds = (Rectangle2D)src.getBounds2D().clone();
            Rectangle2D r;
            while (i.hasNext()) {
                src = (Filter)i.next();
                r = src.getBounds2D();
                Rectangle2D.union(bounds, r, bounds);
            }
        }
        return bounds;
    }

    public Vector getSources() {
        return srcs;
    }

    public RenderedImage createDefaultRendering() {
        return createScaledRendering(100, 100, null);
    }

    public RenderedImage createScaledRendering(int w, int h,
                                           RenderingHints hints) {
        float sX = w/getWidth();
        float sY = h/getHeight();
        float scale = Math.min(sX, sY);

        AffineTransform at = AffineTransform.getScaleInstance(scale, scale);
        RenderContext rc = new RenderContext(at, hints);

        float dX = (getWidth()*scale)-w;
        float dY = (getHeight()*scale)-h;

        RenderedImage ri = createRendering(rc);
        CachableRed cr = RenderedImageCachableRed.wrap(ri);
        return new PadRed(cr, new Rectangle((int)(dX/2), (int)(dY/2), w, h),
                          PadMode.ZERO_PAD, null);
    }

    public float getMinX() {
        return (float)getBounds2D().getX();
    }
    public float getMinY() {
        return (float)getBounds2D().getY();
    }
    public float getWidth() {
        return (float)getBounds2D().getWidth();
    }
    public float getHeight() {
        return (float)getBounds2D().getHeight();
    }

    public Object getProperty(String name) {
        Object ret = props.get(name);
        if (ret != null) return ret;
        Iterator i = srcs.iterator();
        while (i.hasNext()) {
            RenderableImage ri = (RenderableImage)i.next();
            ret = ri.getProperty(name);
            if (ret != null) return ret;
        }
        return null;
    }

    public String [] getPropertyNames() {
        Set keys = props.keySet();
        Iterator iter = keys.iterator();
        String[] ret  = new String[keys.size()];
        int i=0;
        while (iter.hasNext()) {
            ret[i++] = (String)iter.next();
        }

        iter = srcs.iterator();
        while (iter.hasNext()) {
            RenderableImage ri = (RenderableImage)iter.next();
            String [] srcProps = ri.getPropertyNames();
            if (srcProps.length != 0) {
                String [] tmp = new String[ret.length+srcProps.length];
                System.arraycopy(ret,0,tmp,0,ret.length);
                System.arraycopy(tmp,ret.length,srcProps,0,srcProps.length);
                ret = tmp;
            }
        }

        return ret;
    }

    public boolean isDynamic() { return false; }

    public Shape getDependencyRegion(int srcIndex,
                                     Rectangle2D outputRgn) {
        if ((srcIndex < 0) || (srcIndex > srcs.size()))
            throw new IndexOutOfBoundsException
                ("Nonexistant source requested.");

        // We only depend on our source for stuff that is inside
        // our bounds...
        Rectangle2D srect = (Rectangle2D)outputRgn.clone();
        Rectangle2D bounds = getBounds2D();

        // Return empty rect if they don't intersect.
        if ( ! bounds.intersects(srect) )
            return new Rectangle2D.Float();

        Rectangle2D.intersect(srect, bounds, srect);
        return srect;
    }

    public Shape getDirtyRegion(int srcIndex,
                                Rectangle2D inputRgn) {
        if ((srcIndex < 0) || (srcIndex > srcs.size()))
            throw new IndexOutOfBoundsException
                ("Nonexistant source requested.");

          // Changes in the input region don't propogate outside our
          // bounds.
        Rectangle2D drect = (Rectangle2D)inputRgn.clone();
        Rectangle2D bounds = getBounds2D();

        // Return empty rect if they don't intersect.
        if ( ! bounds.intersects(drect) )
            return new Rectangle2D.Float();

        Rectangle2D.intersect(drect, bounds, drect);
        return drect;
    }


    /* left for subclass:
       public RenderedImage createRendering(RenderContext rc);
    */
}
