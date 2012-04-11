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

package flash.swf.debug;

import flash.swf.Action;
import flash.swf.ActionHandler;
import flash.swf.types.ActionList;

/**
 * This class represents a AS2 "register record" byte code.
 */
public class RegisterRecord extends Action
{
	public RegisterRecord(int offset, int numRegisters)
	{
		super(ActionList.sactionRegisterRecord);
		int size = numRegisters;
		registerNumbers = new int[size];
		variableNames = new String[size];
		this.offset = offset;
		next = 0;
	}

    public int[] registerNumbers;
	public String[] variableNames;
	public int offset;

	// internal use for addRegister()
	int next;

	/**
	 * Used to add a register entry into this record
	 */
	public void addRegister(int regNbr, String variableName)
	{
		registerNumbers[next] = regNbr;
		variableNames[next] = variableName;
		next++;
	}

	public int indexOf(int regNbr)
	{
		int at = -1;
		for(int i=0; at<0 && i<registerNumbers.length; i++)
		{
			if (registerNumbers[i] == regNbr)
				at = i;
		}
		return at;
	}

	public void visit(ActionHandler h)
	{
		h.registerRecord(this);
	}

    public String toString()
    {
		StringBuilder sb = new StringBuilder();
		sb.append(offset);
		sb.append(" ");
		for(int i=0; i<registerNumbers.length; i++)
			sb.append("$"+registerNumbers[i]+"='"+variableNames[i]+"' ");
		return ( sb.toString() ); 
    }

    public boolean equals(Object object)
    {
		boolean isIt = (object instanceof RegisterRecord); 
        if (isIt)
        {
            RegisterRecord other = (RegisterRecord) object;
            isIt = super.equals(other);
			for(int i=0; isIt && i<registerNumbers.length; i++)
			{
				isIt = ( (other.registerNumbers[i] == this.registerNumbers[i]) &&
						 (other.variableNames[i] == this.variableNames[i]) ) ? isIt : false;
			}
        }
		return isIt;
    }
}
