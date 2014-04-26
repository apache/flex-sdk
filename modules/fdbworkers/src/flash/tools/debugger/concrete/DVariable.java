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

import flash.tools.debugger.NoResponseException;
import flash.tools.debugger.NotConnectedException;
import flash.tools.debugger.NotSuspendedException;
import flash.tools.debugger.PlayerDebugException;
import flash.tools.debugger.Session;
import flash.tools.debugger.SessionManager;
import flash.tools.debugger.Value;
import flash.tools.debugger.Variable;
import flash.tools.debugger.VariableAttribute;
import flash.tools.debugger.VariableType;
import flash.tools.debugger.events.FaultEvent;
import flash.tools.debugger.expression.Context;

public class DVariable implements Variable, Comparable
{
	/**
	 * The raw name, exactly as it came back from the Player.  For example, this
	 * might be <code>mynamespace@12345678::myvar</code>, which indicates that
	 * the variable is in namespace "mynamespace", which has atom 12345678.
	 */
	private String		m_rawName;

	/** Just name, without namespace */
	private String		m_name;

	/** @see Variable#getNamespace() */
	private String		m_namespace = ""; //$NON-NLS-1$

	/** @see VariableAttribute */
	private int			m_attribs;

	/**
	 * The variable's value.
	 */
	protected Value		m_value;

	/**
	 * Whether we have fired the getter for this value.  Only applicable if
	 * the VariableAttribute.HAS_GETTER attribute is set.
	 */
	private boolean		m_firedGetter;

	/**
	 * The class in which this member was actually defined.  For example, if class
	 * B extends class A, and class A has member variable V, then for variable
	 * V, the defining class is always "A", even though the parent variable might
	 * be an instance of class B.
	 */
	private String		m_definingClass;

	/**
	 * The variable's "level" -- see <code>Variable.getLevel()</code>
	 * @see Variable#getLevel()
	 */
	private byte		m_level;

	/**
	 * The session object that was used when creating this variable, if known.
	 */
	private Session		m_session;

	/**
	 * My parent's <code>m_nonProtoId</code>.  In other words, either my
	 * parent's ID, or else my parent's parent's ID if my parent is <code>__proto__</code>.
	 */
	long				m_nonProtoParentId;
	
	/**
	 * The worker to which this variable belongs.
	 */
	private int m_isolateId;

	/**
	 * Create a variable and its value.
	 *
	 * @param name
	 *            the name of the variable within the context of its parent.  For example,
	 *            when resolving member "bar" of object "foo", the name will be "bar".
	 * @param value
	 *            the variable's value.
	 */
	public DVariable(String name, DValue value, int isolateId)
	{
		m_rawName = name;
		m_attribs = value.getAttributes();
		
		// If the name contains "::", then the name is of the form "namespace::name"
		if (name != null)
		{
			/**
			 * anirudhs - Compute namespace only for non-public variables.
			 * This check helps us avoid cases where public variables have
			 * dynamic keys with :: in them. See FB-26126.
			 */
			if (!isAttributeSet(VariableAttribute.PUBLIC_SCOPE)) 
			{
				int doubleColon = name.lastIndexOf("::"); //$NON-NLS-1$
				if (doubleColon >= 0)
				{
					m_namespace = name.substring(0, doubleColon);
					int at = m_namespace.indexOf('@');
					if (at != -1)
						m_namespace = m_namespace.substring(0, at);
					
					name = name.substring(doubleColon+2);
				}
			}
		}

		m_name = name;
		m_nonProtoParentId = Value.UNKNOWN_ID;
		m_value = value;
		value.setSession(m_session);
		m_isolateId = isolateId;
	}

	/* getters/setters */
	public String		getName()				{ return m_name; }
	public int			getAttributes()			{ return m_attribs; }
	public String		getNamespace()			{ return m_namespace; }
	public int			getScope()				{ return m_attribs & VariableAttribute.SCOPE_MASK; }
	public int			getLevel()				{ return m_level; }
	public String		getDefiningClass()		{ return m_definingClass; }
	
	public int getIsolateId() {
		return m_isolateId;
	}
	
	public void makePublic()
	{
		int attributes = getAttributes();
		attributes &= ~VariableAttribute.SCOPE_MASK;
		attributes |= VariableAttribute.PUBLIC_SCOPE;
		setAttributes(attributes);
		
		m_namespace = ""; //$NON-NLS-1$
	}

	/*
	 * @see flash.tools.debugger.Variable#getValue()
	 */
	public Value getValue()
	{
		if (m_session != null && m_session.getPreference(SessionManager.PREF_INVOKE_GETTERS) != 0) {
			try {
				invokeGetter(m_session);
			} catch (NotSuspendedException e) {
				// fall through -- return raw value without invoking getter
			} catch (NoResponseException e) {
				// fall through -- return raw value without invoking getter
			} catch (NotConnectedException e) {
				// fall through -- return raw value without invoking getter
			}
		}

		return m_value;
	}

	/*
	 * @see flash.tools.debugger.Variable#hasValueChanged(flash.tools.debugger.Session)
	 */
	public boolean hasValueChanged(Session s)
	{
		boolean hasValueChanged = false;
		if (s instanceof PlayerSession)
		{
			Value previousParent = ((PlayerSession)s).getPreviousValue(m_nonProtoParentId, m_isolateId);
			if (previousParent != null)
			{
				try {
					Variable previousMember = previousParent.getMemberNamed(null, getName());
					// If the old variable had a getter but never invoked that getter,
					// then it's too late, we don't know the old value. 
					if (previousMember instanceof DVariable && !previousMember.needsToInvokeGetter())
					{
						Value previousValue = ((DVariable)previousMember).m_value;
						if (previousValue != null)
						{
							String previousValueAsString = previousValue.getValueAsString();
							if (previousValueAsString != null)
							{
								if (!previousValueAsString.equals(getValue().getValueAsString()))
								{
									hasValueChanged = true;
								}
							}
						}
					}
				} catch (PlayerDebugException e) {
					// ignore
				}
			}
		}
		return hasValueChanged;
	}

	/*
	 * @see flash.tools.debugger.Session#setScalarMember(int, java.lang.String, int, java.lang.String)
	 */
	public FaultEvent setValue(Session s, int type, String value) throws NotSuspendedException, NoResponseException, NotConnectedException
	{
		return ((PlayerSession)s).setScalarMember(m_nonProtoParentId, m_rawName, type, value, m_isolateId);
	}

	/*
	 * @see flash.tools.debugger.Variable#isAttributeSet(int)
	 */
	public boolean isAttributeSet(int att)
	{
		if ((att & VariableAttribute.SCOPE_MASK) == att)
			return (getScope() == att);
		else
			return ( ( (getAttributes() & att) == att) ? true : false );
	}

	public void clearAttribute(int att)
	{
		if ((att & VariableAttribute.SCOPE_MASK) == att)
			m_attribs = (m_attribs & ~VariableAttribute.SCOPE_MASK) | VariableAttribute.PUBLIC_SCOPE;
		else
			m_attribs &= ~att;
	}

	public void setAttribute(int att)
	{
		if ((att & VariableAttribute.SCOPE_MASK) == att)
			m_attribs = (m_attribs & ~VariableAttribute.SCOPE_MASK) | att;
		else
			m_attribs |= att;
	}

	public String getRawName()
	{
		return m_rawName;
	}

	/*
	 * @see flash.tools.debugger.Variable#getQualifiedName()
	 */
	public String getQualifiedName()
	{
		if (m_namespace.length() > 0)
			return m_namespace + "::" + m_name; //$NON-NLS-1$
		else
			return m_name;
	}

	/**
	 * Comparator interface for sorting Variables
	 */
	public int compareTo(Object o2)
	{
		Variable v2 = (Variable)o2;

		String n1 = getName();
		String n2 = v2.getName();
		
		return String.CASE_INSENSITIVE_ORDER.compare(n1, n2);
	}

	/*
	 * @see flash.tools.debugger.Variable#needsToFireGetter()
	 */
	public boolean needsToInvokeGetter()
	{
		// If this variable has a getter, and the getter has not yet been invoked
		return (isAttributeSet(VariableAttribute.HAS_GETTER) && m_value.getId() != Value.UNKNOWN_ID && !m_firedGetter);
	}

	/*
	 * @see flash.tools.debugger.Value#invokeGetter(flash.tools.debugger.Session)
	 */
	public void invokeGetter(Session s) throws NotSuspendedException,
			NoResponseException, NotConnectedException {
		if (needsToInvokeGetter())
		{
			PlayerSession playerSession = (PlayerSession) s;

			// If this Variable is stale (that is, the program has run since this Variable
			// was created), then we can't invoke the getter.
			if (playerSession.getRawValue(m_value.getId(), m_isolateId) == m_value)
			{
				// temporarily turn on "invoke getters" preference
				int oldInvokeGetters = playerSession.getPreference(SessionManager.PREF_INVOKE_GETTERS);
				playerSession.setPreference(SessionManager.PREF_INVOKE_GETTERS, 1);

				try {
					// fire the getter using the original object id. make sure we get something reasonable back
					Value v = playerSession.getValue(m_nonProtoParentId, getRawName(), m_isolateId);
					if (v != null)
					{
						m_value = v;
						m_firedGetter = true;
						if (m_value instanceof DValue)
							((DValue)m_value).setSession(s);
					}
				} finally {
					playerSession.setPreference(SessionManager.PREF_INVOKE_GETTERS, oldInvokeGetters);
				}
			}
		}
	}

	public void	setName(String s)		{ m_name = s; }
	public void setAttributes(int f)	{ m_attribs = f; ((DValue)getValue()).setAttributes(f); }

	public void setSession(Session s)
	{
		m_session = s;
		if (m_value instanceof DValue)
			((DValue)m_value).setSession(s);
	}

	public void setDefiningClass(int level, String definingClass)
	{
		m_level = (byte) Math.min(level, 255);
		m_definingClass = definingClass;
	}

	/**
	 * Added so that expressions such as <code>a.b.c = e.f</code> work in the command-line interface.
	 * @see Context#lookup(Object)
	 */
	@Override
	public String toString() { return getValue().getValueAsString(); }

	/**
	 * Return the internal player string type representation for this variable.
	 * Currently used for passing in the type to the Player when doing
	 * a set variable command
	 */
	public static String typeNameFor(int type)
	{
		String s = "string"; //$NON-NLS-1$
		switch(type)
		{
			case VariableType.NUMBER:
				s = "number"; //$NON-NLS-1$
				break;

			case VariableType.BOOLEAN:
				s = "boolean"; //$NON-NLS-1$
				break;

			case VariableType.STRING:
				s = "string"; //$NON-NLS-1$
				break;

			case VariableType.OBJECT:
				s = "object"; //$NON-NLS-1$
				break;

			case VariableType.FUNCTION:
				s = "function"; //$NON-NLS-1$
				break;

			case VariableType.MOVIECLIP:
				s = "movieclip"; //$NON-NLS-1$
				break;

			case VariableType.NULL:
				s = "null"; //$NON-NLS-1$
				break;

			case VariableType.UNDEFINED:
			case VariableType.UNKNOWN:
			default:
				s = "undefined"; //$NON-NLS-1$
				break;
		}
		return s;
	}

	/**
	 * These values are obtained directly from the Player.
	 * See ScriptObject in splay.h.
	 */
	public static final int kNormalObjectType			= 0;
	public static final int kXMLSocketObjectType		= 1;
	public static final int kTextFieldObjectType		= 2;
	public static final int kButtonObjectType			= 3;
	public static final int kNumberObjectType			= 4;
	public static final int kBooleanObjectType			= 5;
	public static final int kNativeStringObject			= 6;
	public static final int kNativeArrayObject			= 7;
	public static final int kDateObjectType				= 8;
	public static final int kSoundObjectType			= 9;
	public static final int kNativeXMLDoc				= 10;
	public static final int kNativeXMLNode				= 11;
	public static final int kNativeCameraObject			= 12;
	public static final int kNativeMicrophoneObject		= 13;
	public static final int kNativeCommunicationObject	= 14;
	public static final int kNetConnectionObjectType  	= 15;
	public static final int kNetStreamObjectType		= 16;
	public static final int kVideoObjectType			= 17;
	public static final int kTextFormatObjectType		= 18;
	public static final int kSharedObjectType			= 19;
	public static final int kSharedObjectDataType		= 20;
	public static final int kPrintJobObjectType			= 21;
	public static final int kMovieClipLoaderObjectType	= 22;
	public static final int kStyleSheetObjectType		= 23;
	public static final int kFapPacketDummyObject		= 24;
	public static final int kLoadVarsObject				= 25;
	public static final int kTextSnapshotType			= 26;

	public static String classNameFor(long clsType, boolean isMc)
	{
		String clsName;
		switch ((int)clsType)
		{
			case kNormalObjectType:
				clsName = (isMc) ? "MovieClip" : "Object"; //$NON-NLS-1$ //$NON-NLS-2$
				break;
			case kXMLSocketObjectType:
				clsName = "XMLSocket"; //$NON-NLS-1$
				break;
			case kTextFieldObjectType:
				clsName = "TextField"; //$NON-NLS-1$
				break;
			case kButtonObjectType:
				clsName = "Button"; //$NON-NLS-1$
				break;
			case kNumberObjectType:
				clsName = "Number"; //$NON-NLS-1$
				break;
			case kBooleanObjectType:
				clsName = "Boolean"; //$NON-NLS-1$
				break;
			case kNativeStringObject:
				clsName = "String"; //$NON-NLS-1$
				break;
			case kNativeArrayObject:
				clsName = "Array"; //$NON-NLS-1$
				break;
			case kDateObjectType:
				clsName = "Date"; //$NON-NLS-1$
				break;
			case kSoundObjectType:
				clsName = "Sound"; //$NON-NLS-1$
				break;
			case kNativeXMLDoc:
				clsName = "XML"; //$NON-NLS-1$
				break;
			case kNativeXMLNode:
				clsName = "XMLNode"; //$NON-NLS-1$
				break;
			case kNativeCameraObject:
				clsName = "Camera"; //$NON-NLS-1$
				break;
			case kNativeMicrophoneObject:
				clsName = "Microphone"; //$NON-NLS-1$
				break;
			case kNativeCommunicationObject:
				clsName = "Communication"; //$NON-NLS-1$
				break;
			case kNetConnectionObjectType:
				clsName = "Connection"; //$NON-NLS-1$
				break;
			case kNetStreamObjectType:
				clsName = "Stream"; //$NON-NLS-1$
				break;
			case kVideoObjectType:
				clsName = "Video"; //$NON-NLS-1$
				break;
			case kTextFormatObjectType:
				clsName = "TextFormat"; //$NON-NLS-1$
				break;
			case kSharedObjectType:
				clsName = "SharedObject"; //$NON-NLS-1$
				break;
			case kSharedObjectDataType:
				clsName = "SharedObjectData"; //$NON-NLS-1$
				break;
			case kPrintJobObjectType:
				clsName = "PrintJob"; //$NON-NLS-1$
				break;
			case kMovieClipLoaderObjectType:
				clsName = "MovieClipLoader"; //$NON-NLS-1$
				break;
			case kStyleSheetObjectType:
				clsName = "StyleSheet"; //$NON-NLS-1$
				break;
			case kFapPacketDummyObject:
				clsName = "FapPacket"; //$NON-NLS-1$
				break;
			case kLoadVarsObject:
				clsName = "LoadVars"; //$NON-NLS-1$
				break;
			case kTextSnapshotType:
				clsName = "TextSnapshot"; //$NON-NLS-1$
				break;
			default:
				clsName = PlayerSessionManager.getLocalizationManager().getLocalizedTextString("unknown") + "<" + clsType + ">"; //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
				break;
		}
		return clsName;
	}
}
