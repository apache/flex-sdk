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

package flex2.compiler.util;

import java.util.SortedMap;
import java.util.TreeMap;

/**
 * Utility class that supports mapping line numbers in one file to
 * line numbers in another.
 */
public class LineNumberMap {
	private String oldName, newName;
	private final SortedMap<Range, Integer> map;
	private final Range lookup;		//	avoid creating new objects on lookup

	public LineNumberMap(String name, String newName) {
		this.oldName = name;
		this.newName = newName;
		this.map = new TreeMap<Range, Integer>();
		this.lookup = new Range(0, 1);
	}

	public LineNumberMap(String name) {
		this(name, name);
	}

	public final void setNewName(String newName) {
		this.newName = newName;
	}

	public final String getOldName() {
		return oldName;
	}

	public final String getNewName() {
		return newName;
	}

	public final void put(int oldStart, int newStart, int extent) {
		map.put(new Range(newStart, extent), new Integer(newStart - oldStart));
	}

	/**
	 * Maps line numbers in the 'new' code to the 'original' code
	 * @param newLine line number, 1-based
	 * @return 0 if the specified line is not in the ranges.
	 */
	public int get(int newLine) {
		lookup.start = newLine;
		Integer delta = map.get(lookup);
		return delta == null ? 0 : newLine - delta.intValue();
	}

	private final class Range implements Comparable {
		private int start, extent;

		Range(int start, int extent) {
			this.start = start;
			this.extent = extent;
		}

		/**
		 * Compares Range starts, then ends. Containment is considered equality. This gives a stable sort and the desired
		 * lookup behavior when a) keys are nonoverlapping, b) lookup values are subranges of keys. Both are true here.
		 * @param o Range object to compare
		 * @return
		 */
		public final int compareTo(Object o) {
			if (!(o instanceof Range)) {
				throw new IllegalArgumentException("argument must be Range");
			}
			Range e = (Range) o;
			return start < e.start ? -1 : (start + extent > e.start + e.extent) ? 1 : 0;
		}

		public String toString()
		{
			return "Range: start = " + start + ", extent = " + extent;
		}
	}

	// error messages
}
