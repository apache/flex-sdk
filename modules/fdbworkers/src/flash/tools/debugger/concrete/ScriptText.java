/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package flash.tools.debugger.concrete;

/**
 * Contains the text contents of a script and is able
 * to map line numbers to specific regions of the script (i.e. string)
 */
public class ScriptText
{
	private final String m_text;
	private int[]  m_lineMap;  // a 2-d array [2i] = startIndex and [2i+1] = endIndex for line i

	public ScriptText(String text)
	{
		m_text = text;
	}

	/* return a string containing the line number requested */
	public String getLine(int lineNum) 
	{
		determineLines();

		int index = lineNum-1;
		if (index < 0)
			; // throw 

		/* look into our mapping array */
		int start = m_lineMap[2*index];
		int end = m_lineMap[(2*index)+1];

		String s = m_text.substring(start, end);
		return s;
	}

	/* line count in module */
	public int getLineCount()
	{
		determineLines();
		return m_lineMap.length/2;
	}

	/**
	 * Build mapping tables based on the line count of 
	 * the given source string.
	 * 
	 * These tables allow us to compute starting and 
	 * ending locations of each line of the source file.
	 * 
	 * The assumption using this technique is that most
	 * lines of the source files will never be accessed 
	 * thus we only incur the overhead of 8 bytes 
	 * (start & end) per line, plus the actual string 
	 * contents each line a line is requested.
	 * 
	 * Thus we need  8 * num_files * num_lines_per_file bytes
	 * for all these maps.
	 * 
	 * For example, say each file is 1000 lines and we have
	 * 400 source files;  We would consume 3.2MB.  With 
	 * each request we would allocate an additional 20+
	 * bytes for the string (assuming a 20B avg line length).
	 * 
	 * Allocating each line individually we would consume
	 * 1000 * 400 * 20 = 8MB.
	 * 
	 * It is debatable whether this scheme is more efficient
	 * than actually builing an array of Strings to contain
	 * the lines, but gut feel says it is ;)
	 */
	private synchronized void determineLines()
	{
		// determineLines() is done on demand in order to avoid wasting time
		// doing this for every file; so check if we've already done it
		if (m_lineMap != null)
			return;

		int count = lineCountFor(m_text) + 1; // add 1 to the line count to handle newline on last line

		// allocated our maps (really a 2-d array where [i] = startAt & [i+1] = endAt )
		m_lineMap = new int[(2*count)+1];

		int i = 0;
		int lineNum = 0;
		int startAt = 0;
		int endAt = 0;
		int length = m_text.length();
		char c = '\0';
		while(i < length)
		{
			/* end of line */
			c = m_text.charAt(i++);
			if (c == '\n' || c == '\r')
			{
				m_lineMap[2*lineNum] = startAt;
				m_lineMap[(2*lineNum)+1] = endAt;
				lineNum++;

				/* do we need to chew a CR LF combo */
				if (c == '\r' && i < length && m_text.charAt(i) == '\n')
					i++;

				startAt = i;
				endAt = i;
			}
			else 
				endAt++;
		}

		/* need to add the last line? */
		if (startAt != endAt)
		{
			/* add the last line if not empty */
			m_lineMap[2*lineNum] = startAt;
			m_lineMap[(2*lineNum)+1] = endAt;
		}
	}
 
	/**
	 * Count the number of lines within this string.
	 */
	public static int lineCountFor(String s)
	{
		int i = 0;
		int lineNum = 0;
		int length = s.length();
		char c = '\0';
		while(i < length)
		{
			/* end of line */
			c = s.charAt(i++);
			if (c == '\n' || c == '\r')
			{
				lineNum++;

				/* do we need to chew a CR LF combo */
				if (c == '\r' && i < length && s.charAt(i) == '\n')
					i++;
			}
		}
		return lineNum;
	}
}
