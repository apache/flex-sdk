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

package flash.swf.debug;

/**
 * This object holds the script for an AS2 debug module, and its name,
 * lines, and the offset value of each of the debug offsets that
 * points within this script.
 *
 * @author Edwin Smith
 */
public class DebugModule
{
	public long id;
    public int bitmap;
    public String name;
    public String text;

    /** offsets[n] = offset of line n */
    public int[] offsets;

    /** index[n] = index of end of line n in text */
    public int[] index;

	/* is this module potentially corrupt; see 81918 */
    public boolean corrupt = false;

    public boolean addOffset(LineRecord lr, int offset)
    {
		boolean worked = true;
        if (lr.lineno < offsets.length)
        {
            offsets[lr.lineno] = offset;
        }
        else
        {
			// We have a condition 81918/78188 whereby Matador can produce a swd
			// where module ids were not unique, resulting in collision of offset records.
			// The best we can do is to mark the entire module as bad
			corrupt = true;
			worked = false;
        }
		return worked;
    }

    public boolean equals(Object obj)
    {
        if (obj == this) return true;
        if (!(obj instanceof DebugModule)) return false;
        DebugModule other = (DebugModule) obj;
        return this.bitmap == other.bitmap &&
                this.name.equals(other.name) &&
                this.text.equals(other.text);
    }

    public int hashCode()
    {
        return name.hashCode() ^ text.hashCode() ^ bitmap;
    }

    public void setText(String text)
    {
        this.text = text;

        int count = 1;

        int length = text.length();
        int last;
        for (int i=eolIndexOf(text); i != -1; i = eolIndexOf(text,last))
        {
            last = i+1;
            count++;
        }
        // allways make room for the last line whether it is empty or not.
        count++;

        index = new int[count];
        index[0] = 0;
        count = 1;
        for (int i=eolIndexOf(text); i != -1; i = eolIndexOf(text,last))
        {
            index[count++] = last = i+1;
        }
        index[count++] = length;

        offsets = new int[count];
    }

	public int getLineNumber(int offset)
    {
        int closestMatch = 0;
        for(int i=0; i < offsets.length; i++)
        {
            int delta = offset - offsets[i];
            if(delta >= 0 && delta < (offset - offsets[closestMatch]))
                closestMatch = i;
        }
        return closestMatch;
    }

	public static int eolIndexOf(String text) { return eolIndexOf(text, 0); }

	public static int eolIndexOf(String text, int i)
	{
		int at = -1;

		// scan starting at location i
		int size = text.length();
		while(i < size && at < 0)
		{
			char c = text.charAt(i);

			// newline?
			if (c == '\n')
				at = i;

			// carriage return?
			else if (c == '\r')
			{
				at = i;

				// might be cr/newline...chew pacman chew...
				if (i+1 < size && text.charAt(i+1) == '\n')
					at++;
			}

			// some crack may use form feeds?
			else if (c == '\f')
				at = i;

			i++;
		}
		return at;
	}

    public static void main(String[] args)
    {
        new DebugModule().setText("hello");
    }
}
