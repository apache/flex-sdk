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

package flex2.compiler.media;

import java.util.ArrayList;
import java.util.Map;

import flex2.compiler.SymbolTable;
import flex2.compiler.TranscoderException;
import flex2.compiler.common.PathResolver;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.NameFormatter;

/**
 * Transcodes a compiled PBJ shader file to an ActionScript class.
 * 
 * @author Peter Farland
 */
public class PBJTranscoder extends AbstractTranscoder
{
    private DataTranscoder dataTranscoder = new DataTranscoder();

    public PBJTranscoder()
    {
        super(new String[]{MimeMappings.PBJ}, null, true);
    }

    @Override
    public TranscodingResults doTranscode(PathResolver context,
            SymbolTable symbolTable, Map<String, Object> args,
            String className, boolean generateSource)
            throws TranscoderException
    {
        VirtualFile source = resolveSource(context, args);

        // Create ByteArray subclass
        String byteArrayClassName = className + "ByteArray";
        args.put(NEWNAME, byteArrayClassName);
        TranscodingResults byteArrayResults = dataTranscoder.doTranscode(context,
                symbolTable, args, byteArrayClassName, generateSource);
        byteArrayResults.className = byteArrayClassName;

        // Create Shader subclass
        TranscodingResults shaderResults = new TranscodingResults(source);
        shaderResults.className = className;
        if (generateSource)
            shaderResults.generatedCode = generateSource(className, byteArrayClassName);

        // Associate ByteArray subclass asset with Shader subclass asset.
        shaderResults.additionalAssets = new ArrayList<TranscodingResults>();
        shaderResults.additionalAssets.add(byteArrayResults);

        return shaderResults;
    }

    @Override
    public boolean isSupportedAttribute(String attr)
    {
        return false;
    }

    /**
     * Generates source:
     * <pre>
     * package mypackage
     * {
     * 
     * import flash.display.Shader;
     * import flash.utils.ByteArray;
     * import mx.core.IFlexAsset;
     * import mypackage.MyShaderAssetByteArray;
     * 
     * public class MyShaderAsset extends Shader implements IFlexAsset
     * {
     *     public function MyShaderAsset()
     *     {
     *         super(null);
     *         byteCode = new mypackage.MyShaderAssetByteArray();
     *     }
     * }
     * }
     * </pre>
     * 
     * @param className
     * @param results
     */
    private String generateSource(String fullClassName, String byteArrayClassName)
    {
        String packageName = NameFormatter.retrievePackageName(fullClassName);
        String className = NameFormatter.retrieveClassName(fullClassName);

        StringBuilder sb = new StringBuilder();
        sb.append("package ").append(packageName).append("\n");
        sb.append("{\n");
        sb.append("import flash.display.Shader;\n");
        sb.append("import flash.utils.ByteArray;\n");
        sb.append("import mx.core.IFlexAsset;\n");
        if (packageName.length() > 0)
            sb.append("import ").append(byteArrayClassName).append(";\n");
        sb.append("\n");
        sb.append("public class ").append(className).append(" extends Shader implements IFlexAsset\n");
        sb.append("{\n");
        sb.append("\tpublic function ").append(className).append("()\n");
        sb.append("    {\n");
        sb.append("        super();\n");
        sb.append("        byteCode = new " + byteArrayClassName + "();\n");
        sb.append("    }\n");
        sb.append("}\n");
        sb.append("}\n");
        return sb.toString();
    }
}
