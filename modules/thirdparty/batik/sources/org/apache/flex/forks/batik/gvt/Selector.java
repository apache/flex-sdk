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

import org.apache.flex.forks.batik.gvt.event.GraphicsNodeChangeListener;
import org.apache.flex.forks.batik.gvt.event.GraphicsNodeKeyListener;
import org.apache.flex.forks.batik.gvt.event.GraphicsNodeMouseListener;
import org.apache.flex.forks.batik.gvt.event.SelectionListener;

/**
 * Interface which allows selection of GraphicsNodes and their contents.
 *
 * @author <a href="mailto:bill.haneman@ireland.sun.com">Bill Haneman</a>
 * @version $Id: Selector.java 478188 2006-11-22 15:19:17Z dvholten $
 */
public interface Selector extends GraphicsNodeMouseListener,
                                  GraphicsNodeKeyListener,
                                  GraphicsNodeChangeListener {

    /**
     * Get the contents of the current selection buffer.
     */
    Object getSelection();

    /**
     * Reports whether the current selection contains any objects.
     */
    boolean isEmpty();

    /**
     * Add a SelectionListener to this Selector's notification list.
     * @param l the SelectionListener to add.
     */
    void addSelectionListener(SelectionListener l);


    /**
     * Remove a SelectionListener from this Selector's notification list.
     * @param l the SelectionListener to be removed.
     */
    void removeSelectionListener(SelectionListener l);

}
