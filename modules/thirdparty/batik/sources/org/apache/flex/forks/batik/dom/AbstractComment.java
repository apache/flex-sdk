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

import org.w3c.dom.Comment;

/**
 * This class implements the {@link org.w3c.dom.Comment} interface.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: AbstractComment.java 475685 2006-11-16 11:16:05Z cam $
 */

public abstract class AbstractComment
    extends    AbstractCharacterData
    implements Comment {

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeName()}.
     * @return "#comment".
     */
    public String getNodeName() {
        return "#comment";
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getNodeType()}.
     * @return {@link org.w3c.dom.Node#COMMENT_NODE}
     */
    public short getNodeType() {
        return COMMENT_NODE;
    }

    /**
     * <b>DOM</b>: Implements {@link org.w3c.dom.Node#getTextContent()}.
     */
    public String getTextContent() {
        return getNodeValue();
    }
}
