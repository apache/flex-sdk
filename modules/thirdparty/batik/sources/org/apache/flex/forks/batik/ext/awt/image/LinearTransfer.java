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
 * LinearTransfer.java
 *
 * This class defines the Linear type transfer function for the
 * feComponentTransfer filter, as defined in chapter 15, section 11 of the SVG
 * specification.
 *
 * @author <a href="mailto:sheng.pei@sun.com">Sheng Pei</a>
 * @version $Id: LinearTransfer.java 475477 2006-11-15 22:44:28Z cam $ 
 */
public class LinearTransfer implements TransferFunction {
    /**
     * This byte array stores the lookuptable data
     */
    public byte [] lutData;

    /**
     * The slope of the linear function
     */
    public float slope;

    /**
     * The intercept of the linear function
     */
    public float intercept;

    /**
     * Two floats as the input for the function
     */
    public LinearTransfer(float slope, float intercept){
        this.slope = slope;
        this.intercept = intercept;
    }

    /*
     * This method will build the lut data. Each entry's
     * value is in form of "slope*C+intercept"
     */
    private void buildLutData(){
        lutData = new byte [256];
        int j, value;
        float scaledInt = (intercept*255f)+0.5f;
        for (j=0; j<=255; j++){
            value = (int)(slope*j+scaledInt);
            if(value < 0){
                value = 0;
            }
            else if(value > 255){
                value = 255;
            }
            lutData[j] = (byte)(0xff & value);
        }

        /*System.out.println("Linear : " + slope + " / " + intercept);
        for(j=0; j<=255; j++){
            System.out.print("[" + j + "] = " + (0xff & lutData[j]) + " ");
        }

        System.out.println();*/
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
