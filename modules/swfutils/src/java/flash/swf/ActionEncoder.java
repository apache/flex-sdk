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

import flash.swf.actions.Branch;
import flash.swf.actions.ConstantPool;
import flash.swf.actions.DefineFunction;
import flash.swf.actions.GetURL;
import flash.swf.actions.GetURL2;
import flash.swf.actions.GotoFrame;
import flash.swf.actions.GotoFrame2;
import flash.swf.actions.GotoLabel;
import flash.swf.actions.Label;
import flash.swf.actions.Push;
import flash.swf.actions.SetTarget;
import flash.swf.actions.StoreRegister;
import flash.swf.actions.StrictMode;
import flash.swf.actions.Try;
import flash.swf.actions.Unknown;
import flash.swf.actions.WaitForFrame;
import flash.swf.actions.With;
import flash.swf.debug.LineRecord;
import flash.swf.debug.RegisterRecord;
import flash.swf.types.ActionList;
import flash.swf.types.ClipActionRecord;
import flash.swf.types.ClipActions;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

/**
 * AS2 encoder.
 */
public class ActionEncoder extends ActionHandler
{
    private SwfEncoder writer;
    private DebugEncoder debug;

    // map label -> position
    private HashMap<Label, LabelEntry> labels;

    private ArrayList<UpdateEntry> updates;
    private int actionCount;

    public ActionEncoder(SwfEncoder writer, DebugEncoder debug)
    {
        this.writer = writer;
        this.debug = debug;
        labels = new HashMap<Label, LabelEntry>();
        updates = new ArrayList<UpdateEntry>();
    }

	private static class UpdateEntry
	{
		int anchor;     // location to subtract to compute delta
		int updatePos;  // byte offset to update with delta value
        Action source;

		public UpdateEntry(int anchor, int updatePos, Action source)
		{
			this.anchor = anchor;
			this.updatePos = updatePos;
            this.source = source;
		}
	}

    private static class LabelEntry
    {
        int offset; // byte offset in swf file
        int count;  // action ordinal number (Nth action in current block)

        public LabelEntry(int offset, int count)
        {
            this.count = count;
            this.offset = offset;
        }
    }

    private int getLabelOffset(Label label)
    {
        assert (labels.containsKey(label)) : ("missing label");
        return labels.get(label).offset;
    }

    private int getLabelCount(Label label)
    {
        assert (labels.containsKey(label)) : ("missing label");
        return labels.get(label).count;
    }

	public void encode(ActionList actionList)
	{
        // write the actions
		for (int i=0; i < actionList.size(); i++)
		{
			Action a = actionList.getAction(i);

			switch (a.code)
			{
            // don't update actionCount for synthetic opcodes
            case ActionList.sactionLabel:
                a.visit(this);
                break;
			case ActionList.sactionLineRecord:
				if (debug != null)
					debug.offset(writer.getPos(), (LineRecord)a);
				break;

			case ActionList.sactionRegisterRecord:
				if (debug != null)
					debug.registers(writer.getPos(), (RegisterRecord)a);
				break;

            // the remaining types need counting
			case ActionConstants.sactionPush:
				i = encodePush((Push)a, i, actionList);
                actionCount++;
				break;
			default:
				if (a.code < 0x80)
					writer.writeUI8(a.code);
				else
					a.visit(this);
                actionCount++;
				break;
			}
		}

        patchForwardBranches();
    }

    private void patchForwardBranches()
    {
        // now patch forward branches
        for (Iterator<UpdateEntry> i = updates.iterator(); i.hasNext();)
        {
            UpdateEntry entry = i.next();
            switch (entry.source.code)
            {
            case ActionConstants.sactionIf:
            case ActionConstants.sactionJump:
                int target = getLabelOffset(((Branch)entry.source).target);
                writer.writeSI16at(entry.updatePos, target - entry.anchor);
                break;
            case ActionConstants.sactionWith:
                int endWith = getLabelOffset(((With)entry.source).endWith);
                writer.writeUI16at(entry.updatePos, endWith - entry.anchor);
                break;
            case ActionConstants.sactionWaitForFrame:
            case ActionConstants.sactionWaitForFrame2:
                int skipTarget = getLabelCount(((WaitForFrame)entry.source).skipTarget);
                writer.writeUI8at(entry.updatePos, skipTarget - entry.anchor);
                break;
            case ActionConstants.sactionTry:
                Try t = (Try) entry.source;
                int endTry = getLabelOffset(t.endTry);
                writer.writeUI16at(entry.updatePos, endTry - entry.anchor);
                entry.anchor = endTry;
                if (t.hasCatch())
                {
                    int endCatch = getLabelOffset(t.endCatch);
                    writer.writeUI16at(entry.updatePos+2, endCatch - entry.anchor);
                    entry.anchor = endCatch;
                }
                if (t.hasFinally())
                {
                    int endFinally = getLabelOffset(t.endFinally);
                    writer.writeUI16at(entry.updatePos+4, endFinally - entry.anchor);
                }
                break;
            default:
                assert false : ("invalid action in UpdateEntry");
            }
        }
    }

//    public void inlineBinaryOp(InlineBinaryOp op)
//    {
//        writer.writeU8(op.code);
//        writer.writeU8(op.dst);
//        encodeOperand(op.lhs, op.rhs);
//    }

//    private void encodeOperand(Object lhs, Object rhs)
//    {
//        int lhsType = operandType(lhs);
//        int rhsType = operandType(rhs);
//        writer.writeU8(lhsType >> 4 | rhsType);
//        encodeOperand(lhsType, lhs);
//        encodeOperand(rhsType, rhs);
//    }
//
//    private void encodeOperand(Object operand)
//    {
//        int type = operandType(operand);
//        writer.writeU8(type);
//        encodeOperand(type, operand);
//    }
//
//    public void inlineBranchWhenFalse(InlineBranchWhenFalse op)
//    {
//        writer.writeU8(op.code);
//        int pos = writer.getPos();
//        writer.writeU8(op.cond);
//        encodeOperand(op.lhs, op.rhs);
//        Integer offset = (Integer) labels.get(op.target);
//        if (offset != null)
//        {
//            // label came earlier
//            writer.writeU16(offset.intValue() - pos - 2);
//        }
//        else
//        {
//            // label comes later. don't know the offset yet.
//			updates.add(new UpdateEntry(pos+2, pos, op));
//            writer.writeU16(0);
//        }
//    }

//    public void inlineGetMember(InlineGetMember op)
//    {
//        writer.writeU8(op.code);
//        writer.writeU8(op.dst);
//        writer.writeU8(op.src);
//        encodeOperand(op.member);
//    }
//
//    public void inlineSetMember(InlineSetMember op)
//    {
//        writer.writeU8(op.code);
//        writer.writeU8(op.dst);
//        encodeOperand(op.member, op.src);
//    }

//    public void inlineSetRegister(InlineSetRegister op)
//    {
//        writer.writeU8(op.code);
//        writer.writeU8(op.dst);
//        encodeOperand(op.value);
//    }
//
//    public void inlineUnaryRegOp(InlineUnaryRegOp op)
//    {
//        writer.writeU8(op.code);
//        writer.writeU8(op.register);
//    }

//    private void encodeOperand(int opType, Object operand)
//    {
//        switch (opType)
//        {
//        case ActionConstants.kInlineTrue:
//        case ActionConstants.kInlineFalse:
//        case ActionConstants.kInlineNull:
//        case ActionConstants.kInlineUndefined:
//            // do nothing, type implies value
//            break;
//        case ActionConstants.kInlineConstantByte:
//        case ActionConstants.kInlineChar:
//        case ActionConstants.kInlineRegister:
//            int i = ((Number)operand).intValue();
//            writer.writeU8(i);
//            break;
//        case ActionConstants.kInlineConstantWord:
//        case ActionConstants.kInlineShort:
//            i = ((Number)operand).intValue();
//            writer.writeU16(i);
//            break;
//        case ActionConstants.kInlineLong:
//            i = ((Number)operand).intValue();
//            writer.write32(i);
//            break;
//        case ActionConstants.kInlineDouble:
//            long num = Double.doubleToLongBits(((Number)operand).doubleValue());
//            writer.write32((int)(num>>32));
//            writer.write32((int)num);
//            break;
//        }
//    }

//    private int operandType(Object operand)
//    {
//        if (operand == Boolean.TRUE)
//            return ActionConstants.kInlineTrue;
//        else if (operand == Boolean.FALSE)
//            return ActionConstants.kInlineFalse;
//        else if (operand == ActionFactory.UNDEFINED)
//            return ActionConstants.kInlineUndefined;
//        else if (operand == ActionFactory.STACKTOP)
//            return ActionConstants.kInlineStack;
//        else if (operand == null)
//            return ActionConstants.kInlineNull;
//        else if (operand instanceof Short)
//            return ((Short)operand).intValue() < 256 ? ActionConstants.kInlineConstantByte : ActionConstants.kInlineConstantWord;
//        else if (operand instanceof Double)
//            return ActionConstants.kInlineDouble;
//        else if (operand instanceof Integer)
//            return (((Integer)operand).intValue() & ~0xFF) == 0 ? ActionConstants.kInlineChar :
//                   (((Integer)operand).intValue() & ~0xFFFF) == 0 ? ActionConstants.kInlineShort :
//                    ActionConstants.kInlineLong;
//        else if (operand instanceof Byte)
//            return ActionConstants.kInlineRegister;
//        else
//            throw new IllegalArgumentException("unknown operand type " + operand.getClass().getName());
//    }

    public void call(Action action)
    {
        writer.writeUI8(action.code);
        // this action's opcode 0x9E has hi bit set, but it never has data.  considered a permanent minor bug.
        writer.writeUI16(0);
    }

    public void constantPool(ConstantPool action)
    {
        int updatePos = encodeActionHeader(action);
        writer.writeUI16(action.pool.length);
        for (int i = 0; i < action.pool.length; i++)
        {
            writer.writeString(action.pool[i]);
        }
        updateActionHeader(updatePos);
    }

    private void updateActionHeader(int updatePos)
    {
        int length = (writer.getPos()-updatePos)-2;
        if (length >= 0x10000)
		{
			assert false : ("action length ("+length+") exceeds 64K");
		}
        writer.writeUI16at(updatePos, length);
    }

    private int encodeActionHeader(Action action)
    {
        writer.writeUI8(action.code);
        int updatePos = writer.getPos();
        writer.writeUI16(0);
        return updatePos;
    }

    public void defineFunction(DefineFunction action)
    {
        int updatePos = encodeActionHeader(action);
        writer.writeString(action.name);
        writer.writeUI16(action.params.length);
        for (int i = 0; i < action.params.length; i++)
        {
            writer.writeString(action.params[i]);
        }
        int pos = writer.getPos();
        writer.writeUI16(0); // codesize placeholder
        updateActionHeader(updatePos);

        new ActionEncoder(writer, debug).encode(action.actionList);

        writer.writeUI16at(pos, (writer.getPos()-pos)-2);
    }

    public void defineFunction2(DefineFunction action)
    {
        int updatePos = encodeActionHeader(action);
        writer.writeString(action.name);
        writer.writeUI16(action.params.length);
        writer.writeUI8(action.regCount);
        writer.writeUI16(action.flags);

        for (int i = 0; i < action.params.length; i++)
        {
            writer.writeUI8(action.paramReg[i]);
            writer.writeString(action.params[i]);
        }

        int pos = writer.getPos();
        writer.writeUI16(0); // placeholder
        updateActionHeader(updatePos);

		new ActionEncoder(writer, debug).encode(action.actionList);

        writer.writeUI16at(pos, (writer.getPos()-pos)-2);
    }

    public void getURL(GetURL action)
    {
        int updatePos = encodeActionHeader(action);
        writer.writeString(action.url);
        writer.writeString(action.target);
        updateActionHeader(updatePos);
    }

    public void getURL2(GetURL2 action)
    {
        int updatePos = encodeActionHeader(action);
        writer.writeUI8(action.method);
        updateActionHeader(updatePos);
    }

    public void gotoFrame(GotoFrame action)
    {
        int updatePos = encodeActionHeader(action);
        writer.writeUI16(action.frame);
        updateActionHeader(updatePos);
    }

    public void gotoFrame2(GotoFrame2 action)
    {
        int updatePos = encodeActionHeader(action);
        writer.writeUI8(action.playFlag);
        updateActionHeader(updatePos);
    }

    public void gotoLabel(GotoLabel action)
    {
        int updatePos = encodeActionHeader(action);
        writer.writeString(action.label);
        updateActionHeader(updatePos);
    }

    public void ifAction(Branch action)
    {
        encodeBranch(action);
    }

    public void jump(Branch action)
    {
        encodeBranch(action);
    }

    private void encodeBranch(Branch branch)
    {
        writer.writeUI8(branch.code);
        writer.writeUI16(2);
        int pos = writer.getPos();
        if (labels.containsKey(branch.target))
        {
            // label came earlier
            writer.writeSI16(getLabelOffset(branch.target) - pos - 2);
        }
        else
        {
            // label comes later. don't know the offset yet.
			updates.add(new UpdateEntry(pos+2, pos, branch));
            writer.writeSI16(0);
        }
    }

	public void with(With action)
	{
		writer.writeUI8(action.code);
		writer.writeUI16(2);
		// label comes later, don't know offset yet
		int pos = writer.getPos();
		updates.add(new UpdateEntry(pos+2, pos, action));
		writer.writeUI16(0);
	}

    public void waitForFrame(WaitForFrame action)
    {
        writer.writeUI8(action.code);
        writer.writeUI16(3);
        writer.writeUI16(action.frame);
        int pos = writer.getPos();
        updates.add(new UpdateEntry(actionCount+1, pos, action));
        writer.writeUI8(0);
    }

    public void waitForFrame2(WaitForFrame action)
    {
        writer.writeUI8(action.code);
        writer.writeUI16(1);
        int pos = writer.getPos();
        updates.add(new UpdateEntry(actionCount+1, pos, action));
        writer.writeUI8(0);
    }

    public void label(Label label)
    {
        assert (!labels.containsKey(label)) : ("found duplicate label");
		int labelPos = writer.getPos();
        labels.put(label, new LabelEntry(labelPos, actionCount));
    }

	/**
	 * encode a run of push actions into one action record.  The player
	 * supports this compact encoding since push is such a common
	 * opcode.  the format is:
	 *
	 *   sactionPush type1 value1 type2 value2 ...
	 *
	 * @param push
	 * @param j the index of the starting push action
	 * @param actions
	 * @return the index of the last push action encoded.  the next action will
	 * not be a push action.
	 */
    public int encodePush(Push push, int j, ActionList actions)
    {
        int updatePos = encodeActionHeader(push);
        do
		{
            Object value = push.value;
			int type = Push.getTypeCode(value);
			writer.writeUI8(type);

            switch (type)
			{
			case 0: // string
				writer.writeString(value.toString());
				break;
			case 1: // float
				int bits = Float.floatToIntBits(((Float) value).floatValue());
				writer.write32(bits);
				break;
			case 2: // null
				break;
			case 3: // undefined
				break;
			case 4: // register
				writer.writeUI8(((Byte) value).intValue() & 0xFF);
				break;
			case 5: // boolean
				writer.writeUI8(((Boolean) value).booleanValue() ? 1 : 0);
				break;
			case 6: // double
				double d = ((Double) value).doubleValue();
				long num = Double.doubleToLongBits(d);
				writer.write32((int)(num>>32));
                writer.write32((int)num);
				break;
			case 7: // integer
				writer.write32(((Integer) value).intValue());
				break;
			case 8: // const8
				writer.writeUI8(((Short) value).intValue());
				break;
			case 9: // const16
				writer.writeUI16(((Short) value).intValue() & 0xFFFF);
				break;
			}

            if (debug == null)
            {
                // ignore line records if we aren't debugging
                while (j+1 < actions.size() && actions.getAction(j+1).code == ActionList.sactionLineRecord)
                    j++;
            }

			Action a;
			if (++j < actions.size()
					&& (a=actions.getAction(j)).code == ActionConstants.sactionPush)
            {
				push = (Push) a;
            }
            else
            {
				push = null;
            }
		}
        while (push != null);
        updateActionHeader(updatePos);
		return j-1;
    }

    public void setTarget(SetTarget action)
    {
        int updatePos = encodeActionHeader(action);
        writer.writeString(action.targetName);
        updateActionHeader(updatePos);
    }

    public void storeRegister(StoreRegister action)
    {
        int updatePos = encodeActionHeader(action);
        writer.writeUI8(action.register);
        updateActionHeader(updatePos);
    }

    public void strictMode(StrictMode action)
    {
        int updatePos = encodeActionHeader(action);
        writer.writeUI8(action.mode ? 1 : 0);
        updateActionHeader(updatePos);
    }

    public void tryAction(Try a)
    {
        int updatePos = encodeActionHeader(a);

        writer.writeUI8(a.flags);
        int trySizePos = writer.getPos();
        writer.writeUI16(0);  // try size
        writer.writeUI16(0);  // catch size
        writer.writeUI16(0);  // finally size

		if (a.hasRegister())
			writer.writeUI8(a.catchReg);
		else
	        writer.writeString(a.catchName);

		// we have emitted the try action, what follows is label mgmt
		updateActionHeader(updatePos);

        int tryStart = writer.getPos();
        updates.add(new UpdateEntry(tryStart, trySizePos, a));
    }

    public void unknown(Unknown action)
    {
        int updatePos = encodeActionHeader(action);
        writer.write(action.data);
        updateActionHeader(updatePos);
    }

    public void encodeClipActions(ClipActions clipActions)
    {
        writer.writeUI16(0);

        encodeClipEventFlags(clipActions.allEventFlags, writer);

        Iterator it = clipActions.clipActionRecords.iterator();
        while (it.hasNext())
        {
            ClipActionRecord r = (ClipActionRecord) it.next();
            encodeClipActionRecord(r);
        }

        if (writer.swfVersion >= 6)
            writer.write32(0);
        else
            writer.writeUI16(0);
    }


    private void encodeClipActionRecord(ClipActionRecord r)
    {
        encodeClipEventFlags(r.eventFlags, writer);

        int pos = writer.getPos();
        writer.write32(0);  // offset placeholder

        if ((r.eventFlags & ClipActionRecord.keyPress) != 0)
        {
            writer.writeUI8(r.keyCode);
        }

		encode(r.actionList);

        writer.write32at(pos, (writer.getPos()-pos)-4);
    }

    private void encodeClipEventFlags(int flags, SwfEncoder w)
    {
        if (w.swfVersion >= 6)
            w.write32(flags);
        else
            w.writeUI16(flags);
    }

}
