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

import flash.swf.TagHandler;
import flash.swf.tags.DefineTag;

/**
 * This represents an import record, which is serialized as a member
 * of an ImportAssets tag.  We subclass DefineTag because definitions
 * are the things that get imported; any tag that refers to a
 * definition can also refer to an import of another definition.
 *
 * @author Edwin Smith
 */
public class ImportRecord extends DefineTag
{
    public ImportRecord()
    {
        super(stagImportAssets);
    }

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof ImportRecord))
        {
            ImportRecord importRecord = (ImportRecord) object;

            if ( equals(importRecord.name, this.name))
            {
                isEqual = true;
            }
        }

        return isEqual;
    }    

    public void visit(TagHandler h)
    {
        // this can't be visited, but you can visit the ImportAssets that owns this record.
       assert (false);
    }
}
