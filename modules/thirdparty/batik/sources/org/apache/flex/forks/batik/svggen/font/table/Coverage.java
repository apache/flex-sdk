/*

   Copyright 2001,2003  The Apache Software Foundation 

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
 * @version $Id: Coverage.java,v 1.5 2005/03/27 08:58:36 cam Exp $
 */
public abstract class Coverage {

    public abstract int getFormat();

    /**
     * @param glyphId The ID of the glyph to find.
     * @return The index of the glyph within the coverage, or -1 if the glyph
     * can't be found.
     */
    public abstract int findGlyph(int glyphId);
    
    protected static Coverage read(RandomAccessFile raf) throws IOException {
        Coverage c = null;
        int format = raf.readUnsignedShort();
        if (format == 1) {
            c = new CoverageFormat1(raf);
        } else if (format == 2) {
            c = new CoverageFormat2(raf);
        }
        return c;
    }

}
