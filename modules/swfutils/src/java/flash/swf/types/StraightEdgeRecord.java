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

/**
 * This class extends EdgeRecord by adding support for an x and y
 * delta.
 *
 * @author Clement Wong
 */
public class StraightEdgeRecord extends EdgeRecord
{
	public int deltaX = 0;
	public int deltaY = 0;

    public StraightEdgeRecord setX(int x)
    {
        deltaX = x;
        return this;
    }
    
    public StraightEdgeRecord setY(int y)
    {
        deltaY = y;
        return this;
    }

    public StraightEdgeRecord()
    {
    }
    
    public StraightEdgeRecord(int deltaX, int deltaY)
    {
        this.deltaX = deltaX;
        this.deltaY = deltaY;
    }

	public void addToDelta(int xTwips, int yTwips)
	{
		deltaX += xTwips;
		deltaY += yTwips;
	}
	public String toString()
	{
		return "Line: x=" + deltaX + " y=" + deltaY;
	}

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof StraightEdgeRecord)
        {
            StraightEdgeRecord straightEdgeRecord = (StraightEdgeRecord) object;

            if ( (straightEdgeRecord.deltaX == this.deltaX) &&
                 (straightEdgeRecord.deltaY == this.deltaY) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
