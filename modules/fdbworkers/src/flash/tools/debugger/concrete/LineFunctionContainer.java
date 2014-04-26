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

import flash.swf.Action;
import flash.swf.ActionConstants;
import flash.swf.types.ActionList;
import flash.swf.actions.DefineFunction;
import flash.swf.debug.LineRecord;
import flash.tools.ActionLocation;
import flash.swf.MovieMetaData;
import flash.tools.SwfActionContainer;
import flash.util.Trace;

/**
 * This class extends the SwfActionContainer.
 * It performs a number of passes on the master
 * action list in order to extract line/function
 * mapping information.
 */
public class LineFunctionContainer extends SwfActionContainer
{
    public LineFunctionContainer(byte[] swf, byte[] swd)
	{
		super(swf, swd);

		// now that we've got all the action lists
		// nicely extracted and lined up we perform a 
		// bit of magic which modifies the DefineFunction 
		// records augmenting them with function names 
		// if they have have none.
		buildFunctionNames(getMasterList(), getHeader().version);
	}

	/**
	 * Use the action list located in the given location
	 * and return a new action location that corresponds
	 * to the next line record that is encountered
	 * after this location.  This routine does not 
	 * span into another action list.
	 */
	public ActionLocation endOfSourceLine(ActionLocation l)
	{
		ActionLocation current = new ActionLocation(l);
		int size = l.actions.size();
		for(int i= l.at+1; i<size; i++)
		{
			// hit a line record => we done
			Action a = l.actions.getAction(i);
			if (a.code == ActionList.sactionLineRecord)
				break;

			// hit a function => we are done
			if ( (a.code == ActionConstants.sactionDefineFunction) ||
				 (a.code == ActionConstants.sactionDefineFunction2) )
				break;

			current.at = i;
		}
		return current;
	}

	/**
	 * This routine is called from the DSwfInfo object
	 * and is used to obtain LineRecord information 
	 * from the ActionLists
	 */
	public void combForLineRecords(DSwfInfo info)
	{
		probeForLineRecords(getMasterList(), new ActionLocation(), info);
	}

	/**
	 * This routine is called from the DSwfInfo object
	 * and is used to obtain LineRecord information 
	 * from the ActionLists
	 * 
	 * The ActionLocation record is used as a holding
	 * container for state as we traverse the lists
	 */
	void probeForLineRecords(ActionList list, ActionLocation where, DSwfInfo info)
	{
		int size = list.size();
		for(int i=0; i<size; i++)
		{
			try
			{
				// set our context
				where.at = i;
				where.actions = list;

				// pull the action
				Action a = list.getAction(i);

				// then see if we need to traverse
				if ( (a.code == ActionConstants.sactionDefineFunction) ||
					 (a.code == ActionConstants.sactionDefineFunction2) )
				{
					where.function = (DefineFunction)a;
					probeForLineRecords(((DefineFunction)a).actionList, where, info);
					where.function = null;
				}
				else if (a.code == ActionList.sactionLineRecord)
				{
					// hit a line record, so let's do our callback
					info.processLineRecord(where, (LineRecord)a);
				}
				else if (a instanceof DummyAction)
				{
					// our dummy container, then we drop in
					where.className = ((DummyAction)a).getClassName();
					probeForLineRecords(((DummyAction)a).getActionList(), where, info);
					where.className = null;
				}
			}		
			catch(Exception e)
			{
				// this is fairly bad and probably means that we have corrupt line
				// records in the swd, the exception being an ArrayIndexOutOfBoundsException. 
				// I've seen this in cases where a bad swc is built by authoring wherein a
				// script id collision occurs and thus the offset table will contain references
				// to line numbers that are non existent in one of the scripts.
				// If its another type of exception...well, hopefully the trace message will
				// help you track it down :)
				if (Trace.error)
				{
					Trace.trace("Error processing ActionList at "+where.at+" at offset "+where.actions.getOffset(where.at)+" in swf "+info.getUrl()); //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$
					e.printStackTrace();
				}
			}
		}
	}

	/**
	 * Go off and fill our DefineFunction records with function names.
	 * @see MovieMetaData#walkActions for a discussion on how this is done.
	 */
	void buildFunctionNames(ActionList list, int version)
	{
		int size = list.size();
		for(int i=0; i<size; i++)
		{
			DummyAction a = (DummyAction)list.getAction(i);
			MovieMetaData.walkActions( a.getActionList(), version, null, a.getClassName(), null );
		}		
	}
}
