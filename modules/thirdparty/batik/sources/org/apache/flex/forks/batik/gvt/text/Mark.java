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
import org.apache.flex.forks.batik.gvt.TextNode;

/**
 * Marker interface, mostly, that encapsulates information about a
 * selection gesture.
 *
 * @author <a href="mailto:bill.haneman@ireland.sun.com">Bill Haneman</a>
 * @version $Id: Mark.java 478188 2006-11-22 15:19:17Z dvholten $
 */
public interface Mark {
    /*
     * Return the TextNode this Mark is associated with
     */
    TextNode getTextNode();

    /**
     * Returns the index of the character that has been hit.
     *
     * @return The character index.
     */
    int getCharIndex();
}
