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

package flash.fonts;

import flash.util.IntMapLRUCache;

/**
 * A <code>FontSet</code> is a collection of styles or "faces" for a
 * given font.  Each <code>FontFace</code> is associated with a
 * <code>java.awt.Font</code> instance and contains a cache of
 * converted glyphs, or character shape outlines.
 *
 * @author Peter Farland
 */
public class FontSet
{
    public FontSet(int maxFacesPerFont)
    {
        entries = new IntMapLRUCache(maxFacesPerFont, maxFacesPerFont)
        {

            public Object fetch(int key)
            {
                throw new UnsupportedOperationException();
            }
        };
    }

    public FontFace put(int style, FontFace entry)
    {
        return (FontFace)entries.put(style, entry);
    }

    public FontFace get(int style)
    {
        return (FontFace)entries.get(style);
    }

    private IntMapLRUCache entries;

}
