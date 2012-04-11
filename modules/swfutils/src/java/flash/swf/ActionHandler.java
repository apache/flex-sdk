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

/**
 * Defines the AS2 visitor API.
 *
 * @author Clement Wong
 */
public class ActionHandler
{
	/**
	 * called before visiting each action, to indicate the offset of this
	 * action from the start of the SWF file.
	 * @param offset
	 */
	public void setActionOffset(int offset, Action a)
	{
	}

    public void nextFrame(Action action)
	{
	}

	public void prevFrame(Action action)
	{
	}

	public void play(Action action)
	{
	}

	public void stop(Action action)
	{
	}

	public void toggleQuality(Action action)
	{
	}

	public void stopSounds(Action action)
	{
	}

	public void add(Action action)
	{
	}

	public void subtract(Action action)
	{
	}

	public void multiply(Action action)
	{
	}

	public void divide(Action action)
	{
	}

	public void equals(Action action)
	{
	}

	public void less(Action action)
	{
	}

	public void and(Action action)
	{
	}

	public void or(Action action)
	{
	}

	public void not(Action action)
	{
	}

	public void stringEquals(Action action)
	{
	}

	public void stringLength(Action action)
	{
	}

	public void stringExtract(Action action)
	{
	}

	public void pop(Action action)
	{
	}

	public void toInteger(Action action)
	{
	}

	public void getVariable(Action action)
	{
	}

	public void setVariable(Action action)
	{
	}

	public void setTarget2(Action action)
	{
	}

	public void stringAdd(Action action)
	{
	}

	public void getProperty(Action action)
	{
	}

	public void setProperty(Action action)
	{
	}

	public void cloneSprite(Action action)
	{
	}

	public void removeSprite(Action action)
	{
	}

	public void trace(Action action)
	{
	}

	public void startDrag(Action action)
	{
	}

	public void endDrag(Action action)
	{
	}

	public void stringLess(Action action)
	{
	}

	public void randomNumber(Action action)
	{
	}

	public void mbStringLength(Action action)
	{
	}

	public void charToASCII(Action action)
	{
	}

	public void asciiToChar(Action action)
	{
	}

	public void getTime(Action action)
	{
	}

	public void mbStringExtract(Action action)
	{
	}

	public void mbCharToASCII(Action action)
	{
	}

	public void mbASCIIToChar(Action action)
	{
	}

	public void delete(Action action)
	{
	}

	public void delete2(Action action)
	{
	}

	public void defineLocal(Action action)
	{
	}

	public void callFunction(Action action)
	{
	}

	public void returnAction(Action action)
	{
	}

	public void modulo(Action action)
	{
	}

	public void newObject(Action action)
	{
	}

	public void defineLocal2(Action action)
	{
	}

	public void initArray(Action action)
	{
	}

	public void initObject(Action action)
	{
	}

	public void typeOf(Action action)
	{
	}

	public void targetPath(Action action)
	{
	}

	public void enumerate(Action action)
	{
	}

	public void add2(Action action)
	{
	}

	public void less2(Action action)
	{
	}

	public void equals2(Action action)
	{
	}

	public void toNumber(Action action)
	{
	}

	public void toString(Action action)
	{
	}

	public void pushDuplicate(Action action)
	{
	}

	public void stackSwap(Action action)
	{
	}

	public void getMember(Action action)
	{
	}

	public void setMember(Action action)
	{
	}

	public void increment(Action action)
	{
	}

	public void decrement(Action action)
	{
	}

	public void callMethod(Action action)
	{
	}

	public void newMethod(Action action)
	{
	}

	public void instanceOf(Action action)
	{
	}

	public void enumerate2(Action action)
	{
	}

	public void bitAnd(Action action)
	{
	}

	public void bitOr(Action action)
	{
	}

	public void bitXor(Action action)
	{
	}

	public void bitLShift(Action action)
	{
	}

	public void bitRShift(Action action)
	{
	}

	public void bitURShift(Action action)
	{
	}

	public void strictEquals(Action action)
	{
	}

	public void greater(Action action)
	{
	}

	public void stringGreater(Action action)
	{
	}

	public void gotoFrame(GotoFrame action)
	{
	}

	public void getURL(GetURL action)
	{
	}

	public void storeRegister(StoreRegister action)
	{
	}

	public void constantPool(ConstantPool action)
	{
	}

	public void strictMode(StrictMode action)
	{
	}

	public void waitForFrame(WaitForFrame action)
	{
	}

	public void setTarget(SetTarget action)
	{
	}

	public void gotoLabel(GotoLabel action)
	{
	}

	public void waitForFrame2(WaitForFrame action)
	{
	}

	public void with(With action)
	{
	}

	public void push(Push action)
	{
	}

	public void jump(Branch action)
	{
	}

	public void getURL2(GetURL2 action)
	{
	}

	public void defineFunction(DefineFunction action)
	{
	}

	public void defineFunction2(DefineFunction action)
	{
	}

	public void ifAction(Branch action)
	{
	}
    
    public void label(Label label)
    {
    }

	public void call(Action action)
	{
	}

	public void gotoFrame2(GotoFrame2 action)
	{
	}

	public void quickTime(Action action)
	{
	}

	public void unknown(Unknown action)
	{
	}

    public void tryAction(Try aTry)
    {
    }

    public void throwAction(Action aThrow)
    {
    }

    public void castOp(Action action)
    {
    }

    public void implementsOp(Action action)
    {
    }

	public void lineRecord(LineRecord line)
	{
	}

	public void registerRecord(RegisterRecord line)
	{
	}

    public void extendsOp(Action action)
    {
    }

    public void nop(Action action)
    {
    }

    public void halt(Action action)
    {
    }

}
