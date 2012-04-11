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

package flex2.compiler.mxml.lang;

import flex2.compiler.SymbolTable;
import flex2.compiler.mxml.reflect.Type;
import flex2.compiler.mxml.reflect.TypeTable;

/**
 * This utility class contains Array coercion logic.
 */
public class TypeCompatibility
{
	public static final int Ok = 0;									//	rvalue type is assignable to lvalue type
	public static final int OkCoerceToArray = 1;					//	rvalue type is assignable to lvalue's array elem type
	public static final int OkCoerceToVector = 2;					//	rvalue type is assignable to lvalue's vector elem type
	public static final int ErrRTypeNotAssignableToLType = 3;		//	rvalue type is not assignable to lvalue type
	public static final int ErrLTypeNotMultiple = 4;				//	multiple rvalues, and lvalue type is not > Array
	public static final int ErrSingleRValueNotArrayOrArrayElem = 5;	//	rvalue type is not assignable to either lvalue type or lvalue's array elem type
	public static final int ErrMultiRValueNotArrayElem = 6;			//	multiple rvalues, and rvalue type is not assignable to lvalue's array elem type

	/**
	 * Check type compatibility modulo Array coercion, and return correctness result and necessary action.
	 * In a nutshell, the algorithm allows implicit array coercion if the lvalue type is either (a) exactly Array, or
	 * (b) a supertype of Array. The only variation between (a) and (b) comes when the rvalue is a singleton. In
	 * (a), a single rvalue is coerced to [rvalue]; in (b) it's left alone.
	 *
	 * <p>Algorithm:<pre>
	 * 	1. if lvalue type is <strong>exactly</strong> Array, then
	 * 		if rvalue is a singleton, then
	 * 			rvalue must either be a subtype of Array (ok), or
	 * 			rvalue must be a subtype of lvalue's array element type (coerce)
	 * 		else (rvalue is one of a collection)
	 * 			rvalue must be a subtype of lvalue's array element type (coerce)
	 * 	2. else if lvalue type is a <strong>supertype</strong> of Array, then
	 * 		if rvalue is a singleton, then
	 * 			rvalue must be a subtype of lvalue type (ok)
	 * 		if rvalue is one of a collection, then
	 * 			rvalue must be a subtype of lvalue's array element type (coerce)
	 * 	3. else (lvalue type is not Array or a supertype of Array), then
	 * 		rvalue must be a singleton, and rvalue type must be a subtype of lvalue type (ok)
	 * </pre>
	 */
	public static int check(Type lvalueType, Type lvalueElementType, Type rvalueType, boolean rvalueIsSingleton, StandardDefs standardDefs)
	{
		TypeTable typeTable = lvalueType.getTypeTable();
		//	assert typeTable == rvalueType.getTypeTable();

		if (typeTable.arrayType.equals(lvalueType))
		{
			if (rvalueIsSingleton)
			{
				return rvalueType != null && rvalueType.isAssignableTo(typeTable.arrayType) ? Ok :
						checkSingleton(typeTable, lvalueElementType, rvalueType, standardDefs) ? OkCoerceToArray :
						ErrSingleRValueNotArrayOrArrayElem;
			}
			else
			{
				return checkSingleton(typeTable, lvalueElementType, rvalueType, standardDefs) ? OkCoerceToArray :
					ErrMultiRValueNotArrayElem;
			}
		}
        else if (lvalueType.getName().startsWith(SymbolTable.VECTOR))
        {
            if (rvalueIsSingleton)
            {
                return rvalueType != null && rvalueType.equals(lvalueType) ? Ok :
                    checkSingleton(typeTable, lvalueElementType, rvalueType, standardDefs) ? OkCoerceToVector :
                    ErrSingleRValueNotArrayOrArrayElem;
            }
            else
            {
                return checkSingleton(typeTable, lvalueElementType, rvalueType, standardDefs) ? OkCoerceToVector :
                    ErrMultiRValueNotArrayElem;
            }
        }
		else if (typeTable.arrayType.isAssignableTo(lvalueType))
		{
			if (rvalueIsSingleton)
			{
				return checkSingleton(typeTable, lvalueType, rvalueType, standardDefs) ? Ok :
					ErrRTypeNotAssignableToLType;
			}
			else
			{
				return checkSingleton(typeTable, lvalueElementType, rvalueType, standardDefs) ? OkCoerceToArray :
					ErrMultiRValueNotArrayElem;
			}
		}
		else
		{
			return !rvalueIsSingleton ? ErrLTypeNotMultiple :
					checkSingleton(typeTable, lvalueType, rvalueType, standardDefs) ? Ok :
					ErrRTypeNotAssignableToLType;
		}
	}

	/**
	 * Note that there is no special 'OkCoerceToFactory'. This is a somewhat cheap way to avoid handling the interplay
	 * between array and factory coercion here. It's possible because caller handles this case in a very simple way currently.
	 * TODO should revisit.
	 */
	private static boolean checkSingleton(TypeTable typeTable, Type ltype, Type rtype, StandardDefs standardDefs)
	{
		return (rtype != null) && (rtype.isAssignableTo(ltype) || (standardDefs.isIFactory(ltype) && rtype.equals(typeTable.classType)));
	}
}
