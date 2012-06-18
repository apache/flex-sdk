/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package macromedia.asc.embedding.avmplus;

/**
 * RuntimeConstants
 *
 * @author Jeff Dyer
 */

// ISSUE: This file needs to be renamed since everything
// in it except for maybe var_indexes are allocated and
// used by the compiler. The back-end allocates and uses
// the physical addresses like var offsets and logical
// addresses like operand ids and method ids.
public class RuntimeConstants
{
    public static final boolean HAS_IF_false = true;
    public static final boolean HAS_IF_true = true;
    public static final boolean HAS_IF_lt = true;
    public static final boolean HAS_IF_lti = false;
    public static final boolean HAS_IF_le = true;
    public static final boolean HAS_IF_gt = true;
    public static final boolean HAS_IF_ge = true;
    public static final boolean HAS_IF_gei = false;
    public static final boolean HAS_IF_eq = true;
    public static final boolean HAS_IF_ne = true;
    public static final boolean HAS_IF_stricteq = true;
    public static final boolean HAS_IF_strictne = true;
    public static final boolean HAS_IF_nlt = true;
    public static final boolean HAS_IF_nle = true;
    public static final boolean HAS_IF_ngt = true;
    public static final boolean HAS_IF_nge = true;

    public static final int IF_false = 0;
    public static final int IF_true = IF_false + 1;
    public static final int IF_lt = IF_true + 1;
    public static final int IF_lti = IF_lt + 1;
    public static final int IF_le = IF_lti + 1;
    public static final int IF_gt = IF_le + 1;
    public static final int IF_ge = IF_gt + 1;
    public static final int IF_gei = IF_ge + 1;
    public static final int IF_eq = IF_gei + 1;
    public static final int IF_ne = IF_eq + 1;
    public static final int IF_stricteq = IF_ne + 1;
    public static final int IF_strictne = IF_stricteq + 1;
    public static final int IF_nlt = IF_strictne + 1;
    public static final int IF_nle = IF_nlt + 1;
    public static final int IF_ngt = IF_nle + 1;
    public static final int IF_nge = IF_ngt + 1;

    public static final int FUNC_method = 0;
	public static final int FUNC_getter = FUNC_method + 1;
	public static final int FUNC_setter = FUNC_method + 2;
	public static final int FUNC_cinit = FUNC_method + 3;
	public static final int FUNC_iinit = FUNC_method + 4;
	public static final int FUNC_unbound = FUNC_method + 5;

	public static final int TYPE_boolean = 0x1 << 0;
	public static final int TYPE_number = 0x1 << 1;
	public static final int TYPE_string = 0x1 << 2;
	public static final int TYPE_null = 0x1 << 4;
	public static final int TYPE_bool = 0x1 << 5;
	public static final int TYPE_double = 0x1 << 6;
	public static final int TYPE_type = 0x1 << 7;
    public static final int TYPE_int = 0x1 << 8;
 	/* cn: TYPE_uint == TYPE_int for internal purposes.  Compare against cx.uintType() if you really need to know the diff */
	public static final int TYPE_uint = 0x1 << 9;
	//public static final int TYPE_uint = TYPE_int;	  
	public static final int TYPE_uint_external = 0x1 << 9;  // for CodeGenerator to use.

    public static final int TYPE_void = 0x1 << 10;
    public static final int TYPE_function = 0x1 << 11;
    public static final int TYPE_array = 0x1 << 12;
    public static final int TYPE_object = 0x1 << 13;
    public static final int TYPE_xml = 0x1 << 14;
    public static final int TYPE_none = 0x1 << 15;
    public static final int TYPE_decimal = 0x1 << 16;

    public static final String typeToString(int type_id)
	{
		switch (type_id)
		{
			case TYPE_boolean:
				return "boolean";
			case TYPE_number:
				return "number";
			case TYPE_string:
				return "string";
			case TYPE_null:
				return "null";
			case TYPE_int:
				return "int";
			case TYPE_double:
				return "double";
			case TYPE_type:
				return "type";
            case TYPE_object:
                return "object";
            case TYPE_none:
                return "*";
            case TYPE_bool:
				return "bool";
			case TYPE_void:
				return "void";
			case TYPE_function:
				return "function";
            case TYPE_array:
                return "array";
			case TYPE_decimal:
				return "decimal";
			///* cn: TYPE_uint == TYPE_int for internal purposes.  Compare against cx.uintType() if you really need to know the diff
			case TYPE_uint:
                return "uint";
			//*/
            default:
				return "unknown type";
		}
	}

	public static final boolean AVMPLUS = true; //System.getProperty("AVMPLUS") != null;
	public static final boolean SWF = System.getProperty("SWF") != null;
	public static final boolean JVM = System.getProperty("JVM") != null;

	/*
	 * Object vars & slots
	 */

	// enum {
	// No VAR_INDEX
	// };

	/*
	 * Global vars & slots
	 */

	public static final int VAR_INDEX_Global_Object = 0;
	public static final int VAR_INDEX_Global_Array = VAR_INDEX_Global_Object + 1;
	public static final int VAR_INDEX_Global_print = VAR_INDEX_Global_Object + 2;

	// Slot indexes are unique for each name and signature
	// in a particular scope.

	public static final int SLOT_Global_start = -2;
	public static final int SLOT_Global_DeleteOp = SLOT_Global_start;
	public static final int SLOT_Global_VoidOp = SLOT_Global_DeleteOp - 1;
	public static final int SLOT_Global_TypeofOp = SLOT_Global_VoidOp - 1;
	public static final int SLOT_Global_TypeofOp_B = SLOT_Global_TypeofOp - 1;
	public static final int SLOT_Global_TypeofOp_I = SLOT_Global_TypeofOp_B - 1;
	public static final int SLOT_Global_TypeofOp_N = SLOT_Global_TypeofOp_I - 1;
	public static final int SLOT_Global_TypeofOp_S = SLOT_Global_TypeofOp_N - 1;
	public static final int SLOT_Global_TypeofOp_U = SLOT_Global_TypeofOp_S - 1;
	public static final int SLOT_Global_IncrementOp = SLOT_Global_TypeofOp_U - 1;
    public static final int SLOT_Global_IncrementOp_I = SLOT_Global_IncrementOp - 1;
	public static final int SLOT_Global_IncrementLocalOp = SLOT_Global_IncrementOp_I - 1;
	public static final int SLOT_Global_IncrementLocalOp_I = SLOT_Global_IncrementLocalOp - 1;
	public static final int SLOT_Global_DecrementOp = SLOT_Global_IncrementLocalOp_I - 1;
	public static final int SLOT_Global_DecrementOp_I = SLOT_Global_DecrementOp - 1;
	public static final int SLOT_Global_DecrementLocalOp = SLOT_Global_DecrementOp_I - 1;
	public static final int SLOT_Global_DecrementLocalOp_I = SLOT_Global_DecrementLocalOp - 1;
	public static final int SLOT_Global_UnaryPlusOp = SLOT_Global_DecrementLocalOp_I - 1;
	public static final int SLOT_Global_UnaryPlusOp_I = SLOT_Global_UnaryPlusOp - 1;
	public static final int SLOT_Global_UnaryPlusOp_M = SLOT_Global_UnaryPlusOp_I - 1;
	public static final int SLOT_Global_BinaryPlusOp = SLOT_Global_UnaryPlusOp_M - 1;
	//public static final int SLOT_Global_BinaryPlusOp_II = SLOT_Global_BinaryPlusOp - 1;
	public static final int SLOT_Global_UnaryMinusOp = SLOT_Global_BinaryPlusOp - 1;
	public static final int SLOT_Global_UnaryMinusOp_I = SLOT_Global_UnaryMinusOp - 1;
	public static final int SLOT_Global_BinaryMinusOp = SLOT_Global_UnaryMinusOp_I - 1;
	//public static final int SLOT_Global_BinaryMinusOp_II = SLOT_Global_BinaryMinusOp - 1;
	public static final int SLOT_Global_BitwiseNotOp = SLOT_Global_BinaryMinusOp - 1;
	public static final int SLOT_Global_BitwiseNotOp_I = SLOT_Global_BitwiseNotOp - 1;
	public static final int SLOT_Global_LogicalNotOp = SLOT_Global_BitwiseNotOp_I - 1;
    public static final int SLOT_Global_LogicalNotOp_B = SLOT_Global_LogicalNotOp - 1;
    public static final int SLOT_Global_LogicalNotOp_I = SLOT_Global_LogicalNotOp_B - 1;
    public static final int SLOT_Global_MultiplyOp = SLOT_Global_LogicalNotOp_I - 1;
	//public static final int SLOT_Global_MultiplyOp_II = SLOT_Global_MultiplyOp - 1;
	public static final int SLOT_Global_DivideOp = SLOT_Global_MultiplyOp - 1;
	public static final int SLOT_Global_ModulusOp = SLOT_Global_DivideOp - 1;
	public static final int SLOT_Global_LeftShiftOp = SLOT_Global_ModulusOp - 1;
	public static final int SLOT_Global_LeftShiftOp_II = SLOT_Global_LeftShiftOp - 1;
	public static final int SLOT_Global_RightShiftOp = SLOT_Global_LeftShiftOp_II - 1;
	public static final int SLOT_Global_RightShiftOp_II = SLOT_Global_RightShiftOp - 1;
	public static final int SLOT_Global_UnsignedRightShiftOp = SLOT_Global_RightShiftOp_II - 1;
	public static final int SLOT_Global_UnsignedRightShiftOp_II = SLOT_Global_UnsignedRightShiftOp - 1;
	public static final int SLOT_Global_LessThanOp = SLOT_Global_UnsignedRightShiftOp_II - 1;
	public static final int SLOT_Global_GreaterThanOp = SLOT_Global_LessThanOp - 1;
	public static final int SLOT_Global_LessThanOrEqualOp = SLOT_Global_GreaterThanOp - 1;
	public static final int SLOT_Global_GreaterThanOrEqualOp = SLOT_Global_LessThanOrEqualOp - 1;
	public static final int SLOT_Global_InstanceofOp = SLOT_Global_GreaterThanOrEqualOp - 1;
	public static final int SLOT_Global_InOp = SLOT_Global_InstanceofOp - 1;
	public static final int SLOT_Global_IsOp = SLOT_Global_InOp - 1;
	public static final int SLOT_Global_IsLateOp = SLOT_Global_IsOp - 1;
	public static final int SLOT_Global_EqualsOp = SLOT_Global_IsLateOp - 1;
	public static final int SLOT_Global_EqualsOp_II = SLOT_Global_EqualsOp - 1;
	public static final int SLOT_Global_NotEqualsOp = SLOT_Global_EqualsOp_II - 1;
	public static final int SLOT_Global_NotEqualsOp_II = SLOT_Global_NotEqualsOp - 1;
	public static final int SLOT_Global_StrictEqualsOp = SLOT_Global_NotEqualsOp_II - 1;
	public static final int SLOT_Global_StrictEqualsOp_II = SLOT_Global_StrictEqualsOp - 1;
	public static final int SLOT_Global_StrictNotEqualsOp = SLOT_Global_StrictEqualsOp_II - 1;
	public static final int SLOT_Global_StrictNotEqualsOp_II = SLOT_Global_StrictNotEqualsOp - 1;
	public static final int SLOT_Global_BitwiseAndOp = SLOT_Global_StrictNotEqualsOp_II - 1;
	public static final int SLOT_Global_BitwiseAndOp_II = SLOT_Global_BitwiseAndOp - 1;
	public static final int SLOT_Global_BitwiseXorOp = SLOT_Global_BitwiseAndOp_II - 1;
	public static final int SLOT_Global_BitwiseXorOp_II = SLOT_Global_BitwiseXorOp - 1;
	public static final int SLOT_Global_BitwiseOrOp = SLOT_Global_BitwiseXorOp_II - 1;
	public static final int SLOT_Global_BitwiseOrOp_II = SLOT_Global_BitwiseOrOp - 1;
	public static final int SLOT_Global_LogicalAndOp = SLOT_Global_BitwiseOrOp_II - 1;
	public static final int SLOT_Global_LogicalAndOp_II = SLOT_Global_LogicalAndOp - 1;
	public static final int SLOT_Global_LogicalOrOp = SLOT_Global_LogicalAndOp_II - 1;
	public static final int SLOT_Global_LogicalOrOp_II = SLOT_Global_LogicalOrOp - 1;
	public static final int SLOT_Global__cv = SLOT_Global_LogicalOrOp_II - 1;
    public static final int SLOT_Global_AsOp = SLOT_Global__cv - 1;
    public static final int SLOT_Global_AsLateOp = SLOT_Global_AsOp - 1;
	public static final int SLOT_Global_TypeofOp_D = SLOT_Global_AsLateOp - 1;	
	public static final int SLOT_Global_TypeofOp_M = SLOT_Global_TypeofOp_D - 1;	

	// Unary indexes are unique for each unary operator and
	// operand type.

	public static final int UNARY_Call = 0;
	public static final int UNARY_Construct = UNARY_Call + 1;
	public static final int UNARY_Put = UNARY_Construct + 1;
	public static final int UNARY_Get = UNARY_Put + 1;
	public static final int UNARY_HasMoreNames = UNARY_Get + 1;
	public static final int UNARY_NextName = UNARY_HasMoreNames + 1;
    public static final int UNARY_NextValue = UNARY_NextName + 1;
    public static final int UNARY_DescendOp = UNARY_NextValue + 1;
    public static final int UNARY_reserved2 = UNARY_DescendOp + 1;
	public static final int UNARY_NewOp = UNARY_reserved2 + 1;
	public static final int UNARY_DeleteOp = UNARY_NewOp + 1;
	public static final int UNARY_VoidOp = UNARY_DeleteOp + 1;
	public static final int UNARY_TypeofOp = UNARY_VoidOp + 1;
	public static final int UNARY_TypeofOp_B = UNARY_TypeofOp + 1;
	public static final int UNARY_TypeofOp_I = UNARY_TypeofOp_B + 1;
	public static final int UNARY_TypeofOp_N = UNARY_TypeofOp_I + 1;
	public static final int UNARY_TypeofOp_S = UNARY_TypeofOp_N + 1;
	public static final int UNARY_TypeofOp_U = UNARY_TypeofOp_S + 1;
	public static final int UNARY_IncrementOp = UNARY_TypeofOp_U + 1;
	public static final int UNARY_IncrementLocalOp = UNARY_IncrementOp + 1;
	public static final int UNARY_IncrementOp_I = UNARY_IncrementLocalOp + 1;
    public static final int UNARY_IncrementLocalOp_I = UNARY_IncrementOp_I + 1;
	public static final int UNARY_DecrementOp = UNARY_IncrementLocalOp_I + 1;
	public static final int UNARY_DecrementLocalOp = UNARY_DecrementOp + 1;
	public static final int UNARY_DecrementOp_I = UNARY_DecrementLocalOp + 1;
	public static final int UNARY_DecrementLocalOp_I = UNARY_DecrementOp_I + 1;
	public static final int UNARY_UnaryPlusOp = UNARY_DecrementLocalOp_I + 1;
	public static final int UNARY_UnaryPlusOp_I = UNARY_UnaryPlusOp + 1;
	public static final int UNARY_UnaryPlusOp_M = UNARY_UnaryPlusOp_I + 1;
	public static final int UNARY_UnaryMinusOp = UNARY_UnaryPlusOp_M + 1;
	public static final int UNARY_UnaryMinusOp_I = UNARY_UnaryMinusOp + 1;
	public static final int UNARY_BitwiseNotOp = UNARY_UnaryMinusOp_I + 1;
	public static final int UNARY_BitwiseNotOp_I = UNARY_BitwiseNotOp + 1;
	public static final int UNARY_LogicalNotOp = UNARY_BitwiseNotOp_I + 1;
	public static final int UNARY_LogicalNotOp_B = UNARY_LogicalNotOp + 1;
	public static final int UNARY_LogicalNotOp_I = UNARY_LogicalNotOp_B + 1;
    public static final int UNARY_ToXMLString = UNARY_LogicalNotOp_I + 1;
    public static final int UNARY_ToXMLAttrString = UNARY_ToXMLString + 1;
    public static final int UNARY_CheckFilterOp = UNARY_ToXMLAttrString + 1;
	public static final int UNARY_TypeofOp_D = UNARY_CheckFilterOp + 1;
	public static final int UNARY_TypeofOp_M = UNARY_TypeofOp_D + 1;
    public static final int UNARY_NumberOfOpCodes = UNARY_TypeofOp_M + 1;

	// Binary indexes are unique for each binary operator and
	// operand types.

	public static final int BINARY_BinaryPlusOp = 0;
	public static final int BINARY_BinaryPlusOp_II = BINARY_BinaryPlusOp + 1;
	public static final int BINARY_BinaryMinusOp = BINARY_BinaryPlusOp + 2;
	public static final int BINARY_BinaryMinusOp_II = BINARY_BinaryPlusOp + 3;
	public static final int BINARY_MultiplyOp = BINARY_BinaryPlusOp + 4;
	public static final int BINARY_MultiplyOp_II = BINARY_BinaryPlusOp + 5;
	public static final int BINARY_DivideOp = BINARY_BinaryPlusOp + 6;
	public static final int BINARY_ModulusOp = BINARY_BinaryPlusOp + 8;
	public static final int BINARY_LeftShiftOp = BINARY_BinaryPlusOp + 10;
	public static final int BINARY_LeftShiftOp_II = BINARY_BinaryPlusOp + 11;
	public static final int BINARY_RightShiftOp = BINARY_BinaryPlusOp + 12;
	public static final int BINARY_RightShiftOp_II = BINARY_BinaryPlusOp + 13;
	public static final int BINARY_UnsignedRightShiftOp = BINARY_BinaryPlusOp + 14;
	public static final int BINARY_UnsignedRightShiftOp_II = BINARY_BinaryPlusOp + 15;
	public static final int BINARY_LessThanOp = BINARY_BinaryPlusOp + 16;
	public static final int BINARY_GreaterThanOp = BINARY_BinaryPlusOp + 18;
	public static final int BINARY_LessThanOrEqualOp = BINARY_BinaryPlusOp + 20;
	public static final int BINARY_GreaterThanOrEqualOp = BINARY_BinaryPlusOp + 22;
	public static final int BINARY_InstanceofOp = BINARY_BinaryPlusOp + 24;
	public static final int BINARY_InOp = BINARY_BinaryPlusOp + 25;
	public static final int BINARY_IsOp = BINARY_BinaryPlusOp + 26;
	public static final int BINARY_IsLateOp = BINARY_BinaryPlusOp + 27;
	public static final int BINARY_EqualsOp = BINARY_BinaryPlusOp + 28;
	public static final int BINARY_EqualsOp_II = BINARY_BinaryPlusOp + 29;
	public static final int BINARY_NotEqualsOp = BINARY_BinaryPlusOp + 30;
	public static final int BINARY_NotEqualsOp_II = BINARY_BinaryPlusOp + 31;
	public static final int BINARY_StrictEqualsOp = BINARY_BinaryPlusOp + 32;
	public static final int BINARY_StrictEqualsOp_II = BINARY_BinaryPlusOp + 33;
	public static final int BINARY_StrictNotEqualsOp = BINARY_BinaryPlusOp + 34;
	public static final int BINARY_StrictNotEqualsOp_II = BINARY_BinaryPlusOp + 35;
	public static final int BINARY_BitwiseAndOp = BINARY_BinaryPlusOp + 36;
	public static final int BINARY_BitwiseAndOp_II = BINARY_BinaryPlusOp + 37;
	public static final int BINARY_BitwiseXorOp = BINARY_BinaryPlusOp + 38;
	public static final int BINARY_BitwiseXorOp_II = BINARY_BinaryPlusOp + 39;
	public static final int BINARY_BitwiseOrOp = BINARY_BinaryPlusOp + 40;
	public static final int BINARY_BitwiseOrOp_II = BINARY_BinaryPlusOp + 41;
	public static final int BINARY_LogicalAndOp = BINARY_BinaryPlusOp + 42;
	public static final int BINARY_LogicalAndOp_II = BINARY_BinaryPlusOp + 43;
	public static final int BINARY_LogicalAndOp_BB = BINARY_BinaryPlusOp + 44;
	public static final int BINARY_LogicalOrOp = BINARY_BinaryPlusOp + 45;
	public static final int BINARY_LogicalOrOp_II = BINARY_BinaryPlusOp + 46;
	public static final int BINARY_LogicalOrOp_BB = BINARY_BinaryPlusOp + 47;
    public static final int BINARY_AsOp = BINARY_BinaryPlusOp + 48;
    public static final int BINARY_AsLateOp = BINARY_BinaryPlusOp + 49;
	public static final int BINARY_NumberOfOpCodes = BINARY_AsLateOp + 1;

	public static final int getUnaryOp(int slot_index)
	{
		switch (slot_index)
		{
			case SLOT_Global_DeleteOp:
				return UNARY_DeleteOp;
			case SLOT_Global_VoidOp:
				return UNARY_VoidOp;
			case SLOT_Global_TypeofOp:
				return UNARY_TypeofOp;
			case SLOT_Global_TypeofOp_B:
				return UNARY_TypeofOp_B;
			case SLOT_Global_TypeofOp_I:
				return UNARY_TypeofOp_I;
			case SLOT_Global_TypeofOp_D:
				return UNARY_TypeofOp_D;
			case SLOT_Global_TypeofOp_M:
				return UNARY_TypeofOp_M;
			case SLOT_Global_TypeofOp_S:
				return UNARY_TypeofOp_S;
			case SLOT_Global_TypeofOp_U:
				return UNARY_TypeofOp_U;
			case SLOT_Global_IncrementOp:
				return UNARY_IncrementOp;
			case SLOT_Global_IncrementOp_I:
				return UNARY_IncrementOp_I;
			case SLOT_Global_IncrementLocalOp:
				return UNARY_IncrementLocalOp;
			case SLOT_Global_IncrementLocalOp_I:
				return UNARY_IncrementLocalOp_I;
			case SLOT_Global_DecrementOp:
				return UNARY_DecrementOp;
			case SLOT_Global_DecrementOp_I:
				return UNARY_DecrementOp_I;
			case SLOT_Global_DecrementLocalOp:
				return UNARY_DecrementLocalOp;
			case SLOT_Global_DecrementLocalOp_I:
				return UNARY_DecrementLocalOp_I;
			case SLOT_Global_UnaryPlusOp:
				return UNARY_UnaryPlusOp;
			case SLOT_Global_UnaryPlusOp_I:
				return UNARY_UnaryPlusOp_I;
			case SLOT_Global_UnaryPlusOp_M:
				return UNARY_UnaryPlusOp_M;
			case SLOT_Global_UnaryMinusOp:
				return UNARY_UnaryMinusOp;
			case SLOT_Global_UnaryMinusOp_I:
				return UNARY_UnaryMinusOp_I;
			case SLOT_Global_BitwiseNotOp:
				return UNARY_BitwiseNotOp;
			case SLOT_Global_BitwiseNotOp_I:
				return UNARY_BitwiseNotOp_I;
			case SLOT_Global_LogicalNotOp:
				return UNARY_LogicalNotOp;
            case SLOT_Global_LogicalNotOp_B:
                return UNARY_LogicalNotOp_B;
            case SLOT_Global_LogicalNotOp_I:
                return UNARY_LogicalNotOp_I;
            default:
				if (slot_index <= SLOT_Global_start)
				{
					return slot_index;
				}
				assert(false); // throw "invalid unary slot index";
				return -1; // C: remove this and throw an exception
		}
	}

	public static final int getBinaryOp(int slot_index)
	{
		switch (slot_index)
		{
			case SLOT_Global_BinaryPlusOp:
				return BINARY_BinaryPlusOp;
			//case SLOT_Global_BinaryPlusOp_II:
			//	return BINARY_BinaryPlusOp_II;
			case SLOT_Global_BinaryMinusOp:
				return BINARY_BinaryMinusOp;
			//case SLOT_Global_BinaryMinusOp_II:
			//	return BINARY_BinaryMinusOp_II;
			case SLOT_Global_MultiplyOp:
				return BINARY_MultiplyOp;
			//case SLOT_Global_MultiplyOp_II:
			//	return BINARY_MultiplyOp_II;
			case SLOT_Global_DivideOp:
				return BINARY_DivideOp;
			case SLOT_Global_ModulusOp:
				return BINARY_ModulusOp;
			case SLOT_Global_LeftShiftOp:
				return BINARY_LeftShiftOp;
			case SLOT_Global_LeftShiftOp_II:
				return BINARY_LeftShiftOp_II;
			case SLOT_Global_RightShiftOp:
				return BINARY_RightShiftOp;
			case SLOT_Global_RightShiftOp_II:
				return BINARY_RightShiftOp_II;
			case SLOT_Global_UnsignedRightShiftOp:
				return BINARY_UnsignedRightShiftOp;
			case SLOT_Global_UnsignedRightShiftOp_II:
				return BINARY_UnsignedRightShiftOp_II;
			case SLOT_Global_LessThanOp:
				return BINARY_LessThanOp;
			case SLOT_Global_GreaterThanOp:
				return BINARY_GreaterThanOp;
			case SLOT_Global_LessThanOrEqualOp:
				return BINARY_LessThanOrEqualOp;
			case SLOT_Global_GreaterThanOrEqualOp:
				return BINARY_GreaterThanOrEqualOp;
			case SLOT_Global_InstanceofOp:
				return BINARY_InstanceofOp;
			case SLOT_Global_InOp:
				return BINARY_InOp;
			case SLOT_Global_IsOp:
	              return BINARY_IsOp;
	        case SLOT_Global_IsLateOp:
	              return BINARY_IsLateOp;
			case SLOT_Global_AsOp:
	              return BINARY_AsOp;
	        case SLOT_Global_AsLateOp:
	              return BINARY_AsLateOp;
			case SLOT_Global_EqualsOp:
				return BINARY_EqualsOp;
			case SLOT_Global_EqualsOp_II:
				return BINARY_EqualsOp_II;
			case SLOT_Global_NotEqualsOp:
				return BINARY_NotEqualsOp;
			case SLOT_Global_NotEqualsOp_II:
				return BINARY_NotEqualsOp_II;
			case SLOT_Global_StrictEqualsOp:
				return BINARY_StrictEqualsOp;
			case SLOT_Global_StrictEqualsOp_II:
				return BINARY_StrictEqualsOp_II;
			case SLOT_Global_StrictNotEqualsOp:
				return BINARY_StrictNotEqualsOp;
			case SLOT_Global_StrictNotEqualsOp_II:
				return BINARY_StrictNotEqualsOp_II;
			case SLOT_Global_BitwiseAndOp:
				return BINARY_BitwiseAndOp;
			case SLOT_Global_BitwiseAndOp_II:
				return BINARY_BitwiseAndOp_II;
			case SLOT_Global_BitwiseXorOp:
				return BINARY_BitwiseXorOp;
			case SLOT_Global_BitwiseXorOp_II:
				return BINARY_BitwiseXorOp_II;
			case SLOT_Global_BitwiseOrOp:
				return BINARY_BitwiseOrOp;
			case SLOT_Global_BitwiseOrOp_II:
				return BINARY_BitwiseOrOp_II;
			case SLOT_Global_LogicalAndOp:
				return BINARY_LogicalAndOp;
			case SLOT_Global_LogicalAndOp_II:
				return BINARY_LogicalAndOp_II;
			case SLOT_Global_LogicalOrOp:
				return BINARY_LogicalOrOp;
			case SLOT_Global_LogicalOrOp_II:
				return BINARY_LogicalOrOp_II;
			default:
				if (slot_index <= SLOT_Global_start)
				{
					return slot_index;
				}
				assert(false); // throw "invalid binary slot index";
				return -1;
		}
	}

	public static final int METHOD_Object_get = 0;
	public static final int METHOD_Object_call = METHOD_Object_get + 1;
	public static final int METHOD_Object_construct = METHOD_Object_get + 2;
	public static final int METHOD_Array_get = METHOD_Object_get + 3;
	public static final int METHOD_Array_call = METHOD_Object_get + 4;
	public static final int METHOD_Array_construct = METHOD_Object_get + 5;
	public static final int METHOD_String_get = METHOD_Object_get + 6;
	public static final int METHOD_String_call = METHOD_Object_get + 7;
	public static final int METHOD_String_construct = METHOD_Object_get + 8;
	public static final int METHOD_print_call = METHOD_Object_get + 9;
	public static final int METHOD_trace_call = METHOD_Object_get + 10;
	public static final int METHOD_int_call = METHOD_Object_get + 11;
	public static final int METHOD_Global_getTimer_call = METHOD_Object_get + 12;

	// !!@ WLS added below

	public static final int METHOD_Global_GotoAndPlay_call = 1000; // !!@ hack to get move these
	// high into the number space so we don't conflict with new functions.  For
	// every function on this list, we need a space in GlobalBuilder to
	// handle these correctly.  Otherwise AS functions conflict with
	// these built in functions
	public static final int METHOD_Global_GotoAndStop_call = METHOD_Global_GotoAndPlay_call + 1;
	public static final int METHOD_Global_nextFrame_call = METHOD_Global_GotoAndPlay_call + 2; // nextScene code
	public static final int METHOD_Global_prevFrame_call = METHOD_Global_GotoAndPlay_call + 3; // prevScene code

	public static final int METHOD_Global_toggleQuality_call = METHOD_Global_GotoAndPlay_call + 4;
	public static final int METHOD_Global_stopSounds_call = METHOD_Global_GotoAndPlay_call + 5;
	public static final int METHOD_Global_play_call = METHOD_Global_GotoAndPlay_call + 6;
	public static final int METHOD_Global_stop_call = METHOD_Global_GotoAndPlay_call + 7;
	public static final int METHOD_Global_fsCommand_call = METHOD_Global_GotoAndPlay_call + 8;
	public static final int METHOD_Global_print_call = METHOD_Global_GotoAndPlay_call + 9;
	public static final int METHOD_Global_printAsBitmap_call = METHOD_Global_GotoAndPlay_call + 10;
	public static final int METHOD_Global_printNum_call = METHOD_Global_GotoAndPlay_call + 11;
	public static final int METHOD_Global_printAsBitmapNum_call = METHOD_Global_GotoAndPlay_call + 12;
	public static final int METHOD_Global_trace_call = METHOD_Global_GotoAndPlay_call + 13;

	public static final int METHOD_Global_startDrag_call = METHOD_Global_GotoAndPlay_call + 14;
	public static final int METHOD_Global_stopDrag_call = METHOD_Global_GotoAndPlay_call + 15;

	public static final int METHOD_Global_duplicateMovieClip_call = METHOD_Global_GotoAndPlay_call + 16;
	public static final int METHOD_Global_removeMovieClip_call = METHOD_Global_GotoAndPlay_call + 17;

	public static final int METHOD_Global_set_call = METHOD_Global_GotoAndPlay_call + 18;
	public static final int METHOD_Global_setProperty_call = METHOD_Global_GotoAndPlay_call + 19;

	public static final int METHOD_Global_getURL_call = METHOD_Global_GotoAndPlay_call + 20;
	public static final int METHOD_Global_loadMovie_call = METHOD_Global_GotoAndPlay_call + 21;
	public static final int METHOD_Global_loadVariables_call = METHOD_Global_GotoAndPlay_call + 22;
	public static final int METHOD_Global_loadMovieNum_call = METHOD_Global_GotoAndPlay_call + 23;
	public static final int METHOD_Global_loadVariablesNum_call = METHOD_Global_GotoAndPlay_call + 24;

	public static final int METHOD_Global_unloadMovie_call = METHOD_Global_GotoAndPlay_call + 25;
	public static final int METHOD_Global_unloadMovieNum_call = METHOD_Global_GotoAndPlay_call + 26;

	public static final int METHOD_Global_call_call = METHOD_Global_GotoAndPlay_call + 27;

	public static final int METHOD_Global_get_call = METHOD_Global_GotoAndPlay_call + 28;
	public static final int METHOD_Global_eval_call = METHOD_Global_GotoAndPlay_call + 29;
	public static final int METHOD_Global_subString_call = METHOD_Global_GotoAndPlay_call + 30;
	public static final int METHOD_Global_mbsubString_call = METHOD_Global_GotoAndPlay_call + 31;
	public static final int METHOD_Global_int_call = METHOD_Global_GotoAndPlay_call + 32;
	public static final int METHOD_Global_length_call = METHOD_Global_GotoAndPlay_call + 33;
	public static final int METHOD_Global_mblength_call = METHOD_Global_GotoAndPlay_call + 34;
	public static final int METHOD_Global_random_call = METHOD_Global_GotoAndPlay_call + 35;
	public static final int METHOD_Global_getProperty_call = METHOD_Global_GotoAndPlay_call + 36;
	public static final int METHOD_Global_ord_call = METHOD_Global_GotoAndPlay_call + 37;
	public static final int METHOD_Global_chr_call = METHOD_Global_GotoAndPlay_call + 38;
	public static final int METHOD_Global_mbord_call = METHOD_Global_GotoAndPlay_call + 39;
	public static final int METHOD_Global_mbchr_call = METHOD_Global_GotoAndPlay_call + 40;
	public static final int METHOD_Global_getVersion_call = METHOD_Global_GotoAndPlay_call + 41;
	public static final int METHOD_Global_targetPath_call = METHOD_Global_GotoAndPlay_call + 42;
	public static final int METHOD_Global_number_call = METHOD_Global_GotoAndPlay_call + 43;
	public static final int METHOD_Global_string_call = METHOD_Global_GotoAndPlay_call + 44;

	public static final int METHOD_lastid = METHOD_int_call;
}
