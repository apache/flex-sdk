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
package org.apache.flex.forks.batik.bridge;

import java.awt.Shape;
import java.awt.geom.AffineTransform;
import java.util.Collection;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import org.apache.flex.forks.batik.bridge.svg12.DefaultXBLManager;
import org.apache.flex.forks.batik.bridge.svg12.SVG12BridgeContext;
import org.apache.flex.forks.batik.bridge.svg12.SVG12ScriptingEnvironment;
import org.apache.flex.forks.batik.dom.events.AbstractEvent;
import org.apache.flex.forks.batik.dom.svg.SVGOMDocument;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.gvt.RootGraphicsNode;
import org.apache.flex.forks.batik.gvt.UpdateTracker;
import org.apache.flex.forks.batik.gvt.renderer.ImageRenderer;
import org.apache.flex.forks.batik.util.EventDispatcher;
import org.apache.flex.forks.batik.util.XMLConstants;
import org.apache.flex.forks.batik.util.EventDispatcher.Dispatcher;
import org.apache.flex.forks.batik.util.RunnableQueue;
import org.w3c.dom.Document;
import org.w3c.dom.events.DocumentEvent;
import org.w3c.dom.events.EventTarget;

/**
 * This class provides features to manage the update of an SVG document.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: UpdateManager.java 501843 2007-01-31 13:52:12Z deweese $
 */
public class UpdateManager  {

    static final int MIN_REPAINT_TIME;
    static {
        int value = 20;
        try {
            String s = System.getProperty
            ("org.apache.flex.forks.batik.min_repaint_time", "20");
            value = Integer.parseInt(s);
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
    protected volatile boolean running;

    /**
     * Whether the suspend() method was called.
     */
    protected volatile boolean suspendCalled;

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
     * Array of resource documents' BridgeContexts.
     */
    protected BridgeContext[] secondaryBridgeContexts;

    /**
     * Array of resource documents' ScriptingEnvironments that should
     * have their SVGLoad event dispatched.
     */
    protected ScriptingEnvironment[] secondaryScriptingEnvironments;

    /**
     * The current minRepaintTime
     */
    protected int minRepaintTime;

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

        scriptingEnvironment = initializeScriptingEnvironment(bridgeContext);

        // Any BridgeContexts for resource documents that exist
        // when initializing the scripting environment for the
        // primary document also need to have their scripting
        // environments initialized.
        secondaryBridgeContexts =
            (BridgeContext[]) ctx.getChildContexts().clone();
        secondaryScriptingEnvironments =
            new ScriptingEnvironment[secondaryBridgeContexts.length];
        for (int i = 0; i < secondaryBridgeContexts.length; i++) {
            BridgeContext resCtx = secondaryBridgeContexts[i];
            if (!((SVGOMDocument) resCtx.getDocument()).isSVG12()) {
                continue;
            }
            resCtx.setUpdateManager(this);
            ScriptingEnvironment se = initializeScriptingEnvironment(resCtx);
            secondaryScriptingEnvironments[i] = se;
        }
        minRepaintTime = MIN_REPAINT_TIME;
    }

    public int getMinRepaintTime() {
        return minRepaintTime;
    }

    public void setMinRepaintTime(int minRepaintTime) {
        this.minRepaintTime = minRepaintTime;
    }

    /**
     * Creates an appropriate ScriptingEnvironment and XBL manager for
     * the given document.
     */
    protected ScriptingEnvironment initializeScriptingEnvironment
            (BridgeContext ctx) {
        SVGOMDocument d = (SVGOMDocument) ctx.getDocument();
        ScriptingEnvironment se;
        if (d.isSVG12()) {
            se = new SVG12ScriptingEnvironment(ctx);
            ctx.xblManager = new DefaultXBLManager(d, ctx);
            d.setXBLManager(ctx.xblManager);
        } else {
            se = new ScriptingEnvironment(ctx);
        }
        return se;
    }

    /**
     * Dispatches an 'SVGLoad' event to the document.
     */
    public synchronized void dispatchSVGLoadEvent()
            throws InterruptedException {
        dispatchSVGLoadEvent(bridgeContext, scriptingEnvironment);
        for (int i = 0; i < secondaryScriptingEnvironments.length; i++) {
            BridgeContext ctx = secondaryBridgeContexts[i];
            if (!((SVGOMDocument) ctx.getDocument()).isSVG12()) {
                continue;
            }
            ScriptingEnvironment se = secondaryScriptingEnvironments[i];
            dispatchSVGLoadEvent(ctx, se);
        }
        secondaryBridgeContexts = null;
        secondaryScriptingEnvironments = null;
    }

    /**
     * Dispatches an 'SVGLoad' event to the document.
     */
    protected void dispatchSVGLoadEvent(BridgeContext ctx,
                                        ScriptingEnvironment se) {
        se.loadScripts();
        se.dispatchSVGLoadEvent();
        if (ctx.isSVG12() && ctx.xblManager != null) {
            SVG12BridgeContext ctx12 = (SVG12BridgeContext) ctx;
            ctx12.addBindingListener();
            ctx12.xblManager.startProcessing();
        }
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
    public void interrupt() {
        Runnable r = new Runnable() {
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
            };
        try {
            // Preempt to cancel the pending tasks
            updateRunnableQueue.preemptLater(r);
            updateRunnableQueue.resumeExecution(); // ensure runnable runs...
        } catch (IllegalStateException ise) {
            // Not running, which is probably ok since that's what we
            // wanted.  Might be an issue if SVGUnload wasn't issued...
        }
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
                        AbstractEvent evt = (AbstractEvent)
                            ((DocumentEvent)document).createEvent("SVGEvents");
                        String type;
                        if (bridgeContext.isSVG12()) {
                            type = "unload";
                        } else {
                            type = "SVGUnload";
                        }
                        evt.initEventNS(XMLConstants.XML_EVENTS_NAMESPACE_URI,
                                        type,
                                        false,    // canBubbleArg
                                        false);   // cancelableArg
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
        if (!updateTracker.hasChanged()) {
            // No changes, nothing to repaint.
            outOfDateTime = 0;
            return;
        }

        long ctime = System.currentTimeMillis();
        if (ctime < allResumeTime) {
            createRepaintTimer();
            return;
        }
        if (allResumeTime > 0) {
            // All suspendRedraw requests have expired.
            releaseAllRedrawSuspension();
        }

        if (ctime-outOfDateTime < minRepaintTime) {
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
     * Users of Batik should essentially never call
     * this directly from Java.  If the Canvas is not
     * updating when you change the SVG Document it is almost
     * certainly because you are not making your changes
     * in the RunnableQueue (getUpdateRunnableQueue()).
     * You will have problems if you are not making all
     * changes to the document in the UpdateManager's
     * RunnableQueue.
     *
     * This method exists to implement the
     * 'SVGSVGElement.forceRedraw()' method.
     */
    public void forceRepaint() {
        if (!updateTracker.hasChanged()) {
            // No changes, nothing to repaint.
            outOfDateTime = 0;
            return;
        }

        List dirtyAreas = updateTracker.getDirtyAreas();
        updateTracker.clear();
        if (dirtyAreas != null) {
            updateRendering(dirtyAreas, false);
        }
        outOfDateTime = 0;
    }

    protected class SuspensionInfo {
        /**
         * The index of this redraw suspension
         */
        int index;
        /**
         * The system time in millisec that this suspension
         * will expire and redraws can resume (at least for
         * this suspension.
         */
        long resumeMilli;
        public SuspensionInfo(int index, long resumeMilli) {
            this.index = index;
            this.resumeMilli = resumeMilli;
        }
        public int getIndex() { return index; }
        public long getResumeMilli() { return resumeMilli; }
    }

    protected class RepaintTimerTask extends TimerTask {
        UpdateManager um;
        RepaintTimerTask(UpdateManager um) {
            this.um = um;
        }
        public void run() {
            RunnableQueue rq = um.getUpdateRunnableQueue();
            if (rq == null) return;
            rq.invokeLater(new Runnable() {
                    public void run() { }
                });
        }
    }

    List suspensionList = new ArrayList();
    int nextSuspensionIndex = 1;
    long allResumeTime = -1;
    Timer repaintTriggerTimer = null;
    TimerTask repaintTimerTask = null;

    void createRepaintTimer() {
        if (repaintTimerTask != null) return;
        if (allResumeTime < 0)        return;
        if (repaintTriggerTimer == null)
            repaintTriggerTimer = new Timer(true);

        long delay = allResumeTime - System.currentTimeMillis();
        if (delay < 0) delay = 0;
        repaintTimerTask = new RepaintTimerTask(this);
        repaintTriggerTimer.schedule(repaintTimerTask, delay);
        // System.err.println("CTimer delay: " + delay);
    }
    /**
     * Sets up a timer that will trigger a repaint
     * when it fires.
     * If create is true it will construct a timer even
     * if one
     */
    void resetRepaintTimer() {
        if (repaintTimerTask == null) return;
        if (allResumeTime < 0)        return;
        if (repaintTriggerTimer == null)
            repaintTriggerTimer = new Timer(true);

        long delay = allResumeTime - System.currentTimeMillis();
        if (delay < 0) delay = 0;
        repaintTimerTask = new RepaintTimerTask(this);
        repaintTriggerTimer.schedule(repaintTimerTask, delay);
        // System.err.println("Timer delay: " + delay);
    }

    int addRedrawSuspension(int max_wait_milliseconds) {
        long resumeTime = System.currentTimeMillis() + max_wait_milliseconds;
        SuspensionInfo si = new SuspensionInfo(nextSuspensionIndex++,
                                               resumeTime);
        if (resumeTime > allResumeTime) {
            allResumeTime = resumeTime;
            // System.err.println("Added AllRes Time: " + allResumeTime);
            resetRepaintTimer();
        }
        suspensionList.add(si);
        return si.getIndex();
    }

    void releaseAllRedrawSuspension() {
        suspensionList.clear();
        allResumeTime = -1;
        resetRepaintTimer();
    }

    boolean releaseRedrawSuspension(int index) {
        if (index > nextSuspensionIndex) return false;
        if (suspensionList.size() == 0) return true;

        int lo = 0, hi=suspensionList.size()-1;
        while (lo < hi) {
            int mid = (lo+hi)>>1;
            SuspensionInfo si = (SuspensionInfo)suspensionList.get(mid);
            int idx = si.getIndex();
            if      (idx == index) { lo = hi = mid; }
            else if (idx <  index) { lo = mid+1; }
            else                   { hi = mid-1; }
        }

        SuspensionInfo si = (SuspensionInfo)suspensionList.get(lo);
        int idx = si.getIndex();
        if (idx != index)
            return true;  // currently not in list but was at some point...

        suspensionList.remove(lo);
        if (suspensionList.size() == 0) {
            // No more active suspensions
            allResumeTime = -1;
            resetRepaintTimer();
        } else {
            // Check if we need to find a new 'bounding' suspension.
            long resumeTime = si.getResumeMilli();
            if (resumeTime == allResumeTime) {
                allResumeTime = findNewAllResumeTime();
                // System.err.println("New AllRes Time: " + allResumeTime);
                resetRepaintTimer();
            }
        }
        return true;
    }

    long findNewAllResumeTime() {
        long ret = -1;
        Iterator i = suspensionList.iterator();
        while (i.hasNext()) {
            SuspensionInfo si = (SuspensionInfo)i.next();
            long t = si.getResumeMilli();
            if (t > ret) ret = t;
        }
        return ret;
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
