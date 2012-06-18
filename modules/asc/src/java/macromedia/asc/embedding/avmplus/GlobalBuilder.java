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

import macromedia.asc.semantics.ObjectValue;
import macromedia.asc.semantics.TypeValue;
import macromedia.asc.util.Context;
import macromedia.asc.util.Namespaces;
import macromedia.asc.semantics.Slot;
import static macromedia.asc.semantics.Slot.*;
import static macromedia.asc.embedding.avmplus.RuntimeConstants.*;

/**
 * Constructs global objects
 *
 * @author Jeff Dyer
 */
public class GlobalBuilder extends PackageBuilder
{
	public boolean is_in_package;

	// huge memory savings, if you suspect this is causing a bug just set to false
	public static final boolean useStaticBuiltins = true;
	
	public GlobalBuilder()
	{
		is_in_package = false;
	}

	public void build(Context cx, ObjectValue ob)
	{
		objectValue = ob;
		contextId = cx.getId();

        // force creation of builtin types we need to check against.  This must happen before global.abc is processed.
	    cx.typeType();
        cx.noType();  
        cx.objectType();  // force the initialization in the right order
        cx.arrayType();
        cx.functionType();
        cx.uintType();
        cx.stringType();
        cx.numberType();
        cx.doubleType();
        if (cx.statics.es4_numerics)
        	cx.decimalType();
        cx.nullType();
        cx.voidType();
        cx.xmlType();
		cx.xmlListType();
        cx.regExpType();
        cx.vectorType();
        cx.vectorObjType();

        if(useStaticBuiltins)
        {
	        if(cx.statics.globalPrototype == null)
	        {
	        	cx.statics.globalPrototype = new ObjectValue();
	        	initGlobalObject(cx, cx.statics.globalPrototype);
	        }
	        ob._proto_ = cx.statics.globalPrototype;
        } else {
        	initGlobalObject(cx, ob);        	
        }
        
		// _cv - A temporary that holds the internal value returned at the end of the script.
		//       We actually just use the top of the operand stack to store its value, but we
		//       need a way to reason about its type so we create a variable slot for it.
		ImplicitVar(cx, ob, "_cv", ObjectValue.internalNamespace, cx.noType(), SLOT_Global__cv, -1, -1);
		

        var_offset = 0;
        reg_offset = 1; // this, in global$init

	}

	private void initGlobalObject(Context cx, ObjectValue ob) {
		// delete
		UnaryOperator(cx, ob, cx.booleanType(), CALL_ThisUnary, SLOT_Global_DeleteOp);

		// void
		UnaryOperator(cx,ob,cx.noType(),CALL_Unary,SLOT_Global_VoidOp );


		// typeof
		UnaryOperator(cx, ob, cx.stringType(), CALL_Unary, SLOT_Global_TypeofOp);
		UnaryOverload(cx, ob, SLOT_Global_TypeofOp, cx.stringType(), cx.booleanType(), CALL_Empty, SLOT_Global_TypeofOp_B);
		UnaryOverload(cx, ob, SLOT_Global_TypeofOp, cx.stringType(), cx.intType(), CALL_Empty, SLOT_Global_TypeofOp_I);
		UnaryOverload(cx, ob, SLOT_Global_TypeofOp, cx.stringType(), cx.uintType(), CALL_Empty, SLOT_Global_TypeofOp_U);
		UnaryOverload(cx, ob, SLOT_Global_TypeofOp, cx.stringType(), cx.doubleType(), CALL_Empty, SLOT_Global_TypeofOp_D);
		if (cx.statics.es4_numerics)
			UnaryOverload(cx, ob, SLOT_Global_TypeofOp, cx.stringType(), cx.decimalType(), CALL_Empty, SLOT_Global_TypeofOp_M);
		UnaryOverload(cx, ob, SLOT_Global_TypeofOp, cx.stringType(), cx.stringType(), CALL_Empty, SLOT_Global_TypeofOp_S);
		UnaryOverload(cx,ob,SLOT_Global_TypeofOp,cx.stringType(),cx.voidType(),CALL_Empty,SLOT_Global_TypeofOp_U );

		// ++
		UnaryOperator(cx, ob, cx.doubleType(), CALL_Unary, SLOT_Global_IncrementOp);
        UnaryOverload(cx, ob, SLOT_Global_IncrementOp, cx.intType(), cx.intType(), CALL_Empty, SLOT_Global_IncrementOp_I);
        if (cx.statics.es4_numerics)
			UnaryOverload(cx, ob, SLOT_Global_IncrementOp, cx.decimalType(), cx.decimalType(), CALL_Empty, SLOT_Global_IncrementOp);
		UnaryOperator(cx, ob, cx.doubleType(), CALL_Unary, SLOT_Global_IncrementLocalOp);
        UnaryOverload(cx, ob, SLOT_Global_IncrementLocalOp, cx.intType(), cx.intType(), CALL_Empty, SLOT_Global_IncrementLocalOp_I);
        if (cx.statics.es4_numerics)
			UnaryOverload(cx, ob, SLOT_Global_IncrementLocalOp, cx.decimalType(), cx.decimalType(), CALL_Empty, SLOT_Global_IncrementLocalOp);

		// --
		UnaryOperator(cx, ob, cx.doubleType(), CALL_Unary, SLOT_Global_DecrementOp);
		if (cx.statics.es4_numerics)
			UnaryOverload(cx, ob, SLOT_Global_DecrementOp, cx.decimalType(), cx.decimalType(), CALL_Empty, SLOT_Global_DecrementOp);
        UnaryOverload(cx, ob, SLOT_Global_DecrementOp, cx.intType(), cx.intType(), CALL_Empty, SLOT_Global_DecrementOp_I);
		UnaryOperator(cx, ob, cx.doubleType(), CALL_Unary, SLOT_Global_DecrementLocalOp);
        UnaryOverload(cx, ob, SLOT_Global_DecrementLocalOp, cx.intType(), cx.intType(), CALL_Empty, SLOT_Global_DecrementLocalOp_I);

		// unary +
		UnaryOperator(cx, ob, cx.doubleType(), CALL_Unary, SLOT_Global_UnaryPlusOp);
		if (cx.statics.es4_numerics)
			UnaryOverload(cx, ob, SLOT_Global_UnaryPlusOp, cx.decimalType(), cx.decimalType(), CALL_Unary, SLOT_Global_UnaryPlusOp_M);
		UnaryOverload(cx, ob, SLOT_Global_UnaryPlusOp, cx.intType(), cx.intType(), CALL_Unary, SLOT_Global_UnaryPlusOp_I);

		// binary +
		BinaryOperator(cx, ob, cx.noType(), SLOT_Global_BinaryPlusOp);
		// cn: disable integer overloads for math operators where result could exceed MAX_INT.  With additional code analysis, we might be able to tell where it would safe to use this.
		//BinaryOverload(cx, ob, SLOT_Global_BinaryPlusOp, cx.intType(), cx.intType(), cx.intType(), SLOT_Global_BinaryPlusOp_II);

		// unary -
		UnaryOperator(cx, ob, cx.doubleType(), CALL_Unary, SLOT_Global_UnaryMinusOp);
		if (cx.statics.es4_numerics)
			UnaryOverload(cx, ob, SLOT_Global_UnaryMinusOp, cx.decimalType(), cx.decimalType(), CALL_Unary, SLOT_Global_UnaryMinusOp);
		UnaryOverload(cx, ob, SLOT_Global_UnaryMinusOp, cx.intType(), cx.intType(), CALL_Unary, SLOT_Global_UnaryMinusOp_I);

		// binary -
		BinaryOperator(cx, ob, cx.doubleType(), SLOT_Global_BinaryMinusOp);
		if (cx.statics.es4_numerics)
			BinaryOverload(cx, ob, SLOT_Global_BinaryMinusOp, cx.decimalType(), cx.decimalType(), cx.decimalType(), SLOT_Global_BinaryMinusOp);
		// cn: disable integer overloads for math operators where result could exceed MAX_INT.  With additional code analysis, we might be able to tell where it would safe to use this.
		//BinaryOverload(cx, ob, SLOT_Global_BinaryMinusOp, cx.intType(), cx.intType(), cx.intType(), SLOT_Global_BinaryMinusOp_II);

		// ~
		UnaryOperator(cx,ob,cx.intType(),CALL_Unary,SLOT_Global_BitwiseNotOp );
		UnaryOverload(cx, ob, SLOT_Global_BitwiseNotOp, cx.intType(), cx.intType(), CALL_Unary, SLOT_Global_BitwiseNotOp_I);

		// !
		UnaryOperator(cx, ob, cx.booleanType(), CALL_Unary, SLOT_Global_LogicalNotOp);
        UnaryOverload(cx, ob, SLOT_Global_LogicalNotOp, cx.booleanType(), cx.booleanType(), CALL_Unary, SLOT_Global_LogicalNotOp_B);
        UnaryOverload(cx, ob, SLOT_Global_LogicalNotOp, cx.booleanType(), cx.intType(), CALL_Unary, SLOT_Global_LogicalNotOp_I);

		// *
		BinaryOperator(cx, ob, cx.doubleType(), SLOT_Global_MultiplyOp);
		if (cx.statics.es4_numerics)
			BinaryOverload(cx, ob, SLOT_Global_MultiplyOp, cx.decimalType(), cx.decimalType(), cx.decimalType(), SLOT_Global_MultiplyOp);
		// cn: disable integer overloads for math operators where result could exceed MAX_INT.  With additional code analysis, we might be able to tell where it would safe to use this.
		//BinaryOverload(cx, ob, SLOT_Global_MultiplyOp, cx.intType(), cx.intType(), cx.intType(), SLOT_Global_MultiplyOp_II);

		// /
		BinaryOperator(cx, ob, cx.doubleType(), SLOT_Global_DivideOp);
		if (cx.statics.es4_numerics)
			BinaryOverload(cx, ob, SLOT_Global_DivideOp, cx.decimalType(), cx.decimalType(), cx.decimalType(), SLOT_Global_DivideOp);

		// %
		BinaryOperator(cx, ob, cx.doubleType(), SLOT_Global_ModulusOp);
		if (cx.statics.es4_numerics)
			BinaryOverload(cx, ob, SLOT_Global_ModulusOp, cx.decimalType(), cx.decimalType(), cx.decimalType(), SLOT_Global_ModulusOp);

		// <<
		BinaryOperator(cx, ob, cx.intType(), SLOT_Global_LeftShiftOp);
		BinaryOverload(cx, ob, SLOT_Global_LeftShiftOp, cx.intType(), cx.intType(), cx.intType(), SLOT_Global_LeftShiftOp_II);

		// >>
		BinaryOperator(cx, ob, cx.intType(), SLOT_Global_RightShiftOp);
		BinaryOverload(cx, ob, SLOT_Global_RightShiftOp, cx.intType(), cx.intType(), cx.intType(), SLOT_Global_RightShiftOp_II);

		// >>>
		BinaryOperator(cx, ob, cx.uintType(), SLOT_Global_UnsignedRightShiftOp);
		BinaryOverload(cx, ob, SLOT_Global_UnsignedRightShiftOp, cx.intType(), cx.intType(), cx.intType(), SLOT_Global_UnsignedRightShiftOp_II);

		// <
		BinaryOperator(cx, ob, cx.booleanType(), SLOT_Global_LessThanOp);

		// >
		BinaryOperator(cx, ob, cx.booleanType(), SLOT_Global_GreaterThanOp);

		// <=
		BinaryOperator(cx, ob, cx.booleanType(), SLOT_Global_LessThanOrEqualOp);

		// >=
		BinaryOperator(cx, ob, cx.booleanType(), SLOT_Global_GreaterThanOrEqualOp);

		// instanceof
		BinaryOperator(cx, ob, cx.booleanType(), SLOT_Global_InstanceofOp);

		// in
		BinaryOperator(cx, ob, cx.booleanType(), SLOT_Global_InOp);

		// is
		BinaryOperator(cx,ob,cx.booleanType(),SLOT_Global_IsOp );
		BinaryOperator(cx,ob,cx.booleanType(),SLOT_Global_IsLateOp );

		// == (Object,Object) : Boolean
		BinaryOperator(cx, ob, cx.booleanType(), SLOT_Global_EqualsOp);
		BinaryOverload(cx, ob, SLOT_Global_EqualsOp, cx.booleanType(), cx.intType(), cx.intType(), SLOT_Global_EqualsOp_II);

		// !=
		BinaryOperator(cx, ob, cx.booleanType(), SLOT_Global_NotEqualsOp);
		BinaryOverload(cx, ob, SLOT_Global_NotEqualsOp, cx.booleanType(), cx.intType(), cx.intType(), SLOT_Global_NotEqualsOp_II);

		// ===
		BinaryOperator(cx, ob, cx.booleanType(), SLOT_Global_StrictEqualsOp);
		BinaryOverload(cx, ob, SLOT_Global_StrictEqualsOp, cx.booleanType(), cx.intType(), cx.intType(), SLOT_Global_StrictEqualsOp_II);

		// !==
		BinaryOperator(cx, ob, cx.booleanType(), SLOT_Global_StrictNotEqualsOp);
		BinaryOverload(cx, ob, SLOT_Global_StrictNotEqualsOp, cx.booleanType(), cx.intType(), cx.intType(), SLOT_Global_StrictNotEqualsOp_II);

		// &
		BinaryOperator(cx, ob, cx.intType(), SLOT_Global_BitwiseAndOp);
		BinaryOverload(cx, ob, SLOT_Global_BitwiseAndOp, cx.intType(), cx.intType(), cx.intType(), SLOT_Global_BitwiseAndOp_II);

		// ^
		BinaryOperator(cx, ob, cx.intType(), SLOT_Global_BitwiseXorOp);
		BinaryOverload(cx, ob, SLOT_Global_BitwiseXorOp, cx.intType(), cx.intType(), cx.intType(), SLOT_Global_BitwiseXorOp_II);

		// |
		BinaryOperator(cx, ob, cx.intType(), SLOT_Global_BitwiseOrOp);
		BinaryOverload(cx, ob, SLOT_Global_BitwiseOrOp, cx.intType(), cx.intType(), cx.intType(), SLOT_Global_BitwiseOrOp_II);

		// && { result is one of the operand types }
		BinaryOperator(cx, ob, cx.noType(), SLOT_Global_LogicalAndOp);
		BinaryOverload(cx, ob, SLOT_Global_LogicalAndOp, cx.intType(), cx.intType(), cx.intType(), SLOT_Global_LogicalAndOp_II);

		// || { result is one of the operand types }
		BinaryOperator(cx, ob, cx.noType(), SLOT_Global_LogicalOrOp);
		BinaryOverload(cx, ob, SLOT_Global_LogicalOrOp, cx.intType(), cx.intType(), cx.intType(), SLOT_Global_LogicalOrOp_II);

        // as { result is the rhs type }
        BinaryOperator(cx, ob, cx.noType(), SLOT_Global_AsOp);
        BinaryOperator(cx, ob, cx.noType(), SLOT_Global_AsLateOp);        

		int slot_id;

        // public : Attribute
        slot_id = ExplicitGet(cx,ob,"public",cx.publicNamespace(),cx.noType(),true/*is_final*/,false/*is_override*/);
        ob.getSlot(cx,slot_id).setValue(cx.publicNamespace());
        
        // intrinsic : Attribute
		slot_id = ExplicitGet(cx,ob,"intrinsic",cx.publicNamespace(),cx.noType(),true/*is_final*/,false/*is_override*/);
		ob.getSlot(cx, slot_id).setValue(ObjectValue.intrinsicAttribute);

		// native : Attribute
		slot_id = ExplicitGet(cx,ob,"native",cx.publicNamespace(),cx.noType(),true/*is_final*/,false/*is_override*/);
		ob.getSlot(cx, slot_id).setValue(ObjectValue.nativeAttribute);

		// static : Attribute
		slot_id = ExplicitGet(cx,ob,"static",cx.publicNamespace(),cx.noType(),true/*is_final*/,false/*is_override*/);
		ob.getSlot(cx, slot_id).setValue(ObjectValue.staticAttribute);

		// dynamic : Attribute
		slot_id = ExplicitGet(cx,ob,"dynamic",cx.publicNamespace(),cx.noType(),true/*is_final*/,false/*is_override*/);
		ob.getSlot(cx, slot_id).setValue(ObjectValue.dynamicAttribute);

		// final : Attribute
		slot_id = ExplicitGet(cx,ob,"final",cx.publicNamespace(),cx.noType(),true/*is_final*/,false/*is_override*/);
		ob.getSlot(cx, slot_id).setValue(ObjectValue.finalAttribute);

		// virtual : Attribute
		slot_id = ExplicitGet(cx,ob,"virtual",cx.publicNamespace(),cx.noType(),true/*is_final*/,false/*is_override*/);
		ob.getSlot(cx,slot_id).setValue(ObjectValue.virtualAttribute);

		// override : Attribute
		slot_id = ExplicitGet(cx,ob,"override",cx.publicNamespace(),cx.noType(),true/*is_final*/,false/*is_override*/);
		ob.getSlot(cx,slot_id).setValue(ObjectValue.overrideAttribute);
		
		// builtin type void doesn't have a class
		slot_id = ExplicitGet(cx,ob,"void",cx.publicNamespace(), cx.noType(),true/*is_final*/,false/*is_override*/);
		ob.getSlot(cx,slot_id).setValue(cx.voidType());
	}

    public int Method( Context cx, ObjectValue ob, String name, Namespaces namespaces )
    {
        if( this.is_in_package )
        {
            return GetMethodId(cx,name,namespaces);
        }
        else
        {
            return super.GetMethodId(cx,name,namespaces);
        }
    }
    
    public int ExplicitCall( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override, int expected_id, int method_id, int var_id )
    {
        int slot_id; 
        
        if( this.is_in_package )
        {
            slot_id = super.ExplicitCall(cx,ob,name,namespaces,type,is_final,is_override,expected_id,method_id,var_id);
        }
        else
        {
            // Do the frontend binding

            if( method_id >= 0 || var_id >= 0 ) // this is secret code for: it is a real method (not intrinsic) that doesn't have an implementation yet
            {
                // allocate a new var
                var_id  = Variable(cx,ob);
            }
            // otherwise, reuse the one passed in

            slot_id = ExplicitVar(cx,ob,name,namespaces,type,expected_id,-1,var_id);
			if (cx.useStaticSemantics())
			{
				ImplicitCall(cx,ob,slot_id,type,CALL_Method,-1,-1);
				ImplicitConstruct(cx,ob,slot_id,cx.noType(),CALL_Method,-1,-1);

				Slot slot = ob.getSlot(cx,slot_id);
				slot.setConst(true);
				slot.setType(cx.functionType().getDefaultTypeInfo());
			}
		}

        return slot_id;
    }
}
