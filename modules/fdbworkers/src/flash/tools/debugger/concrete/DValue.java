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

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import flash.tools.debugger.Isolate;
import flash.tools.debugger.NoResponseException;
import flash.tools.debugger.NotConnectedException;
import flash.tools.debugger.NotSuspendedException;
import flash.tools.debugger.Session;
import flash.tools.debugger.Value;
import flash.tools.debugger.ValueAttribute;
import flash.tools.debugger.Variable;
import flash.tools.debugger.VariableType;
import flash.tools.debugger.expression.Context;

/**
 * Implementation of an ActionScript value.
 */
public class DValue implements Value
{
	/** @see VariableType */
	private int			m_type;

	/** @see Variable#getTypeName() */
	private String		m_typeName;

	/** @see Variable#getClassName() */
	private String		m_className;

	/** @see ValueAttribute */
	private int			m_attribs;

	/** Maps "varname" (without its namespace) to a Variable */
	private Map<String, DVariable> m_members;

	/**
	 * Either my own ID, or else my parent's ID if I am <code>__proto__</code>.
	 */
	long				m_nonProtoId;

	/**
	 * <code>m_value</code> can have one of several possible meanings:
	 *
	 * <ul>
	 * <li> If this variable's value is an <code>Object</code> or a <code>MovieClip</code>,
	 *      then <code>m_value</code> contains the ID of the <code>Object</code> or
	 *      <code>MovieClip</code>, stored as a <code>Long</code>. </li>
	 * <li> If this variable refers to a Getter which has not yet been invoked, then
	 *      <code>m_value</code> contains the ID of the Getter, stored as a
	 *      <code>Long</code>. </li>
	 * <li> If this variable's value is <code>undefined</code>, then <code>m_value</code>
	 *      will be equal to <code>Value.UNDEFINED</code>.
	 * <li> Otherwise, this variable's value is a simple type such as <code>int</code> or
	 *      <code>String</code>, in which case <code>m_value</code> holds the actual value.
	 * </ul>
	 */
	private Object		m_value;

	/**
	 * The list of classes that contributed members to this object, from
	 * the class itself all the way down to Object.
	 */
	private String[] m_classHierarchy;

	/**
	 * How many members of <code>m_classHierarchy</code> actually contributed
	 * members to this object.
	 */
	private int m_levelsWithMembers;

	private Session m_session;
	
	/** Maps duplicate private "varname" to a list of Variable objects */
	private Map<String, List<DVariable>> m_inheritedPrivates;
	
	private int m_isolateId;


	/**
	 * Create a top-level variable which has no parent.  This may be used for
	 * _global, _root, stack frames, etc.
	 *
	 * @param id the ID of the variable
	 */
	public DValue(long id, int isolateId)
	{
		init(VariableType.UNKNOWN, null, null, 0, new Long(id));
		setIsolateId(isolateId);
	}

	/**
	 * Create a value.
	 *
	 * @param type see <code>VariableType</code>
	 * @param typeName
	 * @param className
	 * @param attribs
	 *            the attributes of this value; see <code>ValueAttribute</code>
	 * @param value
	 *            for an Object or MovieClip, this should be a Long which contains the
	 *            ID of this variable.  For a variable of any other type, such as integer
	 *            or string, this should be the value of the variable.
	 * @param isolateId
	 * 			  the worker to which this value belongs
	 */
	public DValue(int type, String typeName, String className, int attribs, Object value, int isolateId)
	{
		init(type, typeName, className, attribs, value);
		setIsolateId(isolateId);
	}

	/**
	 * Constructs a DValue for a primitive value (null, undefined, Boolean, Number, String).
	 * 
	 * There is nothing special about these objects -- it would be just as legitimate for
	 * anyone who wants a Value for a primitive to make their own subclass of Value.
	 */
	public static DValue forPrimitive(Object primitiveValue, int isolateId)
	{
		if (primitiveValue == null)
			return new DValue(VariableType.NULL, "null", "", 0, primitiveValue, isolateId); //$NON-NLS-1$ //$NON-NLS-2$
		else if (primitiveValue == Value.UNDEFINED)
			return new DValue(VariableType.UNDEFINED, "undefined", "", 0, primitiveValue, isolateId); //$NON-NLS-1$ //$NON-NLS-2$
		else if (primitiveValue instanceof Boolean)
			return new DValue(VariableType.BOOLEAN, "Boolean", "", 0, primitiveValue, isolateId); //$NON-NLS-1$ //$NON-NLS-2$
		else if (primitiveValue instanceof Double)
			return new DValue(VariableType.NUMBER, "Number", "", 0, primitiveValue, isolateId); //$NON-NLS-1$ //$NON-NLS-2$
		else if (primitiveValue instanceof String)
			return new DValue(VariableType.STRING, "String", "", 0, primitiveValue, isolateId); //$NON-NLS-1$ //$NON-NLS-2$
		assert false;
		return null;
	}

	/**
	 * Initialize a variable.
	 *
	 * For the meanings of the arguments, see the DVariable constructor.
	 */
	private void init(int type, String typeName, String className, int attribs, Object value)
	{
		if (value == null && type == VariableType.UNDEFINED)
			value = Value.UNDEFINED;

		m_type = type;
		m_typeName = typeName;
		m_className = className;
		m_attribs = attribs;
		m_value = value;
		m_members = null;
		m_inheritedPrivates = null;
		m_nonProtoId = getId();
		m_isolateId = Isolate.DEFAULT_ID;
	}
	
	public int getIsolateId() {
		return m_isolateId;
	}
	
	public void setIsolateId(int isolateid) {
		m_isolateId = isolateid;
	}

	/*
	 * @see flash.tools.debugger.Value#getAttributes()
	 */
	public int getAttributes()
	{
		return m_attribs;
	}

	/*
	 * @see flash.tools.debugger.Value#getClassName()
	 */
	public String getClassName()
	{
		return m_className;
	}

	/*
	 * @see flash.tools.debugger.Value#getId()
	 */
	public long getId()
	{
		// see if we support an id concept
		if (m_value instanceof Long)
			return ((Long)m_value).longValue();
		else
			return Value.UNKNOWN_ID;
	}

	/*
	 * @see flash.tools.debugger.Value#getMemberCount(flash.tools.debugger.Session)
	 */
	public int getMemberCount(Session s) throws NotSuspendedException,
			NoResponseException, NotConnectedException
	{
		obtainMembers(s);
		return (m_members == null) ? 0 : m_members.size();
	}

	/*
	 * @see flash.tools.debugger.Value#getMemberNamed(flash.tools.debugger.Session, java.lang.String)
	 */
	public Variable getMemberNamed(Session s, String name)
			throws NotSuspendedException, NoResponseException,
			NotConnectedException
	{
		obtainMembers(s);
		return findMember(name);
	}

	/*
	 * @see flash.tools.debugger.Value#getClassHierarchy(boolean)
	 */
	public String[] getClassHierarchy(boolean allLevels) {
		if (allLevels) {
			return m_classHierarchy;
		} else {
			String[] partialClassHierarchy;

			if (m_classHierarchy != null)
			{
				partialClassHierarchy = new String[m_levelsWithMembers];
				System.arraycopy(m_classHierarchy, 0, partialClassHierarchy, 0, m_levelsWithMembers);
			}
			else
			{
				partialClassHierarchy = new String[0];
			}
			return partialClassHierarchy;
		}
	}

	/* TODO should this really be public? */
	public DVariable findMember(String named)
	{
		if (m_members == null)
			return null;
		else
			return m_members.get(named);
	}

	/*
	 * @see flash.tools.debugger.Value#getMembers(flash.tools.debugger.Session)
	 */
	public Variable[] getMembers(Session s) throws NotSuspendedException,
			NoResponseException, NotConnectedException
	{
		obtainMembers(s);

		/* find out the size of the array */
		int count = getMemberCount(s);
		DVariable[] ar = new DVariable[count];

		if (count > 0)
		{
			count = 0;
			Iterator<DVariable> itr = m_members.values().iterator();
			while(itr.hasNext())
			{
				DVariable  sf = itr.next();
				ar[count++] = sf;
			}

			// sort the member list by name
			Arrays.sort(ar);
		}

		return ar;
	}

	/**
	 * WARNING: this call will initiate a call to the session to obtain the members
	 * the first time around.
	 * @throws NotConnectedException
	 * @throws NoResponseException
	 * @throws NotSuspendedException
	 */
	private void obtainMembers(Session s) throws NotSuspendedException, NoResponseException, NotConnectedException
	{
		if (s == null)
			s = m_session;
		else
			m_session = s;

		if (m_members == null && s != null)
		{
			// performing a get on this variable obtains all its members
			long id = getId();
			if (id != Value.UNKNOWN_ID)
			{
				if (((PlayerSession)s).getRawValue(id, m_isolateId) == this)
					((PlayerSession)s).obtainMembers(id, m_isolateId);
				if (m_members != null)
				{
					Iterator<DVariable> iter = m_members.values().iterator();
					while (iter.hasNext())
					{
						Object next = iter.next();
						if (next instanceof DVariable)
						{
							((DVariable)next).setSession(s);
						}
					}
				}
			}
		}
	}

	public boolean membersObtained()
	{
		return (getId() == UNKNOWN_ID || m_members != null);
	}

	public void setMembersObtained(boolean obtained)
	{
		if (obtained)
		{
			if (m_members == null)
				m_members = Collections.emptyMap();
			if (m_inheritedPrivates == null)
				m_inheritedPrivates = Collections.emptyMap();
		}
		else
		{
			m_members = null;
			m_inheritedPrivates = null;
		}
	}

	public void addMember(DVariable v)
	{
		if (m_members == null)
			m_members = new HashMap<String, DVariable>();

		// if we are a proto member house away our original parent id
		String name = v.getName();
		DValue val = (DValue) v.getValue();
		val.m_nonProtoId = (name != null && name.equals("__proto__")) ? m_nonProtoId : val.getId(); //$NON-NLS-1$ // TODO is this right?
		v.m_nonProtoParentId = m_nonProtoId;

		m_members.put(name, v);
	}
	
	public void addInheritedPrivateMember(DVariable v)
	{
		if (m_inheritedPrivates == null)
			m_inheritedPrivates = new HashMap<String, List<DVariable>>();

		// if we are a proto member house away our original parent id
		String name = v.getName();
		DValue val = (DValue) v.getValue();
		val.m_nonProtoId = (name != null && name.equals("__proto__")) ? m_nonProtoId : val.getId(); //$NON-NLS-1$ // TODO is this right?
		v.m_nonProtoParentId = m_nonProtoId;
		List<DVariable> resultList = m_inheritedPrivates.get(name);
		if (resultList == null) {
			resultList = new ArrayList<DVariable>();
			resultList.add(v);
			m_inheritedPrivates.put(name, resultList);
		}
		else
			resultList.add(v);
		//m_inheritedPrivates.put(name, v);
	}

	public void removeAllMembers()
	{
		m_members = null;
		m_inheritedPrivates = null;
	}

	/*
	 * @see flash.tools.debugger.Value#getType()
	 */
	public int getType()
	{
		return m_type;
	}

	/*
	 * @see flash.tools.debugger.Value#getTypeName()
	 */
	public String getTypeName()
	{
		return m_typeName;
	}

	/*
	 * @see flash.tools.debugger.Value#getValueAsObject()
	 */
	public Object getValueAsObject()
	{
		return m_value;
	}

	/*
	 * @see flash.tools.debugger.Value#getValueAsString()
	 */
	public String getValueAsString()
	{
		return getValueAsString(m_value);
	}

	/**
	 * @param value an object which might be one of these types:
	 * Boolean, Integer, Long, Double, String, Value.UNDEFINED (representing
	 * the value 'undefined'); or null.
	 */
	public static String getValueAsString(Object value)
	{
		if (value == null)
			return "null"; //$NON-NLS-1$

		if (value instanceof Double)
		{
			// Java often formats whole numbers in ugly ways.  For example,
			// the number 3 might be formatted as "3.0" and, even worse,
			// the number 12345678 might be formatted as "1.2345678E7" !
			// So, if the number has no fractional part, then we override
			// the default display behavior.
			double doubleValue = ((Double)value).doubleValue();
			long longValue = (long) doubleValue;
			if (doubleValue == longValue)
				return Long.toString(longValue);
		}

		return value.toString();
	}

	/*
	 * @see flash.tools.debugger.Value#isAttributeSet(int)
	 */
	public boolean isAttributeSet(int variableAttribute)
	{
		return (m_attribs & variableAttribute) != 0;
	}

	public void	setTypeName(String s)	{ m_typeName = s; }
	public void	setClassName(String s)	{ m_className = s; }
	public void setType(int t)			{ m_type = t; }
	public void setValue(Object o)		{ m_value = o; }
	public void setAttributes(int f)	{ m_attribs = f; }

	public void setClassHierarchy(String[] classHierarchy, int levelsWithMembers)
	{
		m_classHierarchy = classHierarchy;
		m_levelsWithMembers = levelsWithMembers;
	}

	public String membersToString()
	{
		StringBuilder sb = new StringBuilder();

		/* find out the size of the array */
		if (m_members == null)
			sb.append(PlayerSessionManager.getLocalizationManager().getLocalizedTextString("empty")); //$NON-NLS-1$
		else
		{
			Iterator<DVariable> itr = m_members.values().iterator();
			while(itr.hasNext())
			{
				DVariable  sf = itr.next();
				sb.append(sf);
				sb.append(",\n"); //$NON-NLS-1$
			}
		}
		return sb.toString();
	}

	public void setSession(Session s)
	{
		m_session = s;
	}

	/**
	 * Necessary for expression evaluation.
	 * @see Context#lookup(Object)
	 */
	@Override
	public String toString() { return getValueAsString(); }

	public Variable[] getPrivateInheritedMembers() {
		if (m_inheritedPrivates == null)
			return new DVariable[0];
		
		ArrayList<DVariable> finalList = new ArrayList<DVariable>();
		
		Iterator<List<DVariable>> itr = m_inheritedPrivates.values().iterator();
		while(itr.hasNext())
		{
			List<DVariable>  varList = itr.next();
			finalList.addAll(varList);
		}
		
		DVariable[] ar = finalList.toArray(new DVariable[0]);
		// sort the member list by name
		Arrays.sort(ar);

		return ar;
	}
	
	public Variable[] getPrivateInheritedMemberNamed(String name) {
		if (m_inheritedPrivates == null)
			return new DVariable[0];
		List<DVariable> list = m_inheritedPrivates.get(name);
		if (list != null) {
			return list.toArray(new Variable[0]);
		}
		return new DVariable[0];
	}
}
