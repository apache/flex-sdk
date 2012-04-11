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

package macromedia.abc;

import static macromedia.asc.embedding.avmplus.ActionBlockConstants.*;
import java.util.HashSet;

/**
 *
This file stays synchronized with the source code.  To view
previous formats that we don't support, sync backwards in
perforce.

AbcFile {
   U16 minor_version                  // = 10
   U16 major_version                  // = 46
   U16 constant_pool_count
   Constant[constant_pool_count]
   U16 methods_count
   MethodInfo[methods_count]
   U16 metadata_count
   MetadataInfo[metadata_count]
   U16 class_count
   InstanceInfo[class_count]
   ClassInfo[class_count]
   U16 script_count
   ScriptInfo[script_count]         // ScriptInfo[script_count-1] is main entry point
   U16 bodies_count
   MethodBody[bodies_count]
}

Constant {
   U8 kind
   union {
      kind=1 { // CONSTANT_utf8
         U16 length
         U8[length]
      }
      kind=3 { // CONSTANT_Integer
         S32 value
      }
      kind=4 { // CONSTANT_UInteger
	     U32 value
      }
      kind=6 { // CONSTANT_Double
         U64 doublebits (little endian)
      }
      kind=2 { // CONSTANT_Decimal
         U8[16]
      }
      kind=7,13 { // CONSTANT_Qname + CONSTANT_QnameA
         U16 namespace_index			// CONSTANT_Namespace, 0=AnyNamespace wildcard
         U16 name_index					// CONSTANT_Utf8, 0=AnyName wildcard
      }
      kind=8,5 { // CONSTANT_Namespace, CONSTANT_PrivateNamespace
         U16 name_index                    // CONSTANT_Utf8 uri (maybe 0)
      }
      kind=9,14 { // CONSTANT_Multiname, CONSTANT_MultinameA
         U16 name_index                    // CONSTANT_Utf8  simple name.  0=AnyName wildcard
         U16 namespaces_count              // (256 may seem like enough, but 64K use to seem like a lot of memory)
         U16 namespaces[namespaces_count]  // CONSTANT_Namespace (0 = error)
      }
      kind=10 // CONSTANT_False
      kind=11 // CONSTANT_True
      kind=12 // CONSTANT_Null
      kind=15,16 { // CONSTANT_RTQname + CONSTANT_RTQnameA
         U16 name_index				// CONSTANT_utf8, 0=AnyName wildcard
      }
      kind=17,18 // CONSTANT_RTQnameL + CONSTANT_RTQnameLA
   }
}

Traits {
    U16 count
    Trait[count] {
	    U16 name_index                     // CONSTANT_QName
        U8  kind                           // hi 4 bits are flags, 0x04: (1=has_metadata, 0=no metadata)
        union {
           kind=0,6 { // slot, const
              U16 slot_id                  // 0=autoassign
              U16 type_index               // CONSTANT_Multiname, 0=Object
              U16 value_index              // CONSTANT or 0 for undefined
           }
           kind=1,2,3 { // method, getter, setter
              U16 disp_id			  // 0=autoassign
              U16 method_info         // method must be parsed already
   		     // attrs are stored in the hi 4 bits of the kind byte
             // 0x01: (1=final,0=virtual), 0x02: (1=override,0=new)
           }
           kind=4 { // class
              U16 slot_id                  // 0=autoassign
              U16 class_info               // class must have been parsed already
           }
           kind=5 { // function
              U16 slot_index          // 0=autoassign
              U16 method_info		  // method_info of function residing in this slot
           }
        }
        if ( (kind >> 4) & 0x04 )  // these are only present when the kind contains the has_metadata flag
        {
            U16 metadata_count           // Number of metadata
            U16 metadata[count]          // MetadataInfo indices
        }
    }
}

MetadataInfo {
    U16 name_index                         // CONSTANT_utf8
    U16 values_count                       // # of values in this metadata
    U16 keys[values_count]                 // CONSTANT_utf8, 0 = keyless
    U16 values[values_count]               // CONSTANT_utf8
}

InstanceInfo {
    U16 name_index                    // CONSTANT_QName (definition)
    U16 super_index                   // CONSTANT_Multiname (reference)
    U8  sealed                        // 1 = sealed, 0 = dynamic
    U32 protected_namespace           // CONSTANT_Namespace
    U16 interfaces_count
    U16 interfaces[interfaces_count]  // CONSTANT_Multiname (references)
    U16 iinit_index                   // MethodInfo
    Traits instance_traits
}

ClassInfo {
    U16 cinit_index                     // MethodInfo
    Traits static_traits
}

ScriptInfo {
    U16 init_index                      // MethodInfo
    Traits traits
}

// A MethodInfo describes the method signature
MethodInfo {
    U16 param_count
    U16 ret_type					  // CONSTANT_Multiname, 0=Object
    U16 param_types[param_count]	  // CONSTANT_Multiname, 0=Object
    U16 name_index                    // 0=no name.
    // 1=need_arguments, 2=need_activation, 4=need_rest 8=has_optional 16=ignore_rest, 32=explicit
    U8 flags
    U16 optional_count                // if has_optional
    U16 value_index[optional_count]   // if has_optional
}

// A MethodBody describes the method implementation.
// not required for native methods or interface methods.
MethodBody {
	U16 method_info
    U16 max_stack
    U16 max_regs
    U16 scope_depth
    U16 max_scope
    U32 code_length
    U8 code[code_length]
    U16 ex_count
    Exception[ex_count]
    Traits traits	// activation traits
}

Exception {
    U32 start                           // Offsets of beginning and
    U32 end                             // end of the try block
    U32 target                          // Target PC to transfer control to (catch)
    U16 type_index                      // Type matched by this exception handler
}
 *
 * @author Clement Wong
 */
public final class Decoder
{
	public Decoder(BytecodeBuffer in) throws DecoderException
	{
		minorVersion = in.readU16();
		majorVersion = in.readU16();
		constantPool = new ConstantPool(in, minorVersion >= MINORwithDECIMAL);

		int pos = in.pos();
		methodInfo = new MethodInfo(in);
		methodInfo.estimatedSize = in.pos() - pos;

		pos = in.pos();
		metadataInfo = new MetaDataInfo(in);
		metadataInfo.estimatedSize = in.pos() - pos;

		pos = in.pos();
		classInfo = new ClassInfo(in);
		classInfo.estimatedSize = in.pos() - pos;

		pos = in.pos();
		scriptInfo = new ScriptInfo(in);
		scriptInfo.estimatedSize = in.pos() - pos;

		pos = in.pos();
		methodBodies = new MethodBodies(in);
		methodBodies.estimatedSize = in.pos() - pos;

		opcodes = new Opcodes(in);

		this.in = in;
	}

	public final int minorVersion;
	public final int majorVersion;
	public final ConstantPool constantPool;
	public final MethodInfo methodInfo;
	public final MetaDataInfo metadataInfo;
	public final ClassInfo classInfo;
	public final ScriptInfo scriptInfo;
	public final MethodBodies methodBodies;
	public final Opcodes opcodes;

	private final BytecodeBuffer in;

	public int pos()
	{
		return in.pos();
	}

	public final class MethodInfo
	{
		MethodInfo(BytecodeBuffer in)
		{
			this(in, Scanner.scanMethods(in));
		}

		MethodInfo(BytecodeBuffer in, int[] positions)
		{
			this.in = in;
			this.positions = positions;
		}

		BytecodeBuffer in;
		int estimatedSize;
		private int[] positions;

		public int size()
		{
			return positions.length;
		}

		public void decode(int index, Visitor visitor) throws DecoderException
		{
			int pos = positions[index];
			int originalPos = in.pos();
			in.seek(pos);

			int paramCount = in.readU32();
			int returnType = in.readU32();

			int[] paramTypes = null;
			if (paramCount > 0)
			{
				paramTypes = new int[paramCount];
				for (int j = 0; j < paramCount; j++)
				{
					paramTypes[j] = in.readU32();
				}
			}

			int nativeName = in.readU32();
			int flags = in.readU8();

			int optionalCount = ((flags & METHOD_HasOptional) != 0) ? in.readU32() : 0;

			int[] values = null;
            int[] value_kinds = null;
			if (optionalCount > 0)
			{
				values = new int[optionalCount];
                value_kinds = new int[optionalCount];
				for (int j = 0; j < optionalCount; j++)
				{
					values[j] = in.readU32();
                    value_kinds[j] = in.readU8();
				}
			}

            int[] paramNames = null;
            int paramNameCount = ((flags & METHOD_HasParamNames) != 0 ) ? paramCount : 0;
            if( paramNameCount > 0)
            {
                paramNames = new int[paramNameCount];
                for(int j = 0; j < paramNameCount; ++j)
                {
                    paramNames[j] = in.readU32();
                }
            }
			in.seek(originalPos);

			visitor.methodInfo(returnType, paramTypes, nativeName, flags, values, value_kinds, paramNames);
		}
	}

	public final class MetaDataInfo
	{
		MetaDataInfo(BytecodeBuffer in)
		{
			this(in, Scanner.scanMetadata(in));
		}

		MetaDataInfo(BytecodeBuffer in, int[] positions)
		{
			this.in = in;
			this.positions = positions;
		}

		BytecodeBuffer in;
		int estimatedSize;
		private int[] positions;

		public int size()
		{
			return positions.length;
		}

		public void decode(int index, Visitor visitor) throws DecoderException
		{
			int pos = positions[index];
			int originalPos = in.pos();
			in.seek(pos);

			int nameIndex = in.readU32();
			int valueCount = in.readU32();

			int[] keys = null;
			int[] values = null;
			if (valueCount > 0)
			{
				keys = new int[valueCount];
				values = new int[valueCount];
				for (int j = 0; j < valueCount; j++)
				{
					keys[j] = in.readU32();
				}
				for (int j = 0; j < valueCount; j++)
				{
					values[j] = in.readU32();
				}
			}

			in.seek(originalPos);

			visitor.metadataInfo(index, nameIndex, keys, values);
		}
	}

	public final class ClassInfo
	{
		ClassInfo(BytecodeBuffer in)
		{
			this.in = in;
			int size = in.readU32();
			iPositions = Scanner.scanInstances(in, size);
			iTraits = new Traits(in);
			cPositions = Scanner.scanClasses(in, size);
			cTraits = new Traits(in);
		}

		BytecodeBuffer in;
		int estimatedSize;
		private int[] cPositions;
		private int[] iPositions;
		private Traits cTraits;
		private Traits iTraits;

		public int size()
		{
			return cPositions.length;
		}

		public void decode(int index, Visitor visitor) throws DecoderException
		{
			int name = decodeInstance(index, visitor);
			decodeClass(index, name, visitor);
		}

		public int decodeInstance(int index, Visitor visitor) throws DecoderException
		{
			int pos = iPositions[index];
			int originalPos = in.pos();
			in.seek(pos);

			int name = in.readU32();
			int superName = in.readU32();

			int flags = in.readU8();
			boolean isFinal = (flags & CLASS_FLAG_final) != 0;
			boolean isDynamic = ( flags & CLASS_FLAG_sealed ) == 0;
			boolean isInterface = (flags & CLASS_FLAG_interface) != 0;
			boolean hasProtected = (flags & CLASS_FLAG_protected) != 0;
			
			int protectedNamespace = hasProtected ? in.readU32() : 0;

			int interfaceCount = in.readU32();
			int[] interfaces = new int[interfaceCount];
			if (interfaceCount > 0)
			{
				for (int j = 0; j < interfaceCount; j++)
				{
					interfaces[j] = in.readU32();
				}
			}

			int iinit = in.readU32();
			visitor.startInstance(name, superName, isDynamic, isFinal, isInterface, interfaces, iinit, protectedNamespace);
			iTraits.decode(visitor);
			visitor.endInstance();

			in.seek(originalPos);

			return name;
		}

		public void decodeClass(int index, int name, Visitor visitor) throws DecoderException
		{
			int pos = cPositions[index];
			int originalPos = in.pos();
			in.seek(pos);

			int cinit = in.readU32();
			visitor.startClass(name, cinit);
			cTraits.decode(visitor);
			visitor.endClass();

			in.seek(originalPos);
		}
	}

	public final class ScriptInfo
	{
		ScriptInfo(BytecodeBuffer in)
		{
			this(in, Scanner.scanScripts(in));
		}

		ScriptInfo(BytecodeBuffer in, int[] positions)
		{
			this.in = in;
			this.positions = positions;
			traits = new Traits(in);
		}

		BytecodeBuffer in;
		int estimatedSize;
		private int[] positions;
		private Traits traits;

		public int size()
		{
			return positions.length;
		}

		public void decode(int index, Visitor visitor) throws DecoderException
		{
			int pos = positions[index];
			int originalPos = in.pos();
			in.seek(pos);

			int initID = in.readU32();
			visitor.startScript(initID);
			traits.decode(visitor);
			visitor.endScript();

			in.seek(originalPos);
		}
	}

	public final class MethodBodies
	{
		MethodBodies(BytecodeBuffer in)
		{
			this(in, Scanner.scanMethodBodies(in));
		}

		MethodBodies(BytecodeBuffer in, int[] positions)
		{
			this.in = in;
			this.positions = positions;
			traits = new Traits(in);
		}

		BytecodeBuffer in;
		int estimatedSize;
		private int[] positions;
		private Traits traits;

		public int size()
		{
			return positions.length;
		}

		public void decode(int index, Visitor visitor) throws DecoderException
		{
			decode(index, 1, visitor);
		}

		public void decode(int index, int opcodePass, Visitor visitor) throws DecoderException
		{
			int pos = positions[index];
			int originalPos = in.pos();
			in.seek(pos);

			int methodInfo = in.readU32();
			int maxStack = in.readU32();
			int maxRegs = in.readU32();
			int scopeDepth = in.readU32();
			int maxScope = in.readU32();

			long codeLength = in.readU32();
			int codeStart = in.pos();
			in.skip((int) codeLength);

			visitor.startMethodBody(methodInfo, maxStack, maxRegs, scopeDepth, maxScope, codeStart, codeLength);

			int exPos = in.pos();
			for (int i = 0; i < opcodePass; i++)
			{
				opcodes.reset();
				in.seek(exPos);
				int exCount = in.readU32();

				visitor.startOpcodes(methodInfo);
				visitor.startExceptions(exCount);

				decodeExceptions(in, codeStart, visitor, exCount);
				opcodes.decode(codeStart, codeLength, visitor);

				visitor.endOpcodes();
				visitor.endExceptions();
			}
			traits.decode(visitor);
			visitor.endMethodBody();

			in.seek(originalPos);
		}

		private void decodeExceptions(BytecodeBuffer in, int codeStart, Visitor visitor, int exCount)
		{
			boolean hasNames = (in.minorVersion() != 15);
			
			for (int i = 0; i < exCount; i++)
			{
				long start = codeStart + in.readU32();
				long end = codeStart + in.readU32();
				long target = codeStart + in.readU32();

				int type = in.readU32(); // multiname

				int nameIndex = hasNames ? in.readU32() : 0;
				
				opcodes.addTarget((int) start);
				opcodes.addTarget((int) end);
				opcodes.addTarget((int) target);

				visitor.exception(start, end, target, type, nameIndex);
			}
		}
	}

	class Traits
	{
		Traits(BytecodeBuffer in)
		{
			this.in = in;
		}

		BytecodeBuffer in;

		void decode(Visitor visitor) throws DecoderException
		{
			int count = in.readU32();
			visitor.traitCount(count);

			for (int i = 0; i < count; i++)
			{
				int name = in.readU32();
				int kind = in.readU8();
				int slotID, typeID, valueID, methInfo, dispID, classID;
                int value_kind = 0;

				switch (kind & 0x0f)
				{
				case TRAIT_Var:
				case TRAIT_Const:
					slotID = in.readU32();
					typeID = in.readU32();
					valueID = in.readU32();
                    if(valueID != 0 )
                        value_kind = in.readU8();
					visitor.slotTrait(kind, name, slotID, typeID, valueID, value_kind, decodeMetaData(kind));
					break;
				case TRAIT_Method:
				case TRAIT_Getter:
				case TRAIT_Setter:
					dispID = in.readU32();
					methInfo = in.readU32();
					visitor.methodTrait(kind, name, dispID, methInfo, decodeMetaData(kind));
					break;
				case TRAIT_Class:
					slotID = in.readU32();
					classID = in.readU32();
					visitor.classTrait(kind, name, slotID, classID, decodeMetaData(kind));
					break;
				case TRAIT_Function:
					slotID = in.readU32();
					methInfo = in.readU32();
					visitor.functionTrait(kind, name, slotID, methInfo, decodeMetaData(kind));
					break;
				default:
					// do nothing. macromedia.abc.Scanner would throw an exception.
					// bad abc code will not reach here.
				}
			}
		}

		private int[] decodeMetaData(int kind)
		{
			int[] md = null;

			if (((kind >> 4) & TRAIT_FLAG_metadata) != 0)
			{
				int length = in.readU32();
				if (length > 0)
				{
					md = new int[length];
					for (int i = 0; i < length; i++)
					{
						md[i] = in.readU32();
					}
				}
			}

			return md;
		}
	}

	public class Opcodes
	{
		public Opcodes(BytecodeBuffer in)
		{
			this.in = in;
		}

		BytecodeBuffer in;
		
		private HashSet<Integer> targetSet;
		public void addTarget(int pos)
		{
			if (targetSet == null)
				targetSet = new HashSet<Integer>();
			targetSet.add(pos);
		}
		public void reset()
		{
			targetSet = null;
		}

		public void decode(int start, long length, int passes, Visitor v) throws DecoderException
		{
			for (int i = 0; i < passes; i++)
			{
				decode(start, length, v);
			}
		}

		public void decode(int start, long length, Visitor v) throws DecoderException
		{
			int originalPos = in.pos();
			in.seek(start);

			for (long end = start + length; in.pos() < end;)
			{
				int pos = in.pos();
				int opcode = in.readU8();
				
				if (opcode == OP_label)
					addTarget(pos);

				if (targetSet != null && targetSet.contains(pos))
					v.target(pos);

			    switch (opcode)
			    {
				case OP_ifnlt:
				{
					int offset = in.readS24();
					addTarget(offset + in.pos());
					v.OP_ifnlt(offset, in.pos());
					continue;
				}
				case OP_ifnle:
				{
					int offset = in.readS24();
					addTarget(offset + in.pos());
					v.OP_ifnle(offset, in.pos());
					continue;
				}
				case OP_ifngt:
				{
					int offset = in.readS24();
					addTarget(offset + in.pos());
					v.OP_ifngt(offset, in.pos());
					continue;
				}
				case OP_ifnge:
				{
					int offset = in.readS24();
					addTarget(offset + in.pos());
					v.OP_ifnge(offset, in.pos());
					continue;
				}
				case OP_pushscope:
				{
					v.OP_pushscope();
					continue;
				}
				case OP_newactivation:
				{
					v.OP_newactivation();
					continue;
				}
			    case OP_newcatch:
			    {
				    int index = in.readU32();
				    v.OP_newcatch(index);
				    continue;
			    }
				case OP_deldescendants:
				{
					v.OP_deldescendants();
					continue;
				}
				case OP_getglobalscope:
				{
					v.OP_getglobalscope();
					continue;
				}
				case OP_getlocal0:
				{
					v.OP_getlocal0();
					continue;
				}
			    case OP_getlocal1:
			    {
				    v.OP_getlocal1();
				    continue;
			    }
			    case OP_getlocal2:
			    {
				    v.OP_getlocal2();
				    continue;
			    }
			    case OP_getlocal3:
			    {
				    v.OP_getlocal3();
				    continue;
			    }
			    case OP_setlocal0:
			    {
				    v.OP_setlocal0();
				    continue;
			    }
		        case OP_setlocal1:
		        {
			        v.OP_setlocal1();
			        continue;
		        }
		        case OP_setlocal2:
		        {
			        v.OP_setlocal2();
			        continue;
		        }
		        case OP_setlocal3:
		        {
			        v.OP_setlocal3();
			        continue;
		        }
			    case OP_returnvoid:
			    {
				    v.OP_returnvoid();
				    continue;
			    }
			    case OP_returnvalue:
			    {
				    v.OP_returnvalue();
				    continue;
			    }
			    case OP_nop:
			    {
				    v.OP_nop();
			        continue;
			    }
				case OP_bkpt:
			    {
				    v.OP_bkpt();
					continue;
			    }
				case OP_timestamp:
			    {
				    v.OP_timestamp();
					continue;
			    }
				case OP_debugline:
				{
				    int linenum = in.readU32();
					v.OP_debugline(linenum);
					continue;
				}
				case OP_bkptline:
			    {
				    in.readU32();
				    v.OP_bkptline();
					continue;
			    }
				case OP_debug:
			    {
				    int di_local = in.readU8(); // DI_LOCAL
				    int index = in.readU32(); // constant pool index...
				    int slot = in.readU8();
				    int linenum = in.readU32();
				    v.OP_debug(di_local, index, slot, linenum);
					continue;
			    }
				case OP_debugfile:
			    {
				    int index = in.readU32(); // constant pool index...
				    // String file = constantPool.getString(index);
				    v.OP_debugfile(index);
				    continue;
			    }
			    case OP_jump:
			    {
				    int jump = in.readS24(); // readjust jump...
					addTarget(jump + in.pos());
				    v.OP_jump(jump, in.pos());
				    continue;
			    }
			    case OP_pushnull:
			    {
				    v.OP_pushnull();
			        continue;
			    }
			    case OP_pushundefined:
			    {
				    v.OP_pushundefined();
			        continue;
			    }
			    case OP_pushstring:
			    {
				    int index = in.readU32(); // constant pool index...
				    v.OP_pushstring(index);
			        continue;
			    }
                case OP_pushnamespace:
                {
                    int index = in.readU32();
                    v.OP_pushnamespace(index);
                    continue;
                }
                case OP_pushint:
                {
                    int index = in.readU32(); // constant pool index...
                    v.OP_pushint(index);
                    continue;
                }
                case OP_pushuint:
                {
                    int index = in.readU32(); // constant pool index...
                    v.OP_pushuint(index);
                    continue;
                }
                case OP_pushdouble:
                {
                    int index = in.readU32(); // constant pool index...
                    v.OP_pushdouble(index);
                    continue;
                }
                case OP_pushdecimal:
                {
                    int index = in.readU32(); // constant pool index...
                    v.OP_pushdecimal(index);
                    continue;
                }
			    case OP_getlocal:
			    {
				    int index = in.readU32();
				    v.OP_getlocal(index);
				    continue;
			    }
			    case OP_pushtrue:
			    {
				    v.OP_pushtrue();
			        continue;
			    }
			    case OP_pushfalse:
			    {
				    v.OP_pushfalse();
			        continue;
			    }
				case OP_pushnan:
			    {
				    v.OP_pushnan();
					continue;
			    }
				case OP_pushdnan:
			    {
				    v.OP_pushdnan();
					continue;
			    }
			    case OP_pop:
			    {
				    v.OP_pop();
			        continue;
			    }
			    case OP_dup:
			    {
				    v.OP_dup();
			        continue;
			    }
			    case OP_swap:
			    {
				    v.OP_swap();
			        continue;
			    }
			    case OP_convert_s:
			    {
				    v.OP_convert_s();
			        continue;
			    }
				case OP_esc_xelem:
			    {
				    v.OP_esc_xelem();
					continue;
			    }
                case OP_esc_xattr:
                {
                    v.OP_esc_xattr();
                    continue;
                }
                case OP_checkfilter:
                {
                    v.OP_checkfilter();
                    continue;
                }
			    case OP_convert_d:
			    {
				    v.OP_convert_d();
			        continue;
			    }
			    case OP_convert_b:
			    {
				    v.OP_convert_b();
			        continue;
			    }
			    case OP_convert_o:
			    {
				    v.OP_convert_o();
			        continue;
			    }
			    case OP_convert_m:
			    {
				    v.OP_convert_m();
			        continue;
			    }
			    case OP_convert_m_p:
			    {
					int param = in.readU32();
				    v.OP_convert_m_p(param);
			        continue;
			    }
			    case OP_negate:
			    {
				    v.OP_negate();
			        continue;
			    }
			    case OP_negate_p:
			    {
					int param = in.readU32();
				    v.OP_negate_p(param);
			        continue;
			    }
				case OP_negate_i:
			    {
				    v.OP_negate_i();
			        continue;
			    }
			    case OP_increment:
			    {
				    v.OP_increment();
			        continue;
			    }
			    case OP_increment_p:
			    {
					int param = in.readU32();
				    v.OP_increment_p(param);
			        continue;
			    }
			    case OP_increment_i:
			    {
				    v.OP_increment_i();
			        continue;
			    }
				case OP_inclocal:
				{
					int index = in.readU32();
					v.OP_inclocal(index);
					continue;
				}
				case OP_inclocal_p:
				{
					int param = in.readU32();
					int index = in.readU32();
					v.OP_inclocal_p(param, index);
					continue;
				}
				case OP_kill:
				{
					int index = in.readU32();
					v.OP_kill(index);
					continue;
				}
				case OP_label:
				{
					v.OP_label();
					continue;
				}
			    case OP_inclocal_i:
			    {
				    int index = in.readU32();
				    v.OP_inclocal_i(index);
				    continue;
			    }
			    case OP_decrement:
			    {
				    v.OP_decrement();
			        continue;
			    }
			    case OP_decrement_p:
			    {
					int param = in.readU32();
				    v.OP_decrement_p(param);
			        continue;
			    }
			    case OP_decrement_i:
			    {
				    v.OP_decrement_i();
			        continue;
			    }
				case OP_declocal:
			    {
				    int index = in.readU32();
				    v.OP_declocal(index);
				    continue;
			    }
				case OP_declocal_p:
			    {
					int param = in.readU32();
				    int index = in.readU32();
				    v.OP_declocal_p(param, index);
				    continue;
			    }
				case OP_declocal_i:
			    {
				    int index = in.readU32();
				    v.OP_declocal_i(index);
				    continue;
			    }
			    case OP_typeof:
			    {
				    v.OP_typeof();
			        continue;
			    }
			    case OP_not:
			    {
				    v.OP_not();
			        continue;
			    }
				case OP_bitnot:
			    {
				    v.OP_bitnot();
			        continue;
			    }
			    case OP_setlocal:
			    {
				    int index = in.readU32();
				    v.OP_setlocal(index);
				    continue;
			    }
			    case OP_add:
			    {
				    v.OP_add();
			        continue;
			    }
			    case OP_add_p:
			    {
					int param = in.readU32();
				    v.OP_add_p(param);
			        continue;
			    }
				case OP_add_i:
			    {
				    v.OP_add_i();
			        continue;
			    }
			    case OP_subtract:
			    {
				    v.OP_subtract();
			        continue;
			    }
			    case OP_subtract_p:
			    {
					int param = in.readU32();
				    v.OP_subtract_p(param);
			        continue;
			    }
			    case OP_subtract_i:
			    {
				    v.OP_subtract_i();
			        continue;
			    }
			    case OP_multiply:
			    {
				    v.OP_multiply();
			        continue;
			    }
			    case OP_multiply_p:
			    {
					int param = in.readU32();
				    v.OP_multiply_p(param);
			        continue;
			    }
				case OP_multiply_i:
			    {
				    v.OP_multiply_i();
			        continue;
			    }
			    case OP_divide:
			    {
				    v.OP_divide();
			        continue;
			    }
			    case OP_divide_p:
			    {
					int param = in.readU32();
				    v.OP_divide_p(param);
			        continue;
			    }
			    case OP_modulo:
			    {
				    v.OP_modulo();
					continue;
			    }
			    case OP_modulo_p:
			    {
					int param = in.readU32();
				    v.OP_modulo_p(param);
					continue;
			    }
			    case OP_lshift:
			    {
				    v.OP_lshift();
			        continue;
			    }
			    case OP_rshift:
			    {
				    v.OP_rshift();
			        continue;
			    }
			    case OP_urshift:
			    {
				    v.OP_urshift();
			        continue;
			    }
			    case OP_bitand:
			    {
				    v.OP_bitand();
					continue;
			    }
			    case OP_bitor:
			    {
				    v.OP_bitor();
			        continue;
			    }
			    case OP_bitxor:
			    {
				    v.OP_bitxor();
			        continue;
			    }
			    case OP_equals:
			    {
				    v.OP_equals();
			        continue;
			    }
			    case OP_strictequals:
			    {
				    v.OP_strictequals();
			        continue;
			    }
				case OP_lookupswitch:
				{
					int opPos = in.pos() - 1; // OP_lookupswtich position...
					int defaultPos = in.readS24();
					addTarget(defaultPos + opPos);
					int size_1 = in.readU32(); // size - 1
					int[] casePos = new int[size_1 + 1];
					int caseTablePos = in.pos(); // case position
					for (int i = 0, size = casePos.length; i < size; i++)
					{
						casePos[i] = in.readS24();
						addTarget(casePos[i] + opPos);
					}
					v.OP_lookupswitch(defaultPos, casePos, opPos, caseTablePos);
					continue;
				}
			    case OP_iftrue:
			    {
				    int offset = in.readS24();
				    addTarget(offset+in.pos());
				    v.OP_iftrue(offset, in.pos());
				    continue;
			    }
			    case OP_iffalse:
			    {
				    int offset = in.readS24();
				    addTarget(offset+in.pos());
				    v.OP_iffalse(offset, in.pos());
				    continue;
			    }
			    case OP_ifeq:
			    {
				    int offset = in.readS24();
				    addTarget(offset+in.pos());
				    v.OP_ifeq(offset, in.pos());
				    continue;
			    }
			    case OP_ifne:
			    {
				    int offset = in.readS24();
				    addTarget(offset+in.pos());
				    v.OP_ifne(offset, in.pos());
				    continue;
			    }
			    case OP_ifstricteq:
			    {
				    int offset = in.readS24();
				    addTarget(offset+in.pos());
				    v.OP_ifstricteq(offset, in.pos());
				    continue;
			    }
			    case OP_ifstrictne:
			    {
				    int offset = in.readS24();
				    addTarget(offset+in.pos());
				    v.OP_ifstrictne(offset, in.pos());
				    continue;
			    }
			    case OP_iflt:
			    {
				    int offset = in.readS24();
				    addTarget(offset+in.pos());
				    v.OP_iflt(offset, in.pos());
				    continue;
			    }
			    case OP_ifle:
			    {
				    int offset = in.readS24();
				    addTarget(offset+in.pos());
				    v.OP_ifle(offset, in.pos());
				    continue;
			    }
			    case OP_ifgt:
			    {
				    int offset = in.readS24();
				    addTarget(offset+in.pos());
				    v.OP_ifgt(offset, in.pos());
				    continue;
			    }
			    case OP_ifge:
			    {
				    int offset = in.readS24();
				    addTarget(offset+in.pos());
				    v.OP_ifge(offset, in.pos());
				    continue;
			    }
			    case OP_lessthan:
			    {
				    v.OP_lessthan();
			        continue;
			    }
			    case OP_lessequals:
			    {
				    v.OP_lessequals();
			        continue;
			    }
			    case OP_greaterthan:
			    {
				    v.OP_greaterthan();
			        continue;
			    }
			    case OP_greaterequals:
			    {
				    v.OP_greaterequals();
			        continue;
			    }
			    case OP_newobject:
			    {
				    int size = in.readU32();
				    v.OP_newobject(size);
				    continue;
			    }
			    case OP_newarray:
			    {
				    int size = in.readU32();
				    v.OP_newarray(size);
				    continue;
			    }
				// get a property using a multiname ref
			    case OP_getproperty:
				{
					int index = in.readU32(); // constant pool index...
					v.OP_getproperty(index);
					continue;
				}
                // set a property using a multiname ref
                case OP_setproperty:
                {
                    int index = in.readU32(); // constant pool index...
                    v.OP_setproperty(index);
                    continue;
                }
                // set a property using a multiname ref
                case OP_initproperty:
                {
                    int index = in.readU32(); // constant pool index...
                    v.OP_initproperty(index);
                    continue;
                }
				case OP_getdescendants:
				{
					int index = in.readU32(); // constant pool index...
					v.OP_getdescendants(index);
					continue;
				}
				// search the scope chain for a given property and return the object
				// that contains it.  the next instruction will usually be getpropname
				// or setpropname.
			    case OP_findpropstrict:
				{
				    int index = in.readU32(); // constant pool index...
				    v.OP_findpropstrict(index);
				    continue;
				}
			    case OP_getlex:
			    {
				    int index = in.readU32(); // constant pool index...
				    v.OP_getlex(index);
				    continue;
			    }
			    case OP_findproperty:
				{
					// stack in:  [ns [name]]
					// stack out: obj
					int index = in.readU32(); // constant pool index...
					v.OP_findproperty(index);
					continue;
				}
				case OP_finddef:
				{
					// stack in:
					// stack out: obj
					int index = in.readU32(); // constant pool index...
					v.OP_finddef(index);
					continue;
				}
				case OP_nextname:
			    {
				    v.OP_nextname();
					continue;
			    }
				case OP_nextvalue:
			    {
				    v.OP_nextvalue();
					continue;
			    }
				case OP_hasnext:
			    {
				    v.OP_hasnext();
					continue;
			    }
				case OP_hasnext2:
			    {
				    int objectRegister = in.readU32();
				    int indexRegister = in.readU32();
				    v.OP_hasnext2(objectRegister, indexRegister);
					continue;
			    }
				// delete property using multiname
				case OP_deleteproperty:
				{
					int index = in.readU32(); // constant pool index...
					v.OP_deleteproperty(index);
					continue;
				}
			    case OP_setslot:
			    {
				    int index = in.readU32();
				    v.OP_setslot(index);
				    continue;
			    }
				case OP_getslot:
			    {
				    int index = in.readU32();
				    v.OP_getslot(index);
				    continue;
			    }
				case OP_setglobalslot:
			    {
				    int index = in.readU32();
				    v.OP_setglobalslot(index);
				    continue;
			    }
				case OP_getglobalslot:
			    {
				    int index = in.readU32();
				    v.OP_getglobalslot(index);
				    continue;
			    }
				case OP_call:
				{
					int size = in.readU32();
					v.OP_call(size);
			        continue;
				}
				case OP_construct:
				{
					int size = in.readU32();
					v.OP_construct(size);
			        continue;
				}
                case OP_applytype:
                {
                    int size = in.readU32();
                    v.OP_applytype(size);
                    continue;
                }
			    case OP_newfunction:
				{
					int id = in.readU32(); // method info...
					v.OP_newfunction(id);
			        continue;
			    }
			    case OP_newclass:
				{
					int id = in.readU32(); // class info...
					v.OP_newclass(id);
					continue;
				}
			    case OP_callstatic:
				{
					// stack in: receiver, arg1..N
					// stack out: result
					int id = in.readU32(); // method info...
					int argc = in.readU32();
					v.OP_callstatic(id, argc);
					continue;
				}
			    case OP_callmethod:
				{
					// stack in: receiver, arg1..N
					// stack out: result
					int id = in.readU32(); // disp_id...
					int argc = in.readU32();
					v.OP_callmethod(id, argc);
					continue;
				}
				case OP_callproperty:
			    {
				    // stack in: obj [ns [name]] arg1..N
				    // stack out: result
				    int index = in.readU32(); // constant pool index...
				    int argc = in.readU32();
				    v.OP_callproperty(index, argc);
				    continue;
			    }
				case OP_callproplex:
				{
					// stack in: obj [ns [name]] arg1..N
					// stack out: result
					int index = in.readU32(); // constant pool index...
					int argc = in.readU32();
					v.OP_callproplex(index, argc);
					continue;
				}
				case OP_constructprop:
				{
					// stack in: obj [ns [name]] arg1..N
					// stack out: result
					int index = in.readU32(); // constant pool index...
					int argc = in.readU32();
					v.OP_constructprop(index, argc);
					continue;
				}
				case OP_callsuper:
				{
					// stack in: obj [ns [name]] arg1..N
					int index = in.readU32(); // constant pool index...
					int argc = in.readU32();
					v.OP_callsuper(index, argc);
					continue;
				}
				case OP_getsuper:
				{
					int index = in.readU32(); // constant pool index...
					v.OP_getsuper(index);
					continue;
				}
				case OP_setsuper:
				{
					int index = in.readU32(); // constant pool index...
					v.OP_setsuper(index);
					continue;
				}
				// obj arg1 arg2
				//           sp
				case OP_constructsuper:
				{
					// stack in:  obj arg1..N
					// stack out:
					int argc = in.readU32();
					v.OP_constructsuper(argc);
					continue;
				}
			    case OP_pushshort:
			    {
				    // fixme this just pushes an integer since we dont have short atoms yet
				    int n = in.readU32();
				    v.OP_pushshort(n);
				    continue;
			    }
				case OP_astype:
				{
					int index = in.readU32(); // constant pool index...
					v.OP_astype(index);
					continue;
				}
				case OP_astypelate:
				    v.OP_astypelate();
			        continue;

			    case OP_coerce:
				{
			        // expects a CONSTANT_Multiname cpool index
					// this is the ES4 implicit coersion
					int index = in.readU32(); // constant pool index...
					v.OP_coerce(index);
			        continue;
				}
				case OP_coerce_b:
			    {
				    v.OP_coerce_b();
					continue;
			    }
				case OP_coerce_o:
			    {
				    v.OP_coerce_o();
					continue;
			    }
				case OP_coerce_a:
			    {
				    v.OP_coerce_a();
					continue;
			    }
				case OP_coerce_i:
			    {
				    v.OP_coerce_i();
					continue;
			    }
				case OP_coerce_u:
			    {
				    v.OP_coerce_u();
					continue;
			    }
				case OP_coerce_d:
			    {
				    v.OP_coerce_d();
					continue;
			    }
				case OP_coerce_s:
			    {
				    v.OP_coerce_s();
					continue;
			    }
				case OP_istype:
				{
			        // expects a CONSTANT_Multiname cpool index
					// used when operator "is" RHS is a compile-time type constant
					int index = in.readU32(); // constant pool index...
					v.OP_istype(index);
			        continue;
				}
				case OP_istypelate:
			    {
				    v.OP_istypelate();
			        continue;
			    }
			    case OP_pushbyte:
			    {
				    int n = in.readU8();
				    v.OP_pushbyte(n);
				    continue;
			    }
			    case OP_getscopeobject:
			    {
				    int index = in.readU8();
				    v.OP_getscopeobject(index);
					continue;
			    }
			    case OP_pushwith:
			    {
				    v.OP_pushwith();
					continue;
			    }
			    case OP_popscope:
			    {
				    v.OP_popscope();
					continue;
			    }
			    case OP_convert_i:
			    {
				    v.OP_convert_i();
			        continue;
			    }
				case OP_convert_u:
			    {
				    v.OP_convert_u();
			        continue;
			    }
				case OP_throw:
			    {
				    v.OP_throw();
					continue;
			    }
			    case OP_instanceof:
			    {
				    v.OP_instanceof();
					continue;
			    }
			    case OP_in:
			    {
				    v.OP_in();
					continue;
			    }
				case OP_dxns:
			    {
				    int index = in.readU32(); // constant pool index...
				    v.OP_dxns(index);
				    continue;
			    }
				case OP_dxnslate:
			    {
				    v.OP_dxnslate();
					continue;
			    }
				case OP_pushuninitialized:
				{
					int id = in.readU32();
					v.OP_pushconstant(id);
					continue;
				}
				case OP_callsupervoid:
				{
					// stack in: obj [ns [name]] arg1..N
					int index = in.readU32(); // constant pool index...
					int argc = in.readU32();
					v.OP_callsupervoid(index, argc);
					continue;
				}
				case OP_callpropvoid:
				{
					// stack in: obj [ns [name]] arg1..N
					// stack out: result
					int index = in.readU32(); // constant pool index...
					int argc = in.readU32();
					v.OP_callpropvoid(index, argc);
					continue;
				}
                case OP_li8:
                {
                    v.OP_li8();
                    continue;
                }
                case OP_li16:
                {
                    v.OP_li16();
                    continue;
                }
                case OP_li32:
                {
                    v.OP_li32();
                    continue;
                }
                case OP_lf32:
                {
                    v.OP_lf32();
                    continue;
                }
                case OP_lf64:
                {
                    v.OP_lf64();
                    continue;
                }
                case OP_si8:
                {
                    v.OP_si8();
                    continue;
                }
                case OP_si16:
                {
                    v.OP_si16();
                    continue;
                }
                case OP_si32:
                {
                    v.OP_si32();
                    continue;
                }
                case OP_sf32:
                {
                    v.OP_sf32();
                    continue;
                }
                case OP_sf64:
                {
                    v.OP_sf64();
                    continue;
                }
                case OP_sxi1:
                {
                    v.OP_sxi1();
                    continue;
                }
                case OP_sxi8:
                {
                    v.OP_sxi8();
                    continue;
                }
                case OP_sxi16:
                {
                    v.OP_sxi16();
                    continue;
                }

                default:
				{
					throw new DecoderException("unknown opcode?? " + opcode);
				}
			    }
			}

			in.seek(originalPos);
		}
	}
}
