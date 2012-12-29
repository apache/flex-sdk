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
package org.apache.flex.forks.batik.gvt.filter;

import org.apache.flex.forks.batik.ext.awt.image.renderable.Filter;
import org.apache.flex.forks.batik.gvt.GraphicsNode;

/**
 * This interface allows <tt>GraphicsNode</tt> to be seen as
 * <tt>RenderableImages</tt>, which can be used for operations such as
 * filtering, masking or compositing.
 * Given a <tt>GraphicsNode</tt>, a <tt>GraphicsNodeRable</tt> can be
 * created through a <tt>GraphicsNodeRableFactory</tt>.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: GraphicsNodeRable.java 478188 2006-11-22 15:19:17Z dvholten $
 */
public interface GraphicsNodeRable extends Filter {
    /**
     * Returns the <tt>GraphicsNode</tt> for which a rendering can be obtained
     * @return the <tt>GraphicsNode</tt> associated with this image.
     */
    GraphicsNode getGraphicsNode();

    /**
     * Sets the <tt>GraphicsNode</tt> associated with this image.
     */
    void setGraphicsNode(GraphicsNode node);

    /**
     * Returns true if this Rable get's it's contents by calling
     * primitivePaint on the associated <tt>GraphicsNode</tt> or
     * false if it uses paint.
     */
    boolean getUsePrimitivePaint();

    /**
     * Set to true if this Rable should get it's contents by calling
     * primitivePaint on the associated <tt>GraphicsNode</tt> or false
     * if it should use paint.
     */
    void setUsePrimitivePaint(boolean usePrimitivePaint);
}
