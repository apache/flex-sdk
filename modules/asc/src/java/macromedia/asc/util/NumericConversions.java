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

/**
 *  Implement numeric conversions as specified in ECMA-262.
 */
public class NumericConversions
{
	public static final long TwoPow31 = 2147483648L;
	public static final long TwoPow32 = 4294967296L;
	
    public static long toUint32(double d)
    {
    	if ( Double.isNaN(d) || Double.isInfinite(d) || 0.0 == d )
    		return 0;
    	
    	double result3 = Math.floor(Math.abs(d));
    	return (long)result3 % TwoPow32;
    }

    public static int toInt32(double d)
    {
        long result4 = (long)Math.signum(d) * toUint32(d);
                
        if ( result4 >= TwoPow31 )
        	return (int)(result4 - TwoPow32);
        else
        	return (int)result4;
    }
}
