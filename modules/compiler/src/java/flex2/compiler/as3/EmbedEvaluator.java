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

import flex2.compiler.*;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.QName;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.as3.reflect.MetaData;
import flex2.compiler.as3.reflect.NodeMagic;
import flex2.compiler.as3.MetaDataEvaluator.MetaDataRequiresDefinition;
import flex2.compiler.io.TextFile;
import flex2.compiler.util.MultiName;
import flex2.compiler.util.NameFormatter;
import macromedia.asc.parser.*;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;
import flash.swf.tools.as3.EvaluatorAdapter;
import flash.util.FileUtils;
import flash.util.Trace;

import java.io.File;
import java.io.IOException;
import java.util.*;

/**
 * Evaluator that transcodes Embed resources, adds assets to the
 * CompilationUnit, and turns variable level Embeds into class level
 * Embeds.
 *
 * @author Paul Reilly
 * @author Brian Deitte
 */
class EmbedEvaluator extends EvaluatorAdapter
{
    private CompilationUnit unit;
    private String generatedOutputDir;
    private boolean checkDeprecation;
    private Transcoder[] transcoders;
    private Stack<EmbedData> embedDataStack;
	private Set<ClassDefinitionNode> evaluatedClasses;
    private SymbolTable symbolTable;

    EmbedEvaluator(CompilationUnit unit, SymbolTable symbolTable, Transcoder[] transcoders,
                   String generatedOutputDir, boolean checkDeprecation)
    {
        this.unit = unit;
        this.symbolTable = symbolTable;
        this.generatedOutputDir = generatedOutputDir;
        this.transcoders = transcoders;
        this.checkDeprecation = checkDeprecation;
        embedDataStack = new Stack<EmbedData>();
		evaluatedClasses = new HashSet<ClassDefinitionNode>();
	}

    private EmbedData getEmbedData()
    {
        EmbedData embedData = null;
        if (embedDataStack.size() != 0)
        {
            embedData = embedDataStack.peek();
        }
        return embedData;
    }

    public Value evaluate(Context context, ClassDefinitionNode node)
    {
		if (!evaluatedClasses.contains(node))
		{
			evaluatedClasses.add(node);
			String packageName = NodeMagic.getPackageName(node);
			String className = node.name.name;

			EmbedData embedData = getEmbedData();
			if (embedData == null || embedData.inUse)
			{
				embedData = new EmbedData();
				embedDataStack.push(embedData);
			}
			embedData.inUse = true;
			embedData.referenceClassName = className;

			if (node.statements != null)
			{
				node.statements.evaluate(context, this);
			}

			if (embedData.hasData())
			{
				unit.addGeneratedSources( generateSources(packageName, context, node) );
				embedData.clear();
			}

			if (embedDataStack.size() > 0)
			{
				embedDataStack.pop();
			}
			embedData.inUse = false;
		}

		return null;
   }

    public Value evaluate(Context context, MetaDataNode node)
    {
        Node def = node.def;
        if ( "Embed".equals(node.getId()) )
        {
            InputBuffer input = context.input;
            String file;
            int line = -1;
            int col = -1;

            if (input != null)
            {
                file = input.origin;
                int pos = node.pos();
                line = input.getLnNum(pos);
                col = input.getColPos(pos);
            }
            else
            {
                file = context.scriptName();
            }

            if (def instanceof VariableDefinitionNode)
            {
                VariableDefinitionNode variableDefinition = (VariableDefinitionNode) def;

                if ((variableDefinition.list != null) &&
                    (variableDefinition.list.items != null) &&
                    (variableDefinition.list.items.size() > 0))
                {
                    Object item = variableDefinition.list.items.get(0);

                    if (item instanceof VariableBindingNode)
                    {
                        VariableBindingNode variableBinding = (VariableBindingNode) item;

                        if (variableBinding.initializer == null)
                        {
                            EmbedData embedData = getEmbedData();
                            if (embedData == null)
                            {
                                context.localizedError2(node.pos(), new EmbedOnlyOnClassesAndVars());
                                return null;
                            }
                            String name = variableBinding.variable.identifier.name;
                            String className = null;
                            
                            // If this is an embedded css asset then prefix the 
                            // name with a generic "_class" instead of the name
                            // of the reference class. We want embedded css 
                            // assets to have the same name no matter which
                            // class they are embedded into.
                            if (name != null && name.startsWith("_embed_css_"))
                                className = "_class" + name;
                            else
                                className = embedData.referenceClassName + "_" + name;
                            
                            unit.expressions.add(new MultiName(NameFormatter.toColon(className)));
                            Map<String, Object> values = getMetaDataValues(node, context);

                            // Yeah, I feel dirty doing this, but I don't feel like making a separate map.
                            if (!values.containsKey( Transcoder.FILE ))
                            {
                            	if (file.indexOf('\\') != -1)
                            	{
                            		values.put( Transcoder.FILE, file.replace('\\', '/'));
                            		values.put( Transcoder.PATHSEP, "true");
                            	}
                            	else
                            	{
                            		values.put( Transcoder.FILE, file );
                            	}

                                if (input != null)
                                {
                                    values.put( Transcoder.LINE, new Integer(line).toString() );
                                    values.put( Transcoder.COLUMN, new Integer(col).toString() );
                                }
                            }

                            getEmbedData().class2params.put( className, values );

                            String type = NodeMagic.lookupType( variableBinding );
                            boolean correctType = false;
                            if (type != null)
                            {
                                if (type.equals( "Class" ))
                                {
                                    correctType = true;
                                    variableBinding.initializer = generateClassInitializer( className );
                                }
                                else if (type.equals( "String" ))
                                {
                                    correctType = true;
                                    // FIXME- need way to introduce class dep from string embeds
                                    variableBinding.initializer = generateStringInitializer( className );
                                }
                            }

                            if (!correctType)
                            {
	                            context.localizedError2(node.pos(), new UnsupportedTypeForEmbed());
                            }

                        }
                        else
                        {
	                        context.localizedError2(node.pos(), new InvalidEmbedVariable());
                        }
                    }
                }
            }
            else if (def instanceof ClassDefinitionNode)
            {
                ClassDefinitionNode cdn = (ClassDefinitionNode)def;
                String pkg = NodeMagic.getPackageName(cdn);
                String cls = ((pkg == null) || (pkg.length() == 0)) ? cdn.name.name : pkg + "." + cdn.name.name;
                Map<String, Object> values = getMetaDataValues(node, context);

                // Yeah, I feel dirty doing this, but I don't feel like making a separate map.
                if (!values.containsKey( Transcoder.FILE ))
                {
                	if (file.indexOf('\\') != -1)
                	{
                		values.put( Transcoder.FILE, file.replace('\\', '/'));
                		values.put( Transcoder.PATHSEP, "true");
                	}
                	else
                	{
                		values.put( Transcoder.FILE, file );
                	}

                    if (input != null)
                    {
                        values.put( Transcoder.LINE, new Integer(line).toString() );
                        values.put( Transcoder.COLUMN, new Integer(col).toString() );
                    }
                }

                Transcoder.TranscodingResults asset = EmbedUtil.transcode(transcoders, unit, symbolTable,
                                                                          cls, values, line, col, false);

                if ((asset == null) && values.containsKey(Transcoder.SOURCE))
                {
                    context.localizedError2(node.pos(), new UnableToTranscode(values.get(Transcoder.SOURCE)));
                }

                // code below to should given a warning once we figure out non-AS2 way to call stop.  Since
                // this will most likely be a solution that's generated in a class, won't be supported on
                // classes.  Should also put this warning in MxmlDocument if it isn't moved to var level embeds
                //if (asset.defineTag instanceof DefineSprite && ((DefineSprite)asset.defineTag).needsStop)
                // {}

                // TODO: compare DefineTag/associatedClass against given class
            }
            else if (def == null)
            {
                context.localizedError2(node.pos(), new MetaDataRequiresDefinition());
            }
            else
            {
	            context.localizedError2(node.pos(), new EmbedOnlyOnClassesAndVars());
            }
        }

        return null;
    }

    private Map<String, Object> getMetaDataValues(MetaDataNode node, Context context)
    {
        MetaData metaData = new MetaData(node);
        int len = metaData.count();
        Map<String, Object> values = new HashMap<String, Object>();
        for (int i = 0; i < len; i++)
        {
            String key = metaData.getKey(i);
            String value = metaData.getValue(i);
            // FIXME: look for place where source is being added to generated Embeds remove the key.equals check
            if (key == null || key.equals(Transcoder.SOURCE))
            {
                int octothorpe = value.indexOf( "#" );
                if (octothorpe != -1)
                {
                    Source src = unit.getSource();
                    if (src.resolve(value) != null)
                    {
                        values.put(Transcoder.SOURCE, value);
                    }
                    else
                    {
                        values.put(Transcoder.SOURCE, value.substring( 0, octothorpe ));
                        values.put(Transcoder.SYMBOL, value.substring( octothorpe + 1));
                    }
                }
                else
                {
                    values.put(Transcoder.SOURCE, value);
                }
            }
            else
            {
                values.put(key, value);
            }
        }
        
        if (checkDeprecation && (values.containsKey("flashType") || values.containsKey("flash-type")))
        {
        	String deprecated = (values.containsKey("flashType")) ? "flashType" : "flash-type";
        	String replacement = (values.containsKey("flashType")) ? "advancedAntiAliasing" : "advanced-anti-aliasing";
        	context.localizedError2(node.pos(), new DeprecatedAttribute(deprecated, replacement, "3.0"));
        }
        
        return values;
    }

    public Value evaluate(Context context, ProgramNode node)
    {
        embedDataStack = new Stack<EmbedData>();

        super.evaluate(context, node);

        embedDataStack = null;

        return null;
    }

    private Map<QName, Source> generateSources(String packageName, Context cx, Node node)
    {
        Map<QName, Source> sources = new HashMap<QName, Source>();
        EmbedData embedData = getEmbedData();

        for (Iterator<Map.Entry<String, Map<String, Object>>> iterator = embedData.class2params.entrySet().iterator(); iterator.hasNext();)
        {
            Map.Entry<String, Map<String, Object>> e = iterator.next();
            String className = e.getKey();
            Map<String, Object> params = e.getValue();

            generateSources(sources, packageName, className, params, cx, node);
        }
        return sources;
    }

    private void generateSources(Map<QName, Source> sources, String packageName, String className, Map<String, Object> embedMap, Context cx, Node node )
    {
        int line = embedMap.containsKey( Transcoder.LINE ) ? (Integer.parseInt( embedMap.get( Transcoder.LINE ).toString() )) : -1;
        int col = embedMap.containsKey( Transcoder.COLUMN ) ? (Integer.parseInt( embedMap.get( Transcoder.COLUMN ).toString() )) : -1;
        String path = embedMap.containsKey( Transcoder.FILE ) ? (String) embedMap.get( Transcoder.FILE ) : "";
        String pathSep = embedMap.containsKey( Transcoder.PATHSEP ) ? (String) embedMap.get( Transcoder.PATHSEP ) : null;
        if ("true".equals(pathSep))
        {
        	path = path.replace('/', '\\');
        }

        // TODO: This kind of logic should be encapsulated inside Source or even QName
        String packagePrefix = packageName == null || packageName.equals( "" ) ? "" : packageName + ".";
        String nameForReporting = path != null ? path : unit.getSource().getNameForReporting();

        try
        {
            Transcoder.TranscodingResults asset = EmbedUtil.transcode(transcoders, unit, symbolTable,
                                                                      packagePrefix + className,
                                                                      embedMap, line, col, true);
            if (asset != null)
            {
                try
                {
                    generateSource(sources, asset, packageName, className);
                }
                catch(IOException ioe)
                {
                    if (Trace.error)
                    {
                        ioe.printStackTrace();
                    }
                    cx.localizedError(nameForReporting, line, col, ioe.getLocalizedMessage(), "");
                }
            }
    	    else if (embedMap.containsKey(Transcoder.SOURCE))
    	    {
    		    Object what = embedMap.get(Transcoder.SOURCE);
    		    cx.localizedError2(nameForReporting, line, col, new UnableToTranscode(what), "");
    	    }
        }
        catch (Exception e)
        {
            if (Trace.error)
            {
                e.printStackTrace();
            }
            cx.localizedError2(nameForReporting, line, col, new UnableToCreateSource(packagePrefix + className, e), null);
        }
    }

    private void generateSource(Map<QName, Source> sources,
            Transcoder.TranscodingResults asset, String packageName, String className) throws IOException
    {
        // TODO: This kind of logic should be encapsulated inside Source or even QName
        String packagePrefix = packageName == null || packageName.equals("") ? "" : packageName + ".";
        String generatedName = (packagePrefix + className).replace('.', File.separatorChar) + ".as";

        if (generatedOutputDir != null)
        {
            FileUtils.writeClassToFile(generatedOutputDir, packagePrefix, className + ".as", asset.generatedCode);
        }

        // timestamp of this compiler-generated Source should match the asset file timestamp
        String relativePath = "";
        if (packageName != null)
        {
            relativePath = packageName.replace( '.', '/' );
        }

        long modified = asset.assetSource != null ? asset.assetSource.getLastModified() : -1; 
        TextFile file = new TextFile(asset.generatedCode, generatedName, null, MimeMappings.AS, modified);
        Source source = new Source(file, relativePath, className, null, false, false, false);
        source.setAssetInfo(unit.getAssets().get(className));
        source.setPathResolver(unit.getSource().getPathResolver());

        if (source != null)
            sources.put(new QName(packageName, className), source);

        // Also recursively generate sources for any additional assets
        List<Transcoder.TranscodingResults> childAssets = asset.additionalAssets;
        if (childAssets != null)
        {
            for (int i = 0; i < childAssets.size(); i++)
            {
                Transcoder.TranscodingResults childAsset = childAssets.get(i);
                String qualifiedClassName = childAsset.className;
                if (qualifiedClassName != null)
                {
                    int dot = qualifiedClassName.lastIndexOf('.');
                    if (dot == -1)
                    {
                        className = qualifiedClassName;
                        packageName = "";
                    }
                    else
                    {
                        className = qualifiedClassName.substring(dot + 1);
                        packageName = qualifiedClassName.substring(0, dot);
                    }

                    generateSource(sources, childAsset, packageName, className);
                }
            }
        }
    }

    private MemberExpressionNode generateClassInitializer(String name)
    {
        IdentifierNode identifier = new IdentifierNode(name, 0);

        GetExpressionNode getExpression = new GetExpressionNode(identifier);

        getExpression.pos(0);

        MemberExpressionNode result = new MemberExpressionNode(null, getExpression, 0);

        return result;
    }

    private LiteralStringNode generateStringInitializer(String name)
    {
        LiteralStringNode literalString = new LiteralStringNode(name);

        literalString.pos(0);

        return literalString;
    }

    // EmbedData holds all embeds for a given class
    class EmbedData
    {
        public String referenceClassName;
        public Map<String, Map<String, Object>> class2params = new HashMap<String, Map<String, Object>>();    // unique prefix -> map of embed params
        public boolean inUse;

        public void clear()
        {
            if (hasData())
            {
                class2params = new HashMap<String, Map<String, Object>>();
            }
        }

        public boolean hasData()
        {
            return (class2params.size() != 0);
        }
    }

	// error messages

	public static class UnableToTranscode extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -3610099352282214079L;

        public UnableToTranscode(Object what)
		{
			super();
			this.what = what;
		}

		public final Object what;
	}

	public static class UnableToCreateSource extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -8930568038744470639L;

        public UnableToCreateSource(String name)
		{
			super();
			this.name = name;
		}

        public UnableToCreateSource(String name, Throwable rootCause)
        {
            super(rootCause);
            this.name = name;
        }

		public final String name;
	}

	public static class UnsupportedTypeForEmbed extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 8396431734939591871L;

        public UnsupportedTypeForEmbed()
		{
			super();
		}
	}

	public static class InvalidEmbedVariable extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 4571106802738159454L;

        public InvalidEmbedVariable()
		{
			super();
		}
	}

	public static class EmbedOnlyOnClassesAndVars extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -7360808013645966487L;

        public EmbedOnlyOnClassesAndVars()
		{
			super();
		}
	}
	
	public static class DeprecatedAttribute extends CompilerMessage.CompilerWarning
	{
		private static final long serialVersionUID = 2749704493074687265L;

        public DeprecatedAttribute(String deprecated, String replacement, String since)
		{
			this.deprecated = deprecated;
			this.replacement = replacement;
			this.since = since;
		}
		
		public final String deprecated, replacement, since;
	}
}
