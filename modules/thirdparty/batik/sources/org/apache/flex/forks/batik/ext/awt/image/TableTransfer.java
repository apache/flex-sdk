/*

   Copyright 2001,2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.ext.awt.image;


/**
 * TableTransfer.java
 *
 * This class defines the Table type transfer function for the
 * feComponentTransfer filter, as defined in chapter 15, section 11 of the SVG
 * specification.
 *
 * @author <a href="mailto:sheng.pei@sun.com">Sheng Pei</a>
 * @version $Id: TableTransfer.java,v 1.5 2004/08/18 07:13:49 vhardy Exp $ 
 */
public class TableTransfer implements TransferFunction {
    /**
     * This byte array stores the lookuptable data
     */
    public byte [] lutData;

    /**
     * This int array is the input table values from the user
     */
    public int [] tableValues;

    /*
     * The number of the input table's elements
     */
    private int n;

    /*
     * The input is an int array which will be used
     * later to construct the lut data
     */
    public TableTransfer(int [] tableValues){
        this.tableValues = tableValues;
        this.n = tableValues.length;
    }

    /*
     * This method will build the lut data. Each entry's
     * value will increase/decrease between the nearby
     * intervals.
     */
    private void buildLutData(){
        lutData = new byte [256];
        int j;
        float fi, r;
        int ffi, cfi;

        /*for (j=0; j<n; j++){
            System.out.println("tableValues[" + j + "] = " + tableValues[j]);
            }*/

        for (j=0; j<=255; j++){
            fi = j*(n-1)/255f;
            ffi = (int)Math.floor(fi);
            cfi = (ffi + 1)>(n-1)?(n-1):(ffi+1);
            r = fi - ffi;
            lutData[j] = (byte)((int)((tableValues[ffi] + r*(tableValues[cfi] - tableValues[ffi])))&0xff);
            // System.out.println("[" + j + "] : " + ffi + "/" + cfi + "/" + r);
        }
        
        /*for(j=0; j<=255; j++){
            System.out.print("[" + j + "] = " + (0xff & lutData[j]) + "  ");
            }

        System.out.println();
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
