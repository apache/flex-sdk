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

import flex2.compiler.AbstractSubCompiler;
import flex2.compiler.CompilerContext;
import flex2.compiler.CompilationUnit;
import flex2.compiler.CompilerBenchmarkHelper;
import flex2.compiler.Source;
import flex2.compiler.SymbolTable;
import flex2.compiler.abc.AbcClass;
import flex2.compiler.abc.MetaData;
import flex2.compiler.as3.reflect.TypeTable;
import flex2.compiler.as3.reflect.NodeMagic;
import flex2.compiler.css.StyleConflictException;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.LineNumberMap;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.MultiName;
import flex2.compiler.util.MultiNameMap;
import flex2.compiler.util.Name;
import flex2.compiler.util.NameFormatter;
import flex2.compiler.util.QName;
import flex2.compiler.util.QNameList;
import flex2.compiler.util.QNameSet;
import flex2.compiler.util.ThreadLocalToolkit;
import macromedia.asc.embedding.ConfigVar;
import macromedia.asc.embedding.LintEvaluator;
import macromedia.asc.embedding.WarningConstants;
import macromedia.asc.embedding.avmplus.GlobalBuilder;
import macromedia.asc.embedding.avmplus.RuntimeConstants;
import macromedia.asc.parser.*;
import macromedia.asc.semantics.*;
import macromedia.asc.util.Context;
import macromedia.asc.util.ContextStatics;
import macromedia.asc.util.IntegerPool;
import macromedia.asc.util.ObjectList;
import macromedia.asc.util.Slots;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;


/**
 * The sub-compiler used to compile .as files.  Many of the other
 * sub-compilers wrap an instance of this class.  In addition to being
 * the primary interface with ASC, this class also handles invoking
 * the compiler extensions and collecting benchmark data.
 *
 * @author Clement Wong
 * @see macromedia.asc.parser.Parser
 * @see macromedia.asc.semantics.ConstantEvaluator
 * @see macromedia.asc.semantics.FlowAnalyzer
 */
public class As3Compiler extends AbstractSubCompiler implements flex2.compiler.SubCompiler
{
	static
	{
		// C: Is static method call really a good idea?
		TypeValue.init();
		ObjectValue.init();
	}

	public static final String AttrTypeTable = TypeTable.class.getName();
    private static final String COMPILER_NAME = "as3";

    /**
     * Implementation of ASC's CompilerHandler which uses the
     * ThreadLocalToolkit's Logger to log errors and warnings.
     */
	public static class CompilerHandler extends macromedia.asc.embedding.CompilerHandler
	{
		public CompilerHandler()
		{
			super();
		}

		public CompilerHandler(Source s)
		{
			this.s = s;
		}

		private Source s;

		public void error2(String filename, int ln, int col, Object msg, String source)
		{
			ThreadLocalToolkit.log((CompilerMessage) msg, filename, ln, col, source);
		}

		public void warning2(String filename, int ln, int col, Object msg, String source)
		{
			ThreadLocalToolkit.log((CompilerMessage) msg, filename, ln, col, source);
		}

		public void error(String filename, int ln, int col, String msg, String source, int errorCode)
		{
			if (errorCode != -1)
			{
				ThreadLocalToolkit.logError(filename, ln, col, msg, source, errorCode);
			}
			else
			{
				ThreadLocalToolkit.logError(filename, ln, col, msg, source);
			}
		}

		public void warning(String filename, int ln, int col, String msg, String source, int errorCode)
		{
            msg = mapRenamedVariables(msg);

			if (errorCode != -1)
			{
				ThreadLocalToolkit.logWarning(filename, ln, col, msg, source, errorCode);
			}
			else
			{
				ThreadLocalToolkit.logWarning(filename, ln, col, msg, source);
			}
		}

		public void error(String filename, int ln, int col, String msg, String source)
		{
			ThreadLocalToolkit.logError(filename, ln, col, msg, source);
		}

		public void warning(String filename, int ln, int col, String msg, String source)
		{
			ThreadLocalToolkit.logWarning(filename, ln, col, msg, source);
		}

		public FileInclude findFileInclude(String parentPath, String filespec)
		{
			Object obj = s == null ? null : s.getSourceFragment(filespec);

			if (obj instanceof VirtualFile)
			{
				VirtualFile f = (VirtualFile) obj;
				if (f.getParent().equals(parentPath))
				{
					FileInclude incl = new FileInclude();
					try
					{
						if (f.isTextBased())
						{
							incl.text = f.toString();
						}
						else
						{
							incl.in = f.getInputStream();
						}
						incl.parentPath = parentPath;
						// If asc ever reports a problem, it will use the name for reporting...
						incl.fixed_filespec = f.getNameForReporting();
						return incl;
					}
					catch (IOException ex)
					{
						return null;
					}
				}
			}

			return null;
		}

        // flex2.compiler.mxml.MxmlLogAdapter has some similar logic.  Ideally it should be
        // consolidated and move into a shared Logger adapter/filter.
        private String mapRenamedVariables(String msg)
        {
            CompilerContext context = s.getCompilationUnit().getContext();
            Map renamedVariableMap = (Map) context.getAttribute(CompilerContext.RENAMED_VARIABLE_MAP);

            if (renamedVariableMap != null)
            {
                Iterator iterator = renamedVariableMap.entrySet().iterator();

                while ( iterator.hasNext() )
                {
                    Map.Entry entry = (Map.Entry) iterator.next();
                    String newVariableName = (String) entry.getKey();
                    String oldVariableName = (String) entry.getValue();
                    msg = msg.replaceAll("'" + newVariableName + "'", "'" + oldVariableName + "'");
                }
            }

            return msg;
        }
	}

	public As3Compiler(As3Configuration as3Configuration)
	{
		mimeTypes = new String[]{MimeMappings.AS};
		compilerExtensions = new ArrayList<Extension>();
		this.as3Configuration = as3Configuration;

		processCoachSettings();
	}

    private HashMap<Integer, Boolean> warnMap = null;
	private String[] mimeTypes;
	private List<Extension> compilerExtensions;
	private As3Configuration as3Configuration;
    private boolean coachWarningsAsErrors = false;

    /**
     * The name of this compiler as a simple String identifier.
     * 
     * @return This Compiler's name. 
     */
    public String getName()
    {
        return COMPILER_NAME;
    }

	public boolean isSupported(String mimeType)
	{
		return mimeTypes[0].equals(mimeType);
	}

	public String[] getSupportedMimeTypes()
	{
		return mimeTypes;
	}

	public void addCompilerExtension(Extension ext)
	{
		compilerExtensions.add(ext);
	}

	public Source preprocess(Source source)
	{
		return source;
	}

	public CompilationUnit parse1(Source source, SymbolTable symbolTable)
	{
        if (benchmarkHelper != null)
        {
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.PARSE1, source.getNameForReporting());
        }

		CompilationUnit unit = source.getCompilationUnit();

        if (unit != null && unit.hasTypeInfo)
        {
            return unit;
        }

		String path = source.getName();
		ProgramNode node = null;
        CompilerContext context = null;
        Context cx;

        if ((unit != null) && (unit.getSyntaxTree() != null))
        {
            node = (ProgramNode) unit.getSyntaxTree();
            cx = node.cx;
        }
        else
        {
            context = new CompilerContext();
            cx = new Context(symbolTable.perCompileData);
            cx.setScriptName(source.getName());
            cx.setPath(source.getParent());

            cx.setEmitter(symbolTable.emitter);
            cx.setHandler(new CompilerHandler(source));
            symbolTable.perCompileData.handler = cx.getHandler();

            context.setAscContext(cx);

            // conditional compilation: add config settings from the compiler configuration
            // this must be done BEFORE parsing
            final ObjectList<ConfigVar> arr = as3Configuration.getDefine();
            if (arr != null)
            {
                cx.config_vars.addAll(arr);
            }

            assert cx.getNodeFactory().compound_names.size() == 0 : "cleanNodeFactory() should have been called";

            if (source.isTextBased())
            {
                Parser parser = new Parser(cx, source.getInputText(), path, as3Configuration.doc(), false);
                node = parser.parseProgram();

                source.close();
                cleanNodeFactory(cx.getNodeFactory());
            }
            else
            {
                BufferedInputStream in = null;

                try
                {
                    in = new BufferedInputStream(source.getInputStream());
                    Parser parser = null;
                    if (as3Configuration.doc())
                    {
                        if (as3Configuration.getEncoding() == null)
                        {
                            parser = new Parser(cx, in, path, true, false);
                        }
                        else
                        {
                            parser = new Parser(cx, in, path, as3Configuration.getEncoding(), true, false);
                        }
                    }
                    else
                    {
                        if (as3Configuration.getEncoding() == null)
                        {
                            parser = new Parser(cx, in, path);
                        }
                        else
                        {
                            parser = new Parser(cx, in, path, as3Configuration.getEncoding());
                        }
                    }
                    node = parser.parseProgram();

                    cleanNodeFactory(cx.getNodeFactory());
                }
                catch (IOException ex)
                {
                    ThreadLocalToolkit.logError(source.getNameForReporting(), ex.getLocalizedMessage());
                }
                finally
                {
                    if (in != null)
                    {
                        try
                        {
                            in.close();
                        }
                        catch (IOException ex)
                        {
                        }
                    }
                }
            }

            if (ThreadLocalToolkit.errorCount() > 0)
            {
                return null;
            }
        }

		// conditional compilation: run the AS Configurator over the syntax tree
		// (this must be done before transferDefinitions(), as early as possible after parsing)
		node.evaluate(cx, new ConfigurationEvaluator());

        if (ThreadLocalToolkit.errorCount() > 0)
        {
            return null;
        }
        
        if (unit == null)
        {
            unit = source.newCompilationUnit(node, context);
        }

		SyntaxTreeEvaluator treeEvaluator = new SyntaxTreeEvaluator(unit);
		treeEvaluator.setLocalizationManager(ThreadLocalToolkit.getLocalizationManager());
		node.evaluate(cx, treeEvaluator);

		if (ThreadLocalToolkit.errorCount() > 0)
		{
			return null;
		}

		int size = (node.statements != null) ? node.statements.items.size() : 0;
		List<Node> definitions = new ArrayList<Node>((source.isSourcePathOwner() || source.isSourceListOwner() ||
				                          source.isResourceBundlePathOwner()) ? 1 : size);
		boolean inPackage = false;

		for (int i = 0; i < size; i++)
		{
			Node n = node.statements.items.get(i);
			if (n instanceof PackageDefinitionNode)
			{
				inPackage = !inPackage;
			}
			else if (n.isDefinition() && inPackage)
			{
				definitions.add(n);
			}
		}

		// context.setAttribute("definitions", definitions);
		transferDefinitions(unit.topLevelDefinitions, definitions);

		InheritanceEvaluator inheritanceEvaluator = new InheritanceEvaluator();
		node.evaluate(cx, inheritanceEvaluator);
	
        for (Name name : inheritanceEvaluator.getInheritance())
        {
            unit.inheritance.add(name);
        }
	
		TypeTable typeTable = (TypeTable) symbolTable.getContext().getAttribute(AttrTypeTable);

        if (typeTable == null)
        {
            typeTable = new TypeTable(symbolTable);
            symbolTable.getContext().setAttribute(AttrTypeTable, typeTable);
        }

		for (int i = 0, length = compilerExtensions.size(); i < length; i++)
		{
			compilerExtensions.get(i).parse1(unit, typeTable);

			if (ThreadLocalToolkit.errorCount() > 0)
			{
				return null;
			}
		}

        if (benchmarkHelper != null)
        {
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.PARSE1);
        }

		return unit;
	}

	public void parse2(CompilationUnit unit, SymbolTable symbolTable)
	{
        if (benchmarkHelper != null)
        {
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.PARSE2, unit.getSource().getNameForReporting());
        }
        
        if (unit.hasTypeInfo)
        {
            return;
        }

		TypeTable typeTable = (TypeTable) symbolTable.getContext().getAttribute(AttrTypeTable);

		for (int i = 0, length = compilerExtensions.size(); i < length; i++)
		{
			compilerExtensions.get(i).parse2(unit, typeTable);

			if (ThreadLocalToolkit.errorCount() > 0)
			{
				return;
			}
		}

        // Useful when comparing abstract syntax trees
        /*
        String name = unit.getSource().getName().replace('\\', '/');
        int index = name.lastIndexOf('/');
        String className;

        if (index > 0)
        {
            className = name.substring(index + 1);
        }
        else
        {
            className = name;
        }
        
        flash.swf.tools.SyntaxTreeDumper.dump((ProgramNode) unit.getSyntaxTree(), "C:/tmp/" + className + ".xml");
        */

        if (benchmarkHelper != null)
        {
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.PARSE2);
        }
	}

	public void analyze1(CompilationUnit unit, SymbolTable symbolTable)
	{
        if (benchmarkHelper != null)
        {
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.ANALYZE1, unit.getSource().getNameForReporting());
        }
        
        if (unit.hasTypeInfo)
        {
            return;
        }

        TypeTable typeTable = (TypeTable) symbolTable.getContext().getAttribute(AttrTypeTable);

		ProgramNode node = (ProgramNode) unit.getSyntaxTree();
		if (node.state != ProgramNode.Inheritance)
		{
			return;
		}

		CompilerContext context = unit.getContext();
		Context cx = context.getAscContext();
		symbolTable.perCompileData.handler = cx.getHandler();

		ObjectValue global = new ObjectValue(cx, new GlobalBuilder(), null);
		cx.pushScope(global); // first scope is always considered the global scope.

		// run FlowAnalyzer
		FlowGraphEmitter flowem = new FlowGraphEmitter(cx, unit.getSource().getName(), false);
		FlowAnalyzer flower = new FlowAnalyzer(flowem);
		context.setAttribute("FlowAnalyzer", flower);

		// 1. ProgramNode.state == Inheritance
		node.evaluate(cx, flower);
		cx.popScope();

		if (ThreadLocalToolkit.errorCount() > 0)
		{
			return;
		}

        // We don't use fa_unresolved, because unit.inheritance is
        // filled in by InheritanceEvaluator, so just clear it out.
        node.fa_unresolved.clear();
		transferDependencies(node.ns_unresolved, unit.namespaces, unit.namespaceHistory);

		// transferDefinitions2(unit.topLevelDefinitions, context);

		unit.typeInfo = node.frame;

        for (int i = 0, length = compilerExtensions.size(); i < length; i++)
		{
			compilerExtensions.get(i).analyze1(unit, typeTable);

			if (ThreadLocalToolkit.errorCount() > 0)
			{
				return;
			}
        }
        
        if (benchmarkHelper != null)
        {
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.ANALYZE1);
        }
	}
	
	public void analyze2(CompilationUnit unit, SymbolTable symbolTable)
	{
        if (benchmarkHelper != null)
        {
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.ANALYZE2, unit.getSource().getNameForReporting());
        }

        if (unit.hasTypeInfo)
        {
            return;
        }

		TypeTable typeTable = (TypeTable) symbolTable.getContext().getAttribute(AttrTypeTable);

		ProgramNode node = (ProgramNode) unit.getSyntaxTree();
		if (node.state != ProgramNode.Else)
		{
			return;
		}

		CompilerContext context = unit.getContext();
		Context cx = context.getAscContext();
		symbolTable.perCompileData.handler = cx.getHandler();

		FlowAnalyzer flower = (FlowAnalyzer) context.getAttribute("FlowAnalyzer");
		context.setAttribute("processed", new HashSet(15));

		inheritSlots(unit, unit.inheritance, symbolTable);
		inheritSlots(unit, unit.namespaces, symbolTable);

		cx.pushScope(node.frame);
		// 2. ProgramNode.state == Else
		node.evaluate(cx, flower);
		cx.popScope();

		if (ThreadLocalToolkit.errorCount() > 0)
		{
			return;
		}

		transferDependencies(node.ce_unresolved, unit.types, unit.typeHistory);
		transferDependencies(node.body_unresolved, unit.types, unit.typeHistory);
		transferDependencies(node.ns_unresolved, unit.namespaces, unit.namespaceHistory);
	    transferDependencies(node.rt_unresolved, unit.expressions, unit.expressionHistory);

		// only verify import statements when strict is turned on.
		if (as3Configuration.strict())
		{
			transferImportPackages(node.package_unresolved, unit.importPackageStatements);
			transferImportDefinitions(node.import_def_unresolved, unit.importDefinitionStatements);
		}

		for (int i = 0, length = compilerExtensions.size(); i < length; i++)
		{
			compilerExtensions.get(i).analyze2(unit, typeTable);

			if (ThreadLocalToolkit.errorCount() > 0)
			{
				return;
			}
		}

        if (benchmarkHelper != null)
        {
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.ANALYZE2);
        }
    }

	public void analyze3(CompilationUnit unit, SymbolTable symbolTable)
	{
        if (benchmarkHelper != null)
        {
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.ANALYZE3, unit.getSource().getNameForReporting());
        }
        
        if (unit.hasTypeInfo)
        {
            return;
        }

		ProgramNode node = (ProgramNode) unit.getSyntaxTree();
		if (node.state == ProgramNode.Inheritance || node.state == ProgramNode.Else)
		{
			return;
		}

		CompilerContext context = unit.getContext();
		Context cx = context.getAscContext();
		symbolTable.perCompileData.handler = cx.getHandler();

		inheritSlots(unit, unit.types, symbolTable);
		inheritSlots(unit, unit.namespaces, symbolTable);

		// C: If --coach is turned on, do inheritSlots for unit.expressions here...
        if (as3Configuration.strict() || as3Configuration.warnings())
        {
		    inheritSlots(unit, unit.expressions, symbolTable);
        }

		if (as3Configuration.strict())
		{
			verifyImportPackages(unit.importPackageStatements, context);
			verifyImportDefinitions(unit.importDefinitionStatements, context);
		}

		if (true /*configuration.metadataExport()*/ && ! unit.getSource().isInternal())
        {
            cx.pushScope(node.frame);
	        // C: for SWC generation, use debug(). this makes MetaDataEvaluator generate go-to-definition metadata.
	        //    it's okay because compc doesn't use PostLink
	        //    for debug-mode movies, MetaDataEvaluator will generate go-to-definition metadata.
	        //    But PostLink will take them out.
            macromedia.asc.parser.MetaDataEvaluator printer =
                new macromedia.asc.parser.MetaDataEvaluator(as3Configuration.debug(), !as3Configuration.optimize());
            node.evaluate(cx,printer);

	        if (as3Configuration.doc() && unit.getSource().isDebuggable())
	        {
		        StringBuilder out = new StringBuilder();
		        out.append("<asdoc>").append("\n");

		        ObjectList comments = printer.doccomments;
		        int numComments = comments.size();
		        for(int x = 0; x < numComments; x++)
		        {
			        ((DocCommentNode) comments.get(x)).emit(cx,out);
		        }
		        out.append("\n").append("</asdoc>").append("\n");
	        }

	        cx.popScope();
        }

        if (ThreadLocalToolkit.errorCount() > 0)
        {
            return;
        }

        // run ConstantEvaluator
		cx.pushScope(node.frame);
		ConstantEvaluator analyzer = new ConstantEvaluator(cx);
		context.setAttribute("ConstantEvaluator", analyzer);
		analyzer.PreprocessDefinitionTypeInfo(cx, node);
		cx.popScope();

		if (ThreadLocalToolkit.errorCount() > 0)
		{
		    return;
		}

		TypeTable typeTable = (TypeTable) symbolTable.getContext().getAttribute(AttrTypeTable);

		for (int i = 0, length = compilerExtensions.size(); i < length; i++)
		{
			compilerExtensions.get(i).analyze3(unit, typeTable);

			if (ThreadLocalToolkit.errorCount() > 0)
			{
				return;
			}
		}
        
        if (benchmarkHelper != null)
        {
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.ANALYZE3);
        }
	}

	public void analyze4(CompilationUnit unit, SymbolTable symbolTable)
	{
        if (benchmarkHelper != null)
        {
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.ANALYZE4, unit.getSource().getNameForReporting());
        }
        
		TypeTable typeTable = null;

		if (symbolTable != null)
		{
			typeTable = (TypeTable) symbolTable.getContext().getAttribute(AttrTypeTable);
			if (typeTable == null)
			{
				typeTable = new TypeTable(symbolTable);
				symbolTable.getContext().setAttribute(AttrTypeTable, typeTable);
			}
		}

        if (unit.hasTypeInfo)
        {
            for (Map.Entry<String, AbcClass> entry : unit.classTable.entrySet())
            {
                AbcClass c = entry.getValue();
                c.setTypeTable(typeTable);
                symbolTable.registerClass(entry.getKey(), c);
            }

            try
            {
                symbolTable.registerStyles(unit.styles);
            }
            catch (StyleConflictException e)
            {
                // C: assume that StyleConflictException is going to be internationalized...
                ThreadLocalToolkit.logError(unit.getSource().getNameForReporting(), e.getLocalizedMessage());
            }

            evaluateLoaderClassBase(unit, typeTable);
            return;
        }

        ProgramNode node = (ProgramNode) unit.getSyntaxTree();
        if (node.state == ProgramNode.Inheritance || node.state == ProgramNode.Else)
        {
            return;
        }

        CompilerContext context = unit.getContext();
        Context cx = context.getAscContext();
        symbolTable.perCompileData.handler = cx.getHandler();

        // run ConstantEvaluator
        cx.pushScope(node.frame);
        ConstantEvaluator analyzer = (ConstantEvaluator) context.removeAttribute("ConstantEvaluator");
		node.evaluate(cx, analyzer);
		cx.popScope();

		if (ThreadLocalToolkit.errorCount() > 0)
		{
			return;
		}

		// run -strict and -coach
		if (as3Configuration.warnings())
		{
			cx.pushScope(node.frame);

			LintEvaluator lint = new LintEvaluator(cx, unit.getSource().getName(), warnMap);
			node.evaluate(cx, lint);
			cx.popScope();
            lint.simpleLogWarnings(cx, coachWarningsAsErrors);
            // if we want to go back to the verbose style of warnings, uncomment the line below and
            // comment out the line above
            //lint.logWarnings(context.cx);

			lint.clear();
		}

		if (ThreadLocalToolkit.errorCount() > 0)
		{
			return;
		}

		// last step: collect class definitions, add them to the symbol table and the CompilationUnit
        Map classMap = typeTable.createClasses(node.clsdefs, unit.topLevelDefinitions);
        for (Iterator i = classMap.keySet().iterator(); i.hasNext();)
        {
            String className = (String) i.next();
            AbcClass c = (AbcClass) classMap.get(className);
            symbolTable.registerClass(className, c);
            unit.classTable.put(className, c);
        }

        try
        {
            symbolTable.registerStyles(unit.styles);
        }
        catch (StyleConflictException e)
        {
            // C: assume that StyleConflictException is going to be internationalized...
            ThreadLocalToolkit.logError(unit.getSource().getNameForReporting(), e.getLocalizedMessage());
        }

        evaluateLoaderClassBase(unit, typeTable);

		for (int i = 0, length = compilerExtensions.size(); i < length; i++)
		{
			compilerExtensions.get(i).analyze4(unit, typeTable);

			if (ThreadLocalToolkit.errorCount() > 0)
			{
				return;
			}
		}

        if (benchmarkHelper != null)
        {
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.ANALYZE4);
        }
    }


	public void generate(CompilationUnit unit, SymbolTable symbolTable)
	{
        if (benchmarkHelper != null)
        {
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.GENERATE, unit.getSource().getNameForReporting());
        }
        
        if (unit.hasTypeInfo)
        {
            return;
        }

		TypeTable typeTable = (TypeTable) symbolTable.getContext().getAttribute(AttrTypeTable);

		CompilerContext context = unit.getContext();
		Context cx = context.getAscContext();
		symbolTable.perCompileData.handler = cx.getHandler();

		ProgramNode node = (ProgramNode) unit.getSyntaxTree();

		LineNumberMap map = (LineNumberMap) context.getAttribute("LineNumberMap");

		Emitter emitter = new BytecodeEmitter(cx, unit.getSource(),
                                              as3Configuration.debug() || as3Configuration.verboseStacktraces(),
                                              !as3Configuration.optimize(),
                                              as3Configuration.keepEmbedMetadata(),
		                                      as3Configuration.adjustOpDebugLine() ? map : null);

		cx.pushScope(node.frame);
		CodeGenerator generator = new CodeGenerator(emitter);
		if (RuntimeConstants.SWF)
		{
			generator.push_args_right_to_left(true);
		}
		node.evaluate(cx, generator);
		cx.popScope();

		if (ThreadLocalToolkit.errorCount() > 0)
		{
			return;
		}

		emitter.emit(unit.bytes);

		for (int i = 0, length = compilerExtensions.size(); i < length; i++)
		{
			compilerExtensions.get(i).generate(unit, typeTable);

			if (ThreadLocalToolkit.errorCount() > 0)
			{
				return;
			}
		}

		cleanSlots(unit.typeInfo, cx, unit.topLevelDefinitions);
		unit.getContext().removeAscContext();
		cx.setHandler(null);
        
        if (benchmarkHelper != null)
        {
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.GENERATE);
        }
	}

	public static void cleanSlots(ObjectValue ov, Context cx, QNameList definitions)
	{
        if (ov != null)
        {
            // clear this map because it points to AST nodes.
            ov.getDeferredClassMap().clear();
            
            // clean slots in the ObjectValue
            final Slots ovSlots = ov.slots;
            if (ovSlots != null)
            {
                for (int i = 0, length = ovSlots.size(); i < length; i++)
                {
                    final Slot slot = ovSlots.get(i);
                    
                    // the following block should be relatively in sync with ContextStatics.cleanSlot()
                    if (slot != null)
                    {
                        slot.setImplNode(null);
                    }
                }
            }
        }

        // for each QName definition, clean each slot in TypeValue slot and its prototype
        if (cx != null && definitions != null)
        {
    		for (int i = 0, size = definitions.size(); i < size; i++)
    		{
    			final TypeValue value = cx.userDefined((definitions.get(i)).toString());
    			if (value != null)
    			{
                    final Slots valueSlots = value.slots;
                    if (valueSlots != null)
                    {
                        for (int j = 0, length = valueSlots.size(); j < length; j++)
                        {
                            ContextStatics.cleanSlot(valueSlots.get(j));
                        }
                    }
                    
                    final ObjectValue proto = value.prototype;
                    if (proto != null)
                    {
                        final Slots protoSlots = proto.slots;
                        if (protoSlots != null)
                        {
                            for (int j = 0, length = protoSlots.size(); j < length; j++)
                            {
                                ContextStatics.cleanSlot(protoSlots.get(j));
                            }
                        }
                    }
    			}
            }
		}
	}

	public static void cleanNodeFactory(NodeFactory nodeFactory)
	{
		nodeFactory.pkg_defs.clear();
		nodeFactory.pkg_names.clear();
		nodeFactory.compound_names.clear();
		nodeFactory.current_package = null;
		nodeFactory.dxns = null;
		nodeFactory.use_stmts = null;
	}

	public void postprocess(CompilationUnit unit, SymbolTable symbolTable)
	{
        // This method is never called, because generate() always produces bytecode, which
        // causes CompilerAPI.postprocess() to skip calling the flex2.compiler.mxml.MxmlCompiler
        // postprocess() method.
	}

	private boolean isNotPrivate(AttributeListNode attrs)
	{
        for (int i = 0, size = attrs == null ? 0 : attrs.items.size(); i < size; i++)
        {
            Node n = attrs.items.get(i);
            if (n != null && n.hasAttribute("private"))
            {
            	return false;
            }
        }
        
        return true;
	}
	
	private String getPackageDefinition(PackageDefinitionNode pkgdef)
	{
		StringBuilder packageName = new StringBuilder();
		
		if (pkgdef != null)
		{
			List list = pkgdef.name.id.list;
			for (int i = 0, size = list == null ? 0 : list.size(); i < size; i++)
			{
				IdentifierNode node = (IdentifierNode) list.get(i);
				packageName.append(node.name);
				if (i < size - 1)
				{
					packageName.append(".");
				}
			}
		}
		
		return packageName.toString();
	}
	
	private QName getClassDefinition(ClassDefinitionNode def)
	{
		return new QName(getPackageDefinition(def.pkgdef), def.name.name);
	}

	private QName getNamespaceDefinition(NamespaceDefinitionNode def)
	{
		return new QName(getPackageDefinition(def.pkgdef), def.name.name);
	}

	private QName getFunctionDefinition(FunctionDefinitionNode def)
	{
		return new QName(getPackageDefinition(def.pkgdef), def.name.identifier.name);
	}

	private QName getVariableBinding(PackageDefinitionNode pkgdef, VariableBindingNode def)
	{
		return new QName(getPackageDefinition(pkgdef), def.variable.identifier.name);
	}

	private void transferDefinitions(Collection<QName> topLevelDefinitions, List<Node> definitions)
	{
		for (int i = 0, size = definitions.size(); i < size; i++)
		{
			Node n = definitions.get(i);
			if (n instanceof ClassDefinitionNode)
			{
				ClassDefinitionNode def = (ClassDefinitionNode) n;
				if (isNotPrivate(def.attrs))
				{
					topLevelDefinitions.add(getClassDefinition(def));
				}
			}
			else if (n instanceof NamespaceDefinitionNode)
			{
				NamespaceDefinitionNode def = (NamespaceDefinitionNode) n;
                
                // CNDNs are for conditional compilation, and only on the syntax tree for
                // ASC error handling -- they are effectively hidden to us
				if (isNotPrivate(def.attrs) && !(n instanceof ConfigNamespaceDefinitionNode))
				{
					topLevelDefinitions.add(getNamespaceDefinition(def));
				}
			}
			else if (n instanceof FunctionDefinitionNode)
			{
				FunctionDefinitionNode def = (FunctionDefinitionNode) n;
				if (isNotPrivate(def.attrs))
				{
					topLevelDefinitions.add(getFunctionDefinition(def));
				}
			}
			else if (n instanceof VariableDefinitionNode)
			{
				VariableDefinitionNode def = (VariableDefinitionNode) n;
				if (isNotPrivate(def.attrs))
				{
					for (int j = 0, length = def.list == null ? 0 : def.list.size(); j < length; j++)
					{
						VariableBindingNode binding = (VariableBindingNode) def.list.items.get(j);
						topLevelDefinitions.add(getVariableBinding(def.pkgdef, binding));
					}
				}
			}
		}		
	}

//	private void transferDefinitions2(Collection topLevelDefinitions, CompilerContext context)
//	{
//		List definitions = (List) context.removeAttribute("definitions");
//		for (int i = 0, size = definitions.size(); i < size; i++)
//		{
//			Node n = (Node) definitions.get(i);
//			if (n instanceof ClassDefinitionNode)
//			{
//				ClassDefinitionNode def = (ClassDefinitionNode) n;
//				if (def.attrs == null || !def.attrs.hasPrivate)
//				{
//					macromedia.asc.semantics.QName qName = def.cframe.builder.classname;
//					topLevelDefinitions.add(new flex2.compiler.util.QName(qName.ns.name, qName.name));
//				}
//			}
//			else if (n instanceof NamespaceDefinitionNode)
//			{
//				NamespaceDefinitionNode def = (NamespaceDefinitionNode) n;
//				if ((def.attrs == null || !def.attrs.hasPrivate) && !(n instanceof ConfigNamespaceDefinitionNode))
//				{
//					macromedia.asc.semantics.QName qName = def.qualifiedname;
//					topLevelDefinitions.add(new flex2.compiler.util.QName(qName.ns.name, qName.name));
//				}
//			}
//			else if (n instanceof FunctionDefinitionNode)
//			{
//				FunctionDefinitionNode def = (FunctionDefinitionNode) n;
//				if (def.attrs == null || !def.attrs.hasPrivate)
//				{
//					ReferenceValue ref = def.ref;
//					String ns = ref.namespaces.size() == 0 ? "" : ((ObjectValue) ref.namespaces.get(0)).name;
//					topLevelDefinitions.add(new flex2.compiler.util.QName(ns, ref.name));
//				}
//			}
//			else if (n instanceof VariableDefinitionNode)
//			{
//				VariableDefinitionNode def = (VariableDefinitionNode) n;
//				if (def.attrs == null || !def.attrs.hasPrivate)
//				{
//					for (int j = 0, length = def.list == null ? 0 : def.list.size(); j < length; j++)
//					{
//						VariableBindingNode binding = (VariableBindingNode) def.list.items.get(j);
//						ReferenceValue ref = binding.ref;
//						String ns = ref.namespaces.size() == 0 ? "" : ((ObjectValue) ref.namespaces.get(0)).name;
//						topLevelDefinitions.add(new flex2.compiler.util.QName(ns, ref.name));
//					}
//				}
//			}
//			else if (n instanceof ImportDirectiveNode || n instanceof IncludeDirectiveNode || n instanceof UseDirectiveNode)
//			{
//			}
//		}
//	}

	// C: as long as the compiler instance is not shared among multiple concurrent requests, this is okay.
	private final List<String> nsList = new ArrayList<String>();

	private void transferDependencies(Set<ReferenceValue> unresolved, Set<Name> target, MultiNameMap history)
	{
		for (ReferenceValue ref : unresolved)
		{
			nsList.clear();
			for (ObjectValue objectValue : ref.namespaces)
			{
                String ns = null;
                int nsKind = 0;

                if (objectValue instanceof UnresolvedNamespace)
                {
                    UnresolvedNamespace nsValue = (UnresolvedNamespace) objectValue;
                    if( nsValue.resolved )
                    {
                        ns = nsValue.name;
                        nsKind = nsValue.getNamespaceKind();
                    }
                    else
                    {
                        ns = nsValue.ref.name;
                        nsKind = nsValue.getNamespaceKind();
                    }
                }
                else if (objectValue instanceof NamespaceValue)
                {
                    NamespaceValue nsValue = (NamespaceValue) objectValue;
                    ns = nsValue.name;
                    nsKind = nsValue.getNamespaceKind();
                }

                if (ns != null)
                {
                    // C: skip NS_PRIVATE, NS_PROTECTED and NS_STATICPROTECTED. The inheritance relationships should
                    //    take care of PROTECTED...
                    if ((nsKind == Context.NS_PUBLIC || nsKind == Context.NS_INTERNAL) && !nsList.contains(ns))
                    {
                        nsList.add(ns);
                    }
                }
			}
			String[] namespaceURI = new String[nsList.size()];
			nsList.toArray(namespaceURI);

            // Valid references shouldn't have a dot in them, but
            // sometimes ASC creates them.  Filter them out here.
            if ((ref.name.indexOf(".") < 0) && !history.containsKey(namespaceURI, ref.name))
			{
				target.add(new MultiName(namespaceURI, ref.name));
			}
		}

		unresolved.clear();
	}

	private void transferImportPackages(Set<ReferenceValue> unresolved, Set<String> target)
	{
		for (ReferenceValue ref : unresolved)
		{
			target.add(ref.name);
		}

		unresolved.clear();
	}

	private void transferImportDefinitions(Set<ReferenceValue> unresolved, QNameSet target)
	{
		for (ReferenceValue ref : unresolved)
		{
			for (ObjectValue objectValue : ref.namespaces)
			{
                if (objectValue instanceof NamespaceValue)
                {
                    NamespaceValue nsValue = (NamespaceValue) objectValue;
                    String ns = nsValue.name;
                    int nsKind = nsValue.getNamespaceKind();
                    // C: skip NS_PRIVATE, NS_PROTECTED and NS_STATICPROTECTED. The inheritance relationships should
                    //    take care of PROTECTED...
                    if (nsKind == Context.NS_PUBLIC || nsKind == Context.NS_INTERNAL)
                    {
                        target.add(ns, ref.name);
                    }

                    break;
                }
            }
		}

		unresolved.clear();
	}

	private void verifyImportPackages(Set<String> imports, CompilerContext context)
	{
		Context cx = context.getAscContext();

		for (String importName : imports)
		{
			ObjectValue ns = cx.getNamespace(importName);
			if (ns != null)
			{
				ns.setPackage(true);
			}
		}
	}

	private void verifyImportDefinitions(QNameSet imports, CompilerContext context)
	{
		Context cx = context.getAscContext();

		// imports contains only definitions that are available... it doesn't mean that they are linked in.
		for (Iterator i = imports.iterator(); i.hasNext(); )
		{
			QName qName = (QName) i.next();
			// verify import statements
			cx.addValidImport(qName.toString());
		}
	}

    private void inheritSlots(CompilationUnit unit, Set<Name> types, SymbolTable symbolTable)
	{
		CompilerContext context = unit.getContext();
		ProgramNode node = (ProgramNode) unit.getSyntaxTree();
		Context cx = context.getAscContext();
        
		@SuppressWarnings("unchecked")
		Set<String> processed = (Set<String>) context.getAttribute("processed");

		for (Name name : types)
		{
			if (name instanceof flex2.compiler.util.QName)
			{
				flex2.compiler.util.QName qName = (flex2.compiler.util.QName) name;

				Source s = symbolTable.findSourceByQName(qName);
				CompilationUnit u = s.getCompilationUnit();				
				if (unit == u)
				{
					continue;
				}
				
				ObjectValue frame = u.typeInfo;

				if (frame != null && !processed.contains(s.getName()))
				{
					//ThreadLocalToolkit.logDebug("import: " + s.getName() + " --> " + target);
					FlowAnalyzer.inheritContextSlots(frame, node.frame, node.frame.builder, cx);
					processed.add(s.getName());
				}
			}
		}
	}

	public static void evaluateLoaderClassBase(CompilationUnit unit, TypeTable typeTable)
	{
		for (Iterator it = unit.topLevelDefinitions.iterator(); it.hasNext();)
		{
		    QName qName = (QName) it.next();

		    AbcClass c = typeTable.getClass( qName.toString() );
		    if (c == null)
		        continue;
		    getParentLoader(unit, typeTable, c);
		}
	}

	private static void getParentLoader(CompilationUnit u, TypeTable typeTable, AbcClass c)
	{
        String superTypeName = c.getSuperTypeName();

        if (superTypeName != null)
        {
            AbcClass sc = typeTable.getClass( NameFormatter.toColon(superTypeName) );

            if (sc != null)
            {
                List inherited = sc.getMetaData( "Frame", true );
                String inheritedLoaderClass = null;

                for (Iterator it = inherited.iterator(); it.hasNext();)
                {
                    MetaData md = (MetaData) it.next();

                    String lc = md.getValue( "factoryClass" );
                    if (lc != null)
                    {
                        inheritedLoaderClass = NodeMagic.normalizeClassName( lc );
                        break;
                    }
                }

                u.loaderClassBase = inheritedLoaderClass;
            }
        }
	}

	private void processCoachSettings()
	{
		if (warnMap == null)
		{
			warnMap = LintEvaluator.getWarningDefaults();

			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_ArrayToStringChanges), as3Configuration.warn_array_tostring_changes());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_AssignmentWithinConditional), as3Configuration.warn_assignment_within_conditional());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_BadArrayCast), as3Configuration.warn_bad_array_cast());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_BadBoolAssignment), as3Configuration.warn_bad_bool_assignment());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_BadDateCast), as3Configuration.warn_bad_date_cast());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_BadES3TypeMethod), as3Configuration.warn_bad_es3_type_method());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_BadES3TypeProp), as3Configuration.warn_bad_es3_type_prop());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_BadNaNComparision), as3Configuration.warn_bad_nan_comparison());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_BadNullAssignment), as3Configuration.warn_bad_null_assignment());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_BadNullComparision), as3Configuration.warn_bad_null_comparison());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_BadUndefinedComparision), as3Configuration.warn_bad_undefined_comparison());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_BooleanConstructorWithNoArgs), as3Configuration.warn_boolean_constructor_with_no_args());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_ChangesInResolve), as3Configuration.warn_changes_in_resolve());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_ClassIsSealed), as3Configuration.warn_class_is_sealed());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_ConstNotInitialized), as3Configuration.warn_const_not_initialized());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_ConstructorReturnsValue), as3Configuration.warn_constructor_returns_value());

            boolean showDeprecationWarnings = as3Configuration.showDeprecationWarnings();
            warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_Deprecated), showDeprecationWarnings);
            warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_DeprecatedMessage), showDeprecationWarnings);
            warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_DeprecatedUseReplacement), showDeprecationWarnings);
            warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_DeprecatedSince), showDeprecationWarnings);
            warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_DeprecatedSinceNoReplacement), showDeprecationWarnings);
            warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_DepricatedEventHandlerError), showDeprecationWarnings && as3Configuration.warn_deprecated_event_handler_error());
            warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_DepricatedFunctionError), showDeprecationWarnings && as3Configuration.warn_deprecated_function_error());
            warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_DepricatedPropertyError), showDeprecationWarnings && as3Configuration.warn_deprecated_property_error());

			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_DuplicateArgumentNames), as3Configuration.warn_duplicate_argument_names());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_DuplicateVariableDef), as3Configuration.warn_duplicate_variable_def());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_ForVarInChanges), as3Configuration.warn_for_var_in_changes());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_ImportHidesClass), as3Configuration.warn_import_hides_class());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_InstanceOfChanges), as3Configuration.warn_instance_of_changes());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_InternalError), as3Configuration.warn_internal_error());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_LevelNotSupported), as3Configuration.warn_level_not_supported());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_MissingNamespaceDecl), as3Configuration.warn_missing_namespace_decl());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_NegativeUintLiteral), as3Configuration.warn_negative_uint_literal());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_NoConstructor), as3Configuration.warn_no_constructor());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_NoExplicitSuperCallInConstructor), as3Configuration.warn_no_explicit_super_call_in_constructor());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_NoTypeDecl), as3Configuration.warn_no_type_decl());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_NumberFromStringChanges), as3Configuration.warn_number_from_string_changes());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_ScopingChangeInThis), as3Configuration.warn_scoping_change_in_this());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_SlowTextFieldAddition), as3Configuration.warn_slow_text_field_addition());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_UnlikelyFunctionValue), as3Configuration.warn_unlikely_function_value());
			warnMap.put(IntegerPool.getNumber(WarningConstants.kWarning_XML_ClassHasChanged), as3Configuration.warn_xml_class_has_changed());
		}
	}
}
