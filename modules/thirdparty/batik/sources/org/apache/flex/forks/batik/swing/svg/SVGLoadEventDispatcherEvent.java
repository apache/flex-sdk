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

import java.util.EventObject;

import org.apache.flex.forks.batik.gvt.GraphicsNode;

/**
 * This class represents an event which indicate an event originated
 * from a SVGLoadEventDispatcher instance.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGLoadEventDispatcherEvent.java 475477 2006-11-15 22:44:28Z cam $
 */
public class SVGLoadEventDispatcherEvent extends EventObject {
    
    /**
     * The GVT root.
     */
    protected GraphicsNode gvtRoot;

    /**
     * Creates a new SVGLoadEventDispatcherEvent.
     * @param source the object that originated the event, ie. the
     *               SVGLoadEventDispatcher.
     * @param root   the GVT root.
     */
    public SVGLoadEventDispatcherEvent(Object source, GraphicsNode root) {
        super(source);
        gvtRoot = root;
    }

    /**
     * Returns the GVT tree root, or null if the gvt construction
     * was not completed or just started.
     */
    public GraphicsNode getGVTRoot() {
        return gvtRoot;
    }
}
