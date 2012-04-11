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

package flash.swf.tags;

import flash.swf.TagHandler;

/**
 * This class represents a CSMTextSettings SWF tag.
 *
 * @author Brian Deitte
 */
public class CSMTextSettings extends DefineTag
{
    public CSMTextSettings()
    {
        super(stagCSMTextSettings);
    }

    public void visit(TagHandler h)
	{
   		h.csmTextSettings(this);
	}

    public boolean equals(Object object)
    {
        boolean isEqual = false;
        if (super.equals(object) &&  (object instanceof CSMTextSettings))
        {
            CSMTextSettings settings = (CSMTextSettings)object;
            if (textReference.equals(settings.textReference) &&
                styleFlagsUseSaffron == settings.styleFlagsUseSaffron &&
                gridFitType == settings.gridFitType &&
                thickness == settings.thickness &&
                sharpness == settings.sharpness)
            {
                isEqual = true;
            }
        }
        return isEqual;
    }

    public DefineTag textReference;
    public int styleFlagsUseSaffron; // 0 if off, 1 if on
    public int gridFitType; // 0 if none, 1 if pixel, 2 if subpixel
    public long thickness;
    public long sharpness;
}
