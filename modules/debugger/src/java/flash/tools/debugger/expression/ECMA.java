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
package flash.tools.debugger.expression;

import flash.tools.debugger.Isolate;
import flash.tools.debugger.PlayerDebugException;
import flash.tools.debugger.Session;
import flash.tools.debugger.Value;
import flash.tools.debugger.VariableType;
import flash.tools.debugger.concrete.DValue;
import flash.tools.debugger.events.ExceptionFault;

/**
 * Implementations of some of the conversion functions defined by
 * the ECMAScript spec ( http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf ).
 * Please note, these conversion functions should not be considered to
 * be 100% accurate; they handle all the cases the debugger's expression
 * evaluator is likely to run into, but there are some edge cases that
 * fall through the cracks.
 * 
 * @author Mike Morearty
 */
public class ECMA
{
	/** Used by defaultValue() etc. */
	private enum PreferredType { NUMBER, STRING }

	/**
	 * ECMA 4.3.2
	 */
	public static boolean isPrimitive(Value v)
	{
		v = safeValue(v, Isolate.DEFAULT_ID);
		Object o = v.getValueAsObject();
		return (o == Value.UNDEFINED || o == null || o instanceof Boolean
				|| o instanceof Double || o instanceof String);
	}

	private static Value callFunction(Session session, Value v, String functionName, Value[] args, int isolateId)
	{
		v = safeValue(v, isolateId);

		try
		{
			return session.getWorkerSession(isolateId).callFunction(v, functionName, args);
		}
		catch (PlayerDebugException e)
		{
			throw new ExpressionEvaluatorException(e);
		}
	}

	/**
	 * Calls the valueOf() function of an object.
	 */
	private static Value callValueOf(Session session, Value v, int isolateId)
	{
		v = safeValue(v, isolateId);
		return callFunction(session, v, "valueOf", new Value[0], isolateId); //$NON-NLS-1$
	}

	/**
	 * Do not confuse this with toString()!  toString() represents the official
	 * ECMA definition of [[ToString]], as defined in ECMA section 9.8.  This
	 * function, on the other hand, represents calling the toString() function
	 * of an object.
	 */
	private static Value callToString(Session session, Value v, int isolateId)
	{
		v = safeValue(v, isolateId);
		return callFunction(session, v, "toString", new Value[0], isolateId); //$NON-NLS-1$
	}

	/**
	 * ECMA 8.6.2.6
	 * 
	 * @param v
	 * @param optionalPreferredType
	 *            either NUMBER, STRING, or null.
	 */
	public static Value defaultValue(Session session, Value v, 
			PreferredType optionalPreferredType,
			int isolateId)
	{
		v = safeValue(v, isolateId);
		String typename = v.getTypeName();
		int at = typename.indexOf('@');
		if (at != -1)
			typename = typename.substring(0, at);

		if (optionalPreferredType == null)
		{
			if (typename.equals("Date")) //$NON-NLS-1$
				optionalPreferredType = PreferredType.STRING;
			else
				optionalPreferredType = PreferredType.NUMBER;
		}

		if (optionalPreferredType == PreferredType.NUMBER)
		{
			Value result = callValueOf(session, v, isolateId);
			if (isPrimitive(result))
				return result;
			result = callToString(session, v, isolateId);
			if (isPrimitive(result))
				return result;
			throw new RuntimeException(new PlayerFaultException(new ExceptionFault(ASTBuilder.getLocalizationManager().getLocalizedTextString("typeError"), false, null, isolateId))); //$NON-NLS-1$
		}
		else
		{
			Value result = callToString(session, v, isolateId);
			if (isPrimitive(result))
				return result;
			result = callValueOf(session, v, isolateId);
			if (isPrimitive(result))
				return result;
			throw new RuntimeException(new PlayerFaultException(new ExceptionFault(ASTBuilder.getLocalizationManager().getLocalizedTextString("typeError"), false, null, isolateId))); //$NON-NLS-1$
		}
	}

	/**
	 * ECMA 9.1
	 * 
	 * @param v
	 * @param optionalPreferredType
	 *            either NUMBER_TYPE, STRING_TYPE, or null.
	 * @return
	 */
	public static Value toPrimitive(Session session, Value v,
			PreferredType optionalPreferredType, int isolateId)
	{
		v = safeValue(v, isolateId);
		switch (v.getType())
		{
		case VariableType.UNDEFINED:
		case VariableType.NULL:
		case VariableType.BOOLEAN:
		case VariableType.NUMBER:
		case VariableType.STRING:
			return v;

		default:
			return defaultValue(session, v, optionalPreferredType, isolateId);
		}
	}

	/** ECMA 9.2 */
	public static boolean toBoolean(Value v)
	{
		v = safeValue(v, Isolate.DEFAULT_ID);
		switch (v.getType())
		{
		case VariableType.UNDEFINED:
		case VariableType.NULL:
			return false;
		case VariableType.BOOLEAN:
			return ((Boolean) v.getValueAsObject()).booleanValue();
		case VariableType.NUMBER:
		{
			double d = ((Double) v.getValueAsObject()).doubleValue();
			if (d == 0 || Double.isNaN(d))
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		case VariableType.STRING:
			return ((String) v.getValueAsObject()).length() != 0;
		default:
			return true;
		}
	}

	/** ECMA 9.3 */
	public static double toNumber(Session session, Value v)
	{
		v = safeValue(v, Isolate.DEFAULT_ID);
		switch (v.getType())
		{
		case VariableType.UNDEFINED:
			return Double.NaN;
		case VariableType.NULL:
			return 0;
		case VariableType.BOOLEAN:
			return ((Boolean) v.getValueAsObject()).booleanValue() ? 1 : 0;
		case VariableType.NUMBER:
			return ((Double) v.getValueAsObject()).doubleValue();
		case VariableType.STRING:
		{
			String s = (String) v.getValueAsObject();
			if (s.length() == 0)
			{
				return 0;
			}
			else
			{
				try
				{
					return Double.parseDouble(s);
				}
				catch (NumberFormatException e)
				{
					return Double.NaN;
				}
			}
		}
		default:
			return toNumber(session, toPrimitive(session, v, PreferredType.NUMBER, v.getIsolateId()));
		}
	}

	private static final double _2pow31 = Math.pow(2, 31);
	private static final double _2pow32 = Math.pow(2, 32);

	/** ECMA 9.5 */
	public static int toInt32(Session session, Value v)
	{
		v = safeValue(v, Isolate.DEFAULT_ID);
		double d = toNumber(session, v);
		if (d == Double.POSITIVE_INFINITY || d == Double.NEGATIVE_INFINITY)
		{
			return 0;
		}
		else
		{
			double sign = Math.signum(d);
			d = Math.floor(Math.abs(d));
			d %= _2pow32;
			while (d >= _2pow31)
				d -= _2pow32;
			return (int) (sign*d);
		}
	}

	/** ECMA 9.6 */
	public static long toUint32(Session session, Value v)
	{
		v = safeValue(v, Isolate.DEFAULT_ID);
		long n = toInt32(session, v);
		if (n < 0)
			n = n + (long) 0x10000 * (long) 0x10000;
		return n;
	}

	/** ECMA 9.8 */
	public static String toString(Session session, Value v)
	{
		v = safeValue(v, Isolate.DEFAULT_ID);
		switch (v.getType())
		{
		case VariableType.UNDEFINED:
		case VariableType.NULL:
		case VariableType.BOOLEAN:
		case VariableType.STRING:
			return v.getValueAsString();
		case VariableType.NUMBER:
		{
			double d = ((Double) v.getValueAsObject()).doubleValue();
			if (d == (long) d)
			{
				return Long.toString((long) d); // avoid the ".0" on the end
			}
			else
			{
				return v.toString();
			}
		}
		default:
			return toString(session, toPrimitive(session, v, PreferredType.STRING, v.getIsolateId()));
		}
	}

	/** ECMA 11.8.5.  Returns true, false, or undefined. */
	public static Value lessThan(Session session, Value x, Value y)
	{
		x = safeValue(x, Isolate.DEFAULT_ID);
		y = safeValue(y, Isolate.DEFAULT_ID);
		Value px = toPrimitive(session, x, PreferredType.NUMBER, x.getIsolateId());
		Value py = toPrimitive(session, y, PreferredType.NUMBER, y.getIsolateId());
		if (px.getType() == VariableType.STRING
				&& py.getType() == VariableType.STRING)
		{
			String sx = px.getValueAsString();
			String sy = py.getValueAsString();
			return DValue.forPrimitive(new Boolean(sx.compareTo(sy) < 0), x.getIsolateId());
		}
		else
		{
			double dx = toNumber(session, px);
			double dy = toNumber(session, py);
			if (Double.isNaN(dx) || Double.isNaN(dy))
				return DValue.forPrimitive(Value.UNDEFINED, x.getIsolateId());
			return DValue.forPrimitive(new Boolean(dx < dy), x.getIsolateId());
		}
	}

	/** ECMA 11.9.3 */
	public static boolean equals(Session session, Value xv, Value yv)
	{
		xv = safeValue(xv, Isolate.DEFAULT_ID);
		yv = safeValue(yv, Isolate.DEFAULT_ID);

		Object x = xv.getValueAsObject();
		Object y = yv.getValueAsObject();

		if (xv.getType() == yv.getType())
		{
			if (x == Value.UNDEFINED)
				return true;
			if (x == null)
				return true;
			if (x instanceof Double)
			{
				double dx = ((Double) x).doubleValue();
				double dy = ((Double) y).doubleValue();
				return dx == dy;
			}
			if (x instanceof String || x instanceof Boolean)
				return x.equals(y);

			// see if they are the same object
			if (xv.getId() != -1 || yv.getId() != -1)
				return xv.getId() == yv.getId();
			return false;
		}
		else
		{
			if (x == null && y == Value.UNDEFINED)
				return true;
			if (x == Value.UNDEFINED && y == null)
				return true;
			if (x instanceof Double && y instanceof String)
			{
				double dx = ((Double) x).doubleValue();
				double dy = toNumber(session, yv);
				return dx == dy;
			}
			if (x instanceof String && y instanceof Double)
			{
				double dx = toNumber(session, xv);
				double dy = ((Double) y).doubleValue();
				return dx == dy;
			}
			if (x instanceof Boolean)
				return equals(session, DValue.forPrimitive(new Double(toNumber(session, xv)), xv.getIsolateId()), yv);
			if (y instanceof Boolean)
				return equals(session, xv, DValue.forPrimitive(new Double(toNumber(session, yv)), xv.getIsolateId()));
			if ((x instanceof String || x instanceof Double) && yv.getType() == VariableType.OBJECT)
			{
				return equals(session, xv, toPrimitive(session, yv, null, yv.getIsolateId()));
			}
			if (xv.getType() == VariableType.OBJECT && (y instanceof String || y instanceof Double))
			{
				return equals(session, toPrimitive(session, xv, null, xv.getIsolateId()), yv);
			}
			return false;
		}
	}

	/** ECMA 11.9.6 */
	public static boolean strictEquals(Value xv, Value yv)
	{
		xv = safeValue(xv, Isolate.DEFAULT_ID);
		yv = safeValue(yv, Isolate.DEFAULT_ID);

		Object x = xv.getValueAsObject();
		Object y = yv.getValueAsObject();

		if (xv.getType() == yv.getType())
		{
			if (x == Value.UNDEFINED)
				return true;
			if (x == null)
				return true;
			if (x instanceof Double)
			{
				double dx = ((Double) x).doubleValue();
				double dy = ((Double) y).doubleValue();
				return dx == dy;
			}
			if (x instanceof String || x instanceof Boolean)
				return x.equals(y);

			// see if they are the same object
			if (xv.getId() != -1 || yv.getId() != -1)
				return xv.getId() == yv.getId();
			return false;
		}
		else
		{
			return false;
		}
	}

	/**
	 * Returns a "safe" (non-null) form of the specified Value -- that is, if
	 * the specified Value is null, returns a non-null Value that *represents*
	 * null.
	 * 
	 * @param v
	 *            any Value, possibly null
	 * @return a non-null Value
	 */
	public static Value safeValue(Value v, int isolateId)
	{
		if (v == null)
		{
			v = DValue.forPrimitive(null, isolateId);
			assert v != null;
		}
		return v;
	}
}
