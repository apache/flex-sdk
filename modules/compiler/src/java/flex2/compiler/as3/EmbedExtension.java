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

package flex2.compiler.as3;

import flash.swf.tags.*;
import flex2.compiler.AssetInfo;
import flex2.compiler.CompilationUnit;
import flex2.compiler.CompilerContext;
import flex2.compiler.Transcoder;
import flex2.compiler.as3.reflect.TypeTable;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.ThreadLocalToolkit;
import macromedia.asc.parser.Node;
import macromedia.asc.util.Context;

import java.util.Iterator;
import java.util.Map;

/**
 * Compiler extension, which handles [Embed] metadata.
 *  
 * @author Paul Reilly
 */
public final class EmbedExtension implements Extension
{
    private Transcoder[] transcoders;
    private String generatedOutputDir;
    private boolean checkDeprecation;

    public EmbedExtension(Transcoder[] transcoders, String generatedOutputDir, boolean checkDeprecation)
    {
        this.generatedOutputDir = generatedOutputDir;
        this.transcoders = transcoders;
        this.checkDeprecation = checkDeprecation;
    }

    public void parse1(CompilationUnit unit, TypeTable typeTable)
    {
        if (unit.metadata.size() > 0)
        {
            Node node = (Node) unit.getSyntaxTree();
            CompilerContext context = unit.getContext();
            Context cx = context.getAscContext();
            EmbedSkinClassEvaluator embedSkinClassEvaluator = new EmbedSkinClassEvaluator(unit);
            node.evaluate(cx, embedSkinClassEvaluator);
        }
    }
    
    public void parse2(CompilationUnit unit, TypeTable typeTable)
    {
        if (unit.metadata.size() > 0)
        {
            EmbedEvaluator embedEvaluator = new EmbedEvaluator(unit, typeTable.getSymbolTable(),
                                                               transcoders, generatedOutputDir,
                                                               checkDeprecation);
            embedEvaluator.setLocalizationManager(ThreadLocalToolkit.getLocalizationManager());
            Node node = (Node) unit.getSyntaxTree();
            CompilerContext context = unit.getContext();
            Context cx = context.getAscContext();
            node.evaluate(cx, embedEvaluator);
        }
    }

	public void analyze1(CompilationUnit unit, TypeTable typeTable)
	{
	}

	public void analyze2(CompilationUnit unit, TypeTable typeTable)
	{
	}

	public void analyze3(CompilationUnit unit, TypeTable typeTable)
	{
	}

	public void analyze4(CompilationUnit unit, TypeTable typeTable)
	{
	}

    public void generate(CompilationUnit unit, TypeTable typeTable)
    {
        // make sure that symbol/class associations are sane
        if (unit.hasAssets())
        {
            for (Iterator ai = unit.getAssets().iterator(); ai.hasNext();)
            {
                Map.Entry e = (Map.Entry) ai.next();
                String className = (String) e.getKey();
                DefineTag defineTag = ((AssetInfo) e.getValue()).getDefineTag();
                flex2.compiler.abc.AbcClass c = typeTable.getClass( NameFormatter.toColon(className) );

                if (c != null)
                {
                    if (!c.isPublic())
                    {
                        ThreadLocalToolkit.log( new NonPublicAssetClass( c.getName() ), unit.getSource().getNameForReporting() );
                    }

                    IncompatibleAssetClass incompatibleAssetClass = null;

                    // todo - this emacs macro created nightmare should be refactored
                    if ((defineTag instanceof DefineSprite) && !c.isSubclassOf("flash.display:Sprite"))
                    {
                        incompatibleAssetClass = new IncompatibleAssetClass(c.getName(), "DefineSprite", "flash.display.Sprite");
                    }
                    else if ((defineTag instanceof DefineBits) && !c.isSubclassOf("flash.display:Bitmap") && !c.isSubclassOf("flash.display:BitmapData"))
                    {
                        incompatibleAssetClass = new IncompatibleAssetClass(c.getName(), "DefineBits", "flash.display.Bitmap or flash.display.BitmapData");
                    }
                    else if ((defineTag instanceof DefineSound) && !c.isSubclassOf("flash.media:Sound"))
                    {
                        incompatibleAssetClass = new IncompatibleAssetClass(c.getName(), "DefineSound", "flash.media.Sound");
                    }
                    else if ((defineTag instanceof DefineFont) && !c.isSubclassOf("flash.text:Font"))
                    {
                        incompatibleAssetClass = new IncompatibleAssetClass(c.getName(), "DefineFont", "flash.text.Font");
                    }
                    else if ((defineTag instanceof DefineText) && !c.isSubclassOf("flash.display:StaticText"))
                    {
                        incompatibleAssetClass = new IncompatibleAssetClass(c.getName(), "DefineText", "flash.display.StaticText");
                    }
                    else if ((defineTag instanceof DefineEditText) && !c.isSubclassOf("flash.display:TextField"))
                    {
                        incompatibleAssetClass = new IncompatibleAssetClass(c.getName(), "DefineEditText", "flash.display.TextField");
                    }
                    else if ((defineTag instanceof DefineShape) && !c.isSubclassOf("flash.display:Shape"))
                    {
                        incompatibleAssetClass = new IncompatibleAssetClass(c.getName(), "DefineShape", "flash.display.Shape");
                    }
                    else if ((defineTag instanceof DefineButton) && !c.isSubclassOf("flash.display:SimpleButton"))
                    {
                        incompatibleAssetClass = new IncompatibleAssetClass(c.getName(), "DefineButton", "flash.display.SimpleButton");
                    }
                    else if ((defineTag instanceof DefineBinaryData) && !c.isSubclassOf("flash.utils:ByteArray"))
                    {
                        incompatibleAssetClass = new IncompatibleAssetClass(c.getName(), "DefineBinaryData", "flash.utils.ByteArray");
                    }

                    if (incompatibleAssetClass != null)
                    {
                        ThreadLocalToolkit.log(incompatibleAssetClass, unit.getSource().getNameForReporting());
                    }
                }
            }
        }
    }

	public static class NonPublicAssetClass extends CompilerMessage.CompilerWarning
	{
	    private static final long serialVersionUID = 1300245254451431087L;
        public NonPublicAssetClass( String assetClass )
	    {
	        this.assetClass = assetClass;
	    }
	    public final String assetClass;
	}

	public static class IncompatibleAssetClass extends CompilerMessage.CompilerWarning
	{
	    private static final long serialVersionUID = 7943386121665703853L;
        public IncompatibleAssetClass( String assetClass, String assetType, String requiredBase )
	    {
	        super();
	        this.assetClass = assetClass;
	        this.assetType = assetType;
	        this.requiredBase = requiredBase;
	    }
	    public final String assetClass;
	    public final String assetType;
	    public final String requiredBase;
	}
}
