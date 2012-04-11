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

import flash.swf.Dictionary;
import flash.swf.actions.*;
import flash.swf.debug.DebugModule;
import flash.swf.debug.LineRecord;
import flash.swf.tags.*;
import flash.swf.types.*;
import flash.util.IntMap;

import java.io.*;
import java.net.*;
import java.util.*;

/**
 * Represents SWF metadata, which should not be confuses with AS3
 * metadata.
 *
 * @author Clement Wong
 */
public final class MovieMetaData extends TagHandler
{
	public MovieMetaData(byte[] swf, byte[] swd)
	{
		this(new ByteArrayInputStream(swf), new ByteArrayInputStream(swd));
	}


	public MovieMetaData(InputStream swf, InputStream swd)
	{
		try
		{
			init();
			TagDecoder p = new TagDecoder(swf, swd);
			parse(p);
		}
		catch (IOException ex)
		{
		}
	}

	public MovieMetaData(String u)
	{
		try
		{
			init();
			URL url = new URL(u);
			InputStream in = url.openStream();
			TagDecoder p = new TagDecoder(in, url);
			parse(p);
		}
		catch (MalformedURLException ex)
		{
		}
		catch (IOException ex)
		{
		}
	}

	private void init()
	{
		actions = new IntMap();
		modules = new IntMap();
		functionNames = new IntMap();
		functionSizes = new IntMap();
		functionLines = new IntMap();
		preciseLines = new IntMap();
		mxml = new HashMap<String, DebugModule>();

		pool = null;
		skipOffsets = new ArrayList<Integer>();
	}

	private void parse(TagDecoder p) throws IOException
	{
		p.setKeepOffsets(true);
		p.parse(this);

		Collections.sort(skipOffsets);
		className = null;
	}

	private Dictionary dict;
	private Header header;

	// given an offset, what's the bytecode?
	public IntMap actions;

	// given an offset, what debug module it's in?
	public IntMap modules;

	// given an offset, what function it's in?
	public IntMap functionNames;
	public IntMap functionSizes;
	public IntMap functionLines;
	public IntMap preciseLines;

	// MXML DebugModule
	public Map<String, DebugModule> mxml;

	// offsets that we don't want to profile
	public List<Integer> skipOffsets;

	// temporarily store AS2 class name...
	private String className;

	private String[] pool;

	public DebugModule getDebugModule(int offset)
	{
		DebugModule d = (DebugModule) modules.get(offset);
		if (d == null)
		{
			return null;
		}
		else
		{
			return d;
		}
	}

	public String getFunctionName(int offset)
	{
		return (String) functionNames.get(offset);
	}

	public Iterator getFunctionLines()
	{
		return preciseLines.iterator();
	}

	public Integer getOpCode(int offset)
	{
		return (Integer) actions.get(offset);
	}

	protected Integer getFunctionLineNumber(int offset)
	{
		return (Integer) functionLines.get(offset);
	}

	protected boolean isFunction(int offset)
	{
		String s = getFunctionName(offset);
		return (s != null);
	}

	public void setDecoderDictionary(Dictionary dict)
	{
		this.dict = dict;
	}

	public void header(Header h)
	{
		header = h;
	}

	public void defineButton(DefineButton tag)
	{
		String[] temp = pool;
		collectActions(tag.condActions[0].actionList);
		pool = temp;
	}

	public void doAction(DoAction tag)
	{
		String[] temp = pool;
		collectActions(tag.actionList);
		pool = temp;
	}

    public void placeObject2(PlaceObject tag)
    {
        collectClipActions(tag.clipActions);
    }

    public void placeObject3(PlaceObject tag)
    {
        collectClipActions(tag.clipActions);
    }

    public void defineButton2(DefineButton tag)
	{
		collectCondActions(tag.condActions);
	}

	public void defineSprite(DefineSprite tag)
	{
		collectSpriteActions(tag.tagList);
	}

	public void doInitAction(DoInitAction tag)
	{
		if (header.version > 6 && tag.sprite != null)
		{
			String __Packages = idRef(tag.sprite);
			className = (__Packages != null && __Packages.startsWith("__Packages")) ? __Packages.substring(11) : null; // length("__Packages.") = 11

			if (isRegisterClass(tag.actionList))
			{
				DebugModule dm = new DebugModule();
				// C: We actually want the class name here, not the linkage ID.
				dm.name = "<" + __Packages + ".2>";
				// C: We want the class name as the second input argument. Fortunately, we don't
				//    really do anything with the source, so it's okay.
				dm.setText("Object.registerClass(" + __Packages + ", " + __Packages + ");");
				dm.bitmap = 1;

				LineRecord lr = new LineRecord(1, dm);

				int startOffset = tag.actionList.getOffset(0);
				dm.addOffset(lr, startOffset);

				tag.actionList.insert(startOffset, lr);
				modules.put((int) (Math.random() * Integer.MAX_VALUE), dm);
			}
		}

		String[] temp = pool;
		collectActions(tag.actionList);
		pool = temp;

		className = null;
	}

	private static final int[] regClassCall9 = new int[]
	{
			ActionConstants.sactionPush, // class name
			ActionConstants.sactionGetVariable,
			ActionConstants.sactionPush, // linkage id
			ActionConstants.sactionPush, // 2
			ActionConstants.sactionPush, // Object
			ActionConstants.sactionGetVariable,
			ActionConstants.sactionPush, // registerClass
			ActionConstants.sactionCallMethod,
			ActionConstants.sactionPop
	};

	private static final int[] regClassCall10 = new int[]
	{
			ActionConstants.sactionConstantPool, // constant pool
			ActionConstants.sactionPush, // class name
			ActionConstants.sactionGetVariable,
			ActionConstants.sactionPush, // linkage id
			ActionConstants.sactionPush, // 2
			ActionConstants.sactionPush, // Object
			ActionConstants.sactionGetVariable,
			ActionConstants.sactionPush, // registerClass
			ActionConstants.sactionCallMethod,
			ActionConstants.sactionPop
	};

	// TODO: Use an evaluation stack to figure out the Object.registerClass() call.
	public static final boolean isRegisterClass(ActionList actionList)
	{
		if (!hasLineRecord(actionList))
		{
			int[] opcodes;

			if (actionList.size() == 9)
			{
				opcodes = regClassCall9;
			}
			else if (actionList.size() == 10)
			{
				opcodes = regClassCall10;
			}
			else
			{
				return false;
			}

			for (int i = 0;i < opcodes.length;i++)
			{
				if (actionList.getAction(i).code != opcodes[i])
				{
					return false;
				}
				else
				{
					// TODO: need to check the PUSH values...
				}
			}

			return true;
		}

		return false;
	}

	String idRef(DefineTag tag) { return idRef(tag, dict); }

	public static String idRef(DefineTag tag, Dictionary d)
	{
		if (tag == null)
		{
			// if tag is null then it isn't in the dict -- the SWF is invalid.
			// lets be lax and print something; Matador generates invalid SWF sometimes.
			return "-1";
		}
		else if (tag.name == null)
		{
			// just print the character id since no name was exported
			return String.valueOf(d.getId(tag));
		}
		else
		{
			return tag.name;
		}
	}

	private static final boolean hasLineRecord(ActionList c)
	{
		if (c == null || c.size() == 0)
		{
			return true;
		}

		boolean result = false;

		for (int i=0; i < c.size() && !result; i++)
		{
			Action action = c.getAction(i);

			switch (action.code)
			{
			case ActionConstants.sactionDefineFunction:
			case ActionConstants.sactionDefineFunction2:
				result = result || hasLineRecord(((DefineFunction) action).actionList);
				break;
			case ActionList.sactionLineRecord:
				result = true;
				break;
			}
		}

		return result;
	}

	private void collectSpriteActions(TagList s)
	{
		String[] temp;

		int len = s.tags.size();
		for (int i = 0; i < len; i++)
		{
			Tag t = s.tags.get(i);
			switch (t.code)
			{
			case TagValues.stagDoAction:
				temp = pool;
				collectActions(((DoAction) t).actionList);
				pool = temp;
				break;
			case TagValues.stagDefineButton2:
				collectCondActions(((DefineButton) t).condActions);
				break;
			case TagValues.stagDefineButton:
				temp = pool;
				collectActions(((DefineButton) t).condActions[0].actionList);
				pool = temp;
				break;
			case TagValues.stagDoInitAction:
				temp = pool;
				collectActions(((DoInitAction) t).actionList);
				pool = temp;
				break;
			case TagValues.stagDefineSprite:
				collectSpriteActions(((DefineSprite) t).tagList);
				break;
			case TagValues.stagPlaceObject2:
				collectClipActions(((PlaceObject) t).clipActions);
				break;
			}
		}
	}

	private DebugModule findDebugModule(ActionList c)
	{
		MFUCache modules = new MFUCache();

		for (int i=0; i < c.size(); i++)
		{
			Action a = c.getAction(i);

			DebugModule temp = null;

			switch (a.code)
			{
			case ActionConstants.sactionDefineFunction:
			case ActionConstants.sactionDefineFunction2:
				temp = findDebugModule(((DefineFunction) a).actionList);
				break;
			case ActionList.sactionLineRecord:
				if (((LineRecord)a).module != null)
				{
					temp = ((LineRecord)a).module;
				}
				break;
			}

			if (temp != null)
			{
				modules.add(temp);
			}
		}

		// ActionList may have actions pointing to more than one debug module because of #include, etc.
		// The majority wins.

		return modules.topModule;
	}

    private static Integer[] codes = new Integer[256];
    static
    {
        for (int i=0; i < 256; i++)
        {
            codes[i] = new Integer(i);
        }
    }

	private void collectActions(ActionList c)
	{
		// assumption: ActionContext c is always not null! try-catch-finally may be busted.
		if (c == null)
		{
			return;
		}

		// interprets the actions. try to assign names to anonymous functions...
		evalActions(c);

		DebugModule d = findDebugModule(c);

		String emptyMethodName = null;

		// loop again, this time, we register all the actions...
		for (int i=0; i < c.size(); i++)
		{
            int ioffset = c.getOffset(i);
			Action a = c.getAction(i);

			if (emptyMethodName != null && emptyMethodName.length() != 0)
			{
				functionNames.put(ioffset, emptyMethodName);
				emptyMethodName = null;
			}

			if (a.code == ActionList.sactionLineRecord)
			{
				LineRecord line = (LineRecord) a;
				if (line.module != null)
				{
					d = line.module;
					if (d.name.endsWith(".mxml"))
					{
						mxml.put(d.name, d);
					}
				}

				continue;
			}

			if (a.code >= 256)
			{
				// something synthetic we don't care about
				continue;
			}

			actions.put(ioffset, codes[a.code]);
			modules.put(ioffset, d);

			switch (a.code)
			{
			case ActionConstants.sactionDefineFunction:
			case ActionConstants.sactionDefineFunction2:
				DefineFunction f = (DefineFunction) a;
				Integer size = new Integer(f.codeSize);

				if (f.actionList.size() == 0)
				{
					emptyMethodName = f.name;
				}
				else
				{
					Integer lineno = null;

					// map all the offsets in this function to the function name
					for (int j=0; j < f.actionList.size(); j++)
					{
						int o = f.actionList.getOffset(j);
						Action child = f.actionList.getAction(j);
						if (child.code == ActionList.sactionLineRecord)
						{
							// also find out the first line number of this function
							if (lineno == null)
								lineno = new Integer(((LineRecord)child).lineno);

							preciseLines.put(o, new Integer( ((LineRecord)child).lineno ));
						}
						functionNames.put(o, f.name);
						functionSizes.put(o, size);
					}


					// map all the offsets in this function to the first line number of this function.
					for (int j=0; j < f.actionList.size(); j++)
					{
						int o = f.actionList.getOffset(j);
						functionLines.put(o, lineno);
					}
				}

				collectActions(f.actionList);
				break;
			}
		}
	}

	private void collectCondActions(ButtonCondAction[] actions)
	{
		for (int i = 0; i < actions.length; i++)
		{
			collectActions(actions[i].actionList);
		}
	}

	private void collectClipActions(ClipActions actions)
	{
		if (actions != null)
		{
			Iterator it = actions.clipActionRecords.iterator();
			while (it.hasNext())
			{
				ClipActionRecord record = (ClipActionRecord) it.next();
				collectActions(record.actionList);
			}
		}
	}

	private static Object pop(Stack<Object> stack)
	{
		return (stack.isEmpty()) ? null : stack.pop();
	}

	private void evalActions(ActionList c)
	{
		try
		{
			walkActions(c, header.version, pool, className, skipOffsets);
		}
		catch(Throwable t)
		{
		}
	}

	// data used in our walkActions routine
	private static Object dummy = new Object();
	private static Object[] registers = new Object[256];
	static
	{
		for (int i = 0;i < 256;i++)
		{
			registers[i] = dummy;
		}
	}

	/**
	 * Walk the actions filling in the names of functions as we go.
	 * This is done by looking for DefineFunction's actions and then
	 * examining the content of the stack for a name.
	 * 
	 * @param c list of actions to be traversed
	 * @param swfVersion version of swf file that housed the ActionList (just use 7 if you don't know)
	 * @param pool optional; constant pool for the list of actions
	 * @param className optional; used to locate a constructor function (i.e if funcName == className)
	 * @param profileOffsets optional; is filled with offsets if a call to a 
	 * function named 'profile' is encountered.  Can be null if caller is not
	 * interested in obtaining this information.
	 */
	public static void walkActions(ActionList c, int swfVersion, String[] pool, String className, List<Integer> profileOffsets)
	{
		// assumption: ActionContext c is always not null! try-catch-finally may be busted.
		if (c == null) return;

		Stack<Object> evalStack = new Stack<Object>();
		HashMap<Object, Object> variables = new HashMap<Object, Object>();

		// loop again, this time, we register all the actions...
		int offset;
		Action a;

		for (int i=0; i < c.size(); i++)
		{
			offset = c.getOffset(i);
			a = c.getAction(i);

			switch (a.code)
			{
				// Flash 1 and 2 actions
			case ActionConstants.sactionHasLength:
			case ActionConstants.sactionNone:
			case ActionConstants.sactionGotoFrame:
			case ActionConstants.sactionGetURL:
			case ActionConstants.sactionNextFrame:
			case ActionConstants.sactionPrevFrame:
			case ActionConstants.sactionPlay:
			case ActionConstants.sactionStop:
			case ActionConstants.sactionToggleQuality:
			case ActionConstants.sactionStopSounds:
			case ActionConstants.sactionWaitForFrame:
				// Flash 3 Actions
			case ActionConstants.sactionSetTarget:
			case ActionConstants.sactionGotoLabel:
				// no action
				break;

				// Flash 4 Actions
			case ActionConstants.sactionAdd:
			case ActionConstants.sactionSubtract:
			case ActionConstants.sactionMultiply:
			case ActionConstants.sactionDivide:
			case ActionConstants.sactionEquals:
			case ActionConstants.sactionLess:
			case ActionConstants.sactionAnd:
			case ActionConstants.sactionOr:
			case ActionConstants.sactionStringEquals:
			case ActionConstants.sactionStringAdd:
			case ActionConstants.sactionStringLess:
			case ActionConstants.sactionMBStringLength:
			case ActionConstants.sactionGetProperty:
				// pop, pop, push
				pop(evalStack);
				break;
			case ActionConstants.sactionNot:
			case ActionConstants.sactionStringLength:
			case ActionConstants.sactionToInteger:
			case ActionConstants.sactionCharToAscii:
			case ActionConstants.sactionAsciiToChar:
			case ActionConstants.sactionMBCharToAscii:
			case ActionConstants.sactionMBAsciiToChar:
			case ActionConstants.sactionRandomNumber:
				// pop, push
				break;
			case ActionConstants.sactionGetVariable:
				Object key = pop(evalStack);
				if (variables.get(key) == null)
				{
					evalStack.push(key);
				}
				else
				{
					evalStack.push(variables.get(key));
				}
				break;
			case ActionConstants.sactionStringExtract:
			case ActionConstants.sactionMBStringExtract:
				// pop, pop, pop, push
				pop(evalStack);
				pop(evalStack);
				break;
			case ActionConstants.sactionPush:
				Push p = (Push) a;
				Object o = p.value;
				int type = Push.getTypeCode(o);
				switch (type)
				{
				case Push.kPushStringType:
					evalStack.push(o);
					break;
				case Push.kPushNullType:
					evalStack.push("null");
					break;
				case Push.kPushUndefinedType:
					evalStack.push("undefined");
					break;
				case Push.kPushRegisterType:
					evalStack.push(registers[((Byte)o).intValue()&0xFF]);
					break;
				case Push.kPushConstant8Type:
				case Push.kPushConstant16Type:
					evalStack.push(pool[((Number) o).intValue()&0xFFFF]);
					break;
				case Push.kPushFloatType:
					evalStack.push(o + "F");
					break;
				case Push.kPushBooleanType:
				case Push.kPushDoubleType:
				case Push.kPushIntegerType:
					evalStack.push(o);
					break;
				default:
					evalStack.push("type" + type);
					break;
				}
				break;
			case ActionConstants.sactionIf:
				pop(evalStack);
				break;
			case ActionConstants.sactionPop:
			case ActionConstants.sactionCall:
			case ActionConstants.sactionGotoFrame2:
			case ActionConstants.sactionSetTarget2:
			case ActionConstants.sactionRemoveSprite:
			case ActionConstants.sactionWaitForFrame2:
			case ActionConstants.sactionTrace:
				// pop
				pop(evalStack);
				break;
			case ActionConstants.sactionJump:
			case ActionConstants.sactionEndDrag:
				// no action
				break;
			case ActionConstants.sactionSetVariable:
				key = pop(evalStack);
				Object val = pop(evalStack);
				variables.put(key, val);
				break;
			case ActionConstants.sactionGetURL2:
				// pop, pop
				pop(evalStack);
				pop(evalStack);
				break;
			case ActionConstants.sactionSetProperty:
			case ActionConstants.sactionCloneSprite:
				// pop, pop, pop
				pop(evalStack);
				pop(evalStack);
				pop(evalStack);
				break;
			case ActionConstants.sactionStartDrag:
				// pop, pop, pop, if the 3rd pop is non-zero, pop, pop, pop, pop
				pop(evalStack);
				pop(evalStack);
				Object obj = pop(evalStack);
				if (Integer.parseInt(obj.toString()) != 0)
				{
					pop(evalStack);
					pop(evalStack);
					pop(evalStack);
					pop(evalStack);
				}
				break;
			case ActionConstants.sactionGetTime:
				// push
				evalStack.push(dummy);
				break;

				// Flash 5 actions
			case ActionConstants.sactionDelete:
				pop(evalStack);
				break;
			case ActionConstants.sactionDefineLocal:
				// pop, pop
				val = pop(evalStack);
				key = pop(evalStack);
				variables.put(key, val);
				break;
			case ActionConstants.sactionDefineFunction:
			case ActionConstants.sactionDefineFunction2:
				DefineFunction f = (DefineFunction) a;

				if (swfVersion > 6 && className != null)
				{
					if (f.name == null || f.name.length() == 0)
					{
						int depth = evalStack.size();
						if (depth != 0)
						{
							o = evalStack.peek();
							if (o == dummy)
							{
								f.name = "";
							}
							else if (o != null)
							{
								f.name = o.toString();
							}
						}
						evalStack.push(dummy);
					}

					if ("null".equals(f.name))
					{
						f.name = "";
					}

					if (f.name == null || f.name.length() == 0)
					{
						// do nothing... it's an anonymous function!
					}
					else if (!className.endsWith(f.name))
					{
						f.name = className + "." + f.name;
					}
					else
					{
						f.name = className + ".[constructor]";
					}
				}
				else
				{
					if (f.name == null || f.name.length() == 0)
					{
						StringBuilder buffer = new StringBuilder();
						int depth = evalStack.size();
						for (int k = depth - 1; k >= 0; k--)
						{
							o = evalStack.get(k);
							if (o == dummy)
							{
								break;
							}
							else if (k == depth - 1)
							{
								buffer.append(o);
							}
							else
							{
								buffer.insert(0, '.');
								buffer.insert(0, o);
							}
						}
						f.name = buffer.toString();

						if (f.name != null && f.name.indexOf(".prototype.") == -1)
						{
							f.name = "";
						}
						evalStack.push(dummy);
					}
				}
				// evalActions(f.actions);
				break;
			case ActionConstants.sactionCallFunction:
				Object function = pop(evalStack);
				if (profileOffsets != null && "profile".equals(function))
				{
					profileOffsets.add(new Integer(offset - 13)); // Push 1
					profileOffsets.add(new Integer(offset - 5)); // Push 'profile'
					profileOffsets.add(new Integer(offset)); // CallFunction
					profileOffsets.add(new Integer(offset + 1)); // Pop
				}
				int n = ((Number) pop(evalStack)).intValue();
				for (int k = 0; k < n; k++)
				{
					pop(evalStack);
				}
				evalStack.push(dummy);
				break;
			case ActionConstants.sactionReturn:
				// return function() { ... } doesn't push...
				pop(evalStack);
				break;
			case ActionConstants.sactionModulo:
				// pop, push
				break;
			case ActionConstants.sactionNewObject:
				pop(evalStack);
				int num = ((Number) pop(evalStack)).intValue();
				for (int k = 0; k < num; k++)
				{
					pop(evalStack);
				}
				evalStack.push(dummy);
				break;
			case ActionConstants.sactionDefineLocal2:
			case ActionConstants.sactionDelete2:
			case ActionConstants.sactionAdd2:
			case ActionConstants.sactionLess2:
				// pop
				pop(evalStack);
				break;
			case ActionConstants.sactionInitArray:
				// pop, if the first pop is non-zero, keep popping
				num = ((Number) pop(evalStack)).intValue();
				for (int k = 0; k < num; k++)
				{
					pop(evalStack);
				}
				evalStack.push(dummy);
				break;
			case ActionConstants.sactionInitObject:
				num = ((Number) pop(evalStack)).intValue() * 2;
				for (int k = 0; k < num; k++)
				{
					pop(evalStack);
				}
				evalStack.push(dummy);
				break;
			case ActionConstants.sactionTargetPath:
			case ActionConstants.sactionEnumerate:
			case ActionConstants.sactionToNumber:
			case ActionConstants.sactionToString:
			case ActionConstants.sactionTypeOf:
				// no action
				break;
			case ActionConstants.sactionStoreRegister:
				StoreRegister r = (StoreRegister) a;
				registers[r.register] = evalStack.peek();
				break;
			case ActionConstants.sactionEquals2:
				// pop, pop, push
				// if (evalStack.size() >= 2)
			{
				pop(evalStack);
			}
			break;
			case ActionConstants.sactionPushDuplicate:
				evalStack.push(dummy);
				break;
			case ActionConstants.sactionStackSwap:
				// pop, pop, push, push
				break;
			case ActionConstants.sactionGetMember:
				// pop, pop, concat, push
				Object o1 = pop(evalStack);
				Object o2 = pop(evalStack);
				if (pool != null)
				{
					try
					{
						evalStack.push(pool[Integer.parseInt(o2.toString())] + "." + pool[Integer.parseInt(o1.toString())]);
					}
					catch (Exception ex)
					{
						if (o1 == dummy || o2 == dummy)
						{
							evalStack.push(dummy);
						}
						else
						{
							evalStack.push(o2 + "." + o1);
						}
					}
				}
				else
				{
					evalStack.push(o2 + "." + o1);
				}
				break;
			case ActionConstants.sactionSetMember:
				// pop, pop, pop
				pop(evalStack);
				pop(evalStack);
				pop(evalStack);
				break;
			case ActionConstants.sactionIncrement:
			case ActionConstants.sactionDecrement:
				break;
			case ActionConstants.sactionCallMethod:
				pop(evalStack);
				pop(evalStack);
				Object obj2 = pop(evalStack);
				if (obj2 instanceof String)
				{
					try {
						n = Integer.parseInt((String) obj2);
					}
					catch (NumberFormatException ex)
					{
						n = 1;
					}
				}
				else
				{
					n = ((Number) obj2).intValue();
				}
				for (int k = 0; k < n; k++)
				{
					pop(evalStack);
				}
				evalStack.push(dummy);
				break;
			case ActionConstants.sactionNewMethod:
				/*Object meth =*/ pop(evalStack);
			/*Object cls =*/ pop(evalStack);
			num = ((Number) pop(evalStack)).intValue();
			for (int k = 0; k < num; k++)
			{
				pop(evalStack);
			}
			evalStack.push(dummy);
			break;
			case ActionConstants.sactionWith:
				// pop
				pop(evalStack);
				break;
			case ActionConstants.sactionConstantPool:
				pool = ((ConstantPool) a).pool;
				// no action
				break;
			case ActionConstants.sactionStrictMode:
				break;

			case ActionConstants.sactionBitAnd:
			case ActionConstants.sactionBitOr:
			case ActionConstants.sactionBitLShift:
				// pop, push
				break;
			case ActionConstants.sactionBitXor:
			case ActionConstants.sactionBitRShift:
			case ActionConstants.sactionBitURShift:
				pop(evalStack);
				break;

				// Flash 6 actions
			case ActionConstants.sactionInstanceOf:
				pop(evalStack);
				break;
			case ActionConstants.sactionEnumerate2:
				// pop, push, more pushes?
				break;
			case ActionConstants.sactionStrictEquals:
			case ActionConstants.sactionGreater:
			case ActionConstants.sactionStringGreater:
				pop(evalStack);
				break;

				// FEATURE_EXCEPTIONS
			case ActionConstants.sactionTry:
				// do nothing
				break;
			case ActionConstants.sactionThrow:
				pop(evalStack);
				break;

				// FEATURE_AS2_INTERFACES
			case ActionConstants.sactionCastOp:
				break;
			case ActionConstants.sactionImplementsOp:
				break;

				// Reserved for Quicktime
			case ActionConstants.sactionQuickTime:
				break;
			default:
				break;
			}
		}
	}
}

class MFUCache
{
	HashMap<DebugModule, Integer> cache = new HashMap<DebugModule, Integer>(5);
	DebugModule topModule;
	int topCount;

	void add(DebugModule m)
	{
		Integer count = cache.get(m);
		if (count == null)
		{
			count = new Integer(0);
		}
		count = new Integer(count.intValue() + 1);
		cache.put(m, count);

		if (count.intValue() > topCount)
		{
			topCount = count.intValue();
			topModule = m;
		}
	}

	DebugModule getTopModule()
	{
		return topModule;
	}
}
