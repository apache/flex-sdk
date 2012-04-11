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
import flash.swf.types.ImportRecord;

import java.util.List;

/**
 * This represents a ImportAssets SWF tag.
 *
 * @author Clement Wong
 */
public class ImportAssets extends Tag
{
	public ImportAssets(int code)
	{
		super(code);
	}

    public void visit(TagHandler h)
	{
		if (code == stagImportAssets)
			h.importAssets(this);
		else
			h.importAssets2(this);
	}

    public String url;
	public List<ImportRecord> importRecords;

    public boolean downloadNow;
    public byte[] SHA1;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof ImportAssets))
        {
            ImportAssets importAssets = (ImportAssets) object;

            if ( equals(importAssets.url, this.url) &&
            	 (importAssets.downloadNow == this.downloadNow) &&
            	 digestEquals(importAssets.SHA1, this.SHA1) &&
                 equals(importAssets.importRecords,  this.importRecords))
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
    
    private boolean digestEquals(byte[] d1, byte[] d2)
    {
    	if (d1 == null && d2 == null)
    	{
    		return true;
    	}
    	else
    	{
    		for (int i = 0; i < 20; i++)
    		{
    			if (d1[i] != d2[i])
    			{
    				return false;
    			}
    		}
    		return true;
    	}
    }
}
