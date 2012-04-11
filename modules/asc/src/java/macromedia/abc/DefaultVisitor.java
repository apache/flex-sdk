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
 * High-level visitor interface
 * 
 * @author Clement Wong
 */
public abstract class DefaultVisitor implements Visitor
{
	public DefaultVisitor(Decoder decoder)
	{
		this.decoder = decoder;
	}

	protected Decoder decoder;

	public abstract void beginABC();

	public abstract void endABC();

	public abstract void metadata(String name, String[] keys, String[] values);

	public abstract void beginClass(QName name, int slotID);

	public abstract void instanceInfo(QName name, QName superName, MultiName[] interfaces);

	public abstract void beginIInit(int methodInfo);

	public abstract void endIInit();

	public abstract void classInfo(QName name);

	public abstract void beginCInit(int methodInfo);

	public abstract void endCInit();

	public abstract void endClass(QName name);

	public abstract void beginVar(QName name, int slotID, QName type, Object value);

	public abstract void endVar(QName name);

	public abstract void beginConst(QName name, int slotID, QName type, Object value);

	public abstract void endConst(QName name);

	public abstract void methodInfo(QName returnType, QName[] paramTypes, String nativeName, int flags, Object[] values, String[] param_names);

	public abstract void beginGetter(int methodInfo, QName name, int dispID, int attr);

	public abstract void endGetter(QName name);

	public abstract void beginSetter(int methodInfo, QName name, int dispID, int attr);

	public abstract void endSetter(QName name);

	public abstract void beginMethod(int methodInfo, QName name, int dispID, int attr);

	public abstract void endMethod(QName name);

	public abstract void beginFunction(int methodInfo, QName name, int slotID);

	public abstract void endFunction(QName name);

	public abstract void beginBody(int methodID, int codeStart, long codeLength);

	public abstract void endBody();

	public final void methodInfo(int returnTypeID, int[] paramTypeIDs, int nativeNameID, int flags, int[] valueIDs, int[] value_kinds, int[] param_names) throws DecoderException
	{
		QName returnType = decoder.constantPool.getQName(returnTypeID);
		String nativeName = decoder.constantPool.getString(nativeNameID);
		QName[] params = null;
		Object[] values = null;
        String[] arg_names = null;

		if (paramTypeIDs != null)
		{
			params = new QName[paramTypeIDs.length];

			for (int j = 0; j < params.length; j++)
			{
				params[j] = decoder.constantPool.getQName(paramTypeIDs[j]);
			}
		}

		if (valueIDs != null)
		{
			values = new Object[valueIDs.length];

			for (int j = 0; j < values.length; j++)
			{
				values[j] = decoder.constantPool.get(valueIDs[j], value_kinds[j]);
			}
		}
        if( param_names != null )
        {
            arg_names = new String[param_names.length];

            for (int j = 0; j < param_names.length; j++)
            {
                arg_names[j] = decoder.constantPool.getString(param_names[j]);
            }
        }

		methodInfo(returnType, params, nativeName, flags, values, arg_names);
	}

	public final void metadataInfo(int index, int nameID, int[] keyIDs, int[] valueIDs) throws DecoderException
	{
		String name = decoder.constantPool.getString(nameID);
		String[] keys = null, values = null;

		if (keyIDs != null)
		{
			keys = new String[keyIDs.length];

			for (int i = 0; i < keyIDs.length; i++)
			{
				keys[i] = decoder.constantPool.getString(keyIDs[i]);
			}
		}

		if (valueIDs != null)
		{
			values = new String[valueIDs.length];

			for (int i = 0; i < valueIDs.length; i++)
			{
				values[i] = decoder.constantPool.getString(valueIDs[i]);
			}
		}

		metadata(name, keys, values);
	}

	public final void traitCount(int traitCount)
	{
	}

	public final void slotTrait(int kind, int nameID, int slotID, int typeID, int valueID, int value_kind, int[] metadata) throws DecoderException
	{
		QName name = decoder.constantPool.getQName(nameID);
		QName type = decoder.constantPool.getQName(typeID);
		Object value = decoder.constantPool.get(valueID, value_kind);

		int tag = kind & 0x0f;

		if (tag == TRAIT_Var)
		{
			beginVar(name, slotID, type, value);
		}
		else
		{
			beginConst(name, slotID, type, value);
		}

		if (metadata != null)
		{
			for (int i = 0, length = metadata.length; i < length; i++)
			{
				decoder.metadataInfo.decode(metadata[i], this);
			}
		}

		if (tag == TRAIT_Var)
		{
			endVar(name);
		}
		else
		{
			endConst(name);
		}
	}

	public final void methodTrait(int kind, int nameID, int dispID, int methodInfoID, int[] metadata) throws DecoderException
	{
		QName name = decoder.constantPool.getQName(nameID);
		int tag = kind & 0x0f;
		int attr = kind >> 4;

		if (tag == TRAIT_Getter)
		{
			beginGetter(methodInfoID, name, dispID, attr);
		}
		else if (tag == TRAIT_Setter)
		{
			beginSetter(methodInfoID, name, dispID, attr);
		}
		else // if (tag == TRAIT_Method)
		{
			beginMethod(methodInfoID, name, dispID, attr);
		}

		decoder.methodInfo.decode(methodInfoID, this);

		if (metadata != null)
		{
			for (int i = 0, length = metadata.length; i < length; i++)
			{
				decoder.metadataInfo.decode(metadata[i], this);
			}
		}

		if (tag == TRAIT_Getter)
		{
			endGetter(name);
		}
		else if (tag == TRAIT_Setter)
		{
			endSetter(name);
		}
		else // if (tag == TRAIT_Method)
		{
			endMethod(name);
		}
	}

	public final void classTrait(int kind, int nameID, int slotID, int classIndex, int[] metadata) throws DecoderException
	{
		QName name = decoder.constantPool.getQName(nameID);

		beginClass(name, slotID);

		decoder.classInfo.decode(classIndex, this);

		if (metadata != null)
		{
			for (int i = 0, length = metadata.length; i < length; i++)
			{
				decoder.metadataInfo.decode(metadata[i], this);
			}
		}

		endClass(name);
	}

	public final void functionTrait(int kind, int nameID, int slotID, int methodInfoID, int[] metadata) throws DecoderException
	{
		QName name = decoder.constantPool.getQName(nameID);

		beginFunction(methodInfoID, name, slotID);

		decoder.methodInfo.decode(methodInfoID, this);

		if (metadata != null)
		{
			for (int i = 0, length = metadata.length; i < length; i++)
			{
				decoder.metadataInfo.decode(metadata[i], this);
			}
		}

		endFunction(name);
	}

	public final void startInstance(int nameID, int superNameID, boolean isDynamic, boolean isFinal, boolean isInteface, int[] interfaceIDs, int iinitID, int protectedNamespace) throws DecoderException
	{
		QName name = decoder.constantPool.getQName(nameID);
		QName superName = decoder.constantPool.getQName(superNameID);
		MultiName[] interfaces = null;

		if (interfaceIDs != null)
		{
			interfaces = new MultiName[interfaceIDs.length];

			for (int j = 0; j < interfaces.length; j++)
			{
				interfaces[j] = decoder.constantPool.getMultiName(interfaceIDs[j]);
			}
		}

		instanceInfo(name, superName, interfaces);

		beginIInit(iinitID);

		decoder.methodInfo.decode(iinitID, this);

		endIInit();
	}

	public final void endInstance()
	{
	}

	public final void startClass(int nameID, int cinit) throws DecoderException
	{
		QName name = decoder.constantPool.getQName(nameID);

		classInfo(name);

		beginCInit(cinit);

		decoder.methodInfo.decode(cinit, this);

		endCInit();
	}

	public final void endClass()
	{
	}

	public final void startScript(int initID)
	{
		beginABC();
	}

	public final void endScript()
	{
		endABC();
	}

	public final void startMethodBody(int methodInfo, int maxStack, int maxRegs, int scopeDepth, int maxScope, int codeStart, long codeLength) throws DecoderException
	{
		beginBody(methodInfo, codeStart, codeLength);
	}

	public final void endMethodBody()
	{
		endBody();
	}

	public final void startOpcodes(int methodInfo)
	{
	}

	public final void endOpcodes()
	{
	}
	
	public final void exception(long start, long end, long target, int type, int name)
	{
	}

	public final void startExceptions(int exceptionCount)
	{
	}

	public final void endExceptions()
	{
	}
}
