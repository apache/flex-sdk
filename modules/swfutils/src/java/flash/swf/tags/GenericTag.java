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
 * Tag that just contains a byte[] payload.  We can use this to hold
 * any tag in its packed format, and also to hold tags that don't need
 * any unpacking.
 *
 * @author Clement Wong
 */
public class GenericTag extends flash.swf.Tag
{
    public GenericTag(int code)
    {
        super(code);
    }

    public void visit(flash.swf.TagHandler h)
	{
        switch (code)
        {
        case stagJPEGTables:
            h.jpegTables(this);
            break;
        case stagProtect:
            h.protect(this);
            break;
        case stagSoundStreamBlock:
            h.soundStreamBlock(this);
            break;
        default:
            h.unknown(this);
            break;
        }
	}

    public byte[] data;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof GenericTag))
        {
            GenericTag genericTag = (GenericTag) object;

            if ( equals(genericTag.data, this.data) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
