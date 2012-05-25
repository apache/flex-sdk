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
package org.apache.flex.forks.batik.swing.svg;

/**
 * An adapter class that represents a listener to the
 * <tt>SVGDocumentLoaderEvent</tt> events.
 *
 * @author <a href="mailto:tkormann@apache.org">Thierry Kormann</a>
 * @version $Id: SVGDocumentLoaderAdapter.java,v 1.4 2004/08/18 07:15:35 vhardy Exp $
 */
public abstract class SVGDocumentLoaderAdapter
    implements SVGDocumentLoaderListener {

    /**
     * Called when the loading of a document was started.
     */
    public void documentLoadingStarted(SVGDocumentLoaderEvent e) {}

    /**
     * Called when the loading of a document was completed.
     */
    public void documentLoadingCompleted(SVGDocumentLoaderEvent e) {}

    /**
     * Called when the loading of a document was cancelled.
     */
    public void documentLoadingCancelled(SVGDocumentLoaderEvent e) {}

    /**
     * Called when the loading of a document has failed.
     */
    public void documentLoadingFailed(SVGDocumentLoaderEvent e) {}
}
