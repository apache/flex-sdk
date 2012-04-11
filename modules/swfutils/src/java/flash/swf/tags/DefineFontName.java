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

/**
 * Stores the name and copyright information for a font.
 *
 * @author Brian Deitte
 */
public class DefineFontName extends DefineTag
{
    public DefineFontName()
    {
        super(stagDefineFontName);
    }

    public void visit(flash.swf.TagHandler h)
    {
        h.defineFontName(this);
    }

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof DefineFontName))
        {
            DefineFontName defineFontName = (DefineFontName) object;
            isEqual = (equals(font, defineFontName.font) &&
                       (equals(fontName, defineFontName.fontName)) &&
                       (equals(copyright, defineFontName.copyright)));
        }

        return isEqual;
    }

    public DefineFont font;
    public String fontName;
    public String copyright;
}
