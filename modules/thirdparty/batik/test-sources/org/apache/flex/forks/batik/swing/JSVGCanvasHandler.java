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

import java.awt.Dimension;
import java.awt.EventQueue;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;

import javax.swing.JFrame;

import org.apache.flex.forks.batik.test.DefaultTestReport;
import org.apache.flex.forks.batik.test.Test;
import org.apache.flex.forks.batik.test.TestReport;


import org.apache.flex.forks.batik.bridge.ScriptingEnvironment;
import org.apache.flex.forks.batik.bridge.UpdateManager;
import org.apache.flex.forks.batik.bridge.UpdateManagerEvent;
import org.apache.flex.forks.batik.bridge.UpdateManagerListener;
import org.apache.flex.forks.batik.script.Interpreter;
import org.apache.flex.forks.batik.script.InterpreterException;
import org.apache.flex.forks.batik.util.RunnableQueue;

import org.apache.flex.forks.batik.swing.gvt.GVTTreeRendererAdapter;
import org.apache.flex.forks.batik.swing.gvt.GVTTreeRendererEvent;
import org.apache.flex.forks.batik.swing.JSVGCanvas;
import org.apache.flex.forks.batik.swing.svg.SVGDocumentLoaderAdapter;
import org.apache.flex.forks.batik.swing.svg.SVGDocumentLoaderEvent;

/**
 * One line Class Desc
 *
 * Complete Class Desc
 *
 * @author <a href="mailto:deweese@apache.org">l449433</a>
 * @version $Id: JSVGCanvasHandler.java,v 1.10 2005/03/27 08:58:37 cam Exp $
 */
public class JSVGCanvasHandler {

    public interface Delegate {
        public String getName();
        // Returns true if a load event was triggered.  In this case
        // the handler will wait for the load event to complete/fail.
        public boolean canvasInit(JSVGCanvas canvas);
        public void canvasLoaded(JSVGCanvas canvas);
        public void canvasRendered(JSVGCanvas canvas);
        public boolean canvasUpdated(JSVGCanvas canvas);
        public void canvasDone(JSVGCanvas canvas);
        public void failure(TestReport report);
    }
    
    public static final String REGARD_TEST_INSTANCE = "regardTestInstance";
    public static final String REGARD_START_SCRIPT = 
        "try { regardStart(); } catch (er) {}";

    /**
     * Error when canvas can't load SVG file.
     * {0} The file/url that could not be loaded.
     */
    public static final String ERROR_CANNOT_LOAD_SVG = 
        "JSVGCanvasHandler.message.error.could.not.load.svg";

    /**
     * Error when canvas can't render SVG file.
     * {0} The file/url that could not be rendered.
     */
    public static final String ERROR_SVG_RENDER_FAILED = 
        "JSVGCanvasHandler.message.error.svg.render.failed";

    /**
     * Error when canvas can't peform render update SVG file.
     * {0} The file/url that could not be updated..
     */
    public static final String ERROR_SVG_UPDATE_FAILED = 
        "JSVGCanvasHandler.message.error.svg.update.failed";

    /**
     * Entry describing the error
     */
    public static final String ENTRY_KEY_ERROR_DESCRIPTION 
        = "JSVGCanvasHandler.entry.key.error.description";

    public static String fmt(String key, Object []args) {
        return TestMessages.formatMessage(key, args);
    }

    JFrame     frame = null;
    JSVGCanvas canvas = null;
    UpdateManager updateManager = null;
    WindowListener wl = null;
    InitialRenderListener irl = null;
    LoadListener ll = null;
    UpdateRenderListener url = null;
    
    boolean failed;
    boolean abort = false;
    boolean done  = false;
    Object loadMonitor = new Object();
    Object renderMonitor = new Object();
    
    Delegate delegate;
    Test host;
    String desc;

    public JSVGCanvasHandler(Test host, Delegate delegate) {
        this.host     = host;
        this.delegate = delegate;
    }

    public JFrame getFrame()     { return frame; }
    public JSVGCanvas getCanvas() { return canvas; }

    public JSVGCanvas createCanvas() { return new JSVGCanvas(); }

    public void runCanvas(String desc) {
        this.desc = desc;

        setupCanvas();

        if ( abort) return;

        try {
            synchronized (renderMonitor) {
                synchronized (loadMonitor) {
                    if (delegate.canvasInit(canvas)) {
                        checkLoad();
                    }
                }

                if ( abort) return;

                checkRender();
                if ( abort) return;

                try {
                    EventQueue.invokeAndWait(new Runnable() {
                            public void run() {
                                updateManager = canvas.getUpdateManager();
                                if (updateManager == null)
                                    return;
                                url = new UpdateRenderListener();
                                updateManager.addUpdateManagerListener(url);
                            }});
                } catch (Throwable t) { t.printStackTrace(); }

                if ( abort) return;

                if (updateManager == null)
                    return;

                // Wait for Update Manager to Start.
                while (!updateManager.isRunning());

                bindHost();

                if ( abort) return;

                while (!done) {
                    checkUpdate();
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

    public void setupCanvas() { 
        try {
            EventQueue.invokeAndWait(new Runnable() {
                    public void run() {
                        frame = new JFrame(delegate.getName());
                        canvas = createCanvas();
                        canvas.setPreferredSize(new Dimension(450, 500));
                        frame.getContentPane().add(canvas);
                        frame.pack();
                        wl = new WindowAdapter() {
                                public void windowClosing(WindowEvent e) {
                                    synchronized (loadMonitor) {
                                        abort = true;
                                        loadMonitor.notifyAll();
                                    }
                                    synchronized (renderMonitor) {
                                        abort = true;
                                        renderMonitor.notifyAll();
                                    }
                                }
                            };
                        frame.addWindowListener(wl);
                        frame.setVisible(true);

                        irl = new InitialRenderListener();
                        canvas.addGVTTreeRendererListener(irl);
                        ll = new LoadListener();
                        canvas.addSVGDocumentLoaderListener(ll);
                    }});
        } catch (Throwable t) { 
            t.printStackTrace();
        }
    }


    public void scriptDone() {
        Runnable r = new Runnable() {
                public void run() {
                    synchronized(renderMonitor) {
                        done = true;
                        failed = false;
                        renderMonitor.notifyAll();
                    }
                }
            };
        if ((updateManager == null) ||
            (!updateManager.isRunning())){
            // Don't run it in this thread or we deadlock the event queue.
            Thread t = new Thread(r);
            t.start();
        } else {
            updateManager.getUpdateRunnableQueue().invokeLater(r);
        }
    }
    
    public void dispose() {
        if (frame != null) {
            frame.removeWindowListener(wl);
            frame.setVisible(false);
        }
        wl = null;
        if (canvas != null) {
            canvas.removeGVTTreeRendererListener(irl);  irl=null;
            canvas.removeSVGDocumentLoaderListener(ll); ll=null;
            canvas.removeUpdateManagerListener(url);    url=null;
        }
        updateManager = null;
        canvas = null;
        frame = null;
    }

    public void checkSomething(Object monitor, String errorCode) {
        synchronized (monitor) {
            failed = true;
            try { monitor.wait(); }
            catch(InterruptedException ie) { /* nothing */ }
            if (abort || failed) {
                DefaultTestReport report = new DefaultTestReport(host);
                report.setErrorCode(errorCode);
                report.setDescription(new TestReport.Entry[] { 
                    new TestReport.Entry
                    (fmt(ENTRY_KEY_ERROR_DESCRIPTION, null),
                     fmt(errorCode, new Object[]{desc}))
                });
                report.setPassed(false);
                delegate.failure(report);
                done = true;
                return;
            }
        }
    }

    public void checkLoad() {
        checkSomething(loadMonitor, ERROR_CANNOT_LOAD_SVG);
        delegate.canvasLoaded(canvas);
    }

    public void checkRender() {
        checkSomething(renderMonitor, ERROR_SVG_RENDER_FAILED);
        delegate.canvasRendered(canvas);
    }

    public void checkUpdate() {
        checkSomething(renderMonitor, ERROR_SVG_UPDATE_FAILED);
        if (!done)
            done = delegate.canvasUpdated(canvas);
    }

    public void bindHost() {
        RunnableQueue rq;
        rq = updateManager.getUpdateRunnableQueue();
        rq.invokeLater(new Runnable() {
                UpdateManager um = updateManager;
                public void run() {
                    ScriptingEnvironment scriptEnv;
                    scriptEnv = um.getScriptingEnvironment();
                    Interpreter interp;
                    interp    = scriptEnv.getInterpreter();
                    interp.bindObject(REGARD_TEST_INSTANCE, 
                                      host);
                    try {
                        interp.evaluate(REGARD_START_SCRIPT);
                    } catch (InterpreterException ie) {
                        // Could not wait if no start script.
                    }
                }
            });
    }

    class UpdateRenderListener implements UpdateManagerListener {
        public void updateCompleted(UpdateManagerEvent e) {
            synchronized(renderMonitor){
                failed = false;
                renderMonitor.notifyAll();
            }
        }
        public void updateFailed(UpdateManagerEvent e) {
            synchronized(renderMonitor){
                renderMonitor.notifyAll();
            }
        }
        public void managerStarted(UpdateManagerEvent e) { }
        public void managerSuspended(UpdateManagerEvent e) { }
        public void managerResumed(UpdateManagerEvent e) { }
        public void managerStopped(UpdateManagerEvent e) { }
        public void updateStarted(UpdateManagerEvent e) { }
    }

    class InitialRenderListener extends GVTTreeRendererAdapter {
        public void gvtRenderingCompleted(GVTTreeRendererEvent e) {
            synchronized(renderMonitor){
                failed = false;
                renderMonitor.notifyAll();
            }
        }


        public void gvtRenderingCancelled(GVTTreeRendererEvent e) {
            synchronized(renderMonitor){
                renderMonitor.notifyAll();
            }
        }

        public void gvtRenderingFailed(GVTTreeRendererEvent e) {
            synchronized(renderMonitor){
                renderMonitor.notifyAll();
            }
        }
    }

    class LoadListener extends SVGDocumentLoaderAdapter {
        public void documentLoadingCompleted(SVGDocumentLoaderEvent e) {
            synchronized(loadMonitor){
                failed = false;
                loadMonitor.notifyAll();
            }
        }

        public void documentLoadingFailed(SVGDocumentLoaderEvent e) {
            synchronized(loadMonitor){
                loadMonitor.notifyAll();
            }
        }

        public void documentLoadingCancelled(SVGDocumentLoaderEvent e) {
            synchronized(loadMonitor){
                loadMonitor.notifyAll();
            }
        }
    }
}
