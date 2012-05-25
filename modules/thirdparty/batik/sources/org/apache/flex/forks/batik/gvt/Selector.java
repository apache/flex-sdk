/*

   Copyright 2000,2002-2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.gvt;

import org.apache.flex.forks.batik.gvt.event.GraphicsNodeChangeListener;
import org.apache.flex.forks.batik.gvt.event.GraphicsNodeKeyListener;
import org.apache.flex.forks.batik.gvt.event.GraphicsNodeMouseListener;
import org.apache.flex.forks.batik.gvt.event.SelectionListener;

/**
 * Interface which allows selection of GraphicsNodes and their contents.
 *
 * @author <a href="mailto:bill.haneman@ireland.sun.com">Bill Haneman</a>
 * @version $Id: Selector.java,v 1.6 2004/08/18 07:14:27 vhardy Exp $
 */
public interface Selector extends GraphicsNodeMouseListener,
                                  GraphicsNodeKeyListener,
                                  GraphicsNodeChangeListener {

    /**
     * Get the contents of the current selection buffer.
     */
    public Object getSelection();

    /**
     * Reports whether the current selection contains any objects.
     */
    public boolean isEmpty();

    /**
     * Add a SelectionListener to this Selector's notification list.
     * @param l the SelectionListener to add.
     */
    public void addSelectionListener(SelectionListener l);


    /**
     * Remove a SelectionListener from this Selector's notification list.
     * @param l the SelectionListener to be removed.
     */
    public void removeSelectionListener(SelectionListener l);
 
}
