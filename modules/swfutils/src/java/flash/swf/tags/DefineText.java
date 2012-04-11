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
import flash.swf.types.Matrix;
import flash.swf.types.Rect;
import flash.swf.types.TextRecord;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

/**
 * Represents a DefineText SWF tag.
 *
 * @author Clement Wong
 */
public class DefineText extends DefineTag
{
    public DefineText(int code)
    {
        super(code);
        records=new LinkedList<TextRecord>();
    }

    public void visit(TagHandler h)
	{
        if (code == stagDefineText)
    		h.defineText(this);
        else
            h.defineText2(this);
	}

	public Iterator<Tag> getReferences()
    {
        LinkedList<Tag> refs = new LinkedList<Tag>();
        for (int i = 0; i < records.size(); ++i )
            records.get(i).getReferenceList( refs );

        return refs.iterator();
    }

    public Rect bounds;
    public Matrix matrix;
    public List<TextRecord> records;
    public CSMTextSettings csmTextSettings;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof DefineText))
        {
            DefineText defineText = (DefineText) object;

            if ( equals(defineText.bounds, this.bounds) &&
                 equals(defineText.matrix, this.matrix) &&
                 equals(defineText.records, this.records))
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

    public int hashCode()
    {
      int hashCode = super.hashCode();

      if (bounds!=null)
      {
        hashCode += bounds.hashCode();
      }

      if (records!=null) {
        hashCode += records.size();
      }
      return hashCode;
    }
}
