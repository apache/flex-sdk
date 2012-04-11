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

package flash.swf.tools;

import flash.swf.Action;
import flash.swf.ActionHandler;
import flash.swf.ActionConstants;
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
import flash.swf.debug.DebugModule;
import flash.swf.debug.LineRecord;
import flash.swf.debug.RegisterRecord;
import flash.swf.types.ActionList;
import flash.util.FieldFormat;

import java.io.PrintWriter;
import java.util.HashMap;

/**
 * This utility supports printing AS2 byte codes.
 *
 * @author Edwin Smith
 */
public class Disassembler extends ActionHandler
{
    protected ConstantPool cpool;
    protected int start;
    protected int offset;
    protected final PrintWriter out;
    private boolean showOffset = false;
    private boolean showDebugSource = false;
    private boolean showLineRecord = true;
	private RegisterRecord registerRecord = null;
    private int indent;
    private int initialIndent;
	private String comment;
	private String format;

	public Disassembler(PrintWriter out, ConstantPool cpool, String comment)
	{
		this(out, false, 0);
		this.cpool = cpool;
		this.comment = comment;
	}

    public Disassembler(PrintWriter out, boolean showOffset, int indent)
    {
        this.out = out;
        this.showOffset = showOffset;
        this.indent = indent;
        this.initialIndent = indent;
		this.comment = "";
    }

    public void setComment(String comment)
    {
        this.comment = comment;
    }

    public void setFormat(String format)
    {
        this.format = format;
    }

    public void setShowDebugSource(boolean b)
    {
        this.showDebugSource = b;
    }

    public void setShowLineRecord(boolean b)
    {
        this.showLineRecord = b;
    }

    public static void disassemble(ActionList list, ConstantPool pool, int startIndex, int endIndex, PrintWriter out)
    {
		Disassembler d = new Disassembler(out, pool, "    ");
		d.setFormat("    0x%08O  %a"); 
		d.setShowLineRecord(false);

		// probe backward for a register record if any to set up register to variable name mapping
		int at = list.lastIndexOf(ActionList.sactionRegisterRecord, startIndex);
		if (at > -1)
			d.registerRecord = (RegisterRecord)list.getAction(at);

		// now dump the contents of our request
		list.visit(d, startIndex, endIndex);
        out.flush();
    }

    protected void print(Action action)
    {
        start(action);
        out.println();
    }

    public void setActionOffset(int offset, Action a)
    {
        if (this.offset == 0)
        {
            this.start = offset;
        }
        this.offset = offset;
    }

    protected void indent()
    {
        for (int i=0; i < initialIndent; i++)
            out.print("  ");
        out.print(comment);
        for (int i=initialIndent; i < indent; i++)
            out.print("  ");
    }

	public void registerRecord(RegisterRecord record)
	{
		// set the active record
		registerRecord = record;
	}

	protected String variableNameForRegister(int regNbr)
	{
		int at = (registerRecord == null) ? -1 : registerRecord.indexOf(regNbr);
		if (at > -1)
			return registerRecord.variableNames[at];
		else
			return null;
	}

	public void lineRecord(LineRecord line)
	{
		if (!showLineRecord)
			;
        else if (showDebugSource)
        {
            printLines(line, out);
        }
        else
        {
            start(line);
            out.println(" "+line.module.name +":"+line.lineno);
        }
	}

    public void printLines(LineRecord lr, PrintWriter out)
    {
        DebugModule script = lr.module;

        if (script != null)
        {
            int lineno = lr.lineno;
            if (lineno > 0)
            {
                while (lineno-1 > 0 && script.offsets[lineno-1] == 0)
                {
                    lineno--;
                }
                if (lineno == 1)
                {
                    indent();
                    out.println(script.name);
                }
                int off = script.index[lineno-1];
                int len = script.index[lr.lineno] - off;
                out.write(script.text, off, len);
            }
        }
    }

    protected void start(Action action)
    {
        String actionName;
        if ((action.code < 0) || (action.code > actionNames.length))
        {
            actionName = "Unknown";
        }
        else
        {
            actionName = actionNames[action.code];
        }

        if (showOffset)
        {
            indent();
            out.print("absolute=" + offset + ",relative=" + (offset-start) +
                      ",code=" + action.code + "\t" + actionName);
        }
        else
        {
			if (format == null)
			{
				indent();
				out.print(actionName);
			}
			else 
			{
				startFormatted(actionName);
			}
        }
    }

	protected void startFormatted(String action)
	{
		StringBuilder sb = new StringBuilder();
		boolean leadingZeros = false;
		int width = -1;
		
		for(int i=0; i<format.length(); i++)
		{
			char c = format.charAt(i);
			if (c == '%')
			{
				c = format.charAt(++i);
				if (Character.isDigit(c))
				{
					// absorb a leading zero, if any
					if (c == '0')
					{
						leadingZeros = true;
						c = format.charAt(++i);
					}

					StringBuilder number = new StringBuilder();
					while(Character.isDigit(c))
					{
						number.append(c);
						c = format.charAt(++i);
					}
					try { width = Integer.parseInt(number.toString()); } catch(NumberFormatException nfe) { width = -1; }
				}

				if (c == 'O')
				{
					FieldFormat.formatLongToHex(sb, offset, width, leadingZeros);
				}
				else if (c == 'o')
				{
					FieldFormat.formatLong(sb, offset, width, leadingZeros);
				}
				else if (c == 'a')
				{
					sb.append(action);
				}
			}
			else
				sb.append(c);
		}
		out.print( sb.toString() );
	}

    public void nextFrame(Action action)
    {
        print(action);
    }

    public void prevFrame(Action action)
    {
        print(action);
    }

    public void play(Action action)
    {
        print(action);
    }

    public void stop(Action action)
    {
        print(action);
    }

    public void toggleQuality(Action action)
    {
        print(action);
    }

    public void stopSounds(Action action)
    {
        print(action);
    }

    public void add(Action action)
    {
        print(action);
    }

    public void subtract(Action action)
    {
        print(action);
    }

    public void multiply(Action action)
    {
        print(action);
    }

    public void divide(Action action)
    {
        print(action);
    }

    public void equals(Action action)
    {
        print(action);
    }

    public void less(Action action)
    {
        print(action);
    }

    public void and(Action action)
    {
        print(action);
    }

    public void or(Action action)
    {
        print(action);
    }

    public void not(Action action)
    {
        print(action);
    }

    public void stringEquals(Action action)
    {
        print(action);
    }

    public void stringLength(Action action)
    {
        print(action);
    }

    public void stringExtract(Action action)
    {
        print(action);
    }

    public void pop(Action action)
    {
        print(action);
    }

    public void toInteger(Action action)
    {
        print(action);
    }

    public void getVariable(Action action)
    {
        print(action);
    }

    public void setVariable(Action action)
    {
        print(action);
    }

    public void setTarget2(Action action)
    {
        print(action);
    }

    public void stringAdd(Action action)
    {
        print(action);
    }

    public void getProperty(Action action)
    {
        print(action);
    }

    public void setProperty(Action action)
    {
        print(action);
    }

    public void cloneSprite(Action action)
    {
        print(action);
    }

    public void removeSprite(Action action)
    {
        print(action);
    }

    public void trace(Action action)
    {
        print(action);
    }

    public void startDrag(Action action)
    {
        print(action);
    }

    public void endDrag(Action action)
    {
        print(action);
    }

    public void stringLess(Action action)
    {
        print(action);
    }

    public void randomNumber(Action action)
    {
        print(action);
    }

    public void mbStringLength(Action action)
    {
        print(action);
    }

    public void charToASCII(Action action)
    {
        print(action);
    }

    public void asciiToChar(Action action)
    {
        print(action);
    }

    public void getTime(Action action)
    {
        print(action);
    }

    public void mbStringExtract(Action action)
    {
        print(action);
    }

    public void mbCharToASCII(Action action)
    {
        print(action);
    }

    public void mbASCIIToChar(Action action)
    {
        print(action);
    }

    public void delete(Action action)
    {
        print(action);
    }

    public void delete2(Action action)
    {
        print(action);
    }

    public void defineLocal(Action action)
    {
        print(action);
    }

    public void callFunction(Action action)
    {
        print(action);
    }

    public void returnAction(Action action)
    {
        print(action);
    }

    public void modulo(Action action)
    {
        print(action);
    }

    public void newObject(Action action)
    {
        print(action);
    }

    public void defineLocal2(Action action)
    {
        print(action);
    }

    public void initArray(Action action)
    {
        print(action);
    }

    public void initObject(Action action)
    {
        print(action);
    }

    public void typeOf(Action action)
    {
        print(action);
    }

    public void targetPath(Action action)
    {
        print(action);
    }

    public void enumerate(Action action)
    {
        print(action);
    }

    public void add2(Action action)
    {
        print(action);
    }

    public void less2(Action action)
    {
        print(action);
    }

    public void equals2(Action action)
    {
        print(action);
    }

    public void toNumber(Action action)
    {
        print(action);
    }

    public void toString(Action action)
    {
        print(action);
    }

    public void pushDuplicate(Action action)
    {
        print(action);
    }

    public void stackSwap(Action action)
    {
        print(action);
    }

    public void getMember(Action action)
    {
        print(action);
    }

    public void setMember(Action action)
    {
        print(action);
    }

    public void increment(Action action)
    {
        print(action);
    }

    public void decrement(Action action)
    {
        print(action);
    }

    public void callMethod(Action action)
    {
        print(action);
    }

    public void newMethod(Action action)
    {
        print(action);
    }

    public void instanceOf(Action action)
    {
        print(action);
    } // only if object model enabled

    public void enumerate2(Action action)
    {
        print(action);
    }

    public void bitAnd(Action action)
    {
        print(action);
    }

    public void bitOr(Action action)
    {
        print(action);
    }

    public void bitXor(Action action)
    {
        print(action);
    }

    public void bitLShift(Action action)
    {
        print(action);
    }

    public void bitRShift(Action action)
    {
        print(action);
    }

    public void bitURShift(Action action)
    {
        print(action);
    }

    public void strictEquals(Action action)
    {
        print(action);
    }

    public void greater(Action action)
    {
        print(action);
    }

    public void stringGreater(Action action)
    {
        print(action);
    }

    public void gotoFrame(GotoFrame action)
    {
        start(action);
        out.println(" " + action.frame);
    }

    public void getURL(GetURL action)
    {
        start(action);
        out.println(" " + action.url + " " + action.target);
    }

    public void storeRegister(StoreRegister action)
    {
        start(action);
		String variableName = variableNameForRegister(action.register);
        out.println(" $" + action.register + ((variableName == null) ? "" : "   \t\t; "+variableName) );
    }

    public void constantPool(ConstantPool action)
    {
        cpool = action;
        start(action);
        out.println(" [" + action.pool.length +"]");
    }

    public void strictMode(StrictMode action)
    {
        print(action);
    }

    public void waitForFrame(WaitForFrame action)
    {
        start(action);
        out.println(" " + action.frame + " {");
        indent++;
        labels.getLabelEntry(action.skipTarget).source = action;
    }

    public void setTarget(SetTarget action)
    {
        start(action);
        out.println(" " + action.targetName);
    }

    public void gotoLabel(GotoLabel action)
    {
        start(action);
        out.println(" " + action.label);
    }

    public void waitForFrame2(WaitForFrame action)
    {
        start(action);
        out.println(" {");
        indent++;
        labels.getLabelEntry(action.skipTarget).source = action;
    }

    public void with(With action)
    {
        start(action);
        out.println(" {");
        indent++;
        labels.getLabelEntry(action.endWith).source = action;
    }

	public void tryAction(Try action)
	{
		start(action);
		out.println(" {");
		indent++;

        labels.getLabelEntry(action.endTry).source = action;
        if (action.hasCatch())
            labels.getLabelEntry(action.endCatch).source = action;
        if (action.hasFinally())
            labels.getLabelEntry(action.endFinally).source = action;
	}

	public void throwAction(Action action)
	{
		print(action);
	}

	public void castOp(Action action)
	{
		print(action);
	}

	public void implementsOp(Action action)
	{
		print(action);
	}

    public void extendsOp(Action action)
    {
        print(action);
    }

    public void nop(Action action)
    {
        print(action);
    }

    public void halt(Action action)
    {
        print(action);
    }

    public void push(Push action)
    {
        start(action);
        out.print(" ");
		Object value = action.value;
		int type = Push.getTypeCode(value);
		switch (type)
		{
		case Push.kPushStringType:
			out.print(quoteString(value.toString(),'"'));
			break;
		case Push.kPushNullType:
			out.print("null");
			break;
		case Push.kPushUndefinedType:
			out.print("undefined");
			break;
		case Push.kPushRegisterType:
			String variableName = variableNameForRegister( (((Byte)value).intValue()&0xFF) );
			out.print("$" + (((Byte)value).intValue()&0xFF) + ((variableName == null) ? "" : "   \t\t; "+variableName) );
			break;
		case Push.kPushConstant8Type:
		case Push.kPushConstant16Type:
			int index = ((Number) value).intValue()&0xFFFF;
			out.print( ((cpool == null) ? Integer.toString(index) : quoteString(cpool.pool[index],'\'')) );
			break;
		case Push.kPushFloatType:
			out.print(value + "F");
			break;
		case Push.kPushBooleanType:
		case Push.kPushDoubleType:
		case Push.kPushIntegerType:
			out.print(value);
			break;
		default:
			assert (false);
		}
        out.println();
    }

    public void getURL2(GetURL2 action)
    {
        start(action);
        out.println(" " + action.method);
    }

    public void defineFunction(DefineFunction action)
    {
        start(action);
        out.print(" " + action.name + "(");
        for (int i = 0; i < action.params.length; i++)
        {
            out.print(action.params[i]);
            if (i + 1 < action.params.length)
            {
                out.print(", ");
            }
        }
        out.println(") {");
        indent++;
        action.actionList.visitAll(this);
        indent--;
        indent();
        out.println("} " + action.name);
    }

    public void defineFunction2(DefineFunction action)
    {
        start(action);
        out.print(" " + action.name + "(");
        for (int i = 0; i < action.params.length; i++)
        {
            out.print("$"+action.paramReg[i]+"="+action.params[i]);
            if (i + 1 < action.params.length)
            {
                out.print(", ");
            }
        }
        out.print(")");
        int regno = 1;
        if ((action.flags & DefineFunction.kPreloadThis) != 0)
            out.print(" $"+(regno++)+"=this");
        if ((action.flags & DefineFunction.kPreloadArguments) != 0)
            out.print(" $"+(regno++)+"=arguments");
        if ((action.flags & DefineFunction.kPreloadSuper) != 0)
            out.print(" $"+(regno++)+"=super");
        if ((action.flags & DefineFunction.kPreloadRoot) != 0)
            out.print(" $"+(regno++)+"=_root");
        if ((action.flags & DefineFunction.kPreloadParent) != 0)
            out.print(" $"+(regno++)+"=_parent");
        if ((action.flags & DefineFunction.kPreloadGlobal) != 0)
            out.print(" $"+(regno)+"=_global");
        out.println(" {");
        indent++;
        action.actionList.visitAll(this);
        indent--;
        indent();
        out.println("} " + action.name);
    }

    private static class LabelEntry
    {
        String name;
        Action source;

        public LabelEntry(String name, Action source)
        {
            this.name = name;
            this.source = source;
        }
    }
	private static class LabelMap extends HashMap<Label, LabelEntry>
    {
		private static final long serialVersionUID = -7907644739362458461L;

        LabelEntry getLabelEntry(Label l)
        {
            LabelEntry entry = get(l);
            if (entry == null)
            {
                entry = new LabelEntry(null,null);
                put(l, entry);
            }
            return entry;
        }
    }
    private LabelMap labels = new LabelMap();
    int labelCount = 0;

    public void ifAction(Branch action)
    {
        printBranch(action);
    }

    public void jump(Branch action)
    {
        printBranch(action);
    }

    protected void printBranch(Branch action)
    {
        start(action);
        LabelEntry entry = labels.getLabelEntry(action.target);
        if (entry.name == null)
            entry.name = "L"+String.valueOf(labelCount++);
        entry.source = action;
        out.println(" " + entry.name);
    }

    public void label(Label label)
    {
        LabelEntry entry = labels.getLabelEntry(label);
        if (entry.source == null)
        {
            // have not seen any actions that target this label yet, and that
            // means the source can only be a backwards branch
            entry.name = "L"+String.valueOf(labelCount++);
            indent();
            out.println(entry.name + ":");
        }
        else
        {
            switch (entry.source.code)
            {
            case ActionConstants.sactionTry:
                Try t = (Try) entry.source;
                indent--;
                indent();
                out.println("}");
                indent();
                if (label == t.endTry && t.hasCatch())
                {
                    out.println("catch("+
                                (t.hasRegister()?"$"+t.catchReg:t.catchName) +
                                ") {");
                    indent++;
                }
                else if ((label == t.endTry || label == t.endCatch) && t.hasFinally())
                {
                    out.println("finally {");
                    indent++;
                }
                break;
            case ActionConstants.sactionWaitForFrame:
            case ActionConstants.sactionWaitForFrame2:
            case ActionConstants.sactionWith:
                // end of block
                indent--;
                indent();
                out.println("}");
                break;
            case ActionConstants.sactionIf:
            case ActionConstants.sactionJump:
                indent();
                out.println(entry.name + ":");
                break;
            default:
                assert (false);
                break;
            }
        }
    }

    public void call(Action action)
    {
        print(action);
    }

    public void gotoFrame2(GotoFrame2 action)
    {
        start(action);
        out.println(" " + action.playFlag);
    }

    public void quickTime(Action action)
    {
        print(action);
    }

    public void unknown(Unknown action)
    {
        print(action);
    }


    public static String quoteString(String s, char qc)
    {
        StringBuilder b = new StringBuilder(s.length() + 2);

        b.append(qc);
        for (int i=0; i < s.length(); i++)
        {
            char c = s.charAt(i);
            switch (c)
            {
            case 8: b.append("\\v"); break;
            case '\f' : b.append("\\f"); break;
            case '\r' : b.append("\\r"); break;
            case '\t' : b.append("\\t"); break;
            case '\n' : b.append("\\n"); break;
            case '"' : b.append("\\\""); break;
            case '\'' : b.append("\\'"); break;
            default: b.append(c); break;
            }
        }
        b.append(qc);
        return b.toString();
    }


    static final public String[] actionNames = {
        // 00 0000----
        "0x00",
        "0x01",
        "0x02",
        "0x03",
        "next", // sactionNextFrame
        "prev", // sactionPrevFrame
        "play", // sactionPlay
        "stop", // sactionStop
        "toggle", // sactionToggleQuality
        "stopsound", // sactionStopSounds
        "add", // sactionAdd
        "sub", // sactionSubtract
        "mul", // sactionMultiply
        "div", // sactionDivide
        "eq",  // sactionEquals
        "lt",  // sactionLess
        // 0x10 0001----
        "and",  // sactionAnd
        "or",   // sactionOr
        "not",  // sactionNot
        "seq",  // sactionStringEquals
        "slen", // sactionStringLength
        "substr", // sactionStringExtract
        "0x16",
        "pop",  // sactionPop
        "toint", // sactionToInteger
        "0x19",
        "0x1A",
        "0x1B",
        "get", // sactionGetVariable
        "set", // sactionGetVariable
        "0x1E",
        "0x1F",
        //0x20 0010----
        "settarget2", //sactionSetTarget2
        "sadd",     // sactionStringAdd
        "getprop",     // sactionGetProperty
        "setprop",     // sactoinSetProperty
        "csprite",  // sactionCloneSprite
        "rsprite",  // sactionRemoveSprite
        "trace",    // sactionTrace
        "sdrag",    // sactionStartDrag
        "edrag",    // sactionEndDragg
        "slt",      // sactionStringLess
        "0x2A",
        "0x2B",
        "0x2C",
        "0x2D",
        "0x2E",
        "0x2F",
        // 0x30 0011----
        "rand", // sactionRandomNumber
        "wslen", // sactionMbStringLength
        "c2a",  // sactionCharToAscii
        "a2c",  // sactionAscii2Char
        "time",  // sactionGetTime
        "wsubstr",  // sactionMBStringExtract
        "wc2a",   // sactionMbCharToAscii
        "wa2c",  // sactionMbAsciiToChar
        "0x38",
        "0x39",
        "del",   // sactionDelete
        "del2",   // sactionDelete2
        "var",  // sactionDefineLoc
        "callfun",  // sactionCallFunction
        "return",  // sactionReturn
        "mod",   // sactionMod
        // 0x40 0100----
        "newobj",    // sactionNewObject
        "var2",   // sactionDefineLocal2
        "initarr",     // sactionInitArray
        "initobj",    // sactionInitObject
        "typeof",   // sactionTypeOf
        "target",    // sactionTargetPath
        "enum",     // sactionEnumerate
        "add2",     // sactionAdd2
        "lt2",      // sactionLess2
        "eq2",      // sactionEquals2
        "tonum",    // sactionToNumber
        "tostr",    // sactionToString
        "dup",      // sactionPushDuplicate
        "swap",     // sactionStackSwap
        "getmem",     // sactionGetMember
        "setmem",     // sactionSetMember
        // 0x50 0101----
        "inc",      // sactionIncrement
        "dec",      // sactionDecrement
        "callmethod",    // sactionCallMethod
        "newmethod",     // sactionNewMethod
        "instanceof",   // sactionInstanceOf
        "enum2",    // sactionEnumerate2
        "0x56",
        "0x57",
        "0x58",
        "0x59",
        "0x5A",
        "0x5B",
        "0x5C",
        "0x5D",
        "0x5E",
        "halt",     // sactionHalt
        // 0x60 0110----
        "band",     // sactionBitAnd
        "bor",      // sactionBitOr
        "bxor",     // sactionBitXor
        "bls",      // sactionBitLShift
        "brs",      // sactionBitRShift
        "burs",     // sactionBitURShift
        "eqs",      // sactionStrictEquals
        "gt",       // sactionGreater
        "sgt",      // sactionStringGreater
        "extends",  // sactionExtends
        "0x6A",
        "0x6B",
        "0x6C",
        "0x6D",
        "0x6E",
        "0x6F",
        // 0x70 0111----
        "0x70",
        "0x71",
        "0x72",
        "0x73",
        "0x74",
        "0x75",
        "0x76",
        "nop",      // sactionNop
        "0x78",
        "0x79",
        "0x7A",
        "0x7B",
        "0x7C",
        "0x7D",
        "0x7E",
        "0x7F",
        // 0x80 1000----
        "0x80",
        "gotoframe",    // sactionGotoFrame
        "0x82",
        "geturl",   // sactionGetUrl
        "0x84",
        "0x85",
        "0x86",
        "store",    // sactionStoreRegister
        "cpool",    // sactionConstantPool
        "strict",   // sactionStrictMode
        "wait",     // sactionWaitForFrame
        "settarget",     // sactionSetTarget
        "gotolabel",    // sactoinGotoLabel
        "wait2",    // sactionWaitForFrame2
        "function2",    // sactionDefineFunction2
        "try",		// sactionTry
        // 0x90 1001----
        "0x90",
        "0x91",
        "0x92",
        "0x93",
        "with",     // sactionWith
        "0x95",
        "push",     // sactionPush
        "0x97",
        "0x98",
        "jump",     // sactionJump
        "geturl2",  // sactionGetUrl2
        "function",     // sactionDefineFunction
        "0x9C",
        "if",       // sactionIf
        "call",     // sactionCall
        "gotof2",   // sactionGotoFrame2
        // 0xA0 1010----
        "0xA0",
        "0xA1",
        "0xA2",
        "0xA3",
        "0xA4",
        "0xA5",
        "0xA6",
        "0xA7",
        "0xA8",
        "0xA9",
        "quicktime",       // sactionQuickTime
        "0xAB",
        "0xAC",
        "0xAD",
        "0xAE",
        "0xAF",
        // 0xB0 1011----
        "0xB0",
        "0xB1",
        "0xB2",
        "0xB3",
        "0xB4",
        "0xB5",
        "0xB6",
        "0xB7",
        "0xB8",
        "0xB9",
        "0xBA",
        "0xBB",
        "0xBC",
        "0xBD",
        "0xBE",
        "0xBF",
        // 0xC0 1100----
        "0xC0",
        "0xC1",
        "0xC2",
        "0xC3",
        "0xC4",
        "0xC5",
        "0xC6",
        "0xC7",
        "0xC8",
        "0xC9",
        "0xCA",
        "0xCB",
        "0xCC",
        "0xCD",
        "0xCE",
        "0xCF",
        // 0xD0 1101----
        "0xD0",
        "0xD1",
        "0xD2",
        "0xD3",
        "0xD4",
        "0xD5",
        "0xD6",
        "0xD7",
        "0xD8",
        "0xD9",
        "0xDA",
        "0xDB",
        "0xDC",
        "0xDD",
        "0xDE",
        "0xDF",
        // 0xE0 1110----
        "0xE0",
        "0xE1",
        "0xE2",
        "0xE3",
        "0xE4",
        "0xE5",
        "0xE6",
        "0xE7",
        "0xE8",
        "0xE9",
        "0xEA",
        "0xEB",
        "0xEC",
        "0xED",
        "0xEE",
        "0xEF",
        "0xF0",
        // 0xF0 1111----
        "0xF1",
        "0xF2",
        "0xF3",
        "0xF4",
        "0xF5",
        "0xF6",
        "0xF7",
        "0xF8",
        "0xF9",
        "0xFA",
        "0xFB",
        "0xFC",
        "0xFD",
        "0xFE",
        "0xFF",

        // these are not valid bytecodes, but we use them internally
        "label", // 0x100
        "line", // 0x101
    };
}

