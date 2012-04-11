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

import java.math.RoundingMode;

public class NumberUsage {

	public static final int use_Number = 0;
	public static final int use_decimal = 1;
	public static final int use_double = 2;
	public static final int use_int = 3;
	public static final int use_uint = 4;
	
	// the following number correspond to value in decNumber package used by VM
	public static final int round_CEILING = 0;
	public static final int round_UP = 1;
	public static final int round_HALF_UP = 2;
	public static final int round_HALF_EVEN = 3;
	public static final int round_HALF_DOWN = 4;
	public static final int round_DOWN = 5;
	public static final int round_FLOOR = 6;
	
	public static final int defaultparam = (new NumberUsage()).encode();

	public static final String[] roundingModeName = {"CEILING", "UP", "HALF_UP", "HALF_EVEN", "HALF_DOWN",
		"DOWN", "FLOOR"
	};
	
	public RoundingMode fromDecNumberRounding(int ndx) {
		// strange way of doing this, but needed to make work with 1.4.2
		if (ndx == 0)
			return RoundingMode.CEILING;
		else if (ndx == 1)
			return RoundingMode.UP;
		else if (ndx == 2)
			return RoundingMode.HALF_UP;
		else if (ndx == 3)
			return RoundingMode.HALF_EVEN;
		else if (ndx == 4)
			return RoundingMode.HALF_DOWN;
		else if (ndx == 5)
			return RoundingMode.DOWN;
		else if (ndx == 6)
			return RoundingMode.FLOOR;
		else 
			return null;
	};
	
	private int usage;
	private int rounding; 
	private int precision;
	
	private int floating_usage; // used only by code which converts floating literals 
	
	public NumberUsage() {
		usage = use_Number;
		rounding = round_HALF_EVEN;
		precision = 34;
		
		floating_usage = use_Number;
	}
	
	public NumberUsage(NumberUsage nu) {
		usage = nu.usage;
		rounding = nu.rounding;
		precision = nu.precision;
		
		floating_usage = nu.floating_usage;
	}
	
/*
 	public NumberUsage(int encoded) {
		usage = encoded & 0x7;
		assert usage <= 4;
		rounding = (encoded >> 3) & 0x7;
		assert rounding <= 6;
		int p = (encoded >> 6) & 0x3F;
		precision = (p==0)? 34 : p;
		assert 1 <= precision && precision <= 34;
	}
	
	*/
	public void set_usage(int u) {
		assert u <= 4;
		usage = u;
		if (u <= use_double)
			floating_usage = u;
	}
	
	public void set_rounding(int r) {
		assert r <= 6;
		rounding = r;
	}
	
	public void set_precision(int p) {
		assert p <= 34;
		precision = p;
	}
	
	public int get_usage() {
		return usage;
	}
	
	public int get_floating_usage() { // only used for conversion of floating literals
		return floating_usage;
	}
	
	public int get_rounding() {
		return rounding;
	}
	
	public RoundingMode get_java_roundingMode() {
		return fromDecNumberRounding(rounding);
	}
	public int get_precision() {
		return precision;
	}
	
	public boolean is_default() {
		return (usage == use_Number) && (rounding == round_HALF_EVEN) && (precision == 34);
	}
	
	public int encode() {
		int ret = usage;
		if (usage <= use_decimal) {
			// don't need precision or rounding unless decimal is possible
			ret |= (rounding << 3);
			if (precision < 34) {
				ret |= (precision << 6);
			}
		}
		return ret;
	}
}
