/*

   Copyright 2000  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.dom.events;

import org.w3c.dom.events.EventTarget;

/**
 * A Node that uses an EventSupport for its event registration and
 * dispatch.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: NodeEventTarget.java,v 1.6 2005/02/22 09:12:59 cam Exp $
 */
public interface NodeEventTarget extends EventTarget {

    /**
     * Returns the event support instance for this node, or null if any.
     */
    EventSupport getEventSupport();

    /**
     * Returns the parent node event target.
     */
    NodeEventTarget getParentNodeEventTarget();

}
