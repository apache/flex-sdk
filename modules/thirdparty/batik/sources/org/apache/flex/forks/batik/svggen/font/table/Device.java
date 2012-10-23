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
 * @version $Id: Device.java 501495 2007-01-30 18:00:36Z dvholten $
 */
public class Device {

    private int startSize;
    private int endSize;
    private int deltaFormat;
    private int[] deltaValues;

    /** Creates new Device */
    public Device(RandomAccessFile raf) throws IOException {
        startSize = raf.readUnsignedShort();
        endSize = raf.readUnsignedShort();
        deltaFormat = raf.readUnsignedShort();
        int size = startSize - endSize;
        switch (deltaFormat) {
        case 1:
            size = (size % 8 == 0) ? size / 8 : size / 8 + 1;
            break;
        case 2:
            size = (size % 4 == 0) ? size / 4 : size / 4 + 1;
            break;
        case 3:
            size = (size % 2 == 0) ? size / 2 : size / 2 + 1;
            break;
        }
        deltaValues = new int[size];
        for (int i = 0; i < size; i++) {
            deltaValues[i] = raf.readUnsignedShort();
        }
    }


}
