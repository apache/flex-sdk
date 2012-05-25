/*

   Copyright 2001  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.svggen.font.table;

import java.io.IOException;
import java.io.RandomAccessFile;

/**
 *
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 * @version $Id: SingleSubstFormat1.java,v 1.3 2004/08/18 07:15:22 vhardy Exp $
 */
public class SingleSubstFormat1 extends SingleSubst {

    private int coverageOffset;
    private short deltaGlyphID;
    private Coverage coverage;

    /** Creates new SingleSubstFormat1 */
    protected SingleSubstFormat1(RandomAccessFile raf, int offset) throws IOException {
        coverageOffset = raf.readUnsignedShort();
        deltaGlyphID = raf.readShort();
        raf.seek(offset + coverageOffset);
        coverage = Coverage.read(raf);
    }

    public int getFormat() {
        return 1;
    }

    public int substitute(int glyphId) {
        int i = coverage.findGlyph(glyphId);
        if (i > -1) {
            return glyphId + deltaGlyphID;
        }
        return glyphId;
    }

}

