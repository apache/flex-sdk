/*

   Copyright 2001-2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.bridge;

import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.util.Collection;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.RootGraphicsNode;
import org.apache.flex.forks.batik.gvt.UpdateTracker;
import org.apache.flex.forks.batik.gvt.renderer.ImageRenderer;
import org.apache.flex.forks.batik.util.EventDispatcher;
import org.apache.flex.forks.batik.util.EventDispatcher.Dispatcher;
import org.apache.flex.forks.batik.util.RunnableQueue;
import org.w3c.dom.Document;
import org.w3c.dom.events.DocumentEvent;
import org.w3c.dom.events.Event;
import org.w3c.dom.events.EventTarget;

/**
 * This class provides features to manage the update of an SVG document.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: UpdateManager.java,v 1.38 2005/03/27 08:58:30 cam Exp $
 */
public class UpdateManager  {

    static final long MIN_REPAINT_TIME;
    static {
        long value = 20;
        try {
            String s = System.getProperty
            ("org.apache.flex.forks.batik.min_repaint_time", "20");
            value = Long.parseLong(s);
        } catch (SecurityException se) {
        } catch (NumberFormatException nfe){
        } finally {
            MIN_REPAINT_TIME = value;
        }
    }

    /**
     * The bridge context.
     */
    protected BridgeContext bridgeContext;
    
    /**
     * The document to manage.
     */
    protected Document document;

    /**
     * The update RunnableQueue.
     */
    protected RunnableQueue updateRunnableQueue;

    /**
     * The RunHandler for the RunnableQueue.
     */
    protected RunnableQueue.RunHandler runHandler;

    /**
     * Whether the update manager is running.
     */
    protected boolean running;

    /**
     * Whether the suspend() method was called.
     */
    protected boolean suspendCalled;

    /**
     * The listeners.
     */
    protected List listeners = Collections.synchronizedList(new LinkedList());

    /**
     * The scripting environment.
     */
    protected ScriptingEnvironment scriptingEnvironment;

    /**
     * The repaint manager.
     */
    protected RepaintManager repaintManager;

    /**
     * The update tracker.
     */
    protected UpdateTracker updateTracker;

    /**
     * The GraphicsNode whose updates are to be tracked.
     */
    protected GraphicsNode graphicsNode;

    /**
     * Whether the manager was started.
     */
    protected boolean started;

    /**
     * Creates a new update manager.
     * @param ctx The bridge context.
     * @param gn GraphicsNode whose updates are to be tracked.
     * @param doc The document to manage.
     */
    public UpdateManager(BridgeContext ctx,
                         GraphicsNode gn,
                         Document doc) {
        bridgeContext = ctx;
        bridgeContext.setUpdateManager(this);

        document = doc;

        updateRunnableQueue = RunnableQueue.createRunnableQueue();
        runHandler = createRunHandler();
        updateRunnableQueue.setRunHandler(runHandler);

        graphicsNode = gn;

        scriptingEnvironment = new ScriptingEnvironment(ctx);
    }

    /**
     * Dispatches an 'SVGLoad' event to the document.
     */
    public synchronized void dispatchSVGLoadEvent()
        throws InterruptedException {
        scriptingEnvironment.loadScripts();
        scriptingEnvironment.dispatchSVGLoadEvent();
    }

    /**
     * Dispatches an "SVGZoom" event to the document.
     */
    public void dispatchSVGZoomEvent()
        throws InterruptedException {
        scriptingEnvironment.dispatchSVGZoomEvent();
    }

    /**
     * Dispatches an "SVGZoom" event to the document.
     */
    public void dispatchSVGScrollEvent()
        throws InterruptedException {
        scriptingEnvironment.dispatchSVGScrollEvent();
    }

    /**
     * Dispatches an "SVGZoom" event to the document.
     */
    public void dispatchSVGResizeEvent()
        throws InterruptedException {
        scriptingEnvironment.dispatchSVGResizeEvent();
    }

    /**
     * Finishes the UpdateManager initialization.
     */
    public void manageUpdates(final ImageRenderer r) {
        updateRunnableQueue.preemptLater(new Runnable() {
                public void run() {
                    synchronized (UpdateManager.this) {
                        running = true;
        
                        updateTracker = new UpdateTracker();
                        RootGraphicsNode root = graphicsNode.getRoot();
                        if (root != null){
                            root.addTreeGraphicsNodeChangeListener
                                (updateTracker);
                        }

                        repaintManager = new RepaintManager(r);

                        // Send the UpdateManagerStarted event.
                        UpdateManagerEvent ev = new UpdateManagerEvent
                            (UpdateManager.this, null, null);
                        fireEvent(startedDispatcher, ev);
                        started = true;
                    }
                }
            });
        resume();
    }


    /**
     * Returns the bridge context.
     */
    public BridgeContext getBridgeContext() {
        return bridgeContext;
    }

    /**
     * Returns the update RunnableQueue.
     */
    public RunnableQueue getUpdateRunnableQueue() {
        return updateRunnableQueue;
    }

    /**
     * Returns the repaint manager.
     */
    public RepaintManager getRepaintManager() {
        return repaintManager;
    }

    /**
     * Returns the GVT update tracker.
     */
    public UpdateTracker getUpdateTracker() {
        return updateTracker;
    }

    /**
     * Returns the current Document.
     */
    public Document getDocument() {
        return document;
    }

    /**
     * Returns the scripting environment.
     */
    public ScriptingEnvironment getScriptingEnvironment() {
        return scriptingEnvironment;
    }

    /**
     * Tells whether the update manager is currently running.
     */
    public synchronized boolean isRunning() {
        return running;
    }

    /**
     * Suspends the update manager.
     */
    public synchronized void suspend() {
        // System.err.println("Suspend: " + suspendCalled + " : " + running);
        if (updateRunnableQueue.getQueueState() == RunnableQueue.RUNNING) {
            updateRunnableQueue.suspendExecution(false);
        }
        suspendCalled = true;
    }

    /**
     * Resumes the update manager.
     */
    public synchronized void resume() {
        // System.err.println("Resume: " + suspendCalled + " : " + running);

        // if (suspendCalled) {
        //     UpdateManagerEvent ev = new UpdateManagerEvent
        //         (this, null, null);
        //     // FIXX: Must happen in a different thread!
        //     fireEvent(suspendedDispatcher, ev); 
        //     fireEvent(resumedDispatcher, ev);
        // }
        if (updateRunnableQueue.getQueueState() != RunnableQueue.RUNNING) {
            updateRunnableQueue.resumeExecution();
        }
    }

    /**
     * Interrupts the manager tasks.
     */
    public synchronized void interrupt() {
        if (updateRunnableQueue.getThread() == null)
            return;

          // Preempt to cancel the pending tasks
        updateRunnableQueue.preemptLater(new Runnable() {
                public void run() {
                    synchronized (UpdateManager.this) {
                        if (started) {
                            dispatchSVGUnLoadEvent();
                        } else {
                            running = false;
                            scriptingEnvironment.interrupt();
                            updateRunnableQueue.getThread().halt();
                        }
                    }
                }
            });
        resume();
    }

    /**
     * Dispatches an 'SVGUnLoad' event to the document.
     * This method interrupts the update manager threads.
     * NOTE: this method must be called outside the update thread.
     */
    public void dispatchSVGUnLoadEvent() {
        if (!started) {
            throw new IllegalStateException("UpdateManager not started.");
        }

        // Invoke first to cancel the pending tasks
        updateRunnableQueue.preemptLater(new Runnable() {
                public void run() {
                    synchronized (UpdateManager.this) {
                        Event evt =
                            ((DocumentEvent)document).createEvent("SVGEvents");
                        evt.initEvent("SVGUnload", false, false);
                        ((EventTarget)(document.getDocumentElement())).
                            dispatchEvent(evt);
                        running = false;

                        // Now shut everything down and disconnect
                        // everything before we send the 
                        // UpdateMangerStopped event.
                        scriptingEnvironment.interrupt();
                        updateRunnableQueue.getThread().halt();
                        bridgeContext.dispose();

                        // Send the UpdateManagerStopped event.
                        UpdateManagerEvent ev = new UpdateManagerEvent
                            (UpdateManager.this, null, null);
                        fireEvent(stoppedDispatcher, ev);
                    }
                }
            });
        resume();
    }

    /**
     * Updates the rendering buffer.  Only to be called from the
     * update thread.
     * @param u2d The user to device transform.
     * @param dbr Whether the double buffering should be used.
     * @param aoi The area of interest in the renderer space units.
     * @param width The offscreen buffer width.
     * @param height The offscreen buffer height.
     */
    public void updateRendering(AffineTransform u2d,
                                boolean dbr,
                                Shape aoi,
                                int width,
                                int height) {
        repaintManager.setupRenderer(u2d,dbr,aoi,width,height);
        List l = new ArrayList(1);
        l.add(aoi);
        updateRendering(l, false);
    }

    /**
     * Updates the rendering buffer.  Only to be called from the
     * update thread.
     * @param u2d The user to device transform.
     * @param dbr Whether the double buffering should be used.
     * @param cpt If the canvas painting transform should be cleared
     *            when the update complets
     * @param aoi The area of interest in the renderer space units.
     * @param width The offscreen buffer width.
     * @param height The offscreen buffer height.
     */
    public void updateRendering(AffineTransform u2d,
                                boolean dbr,
                                boolean cpt,
                                Shape aoi,
                                int width,
                                int height) {
        repaintManager.setupRenderer(u2d,dbr,aoi,width,height);
        List l = new ArrayList(1);
        l.add(aoi);
        updateRendering(l, cpt);
    }

    /**
     * Updates the rendering buffer.
     * @param areas List of areas of interest in rederer space units.
     * @param clearPaintingTransform Indicates if the painting transform
     *        should be cleared as a result of this update.
     */
    protected void updateRendering(List areas, 
                                   boolean clearPaintingTransform) {
        try {
            UpdateManagerEvent ev = new UpdateManagerEvent
                (this, repaintManager.getOffScreen(), null);
            fireEvent(updateStartedDispatcher, ev);

            Collection c = repaintManager.updateRendering(areas);
            List l = new ArrayList(c);

            ev = new UpdateManagerEvent
                (this, repaintManager.getOffScreen(), 
                 l, clearPaintingTransform);
            fireEvent(updateCompletedDispatcher, ev);
        } catch (ThreadDeath td) {
            UpdateManagerEvent ev = new UpdateManagerEvent
                (this, null, null);
            fireEvent(updateFailedDispatcher, ev);
            throw td;
        } catch (Throwable t) {
            UpdateManagerEvent ev = new UpdateManagerEvent
                (this, null, null);
            fireEvent(updateFailedDispatcher, ev);
        }
    }

    /**
     * This tracks when the rendering first got 'out of date'
     * with respect to the document.
     */
    long outOfDateTime=0;

    /**
     * Repaints the dirty areas, if needed.
     */
    protected void repaint() {
        if (!updateTracker.hasChanged()) 
            return;
        long ctime = System.currentTimeMillis();
        if (ctime-outOfDateTime < MIN_REPAINT_TIME) {
            // We very recently did a repaint check if other 
            // repaint runnables are pending.
            synchronized (updateRunnableQueue.getIteratorLock()) {
                Iterator i = updateRunnableQueue.iterator();
                while (i.hasNext())
                    if (!(i.next() instanceof NoRepaintRunnable))
                        // have a pending repaint runnable so we
                        // will skip this repaint and we will let 
                        // the next one pick it up.
                        return;
                
            }
        }
        
        List dirtyAreas = updateTracker.getDirtyAreas();
        updateTracker.clear();
        if (dirtyAreas != null) {
            updateRendering(dirtyAreas, false);
        }
        outOfDateTime = 0;
    }


    /**
     * Adds a UpdateManagerListener to this UpdateManager.
     */
    public void addUpdateManagerListener(UpdateManagerListener l) {
        listeners.add(l);
    }

    /**
     * Removes a UpdateManagerListener from this UpdateManager.
     */
    public void removeUpdateManagerListener(UpdateManagerListener l) {
        listeners.remove(l);
    }

    protected void fireEvent(Dispatcher dispatcher, Object event) {
        EventDispatcher.fireEvent(dispatcher, listeners, event, false);
    }


    /**
     * Dispatches a UpdateManagerEvent to notify that the manager was
     * started
     */
    static Dispatcher startedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((UpdateManagerListener)listener).managerStarted
                    ((UpdateManagerEvent)event);
            }
        };

    /**
     * Dispatches a UpdateManagerEvent to notify that the manager was
     * stopped.
     */
    static Dispatcher stoppedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((UpdateManagerListener)listener).managerStopped
                    ((UpdateManagerEvent)event);
            }
        };

    /**
     * Dispatches a UpdateManagerEvent to notify that the manager was
     * suspended.
     */
    static Dispatcher suspendedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((UpdateManagerListener)listener).managerSuspended
                    ((UpdateManagerEvent)event);
            }
        };

    /**
     * Dispatches a UpdateManagerEvent to notify that the manager was
     * resumed.
     */
    static Dispatcher resumedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((UpdateManagerListener)listener).managerResumed
                    ((UpdateManagerEvent)event);
            }
        };

    /**
     * Dispatches a UpdateManagerEvent to notify that an update
     * started
     */
    static Dispatcher updateStartedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((UpdateManagerListener)listener).updateStarted
                    ((UpdateManagerEvent)event);
            }
        };

    /**
     * Dispatches a UpdateManagerEvent to notify that an update
     * completed
     */
    static Dispatcher updateCompletedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((UpdateManagerListener)listener).updateCompleted
                    ((UpdateManagerEvent)event);
            }
        };

    /**
     * Dispatches a UpdateManagerEvent to notify that an update
     * failed
     */
    static Dispatcher updateFailedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((UpdateManagerListener)listener).updateFailed
                    ((UpdateManagerEvent)event);
            }
        };



    // RunnableQueue.RunHandler /////////////////////////////////////////
    protected RunnableQueue.RunHandler createRunHandler() {
        return new UpdateManagerRunHander();
    }

    protected class UpdateManagerRunHander 
        extends RunnableQueue.RunHandlerAdapter {

        public void runnableStart(RunnableQueue rq, Runnable r) { 
            if (running && !(r instanceof NoRepaintRunnable)) {
                // Mark the document as updated when the
                // runnable starts.
                if (outOfDateTime == 0)
                    outOfDateTime = System.currentTimeMillis();
            }
        }
        

        /**
         * Called when the given Runnable has just been invoked and
         * has returned.
         */
        public void runnableInvoked(RunnableQueue rq, Runnable r) {
            if (running && !(r instanceof NoRepaintRunnable)) {
                repaint();
            }
        }
        
        /**
         * Called when the execution of the queue has been suspended.
         */
        public void executionSuspended(RunnableQueue rq) {
            synchronized (UpdateManager.this) {
                // System.err.println("Suspended: " + suspendCalled);
                if (suspendCalled) {
                    running = false;
                    UpdateManagerEvent ev = new UpdateManagerEvent
                        (this, null, null);
                    fireEvent(suspendedDispatcher, ev);
                }
            }
        }
        
        /**
         * Called when the execution of the queue has been resumed.
         */
        public void executionResumed(RunnableQueue rq) {
            synchronized (UpdateManager.this) {
                // System.err.println("Resumed: " + suspendCalled + 
                //                    " : " + running);
                if (suspendCalled && !running) {
                    running = true;
                    suspendCalled = false;

                    UpdateManagerEvent ev = new UpdateManagerEvent
                        (this, null, null);
                    fireEvent(resumedDispatcher, ev);
                }
            }
        }
    }
}
