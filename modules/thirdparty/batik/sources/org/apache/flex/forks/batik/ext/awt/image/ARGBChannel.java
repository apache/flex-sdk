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

import java.io.Serializable;

/**
 * Enumerated type for an ARGB Channel selector.
 *
 * @author <a href="mailto:vincent.hardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: ARGBChannel.java 475477 2006-11-15 22:44:28Z cam $
 */
public final class ARGBChannel implements Serializable{
    /**
     * Types.
     * 
     */
    public static final int CHANNEL_A = 3;
    public static final int CHANNEL_R = 2;
    public static final int CHANNEL_G = 1;
    public static final int CHANNEL_B = 0;

    /**
     * Strings used to get a more readable output when
     * a value is displayed.
     */
    public static final String RED = "Red";
    public static final String GREEN = "Green";
    public static final String BLUE = "Blue";
    public static final String ALPHA = "Alpha";

    /**
     * Channel values
     */
    public static final ARGBChannel R 
        = new ARGBChannel(CHANNEL_R, RED);
    public static final ARGBChannel G 
        = new ARGBChannel(CHANNEL_G, GREEN);
    public static final ARGBChannel B 
        = new ARGBChannel(CHANNEL_B, BLUE);
    public static final ARGBChannel A 
        = new ARGBChannel(CHANNEL_A, ALPHA);

    private String desc;
    private int val;

    /** 
     * Constructor is private so that no instances other than
     * the ones in the enumeration can be created.
     * @see #readResolve
     */
    private ARGBChannel(int val, String desc){
        this.desc = desc;
        this.val = val;
    }
    
    /**
     * @return description
     */
    public String toString(){
        return desc;
    }

    /**
     * Convenience for enumeration switching
     * @return value
     */
    public int toInt(){
        return val;
    }


    /**
     * This is called by the serialization code before it returns an unserialized
     * object. To provide for unicity of instances, the instance that was read
     * is replaced by its static equivalent
     */
    public Object readResolve() {
        switch(val){
        case CHANNEL_R:
            return R;
        case CHANNEL_G:
            return G;
        case CHANNEL_B:
            return B;
        case CHANNEL_A:
            return A;
        default:
            throw new Error("Unknown ARGBChannel value");
        }
    }
}
