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

import java.io.ByteArrayInputStream;

/**
 * @version $Id: GlyfSimpleDescript.java 475477 2006-11-15 22:44:28Z cam $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public class GlyfSimpleDescript extends GlyfDescript {

    private int[] endPtsOfContours;
    private byte[] flags;
    private short[] xCoordinates;
    private short[] yCoordinates;
    private int count;

    public GlyfSimpleDescript(GlyfTable parentTable, short numberOfContours, ByteArrayInputStream bais) {

        super(parentTable, numberOfContours, bais);
        
        // Simple glyph description
        endPtsOfContours = new int[numberOfContours];
        for (int i = 0; i < numberOfContours; i++) {
            endPtsOfContours[i] = (bais.read()<<8 | bais.read());
        }

        // The last end point index reveals the total number of points
        count = endPtsOfContours[numberOfContours-1] + 1;
        flags = new byte[count];
        xCoordinates = new short[count];
        yCoordinates = new short[count];

        int instructionCount = (bais.read()<<8 | bais.read());
        readInstructions(bais, instructionCount);
        readFlags(count, bais);
        readCoords(count, bais);
    }

    public int getEndPtOfContours(int i) {
        return endPtsOfContours[i];
    }

    public byte getFlags(int i) {
        return flags[i];
    }

    public short getXCoordinate(int i) {
        return xCoordinates[i];
    }

    public short getYCoordinate(int i) {
        return yCoordinates[i];
    }

    public boolean isComposite() {
        return false;
    }

    public int getPointCount() {
        return count;
    }

    public int getContourCount() {
        return getNumberOfContours();
    }
    /*
    public int getComponentIndex(int c) {
    return 0;
    }

    public int getComponentCount() {
    return 1;
    }
     */
    /**
     * The table is stored as relative values, but we'll store them as absolutes
     */
    private void readCoords(int count, ByteArrayInputStream bais) {
        short x = 0;
        short y = 0;
        for (int i = 0; i < count; i++) {
            if ((flags[i] & xDual) != 0) {
                if ((flags[i] & xShortVector) != 0) {
                    x += (short) bais.read();
                }
            } else {
                if ((flags[i] & xShortVector) != 0) {
                    x += (short) -((short) bais.read());
                } else {
                    x += (short)(bais.read()<<8 | bais.read());
                }
            }
            xCoordinates[i] = x;
        }

        for (int i = 0; i < count; i++) {
            if ((flags[i] & yDual) != 0) {
                if ((flags[i] & yShortVector) != 0) {
                    y += (short) bais.read();
                }
            } else {
                if ((flags[i] & yShortVector) != 0) {
                    y += (short) -((short) bais.read());
                } else {
                    y += (short)(bais.read()<<8 | bais.read());
                }
            }
            yCoordinates[i] = y;
        }
    }

    /**
     * The flags are run-length encoded
     */
    private void readFlags(int flagCount, ByteArrayInputStream bais) {
        try {
            for (int index = 0; index < flagCount; index++) {
                flags[index] = (byte) bais.read();
                if ((flags[index] & repeat) != 0) {
                    int repeats = bais.read();
                    for (int i = 1; i <= repeats; i++) {
                        flags[index + i] = flags[index];
                    }
                    index += repeats;
                }
            }
        } catch (ArrayIndexOutOfBoundsException e) {
            System.out.println("error: array index out of bounds");
        }
    }
}
