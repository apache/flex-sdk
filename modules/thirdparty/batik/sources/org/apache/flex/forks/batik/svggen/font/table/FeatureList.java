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
 * @version $Id: FeatureList.java 475477 2006-11-15 22:44:28Z cam $
 */
public class FeatureList {

    private int featureCount;
    private FeatureRecord[] featureRecords;
    private Feature[] features;

    /** Creates new FeatureList */
    public FeatureList(RandomAccessFile raf, int offset) throws IOException {
        raf.seek(offset);
        featureCount = raf.readUnsignedShort();
        featureRecords = new FeatureRecord[featureCount];
        features = new Feature[featureCount];
        for (int i = 0; i < featureCount; i++) {
            featureRecords[i] = new FeatureRecord(raf);
        }
        for (int i = 0; i < featureCount; i++) {
            features[i] = new Feature(raf, offset + featureRecords[i].getOffset());
        }
    }

    public Feature findFeature(LangSys langSys, String tag) {
        if (tag.length() != 4) {
            return null;
        }
        int tagVal = ((tag.charAt(0)<<24)
            | (tag.charAt(1)<<16)
            | (tag.charAt(2)<<8)
            | tag.charAt(3));
        for (int i = 0; i < featureCount; i++) {
            if (featureRecords[i].getTag() == tagVal) {
                if (langSys.isFeatureIndexed(i)) {
                    return features[i];
                }
            }
        }
        return null;
    }

}
