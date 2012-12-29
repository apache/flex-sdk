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
package org.apache.flex.forks.batik.dom.svg;

import org.apache.flex.forks.batik.dom.anim.AnimationTarget;

/**
 * Stores information about a specific XML attribute or CSS property.
 *
 * @version $Id: TraitInformation.java 582434 2007-10-06 02:11:51Z cam $
 */
public class TraitInformation {

    // Constants for percentage interpretation.
    public static final short PERCENTAGE_FONT_SIZE       = AnimationTarget.PERCENTAGE_FONT_SIZE;
    public static final short PERCENTAGE_VIEWPORT_WIDTH  = AnimationTarget.PERCENTAGE_VIEWPORT_WIDTH;
    public static final short PERCENTAGE_VIEWPORT_HEIGHT = AnimationTarget.PERCENTAGE_VIEWPORT_HEIGHT;
    public static final short PERCENTAGE_VIEWPORT_SIZE   = AnimationTarget.PERCENTAGE_VIEWPORT_SIZE;

    /**
     * Whether this trait can be animated.
     */
    protected boolean isAnimatable;

    // /**
    //  * Whether animations of this trait can be additive.
    //  */
    // protected boolean isAdditive;

    /**
     * The SVG type of this trait.
     */
    protected int type;

    /**
     * What percentages in this trait are relative to.
     */
    protected short percentageInterpretation;

    /**
     * Creates a new TraitInformation object.
     */
    public TraitInformation(boolean isAnimatable, // boolean isAdditive,
                            int type, short percentageInterpretation) {
        this.isAnimatable = isAnimatable;
        // this.isAdditive = isAdditive;
        this.type = type;
        this.percentageInterpretation = percentageInterpretation;
    }

    /**
     * Creates a new TraitInformation object.
     */
    public TraitInformation(boolean isAnimatable, // boolean isAdditive,
                            int type) {
        this.isAnimatable = isAnimatable;
        // this.isAdditive = isAdditive;
        this.type = type;
        this.percentageInterpretation = -1;
    }

    /**
     * Returns whether this trait is animatable.
     */
    public boolean isAnimatable() {
        return isAnimatable;
    }

    // /**
    //  * Returns whether animations of this trait can be additive.
    //  */
    // public boolean isAdditive() {
    //     return isAdditive;
    // }

    /**
     * Returns the SVG type of this trait.
     */
    public int getType() {
        return type;
    }

    /**
     * Returns how percentage values in this trait are resolved.
     */
    public short getPercentageInterpretation() {
        return percentageInterpretation;
    }
}
