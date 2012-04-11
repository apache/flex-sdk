/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flash.swf.types;

import java.util.Arrays;

/**
 * A value object for gradient data. 
 *
 * @author Roger Gonzalez
 */
public class Gradient
{
    public static final int SPREAD_MODE_PAD = 0;
    public static final int SPREAD_MODE_REFLECT = 1;
    public static final int SPREAD_MODE_REPEAT = 2;
    public static final int INTERPOLATION_MODE_NORMAL = 0;
    public static final int INTERPOLATION_MODE_LINEAR = 1;

    public int spreadMode;
    public int interpolationMode;
    public GradRecord[] records;

    public boolean equals(Object o)
    {
        if (!(o instanceof Gradient))
            return false;

        Gradient otherGradient = (Gradient) o;
        return ((otherGradient.spreadMode == spreadMode)
                && (otherGradient.interpolationMode == interpolationMode)
                && Arrays.equals(otherGradient.records, records));

    }
}
