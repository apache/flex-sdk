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

/**
 * @author Clement Wong
 */
public final class Scanner
{
	public static int scanMinorVersion(BytecodeBuffer in)
	{
		int position = in.pos();
		in.skip(2);
		return position;
	}

	public static int scanMajorVersion(BytecodeBuffer in)
	{
		int position = in.pos();
		in.skip(2);
		return position;
	}

    public static int[] scanIntConstants(BytecodeBuffer in)
    {
        int size = in.readU32();
        int[] positions = new int[size];
        for (int i = 1; i < size; i++)
        {
            positions[i] = in.pos();
            in.readU32();
        }
        return positions;
    }

    public static int[] scanUIntConstants(BytecodeBuffer in)
    {
        int size = in.readU32();
        int[] positions = new int[size];
        for (int i = 1; i < size; i++)
        {
            positions[i] = in.pos();
            in.readU32();
        }
        return positions;
    }

    public static int[] scanDoubleConstants(BytecodeBuffer in)
    {
        int size = in.readU32();
        int[] positions = new int[size];
        for (int i = 1; i < size; i++)
        {
            positions[i] = in.pos();
            in.readDouble();
        }
        return positions;
    }

    public static int[] scanDecimalConstants(BytecodeBuffer in)
    {
        int size = in.readU32();
        int[] positions = new int[size];
        for (int i = 1; i < size; i++)
        {
            positions[i] = in.pos();
            in.readBytes(16);
        }
        return positions;
    }

    public static int[] scanStrConstants(BytecodeBuffer in)
    {
        int size = in.readU32();
        int[] positions = new int[size];
        for (int i = 1; i < size; i++)
        {
            positions[i] = in.pos();
            long length = in.readU32();
            in.skip(length);
        }
        return positions;
    }

    public static int[] scanNsConstants(BytecodeBuffer in)
    {
        int size = in.readU32();
        int[] positions = new int[size];
        for (int i = 1; i < size; i++)
        {
            positions[i] = in.pos();
            in.readU8(); // kind byte
            in.readU32();
        }
        return positions;
    }

    public static int[] scanNsSetConstants(BytecodeBuffer in)
    {
        int size = in.readU32();
        int[] positions = new int[size];
        for (int i = 1; i < size; i++)
        {
            positions[i] = in.pos();
            long count = in.readU32();
            in.skipEntries(count);
        }
        return positions;
    }

    public static int[] scanMultinameConstants(BytecodeBuffer in) throws DecoderException
    {
        int size = in.readU32();
        int[] positions = new int[size];
        for (int i = 1; i < size; i++)
        {
            positions[i] = in.pos();
            int kind = in.readU8(); // kind byte
            switch(kind)
            {
                case CONSTANT_Qname:
                case CONSTANT_QnameA:
                    in.readU32();
                    in.readU32();
                    break;
                case CONSTANT_RTQname:
                case CONSTANT_RTQnameA:
                    in.readU32();
                    break;
                case CONSTANT_Multiname:
                case CONSTANT_MultinameA:
                    in.readU32();
                    in.readU32();
                    break;
                case CONSTANT_RTQnameL:
                case CONSTANT_RTQnameLA:
					break;
                case CONSTANT_MultinameL:
                case CONSTANT_MultinameLA:
					in.readU32();
                    break;
                case CONSTANT_TypeName:
                    in.readU32(); // name index
                    long count = in.readU32(); // param count;
                    in.skipEntries(count);
                    break;
                default:
                    throw new DecoderException("Invalid constant type: " + kind);
            }
        }
        return positions;
    }

	public static int[] scanMethods(BytecodeBuffer in)
	{
		int size = in.readU32();
		int[] positions = new int[size];

		for (int i = 0; i < size; i++)
		{
			positions[i] = in.pos();

			long paramCount = in.readU32();
            in.readU32(); // ret type
			in.skipEntries(paramCount);
            in.readU32(); //name_index
			int flags = in.readU8();

			long optionalCount = ((flags & METHOD_HasOptional) != 0) ? in.readU32() : 0;
            for( long q = 0; q < optionalCount; ++q)
            {
                in.readU32();
                in.readU8();
            }
            long paramNameCount = ((flags & METHOD_HasParamNames)!=0) ? paramCount : 0;
            for( long q = 0; q < paramNameCount; ++q)
            {
                in.readU32();
            }
		}

		return positions;
	}

	public static int[] scanMetadata(BytecodeBuffer in)
	{
	    int size = in.readU32();
	    int[] positions = new int [size];

	    for (int i = 0; i < size; i++)
	    {
	        positions[i] = in.pos();

	        in.readU32();
	        long value_count = in.readU32();

	        in.skipEntries(value_count * 2);
	    }

		return positions;
	}

	public static int[] scanInstances(BytecodeBuffer in, int size)
	{
		int[] positions = new int[size];

		for (int i = 0; i < size; i++)
		{
			positions[i] = in.pos();

            in.skipEntries(2); //name & super index
			int flags = in.readU8();

			if ((flags & CLASS_FLAG_protected) != 0)
				in.readU32();//protected namespace
			
			long interfaceCount = in.readU32();
			in.skipEntries(interfaceCount);
			in.readU32(); //init index

			scanTraits(in);
		}

		return positions;
	}

	public static int[] scanClasses(BytecodeBuffer in, int size)
	{
		int[] positions = new int[size];

		for (int i = 0; i < size; i++)
		{
			positions[i] = in.pos();
			in.readU32();
			scanTraits(in);
		}

		return positions;
	}

	public static int[] scanScripts(BytecodeBuffer in)
	{
	    int size = in.readU32();
	    int[] positions = new int[size];

	    for (int i = 0 ; i < size; i++)
	    {
	        positions[i] = in.pos();
	        in.readU32();
	        scanTraits(in);
	    }

		return positions;
	}

	public static int[] scanMethodBodies(BytecodeBuffer in)
	{
		int size = in.readU32();
		int[] positions = new int[size];

		for (int i = 0; i < size; i++)
		{
			positions[i] = in.pos();

            in.skipEntries(5);

			long codeLength = in.readU32();
			in.skip((int) codeLength);

			scanExceptions(in);
			scanTraits(in);
		}

		return positions;
	}

	private static void scanExceptions(BytecodeBuffer in)
	{
		long count = in.readU32();
		if (in.minorVersion() == 15)
		{
			in.skipEntries(count * 4);
		}
		else
		{
			in.skipEntries(count * 5);
		}
	}

	private static void scanTraits(BytecodeBuffer in)
	{
		long count = in.readU32();

		for (long i = 0; i < count; i++)
		{
			in.readU32();
			int kind = in.readU8();
			int tag = kind & 0x0f;

			switch (tag)
			{
			case TRAIT_Var:
			case TRAIT_Const:
            {
				in.skipEntries(2);
                int valueId = in.readU32();
                if( valueId > 0 )
                    in.readU8();
				break;
            }
			case TRAIT_Method:
			case TRAIT_Getter:
			case TRAIT_Setter:
				in.skipEntries(2);
				break;
			case TRAIT_Class:
			case TRAIT_Function:
				in.skipEntries(2);
				break;
			default:
				// throw new DecoderException("Invalid trait type: " + kind);
				System.err.println("invalid trait type: " + tag);
				break;
			}

			if (((kind >> 4) & TRAIT_FLAG_metadata) != 0)
			{
				long metadata = in.readU32();
				in.skipEntries(metadata);
			}
		}
	}
}
