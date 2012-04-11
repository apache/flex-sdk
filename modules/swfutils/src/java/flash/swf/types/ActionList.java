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

package flash.swf.types;

import java.util.Arrays;

import flash.swf.Action;
import flash.swf.ActionHandler;

/**
 * This class represents an array of AS2 byte codes.
 *
 * @author Clement Wong
 */
public class ActionList extends ActionHandler
{
	// start numbering internal opcodes at 256 to make sure we wont
	// collide with a real player opcode.  player opcodes are 8-bit.
	public static final int sactionLabel = 256;
	public static final int sactionLineRecord = 257;
	public static final int sactionRegisterRecord = 258;

	public ActionList()
	{
        this(false);
	}

    public ActionList(int capacity)
    {
        this(false, capacity);
    }

    public ActionList(boolean keepOffsets)
    {
        this(keepOffsets, 10);
    }

    public ActionList(boolean keepOffsets, int capacity)
    {
        if (keepOffsets)
            offsets = new int[capacity];
        actions = new Action[capacity];
        size = 0;
    }

	private int[] offsets;
	private Action[] actions;
	private int size;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof ActionList)
        {
            ActionList actionList = (ActionList) object;

            if ( Arrays.equals(actionList.actions, this.actions) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }    

	public void visitAll(ActionHandler handler)
	{
		visit(handler, 0, size-1);
    }

	public void visit(ActionHandler handler, int startIndex, int endIndex)
	{
		endIndex = (endIndex < 0) ? size-1 : endIndex;
		for (int j=startIndex; j <= endIndex; j++)
		{
			Action a = actions[j];
			if (a.code != sactionLabel && a.code != sactionLineRecord)
			{
				// don't call this for labels
                if (offsets != null)
    				handler.setActionOffset(offsets[j], a);
                else
                    handler.setActionOffset(j, a);
			}
			a.visit(handler);
		}
    }

    public void setActionOffset(int offset, Action a)
    {
		insert(offset, a);
    }

	public void grow(int capacity)
	{
        if (offsets != null)
        {
            int[] newoffsets = new int[capacity];
            System.arraycopy(offsets,0,newoffsets,0,size);
            offsets = newoffsets;
        }

		Action[] newactions = new Action[capacity];
		System.arraycopy(actions,0,newactions,0,size);
		actions = newactions;
	}

	public int size()
	{
		return size;
	}

	public Action getAction(int i)
	{
		return actions[i];
	}

	public int getOffset(int i)
	{
		return offsets[i];
	}

	public void remove(int i)
	{
        if (offsets != null)
    		System.arraycopy(offsets, i+1, offsets, i, size-i-1);
		System.arraycopy(actions, i+1, actions, i, size-i-1);
		size--;
	}

	/**
	 * perform a binary search to find the requested offset.
	 * @param k
	 * @return the index where that offset is found, or -(ins+1) if
	 * the key is not found, and ins is the insertion index.
	 *
	 */
	private int find(int k)
	{
        if (offsets != null)
        {
            int lo = 0;
            int hi = size-1;

            while (lo <= hi)
            {
                int i = (lo + hi)/2;
                int m = offsets[i];
                if (k > m)
                    lo = i + 1;
                else if (k < m)
                    hi = i - 1;
                else
                    return i; // key found
            }
            return -(lo + 1);  // key not found, lo is the insertion point
        }
        else
        {
            return k;
        }
	}

	public void insert(int offset, Action a)
	{
		if (size==actions.length)
			grow(size*2);
		int i;
		if (size == 0 || offsets == null && offset == size || offsets != null && offset > offsets[size-1])
		{
			// appending.
			i = size;
		}
		else
		{
			i = find(offset);
			if (i < 0)
			{
				// offset not used yet.  compute insertion point
				i = -i - 1;
			}
			else
			{
				// offset already used.  if we are inserting a real action, make it be last
				if (a.code < 256)
				{
					// this is a real action, we want it to be last at this offset
					while (i < size && offsets[i] == offset)
						i++;
				}
			}
            if (offsets != null)
    			System.arraycopy(offsets, i, offsets, i+1, size-i);
			System.arraycopy(actions, i, actions, i+1, size-i);
		}
        if (offsets != null)
    		offsets[i] = offset;
		actions[i] = a;
		size++;
	}

    public void append(Action a)
    {
        int i=size;
        if (i == actions.length)
            grow(size*2);
        actions[i] = a;
        size = i+1;
    }

    public String toString()
    {
        StringBuilder stringBuffer = new StringBuilder();

        stringBuffer.append("ActionList: count = " + actions.length);
        stringBuffer.append(", actions = ");

        for (int i = 0; i < size; i++)
        {
            stringBuffer.append(actions[i]);
        }

        return stringBuffer.toString();
    }

	/**
	 * Return the index within this action list of the first
	 * occurence of the specified actionCode, searching foward
	 * starting at the given index
	 */
	public int indexOf(int actionCode, int startAt)
	{
		int at = -1;
		for(int i=startAt; at<0 && i<actions.length; i++)
		{
			Action a = getAction(i);
			if (a != null && a.code == actionCode)
				at = i;
		}
		return at;
	}

	/**
	 * Return the index within this action list of the first
	 * occurence of the specified actionCode, searching backward
	 * starting at the given index
	 */
	public int lastIndexOf(int actionCode, int startAt)
	{
		int at = -1;
		for(int i=startAt; at<0 && i>=0; i--)
		{
			Action a = getAction(i);
			if (a != null && a.code == actionCode)
				at = i;
		}
		return at;
	}

	// specialized indexOf and lastIndexOf that start at the beginning and end of the actions list respectively
	public int indexOf(int actionCode) { return indexOf(actionCode, 0); }
	public int lastIndexOf(int actionCode) { return lastIndexOf(actionCode, actions.length-1); }

    public void setAction(int i, Action action)
    {
        actions[i] = action;
    }
}
