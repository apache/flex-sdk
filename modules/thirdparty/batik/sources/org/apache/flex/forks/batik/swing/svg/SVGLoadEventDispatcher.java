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
package org.apache.flex.forks.batik.swing.svg;

import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import org.apache.flex.forks.batik.bridge.BridgeContext;
import org.apache.flex.forks.batik.bridge.InterruptedBridgeException;
import org.apache.flex.forks.batik.bridge.UpdateManager;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.util.EventDispatcher;
import org.apache.flex.forks.batik.util.EventDispatcher.Dispatcher;
import org.apache.flex.forks.batik.util.HaltingThread;

import org.w3c.dom.svg.SVGDocument;

/**
 * This class dispatches the SVGLoadEvent event on a SVG document.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGLoadEventDispatcher.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGLoadEventDispatcher extends HaltingThread {

    /**
     * The SVG document to give to the bridge.
     */
    protected SVGDocument svgDocument;

    /**
     * The root graphics node.
     */
    protected GraphicsNode root;

    /**
     * The bridge context to use.
     */
    protected BridgeContext bridgeContext;

    /**
     * The update manager.
     */
    protected UpdateManager updateManager;

    /**
     * The listeners.
     */
    protected List listeners = Collections.synchronizedList(new LinkedList());

    /**
     * The exception thrown.
     */
    protected Exception exception;

    /**
     * Creates a new SVGLoadEventDispatcher.
     */
    public SVGLoadEventDispatcher(GraphicsNode gn,
                                  SVGDocument doc,
                                  BridgeContext bc,
                                  UpdateManager um) {
        svgDocument = doc;
        root = gn;
        bridgeContext = bc;
        updateManager = um;
    }

    /**
     * Runs the dispatcher.
     */
    public void run() {
        SVGLoadEventDispatcherEvent ev;
        ev = new SVGLoadEventDispatcherEvent(this, root);
        try {
            fireEvent(startedDispatcher, ev);

            if (isHalted()) {
                fireEvent(cancelledDispatcher, ev);
                return;
            }

            updateManager.dispatchSVGLoadEvent();

            if (isHalted()) {
                fireEvent(cancelledDispatcher, ev);
                return;
            }

            fireEvent(completedDispatcher, ev);
        } catch (InterruptedException e) {
            fireEvent(cancelledDispatcher, ev);
        } catch (InterruptedBridgeException e) {
            fireEvent(cancelledDispatcher, ev);
        } catch (Exception e) {
            exception = e;
            fireEvent(failedDispatcher, ev);
        } catch (ThreadDeath td) {
            exception = new Exception(td.getMessage());
            fireEvent(failedDispatcher, ev);
            throw td;
        } catch (Throwable t) {
            t.printStackTrace();
            exception = new Exception(t.getMessage());
            fireEvent(failedDispatcher, ev);
        }
    }

    /**
     * Returns the update manager.
     */
    public UpdateManager getUpdateManager() {
        return updateManager;
    }

    /**
     * Returns the exception, if any occured.
     */
    public Exception getException() {
        return exception;
    }

    /**
     * Adds a SVGLoadEventDispatcherListener to this SVGLoadEventDispatcher.
     */
    public void addSVGLoadEventDispatcherListener
        (SVGLoadEventDispatcherListener l) {
        listeners.add(l);
    }

    /**
     * Removes a SVGLoadEventDispatcherListener from this
     * SVGLoadEventDispatcher.
     */
    public void removeSVGLoadEventDispatcherListener
        (SVGLoadEventDispatcherListener l) {
        listeners.remove(l);
    }

    public void fireEvent(Dispatcher dispatcher, Object event) {
        EventDispatcher.fireEvent(dispatcher, listeners, event, true);
    }

    static Dispatcher startedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((SVGLoadEventDispatcherListener)listener).
                    svgLoadEventDispatchStarted
                    ((SVGLoadEventDispatcherEvent)event);
            }
        };

    static Dispatcher completedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((SVGLoadEventDispatcherListener)listener).
                    svgLoadEventDispatchCompleted
                    ((SVGLoadEventDispatcherEvent)event);
            }
        };

    static Dispatcher cancelledDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((SVGLoadEventDispatcherListener)listener).
                    svgLoadEventDispatchCancelled
                    ((SVGLoadEventDispatcherEvent)event);
            }
        };

    static Dispatcher failedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((SVGLoadEventDispatcherListener)listener).
                    svgLoadEventDispatchFailed
                    ((SVGLoadEventDispatcherEvent)event);
            }
        };
}
