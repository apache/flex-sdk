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
package org.apache.flex.forks.batik.dom;

import org.apache.flex.forks.batik.dom.util.HashTable;
import org.w3c.dom.Node;
import org.w3c.dom.stylesheets.StyleSheet;

/**
 * This interface represents a StyleSheet factory.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: StyleSheetFactory.java 475477 2006-11-15 22:44:28Z cam $
 */
public interface StyleSheetFactory {
    /**
     * Creates a stylesheet from the data of the xml-stylesheet
     * processing instruction or return null when it is not possible
     * to create the given stylesheet.
     */
    StyleSheet createStyleSheet(Node node, HashTable pseudoAttrs);
}
