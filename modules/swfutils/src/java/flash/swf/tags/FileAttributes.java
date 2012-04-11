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

import flash.swf.Tag;
import flash.swf.TagHandler;

/**
 * FileAttributes defines whole-SWF attributes. It is a place to put
 * information that belongs in the SWF header, but for which the SWF
 * header has no space.  FileAttributes must be the first tag in a SWF
 * file, or it will be ignored.
 * <p>
 * It is our hope that FileAttributes will be the only tag ever to
 * have this requirement of being located at a specific place in the
 * file.  (Otherwise, a complicated set of ordering rules could
 * ensue.)
 * <p>
 * Any information that applies to the whole SWF should hopefully be
 * incorporated into the FileAttributes tag.
 *
 * @author Peter Farland
 */
public class FileAttributes extends Tag
{
    public boolean hasMetadata;
    public boolean actionScript3;
    public boolean suppressCrossDomainCaching;
    public boolean swfRelativeUrls;
    public boolean useNetwork;
    public boolean useGPU;
    public boolean useDirectBlit;

    public FileAttributes()
    {
        super(stagFileAttributes);
    }

    public void visit(TagHandler handler)
    {
        handler.fileAttributes(this);
    }

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof FileAttributes))
        {
            FileAttributes tag = (FileAttributes)object;

            if ((tag.hasMetadata == this.hasMetadata) &&
                (tag.actionScript3 == this.actionScript3) &&
                (tag.suppressCrossDomainCaching == this.suppressCrossDomainCaching) &&
                (tag.swfRelativeUrls == this.swfRelativeUrls) &&
                (tag.useDirectBlit == this.useDirectBlit) &&
                (tag.useGPU == this.useGPU) &&
                (tag.useNetwork == this.useNetwork))
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

}
