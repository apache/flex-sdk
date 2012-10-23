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
 * @version $Id: CmapFormat4.java 501844 2007-01-31 13:54:05Z dvholten $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public class CmapFormat4 extends CmapFormat {

    public  int language;
    private int segCountX2;
    private int searchRange;
    private int entrySelector;
    private int rangeShift;
    private int[] endCode;
    private int[] startCode;
    private int[] idDelta;
    private int[] idRangeOffset;
    private int[] glyphIdArray;
    private int segCount;
    private int first, last;

    protected CmapFormat4(RandomAccessFile raf) throws IOException {
        super(raf);
        format = 4;
        segCountX2 = raf.readUnsignedShort();
        segCount = segCountX2 / 2;
        endCode = new int[segCount];
        startCode = new int[segCount];
        idDelta = new int[segCount];
        idRangeOffset = new int[segCount];
        searchRange = raf.readUnsignedShort();
        entrySelector = raf.readUnsignedShort();
        rangeShift = raf.readUnsignedShort();
        last = -1;
        for (int i = 0; i < segCount; i++) {
            endCode[i] = raf.readUnsignedShort();
            if (endCode[i] > last) last = endCode[i];
        }
        raf.readUnsignedShort(); // reservePad
        for (int i = 0; i < segCount; i++) {
            startCode[i] = raf.readUnsignedShort();
            if ((i==0 ) || (startCode[i] < first)) first = startCode[i];
        }
        for (int i = 0; i < segCount; i++) {
            idDelta[i] = raf.readUnsignedShort();
        }
        for (int i = 0; i < segCount; i++) {
            idRangeOffset[i] = raf.readUnsignedShort();
        }

        // Whatever remains of this header belongs in glyphIdArray
        int count = (length - 16 - (segCount*8)) / 2;
        glyphIdArray = new int[count];
        for (int i = 0; i < count; i++) {
            glyphIdArray[i] = raf.readUnsignedShort();
        }
    }

    public int getFirst() { return first; }
    public int getLast()  { return last; }

    public int mapCharCode(int charCode) {
        try {
            /*
              Quoting :
              http://developer.apple.com/fonts/TTRefMan/RM06/Chap6cmap.html#Surrogates

              The original architecture of the Unicode Standard
              allowed for all encoded characters to be represented
              using sixteen bit code points. This allowed for up to
              65,354 characters to be encoded. (Unicode code points
              U+FFFE and U+FFFF are reserved and unavailable to
              represent characters. For more details, see The Unicode
              Standard.)

              My comment : Isn't there a typo here ? Shouldn't we
              rather read 65,534 ?
              */
            if ((charCode < 0) || (charCode >= 0xFFFE))
                return 0;

            for (int i = 0; i < segCount; i++) {
                if (endCode[i] >= charCode) {
                    if (startCode[i] <= charCode) {
                        if (idRangeOffset[i] > 0) {
                            return glyphIdArray[idRangeOffset[i]/2 +
                                                (charCode - startCode[i]) -
                                                (segCount - i)];
                        } else {
                            return (idDelta[i] + charCode) % 65536;
                        }
                    } else {
                        break;
                    }
                }
            }
        } catch (ArrayIndexOutOfBoundsException e) {
            System.err.println("error: Array out of bounds - " + e.getMessage());
        }
        return 0;
    }

    public String toString() {
        return new StringBuffer( 80 )
        .append(super.toString())
        .append(", segCountX2: ")
        .append(segCountX2)
        .append(", searchRange: ")
        .append(searchRange)
        .append(", entrySelector: ")
        .append(entrySelector)
        .append(", rangeShift: ")
        .append(rangeShift)
        .append(", endCode: ")
        .append( intToStr( endCode ))
        .append(", startCode: ")
        .append( intToStr( startCode ))
        .append(", idDelta: ")
        .append( intToStr( idDelta ))
        .append(", idRangeOffset: ")
        .append( intToStr( idRangeOffset ) ).toString();
    }

    /**
     * local helper method to convert an int-array to String.
     * Intended for debugging, format may change.
     *
     * @param array of int to convert
     * @return a String in the form "[val,val,val ... ]"
     */
    private static String intToStr( int[] array ){
        int nSlots = array.length;
        StringBuffer workBuff = new StringBuffer( nSlots * 8 );
        workBuff.append( '[' );
        for( int i= 0; i < nSlots; i++ ){
            workBuff.append( array[ i ] );
            if ( i < nSlots-1 ) {
                workBuff.append( ',' );
            }
        }
        workBuff.append( ']');
        return workBuff.toString();
    }
}
