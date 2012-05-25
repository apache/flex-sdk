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
package org.apache.flex.forks.batik.gvt.event;

import java.util.EventListener;

/**
 * The listener interface for receiving keyboard focus events on a
 * graphics node.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: GraphicsNodeFocusListener.java,v 1.3 2004/08/18 07:14:30 vhardy Exp $
 */
public interface GraphicsNodeFocusListener extends EventListener {

    /**
     * Invoked when a graphics node gains the keyboard focus.
     */
    void focusGained(GraphicsNodeFocusEvent evt);

    /**
     * Invoked when a graphics node loses the keyboard focus.
     */
    void focusLost(GraphicsNodeFocusEvent evt);

}
