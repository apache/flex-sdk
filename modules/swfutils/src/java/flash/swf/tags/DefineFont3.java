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
 * The DefineFont3 tag extends the functionality of the DefineFont2
 * tag by expressing the Shape coordinates in the glyph shape table at
 * 20 times the resolution. The EM square units are converted to twips
 * to allow fractional resolution to 1/20th of a unit. The DefineFont3
 * tag was introduced in SWF 8.
 * 
 * @author Clement Wong
 * @author Peter Farland
 */
public class DefineFont3 extends DefineFont2
{
    /**
     * Constructor.
     */
    public DefineFont3()
    {
        super(stagDefineFont3);
    }

    //--------------------------------------------------------------------------
    //
    // Fields and Bean Properties
    //
    //--------------------------------------------------------------------------

    public DefineFontAlignZones zones;

    //--------------------------------------------------------------------------
    //
    // Visitor Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Invokes the defineFont visitor on the given TagHandler.
     * 
     * @param handler The SWF TagHandler.
     */
    public void visit(TagHandler handler)
    {
        if (code == stagDefineFont3)
            handler.defineFont3(this);
    }

    //--------------------------------------------------------------------------
    //
    // Utility Methods
    //
    //--------------------------------------------------------------------------

    /**
     * Tests whether this DefineFont3 tag is equivalent to another DefineFont3
     * tag instance.
     * 
     * @param object Another DefineFont3 instance to test for equality.
     * @return true if the given instance is considered equal to this instance
     */
    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof DefineFont3 && super.equals(object))
        {
            DefineFont3 defineFont = (DefineFont3)object;

            // DefineFontAlignZones already checks if its font is equal, so we
            // don't check here to avoid circular equality checking...
            //if (equals(defineFont.zones, this.zones))

            isEqual = true;

        }

        return isEqual;
    }
}