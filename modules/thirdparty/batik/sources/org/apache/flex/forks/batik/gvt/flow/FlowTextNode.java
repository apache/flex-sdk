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

package org.apache.flex.forks.batik.gvt.flow;

import java.util.List;

import org.apache.flex.forks.batik.gvt.TextNode;
import org.apache.flex.forks.batik.gvt.TextPainter;


/**
 * One line Class Desc
 *
 * Complete Class Desc
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: FlowTextNode.java,v 1.2 2005/03/27 08:58:34 cam Exp $
 */
public class FlowTextNode extends TextNode{

    public FlowTextNode() {
        textPainter = FlowTextPainter.getInstance();
    }

    public void setTextPainter(TextPainter textPainter) {
        if (textPainter == null)
            this.textPainter = FlowTextPainter.getInstance();
        else
            this.textPainter = textPainter;
    }

};
