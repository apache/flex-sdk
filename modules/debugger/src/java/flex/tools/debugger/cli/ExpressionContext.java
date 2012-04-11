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

package flex.tools.debugger.cli;

import java.util.StringTokenizer;
import java.util.Vector;

import flash.tools.debugger.PlayerDebugException;
import flash.tools.debugger.Session;
import flash.tools.debugger.SessionManager;
import flash.tools.debugger.Value;
import flash.tools.debugger.ValueAttribute;
import flash.tools.debugger.Variable;
import flash.tools.debugger.VariableType;
import flash.tools.debugger.concrete.DValue;
import flash.tools.debugger.events.ExceptionFault;
import flash.tools.debugger.events.FaultEvent;
import flash.tools.debugger.expression.Context;
import flash.tools.debugger.expression.ExpressionEvaluatorException;
import flash.tools.debugger.expression.NoSuchVariableException;
import flash.tools.debugger.expression.PlayerFaultException;

public class ExpressionContext implements Context
{
	ExpressionCache		m_cache;
	Object				m_current;
	boolean				m_createIfMissing;  // set if we need to create a variable if it doesn't exist
	Vector<String>		m_namedPath;
	boolean				m_nameLocked;
	String				m_newline = System.getProperty("line.separator"); //$NON-NLS-1$

	// used when evaluating an expression
	public ExpressionContext(ExpressionCache cache)
	{
		m_cache = cache;
		m_current = null;
		m_createIfMissing = false;
		m_namedPath = new Vector<String>();
		m_nameLocked = false;
	}

	void		setContext(Object o)	{ m_current = o; }

	void		pushName(String name)	{ if (m_nameLocked || name.length() < 1) return; m_namedPath.add(name);  }
	boolean		setName(String name)	{ if (m_nameLocked) return true; m_namedPath.clear(); pushName(name); return true; }
	void		lockName()				{ m_nameLocked = true; }

	public String getName()
	{
		int size = m_namedPath.size();
		StringBuilder sb = new StringBuilder();
		for(int i=0; i<size; i++)
		{
			String s = m_namedPath.get(i);
			if (i > 0)
				sb.append('.');
			sb.append(s);
		}
		return ( sb.toString() );
	}

	String getCurrentPackageName()
	{ 
		String s = null;
		try
		{
			Integer o = (Integer)m_cache.get(DebugCLI.LIST_MODULE);
			s = m_cache.getPackageName(o.intValue());
		}
		catch(NullPointerException npe)
		{
		}
		catch(ClassCastException cce)
		{
		}
		return s; 
	}

	//
	//
	// Start of Context API implementation
	//
	//
	public void createPseudoVariables(boolean oui) { m_createIfMissing = oui; }

	// create a new context object by combining the current one and o 
	public Context createContext(Object o)
	{
		ExpressionContext c = new ExpressionContext(m_cache);
		c.setContext(o);
		c.createPseudoVariables(m_createIfMissing);
		c.m_namedPath.addAll(m_namedPath);
		return c;
	}

	// assign the object o, the value v
	public void assign(Object o, Value v) throws NoSuchVariableException, PlayerFaultException
	{
		try
		{
			// first see if it is an internal property (avoids player calls)
			InternalProperty prop = resolveToInternalProperty(o);

			// we expect that o is a variable that can be resolved or is a specially marked internal variable
			if (prop != null)
			{
				assignInternal(prop, v);
			}
			else
			{
				boolean wasCreateIfMissing = m_createIfMissing;
				createPseudoVariables(true);
				Variable var = null;
				try {
					var = resolveToVariable(o);
				} finally {
					createPseudoVariables(wasCreateIfMissing);
				}

				if (var == null)
					throw new NoSuchVariableException((var == null) ? m_current : var.getName());

				// set the value, for the case of a variable that does not exist it will not have a type
				// so we try to glean one from v.
				FaultEvent faultEvent = var.setValue(getSession(), v.getType(), v.getValueAsString());
				if (faultEvent != null)
					throw new PlayerFaultException(faultEvent);
			}
		}
		catch(PlayerDebugException pde)
		{
			throw new ExpressionEvaluatorException(pde);
		}
	}

	/**
	 * The Context interface which goes out and gets values from the session
	 * Expressions use this interface as a means of evaluation.
	 * 
	 * We also use this to create a reference to internal variables.
	 */
	public Object lookup(Object o) throws NoSuchVariableException, PlayerFaultException
	{
		Object result = null;
		try
		{
			// first see if it is an internal property (avoids player calls)
			if ( (result = resolveToInternalProperty(o)) != null)
				;

			// attempt to resolve to a player variable
			else if ( (result = resolveToVariable(o)) != null)
				;

			// or value
			else if ( (result = resolveToValue(o)) != null)
				;

			else
				throw new NoSuchVariableException(o);

			// take on the path to the variable; so 'what' command prints something nice
			if ((result != null) && result instanceof VariableFacade)
			{
				((VariableFacade)result).setPath(getName());
			}

			// if the attempt to get the variable's value threw an exception inside the
			// player (most likely because the variable is actually a getter, and the
			// getter threw something), then throw something here
			Value resultValue = null;

			if (result instanceof Variable)
			{
				if (result instanceof VariableFacade && ((VariableFacade)result).getVariable() == null)
					resultValue = null;
				else
					resultValue = ((Variable)result).getValue();
			}
			else if (result instanceof Value)
			{
				resultValue = (Value) result;
			}

			if (resultValue != null)
			{
				if (resultValue.isAttributeSet(ValueAttribute.IS_EXCEPTION))
				{
					String value = resultValue.getValueAsString();
					throw new PlayerFaultException(new ExceptionFault(value, false, resultValue));
				}
			}
		}
		catch(PlayerDebugException pde)
		{
			result = Value.UNDEFINED;
		}
		return result;
	}

	/* returns a string consisting of formatted member names and values */
	public Object lookupMembers(Object o) throws NoSuchVariableException
	{
		Variable var = null;
		Value val = null;
  		Variable[] mems = null;
		try
		{
			var = resolveToVariable(o);
			if (var != null)
				val = var.getValue();
			else
				val = resolveToValue(o);
			mems = val.getMembers(getSession());
		}
		catch(NullPointerException npe)
		{
			throw new NoSuchVariableException(o);
		}
		catch(PlayerDebugException pde)
		{
			throw new NoSuchVariableException(o); // not quite right...
		}

  		StringBuilder sb = new StringBuilder();

  		if (var != null)
  			ExpressionCache.appendVariable(sb, var);
  		else
  			ExpressionCache.appendVariableValue(sb, val);

		boolean attrs = m_cache.propertyEnabled(DebugCLI.DISPLAY_ATTRIBUTES);
		if (attrs && var != null)
			ExpressionCache.appendVariableAttributes(sb, var);

		// [mmorearty] experimenting with hierarchical display of members
		String[] classHierarchy = val.getClassHierarchy(false);
		if (classHierarchy != null && getSession().getPreference(SessionManager.PREF_HIERARCHICAL_VARIABLES) != 0)
		{
			for (int c=0; c<classHierarchy.length; ++c)
			{
				String classname = classHierarchy[c];
				sb.append(m_newline + "(Members of " + classname + ")"); //$NON-NLS-1$ //$NON-NLS-2$
				for (int i=0; i<mems.length; ++i)
				{
					if (classname.equals(mems[i].getDefiningClass()))
					{
			  			sb.append(m_newline + " "); //$NON-NLS-1$
			  			ExpressionCache.appendVariable(sb, mems[i]);
						if (attrs)
							ExpressionCache.appendVariableAttributes(sb, mems[i]);
					}
				}
			}
		}
		else
		{
	  		for(int i=0; i<mems.length; i++)
	  		{
	  			sb.append(m_newline + " "); //$NON-NLS-1$
	  			ExpressionCache.appendVariable(sb, mems[i]);
				if (attrs)
					ExpressionCache.appendVariableAttributes(sb, mems[i]);
	  		}
		}

  		return sb.toString();
  	}

	//
	//
	// End of Context API implementation 
	//
	//

	// used to assign a value to an internal variable 
	private void assignInternal(InternalProperty var, Value v) throws NoSuchVariableException, NumberFormatException, PlayerDebugException
	{
		// otherwise set it
		if (v.getType() != VariableType.NUMBER)
			throw new NumberFormatException(v.getValueAsString());
		long l = Long.parseLong(v.getValueAsString());
		m_cache.put(var.getName(), (int)l);
	}

	InternalProperty resolveToInternalProperty(Object o)
	{
		if (o instanceof String && ((String)o).charAt(0) == '$')
		{
			String key = (String)o;
			Object value = null;

			try { value = m_cache.get(key); } catch(Exception e) {}
			return new InternalProperty(key, value);
		}

		return null;
	}

	/**
	 * Resolve the object into a variable by various means and 
	 * using the current context.
	 * @return variable, or <code>null</code>
	 */
	Variable resolveToVariable(Object o) throws PlayerDebugException
	{
		Variable v = null;

		// if o is a variable already, then we're done!
		if (o instanceof Variable)
			return (Variable)o;

		/**
		 * Resolve the name to something
		 */
		{
			// not an id so try as name 
			String name = o.toString();
			long id = nameAsId(name);

			/**
			 * if #N was used just pick up the variable, otherwise
			 * we need to use the current context to resolve 
			 * the name to a member
			 */
			if (id != Value.UNKNOWN_ID)
			{
				// TODO what here?
			}
			else
			{
				// try to resolve as a member of current context (will set context if null)
				id = determineContext(name);
				v = locateForNamed(id, name, true);
				if (v != null)
					v = new VariableFacade(v, id);
				else if (v == null && m_createIfMissing && name.charAt(0) != '$')
					v = new VariableFacade(id, name);
			}
		}

		/* return the variable */
		return v;
	}

	/*
	 * Resolve the object into a variable by various means and 
	 * using the current context.
	 */
	Value resolveToValue(Object o) throws PlayerDebugException
	{
		Value v = null;

		// if o is a variable or a value already, then we're done!
		if (o instanceof Value)
			return (Value)o;
		else if (o instanceof Variable)
			return ((Variable)o).getValue();
		else if (o instanceof InternalProperty)
			return DValue.forPrimitive(((InternalProperty)o).m_value);

		/**
		 * Resolve the name to something
		 */
		if (m_current == null)
		{
			// not an id so try as name 
			String name = o.toString();
			long id = nameAsId(name);

			/**
			 * if #N was used just pick up the variable, otherwise
			 * we need to use the current context to resolve 
			 * the name to a member
			 */
			if (id != Value.UNKNOWN_ID)
			{
				v = getSession().getValue((int)id);
			}
			else if (name.equals("undefined")) //$NON-NLS-1$
			{
				v = DValue.forPrimitive(Value.UNDEFINED);
			}
			else
			{
				// Ask the player to find something, anything, on the scope chain
				// with this name.  We'll end up here, for example, when resolving
				// things like MyClass, String, Number, etc.
				v = getSession().getGlobal(name);
			}
		}

		/* return the value */
		return v;
	}

	// special code for #N support. I.e. naming a variable via an ID
	long nameAsId(String name)
	{
		long id = Value.UNKNOWN_ID;
		try
		{
			if (name.charAt(0) == '#')
				id = Long.parseLong(name.substring(1));
		}
		catch(Exception e) 
		{
			id = Value.UNKNOWN_ID;
		}
		return id;
	}

	/**
	 * Using the given id as a parent find the member named
	 * name.
	 * @throws NoSuchVariableException if id is UNKNOWN_ID
	 */
	Variable memberNamed(long id, String name) throws NoSuchVariableException, PlayerDebugException
	{
		Variable v = null;
		Value parent = getSession().getValue(id);

		if (parent == null)
			throw new NoSuchVariableException(name);

		/* got a variable now return the member if any */
		v = parent.getMemberNamed(getSession(), name);

		return v;
	}

	/**
	 * All the really good stuff about finding where name exists goes here!
	 * 
	 * If name is not null, then it implies that we use the existing
	 * m_current to find a member of m_current.  If m_current is null
	 * Then we need to probe variable context points attempting to locate
	 * name.  When we find a match we set the m_current to this context
	 *
	 * If name is null then we simply return the current context.
	 */
	long determineContext(String name) throws PlayerDebugException
	{
		long id = Value.UNKNOWN_ID;

		// have we already resolved our context...
		if (m_current != null)
		{
			id = toValue().getId();
		}

		// nothing to go on, so we're done
		else if (name == null)
			;

		// use the name and try and resolve where we are...
		else
		{
			// Each stack frame has a root variable under (BASE_ID-depth)
			// where depth is the depth of the stack.
			// So we query for our current stack depth and use that 
			// as the context for our base computation
			long baseId = Value.BASE_ID;
			int depth = ((Integer)m_cache.get(DebugCLI.DISPLAY_FRAME_NUMBER)).intValue();
			baseId -= depth;

			// obtain data about our current state 
			Variable contextVar = null;
			Value contextVal = null;
			Value val = null;

			// look for 'name' starting from local scope
			if ( (val = locateParentForNamed(baseId, name, false)) != null)
				;

			// get the this pointer, then look for 'name' starting from that point
			else if ( ( (contextVar = locateForNamed(baseId, "this", false)) != null ) &&  //$NON-NLS-1$
					  ( setName("this") && (val = locateParentForNamed(contextVar.getValue().getId(), name, true)) != null ) ) //$NON-NLS-1$
				;

			// now try to see if 'name' exists off of _root
			else if ( setName("_root") && (val = locateParentForNamed(Value.ROOT_ID, name, true)) != null ) //$NON-NLS-1$
				;

			// now try to see if 'name' exists off of _global
			else if ( setName("_global") && (val = locateParentForNamed(Value.GLOBAL_ID, name, true)) != null ) //$NON-NLS-1$
				;

			// now try off of class level, if such a thing can be found
			else if ( ( (contextVal = locate(Value.GLOBAL_ID, getCurrentPackageName(), false)) != null ) && 
					  ( setName("_global."+getCurrentPackageName()) && (val = locateParentForNamed(contextVal.getId(), name, true)) != null ) ) //$NON-NLS-1$
				;

			// if we found it then stake this as our context!
			if (val != null)
			{
				id = val.getId();
				pushName(name);
				lockName();
			}
		}
		
		return id;
	}

	/**
	 * Performs a search for a member with the given name using the
	 * given id as the parent variable.
	 * 
	 * If a match is found then, we return the parent variable of
	 * the member that matched.  The proto chain is optionally traversed.
	 * 
	 * No exceptions are thrown
	 */
	Value locateParentForNamed(long id, String name, boolean traverseProto) throws PlayerDebugException
	{
		StringBuilder sb = new StringBuilder();

		Variable var = null;
		Value val = null;
		try
		{
			var = memberNamed(id, name);

			// see if we need to traverse the proto chain
			while (var == null && traverseProto)
			{
				// first attempt to get __proto__, then resolve name
				Variable proto = memberNamed(id, "__proto__"); //$NON-NLS-1$
 				sb.append("__proto__"); //$NON-NLS-1$
				if (proto == null)
					traverseProto = false;
				else
				{
					id = proto.getValue().getId();
					var = memberNamed(id, name);
					if (var == null)
						sb.append('.');
				}
			}
		}
		catch(NoSuchVariableException nsv)
		{
			// don't worry about this one, it means variable with id couldn't be found
		}
		catch(NullPointerException npe)
		{
			// probably no session
		}

		// what we really want is the parent not the child variable
		if (var != null)
		{
			pushName(sb.toString());
			val = getSession().getValue(id);
		}

		return val;
	}

	// variant of locateParentForNamed, whereby we return the child variable
	Variable locateForNamed(long id, String name, boolean traverseProto) throws PlayerDebugException
	{
		Variable var = null;
		Value v = locateParentForNamed(id, name, traverseProto);
		if (v != null)
		{
			try
			{
				var = memberNamed(v.getId(), name);
			}
			catch(NoSuchVariableException nse)
			{
				v = null;
			}
		}

		return var;
	}

	/**
	 * Locates the member via a dotted name starting at the given id.
	 * It will traverse any and all proto chains if necc. to find the name.
	 */
	Value locate(long startingId, String dottedName, boolean traverseProto) throws PlayerDebugException
	{
		if (dottedName == null)
			return null;

		// first rip apart the dottedName
		StringTokenizer names = new StringTokenizer(dottedName, "."); //$NON-NLS-1$
		Value val = getSession().getValue(startingId);

		while(names.hasMoreTokens() && val != null)
			val = locateForNamed(val.getId(), names.nextToken(), traverseProto).getValue();

		return val;
	}

	/*
	 * @see flash.tools.debugger.expression.Context#toValue(java.lang.Object)
	 */
	public Value toValue(Object o)
	{
		// if o is a variable or a value already, then we're done!
		if (o instanceof Value)
			return (Value)o;
		else if (o instanceof Variable)
			return ((Variable)o).getValue();
		else if (o instanceof InternalProperty)
			return DValue.forPrimitive(((InternalProperty)o).m_value);
		else
			return DValue.forPrimitive(o);
	}

	public Value toValue()
	{
		return toValue(m_current);
	}

	public Session getSession()
	{
		return m_cache.getSession();
	}
}
