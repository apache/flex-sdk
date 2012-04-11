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
 * Base class for all actionscript opcodes
 * @author Clement Wong
 */
public class Action implements ActionConstants
{
    public Action(int code)
    {
        this.code = code;
    }

	public final int code;

	/**
	 * Subclasses implement this method to callback one of the methods in ActionHandler...
	 * @param h
	 */
	public void visit(ActionHandler h)
    {
        switch (code)
        {
        case sactionNextFrame: h.nextFrame(this); break;
        case sactionPrevFrame: h.prevFrame(this); break;
        case sactionPlay: h.play(this); break;
        case sactionStop: h.stop(this); break;
        case sactionToggleQuality: h.toggleQuality(this); break;
        case sactionStopSounds: h.stopSounds(this); break;
        case sactionAdd: h.add(this); break;
        case sactionSubtract: h.subtract(this); break;
        case sactionMultiply: h.multiply(this); break;
        case sactionDivide: h.divide(this); break;
        case sactionEquals: h.equals(this); break;
        case sactionLess: h.less(this); break;
        case sactionAnd: h.and(this); break;
        case sactionOr: h.or(this); break;
        case sactionNot: h.not(this); break;
        case sactionStringEquals: h.stringEquals(this); break;
        case sactionStringLength: h.stringLength(this); break;
        case sactionStringExtract: h.stringExtract(this); break;
        case sactionPop: h.pop(this); break;
        case sactionToInteger: h.toInteger(this); break;
        case sactionGetVariable: h.getVariable(this); break;
        case sactionSetVariable: h.setVariable(this); break;
        case sactionSetTarget2: h.setTarget2(this); break;
        case sactionStringAdd: h.stringAdd(this); break;
        case sactionGetProperty: h.getProperty(this); break;
        case sactionSetProperty: h.setProperty(this); break;
        case sactionCloneSprite: h.cloneSprite(this); break;
        case sactionRemoveSprite: h.removeSprite(this); break;
        case sactionTrace: h.trace(this); break;
        case sactionStartDrag: h.startDrag(this); break;
        case sactionEndDrag: h.endDrag(this); break;
        case sactionStringLess: h.stringLess(this); break;
        case sactionThrow: h.throwAction(this); break;
        case sactionCastOp: h.castOp(this); break;
        case sactionImplementsOp: h.implementsOp(this); break;
        case sactionRandomNumber: h.randomNumber(this); break;
        case sactionMBStringLength: h.mbStringLength(this); break;
        case sactionCharToAscii: h.charToASCII(this); break;
        case sactionAsciiToChar: h.asciiToChar(this); break;
        case sactionGetTime: h.getTime(this); break;
        case sactionMBStringExtract: h.mbStringExtract(this); break;
        case sactionMBCharToAscii: h.mbCharToASCII(this); break;
        case sactionMBAsciiToChar: h.mbASCIIToChar(this); break;
        case sactionDelete: h.delete(this); break;
        case sactionDelete2: h.delete2(this); break;
        case sactionDefineLocal: h.defineLocal(this); break;
        case sactionCallFunction: h.callFunction(this); break;
        case sactionReturn: h.returnAction(this); break;
        case sactionModulo: h.modulo(this); break;
        case sactionNewObject: h.newObject(this); break;
        case sactionDefineLocal2: h.defineLocal2(this); break;
        case sactionInitArray: h.initArray(this); break;
        case sactionInitObject: h.initObject(this); break;
        case sactionTypeOf: h.typeOf(this); break;
        case sactionTargetPath: h.targetPath(this); break;
        case sactionEnumerate: h.enumerate(this); break;
        case sactionAdd2: h.add2(this); break;
        case sactionLess2: h.less2(this); break;
        case sactionEquals2: h.equals2(this); break;
        case sactionToNumber: h.toNumber(this); break;
        case sactionToString: h.toString(this); break;
        case sactionPushDuplicate: h.pushDuplicate(this); break;
        case sactionStackSwap: h.stackSwap(this); break;
        case sactionGetMember: h.getMember(this); break;
        case sactionSetMember: h.setMember(this); break;
        case sactionIncrement: h.increment(this); break;
        case sactionDecrement: h.decrement(this); break;
        case sactionCallMethod: h.callMethod(this); break;
        case sactionNewMethod: h.newMethod(this); break;
        case sactionInstanceOf: h.instanceOf(this); break;
        case sactionEnumerate2: h.enumerate2(this); break;
        case sactionBitAnd: h.bitAnd(this); break;
        case sactionBitOr: h.bitOr(this); break;
        case sactionBitXor: h.bitXor(this); break;
        case sactionBitLShift: h.bitLShift(this); break;
        case sactionBitRShift: h.bitRShift(this); break;
        case sactionBitURShift: h.bitURShift(this); break;
        case sactionStrictEquals: h.strictEquals(this); break;
        case sactionGreater: h.greater(this); break;
        case sactionStringGreater: h.stringGreater(this); break;
		case sactionCall: h.call(this); break;
		case sactionQuickTime: h.quickTime(this); break;
        case sactionExtends: h.extendsOp(this); break;
        case sactionNop: h.nop(this); break;
        case sactionHalt: h.halt(this); break;
        default:
            assert false : ("unexpected action "+code);// should not get here
        }
    }

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof Action)
        {
            Action action = (Action) object;

            if (action.code == this.code)
            {
                isEqual = true;
            }
        }

        return isEqual;
    }

    protected boolean equals(Object a, Object b)
    {
        return a == b || a != null && a.equals(b);
    }

    public int hashCode()
    {
        return code;
    }

    public int objectHashCode()
    {
        return super.hashCode();
    }

    public String toString()
    {
        return getClass().getName() + "[ code = " + code + " ]";
    }
}
