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
import flash.swf.actions.Push;
import flash.swf.actions.SetTarget;
import flash.swf.actions.StoreRegister;
import flash.swf.actions.StrictMode;
import flash.swf.actions.Try;
import flash.swf.actions.Unknown;
import flash.swf.actions.WaitForFrame;
import flash.swf.actions.With;
import flash.swf.debug.DebugTable;
import flash.swf.debug.LineRecord;
import flash.swf.debug.RegisterRecord;
import flash.swf.types.ActionList;
import flash.swf.types.ClipActionRecord;
import flash.swf.types.ClipActions;

import java.io.IOException;
import java.util.ArrayList;

/**
 * AS2 decoder.
 */
public class ActionDecoder
        implements ActionConstants
{
    private SwfDecoder reader;
    private DebugTable debug;
    private boolean keepOffsets;
    private int actionCount;

    public ActionDecoder(SwfDecoder reader)
    {
        this(reader, null);
    }

    public ActionDecoder(SwfDecoder reader, DebugTable debug)
    {
        this.reader = reader;
        this.debug = debug;
    }

    public void setKeepOffsets(boolean b)
    {
        keepOffsets = b;
    }

	/**
     * consume actions until length bytes are used up. 
     * @param length
     * @throws IOException
     */
    public ActionList decode(int length) throws IOException { return decode(length, true); }

	/**
     * consume actions until length bytes are used up
     * @param length
	 * @param throwExceptions - if false exceptions will NOT be thrown. This is 
	 * used for decoding a series of opcodes which may not be complete on their own.
     * @throws IOException
     */
    public ActionList decode(int length, boolean throwExceptions) throws IOException
    {
        int startOffset = reader.getOffset();
		int end = startOffset+length;
        boolean ending = false;

        ActionFactory factory = new ActionFactory(length, startOffset, actionCount);
		try
		{
			for (int offset = startOffset; offset < end; offset = reader.getOffset())
			{
				int opcode = reader.readUI8();

				if (opcode > 0)
				{
					if (ending)
						throw new SwfFormatException("unexpected bytes after sactionEnd: " + opcode);
                    factory.setActionOffset(actionCount, offset);
					decodeAction(opcode, offset, factory);
                    actionCount++;
				}
				else if (opcode == 0)
				{
					ending = true;
				}
				else
				{
					break;
				}
			}
            // keep track of the end too
            factory.setActionOffset(actionCount, reader.getOffset());
		}
		catch(ArrayIndexOutOfBoundsException aio) 
		{
			if (throwExceptions)
				throw aio;
		}
		catch(SwfFormatException swf) 
		{
			if (throwExceptions)
				throw swf;
		}

        return factory.createActionList(keepOffsets);
    }

    public ClipActions decodeClipActions(int length) throws IOException
    {
        ClipActions a = new ClipActions();
        reader.readUI16(); // must be 0
        a.allEventFlags = decodeClipEventFlags(reader);

        ArrayList<ClipActionRecord> list = new ArrayList<ClipActionRecord>();

        ClipActionRecord record = decodeClipActionRecord();
        while (record != null)
        {
            list.add(record);
            record = decodeClipActionRecord();
        }

        a.clipActionRecords = list;

        return a;
    }

    private ClipActionRecord decodeClipActionRecord() throws IOException
    {
        int flags = decodeClipEventFlags(reader);
        if (flags != 0)
        {
            ClipActionRecord c = new ClipActionRecord();

            c.eventFlags = flags;

            // this tells us how big the action block is
            int size = (int)reader.readUI32();

            if ((flags & ClipActionRecord.keyPress) != 0)
            {
                size--;
                c.keyCode = reader.readUI8();
            }

            c.actionList = decode(size);

            return c;
        }
        else
        {
            return null;
        }
    }

    private int decodeClipEventFlags(SwfDecoder r) throws IOException
    {
        int flags;
        if (r.swfVersion >= 6)
            flags = (int)r.readUI32();
        else
            flags = r.readUI16();
        return flags;
    }

    private void decodeAction(int opcode, int offset, ActionFactory factory) throws IOException
    {
        LineRecord line = debug != null ? debug.getLine(offset) : null;
		if (line != null)
		{
            factory.setLine(offset, line);
		}

 		// interleave register records in the action list
		RegisterRecord record = (debug != null) ? debug.getRegisters(offset) : null;
		if (record != null)
		{
 			factory.setRegister(offset, record);
 		}

        Action a;
        if (opcode < 0x80)
        {
			a = ActionFactory.createAction(opcode);
            factory.setAction(offset, a);
			return;
        }

        int len = reader.readUI16();
        int pos = offset+3;

        switch (opcode)
        {
        case sactionDefineFunction:
            a = decodeDefineFunction(pos, len);
            factory.setAction(offset, a);
			return;

        case sactionDefineFunction2:
            a = decodeDefineFunction2(pos, len);
            factory.setAction(offset, a);
			return;

        case sactionWith:
            a = decodeWith(factory);
			break;

		case sactionTry:
			a = decodeTry(factory);
			break;

		case sactionPush:
			Push p = decodePush(offset, pos+len, factory);
			checkConsumed(pos, len, p);
			return;

        case sactionStrictMode:
            a = decodeStrictMode();
            break;

        case sactionCall:
            // this actions opcode has the high bit set, but there is no length.  considered a permanent bug.
            a = ActionFactory.createCall();
            break;

        case sactionGotoFrame:
            a = decodeGotoFrame();
            break;

        case sactionGetURL:
            a = decodeGetURL();
            break;

        case sactionStoreRegister:
            a = decodeStoreRegister();
            break;

        case sactionConstantPool:
            a = decodeConstantPool();
            break;

        case sactionWaitForFrame:
            a = decodeWaitForFrame(opcode, factory);
            break;

        case sactionSetTarget:
            a = decodeSetTarget();
            break;

        case sactionGotoLabel:
            a = decodeGotoLabel();
            break;

        case sactionWaitForFrame2:
            a = decodeWaitForFrame(opcode, factory);
            break;

        case sactionGetURL2:
            a = decodeGetURL2();
            break;

        case sactionJump:
        case sactionIf:
            a = decodeBranch(opcode, factory);
            break;

        case sactionGotoFrame2:
            a = decodeGotoFrame2();
            break;

        default:
            a = decodeUnknown(opcode, len);
            break;
        }
        checkConsumed(pos, len, a);
        factory.setAction(offset, a);
	}

    private Try decodeTry(ActionFactory factory) throws IOException
    {
        Try a = new Try();

        a.flags = reader.readUI8();
        int trySize = reader.readUI16();
        int catchSize = reader.readUI16();
        int finallySize = reader.readUI16();

		if (a.hasRegister())
			a.catchReg = reader.readUI8();
		else
	       	a.catchName = reader.readString();

		// we have now consumed the try action.  what follows is label mgmt

        int tryEnd = reader.getOffset() + trySize;
		a.endTry = factory.getLabel(tryEnd);

        // place the catchLabel to mark the end point of the catch handler
		if (a.hasCatch())
            a.endCatch = factory.getLabel(tryEnd + catchSize);

        // place the finallyLabel to mark the end point of the finally handler
		if (a.hasFinally())
            a.endFinally = factory.getLabel(tryEnd + finallySize + (a.hasCatch() ? catchSize : 0));

        return a;
    }

    private GotoFrame2 decodeGotoFrame2() throws IOException
    {
        GotoFrame2 a = new GotoFrame2();
        a.playFlag = reader.readUI8();
        return a;
    }

    private Branch decodeBranch(int code, ActionFactory factory) throws IOException
    {
        Branch a = new Branch(code);
        int offset = reader.readSI16();
        int target = offset + reader.getOffset();
        a.target = factory.getLabel(target);
        return a;
    }

    private WaitForFrame decodeWaitForFrame(int opcode, ActionFactory factory) throws IOException
    {
        WaitForFrame a = new WaitForFrame(opcode);
        if (opcode == sactionWaitForFrame)
            a.frame = reader.readUI16();
        int skipCount = reader.readUI8();
        int skipTarget = actionCount+1 + skipCount;
        factory.addSkipEntry(a, skipTarget);
        return a;
    }

	private GetURL2 decodeGetURL2() throws IOException
    {
        GetURL2 a = new GetURL2();
        a.method = reader.readUI8();
        return a;
    }

    private GotoLabel decodeGotoLabel() throws IOException
    {
        GotoLabel a = new GotoLabel();
        a.label = reader.readString();
        return a;
    }

    private SetTarget decodeSetTarget() throws IOException
    {
        SetTarget a = new SetTarget();
        a.targetName = reader.readString();
        return a;
    }

    private ConstantPool decodeConstantPool() throws IOException
    {
        ConstantPool cpool = new ConstantPool();
        int count = reader.readUI16();
        cpool.pool = new String[count];
        for (int i = 0; i < count; i++)
        {
            cpool.pool[i] = reader.readString();
        }
        return cpool;
    }

    private StoreRegister decodeStoreRegister() throws IOException
    {
        int register = reader.readUI8();
		return ActionFactory.createStoreRegister(register);
    }

    private GetURL decodeGetURL() throws IOException
    {
        GetURL a = new GetURL();
        a.url = reader.readString();
        a.target = reader.readString();
        return a;
    }

    private GotoFrame decodeGotoFrame() throws IOException
    {
        GotoFrame a = new GotoFrame();
        a.frame = reader.readUI16();
        return a;
    }

    private Unknown decodeUnknown(int opcode, int length) throws IOException
    {
        Unknown a = new Unknown(opcode);
        a.data = new byte[length];
        reader.readFully(a.data);
        return a;
    }

    private StrictMode decodeStrictMode() throws IOException
    {
        boolean mode = reader.readUI8() != 0;
        return ActionFactory.createStrictMode(mode);
    }

    private Push decodePush(int offset, int end, ActionFactory factory) throws IOException
    {
        Push p;
        do
        {
            int pushType = reader.readUI8();
            switch (pushType)
            {
            case Push.kPushStringType: // string
                p = ActionFactory.createPush(reader.readString());
                break;
            case Push.kPushFloatType: // float
                float fvalue = Float.intBitsToFloat((int) reader.readUI32());
                p = ActionFactory.createPush(fvalue); // value
                break;
            case Push.kPushNullType: // null
                p = ActionFactory.createPushNull();
                break;
            case Push.kPushUndefinedType: // undefined
                p = ActionFactory.createPushUndefined();
                break;
            case Push.kPushRegisterType: // register
                p = ActionFactory.createPushRegister(reader.readUI8());
                break;
            case Push.kPushBooleanType: // boolean
                p = ActionFactory.createPush(reader.readUI8() != 0);
                break;
            case Push.kPushDoubleType: // double
				// read two 32 bit little-endian values in big-endian order.  weird.
                long hx = reader.readUI32();
                long lx = reader.readUI32();
                p = ActionFactory.createPush(Double.longBitsToDouble((hx << 32) | (lx & 0xFFFFFFFFL)));
                break;
            case Push.kPushIntegerType: // integer
                p = ActionFactory.createPush((int)reader.readUI32());
                break;
            case Push.kPushConstant8Type: // 8-bit cpool reference
                p = ActionFactory.createPushCpool(reader.readUI8());
                break;
            case Push.kPushConstant16Type: // 16-bit cpool reference
                p = ActionFactory.createPushCpool(reader.readUI16());
                break;
            default:
                throw new SwfFormatException("Unknown push data type "+pushType);
            }
			factory.setAction(offset, p);
            offset = reader.getOffset();
        }
        while (offset < end);
        return p;
    }

    private DefineFunction decodeDefineFunction(int pos, int len) throws IOException
    {
        DefineFunction a = new DefineFunction(ActionConstants.sactionDefineFunction);
        a.name = reader.readString();
        int number = reader.readUI16();
        a.params = new String[number];

        for (int i = 0; i < number; i++)
        {
            a.params[i] = reader.readString();
        }

        a.codeSize = reader.readUI16();

        checkConsumed(pos, len, a);

        a.actionList = decode(a.codeSize);

        return a;
    }

    private DefineFunction decodeDefineFunction2(int pos, int len) throws IOException
    {
        DefineFunction a = new DefineFunction(ActionConstants.sactionDefineFunction2);
        a.name = reader.readString();
        int number = reader.readUI16();
        a.params = new String[number];
        a.paramReg = new int[number];

        a.regCount = reader.readUI8();
        a.flags = reader.readUI16();

        for (int i = 0; i < number; i++)
        {
            a.paramReg[i] = reader.readUI8();
            a.params[i] = reader.readString();
        }

        a.codeSize = reader.readUI16();

        checkConsumed(pos, len, a);

        a.actionList = decode(a.codeSize);

        return a;
    }

    private void checkConsumed(int pos, int len, Action a) throws IOException
    {
        int consumed = reader.getOffset() - pos;
        if (consumed != len)
        {
            throw new SwfFormatException(a.getClass().getName() + ": " + consumed + " was read. " + len + " was required.");
        }
    }

    private With decodeWith(ActionFactory factory) throws IOException
    {
        With a = new With();
        int size = reader.readUI16();
		int target = size + reader.getOffset();
        a.endWith = factory.getLabel(target);
        return a;
    }
}
