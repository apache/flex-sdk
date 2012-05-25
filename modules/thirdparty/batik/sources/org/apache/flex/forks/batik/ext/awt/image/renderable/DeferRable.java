/*

   Copyright 2001,2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.ext.awt.image.renderable;

import java.awt.RenderingHints;
import java.awt.Shape;
import java.awt.geom.Rectangle2D;
import java.awt.image.RenderedImage;
import java.awt.image.renderable.RenderContext;
import java.util.Map;
import java.util.Vector;

/**
 * This class allows for the return of a proxy object quickly, while a
 * heavy weight object is constrcuted in a background Thread.  This
 * proxy object will then block if any methods are called on it that
 * require talking to the source object.
 *
 * This is actually a particular instance of a very general pattern
 * this is probably best represented using the Proxy class in the
 * Reflection APIs.
 */

public class DeferRable implements Filter {
    Filter      src;
    Rectangle2D bounds;
    Map         props;
    /**
     * Constructor takes nothing
     */
    public DeferRable() { 
    }

    /**
     * Key method that blocks if the src has not yet been provided.
     */
    public synchronized Filter getSource() {
        while (src == null) {
            try {
                // Wait for someone to set src.
                wait();
            }
            catch(InterruptedException ie) { 
                // Loop around again see if src is set now...
            }
        }
        return src;
    }

    /**
     * Key method that sets the src.  The source can only
     * be set once (this makes sense given the intent of the
     * class is to stand in for a real object, so swaping that
     * object isn't a good idea.
     *
     * This will wake all the threads that might be waiting for
     * the source to be set.
     */
    public synchronized void setSource(Filter src) {
        // Only let them set Source once.
        if (this.src != null) return;
        this.src    = src;
        this.bounds = src.getBounds2D();
        notifyAll();
    }

    public synchronized void setBounds(Rectangle2D bounds) {
        if (this.bounds != null) return;
        this.bounds = bounds;
        notifyAll();
    }

    public synchronized void setProperties(Map props) {
        this.props = props;
        notifyAll();
    }

    public long getTimeStamp() { 
        return getSource().getTimeStamp();
    }

    public Vector getSources() {
        return getSource().getSources();
    }

    /**
     * Forward the call (blocking until source is set if need be).
     */
    public boolean isDynamic() { 
        return getSource().isDynamic();
    }

    /**
     * Implement the baseclass method to call getSource() so
     * it will block until we have a real source.
     */
    public Rectangle2D getBounds2D() {
        synchronized(this) {
            while ((src == null) && (bounds == null))  {
                try {
                    // Wait for someone to set bounds.
                    wait();
                }
                catch(InterruptedException ie) { 
                    // Loop around again see if src is set now...
                }
            }
        }
        if (src != null)
            return src.getBounds2D();
        return bounds;
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

    /**
     * Forward the call (blocking until source is set if need be).
     */
    public Object getProperty(String name) {
        synchronized (this) {
            while ((src == null) && (props == null)) {
                try {
                    // Wait for someone to set src | props
                    wait();
                } catch(InterruptedException ie) { }
            }
        }
        if (src != null)
            return src.getProperty(name);
        return props.get(name);
    }

    /**
     * Forward the call (blocking until source is set if need be).
     */
    public String [] getPropertyNames() {
        synchronized (this) {
            while ((src == null) && (props == null)) {
                try {
                    // Wait for someone to set src | props
                    wait();
                } catch(InterruptedException ie) { }
            }
        }
        if (src != null)
            return src.getPropertyNames();

        String [] ret = new String[props.size()];
        props.keySet().toArray(ret);
        return ret;
    }

    /**
     * Forward the call (blocking until source is set if need be).
     */
    public RenderedImage createDefaultRendering() {
        return getSource().createDefaultRendering();
    }

    /**
     * Forward the call (blocking until source is set if need be).
     */
    public RenderedImage createScaledRendering(int w, int h, 
                                               RenderingHints hints) {
        return getSource().createScaledRendering(w, h, hints);
    }

    /**
     * Forward the call (blocking until source is set if need be).
     */
    public RenderedImage createRendering(RenderContext rc) {
        return getSource().createRendering(rc);
    }

    /**
     * Forward the call (blocking until source is set if need be).
     */
    public Shape getDependencyRegion(int srcIndex, 
                                     Rectangle2D outputRgn) {
        return getSource().getDependencyRegion(srcIndex, outputRgn);
    }

    /**
     * Forward the call (blocking until source is set if need be).
     */
    public Shape getDirtyRegion(int srcIndex, 
                                Rectangle2D inputRgn) {
        return getSource().getDirtyRegion(srcIndex, inputRgn);
    }
}
