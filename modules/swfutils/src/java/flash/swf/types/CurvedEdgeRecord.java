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
 * This class extends EdgeRecord by adding support for curve data.
 *
 * @author Clement Wong
 */
public class CurvedEdgeRecord extends EdgeRecord
{
    public int controlDeltaX;
	public int controlDeltaY;
	public int anchorDeltaX;
	public int anchorDeltaY;

	public void addToDelta(int xTwips, int yTwips)
	{
		anchorDeltaX += xTwips;
		anchorDeltaY += yTwips;
	}
	
	public String toString()
	{
		return "Curve: cx=" + controlDeltaX + " cy=" + controlDeltaY + " dx=" + anchorDeltaX + " dy=" + anchorDeltaY;
	}

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (super.equals(object) && (object instanceof CurvedEdgeRecord))
        {
            CurvedEdgeRecord curvedEdgeRecord = (CurvedEdgeRecord) object;

            if ( (curvedEdgeRecord.controlDeltaX == this.controlDeltaX) &&
                 (curvedEdgeRecord.controlDeltaY == this.controlDeltaY) &&
                 (curvedEdgeRecord.anchorDeltaX == this.anchorDeltaX) &&
                 (curvedEdgeRecord.anchorDeltaY == this.anchorDeltaY) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }
}
