/*

   Copyright 2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.swing;

import java.awt.EventQueue;
import java.awt.geom.AffineTransform;
import java.io.File;
import java.net.MalformedURLException;

import org.apache.flex.forks.batik.swing.JSVGCanvas;
import org.apache.flex.forks.batik.swing.gvt.GVTTreeRendererListener;
import org.apache.flex.forks.batik.swing.gvt.GVTTreeRendererEvent;
import org.apache.flex.forks.batik.swing.svg.SVGDocumentLoaderListener;
import org.apache.flex.forks.batik.swing.svg.SVGLoadEventDispatcherListener;
import org.apache.flex.forks.batik.swing.svg.SVGLoadEventDispatcherEvent;
import org.apache.flex.forks.batik.swing.svg.SVGDocumentLoaderEvent;
import org.apache.flex.forks.batik.swing.svg.GVTTreeBuilderListener;
import org.apache.flex.forks.batik.swing.svg.GVTTreeBuilderEvent;

import org.w3c.flex.forks.dom.svg.SVGDocument;

/**
 * One line Class Desc
 *
 * Complete Class Desc
 *
 * @author <a href="mailto:deweese@apache.org">l449433</a>
 * @version $Id: JSVGInterruptTest.java,v 1.6 2005/03/27 08:58:37 cam Exp $
 */
public class JSVGInterruptTest extends JSVGMemoryLeakTest {

    public String getName() { return "JSVGInterruptTest."+getId(); }

    public JSVGInterruptTest() {
    }

    /* JSVGCanvasHandler.Delegate Interface */
    Runnable stopRunnable;

    int state = 0;
    MyLoaderListener  loadListener   = new MyLoaderListener();
    MyBuildListener   buildListener  = new MyBuildListener();
    MyOnloadListener  onloadListener = new MyOnloadListener();
    MyRenderListener  renderListener = new MyRenderListener();

    DelayRunnable stopper = null;


    final static int COMPLETE  = 1;
    final static int CANCELLED = 2;
    final static int FAILED    = 4;
    final static int MAX_WAIT  = 40000;

    public JSVGCanvasHandler createHandler() {
        return new JSVGCanvasHandler(this, this) {
                public void runCanvas(String desc) {
                    this.desc = desc;
                    setupCanvas();

                    if ( abort) return;
                    try {
                        synchronized (renderMonitor) {
                            delegate.canvasInit(canvas);
                            if ( abort) return;
                            
                            while (!done) {
                                checkRender();
                                if ( abort) return;
                            }
                        }
                    } catch (Throwable t) {
                        t.printStackTrace();
                    } finally {
                        delegate.canvasDone(canvas);
                        dispose();
                    }
                }
                public void checkSomething(Object monitor, String errorCode) {
                    synchronized (monitor) {
                        try { monitor.wait(); }
                        catch(InterruptedException ie) { /* nothing */ }
                    }
                }
            };
    }


    public boolean canvasInit(final JSVGCanvas canvas) {
        // System.err.println("In Init");
        theCanvas = canvas;
        theFrame  = handler.getFrame();
        registerObjectDesc(canvas, "JSVGCanvas");
        registerObjectDesc(handler.getFrame(), "JFrame");

        stopRunnable = new StopRunnable(canvas);

        File f = new File(getId());
        String uri;
        try {
            uri = f.toURL().toString();
        } catch (MalformedURLException mue) {
            throw new IllegalArgumentException(mue.getMessage());
        }

        tweakIt(canvas, uri);

        return false;
    }

    public void canvasDone(JSVGCanvas canvas) {
        loadListener   = null;
        buildListener  = null;
        renderListener = null;
        onloadListener = null;
        stopper        = null;
        stopRunnable   = null;
    }

    public void tweakIt(final JSVGCanvas canvas, final String uri) {
        Thread t = new Thread() {
                public void run() {
                    int state;
                    Runnable setURI = new Runnable() {
                            public void run() {
                                canvas.setURI(uri);
                            }
                        };
                    System.err.println("Starting Load Tweak");
                    canvas.addSVGDocumentLoaderListener(loadListener);
                    state = doTweak(setURI, loadListener);
                    canvas.removeSVGDocumentLoaderListener(loadListener);
                    System.err.println("Finished Load Tweak: " + state);

                    final SVGDocument doc = canvas.getSVGDocument();
                    Runnable setDoc = new Runnable() {
                            public void run() {
                                canvas.setSVGDocument(doc);
                            }
                        };
                    System.err.println("Starting setDoc Tweak");
                    canvas.addGVTTreeBuilderListener(buildListener);
                    state = doTweak(setDoc, buildListener);
                    canvas.removeGVTTreeBuilderListener(buildListener);
                    System.err.println("Finished setDoc Tweak: " + state);

                    if (canvas.isDynamic()) {
                        System.err.println("Starting onload Tweak");
                        canvas.addSVGLoadEventDispatcherListener
                            (onloadListener);
                        state = doTweak(setDoc, onloadListener);
                        canvas.removeSVGLoadEventDispatcherListener
                            (onloadListener);
                        System.err.println("Finished onload Tweak: " + state);
                    }

                    Runnable setTrans = new Runnable() {
                            public void run() {
                                canvas.setRenderingTransform
                                    (new AffineTransform(), true);
                            }
                        };
                    System.err.println("Starting render Tweak");
                    canvas.addGVTTreeRendererListener(renderListener);
                    state = doTweak(setTrans, renderListener);
                    canvas.removeGVTTreeRendererListener(renderListener);
                    System.err.println("Finished render Tweak: " + state);
                    
                    handler.scriptDone();
                }
            };
        t.setDaemon(true);
        t.start();
    }

    public int doTweak(Runnable r, SetDelayable delayable) {
        synchronized (JSVGInterruptTest.this) {
            int delay = 0;
            int delayInc = 3;
            int delayIncInc = 4;
            int ret = 0;
            state = 0;
            while ((state & (COMPLETE | FAILED)) == 0) {
                ret |= state;
                state = 0;
                System.err.println("Tweaking: " + delay);
                delayable.setDelay(delay);
                EventQueue.invokeLater(r);
                
                long start = System.currentTimeMillis();
                long end   = start + MAX_WAIT;
                long curr  = start;
                while ((state == 0) && (curr < end)) {
                    // No 'complete' event generated yet and
                    // Still willing to wait a bit...
                    try {
                        JSVGInterruptTest.this.wait(end-curr);
                    } catch(InterruptedException ie) {
                    }
                    curr = System.currentTimeMillis();
                }
                if (state == 0) {
                    throw new IllegalArgumentException
                        ("Timed out - proabably indicates failure");
                }
                delay += delayInc + (curr-start-delay)/8;
                delayInc += delayIncInc;
            }
            ret |= state;
            return ret;
        }
    }

    
    public void triggerStopProcessing(int delay) {
        stopper = new DelayRunnable(delay, stopRunnable);
        stopper.start();
    }
    public boolean stopStopper() {
        return stopper.abort();
    }

    interface SetDelayable {
        public void setDelay(int delay);
    }

    class MyLoaderListener implements SVGDocumentLoaderListener, SetDelayable {
        int delay = 0;
        public void setDelay(int delay) { this.delay = delay; }
        public void documentLoadingStarted(SVGDocumentLoaderEvent e) {
            triggerStopProcessing(delay);
        }
        public void documentLoadingCompleted(SVGDocumentLoaderEvent e) {
            stopStopper();
            synchronized (JSVGInterruptTest.this) {
                state |= COMPLETE;
                JSVGInterruptTest.this.notifyAll();
            }
        }
        public void documentLoadingCancelled(SVGDocumentLoaderEvent e) {
            synchronized (JSVGInterruptTest.this) {
                state |= CANCELLED;
                JSVGInterruptTest.this.notifyAll();
            }
        }
        public void documentLoadingFailed(SVGDocumentLoaderEvent e) {
            synchronized (JSVGInterruptTest.this) {
                state |= FAILED;
                JSVGInterruptTest.this.notifyAll();
            }
        }
    }

    class MyBuildListener implements GVTTreeBuilderListener, SetDelayable {
        int delay = 0;
        public void setDelay(int delay) { this.delay = delay; }
        public void gvtBuildStarted(GVTTreeBuilderEvent e) {
            // System.err.println("Build Start: " + e.getSource());
            triggerStopProcessing(delay);
        }
        public void gvtBuildCompleted(GVTTreeBuilderEvent e) {
            stopStopper();
            // System.err.println("Build Complete: " + e.getSource());
            synchronized (JSVGInterruptTest.this) {
                state |= COMPLETE;
                JSVGInterruptTest.this.notifyAll();
            }
        }
        public void gvtBuildCancelled(GVTTreeBuilderEvent e) {
            // System.err.println("Build Cancelled");
            synchronized (JSVGInterruptTest.this) {
                state |= CANCELLED;
                JSVGInterruptTest.this.notifyAll();
            }
        }
        public void gvtBuildFailed(GVTTreeBuilderEvent e) {
            // System.err.println("Build Failed");
            synchronized (JSVGInterruptTest.this) {
                state |= FAILED;
                JSVGInterruptTest.this.notifyAll();
            }
        }
    }

    class MyOnloadListener 
        implements SVGLoadEventDispatcherListener, SetDelayable {
        int delay = 0;
        public void setDelay(int delay) { this.delay = delay; }
        public void svgLoadEventDispatchStarted
            (SVGLoadEventDispatcherEvent e) {
            // System.err.println("Onload Start: " + e.getSource());
                triggerStopProcessing(delay);
            }
            public void svgLoadEventDispatchCompleted
                (SVGLoadEventDispatcherEvent e) {
                stopStopper();
                // System.err.println("Onload Complete: " + e.getSource());
                synchronized (JSVGInterruptTest.this) {
                    state |= COMPLETE;
                    JSVGInterruptTest.this.notifyAll();
                }
            }
            public void svgLoadEventDispatchCancelled
                (SVGLoadEventDispatcherEvent e) {
                // System.err.println("Onload Cancelled");
                synchronized (JSVGInterruptTest.this) {
                    state |= CANCELLED;
                    JSVGInterruptTest.this.notifyAll();
                }
            }
            public void svgLoadEventDispatchFailed
                (SVGLoadEventDispatcherEvent e) {
                // System.err.println("Onload Failed");
                synchronized (JSVGInterruptTest.this) {
                    state |= FAILED;
                    JSVGInterruptTest.this.notifyAll();
                }
            }
        }

    class MyRenderListener implements GVTTreeRendererListener, SetDelayable {
            int delay = 0;
            public void setDelay(int delay) { this.delay = delay; }
            public void gvtRenderingPrepare(GVTTreeRendererEvent e) {
                // System.err.println("Render Prep");
                triggerStopProcessing(delay);
            }
            public void gvtRenderingStarted(GVTTreeRendererEvent e) {
                // System.err.println("Render Start");
            }
            public void gvtRenderingCompleted(GVTTreeRendererEvent e) {
                stopStopper();
                // System.err.println("Render Complete");
                synchronized (JSVGInterruptTest.this) {
                    state |= COMPLETE;
                    JSVGInterruptTest.this.notifyAll();
                }
            }
            public void gvtRenderingCancelled(GVTTreeRendererEvent e) {
                // System.err.println("Render Cancelled");
                synchronized (JSVGInterruptTest.this) {
                    state |= CANCELLED;
                    JSVGInterruptTest.this.notifyAll();
                }
            }
            public void gvtRenderingFailed(GVTTreeRendererEvent e) {
                // System.err.println("Render Failed");
                synchronized (JSVGInterruptTest.this) {
                    state |= FAILED;
                    JSVGInterruptTest.this.notifyAll();
                }
            }
        }


    static class StopRunnable implements Runnable {
        JSVGCanvas canvas;
        public StopRunnable(JSVGCanvas canvas) {
            this.canvas = canvas;
        }

        public void run() {
            if (EventQueue.isDispatchThread())
                canvas.stopProcessing();
            else
                EventQueue.invokeLater(this);
        }
    }


    class DelayRunnable extends Thread {
        int delay;
        Runnable r;
        boolean stop     = false;
        boolean complete = false;
        public DelayRunnable(int delay, Runnable r) {
            this.delay = delay;
            this.r = r;
            setDaemon(true);
        }
        public boolean getComplete() { return complete; }

        public boolean abort() {
            synchronized (this) {
                if (complete) return false;
                stop = true;  return true;
            }
        }
        public void run() {
            long start = System.currentTimeMillis();
            long end   = start + delay;
            long curr  = start;
            while (curr < end) {
                try {
                    Thread.sleep(end-curr);
                } catch(InterruptedException ie) {
                }
                curr = System.currentTimeMillis();
            }
            synchronized (this) {
                if (stop) return;
                r.run();
                complete = true;
            }
        }
    }

}
