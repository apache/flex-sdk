/*

   Copyright 2002  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.swing.svg;

/**
 * This class provides an adapter for the SVGLoadEventDispatcherListener
 * interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: SVGLoadEventDispatcherAdapter.java,v 1.3 2004/08/18 07:15:36 vhardy Exp $
 */
public class SVGLoadEventDispatcherAdapter
    implements SVGLoadEventDispatcherListener {

    /**
     * Called when a onload event dispatch started.
     */
    public void svgLoadEventDispatchStarted(SVGLoadEventDispatcherEvent e) {
    }

    /**
     * Called when a onload event dispatch was completed.
     */
    public void svgLoadEventDispatchCompleted(SVGLoadEventDispatcherEvent e) {
    }

    /**
     * Called when a onload event dispatch was cancelled.
     */
    public void svgLoadEventDispatchCancelled(SVGLoadEventDispatcherEvent e) {
    }

    /**
     * Called when a onload event dispatch failed.
     */
    public void svgLoadEventDispatchFailed(SVGLoadEventDispatcherEvent e) {
    }
}
