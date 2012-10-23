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

import java.io.InterruptedIOException;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import org.apache.flex.forks.batik.bridge.DocumentLoader;
import org.apache.flex.forks.batik.util.EventDispatcher;
import org.apache.flex.forks.batik.util.EventDispatcher.Dispatcher;
import org.apache.flex.forks.batik.util.HaltingThread;

import org.w3c.dom.svg.SVGDocument;

/**
 * This class represents an object which loads asynchroneaously a SVG document.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGDocumentLoader.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGDocumentLoader extends HaltingThread {

    /**
     * The URL of the document,
     */
    protected String url;

    /**
     * The document loader.
     */
    protected DocumentLoader loader;

    /**
     * The exception thrown.
     */
    protected Exception exception;

    /**
     * The listeners.
     */
    protected List listeners = Collections.synchronizedList(new LinkedList());

    /**
     * Creates a new SVGDocumentLoader.
     * @param u The URL of the document.
     * @param l The document loader to use
     */
    public SVGDocumentLoader(String u, DocumentLoader l) {
        url = u;
        loader = l;
    }

    /**
     * Runs this loader.
     */
    public void run() {
        SVGDocumentLoaderEvent evt;
        evt = new SVGDocumentLoaderEvent(this, null);
        try {
            fireEvent(startedDispatcher, evt);
            if (isHalted()) {
                fireEvent(cancelledDispatcher, evt);
                return;
            }

            SVGDocument svgDocument = (SVGDocument)loader.loadDocument(url);

            if (isHalted()) {
                fireEvent(cancelledDispatcher, evt);
                return;
            }

            evt = new SVGDocumentLoaderEvent(this, svgDocument);
            fireEvent(completedDispatcher, evt);
        } catch (InterruptedIOException e) {
            fireEvent(cancelledDispatcher, evt);
        } catch (Exception e) {
            exception = e;
            fireEvent(failedDispatcher, evt);
        } catch (ThreadDeath td) {
            exception = new Exception(td.getMessage());
            fireEvent(failedDispatcher, evt);
            throw td;
        } catch (Throwable t) {
            t.printStackTrace();
            exception = new Exception(t.getMessage());
            fireEvent(failedDispatcher, evt);
        }
    }

    /**
     * Returns the exception, if any occured.
     */
    public Exception getException() {
        return exception;
    }

    /**
     * Adds a SVGDocumentLoaderListener to this SVGDocumentLoader.
     */
    public void addSVGDocumentLoaderListener(SVGDocumentLoaderListener l) {
        listeners.add(l);
    }

    /**
     * Removes a SVGDocumentLoaderListener from this SVGDocumentLoader.
     */
    public void removeSVGDocumentLoaderListener(SVGDocumentLoaderListener l) {
        listeners.remove(l);
    }

    public void fireEvent(Dispatcher dispatcher, Object event) {
        EventDispatcher.fireEvent(dispatcher, listeners, event, true);
    }

    static Dispatcher startedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((SVGDocumentLoaderListener)listener).documentLoadingStarted
                    ((SVGDocumentLoaderEvent)event);
            }
        };
            
            static Dispatcher completedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((SVGDocumentLoaderListener)listener).documentLoadingCompleted
                 ((SVGDocumentLoaderEvent)event);
            }
        };

    static Dispatcher cancelledDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((SVGDocumentLoaderListener)listener).documentLoadingCancelled
                 ((SVGDocumentLoaderEvent)event);
            }
        };

    static Dispatcher failedDispatcher = new Dispatcher() {
            public void dispatch(Object listener,
                                 Object event) {
                ((SVGDocumentLoaderListener)listener).documentLoadingFailed
                 ((SVGDocumentLoaderEvent)event);
            }
        };
}
