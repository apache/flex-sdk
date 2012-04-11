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

package macromedia.asc.util;

import macromedia.asc.semantics.*;

/**
 * @author Jeff Dyer
 */
public final class Slots extends ObjectList<Slot>
{
	public boolean put(Slot slot)
	{
		// Find the position for this character using binary search
		int lo = -1;
		int hi = size();
		int id = slot.id;
		
		while (hi - lo > 1) {
			int pivot = (lo+hi)>>1;
			int testID = at(pivot).id;

			if (id == testID) {
				// Slot is already present 
				return true;
			} else if (id < testID) {
				hi = pivot;
			} else {
				lo = pivot;
			}
		}
		
		add(hi, slot);
		return true;
	}
	
	public Slot getByID(int id)
	{
		// Find the position for this character using binary search
		int lo = 0;
		int hi = size() - 1;

		// fail fast if the id is not in the range of slot id's in this object
		if( hi > lo && (id < at(lo).id || id > at(hi).id) )
			return null;
		
		while (lo <= hi) {
			int pivot = (lo+hi)>>1;
			Slot slot = at(pivot);
			int testID = slot.id;

			if (id == testID) {
				return slot;
			} else if (id < testID) {
				hi = pivot-1;
			} else {
				lo = pivot+1;
			}
		}
		
		return null;
	}
}

