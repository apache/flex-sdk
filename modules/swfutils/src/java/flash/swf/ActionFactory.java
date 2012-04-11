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

package flash.swf;

import flash.swf.actions.Push;
import flash.swf.actions.StoreRegister;
import flash.swf.actions.StrictMode;
import flash.swf.actions.Label;
import flash.swf.actions.WaitForFrame;
import flash.swf.types.ActionList;
import flash.swf.debug.LineRecord;
import flash.swf.debug.RegisterRecord;

import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;

/**
 * This is a factory for decoding ActionScript bytecode.  It keeps
 * track of temporary information we need while decoding but can
 * discard once we are done.
 * @author Edwin Smith
 */
final public class ActionFactory
{
    public static final Object UNDEFINED = new Object()
    {
        public String toString()
        {
            return "undefined";
        }
    };
    
    public static final Object STACKTOP = new Object()
    {
        public String toString()
        {
            return "stack";
        }
    };

    /** flyweight action objects for 1-byte opcodes 0..7F */
    private static final Action[] actionFlyweights = new Action[0x80];
    private static final Push[] pushCpoolFlyweights = new Push[256];
    private static final Push[] pushRegisterFlyweights = new Push[256];
    private static final StoreRegister[] storeRegisterFlyweights = new StoreRegister[256];
    private static final Push pushTrueFlyweight = new Push(Boolean.TRUE);
    private static final Push pushFalseFlyweight = new Push(Boolean.FALSE);
    private static final Push pushUndefinedFlyweight = new Push(UNDEFINED);
    private static final Push pushNullFlyweight = new Push(null);
    private static final Push pushFloat0Flyweight = new Push(new Float(0));
    private static final Push pushInteger0Flyweight = new Push(new Integer(0));
    private static final Push pushDouble0Flyweight = new Push(new Double(0));
    private static final Action callFlyweight = new Action(ActionConstants.sactionCall);
    private static final StrictMode strictTrueFlyweight = new StrictMode(true);
    private static final StrictMode strictFalseFlyweight = new StrictMode(false);

    static
    {
        for (int i=0; i < 0x80; i++)
        {
            ActionFactory.actionFlyweights[i] = new Action(i);
        }

		for (int i=0; i < 256; i++)
		{
			ActionFactory.pushRegisterFlyweights[i] = new Push(new Byte((byte)i));
			ActionFactory.pushCpoolFlyweights[i] = new Push(new Short((short)i));
			ActionFactory.storeRegisterFlyweights[i] = new StoreRegister(i);
		}
	}

    public static Action createAction(int code)
    {
        return actionFlyweights[code];
    }

    public static Push createPushCpool(int index)
    {
        return (index < pushCpoolFlyweights.length)
                        ? pushCpoolFlyweights[index]
                        : new Push(new Short((short)index));
    }

    public static Push createPush(String s)
    {
        return new Push(s);
    }

    public static Push createPush(float fvalue)
    {
        return fvalue == 0
                            ? pushFloat0Flyweight
                            : new Push(new Float(fvalue));
    }

    public static Push createPushNull()
    {
        return pushNullFlyweight;
    }

    public static Push createPushUndefined()
    {
        return pushUndefinedFlyweight;
    }

    public static Push createPushRegister(int regno)
    {
        return pushRegisterFlyweights[regno];
    }

    public static Push createPush(boolean b)
    {
        return (b ? pushTrueFlyweight : pushFalseFlyweight);
    }

    public static Push createPush(double dvalue)
    {
        return dvalue == 0
                            ? pushDouble0Flyweight
                            : new Push(new Double(dvalue));
    }

    public static Push createPush(int ivalue)
    {
        return ivalue == 0
                            ? pushInteger0Flyweight
                            : new Push(new Integer(ivalue));
    }

    public static StoreRegister createStoreRegister(int register)
    {
        return storeRegisterFlyweights[register];
    }

    public static Action createCall()
    {
        return callFlyweight;
    }

    public static StrictMode createStrictMode(boolean mode)
    {
        return mode ? strictTrueFlyweight : strictFalseFlyweight;
    }

    private final int startOffset;
    private final int startCount;
    private final Action[] actions;
    private final Label[] labels;
    private final LineRecord[] lines;
	private final RegisterRecord[] registers;
    private final int[] actionOffsets;
    private int count;
    private List<SkipEntry> skipRecords;

    public ActionFactory(int length, int startOffset, int startCount)
    {
        this.startOffset = startOffset;
        this.startCount = startCount;

        labels = new Label[length+1];  // length+1 to handle labels after last action
        lines = new LineRecord[length];
		registers = new RegisterRecord[length];
        actions = new Action[length];
        actionOffsets = new int[length+1];
        skipRecords = new ArrayList<SkipEntry>();
    }

    public void setLine(int offset, LineRecord line)
    {
        int i = offset-startOffset;
        if (lines[i] == null)
            count++;
        lines[i] = line;
    }

	public void setRegister(int offset, RegisterRecord record)
	{
		int i = offset-startOffset;
		if (registers[i] == null)
			count++;
		registers[i] = record;
	}

    public void setAction(int offset, Action a)
    {
        int i = offset-startOffset;
        if (actions[i] == null)
            count++;
        actions[i] = a;
    }

    public Label getLabel(int target)
    {
        int i = target-startOffset;
        Label label = null;

        // See http://bugs.adobe.com/jira/browse/SDK-23169, for a SWF
        // where i is negative.  This seems like a broken SWF, because
        // a branch is trying to jump before the start of the
        // DoInitAction.  To avoid a ArrayIndexOutOfBoundsException,
        // do a range check.
        if ((i >= 0) && (i < labels.length))
        {
            label = labels[i];

            if (label == null)
            {
                labels[i] = label = new Label();
                count++;
            }
        }

        return label;
    }

    public void setActionOffset(int actionCount, int offset)
    {
        actionOffsets[actionCount-startCount] = offset;
    }

    /**
     * now that everything has been decoded, build a single actionlist
     * with the labels and jump targets merged in.
     * @param keepOffsets
     * @return
     */
    public ActionList createActionList(boolean keepOffsets)
    {
        processSkipEntries();

        ActionList list = new ActionList(keepOffsets);
        list.grow(count);
        Action a;
        int length = actions.length;
        if (keepOffsets)
        {
            for (int i=0; i < length; i++)
            {
                int offset = startOffset+i;
                if ((a=actions[i]) != null)
                    list.insert(offset, a);
                if ((a=lines[i]) != null)
                    list.insert(offset, a);
				if ((a=registers[i]) != null)
					list.insert(offset, a);
                if ((a=labels[i]) != null)
                    list.insert(offset, a);
            }
            if ((a=labels[length]) != null)
                list.insert(startOffset+length, a);
        }
        else
        {
            for (int i=0; i < length; i++)
            {
                if ((a=labels[i]) != null)
                    list.append(a);
                if ((a=lines[i]) != null)
                    list.append(a);
				if ((a=registers[i]) != null)
					list.append(a);
                if ((a=actions[i]) != null)
                    list.append(a);
            }
            if ((a=labels[length]) != null)
                list.append(a);
        }
        return list;
    }

    private static class SkipEntry
    {
        WaitForFrame action;
        int skipTarget;

        public SkipEntry(WaitForFrame action, int skipTarget)
        {
            this.action = action;
            this.skipTarget = skipTarget;
        }
    }

    /**
     * postprocess skip records now that we now the offset of each encoded action
     */
    private void processSkipEntries()
    {
        for (Iterator<SkipEntry> i = skipRecords.iterator(); i.hasNext();)
        {
            SkipEntry skipRecord = i.next();
            int labelOffset = actionOffsets[skipRecord.skipTarget-startCount];
            skipRecord.action.skipTarget = getLabel(labelOffset);
        }
    }

    public void addSkipEntry(WaitForFrame a, int skipTarget)
    {
        skipRecords.add(new SkipEntry(a, skipTarget));
    }

}
