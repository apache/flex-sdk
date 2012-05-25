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
package org.apache.flex.forks.batik.gvt.event;

/**
 * An abstract adapter class for receiving graphics node change
 * events. The methods in this class are empty. This class exists as
 * convenience for creating listener objects.
 *
 * <p>Extend this class to create a <tt>GraphicsNodeChangeEvent</tt>
 * listener and override the methods for the events of interest. (If
 * you implement the <tt>GraphicsNodeChangeListener</tt> interface, you
 * have to define all of the methods in it. This abstract class
 * defines null methods for them all, so you can only have to define
 * methods for events you care about.)
 *
 * @author <a href="mailto:deweese@apache.org">Thomas DeWeese</a>
 * @version $Id: GraphicsNodeChangeAdapter.java,v 1.4 2005/03/27 08:58:34 cam Exp $
 */
public abstract class GraphicsNodeChangeAdapter
        implements GraphicsNodeChangeListener {
    
    /**
     * Invoked when a change has started on a graphics node, but before
     * any changes occure in the graphics node it's self.
     * @param gnce the graphics node change event
     */
    public void changeStarted(GraphicsNodeChangeEvent gnce) { }

    /**
     * Invoked when a change on a graphics node has completed
     * @param gnce the graphics node change event
     */
    public void changeCompleted(GraphicsNodeChangeEvent gnce) { }
}
