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
 * GammaTransfer.java
 *
 * This class defines the Gamma type transfer function for the
 * feComponentTransfer filter, as defined in chapter 15, section 11 of the SVG
 * specification.
 *
 * @author <a href="mailto:sheng.pei@sun.com">Sheng Pei</a>
 * @version $Id: GammaTransfer.java 475477 2006-11-15 22:44:28Z cam $ 
 */
public class GammaTransfer implements TransferFunction {
    /**
     * This byte array stores the lookuptable data
     */
    public byte [] lutData;

    /**
     * The amplitude of the Gamma function
     */
    public float amplitude;

    /**
     * The exponent of the Gamma function
     */
    public float exponent;

    /**
     * The offset of the Gamma function
     */
    public float offset;

    /**
     * Three floats as the input for the Gamma function
     */
    public GammaTransfer(float amplitude, float exponent, float offset){
        this.amplitude = amplitude;
        this.exponent = exponent;
        this.offset = offset;
    }

    /*
     * This method will build the lut data. Each entry's
     * value is in form of "amplitude*pow(C, exponent) + offset"
     */
    private void buildLutData(){
        lutData = new byte [256];
        int j, v;
        for (j=0; j<=255; j++){
            v = (int)Math.round(255*(amplitude*Math.pow(j/255f, exponent)+offset));
            if(v > 255){
                v = (byte)0xff;
            }
            else if(v < 0){
                v = (byte)0x00;
            }
            lutData[j] = (byte)(v & 0xff);
        }
    }


    /**
     * This method will return the lut data in order
     * to construct a LookUpTable object
     */
    public byte [] getLookupTable(){
        buildLutData();
        return lutData;
    }
}
