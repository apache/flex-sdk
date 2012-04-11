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

import org.apache.bcel.Constants;
import org.apache.bcel.classfile.ClassParser;
import org.apache.bcel.classfile.Constant;
import org.apache.bcel.classfile.ConstantFieldref;
import org.apache.bcel.classfile.ConstantMethodref;
import org.apache.bcel.classfile.ConstantNameAndType;
import org.apache.bcel.classfile.ConstantUtf8;
import org.apache.bcel.classfile.JavaClass;
import org.apache.bcel.classfile.Method;
import org.apache.bcel.generic.CPInstruction;
import org.apache.bcel.generic.ConstantPoolGen;
import org.apache.bcel.generic.InstructionConstants;
import org.apache.bcel.generic.InstructionHandle;
import org.apache.bcel.generic.InstructionList;
import org.apache.bcel.generic.MethodGen;
import org.apache.bcel.generic.TargetLostException;
import org.apache.bcel.util.InstructionFinder;

import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Iterator;

/**
 * make JDK 1.5 classfiles (version 49.0) compatible with JDK 1.3 (version 47.0)
 * by making the following changes:
 *
 * 1. replace references to java.lang.StringBuilder with java.lang.StringBuffer
 * 2. replace Integer.valueOf(int) with macromedia.asc.util.Boxing.valueOf(int)
 * 3. reorder this$outer and super() code snippets in inner class constructors,
 *    to please the 1.3 verifier.
 * 4. replace java.lang.AssertionError with java.lang.Error
 *
 * NOTE TO MAINTAINERS:
 * additional class reference changes can be added by adding entries in the strings
 * table.  these are simple substitutions.  Note that usually both the classname
 * reference and signatures of its methods must be changed.
 *
 * To adjust bytecode, we use BCEL's InstructionFinder, which lets us do regexp
 * matching on instruction sequences.  Once we find a match, we make the necessary
 * changes to a method's existing InstructionList.
 *
 * @author Edwin Smith
 */
public class Downgrader implements Constants
{
    static HashMap<String,String> strings = new HashMap<String,String>();

    static
    {
        // replace StringBuilder with StringBuffer
        strings.put("java/lang/StringBuilder", "java/lang/StringBuffer");
        strings.put("(Ljava/lang/String;)Ljava/lang/StringBuilder;", "(Ljava/lang/String;)Ljava/lang/StringBuffer;");
        strings.put("(Ljava/lang/Object;)Ljava/lang/StringBuilder;", "(Ljava/lang/Object;)Ljava/lang/StringBuffer;");
        strings.put("(I)Ljava/lang/StringBuilder;", "(I)Ljava/lang/StringBuffer;");
        strings.put("(C)Ljava/lang/StringBuilder;", "(C)Ljava/lang/StringBuffer;");
        strings.put("(Z)Ljava/lang/StringBuilder;", "(Z)Ljava/lang/StringBuffer;");
        strings.put("(D)Ljava/lang/StringBuilder;", "(D)Ljava/lang/StringBuffer;");
        strings.put("(J)Ljava/lang/StringBuilder;", "(J)Ljava/lang/StringBuffer;");

        // replace java.lang.AssertionError with java/lang/Error
        strings.put("java/lang/AssertionError", "java/lang/Error");
        
        //strings.put("java/lang/Iterable", "macromedia/asc/util/Iterable");
    }

    ConstantPoolGen cpool;

    void downgrade(String filename) throws IOException
    {
        byte[] b = new byte[(int) new File(filename).length()];
        InputStream in = new FileInputStream(filename);
        new DataInputStream(in).readFully(b);
        in.close();

        ClassParser parser = new ClassParser(new ByteArrayInputStream(b), filename);
        JavaClass jc = parser.parse();
        boolean changed;
        changed = downgrade(jc);

        if (changed)
        {
            b = jc.getBytes();

            FileOutputStream out = new FileOutputStream(filename);
            out.write(b);
            out.close();
        }
    }

    private boolean downgrade(JavaClass jc)
    {
        if (jc.getMajor() <= 47)
            return false;

        Method[] methods = jc.getMethods();
        cpool = new ConstantPoolGen(jc.getConstantPool().getConstantPool());

        jc.setMajor(47);

        for (int i=1, n=cpool.getSize(); i < n; i++)
        {
            Constant constant = cpool.getConstant(i);
            switch (constant.getTag())
            {
            case Constants.CONSTANT_Utf8:
                ConstantUtf8 cstring = (ConstantUtf8)constant;
                String bytes = cstring.getBytes();
                String newbytes = (String) strings.get(bytes);
                if (newbytes != null)
                    cstring.setBytes(newbytes);
                break;
            case Constants.CONSTANT_Double:
            case Constants.CONSTANT_Long:
                i++;
                break;
            case Constants.CONSTANT_Methodref:
                ConstantMethodref cmethod = (ConstantMethodref) constant;
                if (cmethod.getClass(cpool.getConstantPool()).equals("java.lang.Integer"))
                {
                    ConstantNameAndType cnt = (ConstantNameAndType) cpool.getConstant(cmethod.getNameAndTypeIndex());

                    if (cnt.getName(cpool.getConstantPool()).equals("valueOf") &&
                        cnt.getSignature(cpool.getConstantPool()).equals("(I)Ljava/lang/Integer;"))
                    {
                        cmethod.setClassIndex(cpool.addClass("macromedia.asc.util.Boxing"));
                    }
                }
                
                else if (cmethod.getClass(cpool.getConstantPool()).equals("java.lang.Double"))
                {
                    ConstantNameAndType cnt = (ConstantNameAndType) cpool.getConstant(cmethod.getNameAndTypeIndex());

                    if (cnt.getName(cpool.getConstantPool()).equals("valueOf") &&
                        cnt.getSignature(cpool.getConstantPool()).equals("(D)Ljava/lang/Double;"))
                    {
                        cmethod.setClassIndex(cpool.addClass("macromedia.asc.util.Boxing"));
                    }
                }
                break;
            }
        }

        for (int i=0, n = methods.length; i < n; i++)
        {
            if (!(methods[i].isAbstract() || methods[i].isNative()))
            {
                MethodGen mg = new MethodGen(methods[i], jc.getClassName(), cpool);

                boolean changed = change1(mg);

                if (methods[i].getName().equals("<init>"))
                    changed |= change2(mg);

//                changed |= change3(mg);

                if (changed)
                {
                    mg.setMaxStack();
                    methods[i] = mg.getMethod();
                }
            }
        }

        jc.setConstantPool(cpool.getFinalConstantPool());
        return true;
    }

    private boolean change2(MethodGen mg)
    {
        InstructionList il = mg.getInstructionList();
        InstructionFinder f   = new InstructionFinder(il);
        String            pat = "ALOAD_0 ALOAD_1 PUTFIELD ALOAD_0 INVOKESPECIAL";

        boolean changed = false;
        for(Iterator j = f.search(pat, new IsInnerConstructor()); j.hasNext(); )
        {
            InstructionHandle[] match = (InstructionHandle[]) j.next();

            // replace
            //    ALOAD_0       [0] 
            //    ALOAD_1		[1]
            //    PUTFIELD		[2]
            //    ALOAD_0		[3]
            //    INVOKESPECIAL	[4]
            // with
            //    ALOAD_0		[0]
            //    INVOKESPECIAL	[4]
            //    ALOAD_0		[3]
            //    ALOAD_1		[1]
            //    PUTFIELD		[2]

            changed = true;
            try
            {
                InstructionList il2 = new InstructionList();
                il2.append(match[3].getInstruction());
                il2.append(match[4].getInstruction());
                il.delete(match[3], match[4]);
                il.insert(match[0], il2);
            }
            catch (TargetLostException e)
            {
            	System.err.println("ERROR IN "+mg);
                e.printStackTrace();
            }
        }
        return changed;
    }

    class IsInnerConstructor implements InstructionFinder.CodeConstraint
    {
        public boolean checkCode(InstructionHandle[] match)
        {
            InstructionHandle ih = match[2];
            CPInstruction putfield = (CPInstruction) ih.getInstruction();
            Constant cc = cpool.getConstant(putfield.getIndex());
            if (cc.getTag() != CONSTANT_Fieldref)
                return false;
            ConstantFieldref cfield = (ConstantFieldref) cc;
            ConstantNameAndType cnt = (ConstantNameAndType) cpool.getConstant(cfield.getNameAndTypeIndex());
            if (!cnt.getName(cpool.getConstantPool()).equals("this$0"))
                return false;
            return true;
        }
    }

/*    private boolean change3(MethodGen mg)
    {
        InstructionList il = mg.getInstructionList();
        InstructionFinder f   = new InstructionFinder(il);
        String            pat = "INVOKESTATIC";

        boolean changed = false;
        for(Iterator j = f.search(pat, new IsIntegerValueOf()); j.hasNext(); )
        {
            InstructionHandle[] match = (InstructionHandle[]) j.next();

            // replace
            //    (expr)
            //    INVOKESTATIC Integer.valueOf(int):Integer
            // with
            //    (expr)
            //    NEW        Integer
            //    DUP_X1
            //    SWAP
            //    INVOKESPECIAL  Integer(int)

            changed = true;
            try
            {
                InstructionFactory factory = new InstructionFactory(cpool);
                InstructionList il2 = new InstructionList();

                il2.append(factory.createNew("java.lang.Integer"));
                il2.append(InstructionConstants.DUP_X1);
                il2.append(InstructionConstants.SWAP);
				il2.append(factory.createInvoke("java.lang.Integer", "Integer", Type.VOID, new Type[] { Type.INT }, INVOKESPECIAL));

                il.append(match[0], il2);
                il.delete(match[0]);
                System.out.println(il);
            }
            catch (TargetLostException e)
            {
                e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
            }
        }
        return changed;
    }

    class IsIntegerValueOf implements InstructionFinder.CodeConstraint
    {
        public boolean checkCode(InstructionHandle[] match)
        {
            InstructionHandle ih = match[0];
            CPInstruction invokestatic = (CPInstruction) ih.getInstruction();
            Constant cc = cpool.getConstant(invokestatic.getIndex());
            if (cc.getTag() != CONSTANT_Methodref)
                return false;
            ConstantMethodref cmethod = (ConstantMethodref) cc;
            if (cmethod.getClass(cpool.getConstantPool()).equals("java.lang.Integer"))
            {
                ConstantNameAndType cnt = (ConstantNameAndType) cpool.getConstant(cmethod.getNameAndTypeIndex());
                if (cnt.getName(cpool.getConstantPool()).equals("valueOf") &&
                    cnt.getSignature(cpool.getConstantPool()).equals("(I)Ljava/lang/Integer;"))
                {
                    return true;
                }
            }
            return false;
        }
    }
*/

    private boolean change1(MethodGen mg)
    {
        InstructionList il = mg.getInstructionList();
        InstructionFinder f   = new InstructionFinder(il);
        String            pat = "[LDC_W|LDC] INVOKEVIRTUAL IFNE ICONST_1 GOTO ICONST_0";

        boolean changed = false;
        for(Iterator j = f.search(pat, new IsLdcClass()); j.hasNext(); )
        {
            InstructionHandle[] match = (InstructionHandle[]) j.next();

            // replace
            //    LDC_W <class>
            //    INVOKEVIRTUAL Class.desiredAssertionStatus
            //    IFNE
            //    ICONST_1
            //    goto
            //    ICONST_0
            // with
            //    ICONST_1

            changed = true;
            match[0].setInstruction(InstructionConstants.ICONST_1);
            try
            {
                il.delete(match[1], match[5]);
//                System.out.println(il);
            }
            catch (TargetLostException e)
            {
                e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
            }
        }
        return changed;
    }

    class IsLdcClass implements InstructionFinder.CodeConstraint
    {
        public boolean checkCode(InstructionHandle[] match)
        {
            InstructionHandle ih = match[0];
            CPInstruction ldc_w = (CPInstruction) ih.getInstruction();
            Constant cc = cpool.getConstant(ldc_w.getIndex());
            if (cc.getTag() != CONSTANT_Class)
                return false;

            ih = match[1];
            CPInstruction invokevirtual = (CPInstruction) ih.getInstruction();
            ConstantMethodref cm = (ConstantMethodref) cpool.getConstant(invokevirtual.getIndex());
            ConstantNameAndType cnt = (ConstantNameAndType) cpool.getConstant(cm.getNameAndTypeIndex());
            if (!cnt.getName(cpool.getConstantPool()).equals("desiredAssertionStatus"))
                return false;
            return true;
        }
    }

    public static void main(String[] args)
    {
		for (int i = 0, length = args.length; i < length; i++)
		{
			String dirname = args[i];

			File dir = new File(dirname);
			try
			{
				downgradeDir(dir);
			}
			catch (Throwable e)
			{
				e.printStackTrace();
				System.exit(1);
			}
		}
    }

    static void downgradeDir(File dir) throws IOException
    {
        System.out.println(dir);
        File[] files = dir.listFiles(new FilenameFilter()
        {
            public boolean accept(File dir, String name)
            {
                return name.endsWith(".class") || new File(dir,name).isDirectory();
            }
        });

        for (int i=0, n=files.length; i < n; i++)
        {
            if (files[i].isDirectory())
                downgradeDir(files[i]);
            else
                new Downgrader().downgrade(files[i].getPath());
        }
    }
}
