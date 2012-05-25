/*

   Copyright 2001  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.swing.gvt;

/**
 * An adapter class that represents a listener to the
 * <tt>GVTTreeRendererEvent</tt> events.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: GVTTreeRendererAdapter.java,v 1.3 2004/08/18 07:15:32 vhardy Exp $
 */
public abstract class GVTTreeRendererAdapter implements GVTTreeRendererListener {

    /**
     * Called when a rendering is in its preparing phase.
     */
    public void gvtRenderingPrepare(GVTTreeRendererEvent e) {}

    /**
     * Called when a rendering started.
     */
    public void gvtRenderingStarted(GVTTreeRendererEvent e) {}

    /**
     * Called when a rendering was completed.
     */
    public void gvtRenderingCompleted(GVTTreeRendererEvent e) {}

    /**
     * Called when a rendering was cancelled.
     */
    public void gvtRenderingCancelled(GVTTreeRendererEvent e) {}

    /**
     * Called when a rendering failed.
     */
    public void gvtRenderingFailed(GVTTreeRendererEvent e) {}

}
