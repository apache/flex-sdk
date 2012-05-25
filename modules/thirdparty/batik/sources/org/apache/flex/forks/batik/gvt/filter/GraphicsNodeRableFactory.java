/*

   Copyright 2000-2001  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.gvt.filter;

import org.apache.flex.forks.batik.gvt.GraphicsNode;

/**
 * This interface lets <tt>GraphicsNode</tt> create instances of
 * <tt>GraphicsNodeRable</tt> appropriate for the filter module
 * implementation.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: GraphicsNodeRableFactory.java,v 1.6 2004/08/18 07:14:33 vhardy Exp $
 */
public interface GraphicsNodeRableFactory {
    /**
     * Returns a <tt>GraphicsNodeRable</tt> initialized with the
     * input <tt>GraphicsNode</tt>.
     */
    GraphicsNodeRable createGraphicsNodeRable(GraphicsNode node);
}
