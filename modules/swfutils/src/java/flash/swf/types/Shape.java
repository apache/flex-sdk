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

import flash.swf.Tag;
import flash.swf.TagHandler;
import java.util.Iterator;
import java.util.List;

/**
 * A value object for shape data.
 *
 * @author Clement Wong
 */
public class Shape
{
	public List<ShapeRecord> shapeRecords;

    public void visitDependents(TagHandler h)
    {
        Iterator<ShapeRecord> it = shapeRecords.iterator();
        while (it.hasNext())
        {
            ShapeRecord rec = it.next();
            rec.visitDependents(h);
        }
    }

    public void getReferenceList( List<Tag> refs )
    {
        Iterator<ShapeRecord> it = shapeRecords.iterator();

        while (it.hasNext())
        {
            ShapeRecord rec = it.next();
            rec.getReferenceList( refs );
        }
    }

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof Shape)
        {
            Shape shape = (Shape) object;

            if ( ( (shape.shapeRecords == null) && (this.shapeRecords == null) ) ||
                 ( (shape.shapeRecords != null) && (this.shapeRecords != null) &&
                   ArrayLists.equals( shape.shapeRecords, this.shapeRecords ) ) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
