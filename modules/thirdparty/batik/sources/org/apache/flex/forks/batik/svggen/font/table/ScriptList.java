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
 * @version $Id: ScriptList.java 475477 2006-11-15 22:44:28Z cam $
 */
public class ScriptList {

    private int scriptCount = 0;
    private ScriptRecord[] scriptRecords;
    private Script[] scripts;
    
    /** Creates new ScriptList */
    protected ScriptList(RandomAccessFile raf, int offset) throws IOException {
        raf.seek(offset);
        scriptCount = raf.readUnsignedShort();
        scriptRecords = new ScriptRecord[scriptCount];
        scripts = new Script[scriptCount];
        for (int i = 0; i < scriptCount; i++) {
            scriptRecords[i] = new ScriptRecord(raf);
        }
        for (int i = 0; i < scriptCount; i++) {
            scripts[i] = new Script(raf, offset + scriptRecords[i].getOffset());
        }
    }

    public int getScriptCount() {
        return scriptCount;
    }
    
    public ScriptRecord getScriptRecord(int i) {
        return scriptRecords[i];
    }
    
    public Script findScript(String tag) {
        if (tag.length() != 4) {
            return null;
        }
        int tagVal = ((tag.charAt(0)<<24)
            | (tag.charAt(1)<<16)
            | (tag.charAt(2)<<8)
            | tag.charAt(3));
        for (int i = 0; i < scriptCount; i++) {
            if (scriptRecords[i].getTag() == tagVal) {
                return scripts[i];
            }
        }
        return null;
    }

}

