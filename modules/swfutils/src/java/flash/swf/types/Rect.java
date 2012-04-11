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

import flash.swf.SwfEncoder;
import flash.swf.tags.DefineTag;

/**
 * A value object for rect data.
 *
 * @author Clement Wong
 */
public class Rect
{
    public Rect(int width, int height)
    {
        xMax = width;
        yMax = height;
        nbits();
    }

    public Rect()
    {
    }

    public Rect(int xMin, int xMax, int yMin, int yMax)
    {
        this.xMin = xMin;
        this.xMax = xMax;
        this.yMin = yMin;
        this.yMax = yMax;
    }

	public int xMin;
	public int xMax;
	public int yMin;
	public int yMax;

	public String toString()
	{
        if ((xMin != 0) || (yMin != 0))
        {
            return "(" + xMin + "," + yMin + "),(" + xMax + "," + yMax + ")";
        }
        else
        {
		    return new StringBuilder().append(xMax).append('x').append(yMax).toString();
        }
	}

    public int nbits()
    {
        int maxCoord = SwfEncoder.maxNum(xMin, xMax, yMin, yMax);
        return SwfEncoder.minBits(maxCoord,1);
    }

    public int getWidth()
    {
        return xMax-xMin;
    }

    public int getHeight()
    {
        return yMax-yMin;
    }

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof Rect)
        {
            Rect rect = (Rect) object;

            if ( (rect.xMin == this.xMin) &&
                 (rect.xMax == this.xMax) &&
                 (rect.yMin == this.yMin) &&
                 (rect.yMax == this.yMax) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

    public int hashCode() {
      int hashCode = super.hashCode();
      hashCode += DefineTag.PRIME * xMin;
      hashCode += DefineTag.PRIME * xMax;
      hashCode += DefineTag.PRIME * yMin;
      hashCode += DefineTag.PRIME * yMax;

      return hashCode;
    }

}
