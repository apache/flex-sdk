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

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * ExportAssets makes portions of a SWF file available for import by
 * other SWF files (see ImportAssets). For example, ten Flash movies
 * that are all part of the same website can share an embedded custom
 * font if one movie embeds the font and exports the font
 * character. Each exported character is identified by a string. Any
 * type of character can be exported.
 *
 * @author Clement Wong
 * @since SWF5
 */
public class ExportAssets extends Tag
{
	public ExportAssets()
	{
		super(stagExportAssets);
	}

    public void visit(TagHandler h)
	{
		h.exportAssets(this);
	}

	public Iterator<Tag> getReferences()
    {
        return exports.iterator();
    }

    /** list of DefineTags exported by this ExportTag */
    public List<Tag> exports = new ArrayList<Tag>();

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof ExportAssets))
        {
            ExportAssets exportAssets = (ExportAssets) object;

            if ( equals(exportAssets.exports, this.exports) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
