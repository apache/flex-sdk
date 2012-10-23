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
 * IdentityTransfer.java
 *
 * This class defines the Identity type transfer function for the
 * feComponentTransfer filter, as defined in chapter 15, section 11 of the SVG
 * specification.
 *
 * @author <a href="mailto:sheng.pei@sun.com">Sheng Pei</a>
 * @version $Id: IdentityTransfer.java 475477 2006-11-15 22:44:28Z cam $ 
 */
public class IdentityTransfer implements TransferFunction {
    /**
     * This byte array stores the lookuptable data
     */
    public static byte [] lutData = new byte [256];

    /*
     * This method will build the lut data. Each entry
     * has the value as its index.
     */
    static {
        // as Identity, the lookup table contains
        // the same value as the index
        for (int j=0; j<=255; j++) {
            lutData[j] = (byte)j;
        }
    }

    /**
     * This method will return the lut data in order
     * to construct a LookUpTable object
     */
    public byte [] getLookupTable(){
        return lutData;
    }
}
