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

import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_Decimal;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_Double;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_ExplicitNamespace;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_False;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_Integer;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_Multiname;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_MultinameA;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_MultinameL;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_MultinameLA;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_TypeName;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_Namespace;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_Namespace_Set;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_Null;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_PackageInternalNs;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_PackageNamespace;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_PrivateNamespace;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_ProtectedNamespace;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_Qname;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_QnameA;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_RTQname;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_RTQnameA;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_RTQnameL;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_RTQnameLA;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_StaticProtectedNs;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_True;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_UInteger;
import static macromedia.asc.embedding.avmplus.ActionBlockConstants.CONSTANT_Utf8;

import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;

import macromedia.asc.util.Decimal128;
import macromedia.asc.util.IntegerPool;
import macromedia.asc.util.IntList;


/**
 * Constant {
 * U8 kind
 * union {
 * kind=1 { // CONSTANT_utf8
 * U16 length
 * U8[length]
 * }
 * kind=2 { // CONSTANT_Decimal
 * U8[16] value
 * }
 * kind=3 { // CONSTANT_Integer
 * S32 value
 * }
 * kind=4 { // CONSTANT_UInteger
 * U32 value
 * }
 * kind=6 { // CONSTANT_Double
 * U64 doublebits (little endian)
 * }
 * kind=7,13 { // CONSTANT_Qname + CONSTANT_QnameA
 * U16 namespace_index			// CONSTANT_Namespace, 0=AnyNamespace wildcard
 * U16 name_index					// CONSTANT_Utf8, 0=AnyName wildcard
 * }
 * kind=8,5 { // CONSTANT_Namespace, CONSTANT_PrivateNamespace
 * U16 name_index                    // CONSTANT_Utf8 uri (maybe 0)
 * }
 * kind=9,14 { // CONSTANT_Multiname, CONSTANT_MultinameA
 * U16 name_index                    // CONSTANT_Utf8  simple name.  0=AnyName wildcard
 * U16 namespaces_count              // (256 may seem like enough, but 64K use to seem like a lot of memory)
 * U16 namespaces[namespaces_count]  // CONSTANT_Namespace (0 = error)
 * }
 * kind=10 // CONSTANT_False
 * kind=11 // CONSTANT_True
 * kind=12 // CONSTANT_Null
 * kind=15,16 { // CONSTANT_RTQname + CONSTANT_RTQnameA
 * U16 name_index				// CONSTANT_utf8, 0=AnyName wildcard
 * }
 * kind=17,18 // CONSTANT_RTQnameL + CONSTANT_RTQnameLA
 * }
 * }
 *
 * @author Clement Wong
 */
public class ConstantPool
{
    public static final Object NULL = new Object();

    public boolean poolHasDecimal;

    public static ConstantPool merge(ConstantPool[] pools)
    {
        // create a new ConstantPool big enough for the combined pools.
        int preferredSize = 0;
        boolean hasDecimal = false;

        for (int i = 0, size = pools.length; i < size; i++)
        {
            if (pools[i].decimalpositions.length > 0)
                hasDecimal = true;
            preferredSize += pools[i].mnEnd;
        }

        ConstantPool newPool = new ConstantPool(hasDecimal); // make room for decimal in the one we create
        newPool.in = new BytecodeBuffer(preferredSize);
        newPool.history = new IndexHistory(pools, hasDecimal);

        return newPool;
    }

    ConstantPool(boolean hasDecimal)
    {
        poolHasDecimal = hasDecimal;
    }

    public ConstantPool(BytecodeBuffer in, boolean hasDecimal) throws DecoderException
    {
        this.in = in;
        poolHasDecimal = hasDecimal;
        scan();
    }

    private void scan() throws DecoderException
    {
        intpositions = Scanner.scanIntConstants(in);
        intEnd = in.pos();
        uintpositions = Scanner.scanUIntConstants(in);
        uintEnd = in.pos();
        doublepositions = Scanner.scanDoubleConstants(in);
        doubleEnd = in.pos();
        if (poolHasDecimal) {
            decimalpositions = Scanner.scanDecimalConstants(in);
            decimalEnd = in.pos();
        } else {
            decimalpositions = new int[0];
            decimalEnd = in.pos();
        }
        strpositions = Scanner.scanStrConstants(in);
        strEnd = in.pos();
        nspositions = Scanner.scanNsConstants(in);
        nsEnd = in.pos();
        nsspositions = Scanner.scanNsSetConstants(in);
        nssEnd = in.pos();
        mnpositions = Scanner.scanMultinameConstants(in);
        mnEnd = in.pos();

        size = ((intpositions.length == 0) ? 0 : (intpositions.length - 1)) +
               ((uintpositions.length == 0) ? 0: (uintpositions.length - 1)) +
               ((doublepositions.length == 0) ? 0 : (doublepositions.length - 1)) +
               ((decimalpositions.length == 0) ? 0 : (decimalpositions.length - 1)) +
               ((strpositions.length == 0) ? 0 : (strpositions.length - 1)) +
               ((nspositions.length == 0) ? 0 : (nspositions.length - 1)) +
               ((nsspositions.length == 0) ? 0 : (nsspositions.length - 1)) +
               ((mnpositions.length == 0) ? 0 : (mnpositions.length - 1));
    }

    BytecodeBuffer in;
    IndexHistory history;
    private int size;

    int[] intpositions;
    int[] uintpositions;
    int[] doublepositions;
    int[] decimalpositions;
    int[] strpositions;
    int[] nspositions;
    int[] nsspositions;
    int[] mnpositions;

    int intEnd;
    int uintEnd;
    int doubleEnd;
    int decimalEnd;
    int strEnd;
    int nsEnd;
    int nssEnd;
    int mnEnd;

    public int size()
    {
        return size;
    }

    public int getInt(int index)
    {
        if (index == 0)
        {
            return 0;
        }

        int pos = intpositions[index];
        int originalPos = in.pos();
        in.seek(pos);

        int value = in.readU32();
        in.seek(originalPos);
        return value;

    }

    public long getLong(int index)
    {
        if (index == 0)
        {
            return 0;
        }

        int pos = uintpositions[index];
        int originalPos = in.pos();
        in.seek(pos);
        long value = in.readU32();
        in.seek(originalPos);
        return value;
    }

    public double getDouble(int index)
    {
        if (index == 0)
        {
            return 0;
        }

        int pos = doublepositions[index];
        int originalPos = in.pos();
        in.seek(pos);
        double value = in.readDouble();
        in.seek(originalPos);
        return value;
    }

    public Decimal128 getDecimal(int index)
    {
        if (index == 0)
        {
            return Decimal128.ZERO;
        }

        int pos = decimalpositions[index];
        int originalPos = in.pos();
        in.seek(pos);
        byte[] valbytes = in.readBytes(16);
        in.seek(originalPos);
        return new Decimal128(valbytes); // perhaps need to change endian
    }

    public String getString(int index) throws DecoderException
    {
        if (index == 0)
        {
            return null;
        }

        int pos = strpositions[index];
        int originalPos = in.pos();
        in.seek(pos);
        String value = in.readString(in.readU32());
        in.seek(originalPos);
        if (value != null)
        {
            return value;
        }
        else
        {
            throw new DecoderException("abc Decoder Erro: problem reading UTF-8 encoded strings.");
        }
    }

    public String getNamespaceName(int index) throws DecoderException
    {
        if( index == 0 )
        {
            return null;
        }
        int pos = nspositions[index];
        int originalPos = in.pos();
        in.seek(pos);
        int kind = in.readU8();
        String value = "";
        switch(kind)
        {
            case CONSTANT_PrivateNamespace:
            case CONSTANT_Namespace:
            case CONSTANT_PackageNamespace:
            case CONSTANT_PackageInternalNs:
            case CONSTANT_ProtectedNamespace:
            case CONSTANT_ExplicitNamespace:
            case CONSTANT_StaticProtectedNs:
                value = getString(in.readU32());
                break;
            default:
                throw new DecoderException("abc Decoder Error: constant pool index '" + index + "' is not a Namespace type. The actual type is '" + kind + "'");
        }
        in.seek(originalPos);
        return value;
    }

    public String[] getNamespaceSet(int index) throws DecoderException
    {
        if (index == 0)
        {
            return null;
        }

        int pos = nsspositions[index];
        int originalPos = in.pos();
        in.seek(pos);
        int count = in.readU32();
        String[] value = new String[count];
        for (int j = 0; j < count; j++)
        {
            value[j] = getNamespaceName(in.readU32());
        }
        in.seek(originalPos);
        if (value != null)
        {
            return value;
        }
        else
        {
            throw new DecoderException("abc Decoder Erro: problem reading namespace set.");
        }
    }

    public int getNamespaceIndexForQName(int index) throws DecoderException {
        if (index == 0)
        {
            return 0;
        }

        int pos = mnpositions[index];
        int originalPos = in.pos();
        in.seek(pos);
        int kind = in.readU8();

        switch (kind)
        {
        case CONSTANT_Qname:
        case CONSTANT_QnameA:
            int namespaceIndex = in.readU32();
            in.seek(originalPos);
            return namespaceIndex;
        default:
            in.seek(originalPos);
            throw new DecoderException("abc Decoder Error: constant pool index '" + index + "' is not a QName type. The actual type is '" + kind + "'");
        }
    }

    public int getNamespaceKind(int namespaceIndex) {
        if(namespaceIndex == 0)
            return -1;

        int pos = nspositions[namespaceIndex];
        int originalPos = in.pos();
        in.seek(pos);
        int kind = in.readU8();
        in.seek(originalPos);
        return kind;
    }

    public QName getQName(int index) throws DecoderException
    {
        if (index == 0)
        {
            return null;
        }

        int pos = mnpositions[index];
        int originalPos = in.pos();
        in.seek(pos);
        int kind = in.readU8();

        switch (kind)
        {
        case CONSTANT_Qname:
        case CONSTANT_QnameA:
        {
            int namespaceIndex = in.readU32();
            int nameIndex = in.readU32();
            QName value = createQName(getNamespaceName(namespaceIndex), getString(nameIndex));
            in.seek(originalPos);
            return value;
        }
        case CONSTANT_TypeName:
        {
            int nameIndex = in.readU32();
            int count = in.readU32();
            String params = ".<";
            QName base = getQName(nameIndex);
            for(int i = 0; i < count; ++i)
            {
                params += (i>0?",":"") + getQName(in.readU32());
            }
            params+=">";
            QName value = createQName(base.getNamespace(), base.getLocalPart()+params);
            in.seek(originalPos);
            return value;
        }
        default:
            in.seek(originalPos);
            throw new DecoderException("abc Decoder Error: constant pool index '" + index + "' is not a QName type. The actual type is '" + kind + "'");
        }
    }

    public MultiName getMultiName(int index) throws DecoderException
    {
        if (index == 0)
        {
            return null;
        }

        int pos = mnpositions[index];
        int originalPos = in.pos();
        in.seek(pos);
        int kind = in.readU8();

        switch (kind)
        {
        case CONSTANT_Multiname:
        case CONSTANT_MultinameA:
            String name = getString(in.readU32());
            int namespace_set = in.readU32();
            String[] namespaces = getNamespaceSet(namespace_set);
            MultiName value = createMultiName(name, namespaces);
            in.seek(originalPos);
            return value;
        default:
            in.seek(originalPos);
            throw new DecoderException("abc Decoder Error: constant constantPool index '" + index + "' is not a MultiName type. The actual type is '" + kind + "'");
        }
    }

    public Object getGeneralMultiname(int index) throws DecoderException
    {
        if (index == 0)
        {
            return null;
        }

        int pos = mnpositions[index];
        int originalPos = in.pos();
        in.seek(pos);
        int kind = in.readU8();

        switch (kind)
        {
        case CONSTANT_Qname:
        case CONSTANT_QnameA:
        {
            int namespaceIndex = in.readU32();
            int nameIndex = in.readU32();
            QName value = createQName(getNamespaceName(namespaceIndex), getString(nameIndex));
            in.seek(originalPos);
            return value;
        }
        case CONSTANT_Multiname:
        case CONSTANT_MultinameA:
        {
            String name = getString(in.readU32());
            int namespace_set = in.readU32();
            String[] namespaces = getNamespaceSet(namespace_set);
            MultiName value = createMultiName(name, namespaces);
            in.seek(originalPos);
            return value;
        }
        case CONSTANT_RTQnameL:
            in.seek(originalPos);
            return "CONSTANT_RTQnameL"; // Boolean.FALSE;
        case CONSTANT_RTQnameLA:
            in.seek(originalPos);
            return "CONSTANT_RTQnameLA"; // Boolean.TRUE;
        case CONSTANT_MultinameL:
        case CONSTANT_MultinameLA:
        {
            int namespacesetIndex = in.readU32();
            String[] value = getNamespaceSet(namespacesetIndex);
            ArrayList<String> a = new ArrayList<String>();
            for (int k = 0; k < value.length; k++)
            {
                a.add(value[k]);
            }
            in.seek(originalPos);
            return a;
        }
        case CONSTANT_RTQname:
        case CONSTANT_RTQnameA:
        {
            int idx = in.readU32();
            String s = getString(idx);
            in.seek(originalPos);
            return s;
        }
        default:
            in.seek(originalPos);
            throw new DecoderException("abc Decoder Error: constant pool index '" + index + "' is not a QName type. The actual type is '" + kind + "'");
        }
    }

    public Object get(int index, int kind) throws DecoderException
    {
        if (index == 0)
        {
            return null;
        }

        Object value;
        switch(kind)
        {
            case CONSTANT_Utf8:
                value = getString(index);
                return value;
            case CONSTANT_Integer:
                value = createInteger(getInt(index));
                return value;
            case CONSTANT_UInteger:
                value = createLong(getLong(index));
                return value;
            case CONSTANT_Double:
                value = createDouble(getDouble(index));
                return value;
            case CONSTANT_Decimal:
                value = getDecimal(index);
                return value;
            case CONSTANT_Qname:
            case CONSTANT_QnameA:
                value = getQName(index);
                return value;
            case CONSTANT_Namespace:
            case CONSTANT_PrivateNamespace:
            case CONSTANT_PackageNamespace:
            case CONSTANT_PackageInternalNs:
            case CONSTANT_ProtectedNamespace:
            case CONSTANT_ExplicitNamespace:
            case CONSTANT_StaticProtectedNs:
                value = getNamespaceName(index);
                return value;
            case CONSTANT_Multiname:
            case CONSTANT_MultinameA:
                value = getMultiName(index);
                return value;
            case CONSTANT_False:
                value = Boolean.FALSE;
                return value;
            case CONSTANT_True:
                value = Boolean.TRUE ;
                return value;
            case CONSTANT_Null:
                value = NULL;
                return value;
            case CONSTANT_RTQname:
            case CONSTANT_RTQnameA:
                value = getGeneralMultiname(index);
                return value;
            case CONSTANT_RTQnameL:
                value = "CONSTANT_RTQnameL"; // Boolean.FALSE;
                return value;
            case CONSTANT_RTQnameLA:
                value = "CONSTANT_RTQnameLA"; // Boolean.TRUE;
                return value;
            case CONSTANT_MultinameL:
                value = getNamespaceSet(getInt(index));
                return value;
            case CONSTANT_MultinameLA:
                value = getNamespaceSet(getInt(index));
                return value;
            case CONSTANT_Namespace_Set:
                value = getNamespaceSet(index);
                return value;
            default:
                throw new DecoderException("Error: Unhandled constant type - " + kind);
        }
    }

    private Integer createInteger(int number)
    {
        return IntegerPool.getNumber(number);
    }

    private Long createLong(long number)
    {
        return new Long(number);
    }

    private Double createDouble(double number)
    {
        return new Double(number);
    }

    private QName createQName(String ns, String name)
    {
        return new QName(ns, name);
    }

    private MultiName createMultiName(String name, String[] ns)
    {
        return new MultiName(name, ns);
    }

    public void writeTo(OutputStream out) throws IOException
    {
        history.writeTo(in);
        in.writeTo(out);
    }
}

final class IndexHistory
{
	public static final int cp_int = 0;
	public static final int cp_uint = 1;
	public static final int cp_double = 2;
	public static final int cp_decimal = 3;
	public static final int cp_string = 4;
	public static final int cp_ns = 5;
	public static final int cp_nsset = 6;
	public static final int cp_mn = 7;
	
	IndexHistory(ConstantPool[] pools, boolean poolHasDecimal)
	{
		this.pools = pools;
		poolSizes = new int[pools.length];
		hasDecimal = poolHasDecimal;

		int size = 0, preferredSize = 0;
		for (int i = 0, length = pools.length; i < length; i++)
		{
			poolSizes[i] = (i == 0) ? 0 : size;
			size += pools[i].size();
			preferredSize += (pools[i].mnEnd - pools[i].strEnd);
		}

		map = new int[size];
		in_ns = new BytecodeBuffer(preferredSize);
		in_nsset = new BytecodeBuffer(preferredSize);
		in_mn = new BytecodeBuffer(preferredSize);

		intP = new ByteArrayPool();
		uintP = new ByteArrayPool();
		doubleP = new ByteArrayPool();
		if (hasDecimal)
			decimalP = new ByteArrayPool();
		stringP = new ByteArrayPool();
		nsP = new NSPool();
		nssP = new NSSPool();
		mnP = new MultiNamePool();

		total = 0;
		duplicate = 0;
		totalBytes = 0;
		duplicateBytes = 0;

		// nss = new HashSet<Integer>();
	}

	public int total, duplicate, totalBytes, duplicateBytes;

	private ConstantPool[] pools;
	private int[] poolSizes;
	private int[] map;

	private boolean hasDecimal;
	
	private ByteArrayPool intP, uintP, doubleP, decimalP, stringP, nsP, nssP, mnP;
	private BytecodeBuffer in_ns, in_nsset, in_mn;
	// private Set<Integer> nss;

    // Needed so we can strip out the index for all CONSTANT_PrivateNamespace entries
    // since the name for private namespaces is not important
    private boolean disableDebuggingInfo = false;
    void disableDebugging()
    {
        disableDebuggingInfo = true;
    }


	public int getIndex(int poolIndex, int kind, int index)
	{
		if (index == 0)
		{
			return 0;
		}
		else
		{
			int newIndex = calculateIndex(poolIndex, kind, index);

			if (map[newIndex] == 0)
			{
				decodeOnDemand(poolIndex, kind, index, newIndex);
			}

			return map[newIndex];
		}
	}

	public void writeTo(BytecodeBuffer b)
	{
		intP.writeTo(b);
		uintP.writeTo(b);
		doubleP.writeTo(b);
		if (hasDecimal)
			decimalP.writeTo(b);
		stringP.writeTo(b);
		nsP.writeTo(b);
		nssP.writeTo(b);
		mnP.writeTo(b);
	}

	/**
	 * @param poolIndex 0-based
	 * @param kind 0-based
	 * @param oldIndex 1-based
	 */
	private final int calculateIndex(final int poolIndex, final int kind, final int oldIndex)
	{
		int index = poolSizes[poolIndex];

		if (kind > cp_int)
		{
			index += (pools[poolIndex].intpositions.length == 0) ? 0 : (pools[poolIndex].intpositions.length - 1);
		}

		if (kind > cp_uint)
		{
			index += (pools[poolIndex].uintpositions.length == 0) ? 0 : (pools[poolIndex].uintpositions.length - 1);
		}

		if (kind > cp_double)
		{
			index += (pools[poolIndex].doublepositions.length == 0) ? 0 : (pools[poolIndex].doublepositions.length - 1);
		}

		if (hasDecimal && (kind > cp_decimal))
		{
			index += (pools[poolIndex].decimalpositions.length == 0) ? 0 : (pools[poolIndex].decimalpositions.length - 1);
		}

		if (kind > cp_string)
		{
			index += (pools[poolIndex].strpositions.length == 0) ? 0 : (pools[poolIndex].strpositions.length - 1);
		}

		if (kind > cp_ns)
		{
			index += (pools[poolIndex].nspositions.length == 0) ? 0 : (pools[poolIndex].nspositions.length - 1);
		}

		if (kind > cp_nsset)
		{
			index += (pools[poolIndex].nsspositions.length == 0) ? 0 : (pools[poolIndex].nsspositions.length - 1);
		}

		if (kind > cp_mn)
		{
			index += (pools[poolIndex].mnpositions.length == 0) ? 0 : (pools[poolIndex].mnpositions.length - 1);
		}

		index += (oldIndex - 1);

		return index;
	}

	private final void decodeOnDemand(final int poolIndex, final int kind, final int j, final int j2)
    {
	    ConstantPool pool = pools[poolIndex];
	    ByteArrayPool baPool = null;
	    BytecodeBuffer poolIn = null;
	    int[] positions = null;
	    int length = 0, endPos = 0;

	    if (kind == cp_int)
	    {
		    positions = pool.intpositions;
		    length = positions.length;
		    endPos = pool.intEnd;
		    baPool = intP;
		    poolIn = pool.in;
	    }
	    else if (kind == cp_uint)
	    {
		    positions = pool.uintpositions;
		    length = positions.length;
		    endPos = pool.uintEnd;
		    baPool = uintP;
		    poolIn = pool.in;
	    }
	    else if (kind == cp_double)
	    {
		    positions = pool.doublepositions;
		    length = positions.length;
		    endPos = pool.doubleEnd;
		    baPool = doubleP;
		    poolIn = pool.in;
	    }
	    else if (kind == cp_decimal)
	    {
	    	assert(hasDecimal);
		    positions = pool.decimalpositions;
		    length = positions.length;
		    endPos = pool.decimalEnd;
		    baPool = decimalP;
		    poolIn = pool.in;
	    }
	    else if (kind == cp_string)
	    {
		    positions = pool.strpositions;
		    length = positions.length;
		    endPos = pool.strEnd;
		    baPool = stringP;
		    poolIn = pool.in;
	    }
	    else if (kind == cp_ns)
	    {
		    positions = pool.nspositions;
		    length = positions.length;
		    endPos = pool.nsEnd;
		    baPool = nsP;
		    poolIn = pool.in;
	    }
	    else if (kind == cp_nsset)
	    {
		    positions = pool.nsspositions;
		    length = positions.length;
		    endPos = pool.nssEnd;
		    baPool = nssP;
		    poolIn = pool.in;
	    }
	    else if (kind == cp_mn)
	    {
		    positions = pool.mnpositions;
		    length = positions.length;
		    endPos = pool.mnEnd;
		    baPool = mnP;
		    poolIn = pool.in;
	    }

	    int start = positions[j];
	    int end = (j != length - 1) ? positions[j + 1] : endPos;

	    if (kind == cp_ns)
	    {
		    int pos = positions[j];
		    int originalPos = poolIn.pos();
		    poolIn.seek(pos);
		    start = in_ns.size();
		    int nsKind = poolIn.readU8();
		    in_ns.writeU8(nsKind);
		    switch (nsKind)
		    {
		    case CONSTANT_PrivateNamespace:
                if( this.disableDebuggingInfo )
                {
                    in_ns.writeU32(0); // name not important for private namespace
                    break;
                }
                // else fall through and treat like a normal namespace
		    case CONSTANT_Namespace:
            case CONSTANT_PackageNamespace:
            case CONSTANT_PackageInternalNs:
            case CONSTANT_ProtectedNamespace:
            case CONSTANT_ExplicitNamespace:
            case CONSTANT_StaticProtectedNs:				
			    int index = poolIn.readU32();
			    int newIndex = getIndex(poolIndex, cp_string, index);
			    in_ns.writeU32(newIndex);
			    break;
		    default:
			    assert false; // can't possibly happen...
		    }
            poolIn.seek(originalPos);
            end = in_ns.size();
            poolIn = in_ns;
	    }
	    else if (kind == cp_nsset)
	    {
		    int pos = positions[j];
		    int originalPos = poolIn.pos();
		    poolIn.seek(pos);
		    start = in_nsset.size();

		    /*
		    nss.clear();
		    int count = (int) poolIn.readU32();
		    for (int k = 0; k < count; k++)
		    {
			    nss.add((int) poolIn.readU32());
		    }
		    count = nss.size();
		    in5.writeU32(count);
		    for (Iterator<Integer> k = nss.iterator(); k.hasNext();)
		    {
			    int index = k.next();
			    int newIndex = getIndex(poolIndex, 4, index);
			    in_nsset.writeU32(newIndex);
		    }
            */

		    int count = poolIn.readU32();
		    in_nsset.writeU32(count);
		    for (int k = 0; k < count; k++)
		    {
			    int index = poolIn.readU32();
			    int newIndex = getIndex(poolIndex, cp_ns, index);
			    in_nsset.writeU32(newIndex);
		    }

		    poolIn.seek(originalPos);
		    end = in_nsset.size();
		    poolIn = in_nsset;
	    }
	    else if (kind == cp_mn)
	    {
		    int pos = positions[j];
		    int originalPos = poolIn.pos();
		    poolIn.seek(pos);
		    start = in_mn.size();
		    int constKind = poolIn.readU8();
            if( !(constKind==CONSTANT_TypeName))
                in_mn.writeU8(constKind);

		    switch (constKind)
		    {
		    case CONSTANT_Qname:
		    case CONSTANT_QnameA:
		    {
			    int namespaceIndex = poolIn.readU32();
			    int newNamespaceIndex = getIndex(poolIndex, cp_ns, namespaceIndex);
			    in_mn.writeU32(newNamespaceIndex);
			    int nameIndex = poolIn.readU32();
			    int newNameIndex = getIndex(poolIndex, cp_string, nameIndex);
			    in_mn.writeU32(newNameIndex);
			    break;
		    }
		    case CONSTANT_Multiname:
		    case CONSTANT_MultinameA:
		    {
			    int nameIndex = poolIn.readU32();
			    int newNameIndex = getIndex(poolIndex, cp_string, nameIndex);
			    in_mn.writeU32(newNameIndex);
			    int namespace_set = poolIn.readU32();
			    int newNamespace_set = getIndex(poolIndex, cp_nsset, namespace_set);
			    in_mn.writeU32(newNamespace_set);
			    break;
		    }
		    case CONSTANT_RTQname:
		    case CONSTANT_RTQnameA:
		    {
			    int index = poolIn.readU32();
			    int newIndex = getIndex(poolIndex, cp_string, index);
			    in_mn.writeU32(newIndex);
			    break;
		    }
		    case CONSTANT_RTQnameL:
		    case CONSTANT_RTQnameLA:
				break;
		    case CONSTANT_MultinameL:
		    case CONSTANT_MultinameLA:
			{
				int namespace_set = poolIn.readU32();
				int newNamespace_set = getIndex(poolIndex, cp_nsset, namespace_set);
				in_mn.writeU32(newNamespace_set);
				break;
			}
            case CONSTANT_TypeName:
            {
                int nameIndex = poolIn.readU32();
                int newNameIndex = getIndex(poolIndex, cp_mn, nameIndex);
                int count = poolIn.readU32();
                IntList newParams = new IntList();
                for( int i = 0; i<count;++i) {
                    newParams.add(getIndex(poolIndex, cp_mn, poolIn.readU32()));
                }
                start = in_mn.size();
                in_mn.writeU8(constKind);
                in_mn.writeU32(newNameIndex);
                in_mn.writeU32(count);
                for( int i =0; i < count; ++i ) {
                    in_mn.writeU32(newParams.at(i));
                }
				break;
            }

            default:
			    assert false; // can't possibly happen...
		    }

		    poolIn.seek(originalPos);
		    end = in_mn.size();
		    poolIn = in_mn;
	    }

	    int newIndex = baPool.contains(poolIn, start, end);
	    if (newIndex == -1)
	    {
		    newIndex = baPool.store(poolIn, start, end);
	    }
	    else
	    {
		    duplicate++;
		    duplicateBytes += (end - start);
	    }

	    total++;
	    totalBytes += (end - start);

	    if (j != 0)
	    {
		    map[j2] = newIndex;
	    }
    }
}

final class NSPool extends ByteArrayPool
{
	NSPool()
	{
		super();
	}

	ByteArray newByteArray()
	{
		return new NS();
	}
}

final class NS extends ByteArray
{
	int nsKind = 0, index = 0;

	void init()
	{
		super.init();

		int originalPos = b.pos();
		b.seek(start);
		nsKind = b.readU8();
		switch (nsKind)
		{
		case CONSTANT_PrivateNamespace:
		case CONSTANT_Namespace:
        case CONSTANT_PackageNamespace:
        case CONSTANT_PackageInternalNs:
        case CONSTANT_ProtectedNamespace:
        case CONSTANT_ExplicitNamespace:
        case CONSTANT_StaticProtectedNs:				
			index = b.readU32();
			break;
		default:
			assert false; // can't possibly happen...
		}
		b.seek(originalPos);

		long num = 1234 ^ nsKind ^ index;
		hash = (int) ((num >> 32) ^ num);
	}

	void clear()
	{
		super.clear();
		nsKind = 0;
		index = 0;
	}

	public boolean equals(Object obj)
	{
        boolean equal = false;
		if (obj instanceof NS)
		{
            NS ns = (NS) obj;
            if( this.nsKind == CONSTANT_PrivateNamespace )
            {
                // Private namespaces are only equal if they are literally the same namespace,
                // the name is not important.
                equal = (this.b == ns.b) && (this.start == ns.start) && (this.end == ns.end);
            }
            else
            {
                equal = (ns.nsKind == this.nsKind) && (ns.index == this.index);
            }
		}
        return equal;
	}
}


final class NSSPool extends ByteArrayPool
{
	NSSPool()
	{
		super();
	}

	ByteArray newByteArray()
	{
		return new NSS();
	}
}

final class NSS extends ByteArray
{
	int[] set = null;
	int size = 0;

	void init()
	{
		super.init();

		int originalPos = b.pos();
		b.seek(start);
		int count = b.readU32();

		if (set == null || count > set.length)
		{
			set = new int[count];
		}
		size = count;

		for (int k = 0; k < count; k++)
		{
			set[k] = b.readU32();
		}
		b.seek(originalPos);

		long num = 1234;
		for (int k = 0; k < count; k++)
		{
			num ^= set[k];
		}
		hash = (int) ((num >> 32) ^ num);
	}

	void clear()
	{
		super.clear();
		size = 0;
	}

	public boolean equals(Object obj)
	{
		if (obj instanceof NSS)
		{
			NSS nss = (NSS) obj;
			if (size == nss.size)
			{
				for (int i = 0; i < size; i++)
				{
					if (set[i] != nss.set[i])
					{
						return false;
					}
				}
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}
}

final class MultiNamePool extends ByteArrayPool
{
	MultiNamePool()
	{
		super();
	}

	ByteArray newByteArray()
	{
		return new MN();
	}
}

final class MN extends ByteArray
{
	int constKind = 0, index1 = 1, index2 = 1;

	void init()
	{
		super.init();

		int originalPos = b.pos();
		b.seek(start);
		constKind = b.readU8();

		switch (constKind)
		{
		case CONSTANT_Qname:
		case CONSTANT_QnameA:
		{
			index1 = b.readU32();
			index2 = b.readU32();
			long num = 1234 ^ constKind ^ index1 ^ index2;
			hash = (int) ((num >> 32) ^ num);
			break;
		}
		case CONSTANT_Multiname:
		case CONSTANT_MultinameA:
		{
			index1 = b.readU32();
			index2 = b.readU32();
			long num = 1234 ^ constKind ^ index1 ^ index2;
			hash = (int) ((num >> 32) ^ num);
			break;
		}
		case CONSTANT_RTQname:
		case CONSTANT_RTQnameA:
		{
			index1 = b.readU32();
			long num = 1234 ^ constKind ^ index1;
			hash = (int) ((num >> 32) ^ num);
			break;
		}
		case CONSTANT_RTQnameL:
		case CONSTANT_RTQnameLA:
		{
			long num = 1234 ^ constKind;
			hash = (int) ((num >> 32) ^ num);
			break;
		}
		case CONSTANT_MultinameL:
		case CONSTANT_MultinameLA:
		{
			index1 = b.readU32();
			long num = 1234 ^ constKind ^ index1;
			hash = (int) ((num >> 32) ^ num);
			break;
		}
        case CONSTANT_TypeName:
        {
            index1 = b.readU32();
            int count = b.readU32();
            // Only 1 typeparam for now.
            index2 = b.readU32();
            long num = 1234 ^ constKind ^ index1 ^ index2;
            hash = (int) ((num >> 32) ^ num);
            break;
        }
        default:
			assert false; // can't possibly happen...
		}

		b.seek(originalPos);
	}

	void clear()
	{
		super.clear();
		constKind = 0;
		index1 = 0;
		index2 = 0;
	}

	public boolean equals(Object obj)
	{
		if (obj instanceof MN)
		{
			MN mn = (MN) obj;

			switch (constKind)
			{
			case CONSTANT_Qname:
			case CONSTANT_QnameA:
			case CONSTANT_Multiname:
			case CONSTANT_MultinameA:
			{
				return (constKind == mn.constKind) && (index1 == mn.index1) && (index2 == mn.index2);
			}
			case CONSTANT_RTQname:
			case CONSTANT_RTQnameA:
			{
				return (constKind == mn.constKind) && (index1 == mn.index1);
			}
			case CONSTANT_RTQnameL:
			case CONSTANT_RTQnameLA:
				return (constKind == mn.constKind);
			case CONSTANT_MultinameL:
			case CONSTANT_MultinameLA:
			{
				return (constKind == mn.constKind) && (index1 == mn.index1);
			}
            case CONSTANT_TypeName:
            {
                return ( constKind == mn.constKind && index1 == mn.index1 && index2 == mn.index2 );
            }
            default:
				return false;
			}
		}
		else
		{
			return false;
		}
	}
}
