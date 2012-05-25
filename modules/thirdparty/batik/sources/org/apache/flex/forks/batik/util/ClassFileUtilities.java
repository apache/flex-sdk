/*

   Copyright 2001,2003  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.util;

import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

/**
 * This class contains utility methods to manipulate Java classes.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ClassFileUtilities.java,v 1.4 2004/08/18 07:15:48 vhardy Exp $
 */
public class ClassFileUtilities {

    // Constant pool info tags
    public final static byte CONSTANT_UTF8_INFO                = 1;
    public final static byte CONSTANT_INTEGER_INFO             = 3;
    public final static byte CONSTANT_FLOAT_INFO               = 4;
    public final static byte CONSTANT_LONG_INFO                = 5;
    public final static byte CONSTANT_DOUBLE_INFO              = 6;
    public final static byte CONSTANT_CLASS_INFO               = 7;
    public final static byte CONSTANT_STRING_INFO              = 8;
    public final static byte CONSTANT_FIELDREF_INFO            = 9;
    public final static byte CONSTANT_METHODREF_INFO           = 10;
    public final static byte CONSTANT_INTERFACEMETHODREF_INFO  = 11;
    public final static byte CONSTANT_NAMEANDTYPE_INFO         = 12;

    /**
     * This class does not need to be instantiated.
     */
    protected ClassFileUtilities() {
    }

    /**
     * Returns the dependencies of the given class.
     * @param path The root class path.
     * @param classpath The set of directories (Strings) to scan.
     * @return a list of paths representing the used classes.
     */
    public static Set getClassDependencies(String path, Set classpath)
        throws IOException {
        InputStream is = new FileInputStream(path);

        Set result = new HashSet();
        Set done = new HashSet();

        computeClassDependencies(is, classpath, done, result);

        return result;
    }

    private static void computeClassDependencies(InputStream is,
                                                 Set classpath,
                                                 Set done,
                                                 Set result) throws IOException {
        Iterator it = getClassDependencies(is).iterator();
        while (it.hasNext()) {
            String s = (String)it.next();
            if (!done.contains(s)) {
                done.add(s);

                Iterator cpit = classpath.iterator();
                while (cpit.hasNext()) {
                    String root = (String)cpit.next();
                    StringBuffer sb = new StringBuffer(root);
                    sb.append('/').append(s).append(".class");
                    String path = sb.toString();

                    File f = new File(path);
                    if (f.isFile()) {
                        result.add(path);
                        
                        computeClassDependencies(new FileInputStream(f),
                                                 classpath,
                                                 done,
                                                 result);
                    }
                }
            }
        }
    }

    /**
     * Returns the dependencies of the given class.
     * @return a list of strings representing the used classes.
     */
    public static Set getClassDependencies(InputStream is) throws IOException {
        DataInputStream dis = new DataInputStream(is);

        if (dis.readInt() != 0xcafebabe) {
            throw new IOException("Invalid classfile");
        }
        
        dis.readInt();
        
        int len = dis.readShort();
        String[] strs = new String[len];
        Set classes = new HashSet();
        Set desc = new HashSet();

        for (int i = 1; i < len; i++) {
            switch (dis.readByte() & 0xff) {
            case CONSTANT_LONG_INFO:
            case CONSTANT_DOUBLE_INFO:
                dis.readLong();
                i++;
                break;

            case CONSTANT_FIELDREF_INFO:
            case CONSTANT_METHODREF_INFO:
            case CONSTANT_INTERFACEMETHODREF_INFO:
            case CONSTANT_INTEGER_INFO:
            case CONSTANT_FLOAT_INFO:
                dis.readInt();
                break;

            case CONSTANT_CLASS_INFO:
                classes.add(new Integer(dis.readShort() & 0xffff));
                break;

            case CONSTANT_STRING_INFO:
                dis.readShort();
                break;
                
            case CONSTANT_NAMEANDTYPE_INFO:
                dis.readShort();
                desc.add(new Integer(dis.readShort() & 0xffff));
                break;

            case CONSTANT_UTF8_INFO:
                strs[i] = dis.readUTF();
                break;
                
            default:
                throw new RuntimeException();
            }
        }

        Set result = new HashSet();

        Iterator it = classes.iterator();
        while (it.hasNext()) {
            result.add(strs[((Integer)it.next()).intValue()]);
        }

        it = desc.iterator();
        while (it.hasNext()) {
            result.addAll(getDescriptorClasses(strs[((Integer)it.next()).intValue()]));
        }

        return result;
    }

    /**
     * Returns the classes contained in a field or method desciptor.
     */
    protected static Set getDescriptorClasses(String desc) {
        Set result = new HashSet();
        int  i = 0;
        char c = desc.charAt(i);
        switch (c) {
        case '(':
            loop: for (;;) {
                c = desc.charAt(++i);
                switch (c) {
                case '[':
                    do {
                        c = desc.charAt(++i);
                    } while (c == '[');
                    if (c != 'L') {
                        break;
                    }

                case 'L':
                    c = desc.charAt(++i);
                    StringBuffer sb = new StringBuffer();
                    while (c != ';') {
                        sb.append(c);
                        c = desc.charAt(++i);
                    }
                    result.add(sb.toString());
                    break;
                    
                default:
                    break;
                    
                case ')':
                    break loop;
                }
            }
            c = desc.charAt(++i);
            switch (c) {
            case '[':
                do {
                    c = desc.charAt(++i);
                } while (c == '[');
                if (c != 'L') {
                    break;
                }

            case 'L':
                c = desc.charAt(++i);
                StringBuffer sb = new StringBuffer();
                while (c != ';') {
                    sb.append(c);
                    c = desc.charAt(++i);
                }
                result.add(sb.toString());
                break;

            default:
            case 'V':
            }
            break;

        case '[':
            do {
                c = desc.charAt(++i);
            } while (c == '[');
            if (c != 'L') {
                break;
            }

        case 'L':
            c = desc.charAt(++i);
            StringBuffer sb = new StringBuffer();
            while (c != ';') {
                sb.append(c);
                c = desc.charAt(++i);
            }
            result.add(sb.toString());
            break;

        default:
        }

        return result;
    }
}
