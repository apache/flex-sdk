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
import macromedia.asc.util.IntegerPool;
import macromedia.asc.util.IntList;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.*;

/**
 * abc encoder. If the encoder is provided with multiple constant pools, it will use do merging.
 */
public class Encoder implements Visitor
{
	public Encoder(int majorVersion, int minorVersion)
	{
		this.majorVersion = majorVersion;
		this.minorVersion = minorVersion;

		poolIndex = 0;
		peepHole = false;
		disableDebugging = false;
		removeMetadata = false;

    }

	private ConstantPool pool;
	private int majorVersion, minorVersion;
	private int poolIndex, opcodePass, exPass;
	private boolean disableDebugging, removeMetadata, peepHole;

    private HashSet<String> keep_metadata = new HashSet<String>();

	private BytecodeBuffer2 methodInfo;
	private ByteArrayPool2 metadataInfo;
	private BytecodeBuffer2 classInfo;
	private BytecodeBuffer2 scriptInfo;
	private BytecodeBuffer2 methodBodies;
	private BytecodeBuffer3 opcodes;
	private BytecodeBuffer exceptions;

	private BytecodeBuffer currentBuffer;

    private ConstantPool[] pools;

	public void enablePeepHole()
	{
		peepHole = true;
	}

	public void disableDebugging()
	{
		disableDebugging = true;
        pool.history.disableDebugging();
	}

	public void removeMetadata()
	{
		removeMetadata = true;
	}

    public void addMetadataToKeep(String meta_name)
    {
        keep_metadata.add(meta_name);
    }

	public void addConstantPools(ConstantPool[] pools)
	{
        this.pools = pools;
		pool = ConstantPool.merge(pools);
        if( disableDebugging )
            pool.history.disableDebugging();
	}
	
	public void test()
	{
		// C: testing only...
		for (int i = 0, size = pools.length; i < size; i++)
		{
			/*
			for (int j = 1, count = pools[i].intpositions.length; j < count; j++)
			{
				int original = pools[i].getInt(j);
				int real = pool.getInt(pool.history.getIndex(i, 0, j));

				if (original != real)
				{
					throw new DecoderException("Error (int) in constant pooling merging...");
				}
			}

			for (int j = 1, count = pools[i].uintpositions.length; j < count; j++)
			{
				long original = pools[i].getLong(j);
				long real = pool.getLong(pool.history.getIndex(i, 1, j));

				if (original != real)
				{
					throw new DecoderException("Error (uint) in constant pooling merging...");
				}
			}

			for (int j = 1, count = pools[i].doublepositions.length; j < count; j++)
			{
				double original = pools[i].getDouble(j);
				double real = pool.getDouble(pool.history.getIndex(i, 2, j));

				if (original != real)
				{
					throw new DecoderException("Error (double) in constant pooling merging...");
				}
			}

			for (int j = 1, count = pools[i].strpositions.length; j < count; j++)
			{
				String original = pools[i].getString(j);
				System.out.println("(" + i + "," + j + ")-->(0," + pool.history.getIndex(i, 3, j) + "): " + original);
			}

			for (int j = 1, count = pools[i].nspositions.length; j < count; j++)
			{
				String original = pools[i].getNamespaceName(j);
				String real = pool.getNamespaceName(pool.history.getIndex(i, 4, j));

				if (!original.equals(real))
				{
					throw new DecoderException("Error (namespace) in constant pooling merging...");
				}
			}

			for (int j = 1, count = pools[i].nsspositions.length; j < count; j++)
			{
				String[] original = pools[i].getNamespaceSet(j);
				String[] real = pool.getNamespaceSet(pool.history.getIndex(i, 5, j));

				if (original.length != real.length)
				{
					throw new DecoderException("Error (namespace set) in constant pooling merging...");
				}
				else
				{
					for (int k = 0, len = original.length; k < len; k++)
					{
						if (!original[k].equals(real[k]))
						{
							throw new DecoderException("Error (namespace set) in constant pooling merging...");
						}
					}
				}
			}

			for (int j = 1, count = pools[i].mnpositions.length; j < count; j++)
			{
				Object original = pools[i].getGeneralMultiname(j);
				Object real = pool.getGeneralMultiname(pool.history.getIndex(i, 6, j));

				if (original.getClass() != real.getClass())
				{
					throw new DecoderException("Error (multiname) in constant pooling merging...");
				}

				if (original instanceof QName && !((QName) original).equals(real))
				{
					throw new DecoderException("Error (multiname) in constant pooling merging...");
				}

				if (original instanceof MultiName && !((MultiName) original).equals(real))
				{
					throw new DecoderException("Error (multiname) in constant pooling merging...");
				}
			}
			*/
		}
	}

	public void configure(Decoder[] decoders)
	{
		int estimatedSize = 0, total = 0;
		int[] sizes = new int[decoders.length];
		for (int i = 0, size = sizes.length; i < size; i++)
		{
			estimatedSize += decoders[i].methodInfo.estimatedSize;
			sizes[i] = decoders[i].methodInfo.size();
			total += sizes[i];
		}
		methodInfo = new BytecodeBuffer2(estimatedSize, sizes);
		methodInfo.writeU32(total);


		estimatedSize = 0; total = 0;
		sizes = new int[decoders.length];
		for (int i = 0, size = sizes.length; i < size; i++)
		{
			estimatedSize += decoders[i].metadataInfo.estimatedSize;
			sizes[i] = decoders[i].metadataInfo.size();
			total += sizes[i];
		}
		metadataInfo = new ByteArrayPool2(sizes);


		estimatedSize = 0; total = 0;
		sizes = new int[decoders.length];
		for (int i = 0, size = sizes.length; i < size; i++)
		{
			estimatedSize += decoders[i].classInfo.estimatedSize;
			sizes[i] = decoders[i].classInfo.size();
			total += sizes[i];
		}
		classInfo = new BytecodeBuffer2(estimatedSize, sizes);
		classInfo.writeU32(total);


		estimatedSize = 0; total = 0;
		sizes = new int[decoders.length];
		for (int i = 0, size = sizes.length; i < size; i++)
		{
			estimatedSize += decoders[i].scriptInfo.estimatedSize;
			sizes[i] = decoders[i].scriptInfo.size();
			total += sizes[i];
		}
		scriptInfo = new BytecodeBuffer2(estimatedSize, sizes);
		scriptInfo.writeU32(total);


		estimatedSize = 0; total = 0;
		sizes = new int[decoders.length];
		for (int i = 0, size = sizes.length; i < size; i++)
		{
			estimatedSize += decoders[i].methodBodies.estimatedSize;
			sizes[i] = decoders[i].methodBodies.size();
			total += sizes[i];
		}
		methodBodies = new BytecodeBuffer2(estimatedSize, sizes);
		methodBodies.writeU32(total);

		opcodes = new BytecodeBuffer3(decoders, 4096);
		exceptions = new BytecodeBuffer(4096);
	}

	public void useConstantPool(int index)
	{
		poolIndex = index;
	}

	public byte[] toABC()
	{
		/*
		System.out.println();
		System.out.println("--Constant Pool--");
		System.out.println("total: " + pool.history.total + " duplicate: " + pool.history.duplicate);
		System.out.println("totalBytes: " + pool.history.totalBytes + " duplicateBytes: " + pool.history.duplicateBytes);
		System.out.println("--Method Info--");
		System.out.println("before: " + methodInfo.estimatedSize + " after: " + methodInfo.size());
		System.out.println("--Metadata Info--");
		System.out.println("before: " + metadataInfo.estimatedSize + " after: " + metadataInfo.size());
		System.out.println("--Class Info--");
		System.out.println("before: " + classInfo.estimatedSize + " after: " + classInfo.size());
		System.out.println("--Script Info--");
		System.out.println("before: " + scriptInfo.estimatedSize + " after: " + scriptInfo.size());
		System.out.println("--Method Bodies--");
		System.out.println("before: " + methodBodies.estimatedSize + " after: " + methodBodies.size());
		System.out.println();
		*/
		
		int size = pool.in.size() + methodInfo.size() + metadataInfo.size() + classInfo.size() + scriptInfo.size() + methodBodies.size();
		ByteArrayOutputStream baos = new ByteArrayOutputStream(size);

		try
		{
			baos.write((byte) minorVersion);
			baos.write((byte) (minorVersion >> 8));
			baos.write((byte) majorVersion);
			baos.write((byte) (majorVersion >> 8));

			pool.writeTo(baos);
			methodInfo.writeTo(baos);
			metadataInfo.writeTo(baos);
			classInfo.writeTo(baos);
			scriptInfo.writeTo(baos);
			methodBodies.writeTo(baos);
		}
		catch (IOException ex)
		{
			return null;
		}

		return baos.toByteArray();
	}

	public void methodInfo(int returnType, int[] paramTypes, int nativeName, int flags, int[] values, int[] value_kinds, int[] param_names)
	{
		if (paramTypes == null)
		{
			methodInfo.writeU32(0);
		}
		else
		{
			methodInfo.writeU32(paramTypes.length);
		}

		methodInfo.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, returnType));

		for (int i = 0, paramCount = (paramTypes == null) ? 0 : paramTypes.length; i < paramCount; i++)
		{
			methodInfo.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, paramTypes[i]));
		}

		methodInfo.writeU32((disableDebugging) ? 0 : pool.history.getIndex(poolIndex, IndexHistory.cp_string, nativeName));

        if( disableDebugging )
        {
            // Nuke the param names if we're getting rid of debugging info, don't want them showing
            // up in release code
            flags &= ~METHOD_HasParamNames;
        }

		methodInfo.writeU8(flags);

		if ((flags & METHOD_HasOptional) != 0)
		{
			if (values == null)
			{
				methodInfo.writeU32(0);
			}
			else
			{
				methodInfo.writeU32(values.length);
			}
		}

		for (int i = 0, optionalCount = (values == null) ? 0 : values.length; i < optionalCount; i++)
		{
			int kind = -1;

			switch (value_kinds[i])
			{
		    case CONSTANT_Utf8:
				kind = IndexHistory.cp_string;
				break;
		    case CONSTANT_Integer:
				kind = IndexHistory.cp_int;
				break;
		    case CONSTANT_UInteger:
				kind = IndexHistory.cp_uint;
				break;
		    case CONSTANT_Double:
				kind = IndexHistory.cp_double;
				break;
		    case CONSTANT_Decimal:
				kind = IndexHistory.cp_decimal;
				break;
		    case CONSTANT_Namespace:
		    case CONSTANT_PrivateNamespace:
            case CONSTANT_PackageNamespace:
            case CONSTANT_PackageInternalNs:
            case CONSTANT_ProtectedNamespace:
            case CONSTANT_ExplicitNamespace:
            case CONSTANT_StaticProtectedNs:
				kind = IndexHistory.cp_ns;
				break;
			case CONSTANT_Qname:
			case CONSTANT_QnameA:
		    case CONSTANT_Multiname:
		    case CONSTANT_MultinameA:
            case CONSTANT_TypeName:
                kind = IndexHistory.cp_mn;
				break;
		    case CONSTANT_Namespace_Set:
				kind = IndexHistory.cp_nsset;
				break;
			}

			int newIndex = 0;

			switch(value_kinds[i])
			{
			case 0:
			case CONSTANT_False:
			case CONSTANT_True:
			case CONSTANT_Null:
				// The index doesn't matter, as long as its non 0
				// there are no boolean values in any cpool, instead the value will be determined by the kind byte
				newIndex = values[i];
				break;
			default:
			{
				if (kind == -1)
				{
					System.out.println("writing MethodInfo: don't know what constant type it is... " + value_kinds[i] + "," + values[i]);
				}
				newIndex = pool.history.getIndex(poolIndex, kind, values[i]);
			}
			}

			methodInfo.writeU32(newIndex);
			methodInfo.writeU8(value_kinds[i]);
		}
        // Nuke the param names if we're not keeping debugging around
        if( (flags & METHOD_HasParamNames) != 0 && param_names != null)
        {
            for( int i = 0 ; i < param_names.length; ++i )
            {
                methodInfo.writeU32( pool.history.getIndex(poolIndex, IndexHistory.cp_string, returnType) );
            }
        }
	}

	public void metadataInfo(int index, int name, int[] keys, int[] values)
	{


        try
        {
            String s = pools[poolIndex].getString(name);
            if (removeMetadata && !keep_metadata.contains(s) )
                return;

            BytecodeBuffer b = new BytecodeBuffer(6);
            b.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_string, name));
            if (keys == null)
            {
                b.writeU32(0);
            }
            else
            {
                b.writeU32(keys.length);
            }

            for (int i = 0, keyCount = (keys == null) ? 0 : keys.length; i < keyCount; i++)
            {
                b.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_string, keys[i]));
            }

            for (int i = 0, valueCount = (values == null) ? 0 : values.length; i < valueCount; i++)
            {
                b.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_string, values[i]));
            }

            metadataInfo.addByteArray(poolIndex, index, b);
        }
        catch( DecoderException ex)
        {
            // this should never happen
            // ex.printStackTrace();
        }
	}

	public void startInstance(int name, int superName, boolean isDynamic, boolean isFinal, boolean isInterface, int[] interfaces, int iinit, int protectedNamespace)
	{
		classInfo.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, name));
		classInfo.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, superName));

		int flags = 0;
		flags = (isFinal) ? (flags | CLASS_FLAG_final) : flags;
		flags = (!isDynamic) ? (flags | CLASS_FLAG_sealed) : flags;
		flags = (isInterface) ? (flags | CLASS_FLAG_interface) : flags;
		flags = (protectedNamespace != 0) ? (flags | CLASS_FLAG_protected) : flags;
		classInfo.writeU8(flags);

		if (protectedNamespace != 0)
		{
			classInfo.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_ns, protectedNamespace));
		}
		
		if (interfaces == null)
		{
			classInfo.writeU32(0);
		}
		else
		{
			classInfo.writeU32(interfaces.length);
		}

		for (int i = 0, interfaceCount = interfaces == null ? 0 : interfaces.length; i < interfaceCount; i++)
		{
			classInfo.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, interfaces[i]));
		}

		classInfo.writeU32(methodInfo.getIndex(poolIndex, iinit));

		currentBuffer = classInfo;
	}

	public void endInstance()
	{
		currentBuffer = null;
	}

	public void startClass(int name, int cinit)
	{
		classInfo.writeU32(methodInfo.getIndex(poolIndex, cinit));

		currentBuffer = classInfo;
	}

	public void endClass()
	{
		currentBuffer = null;
	}

	public void startScript(int initID)
	{
		scriptInfo.writeU32(methodInfo.getIndex(poolIndex, initID));

		currentBuffer = scriptInfo;
	}

	public void endScript()
	{
		currentBuffer = null;
	}

	public void startMethodBody(int methodInfo, int maxStack, int maxRegs, int scopeDepth, int maxScope, int codeStart, long codeLength)
	{
		methodBodies.writeU32(this.methodInfo.getIndex(poolIndex, methodInfo));
		methodBodies.writeU32(maxStack);
		methodBodies.writeU32(maxRegs);
		methodBodies.writeU32(scopeDepth);
		methodBodies.writeU32(maxScope);

		currentBuffer = methodBodies;
		opcodePass = 1;
		exPass = 1;
	}

	public void endMethodBody()
	{
		currentBuffer = null;
		opcodes.clear();
		exceptions.clear();
	}

	public void startOpcodes(int methodInfo)
	{
	}

	public void endOpcodes()
	{
		if (opcodePass == 1)
		{
			opcodePass = 2;
		}
		else if (opcodePass == 2)
		{
			methodBodies.writeU32(opcodes.size());
			methodBodies.writeBytes(opcodes, 0, opcodes.size());
		}
	}

	public void exception(long start, long end, long target, int type, int name)
	{
		if (exPass == 2)
		{
			exceptions.writeU32(opcodes.getOffset(start));
			exceptions.writeU32(opcodes.getOffset(end));
			exceptions.writeU32(opcodes.getOffset(target));
			exceptions.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, type));
			if (minorVersion != 15)
			{
				exceptions.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, name));
			}
		}
	}

	public void startExceptions(int exceptionCount)
	{
		if (exPass == 2)
		{
			exceptions.writeU32(exceptionCount);
		}
	}

	public void endExceptions()
	{
		if (exPass == 1)
		{
			exPass++;
		}
		else if (exPass == 2)
		{
			methodBodies.writeBytes(exceptions, 0, exceptions.size());
		}
	}

	public void traitCount(int traitCount)
	{
		currentBuffer.writeU32(traitCount);
	}

//	private void encodeMetaData(int kind, int[] metadata)
//	{
//		if (((kind >> 4) & TRAIT_FLAG_metadata) != 0)
//		{
//			if (metadata == null)
//			{
//				currentBuffer.writeU32(0);
//			}
//			else
//			{
//				currentBuffer.writeU32(metadata.length);
//			}
//
//			for (int i = 0, length = metadata == null ? 0 : metadata.length; i < length; i++)
//			{
//				currentBuffer.writeU32(metadataInfo.getIndex(poolIndex, metadata[i]));
//			}
//		}
//	}

    private void encodeMetaData(int kind, IntList metadata)
    {
        if (((kind >> 4) & TRAIT_FLAG_metadata) != 0)
        {
            if (metadata == null)
            {
                currentBuffer.writeU32(0);
            }
            else
            {
                currentBuffer.writeU32(metadata.size());
            }

            for (int i = 0, length = metadata == null ? 0 : metadata.size(); i < length; i++)
            {
                currentBuffer.writeU32(metadata.get(i));
            }
        }
    }

    private IntList trimMetadata(int[] metadata)
    {
        IntList newMetadata = new IntList();
        int length = metadata != null ? metadata.length : 0;
        for( int i = 0; i < length; ++i)
        {
            int new_index = metadataInfo.getIndex(poolIndex, metadata[i]) ;
            if( new_index != -1 )
            {
                newMetadata.add(new_index);
            }
        }
        return newMetadata;
    }

	public void slotTrait(int trait_kind, int name, int slotId, int type, int value, int value_kind, int[] metadata)
	{
		currentBuffer.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, name));
        IntList new_metadata = trimMetadata(metadata);
		if ( ((trait_kind >> 4) & TRAIT_FLAG_metadata) != 0 && new_metadata.size()==0 )
		{
			trait_kind = trait_kind & ~(TRAIT_FLAG_metadata << 4);
		}
		currentBuffer.writeU8(trait_kind);

		currentBuffer.writeU32(slotId);
		currentBuffer.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, type));

		int kind = -1;

		switch(value_kind)
		{
		case CONSTANT_Utf8:
			kind = IndexHistory.cp_string;
			break;
		case CONSTANT_Integer:
			kind = IndexHistory.cp_int;
			break;
		case CONSTANT_UInteger:
			kind = IndexHistory.cp_uint;
			break;
		case CONSTANT_Double:
			kind = IndexHistory.cp_double;
			break;
		case CONSTANT_Decimal:
			kind = IndexHistory.cp_decimal;
			break;
		case CONSTANT_Namespace:
		case CONSTANT_PrivateNamespace:
        case CONSTANT_PackageNamespace:
        case CONSTANT_PackageInternalNs:
        case CONSTANT_ProtectedNamespace:
        case CONSTANT_ExplicitNamespace:
        case CONSTANT_StaticProtectedNs:			
			kind = IndexHistory.cp_ns;
			break;
		case CONSTANT_Qname:
		case CONSTANT_QnameA:
		case CONSTANT_Multiname:
		case CONSTANT_MultinameA:
        case CONSTANT_TypeName:
            kind = IndexHistory.cp_mn;
			break;
		case CONSTANT_Namespace_Set:
			kind = IndexHistory.cp_nsset;
			break;
		}

		int newIndex = 0;
		switch(value_kind)
		{
		case 0:
		case CONSTANT_False:
		case CONSTANT_True:
		case CONSTANT_Null:
			newIndex = value;
			break;
		default:
		{
			if (kind == -1)
			{
				System.out.println("writing slotTrait: don't know what constant type it is... " + value_kind + "," + value);
			}
			newIndex = pool.history.getIndex(poolIndex, kind, value);
		}
		}

		currentBuffer.writeU32(newIndex);
		if (value != 0)
		{
			currentBuffer.writeU8(value_kind);
		}

		encodeMetaData(trait_kind, new_metadata);
	}

	public void methodTrait(int trait_kind, int name, int dispId, int methodInfo, int[] metadata)
	{
		currentBuffer.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, name));
        IntList new_metadata = trimMetadata(metadata);
		if ( ((trait_kind >> 4) & TRAIT_FLAG_metadata) != 0 && new_metadata.size()==0 )
		{
			trait_kind = trait_kind & ~(TRAIT_FLAG_metadata << 4);
		}
		currentBuffer.writeU8(trait_kind);

		//currentBuffer.writeU32(0);
		currentBuffer.writeU32(dispId);
		currentBuffer.writeU32(this.methodInfo.getIndex(poolIndex, methodInfo));

		encodeMetaData(trait_kind, new_metadata);
	}

	public void classTrait(int kind, int name, int slotId, int classIndex, int[] metadata)
	{
		currentBuffer.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, name));
        IntList new_metadata = trimMetadata(metadata);
		if ( ((kind >> 4) & TRAIT_FLAG_metadata) != 0 && new_metadata.size()==0 )
		{
			kind = kind & ~(TRAIT_FLAG_metadata << 4);
		}
		currentBuffer.writeU8(kind);

		currentBuffer.writeU32(slotId);
		currentBuffer.writeU32(classInfo.getIndex(poolIndex, classIndex));

		encodeMetaData(kind, new_metadata);
	}

	public void functionTrait(int kind, int name, int slotId, int methodInfo, int[] metadata)
	{
		currentBuffer.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, name));
        IntList new_metadata = trimMetadata(metadata);
		if ( ((kind >> 4) & TRAIT_FLAG_metadata) != 0 && new_metadata.size()==0 )
		{
			kind = kind & ~(TRAIT_FLAG_metadata << 4);
		}
		currentBuffer.writeU8(kind);

		currentBuffer.writeU32(slotId);
		currentBuffer.writeU32(this.methodInfo.getIndex(poolIndex, methodInfo));

		encodeMetaData(kind, new_metadata);
	}

	static final int W = 8;
	int[] window = new int[W];
    int window_size = 0;
	int head = 0;
	boolean reachable = true;
	
	void clearWindow()
	{
		for (int i=0; i < W; i++)
			window[i] = 0;
        window_size = 0;
	}
	
	void beginop(int opcode)
	{
		window[head] = opcodes.size();
		head = (head+1) & (W-1);
        if( window_size < 8 )
            ++window_size;
		opcodes.writeU8(opcode);
	}
	
	int opat(int i)
	{
		if (peepHole)
		{
            if( i <= window_size )
            {
                int ip = window[(head-i) & (W-1)];
                if (ip < opcodes.size())
                    return opcodes.readU8(ip);
            }
		}
		return 0;
	}
	
	void setOpcodeAt(int i, int opcode)
	{
		assert peepHole;

        if( i <= window_size )
        {
            int ip = window[(head-i) & (W-1)];
            if (ip < opcodes.size())
                opcodes.writeU8(ip, opcode);
        }
	}
	
	int readByteAt(int i)
	{
        if( i <= window_size )
        {
            int ip = 1+window[(head-i) & (W-1)];
            return (byte) opcodes.readU8(ip);
        }
        return 0;
	}
	
	int readIntAt(int i)
	{
        if( i <= window_size )
        {
            int ip = 1+window[(head-i) & (W-1)];
            return (int) opcodes.readU32(ip);
        }
        return 0;
	}
	
	void rewind(int i)
	{
		int to = (head-i) & (W-1);
		int ip = window[to];
		int end = opcodes.size();
		opcodes.delete(end-ip);
		head = to;
        window_size -= i;
	}
	
	public void target(int oldPos)
	{
		if (opcodePass == 1)
		{
			opcodes.mapOffsets(oldPos);
			clearWindow();
		}
	}

	public void OP_returnvoid()
	{
		if (opcodePass == 1)
		{
			/*
			if (opat(2) == OP_getlocal0 && opat(1) == OP_pushscope)
				rewind(2);
			
			if (opat(1) == OP_returnvalue)
				return;
			*/
			beginop(OP_returnvoid);
		}
	}

	public void OP_returnvalue()
	{
		if (opcodePass == 1)
		{
			
			if (opat(1) == OP_coerce_a)
			{
				rewind(1);
			}
			
			if (opat(1) == OP_pushundefined)
			{
				rewind(1);						
				OP_returnvoid();
				return;
			}
			
			// eliminate dead code... maybe do this higher up?
			/*
			for (int i=1; i < W; i++)
			{
				if (opat(i) == OP_returnvalue) 
				{
					rewind(i);
					break;
				}
			}
			
			if (	opat(4) == OP_pushundefined &&
					opat(3) == OP_coerce_a &&
					opat(2) == OP_setlocal1 &&
					opat(1) == OP_getlocal1)
			{
				rewind(4);
				OP_returnvoid();
				return;
			}
			*/
			
			beginop(OP_returnvalue);
		}
	}

	public void OP_nop()
	{
		if (opcodePass == 1)
		{
			beginop(OP_nop);
		}
	}

	public void OP_bkpt()
	{
		if (opcodePass == 1)
		{
			beginop(OP_bkpt);
		}
	}

	public void OP_timestamp()
	{
		if (opcodePass == 1)
		{
			beginop(OP_timestamp);
		}
	}

	public void OP_debugline(int linenum)
	{
		if (opcodePass == 1)
		{
			if (!disableDebugging)
			{
				beginop(OP_debugline);
				opcodes.writeU32(linenum);
			}
		}
	}

	public void OP_bkptline()
	{
		if (opcodePass == 1)
		{
			beginop(OP_bkptline);
		}
	}

	public void OP_debug(int di_local, int index, int slot, int linenum)
	{
		if (opcodePass == 1)
		{
			if (!disableDebugging)
			{
				beginop(OP_debug);
				opcodes.writeU8(di_local);
				// FIX: is this a constant pool index? if so, we need to know the constant type...
				// opcodes.writeU32(index);
				opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_string, index));
				opcodes.writeU8(slot);
				opcodes.writeU32(linenum);
			}
		}
	}

	public void OP_debugfile(int index)
	{
		if (opcodePass == 1)
		{
			if (!disableDebugging)
			{
				beginop(OP_debugfile);
				opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_string, index));
			}
		}
	}

	public void OP_jump(int offset, int pos)
	{
		if (opcodePass == 1)
        {
			/*
			if (opat(1) == OP_jump)
			{
				// unreachable
				return;
			}
			*/

			beginop(OP_jump);
			opcodes.writeS24(offset);
			opcodes.mapOffsets(pos);
		}
		else if (opcodePass == 2)
		{
			opcodes.updateOffset(pos + offset);
		}
	}

	public void OP_pushnull()
	{
		if (opcodePass == 1)
		{
			beginop(OP_pushnull);
		}
	}

	public void OP_pushundefined()
	{
		if (opcodePass == 1)
		{
			beginop(OP_pushundefined);
		}
	}

    public void OP_pushstring(int index)
    {
	    if (opcodePass == 1)
	    {
	    	beginop(OP_pushstring);
	    	opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_string, index));
	    }
    }

    public void OP_pushnamespace(int index)
    {
	    if (opcodePass == 1)
	    {
	    	beginop(OP_pushnamespace);
	    	opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_ns, index));
	    }
    }

    public void OP_pushint(int index)
    {
	    if (opcodePass == 1)
	    {
	    	beginop(OP_pushint);
		    opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_int, index));
	    }
    }

    public void OP_pushuint(int index)
    {
	    if (opcodePass == 1)
	    {
	    	beginop(OP_pushuint);
		    opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_uint, index));
	    }
    }

    public void OP_pushdouble(int index)
    {
	    if (opcodePass == 1)
	    {
	    	beginop(OP_pushdouble);
		    opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_double, index));
	    }
    }

    public void OP_pushdecimal(int index)
    {
	    if (opcodePass == 1)
	    {
	    	beginop(OP_pushdecimal);
		    opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_decimal, index));
	    }
    }

	public void OP_getlocal(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_getlocal);
			opcodes.writeU32(index);
		}
	}

	public void OP_pushtrue()
	{
		if (opcodePass == 1)
		{
			beginop(OP_pushtrue);
		}
	}

	public void OP_pushfalse()
	{
		if (opcodePass == 1)
		{
			beginop(OP_pushfalse);
		}
	}

	public void OP_pushnan()
	{
		if (opcodePass == 1)
		{
			beginop(OP_pushnan);
		}
	}

	public void OP_pushdnan()
	{
		if (opcodePass == 1)
		{
			beginop(OP_pushdnan);
		}
	}

	public void OP_pop()
	{
		if (opcodePass == 1)
		{
			switch (opat(1))
			{
			case OP_callproperty:
				setOpcodeAt(1, OP_callpropvoid);
				return;
			case OP_callsuper:
				setOpcodeAt(1, OP_callsupervoid);
				return;
			}

			beginop(OP_pop);
		}
	}

	public void OP_dup()
	{
		if (opcodePass == 1)
		{
			beginop(OP_dup);
		}
	}

	public void OP_swap()
	{
		if (opcodePass == 1)
		{
			beginop(OP_swap);
		}
	}

	public void OP_convert_s()
	{
		if (opcodePass == 1)
		{
	        if (opat(1) == OP_coerce_a)
				rewind(1);
	        
			switch (opat(1))
			{
			case OP_coerce_s:
			case OP_convert_s:
			case OP_pushstring:
			case OP_typeof:
				// result is already string
				return;
			}
			
			if (opat(2) == OP_pushstring && opat(1) == OP_add)
			{
				// result must be string, so dont coerce after
				return;
			}

			beginop(OP_convert_s);
		}
	}

	public void OP_esc_xelem()
	{
		if (opcodePass == 1)
		{
			beginop(OP_esc_xelem);
		}
	}

    public void OP_esc_xattr()
    {
        if (opcodePass == 1)
        {
            beginop(OP_esc_xattr);
        }
    }

    public void OP_checkfilter()
    {
        if (opcodePass == 1)
        {
            beginop(OP_checkfilter);
        }
    }

	public void OP_convert_d()
	{
		if (opcodePass == 1)
		{
			beginop(OP_convert_d);
		}
	}

	public void OP_convert_m()
	{
		if (opcodePass == 1)
		{
			beginop(OP_convert_m);
		}
	}

	public void OP_convert_m_p(int param)
	{
		if (opcodePass == 1)
		{
			beginop(OP_convert_m);
			opcodes.writeU32(param);
		}
	}


	public void OP_convert_b()
	{
		if (opcodePass == 1)
		{
			switch(opat(1))
			{
			case OP_equals:
			case OP_strictequals:
			case OP_not:
			case OP_greaterthan:
			case OP_lessthan:
			case OP_greaterequals:
			case OP_lessequals:
			case OP_istype:
			case OP_istypelate:
			case OP_instanceof:
			case OP_deleteproperty:
			case OP_in:
            case OP_convert_b:
            case OP_pushtrue:
            case OP_pushfalse:
				// dont need convert
				return;
			}

			beginop(OP_convert_b);
		}
	}

	public void OP_convert_o()
	{
		if (opcodePass == 1)
		{
			beginop(OP_convert_o);
		}
	}

	public void OP_negate()
	{
		if (opcodePass == 1)
		{
			beginop(OP_negate);
		}
	}

	public void OP_negate_p(int param)
	{
		if (opcodePass == 1)
		{
			beginop(OP_negate_p);
			opcodes.writeU32(param);
		}
	}

	public void OP_negate_i()
	{
		if (opcodePass == 1)
		{
			beginop(OP_negate_i);
		}
	}

	public void OP_increment()
	{
		if (opcodePass == 1)
		{
			beginop(OP_increment);
		}
	}

	public void OP_increment_p(int param)
	{
		if (opcodePass == 1)
		{
			beginop(OP_increment_p);
			opcodes.writeU32(param);
		}
	}

	public void OP_increment_i()
	{
		if (opcodePass == 1)
		{
			beginop(OP_increment_i);
		}
	}

	public void OP_inclocal(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_inclocal);
			opcodes.writeU32(index);
		}
	}

	public void OP_inclocal_p(int param, int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_inclocal_p);
			opcodes.writeU32(param);
			opcodes.writeU32(index);
		}
	}

	public void OP_kill(int index)
	{
		if (opcodePass == 1)
		{
			switch(opat(1))
			{
			case OP_returnvalue:
			case OP_returnvoid:
				// unreachable
				return;
			}

			beginop(OP_kill);
			opcodes.writeU32(index);
		}
	}

	public void OP_inclocal_i(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_inclocal_i);
			opcodes.writeU32(index);
		}
	}

	public void OP_decrement()
	{
		if (opcodePass == 1)
		{
			beginop(OP_decrement);
		}
	}

	public void OP_decrement_p(int param)
	{
		if (opcodePass == 1)
		{
			beginop(OP_decrement_p);
			opcodes.writeU32(param);
		}
	}

	public void OP_decrement_i()
	{
		if (opcodePass == 1)
		{
			beginop(OP_decrement_i);
		}
	}

	public void OP_declocal(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_declocal);
			opcodes.writeU32(index);
		}
	}

	public void OP_declocal_p(int param, int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_declocal_p);
			opcodes.writeU32(param);
			opcodes.writeU32(index);
		}
	}

	public void OP_declocal_i(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_declocal_i);
			opcodes.writeU32(index);
		}
	}

	public void OP_typeof()
	{
		if (opcodePass == 1)
		{
			beginop(OP_typeof);
		}
	}

	public void OP_not()
	{
		if (opcodePass == 1)
		{
			beginop(OP_not);
		}
	}

	public void OP_bitnot()
	{
		if (opcodePass == 1)
		{
			beginop(OP_bitnot);
		}
	}

	public void OP_setlocal(int index)
	{
		if (opcodePass == 1)
		{
			if (opat(2) == OP_getlocal && readIntAt(2) == index &&
				opat(1) == OP_increment_i)
			{
				rewind(2);
				OP_inclocal_i(index);
				return;
			}
			
			if (opat(2) == OP_getlocal && readIntAt(2) == index &&
				opat(1) == OP_increment)
			{
				rewind(2);
				OP_inclocal(index);
				return;
			}
			
			beginop(OP_setlocal);
			opcodes.writeU32(index);
		}
	}

	public void OP_add()
	{
		if (opcodePass == 1)
		{
			if (opat(1) == OP_coerce_a)
				rewind(1);
			beginop(OP_add);
		}
	}

	public void OP_add_p(int param)
	{
		if (opcodePass == 1)
		{
			if (opat(1) == OP_coerce_a)
				rewind(1);
			beginop(OP_add_p);
			opcodes.writeU32(param);
		}
	}

	public void OP_add_i()
	{
		if (opcodePass == 1)
		{
			beginop(OP_add_i);
		}
	}

	public void OP_subtract()
	{
		if (opcodePass == 1)
		{
			if (opat(1) == OP_pushbyte && readByteAt(1) == 1)
			{
				rewind(1);
				OP_decrement();
				return;
			}
			beginop(OP_subtract);
		}
	}

	public void OP_subtract_p(int param)
	{
		if (opcodePass == 1)
		{
			if (opat(1) == OP_pushbyte && readByteAt(1) == 1)
			{
				rewind(1);
				OP_decrement_p(param);
				return;
			}
			beginop(OP_subtract_p);
			opcodes.writeU32(param);
		}
	}

	public void OP_subtract_i()
	{
		if (opcodePass == 1)
		{
			if (opat(1) == OP_pushbyte && readIntAt(1) == 1)
			{
				rewind(1);
				OP_decrement_i();
				return;
			}
			beginop(OP_subtract_i);
		}
	}

	public void OP_multiply()
	{
		if (opcodePass == 1)
		{
			beginop(OP_multiply);
		}
	}

	public void OP_multiply_p(int param)
	{
		if (opcodePass == 1)
		{
			beginop(OP_multiply_p);
			opcodes.writeU32(param);
		}
	}

	public void OP_multiply_i()
	{
		if (opcodePass == 1)
		{
			beginop(OP_multiply_i);
		}
	}

	public void OP_divide()
	{
		if (opcodePass == 1)
		{
			beginop(OP_divide);
		}
	}

	public void OP_divide_p(int param)
	{
		if (opcodePass == 1)
		{
			beginop(OP_divide_p);
			opcodes.writeU32(param);
		}
	}

	public void OP_modulo()
	{
		if (opcodePass == 1)
		{
			beginop(OP_modulo);
		}
	}

	public void OP_modulo_p(int param)
	{
		if (opcodePass == 1)
		{
			beginop(OP_modulo_p);
			opcodes.writeU32(param);
		}
	}

	public void OP_lshift()
	{
		if (opcodePass == 1)
		{
			beginop(OP_lshift);
		}
	}

	public void OP_rshift()
	{
		if (opcodePass == 1)
		{
			beginop(OP_rshift);
		}
	}

	public void OP_urshift()
	{
		if (opcodePass == 1)
		{
			beginop(OP_urshift);
		}
	}

	public void OP_bitand()
	{
		if (opcodePass == 1)
		{
			beginop(OP_bitand);
		}
	}

	public void OP_bitor()
	{
		if (opcodePass == 1)
		{
			beginop(OP_bitor);
		}
	}

	public void OP_bitxor()
	{
		if (opcodePass == 1)
		{
			beginop(OP_bitxor);
		}
	}

	public void OP_equals()
	{
		if (opcodePass == 1)
		{
			beginop(OP_equals);
		}
	}

	public void OP_strictequals()
	{
		if (opcodePass == 1)
		{
			beginop(OP_strictequals);
		}
	}

	public void OP_lookupswitch(int defaultPos, int[] casePos, int oldPos, int oldTablePos)
	{
		if (opcodePass == 1)
		{
			opcodes.mapOffsets(oldPos);
			beginop(OP_lookupswitch);
			opcodes.mapOffsets(oldPos+1);
			opcodes.writeS24(defaultPos);
			opcodes.writeU32((casePos == null || casePos.length == 0) ? 0 : casePos.length - 1);
			for (int i = 0, size = casePos.length; i < size; i++)
			{
				opcodes.mapOffsets(oldTablePos+3*i);
				opcodes.writeS24(casePos[i]);
			}
		}
		else if (opcodePass == 2)
		{
			opcodes.updateOffset(oldPos + 1, oldPos, oldPos + defaultPos);
			for (int i = 0, size = casePos.length; i < size; i++)
			{
				opcodes.updateOffset(oldTablePos + (3 * i), oldPos, oldPos + casePos[i]);
			}
		}
	}

	public void OP_iftrue(int offset, int pos)
	{
		if (opcodePass == 1)
		{
			if (opat(1) == OP_convert_b)
				rewind(1);

			if (opat(1) == OP_pushtrue)
			{
				rewind(1);
				OP_jump(offset,pos);
				return;
			}
			
			beginop(OP_iftrue);
			opcodes.writeS24(offset);
			opcodes.mapOffsets(pos);
		}
		else if (opcodePass == 2)
		{
			opcodes.updateOffset(pos + offset);
		}
	}

	public void OP_iffalse(int offset, int pos)
	{
		if (opcodePass == 1)
		{
			if (opat(1) == OP_convert_b)
			{
				rewind(1);
			}

			if (opat(2) == OP_strictequals && opat(1) == OP_not)
			{
				rewind(2);
				OP_ifstricteq(offset, pos);
				return;
			}
			
			if (opat(2) == OP_equals && opat(1) == OP_not)
			{
				rewind(2);
				OP_ifeq(offset, pos);
				return;
			}
			
			if (opat(1) == OP_not)
			{
				rewind(1);
				OP_iftrue(offset, pos);
				return;
			}
			
			if (opat(1) == OP_pushfalse)
			{
				rewind(1);
				OP_jump(offset, pos);
				return;
			}
			
			beginop(OP_iffalse);
			opcodes.writeS24(offset);
			opcodes.mapOffsets(pos);
		}
		else if (opcodePass == 2)
		{
			opcodes.updateOffset(pos + offset);
		}
	}

	public void OP_ifeq(int offset, int pos)
	{
		if (opcodePass == 1)
		{
			beginop(OP_ifeq);
			opcodes.writeS24(offset);
			opcodes.mapOffsets(pos);
		}
		else if (opcodePass == 2)
		{
			opcodes.updateOffset(pos + offset);
		}
	}

	public void OP_ifne(int offset, int pos)
	{
		if (opcodePass == 1)
		{
			beginop(OP_ifne);
			opcodes.writeS24(offset);
			opcodes.mapOffsets(pos);
		}
		else if (opcodePass == 2)
		{
			opcodes.updateOffset(pos + offset);
		}
	}

	public void OP_ifstricteq(int offset, int pos)
	{
		if (opcodePass == 1)
		{
			beginop(OP_ifstricteq);
			opcodes.writeS24(offset);
			opcodes.mapOffsets(pos);
		}
		else if (opcodePass == 2)
		{
			opcodes.updateOffset(pos + offset);
		}
	}

	public void OP_ifstrictne(int offset, int pos)
	{
		if (opcodePass == 1)
		{
			beginop(OP_ifstrictne);
			opcodes.writeS24(offset);
			opcodes.mapOffsets(pos);
		}
		else if (opcodePass == 2)
		{
			opcodes.updateOffset(pos + offset);
		}
	}

	public void OP_iflt(int offset, int pos)
	{
		if (opcodePass == 1)
		{
			beginop(OP_iflt);
			opcodes.writeS24(offset);
			opcodes.mapOffsets(pos);
		}
		else if (opcodePass == 2)
		{
			opcodes.updateOffset(pos + offset);
		}
	}

	public void OP_ifle(int offset, int pos)
	{
		if (opcodePass == 1)
		{
			beginop(OP_ifle);
			opcodes.writeS24(offset);
			opcodes.mapOffsets(pos);
		}
		else if (opcodePass == 2)
		{
			opcodes.updateOffset(pos + offset);
		}
	}

	public void OP_ifgt(int offset, int pos)
	{
		if (opcodePass == 1)
		{
			beginop(OP_ifgt);
			opcodes.writeS24(offset);
			opcodes.mapOffsets(pos);
		}
		else if (opcodePass == 2)
		{
			opcodes.updateOffset(pos + offset);
		}
	}

	public void OP_ifge(int offset, int pos)
	{
		if (opcodePass == 1)
		{
			beginop(OP_ifge);
			opcodes.writeS24(offset);
			opcodes.mapOffsets(pos);
		}
		else if (opcodePass == 2)
		{
			opcodes.updateOffset(pos + offset);
		}
	}

	public void OP_lessthan()
	{
		if (opcodePass == 1)
		{
			beginop(OP_lessthan);
		}
	}

	public void OP_lessequals()
	{
		if (opcodePass == 1)
		{
			beginop(OP_lessequals);
		}
	}

	public void OP_greaterthan()
	{
		if (opcodePass == 1)
		{
			beginop(OP_greaterthan);
		}
	}

	public void OP_greaterequals()
	{
		if (opcodePass == 1)
		{
			beginop(OP_greaterequals);
		}
	}

	public void OP_newobject(int size)
	{
		if (opcodePass == 1)
		{
			if (opat(1) == OP_coerce_a && size >= 1)
				rewind(1);

			beginop(OP_newobject);
			opcodes.writeU32(size);
		}
	}

	public void OP_newarray(int size)
	{
		if (opcodePass == 1)
		{
			beginop(OP_newarray);
			opcodes.writeU32(size);
		}
	}

	public void OP_getproperty(int index)
	{
		if (opcodePass == 1)
		{
			if (opat(1) == OP_findpropstrict && readIntAt(1) == pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index))
			{
				rewind(1);
				OP_getlex(index);
				return;
			}

			beginop(OP_getproperty);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
		}
	}

    public void OP_setproperty(int index)
    {
        if (opcodePass == 1)
        {
            if (opat(1) == OP_coerce_a)
                rewind(1);

            beginop(OP_setproperty);
            opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
        }
    }

    public void OP_initproperty(int index)
    {
        if (opcodePass == 1)
        {
            if (opat(1) == OP_coerce_a)
                rewind(1);

            beginop(OP_initproperty);
            opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
        }
    }

	public void OP_getdescendants(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_getdescendants);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
		}
	}

	public void OP_findpropstrict(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_findpropstrict);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
		}
	}

	public void OP_findproperty(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_findproperty);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
		}
	}

	public void OP_finddef(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_finddef);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
		}
	}
	
	public void OP_getlex(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_getlex);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
		}
	}

	public void OP_nextname()
	{
		if (opcodePass == 1)
		{
			beginop(OP_nextname);
		}
	}

	public void OP_nextvalue()
	{
		if (opcodePass == 1)
		{
			beginop(OP_nextvalue);
		}
	}

	public void OP_hasnext()
	{
		if (opcodePass == 1)
		{
			beginop(OP_hasnext);
		}
	}

	public void OP_hasnext2(int objectRegister, int indexRegister)
	{
		if (opcodePass == 1)
		{
			beginop(OP_hasnext2);
			opcodes.writeU32(objectRegister);
			opcodes.writeU32(indexRegister);			
		}
	}
	
	public void OP_deleteproperty(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_deleteproperty);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
		}
	}

	public void OP_setslot(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_setslot);
			opcodes.writeU32(index);
		}
	}

	public void OP_getslot(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_getslot);
			opcodes.writeU32(index);
		}
	}

	public void OP_setglobalslot(int index)
	{
		if (opcodePass == 1)
		{
			if (opat(1) == OP_coerce_a)
				rewind(1);

			beginop(OP_setglobalslot);
			opcodes.writeU32(index);
		}
	}

	public void OP_getglobalslot(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_getglobalslot);
			opcodes.writeU32(index);
		}
	}

	public void OP_call(int size)
	{
		if (opcodePass == 1)
		{
			beginop(OP_call);
			opcodes.writeU32(size);
		}
	}

	public void OP_construct(int size)
	{
		if (opcodePass == 1)
		{
			beginop(OP_construct);
			opcodes.writeU32(size);
		}
	}

    public void OP_applytype(int size)
    {
        if (opcodePass == 1)
        {
            beginop(OP_applytype);
            opcodes.writeU32(size);
        }
    }

	public void OP_newfunction(int id)
	{
		if (opcodePass == 1)
		{
			beginop(OP_newfunction);
			opcodes.writeU32(methodInfo.getIndex(poolIndex, id));
		}
	}

	public void OP_newclass(int id)
	{
		if (opcodePass == 1)
		{
			beginop(OP_newclass);
			opcodes.writeU32(classInfo.getIndex(poolIndex, id));
		}
	}

	public void OP_callstatic(int id, int argc)
	{
		if (opcodePass == 1)
		{
			beginop(OP_callstatic);
			opcodes.writeU32(methodInfo.getIndex(poolIndex, id));
			opcodes.writeU32(argc);
		}
	}

	public void OP_callmethod(int id, int argc)
	{
		if (opcodePass == 1)
		{
			beginop(OP_callmethod);
			opcodes.writeU32(methodInfo.getIndex(poolIndex, id));
			opcodes.writeU32(argc);
		}
	}

	public void OP_callproperty(int index, int argc)
	{
		if (opcodePass == 1)
		{
	        if (opat(1) == OP_coerce_a)
	        	rewind(1);
			
			beginop(OP_callproperty);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
			opcodes.writeU32(argc);
		}
	}

	public void OP_callproplex(int index, int argc)
	{
		if (opcodePass == 1)
		{
			beginop(OP_callproplex);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
			opcodes.writeU32(argc);
		}
	}

	public void OP_constructprop(int index, int argc)
	{
		if (opcodePass == 1)
		{
			beginop(OP_constructprop);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
			opcodes.writeU32(argc);
		}
	}

	public void OP_callsuper(int index, int argc)
	{
		if (opcodePass == 1)
		{
			beginop(OP_callsuper);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
			opcodes.writeU32(argc);
		}
	}

	public void OP_getsuper(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_getsuper);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
		}
	}

	public void OP_setsuper(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_setsuper);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
		}
	}

	public void OP_constructsuper(int argc)
	{
		if (opcodePass == 1)
		{
			beginop(OP_constructsuper);
			opcodes.writeU32(argc);
		}
	}

	public void OP_pushshort(int n)
	{
		if (opcodePass == 1)
		{
			if (peepHole && n >= -128 && n <= 127)
			{
				OP_pushbyte(n);
				return;
			}
			beginop(OP_pushshort);
			opcodes.writeU32(n);
		}
	}

	public void OP_astype(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_astype);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
		}
	}

	public void OP_astypelate()
	{
		if (opcodePass == 1)
		{
			beginop(OP_astypelate);
		}
	}

	public void OP_coerce(int index)
	{
		if (opcodePass == 1)
		{
			if (opat(1) == OP_coerce && readIntAt(1) == pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index))
			{
				// second coerce to same type is redundant
				return;
			}

			beginop(OP_coerce);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
		}
	}

	public void OP_coerce_b()
	{
		if (opcodePass == 1)
		{
			beginop(OP_coerce_b);
		}
	}

	public void OP_coerce_o()
	{
		if (opcodePass == 1)
		{
			beginop(OP_coerce_o);
		}
	}

	public void OP_coerce_a()
	{
		if (opcodePass == 1)
		{
			if (opat(1) == OP_coerce_a)
				return;
			beginop(OP_coerce_a);
		}
	}

	public void OP_coerce_i()
	{
		if (opcodePass == 1)
		{
			switch (opat(1))
			{
				case OP_coerce_i :
				case OP_convert_i :
				case OP_increment_i :
				case OP_decrement_i :
				case OP_pushbyte :
				case OP_pushshort :
				case OP_pushint :
				case OP_bitand:
				case OP_bitor:
				case OP_bitxor:
				case OP_lshift:
				case OP_rshift:
				case OP_add_i:
				case OP_subtract_i:
				case OP_multiply_i:
				case OP_bitnot:
					// coerce is redundant
					return;
			}
			beginop(OP_coerce_i);
		}
	}

	public void OP_coerce_u()
	{
		if (opcodePass == 1)
		{
			switch (opat(1))
			{
			case OP_coerce_u:
			case OP_convert_u:
			case OP_urshift:
				// redundant coerce
				return;
			}
			beginop(OP_coerce_u);
		}
	}

	public void OP_coerce_d()
	{
		if (opcodePass == 1)
		{
			switch (opat(1))
			{
				case OP_subtract :
				case OP_multiply :
				case OP_divide :
				case OP_modulo :
				case OP_increment :
				case OP_decrement :
				case OP_inclocal :
				case OP_declocal :
				case OP_coerce_d :
				case OP_convert_d :
					// coerce is redundant
					return;
			}
			beginop(OP_coerce_d);
		}
	}

	public void OP_coerce_s()
	{
		if (opcodePass == 1)
		{
			switch (opat(1))
			{
			case OP_coerce_s:
			case OP_convert_s:
			case OP_pushstring:
			case OP_typeof:
				// result is already string
				return;
			}
			
			if (opat(2) == OP_pushstring && opat(1) == OP_add)
			{
				// result must be string, so dont coerce after
				return;
			}

			beginop(OP_coerce_s);
		}
	}

	public void OP_istype(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_istype);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
		}
	}

	public void OP_istypelate()
	{
		if (opcodePass == 1)
		{
			beginop(OP_istypelate);
		}
	}

	public void OP_pushbyte(int n)
	{
		if (opcodePass == 1)
		{
			if (opat(1) == OP_pushbyte && readByteAt(1) == n ||
				opat(1) == OP_dup && opat(2) == OP_pushbyte && readByteAt(2) == n )
			{
				OP_dup();
				return;
			}
			beginop(OP_pushbyte);
			opcodes.writeU8(n);
		}
	}

	public void OP_getscopeobject(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_getscopeobject);
			opcodes.writeU8(index);
		}
	}

	public void OP_pushscope()
	{
		if (opcodePass == 1)
		{
			beginop(OP_pushscope);
		}
	}

	public void OP_popscope()
	{
		if (opcodePass == 1)
		{
			beginop(OP_popscope);
		}
	}

	public void OP_convert_i()
	{
		if (opcodePass == 1)
		{
			switch (opat(1))
			{
			case OP_convert_i:
			case OP_coerce_i:
			case OP_bitand:
			case OP_bitor:
			case OP_bitxor:
			case OP_lshift:
			case OP_rshift:
			case OP_add_i:
			case OP_subtract_i:
			case OP_increment_i:
			case OP_decrement_i:
			case OP_multiply_i:
			case OP_pushbyte:
			case OP_pushshort:
			case OP_pushint:
				return;
			}
			
			beginop(OP_convert_i);
		}
	}

	public void OP_convert_u()
	{
		if (opcodePass == 1)
		{
			beginop(OP_convert_u);
		}
	}

	public void OP_throw()
	{
		if (opcodePass == 1)
		{
			beginop(OP_throw);
		}
	}

	public void OP_instanceof()
	{
		if (opcodePass == 1)
		{
			beginop(OP_instanceof);
		}
	}

	public void OP_in()
	{
		if (opcodePass == 1)
		{
			beginop(OP_in);
		}
	}

	public void OP_dxns(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_dxns);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_string, index));
		}
	}

	public void OP_dxnslate()
	{
		if (opcodePass == 1)
		{
			beginop(OP_dxnslate);
		}
	}

	public void OP_ifnlt(int offset, int pos)
	{
		if (opcodePass == 1)
		{
			beginop(OP_ifnlt);
			opcodes.writeS24(offset);
			opcodes.mapOffsets(pos);
		}
		else if (opcodePass == 2)
		{
			opcodes.updateOffset(pos + offset);
		}
	}

	public void OP_ifnle(int offset, int pos)
	{
		if (opcodePass == 1)
		{
			beginop(OP_ifnle);
			opcodes.writeS24(offset);
			opcodes.mapOffsets(pos);
		}
		else if (opcodePass == 2)
		{
			opcodes.updateOffset(pos + offset);
		}
	}

	public void OP_ifngt(int offset, int pos)
	{
		if (opcodePass == 1)
		{
			beginop(OP_ifngt);
			opcodes.writeS24(offset);
			opcodes.mapOffsets(pos);
		}
		else if (opcodePass == 2)
		{
			opcodes.updateOffset(pos + offset);
		}
	}

	public void OP_ifnge(int offset, int pos)
	{
		if (opcodePass == 1)
		{
			beginop(OP_ifnge);
			opcodes.writeS24(offset);
			opcodes.mapOffsets(pos);
		}
		else if (opcodePass == 2)
		{
			opcodes.updateOffset(pos + offset);
		}
	}

	public void OP_pushwith()
	{
		if (opcodePass == 1)
		{
			beginop(OP_pushwith);
		}
	}

	public void OP_newactivation()
	{
		if (opcodePass == 1)
		{
			beginop(OP_newactivation);
		}
	}

	public void OP_newcatch(int index)
	{
		if (opcodePass == 1)
		{
			beginop(OP_newcatch);
			opcodes.writeU32(index);			
		}
	}

	public void OP_deldescendants()
	{
		if (opcodePass == 1)
		{
			beginop(OP_deldescendants);
		}
	}

	public void OP_getglobalscope()
	{
		if (opcodePass == 1)
		{
			beginop(OP_getglobalscope);
		}
	}

	public void OP_getlocal0()
	{
		if (opcodePass == 1)
		{
			beginop(OP_getlocal0);
		}
	}

	public void OP_getlocal1()
	{
		if (opcodePass == 1)
		{
			beginop(OP_getlocal1);
		}
	}

	public void OP_getlocal2()
	{
		if (opcodePass == 1)
		{
			beginop(OP_getlocal2);
		}
	}

	public void OP_getlocal3()
	{
		if (opcodePass == 1)
		{
			beginop(OP_getlocal3);
		}
	}

	public void OP_setlocal0()
	{
		if (opcodePass == 1)
		{
			beginop(OP_setlocal0);
		}
	}

	public void OP_setlocal1()
	{
		if (opcodePass == 1)
		{
			if (opat(2) == OP_getlocal1 && opat(1) == OP_increment_i)
			{
				rewind(2);
				OP_inclocal_i(1);
				return;
			}
			if (opat(2) == OP_getlocal1 && opat(1) == OP_increment)
			{
				rewind(2);
				OP_inclocal(1);
				return;
			}
			beginop(OP_setlocal1);
		}
	}

	public void OP_setlocal2()
	{
		if (opcodePass == 1)
		{
			if (opat(2) == OP_getlocal2 && opat(1) == OP_increment_i)
			{
				rewind(2);
				OP_inclocal_i(2);
				return;
			}
			if (opat(2) == OP_getlocal2 && opat(1) == OP_increment)
			{
				rewind(2);
				OP_inclocal(2);
				return;
			}
			beginop(OP_setlocal2);
		}
	}

	public void OP_setlocal3()
	{
		if (opcodePass == 1)
		{
			if (opat(2) == OP_getlocal3 && opat(1) == OP_increment_i)
			{
				rewind(2);
				OP_inclocal_i(3);
				return;
			}
			if (opat(2) == OP_getlocal3 && opat(1) == OP_increment)
			{
				rewind(2);
				OP_inclocal(3);
				return;
			}
			beginop(OP_setlocal3);
		}
	}
	
	public void OP_label()
	{
		if (opcodePass == 1)
		{
			beginop(OP_label);
		}
	}

	public void OP_pushconstant(int id)
	{
		if (opcodePass == 1)
		{
			beginop(OP_pushuninitialized);
			opcodes.writeU32(id);
		}
	}

	public void OP_callsupervoid(int index, int argc)
	{
		if (opcodePass == 1)
		{
			beginop(OP_callsupervoid);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
			opcodes.writeU32(argc);
		}
	}

	public void OP_callpropvoid(int index, int argc)
	{
		if (opcodePass == 1)
		{
			beginop(OP_callpropvoid);
			opcodes.writeU32(pool.history.getIndex(poolIndex, IndexHistory.cp_mn, index));
			opcodes.writeU32(argc);
		}
	}

    public void OP_li8()
    {
        if( opcodePass == 1 )
        {
            beginop(OP_li8);
        }
    }

    public void OP_li16()
    {
        if( opcodePass == 1 )
        {
            beginop(OP_li16);
        }
    }

    public void OP_li32()
    {
        if( opcodePass == 1 )
        {
            beginop(OP_li32);
        }
    }

    public void OP_lf32()
    {
        if( opcodePass == 1 )
        {
            beginop(OP_lf32);
        }
    }

    public void OP_lf64()
    {
        if( opcodePass == 1 )
        {
            beginop(OP_lf64);
        }
    }

    public void OP_si8()
    {
        if( opcodePass == 1 )
        {
            beginop(OP_si8);
        }
    }

    public void OP_si16()
    {
        if( opcodePass == 1 )
        {
            beginop(OP_si16);
        }
    }

    public void OP_si32()
    {
        if( opcodePass == 1 )
        {
            beginop(OP_si32);
        }
    }

    public void OP_sf32()
    {
        if( opcodePass == 1 )
        {
            beginop(OP_sf32);
        }
    }

    public void OP_sf64()
    {
        if( opcodePass == 1 )
        {
            beginop(OP_sf64);
        }
    }

    public void OP_sxi1()
    {
        if( opcodePass == 1 )
        {
            beginop(OP_sxi1);
        }
    }

    public void OP_sxi8()
    {
        if( opcodePass == 1 )
        {
            beginop(OP_sxi8);
        }
    }

    public void OP_sxi16()
    {
        if( opcodePass == 1 )
        {
            beginop(OP_sxi16);
        }
    }

    class ByteArrayPool2 extends ByteArrayPool
    {
        ByteArrayPool2(int[] sizes)
        {
            this.sizes = sizes;
            indexes = new HashMap<Integer, Integer>();
        }

        int size = 0;

        private int[] sizes;

        private Map<Integer, Integer> indexes;

        int addByteArray(int poolIndex, int oldIndex, BytecodeBuffer ba)
        {
            int index = this.contains(ba, 0, ba.size());
            if( index == -1 )
            {
                index = this.store(ba, 0, ba.size());
                size += ba.size();
            }
            // ByteArrayPool is 1 based, we want zero based for metadataInfos
            indexes.put(IntegerPool.getNumber(calcIndex(poolIndex, oldIndex)), IntegerPool.getNumber(index-1));
            return index;
        }

        private int calcIndex(int poolIndex, int oldIndex)
        {
            int newIndex = 0;
            for (int i = 0; i < poolIndex; i++)
            {
                newIndex += sizes[i];
            }
            newIndex += oldIndex;

            return newIndex;
        }

        int getIndex(int poolIndex, int oldIndex)
        {
            int newIndex = calcIndex(poolIndex, oldIndex);
            Integer i = indexes.get(IntegerPool.getNumber(newIndex));
            return i != null ? i.intValue() : -1;
        }

        int size()
        {
            return size;
        }

        void writeTo(BytecodeBuffer b)
        {
            Map sortedMap = new TreeMap();

            for (Iterator i = map.keySet().iterator(); i.hasNext();)
            {
                Object key = i.next(); // ByteArray
                Object value = map.get(key); // Integer
                sortedMap.put(value, key);
            }

            b.writeU32((sortedMap.size() == 0) ? 0 : sortedMap.size() );

            for (Iterator i = sortedMap.keySet().iterator(); i.hasNext();)
            {
                Integer index = (Integer) i.next();
                ByteArray a = (ByteArray) sortedMap.get(index);
                b.writeBytes(a.b, a.start, a.end);
            }
        }

        void writeTo(OutputStream os) throws java.io.IOException
        {
            BytecodeBuffer b = new BytecodeBuffer(size());
            writeTo(b);
            b.writeTo(os);
        }
    }

	class BytecodeBuffer2 extends BytecodeBuffer
	{
		BytecodeBuffer2(int estimatedSize, int[] sizes)
		{
			super(estimatedSize);
			this.sizes = sizes;
			this.estimatedSize = estimatedSize;
		}

		private int[] sizes;
		int estimatedSize;

		int getIndex(int poolIndex, int oldIndex)
		{
			int newIndex = 0;
			for (int i = 0; i < poolIndex; i++)
			{
				newIndex += sizes[i];
			}
			newIndex += oldIndex;

			return newIndex;
		}
	}

	class BytecodeBuffer3 extends BytecodeBuffer
	{
		BytecodeBuffer3(Decoder[] decoders, int estimatedSize)
		{
			super(estimatedSize);
			offsets = new HashMap<Integer, Integer>();
			this.decoders = decoders;
		}

		Map<Integer, Integer> offsets;
		Decoder[] decoders;

		void mapOffsets(long offset)
		{
			Integer oldPos = IntegerPool.getNumber((int) offset);
			Integer newPos = IntegerPool.getNumber(size());

			offsets.put(IntegerPool.getNumber(oldPos), IntegerPool.getNumber(newPos));
		}

		long getOffset(long offset)
		{
			Integer i = offsets.get(IntegerPool.getNumber((int) offset));
			if (i != null)
			{
				return i.intValue();
			}
			else
			{
				System.out.println("getOffset: can't match " + offset + " with a new offset ");
				System.out.println(offsets);
				return 0;
			}
		}

		void updateOffset(long offset)
		{
			Integer i = offsets.get(IntegerPool.getNumber((int) offset));
			Integer p = offsets.get(IntegerPool.getNumber(decoders[poolIndex].pos()));

			if (i != null && p != null)
			{
				writeS24(p-3, i-p);
			}
			else
			{
				/* cn: temporarily disable this warning.  The warnings that are being generated are
				 *     for jumps which are part of unreachable code, but I haven't found where those
				 *     unecessary jumps are being genreated within codeGenerator yet.  Disabling to redeuce
				 *     annoyance in the short term, 
				 *     bug #149141 remains open until the root cause is found and removed
				if (i == null)
					System.out.println("updateOffset1: can't match i " + offset + " with a new offset");
				if (p == null)
					System.out.println("updateOffset1: can't match p " + decoders[poolIndex].pos() + " with a new offset");
				System.out.println(offsets);
				*/
			}
		}

		void updateOffset(long oldOffsetPos, long oldPos, long oldTarget)
		{
			Integer i = offsets.get(IntegerPool.getNumber((int) oldTarget));
			Integer p = offsets.get(IntegerPool.getNumber((int) oldPos));
			Integer s = offsets.get(IntegerPool.getNumber((int) oldOffsetPos));

			if (i != null && p != null && s != null)
			{
				writeS24(s, i-p);
			}
			else
			{
				if (i == null)
					System.out.println("updateOffset2: can't match i " + oldTarget + " with a new offset");
				if (p == null)
					System.out.println("updateOffset2: can't match p " + oldPos + " with a new offset");
				if (s == null)
					System.out.println("updateOffset2: can't match s " + oldOffsetPos + " with a new offset");
				System.out.println(offsets);
			}
		}

		public void clear()
		{
			super.clear();
			offsets.clear();
		}
	}
}

