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
package org.apache.flex.forks.batik.gvt.text;
import org.apache.flex.forks.batik.gvt.TextNode;

/**
 * Marker interface, mostly, that encapsulates information about a
 * selection gesture.
 *
 * @author <a href="mailto:bill.haneman@ireland.sun.com">Bill Haneman</a>
 * @version $Id: Mark.java,v 1.5 2005/02/27 02:08:52 deweese Exp $ 
 */
public interface Mark {
    /*
     * Return the TextNode this Mark is associated with 
     */
    public TextNode getTextNode();

    /**
     * Returns the index of the character that has been hit.
     *
     * @return The character index.
     */
    public int getCharIndex();
}
