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

package flex2.compiler.mxml.lang;

import flex2.compiler.mxml.reflect.*;

/**
 * Encapsulates the order in which we attempt to resolve an MXML
 * attribute or child node name, against an AS3 type.
 * <p>
 * Implementer overrides handler routines.
 * <p>
 * NOTE: search order applies to both attribute and child
 * declarations, of both faceless and visual components.
 */
public abstract class DeclarationHandler
{
	/**
	 * name resolves to Event
	 */
	protected abstract void event(Event event);

	/**
	 * name resolves to declared property
	 */
	protected abstract void property(Property property);
	
	/**
	 * name resolves to declared states property
	 */
	protected abstract void states(Property property);

	/**
	 * name resolves to Effect name
	 * @param effect
	 */
	protected abstract void effect(Effect effect);

	/**
	 * name resolves to Style
	 */
	protected abstract void style(Style style);

	/**
	 * name resolves to dynamic property
	  */
	protected abstract void dynamicProperty(String name, String state);

	/**
	 * name fails to resolve
	 */
	protected abstract void unknown(String namespace, String localPart);

	/**
	 * Search (in order) the following places in our Type for the given name:
	 * <li>- event
	 * <li>- property
	 * <li>- effect
	 * <li>- style
	 * <li>- dynamic property (if target type is dynamic)
	 * 
	 * Assign state-specificity here as well.
	 */
	protected void invoke(Type type, String namespace, String localPart, String state)
	{
		Event event = type.getEvent(localPart);
		if (event != null)
		{
			event.setStateName(state);
			event(event);
			return;
		}
		
		Property property = type.getProperty(localPart);
		if (property != null)
		{
			property.setStateName(state);

			if (localPart.equals(StandardDefs.PROP_UICOMPONENT_STATES))
			{
				states(property);
			}
			else
			{
				property(property);
			}
			return;
		}

		Effect effect = type.getEffect(localPart);
		if (effect != null)
		{
			effect.setStateName(state);
			effect(effect);
			return;
		}

        Style style = type.getStyle(localPart);
        if (style != null)
        {
            style.setStateName(state);
            style(style);
            return;
        }

		if (type.hasDynamic())
		{
			dynamicProperty(localPart, state);
			return;
		}

		unknown(namespace, localPart);
	}
	
	/*
	 * 
	 */
	protected void invoke(Type type, String namespace, String localPart)
	{
		invoke(type, namespace, localPart, (String) null);
	}
}
