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
package org.apache.flex.forks.batik.gvt;

import java.util.LinkedList;
import java.util.List;

import org.apache.flex.forks.batik.gvt.event.GraphicsNodeChangeListener;

/**
 * The top-level graphics node of the GVT tree.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: RootGraphicsNode.java 475477 2006-11-15 22:44:28Z cam $
 */
public class RootGraphicsNode extends CompositeGraphicsNode {

    List treeGraphicsNodeChangeListeners = null;

   /**
     * Constructs a new empty <tt>RootGraphicsNode</tt>.
     */
    public RootGraphicsNode() {}

    /**
     * Returns the root of the GVT tree or null if the node is not
     * part of a GVT tree.  
     */
    public RootGraphicsNode getRoot() {
        return this;
    }

    public List getTreeGraphicsNodeChangeListeners() {
        if (treeGraphicsNodeChangeListeners == null) {
            treeGraphicsNodeChangeListeners = new LinkedList();
        }
        return treeGraphicsNodeChangeListeners;
    }

    public void addTreeGraphicsNodeChangeListener
        (GraphicsNodeChangeListener l) {
        getTreeGraphicsNodeChangeListeners().add(l);
    }

    public void removeTreeGraphicsNodeChangeListener
        (GraphicsNodeChangeListener l) {
        getTreeGraphicsNodeChangeListeners().remove(l);
    }

}
