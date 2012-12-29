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

import java.util.Arrays;

import org.apache.flex.forks.batik.dom.anim.AnimationTarget;

/**
 * An SVG path value in the animation system.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AnimatablePathDataValue.java 479349 2006-11-26 11:54:23Z cam $
 */
public class AnimatablePathDataValue extends AnimatableValue {

    /**
     * The path commands.  These must be one of the PATHSEG_*
     * constants defined in {@link org.w3c.dom.svg.SVGPathSeg}.
     */
    protected short[] commands;

    /**
     * The path parameters.  Also includes the booleans.
     */
    protected float[] parameters;

    /**
     * Creates a new, uninitialized AnimatablePathDataValue.
     */
    protected AnimatablePathDataValue(AnimationTarget target) {
        super(target);
    }

    /**
     * Creates a new AnimatablePathDataValue.
     */
    public AnimatablePathDataValue(AnimationTarget target, short[] commands,
                                   float[] parameters) {
        super(target);
        this.commands = commands;
        this.parameters = parameters;
    }
    
    /**
     * Performs interpolation to the given value.
     */
    public AnimatableValue interpolate(AnimatableValue result,
                                       AnimatableValue to, float interpolation,
                                       AnimatableValue accumulation,
                                       int multiplier) {
        AnimatablePathDataValue toValue = (AnimatablePathDataValue) to;
        AnimatablePathDataValue accValue =
            (AnimatablePathDataValue) accumulation;

        boolean hasTo = to != null;
        boolean hasAcc = accumulation != null;
        boolean canInterpolate = hasTo
            && toValue.parameters.length == parameters.length
            && Arrays.equals(toValue.commands, commands);
        boolean canAccumulate = hasAcc
            && accValue.parameters.length == parameters.length
            && Arrays.equals(accValue.commands, commands);

        AnimatablePathDataValue base;
        if (!canInterpolate && hasTo && interpolation >= 0.5) {
            base = toValue;
        } else {
            base = this;
        }
        int cmdCount = base.commands.length;
        int paramCount = base.parameters.length;

        AnimatablePathDataValue res;
        if (result == null) {
            res = new AnimatablePathDataValue(target);
            res.commands = new short[cmdCount];
            res.parameters = new float[paramCount];
            System.arraycopy(base.commands, 0, res.commands, 0, cmdCount);
        } else {
            res = (AnimatablePathDataValue) result;
            if (res.commands == null || res.commands.length != cmdCount) {
                res.commands = new short[cmdCount];
                System.arraycopy(base.commands, 0, res.commands, 0, cmdCount);
                res.hasChanged = true;
            } else {
                if (!Arrays.equals(base.commands, res.commands)) {
                    System.arraycopy(base.commands, 0, res.commands, 0,
                                     cmdCount);
                    res.hasChanged = true;
                }
            }
        }

        for (int i = 0; i < paramCount; i++) {
            float newValue = base.parameters[i];
            if (canInterpolate) {
                newValue += interpolation * (toValue.parameters[i] - newValue);
            }
            if (canAccumulate) {
                newValue += multiplier * accValue.parameters[i];
            }
            if (res.parameters[i] != newValue) {
                res.parameters[i] = newValue;
                res.hasChanged = true;
            }
        }

        return res;
    }

    /**
     * Returns the array of path data commands.
     */
    public short[] getCommands() {
        return commands;
    }

    /**
     * Returns the array of path data parameters.
     */
    public float[] getParameters() {
        return parameters;
    }

    /**
     * Returns whether two values of this type can have their distance
     * computed, as needed by paced animation.
     */
    public boolean canPace() {
        return false;
    }

    /**
     * Returns the absolute distance between this value and the specified other
     * value.
     */
    public float distanceTo(AnimatableValue other) {
        return 0f;
    }

    /**
     * Returns a zero value of this AnimatableValue's type.
     */
    public AnimatableValue getZeroValue() {
        short[] cmds = new short[commands.length];
        System.arraycopy(commands, 0, cmds, 0, commands.length);
        float[] params = new float[parameters.length];
        return new AnimatablePathDataValue(target, cmds, params);
    }

    /**
     * The path data commands.
     */
    protected static final char[] PATH_COMMANDS = {
        ' ', 'z', 'M', 'm', 'L', 'l', 'C', 'c', 'Q', 'q', 'A', 'a', 'H', 'h',
        'V', 'v', 'S', 's', 'T', 't'
    };

    /**
     * The number of parameters for each path command.
     */
    protected static final int[] PATH_PARAMS = {
        0, 0, 2, 2, 2, 2, 6, 6, 4, 4, 7, 7, 1, 1, 1, 1, 4, 4, 2, 2
    };

    /**
     * Returns a string representation of this object.
     */
    public String toStringRep() {
        StringBuffer sb = new StringBuffer();
        int k = 0;
        for (int i = 0; i < commands.length; i++) {
            sb.append(PATH_COMMANDS[commands[i]]);
            for (int j = 0; j < PATH_PARAMS[commands[i]]; j++) {
                sb.append(' ');
                sb.append(parameters[k++]);
            }
        }
        return sb.toString();
    }
}
