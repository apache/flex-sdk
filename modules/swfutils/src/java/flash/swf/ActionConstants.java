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

/**
 * Defines AS2 contants.
 */
public interface ActionConstants
{
	// Flash 1 and 2 actions
    int sactionHasLength		= 0x80;
    int sactionNone				= 0x00;
    int sactionGotoFrame		= 0x81; // frame num (int)
    int sactionGetURL			= 0x83; // url (STR), window (STR)
    int sactionNextFrame		= 0x04;
    int sactionPrevFrame		= 0x05;
    int sactionPlay				= 0x06;
    int sactionStop				= 0x07;
    int sactionToggleQuality	= 0x08;
    int sactionStopSounds		= 0x09;
    int sactionWaitForFrame		= 0x8A; // frame needed (int), actions to skip (BYTE)

    // Flash 3 Actions
    int sactionSetTarget		= 0x8B; // name (STR)
    int sactionGotoLabel		= 0x8C; // name (STR)

    // Flash 4 Actions
    int sactionAdd				= 0x0A; // Stack IN: number, number, OUT: number
    int sactionSubtract			= 0x0B; // Stack IN: number, number, OUT: number
    int sactionMultiply			= 0x0C; // Stack IN: number, number, OUT: number
    int sactionDivide			= 0x0D; // Stack IN: dividend, divisor, OUT: number
    int sactionEquals			= 0x0E; // Stack IN: number, number, OUT: bool
    int sactionLess				= 0x0F; // Stack IN: number, number, OUT: bool
    int sactionAnd				= 0x10; // Stack IN: bool, bool, OUT: bool
    int sactionOr				= 0x11; // Stack IN: bool, bool, OUT: bool
    int sactionNot				= 0x12; // Stack IN: bool, OUT: bool
    int sactionStringEquals		= 0x13; // Stack IN: string, string, OUT: bool
    int sactionStringLength		= 0x14; // Stack IN: string, OUT: number
    int sactionStringAdd		= 0x21; // Stack IN: string, strng, OUT: string
    int sactionStringExtract	= 0x15; // Stack IN: string, index, count, OUT: substring
    int sactionPush				= 0x96; // type (BYTE), value (STRING or FLOAT)
    int sactionPop				= 0x17; // no arguments
    int sactionToInteger		= 0x18; // Stack IN: number, OUT: integer
    int sactionJump				= 0x99; // offset (int)
    int sactionIf				= 0x9D; // offset (int) Stack IN: bool
    int sactionCall				= 0x9E; // Stack IN: name
    int sactionGetVariable		= 0x1C; // Stack IN: name, OUT: value
    int sactionSetVariable		= 0x1D; // Stack IN: name, value
    int sactionGetURL2			= 0x9A; // method (BYTE) Stack IN: url, window
    int sactionGotoFrame2		= 0x9F; // flags (BYTE) Stack IN: frame
    int sactionSetTarget2		= 0x20; // Stack IN: target
    int sactionGetProperty		= 0x22; // Stack IN: target, property, OUT: value
    int sactionSetProperty		= 0x23; // Stack IN: target, property, value
    int sactionCloneSprite		= 0x24; // Stack IN: source, target, depth
    int sactionRemoveSprite		= 0x25; // Stack IN: target
    int sactionTrace			= 0x26; // Stack IN: message
    int sactionStartDrag		= 0x27; // Stack IN: no constraint: 0, center, target
    									// constraint: x1, y1, x2, y2, 1, center, target
    int sactionEndDrag			= 0x28; // no arguments
    int sactionStringLess		= 0x29; // Stack IN: string, string, OUT: bool
    int sactionWaitForFrame2	= 0x8D; // skipCount (BYTE) Stack IN: frame
    int sactionRandomNumber		= 0x30; // Stack IN: maximum, OUT: result
    int sactionMBStringLength	= 0x31; // Stack IN: string, OUT: length
    int sactionCharToAscii		= 0x32; // Stack IN: character, OUT: ASCII code
    int sactionAsciiToChar		= 0x33; // Stack IN: ASCII code, OUT: character
    int sactionGetTime			= 0x34; // Stack OUT: milliseconds since Player start
    int sactionMBStringExtract	= 0x35;// Stack IN: string, index, count, OUT: substring
    int sactionMBCharToAscii	= 0x36;// Stack IN: character, OUT: ASCII code
    int sactionMBAsciiToChar	= 0x37;// Stack IN: ASCII code, OUT: character

    // Flash 5 actions
    //unused OK to reuse --> public static final int sactionGetLastKeyCode= 0x38; // Stack OUT: code for last key pressed
    int sactionDelete			= 0x3A; // Stack IN: name of object to delete
    int sactionDefineFunction	= 0x9B; // name (STRING), body (BYTES)
    int sactionDelete2			= 0x3B; // Stack IN: name
    int sactionDefineLocal		= 0x3C; // Stack IN: name, value
    int sactionCallFunction		= 0x3D; // Stack IN: function, numargs, arg1, arg2, ... argn
    int sactionReturn			= 0x3E; // Stack IN: value to return
    int sactionModulo			= 0x3F; // Stack IN: x, y Stack OUT: x % y
    int sactionNewObject		= 0x40; // like CallFunction but constructs object
    int sactionDefineLocal2		= 0x41; // Stack IN: name
    int sactionInitArray		= 0x42; // Stack IN: //# of elems, arg1, arg2, ... argn
    int sactionInitObject		= 0x43; // Stack IN: //# of elems, arg1, name1, ...
    int sactionTypeOf			= 0x44; // Stack IN: object, Stack OUT: type of object
    int sactionTargetPath		= 0x45; // Stack IN: object, Stack OUT: target path
    int sactionEnumerate		= 0x46; // Stack IN: name, Stack OUT: children ended by null
    int sactionStoreRegister	= 0x87; // register number (BYTE, 0-31)
    int sactionAdd2				= 0x47; // Like sactionAdd, but knows about types
    int sactionLess2			= 0x48; // Like sactionLess, but knows about types
    int sactionEquals2			= 0x49; // Like sactionEquals, but knows about types
    int sactionToNumber			= 0x4A; // Stack IN: object Stack OUT: number
    int sactionToString			= 0x4B; // Stack IN: object Stack OUT: string
    int sactionPushDuplicate	= 0x4C; // pushes duplicate of top of stack
    int sactionStackSwap		= 0x4D; // swaps top two items on stack
    int sactionGetMember		= 0x4E; // Stack IN: object, name, Stack OUT: value
    int sactionSetMember		= 0x4F; // Stack IN: object, name, value
    int sactionIncrement		= 0x50; // Stack IN: value, Stack OUT: value+1
    int sactionDecrement		= 0x51; // Stack IN: value, Stack OUT: value-1
    int sactionCallMethod		= 0x52; // Stack IN: object, name, numargs, arg1, arg2, ... argn
    int sactionNewMethod		= 0x53; // Like sactionCallMethod but constructs object
    int sactionWith				= 0x94; // body length: int, Stack IN: object
    int sactionConstantPool		= 0x88; // Attaches constant pool
    int sactionStrictMode		= 0x89; // Activate/deactivate strict mode

    int sactionBitAnd			= 0x60; // Stack IN: number, number, OUT: number
    int sactionBitOr 			= 0x61; // Stack IN: number, number, OUT: number
    int sactionBitXor			= 0x62; // Stack IN: number, number, OUT: number
    int sactionBitLShift		= 0x63; // Stack IN: number, number, OUT: number
    int sactionBitRShift		= 0x64; // Stack IN: number, number, OUT: number
    int sactionBitURShift		= 0x65; // Stack IN: number, number, OUT: number

    // Flash 6 actions
	int sactionInstanceOf		= 0x54; // Stack IN: object, class OUT: boolean
	int sactionEnumerate2		= 0x55; // Stack IN: object, Stack OUT: children ended by null
    int sactionStrictEquals		= 0x66; // Stack IN: something, something, OUT: bool
    int sactionGreater			= 0x67; // Stack IN: something, something, OUT: bool
    int sactionStringGreater	= 0x68; // Stack IN: something, something, OUT: bool

	// Flash 7 actions
	int sactionDefineFunction2	= 0x8E; // name (STRING), numParams (WORD), registerCount (BYTE)
	int sactionTry				= 0x8F;
	int sactionThrow			= 0x2A;
	int sactionCastOp			= 0x2B;
	int sactionImplementsOp		= 0x2C;

	int sactionExtends			= 0x69; // stack in: baseclass, classname, constructor

    int sactionNop				= 0x77;  // nop
    int sactionHalt				= 0x5F;  // halt script execution

	// Reserved for Quicktime
	int sactionQuickTime		= 0xAA; // I think this is what they are using...

    int kPushStringType			= 0;
    int kPushFloatType			= 1;
    int kPushNullType			= 2;
    int kPushUndefinedType		= 3;
    int kPushRegisterType		= 4;
    int kPushBooleanType		= 5;
    int kPushDoubleType			= 6;
    int kPushIntegerType		= 7;
    int kPushConstant8Type		= 8;
    int kPushConstant16Type		= 9;

    // GetURL2 methods

    int kHttpDontSend			= 0x0000;
    int kHttpSendUseGet			= 0x0001;
    int kHttpSendUsePost		= 0x0002;
    int kHttpMethodMask			= 0x0003;
    int kHttpLoadTarget			= 0x0040;
    int kHttpLoadVariables		= 0x0080;
//    //#ifdef FAP
//    int kHttpIsFAP = 0x0200;
    //#endif

    int kClipEventLoad			= 0x0001;
    int kClipEventEnterFrame	= 0x0002;
    int kClipEventUnload		= 0x0004;
    int kClipEventMouseMove		= 0x0008;
    int kClipEventMouseDown		= 0x0010;
    int kClipEventMouseUp		= 0x0020;
    int kClipEventKeyDown		= 0x0040;
    int kClipEventKeyUp			= 0x0080;
    int kClipEventData			= 0x0100;
    int kClipEventInitialize	= 0x00200;
    int kClipEventPress			= 0x00400;
    int kClipEventRelease		= 0x00800;
    int kClipEventReleaseOutside = 0x01000;
    int kClipEventRollOver		= 0x02000;
    int kClipEventRollOut		= 0x04000;
    int kClipEventDragOver		= 0x08000;
    int kClipEventDragOut		= 0x10000;
    int kClipEventKeyPress		= 0x20000;
	int kClipEventConstruct		= 0x40000;

	// #ifdef FEATURE_EXCEPTIONS
	int kTryHasCatchFlag		= 1;
	int kTryHasFinallyFlag		= 2;
	int kTryCatchRegisterFlag	= 4;
	// #endif /* FEATURE_EXCEPTIONS */
}
