/*

   Copyright 2004 The Apache Software Foundation 

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

package org.apache.flex.forks.batik.dom.util;

import java.util.List;

import org.w3c.dom.NodeList;
import org.w3c.dom.Node;

/**
 * A simple class that implements the DOM NodeList interface by
 * wrapping an Java List instace.
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: ListNodeList.java,v 1.2 2005/03/27 08:58:32 cam Exp $
 */
public class ListNodeList implements NodeList {
    protected List list;

    public ListNodeList(List list) {
        this.list = list;
    }

    /**
     * <b>DOM</b>: Implements {@link NodeList#item(int)}.
     */
    public Node item(int index) {
        if ((index < 0) || (index > list.size()))
            return null;
        return (Node)list.get(index);
    }

    /**
     * <b>DOM</b>: Implements {@link NodeList#getLength()}.
     */
    public int getLength() {
        return list.size();
    }
};
