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

public class DoubleNumberConstant extends NumberConstant {

	
	double val;
	
	public DoubleNumberConstant(double num) {
		val = num;
	}
	
	@Override
	public Decimal128 decimalValue() {
		// TODO Auto-generated method stub
		return new Decimal128(val);
	}

	@Override
	public double doubleValue() {
		return val;
	}

	@Override
	public int intValue() {
		return (int)val;
	}

	@Override
	public byte number_type() {
		return NumberUsage.use_double;
	}

	@Override
	public long uintValue() {
		// Java truncates any positive double > Integer.MAX_VALUE to MAX_VALUE.  If we
		// launder the value through long, we get the result we want.
		long lval = (long)val;
		int ival = (int)lval;
		return ival;
	}
	
	@Override
	public String toString() {
		if (Double.isNaN(val))
			return ("NaN");
		return String.valueOf(val);
	}

}
