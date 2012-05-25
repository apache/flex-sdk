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

import java.text.AttributedCharacterIterator;
import java.util.ArrayList;
import java.util.List;
import java.util.Iterator;

import org.apache.flex.forks.batik.gvt.TextNode;
import org.apache.flex.forks.batik.gvt.TextPainter;
import org.apache.flex.forks.batik.gvt.renderer.StrokingTextPainter;

/**
 * One line Class Desc
 *
 * Complete Class Desc
 *
 * @author <a href="mailto:deweese@apache.org">deweese</a>
 * @version $Id: FlowTextPainter.java,v 1.2 2005/03/27 08:58:34 cam Exp $
 */
public class FlowTextPainter extends StrokingTextPainter {
    /**
     * A unique instance of this class.
     */
    protected static TextPainter singleton = new FlowTextPainter();

    /**
     * Returns a unique instance of this class.
     */
    public static TextPainter getInstance() {
	return singleton;
    }

    public List getTextRuns(TextNode node, AttributedCharacterIterator aci) {
        List textRuns = node.getTextRuns();
        if (textRuns != null) {
            return textRuns;
        }

        AttributedCharacterIterator[] chunkACIs = getTextChunkACIs(aci);
        textRuns = computeTextRuns(node, aci, chunkACIs);

        aci.first();
        List rgns = (List)aci.getAttribute(FLOW_REGIONS);

        if (rgns != null) {
            Iterator i = textRuns.iterator();
            List chunkLayouts = new ArrayList();
            TextRun tr = (TextRun)i.next();
            List layouts = new ArrayList();
            chunkLayouts.add(layouts);
            layouts.add(tr.getLayout());
            while (i.hasNext()) {
                tr = (TextRun)i.next();
                if (tr.isFirstRunInChunk()) {
                    layouts = new ArrayList();
                    chunkLayouts.add(layouts);
                }
                layouts.add(tr.getLayout());
            }

            FlowGlyphLayout.textWrapTextChunk
                (chunkACIs, chunkLayouts, rgns, fontRenderContext);
        }

        node.setTextRuns(textRuns);
        return textRuns;
    }
};
