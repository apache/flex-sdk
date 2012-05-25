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
package org.apache.flex.forks.batik.gvt;

import java.awt.Shape;

/**
 * Interface describing object that can be selected or have selections
 * made on it.
 *
 * @author <a href="mailto:bill.haneman@ireland.sun.com">Bill Haneman</a>
 * @version $Id: Selectable.java,v 1.8 2005/03/27 08:58:34 cam Exp $
 */
public interface Selectable {

    /**
     * Initializes the current selection to begin with the character at (x, y).
     * @return true if action resulted in change of selection.
     */
    boolean selectAt(double x, double y);

    /**
     * Extends the current selection to the character at (x, y)..
     * @return true if action resulted in change of selection.
     */
    boolean selectTo(double x, double y);

    /**
     * Selects the entire contents of the GraphicsNode at (x, y).
     * @return true if action resulted in change of selection.
     */
    boolean selectAll(double x, double y);

    /**
     * Get the current text selection.
     * @return an object containing the selected content.
     */
    Object getSelection();

    /**
     * Return a shape in user coords which encloses the current selection.
     */
    Shape getHighlightShape();
}
