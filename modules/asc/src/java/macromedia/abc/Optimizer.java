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

import macromedia.asc.util.ByteList;
import macromedia.asc.util.ObjectList;

import java.io.IOException;
import java.io.FileOutputStream;

/**
 * @author Erik Tierney
 */
public class Optimizer
{
    public static void main(String[] args)
    {
        ObjectList<String> file_names = new ObjectList();
        String output_file = "merged.abc";
        for( int i = 0; i < args.length; ++i )
        {
            if( args[i].equals("-o") )
            {
                output_file = args[++i];
            }
            else
            {
                file_names.add(args[i]);
            }
        }

        BytecodeBuffer[] byte_codes = new BytecodeBuffer[file_names.size()];
        for(int i = 0; i < file_names.size(); ++i )
        {
            try
            {
                BytecodeBuffer buf = new BytecodeBuffer(file_names.at(i));
                byte_codes[i] = buf;
            }
            catch( IOException ioe )
            {

            }
        }
        byte[] abc = optimize(byte_codes);

        try
        {
            if( abc != null )
            {
                // kkiran close the FileOutputStream, else CP wont be able to
                // read the merged "abc" file
                //new FileOutputStream(output_file).write(abc);
                 FileOutputStream fos = new FileOutputStream(output_file);
                 fos.write(abc);
                 fos.close();
            }
            else
            {
                System.err.println("Error occurred when merging abc files.");
            }
        }
        catch(IOException ioe )
        {
            ioe.printStackTrace();
        }

    }

    public static ByteList optimize(ByteList bytes )
    {
        BytecodeBuffer[] byte_codes = new BytecodeBuffer[1];
        byte_codes[0] = new BytecodeBuffer(bytes.toByteArray());
        byte[] temp = optimize(byte_codes);
        ByteList new_bytes = new ByteList(temp.length);
        new_bytes.addAll(temp);
        return new_bytes;
    }

    public static byte[] optimize(BytecodeBuffer[] byte_codes)
    {
        int abcSize = byte_codes.length;
        Decoder[] decoders = new Decoder[abcSize];
        ConstantPool[] pools = new ConstantPool[abcSize];
        int majorVersion = 0, minorVersion = 0;

        boolean skipFrame = false;

        for( int j = 0; j < abcSize; ++j )
        {
            try
            {
                // ThreadLocalToolkit.logInfo(tag.name);
                decoders[j] = new Decoder(byte_codes[j]);
                if (decoders[j].majorVersion > majorVersion)
                	majorVersion = decoders[j].majorVersion;
                if (decoders[j].minorVersion > minorVersion)
                	minorVersion = decoders[j].minorVersion;
                pools[j] = decoders[j].constantPool;
            }
            catch (Throwable ex)
            {
                ex.printStackTrace();
                skipFrame = true;
                break;
            }

        }

        Encoder encoder = new Encoder(majorVersion, minorVersion);
        encoder.enablePeepHole();
        Decoder decoder = null;
        // all the constant pools are merged here...
        try
        {
            encoder.addConstantPools(pools);
            //if (!keepDebugOpcodes)
            {
                encoder.disableDebugging();
            }
            // always remove metadata...
            encoder.removeMetadata();
            encoder.configure(decoders);
        }
        catch (Throwable ex)
        {
            ex.printStackTrace();
            return null;
        }


        // decode methodInfo...
        for (int j = 0; j < abcSize; j++)
        {
            decoder = decoders[j];
            encoder.useConstantPool(j);

            Decoder.MethodInfo methodInfo = decoder.methodInfo;

            try
            {
                for (int k = 0, infoSize = methodInfo.size(); k < infoSize; k++)
                {
                    methodInfo.decode(k, encoder);
                }
            }
            catch (Throwable ex)
            {
                ex.printStackTrace();
                skipFrame = true;
                break;
            }
        }

        if (skipFrame)
        {
            return null;
        }

        // decode metadataInfo...
        for (int j = 0; j < abcSize; j++)
        {
            decoder = decoders[j];
            encoder.useConstantPool(j);

            Decoder.MetaDataInfo metadataInfo = decoder.metadataInfo;

            try
            {
                for (int k = 0, infoSize = metadataInfo.size(); k < infoSize; k++)
                {
                    metadataInfo.decode(k, encoder);
                }
            }
            catch (Throwable ex)
            {
                ex.printStackTrace();
                skipFrame = true;
                break;
            }
        }

        if (skipFrame)
        {
            return null;
        }

        // decode classInfo...

        for (int j = 0; j < abcSize; j++)
        {
            decoder = decoders[j];
            encoder.useConstantPool(j);

            Decoder.ClassInfo classInfo = decoder.classInfo;

            try
            {
                for (int k = 0, infoSize = classInfo.size(); k < infoSize; k++)
                {
                    classInfo.decodeInstance(k, encoder);
                }
            }
            catch (Throwable ex)
            {
                ex.printStackTrace();
                skipFrame = true;
                break;
            }
        }

        if (skipFrame)
        {
            return null;
        }

        for (int j = 0; j < abcSize; j++)
        {
            decoder = decoders[j];
            encoder.useConstantPool(j);

            Decoder.ClassInfo classInfo = decoder.classInfo;

            try
            {
                for (int k = 0, infoSize = classInfo.size(); k < infoSize; k++)
                {
                    classInfo.decodeClass(k, 0, encoder);
                }
            }
            catch (Throwable ex)
            {
                ex.printStackTrace();
                skipFrame = true;
                break;
            }
        }

        if (skipFrame)
        {
            return null;
        }

        // decode scripts...
        for (int j = 0; j < abcSize; j++)
        {
            decoder = decoders[j];
            encoder.useConstantPool(j);

            Decoder.ScriptInfo scriptInfo = decoder.scriptInfo;

            try
            {
                for (int k = 0, scriptSize = scriptInfo.size(); k < scriptSize; k++)
                {
                    scriptInfo.decode(k, encoder);
                }
            }
            catch (Throwable ex)
            {
                ex.printStackTrace();
                skipFrame = true;
                break;
            }
        }

        if (skipFrame)
        {
            return null;
        }

        // decode method bodies...
        for (int j = 0; j < abcSize; j++)
        {
            decoder = decoders[j];
            encoder.useConstantPool(j);

            Decoder.MethodBodies methodBodies = decoder.methodBodies;

            try
            {
                for (int k = 0, bodySize = methodBodies.size(); k < bodySize; k++)
                {
                    methodBodies.decode(k, 2, encoder);
                }
            }
            catch (Throwable ex)
            {
                ex.printStackTrace();
                skipFrame = true;
                break;
            }
        }

        if (skipFrame)
        {
            return null;
        }

        byte[] abc = encoder.toABC();
        return abc;
    }
}
