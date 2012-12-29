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
package org.apache.flex.forks.batik.svggen.font.table;

import java.io.IOException;
import java.io.RandomAccessFile;

/**
 *
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 * @version $Id: CoverageFormat1.java 475477 2006-11-15 22:44:28Z cam $
 */
public class CoverageFormat1 extends Coverage {

    private int glyphCount;
    private int[] glyphIds;

    /** Creates new CoverageFormat1 */
    protected CoverageFormat1(RandomAccessFile raf) throws IOException {
        glyphCount = raf.readUnsignedShort();
        glyphIds = new int[glyphCount];
        for (int i = 0; i < glyphCount; i++) {
            glyphIds[i] = raf.readUnsignedShort();
        }
    }

    public int getFormat() {
        return 1;
    }

    public int findGlyph(int glyphId) {
        for (int i = 0; i < glyphCount; i++) {
            if (glyphIds[i] == glyphId) {
                return i;
            }
        }
        return -1;
    }

}
