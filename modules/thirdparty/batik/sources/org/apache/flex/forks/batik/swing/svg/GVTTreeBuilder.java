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
import org.apache.flex.forks.batik.bridge.BridgeException;
import org.apache.flex.forks.batik.bridge.DynamicGVTBuilder;
import org.apache.flex.forks.batik.bridge.GVTBuilder;
import org.apache.flex.forks.batik.bridge.InterruptedBridgeException;
import org.apache.flex.forks.batik.gvt.GraphicsNode;
import org.apache.flex.forks.batik.util.EventDispatcher;
import org.apache.flex.forks.batik.util.EventDispatcher.Dispatcher;
import org.apache.flex.forks.batik.util.HaltingThread;

import org.w3c.dom.svg.SVGDocument;


/**
 * This class represents an object which builds asynchroneaously
 * a GVT tree.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: GVTTreeBuilder.java 475477 2006-11-15 22:44:28Z cam $
 */
public class GVTTreeBuilder extends HaltingThread {

    /**
     * The SVG document to give to the bridge.
     */
    protected SVGDocument svgDocument;

    /**
     * The bridge context to use.
     */
    protected BridgeContext bridgeContext;

    /**
     * The listeners.
     */
    protected List listeners = Collections.synchronizedList(new LinkedList());

    /**
     * The exception thrown.
     */
    protected Exception exception;

    /**
     * Creates a new GVTTreeBuilder.
     */
    public GVTTreeBuilder(SVGDocument   doc,
                          BridgeContext bc) {
        svgDocument = doc;
        bridgeContext = bc;
    }

    /**
     * Runs this builder.
     */
    public void run() {
        GVTTreeBuilderEvent ev;
        ev = new GVTTreeBuilderEvent(this, null);
        try {
            fireEvent(startedDispatcher, ev);

            if (isHalted()) {
                fireEvent(cancelledDispatcher, ev);
                return;
            }
            GVTBuilder builder = null;

            if (bridgeContext.isDynamic()) {
                builder = new DynamicGVTBuilder();
            } else {
                builder = new GVTBuilder();
            }
            GraphicsNode gvtRoot = builder.build(bridgeContext, svgDocument);

            if (isHalted()) {
                fireEvent(cancelledDispatcher, ev);
                return;
            }

            ev = new GVTTreeBuilderEvent(this, gvtRoot);
            fireEvent(completedDispatcher, ev);
        } catch (InterruptedBridgeException e) {
            fireEvent(cancelledDispatcher, ev);
        } catch (BridgeException e) {
            exception = e;
            ev = new GVTTreeBuilderEvent(this, e.getGraphicsNode());
            fireEvent(failedDispatcher, ev);
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
        } finally {
            // bridgeContext.getDocumentLoader().dispose();
        }
    }

    /**
     * Returns the exception, if any occured.
     */
    public Exception getException() {
        return exception;
    }

    /**
     * Adds a GVTTreeBuilderListener to this GVTTreeBuilder.
     */
    public void addGVTTreeBuilderListener(GVTTreeBuilderListener l) {
        listeners.add(l);
    }

    /**
     * Removes a GVTTreeBuilderListener from this GVTTreeBuilder.
     */
    public void removeGVTTreeBuilderListener(GVTTreeBuilderListener l) {
        listeners.remove(l);
    }

    public void fireEvent(Dispatcher dispatcher, Object event) {
        EventDispatcher.fireEvent(dispatcher, listeners, event, true);
    }

    static Dispatcher startedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((GVTTreeBuilderListener)listener).gvtBuildStarted
                 ((GVTTreeBuilderEvent)event);
            }
        };

    static Dispatcher completedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((GVTTreeBuilderListener)listener).gvtBuildCompleted
                 ((GVTTreeBuilderEvent)event);
            }
        };

    static Dispatcher cancelledDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((GVTTreeBuilderListener)listener).gvtBuildCancelled
                 ((GVTTreeBuilderEvent)event);
            }
        };

    static Dispatcher failedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((GVTTreeBuilderListener)listener).gvtBuildFailed
                 ((GVTTreeBuilderEvent)event);
            }
        };
}
