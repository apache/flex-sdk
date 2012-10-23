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
package org.apache.flex.forks.batik.gvt.text;


/**
 * Class that encapsulates information returned from hit testing
 * a <tt>TextSpanLayout</tt> instance.
 * @see org.apache.flex.forks.batik.gvt.text.TextSpanLayout
 *
 * @author <a href="mailto:bill.haneman@ireland.sun.com">Bill Haneman</a>
 * @version $Id: TextHit.java 475477 2006-11-15 22:44:28Z cam $
 */
public class TextHit {

    private int charIndex;
    private boolean leadingEdge;

    /**
     * Constructs a TextHit with the specified values.
     *
     * @param charIndex The index of the character that has been
     * hit. In the case of bidirectional text this will be the logical
     * character index not the visual index. The index is relative to
     * whole text within the selected TextNode.
     * @param leadingEdge Indicates which side of the character has
     * been hit.  
     */
    public TextHit(int charIndex, boolean leadingEdge) {
        this.charIndex = charIndex;
        this.leadingEdge = leadingEdge;
    }

    /**
     * Returns the index of the character that has been hit.
     *
     * @return The character index.
     */
    public int getCharIndex() {
        return charIndex;
    }

    /**
     * Returns whether on not the character has been hit on its leading edge.
     *
     * @return Whether on not the character has been hit on its leading edge.
     */
    public boolean isLeadingEdge() {
        return leadingEdge;
    }
}

