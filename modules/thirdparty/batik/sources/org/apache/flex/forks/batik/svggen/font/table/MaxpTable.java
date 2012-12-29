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
 * @version $Id: MaxpTable.java 475477 2006-11-15 22:44:28Z cam $
 * @author <a href="mailto:david@steadystate.co.uk">David Schweinsberg</a>
 */
public class MaxpTable implements Table {

    private int versionNumber;
    private int numGlyphs;
    private int maxPoints;
    private int maxContours;
    private int maxCompositePoints;
    private int maxCompositeContours;
    private int maxZones;
    private int maxTwilightPoints;
    private int maxStorage;
    private int maxFunctionDefs;
    private int maxInstructionDefs;
    private int maxStackElements;
    private int maxSizeOfInstructions;
    private int maxComponentElements;
    private int maxComponentDepth;

    protected MaxpTable(DirectoryEntry de,RandomAccessFile raf) throws IOException {
        raf.seek(de.getOffset());
        versionNumber = raf.readInt();
        numGlyphs = raf.readUnsignedShort();
        maxPoints = raf.readUnsignedShort();
        maxContours = raf.readUnsignedShort();
        maxCompositePoints = raf.readUnsignedShort();
        maxCompositeContours = raf.readUnsignedShort();
        maxZones = raf.readUnsignedShort();
        maxTwilightPoints = raf.readUnsignedShort();
        maxStorage = raf.readUnsignedShort();
        maxFunctionDefs = raf.readUnsignedShort();
        maxInstructionDefs = raf.readUnsignedShort();
        maxStackElements = raf.readUnsignedShort();
        maxSizeOfInstructions = raf.readUnsignedShort();
        maxComponentElements = raf.readUnsignedShort();
        maxComponentDepth = raf.readUnsignedShort();
    }

    public int getMaxComponentDepth() {
        return maxComponentDepth;
    }

    public int getMaxComponentElements() {
        return maxComponentElements;
    }

    public int getMaxCompositeContours() {
        return maxCompositeContours;
    }

    public int getMaxCompositePoints() {
        return maxCompositePoints;
    }

    public int getMaxContours() {
        return maxContours;
    }

    public int getMaxFunctionDefs() {
        return maxFunctionDefs;
    }

    public int getMaxInstructionDefs() {
        return maxInstructionDefs;
    }

    public int getMaxPoints() {
        return maxPoints;
    }

    public int getMaxSizeOfInstructions() {
        return maxSizeOfInstructions;
    }

    public int getMaxStackElements() {
        return maxStackElements;
    }

    public int getMaxStorage() {
        return maxStorage;
    }

    public int getMaxTwilightPoints() {
        return maxTwilightPoints;
    }

    public int getMaxZones() {
        return maxZones;
    }

    public int getNumGlyphs() {
        return numGlyphs;
    }

    public int getType() {
        return maxp;
    }
}
