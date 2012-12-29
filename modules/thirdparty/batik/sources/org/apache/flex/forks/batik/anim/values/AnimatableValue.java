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
package org.apache.flex.forks.batik.anim.values;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Locale;

import org.apache.flex.forks.batik.dom.anim.AnimationTarget;

/**
 * An abstract class for values in the animation engine.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatableValue.java 475477 2006-11-15 22:44:28Z cam $
 */
public abstract class AnimatableValue {

    /**
     * A formatting object to get CSS compatible float strings.
     */
    protected static DecimalFormat decimalFormat = new DecimalFormat
        ("0.0###########################################################",
         new DecimalFormatSymbols(Locale.ENGLISH));

    /**
     * The target of the animation.
     */
    protected AnimationTarget target;

    /**
     * Whether this value has changed since the last call to
     * {@link #hasChanged()}.  This must be updated within {@link #interpolate}
     * in descendant classes.
     */
    protected boolean hasChanged = true;

    /**
     * Creates a new AnimatableValue.
     */
    protected AnimatableValue(AnimationTarget target) {
        this.target = target;
    }

    /**
     * Returns a CSS compatible string version of the specified float.
     */
    public static String formatNumber(float f) {
        return decimalFormat.format(f);
    }

    /**
     * Performs interpolation to the given value.
     * @param result the object in which to store the result of the
     *               interpolation, or null if a new object should be created
     * @param to the value this value should be interpolated towards, or null
     *           if no actual interpolation should be performed
     * @param interpolation the interpolation distance, 0 &lt;= interpolation
     *                      &lt;= 1
     * @param accumulation an accumulation to add to the interpolated value 
     * @param multiplier an amount the accumulation values should be multiplied
     *                   by before being added to the interpolated value
     */
    public abstract AnimatableValue interpolate(AnimatableValue result,
                                                AnimatableValue to,
                                                float interpolation,
                                                AnimatableValue accumulation,
                                                int multiplier);

    /**
     * Returns whether two values of this type can have their distance
     * computed, as needed by paced animation.
     */
    public abstract boolean canPace();

    /**
     * Returns the absolute distance between this value and the specified other
     * value.
     */
    public abstract float distanceTo(AnimatableValue other);

    /**
     * Returns a zero value of this AnimatableValue's type.
     */
    public abstract AnimatableValue getZeroValue();

    /**
     * Returns the CSS text representation of the value.
     */
    public String getCssText() {
        return null;
    }
    
    /**
     * Returns whether the value in this AnimatableValue has been modified.
     */
    public boolean hasChanged() {
        boolean ret = hasChanged;
        hasChanged = false;
        return ret;
    }

    /**
     * Returns a string representation of this object.  This should be
     * overridden in classes that do not have a CSS representation.
     */
    public String toStringRep() {
        return getCssText();
    }

    /**
     * Returns a string representation of this object prefixed with its
     * class name.
     */
    public String toString() {
        return getClass().getName() + "[" + toStringRep() + "]";
    }
}
