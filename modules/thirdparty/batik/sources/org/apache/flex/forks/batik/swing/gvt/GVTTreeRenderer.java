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
package org.apache.flex.forks.batik.swing.gvt;

import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import org.apache.flex.forks.batik.bridge.InterruptedBridgeException;
import org.apache.flex.forks.batik.gvt.renderer.ImageRenderer;
import org.apache.flex.forks.batik.util.EventDispatcher;
import org.apache.flex.forks.batik.util.EventDispatcher.Dispatcher;
import org.apache.flex.forks.batik.util.HaltingThread;

/**
 * This class represents an object which renders asynchroneaously
 * a GVT tree.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: GVTTreeRenderer.java 475477 2006-11-15 22:44:28Z cam $
 */
public class GVTTreeRenderer extends HaltingThread {

    /**
     * The renderer used to paint.
     */
    protected ImageRenderer renderer;

    /**
     * The area of interest.
     */
    protected Shape areaOfInterest;

    /**
     * The buffer width.
     */
    protected int width;

    /**
     * The buffer height.
     */
    protected int height;

    /**
     * The user to device transform.
     */
    protected AffineTransform user2DeviceTransform;

    /**
     * Whether to enable the double buffering.
     */
    protected boolean doubleBuffering;

    /**
     * The listeners.
     */
    protected List listeners = Collections.synchronizedList(new LinkedList());

    /**
     * Creates a new GVTTreeRenderer.
     * @param r The renderer to use to paint.
     * @param usr2dev The user to device transform.
     * @param dbuffer Whether the double buffering should be enabled.
     * @param aoi The area of interest in the renderer space units.
     * @param width The offscreen buffer width.
     * @param height The offscreen buffer height.
     */
    public GVTTreeRenderer(ImageRenderer r, AffineTransform usr2dev,
                           boolean dbuffer,
                           Shape aoi, int width, int height) {
        renderer = r;
        areaOfInterest = aoi;
        user2DeviceTransform = usr2dev;
        doubleBuffering = dbuffer;
        this.width = width;
        this.height = height;
    }

    /**
     * Runs this renderer.
     */
    public void run() {
        GVTTreeRendererEvent ev = new GVTTreeRendererEvent(this, null);
        try {
            fireEvent(prepareDispatcher, ev);

            renderer.setTransform(user2DeviceTransform);
            renderer.setDoubleBuffered(doubleBuffering);
            renderer.updateOffScreen(width, height);
            renderer.clearOffScreen();

            if (isHalted()) {
                fireEvent(cancelledDispatcher, ev);
                return;
            }

            ev = new GVTTreeRendererEvent(this, renderer.getOffScreen());
            fireEvent(startedDispatcher, ev);

            if (isHalted()) {
                fireEvent(cancelledDispatcher, ev);
                return;
            }

            renderer.repaint(areaOfInterest);

            if (isHalted()) {
                fireEvent(cancelledDispatcher, ev);
                return;
            }

            ev = new GVTTreeRendererEvent(this, renderer.getOffScreen());
            fireEvent(completedDispatcher, ev);
        } catch (NoClassDefFoundError e) {
            // This error was reported to happen when the rendering
            // is interrupted with JDK1.3.0rc1 Solaris.
        } catch (InterruptedBridgeException e) {
            // this sometimes happens with SVG Fonts since the glyphs are
            // not built till the rendering stage
            fireEvent(cancelledDispatcher, ev);
        } catch (ThreadDeath td) {
            fireEvent(failedDispatcher, ev);
            throw td;
        } catch (Throwable t) {
            t.printStackTrace();
            fireEvent(failedDispatcher, ev);
        }
    }

    public void fireEvent(Dispatcher dispatcher, Object event) {
        EventDispatcher.fireEvent(dispatcher, listeners, event, true);
    }

    /**
     * Adds a GVTTreeRendererListener to this GVTTreeRenderer.
     */
    public void addGVTTreeRendererListener(GVTTreeRendererListener l) {
        listeners.add(l);
    }

    /**
     * Removes a GVTTreeRendererListener from this GVTTreeRenderer.
     */
    public void removeGVTTreeRendererListener(GVTTreeRendererListener l) {
        listeners.remove(l);
    }

    static Dispatcher prepareDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((GVTTreeRendererListener)listener).gvtRenderingPrepare
                    ((GVTTreeRendererEvent)event);
            }
        };
            
    static Dispatcher startedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((GVTTreeRendererListener)listener).gvtRenderingStarted
                    ((GVTTreeRendererEvent)event);
            }
        };
            
    static Dispatcher cancelledDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((GVTTreeRendererListener)listener).gvtRenderingCancelled
                    ((GVTTreeRendererEvent)event);
            }
        };
            
    static Dispatcher completedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((GVTTreeRendererListener)listener).gvtRenderingCompleted
                    ((GVTTreeRendererEvent)event);
            }
        };
            
    static Dispatcher failedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((GVTTreeRendererListener)listener).gvtRenderingFailed
                    ((GVTTreeRendererEvent)event);
            }
        };
            

}
