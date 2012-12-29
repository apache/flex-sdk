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
package org.apache.flex.forks.batik.ext.awt.image;

/**
 * This is a typesafe enumeration of the standard Composite rules for
 * the CompositeRable operation. (over, in, out, atop, xor, arith)
 *
 * @author <a href="mailto:Thomas.DeWeeese@Kodak.com">Thomas DeWeese</a>
 * @version $Id: PadMode.java 475477 2006-11-15 22:44:28Z cam $
 */
public final class PadMode implements java.io.Serializable {
      /** Pad edges with zeros */
    public static final int MODE_ZERO_PAD = 1;

      /** Pad edges by replicating edge pixels */
    public static final int MODE_REPLICATE = 2;

      /** Pad edges by wrapping around edge pixels */
    public static final int MODE_WRAP = 3;

      /** Pad edges with zeros */
    public static final PadMode ZERO_PAD = new PadMode(MODE_ZERO_PAD);

      /** Pad edges by replicating edge pixels */
    public static final PadMode REPLICATE = new PadMode(MODE_REPLICATE);

      /** Pad edges by replicating edge pixels */
    public static final PadMode WRAP = new PadMode(MODE_WRAP);

    /**
     * Returns the mode of this pad mode.
     */
    public int getMode() {
        return mode;
    }

      /**
       * The pad mode for this object.
       */
    private int mode;

    private PadMode(int mode) {
        this.mode = mode;
    }

    /**
     * This is called by the serialization code before it returns
     * an unserialized object. To provide for unicity of
     * instances, the instance that was read is replaced by its
     * static equivalent. See the serialiazation specification for
     * further details on this method's logic.
     */
    private Object readResolve() throws java.io.ObjectStreamException {
        switch(mode){
        case MODE_ZERO_PAD:
            return ZERO_PAD;
        case MODE_REPLICATE:
            return REPLICATE;
        case MODE_WRAP:
            return WRAP;
        default:
            throw new Error("Unknown Pad Mode type");
        }
    }
}
