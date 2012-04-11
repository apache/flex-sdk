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

package flex2.compiler.abc;

import flash.util.FileUtils;
import flex2.compiler.AbstractSubCompiler;
import flex2.compiler.CompilationUnit;
import flex2.compiler.CompilerBenchmarkHelper;
import flex2.compiler.CompilerContext;
import flex2.compiler.Source;
import flex2.compiler.SymbolTable;
import flex2.compiler.as3.As3Compiler;
import flex2.compiler.as3.As3Configuration;
import flex2.compiler.as3.Extension;
import flex2.compiler.as3.SyntaxTreeEvaluator;
import flex2.compiler.as3.reflect.TypeTable;
import flex2.compiler.css.StyleConflictException;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.Name;
import flex2.compiler.util.ThreadLocalToolkit;
import macromedia.abc.AbcParser;
import macromedia.asc.embedding.avmplus.GlobalBuilder;
import macromedia.asc.parser.ProgramNode;
import macromedia.asc.semantics.*;
import macromedia.asc.util.Context;

import java.io.IOException;
import java.util.*;

/**
 * This subcompiler is used to process ABC (Actionscript Byte Code)
 * blocks and to extract type information.
 *
 * @author Clement Wong
 */
public class AbcCompiler extends AbstractSubCompiler implements flex2.compiler.SubCompiler
{
	static
	{
		TypeValue.init();
		ObjectValue.init();
	}

	private static final String COMPILER_NAME = "abc";

	public AbcCompiler(As3Configuration as3Configuration)
	{
		mimeTypes = new String[]{MimeMappings.ABC};
		compilerExtensions = new ArrayList<Extension>();
	}

	private String[] mimeTypes;
	private List<Extension> compilerExtensions;

    /**
     * The name of this compiler as a simple String identifier.
     * 
     * @return This SubCompiler's name. 
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
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.PARSE1, source.getNameForReporting());

		CompilationUnit unit = source.getCompilationUnit();

		if (unit != null && unit.hasTypeInfo)
		{
            if (unit.bytes.isEmpty())
            {
                copyBytecodes(source, unit);
            }

			return unit;
		}

		if ((unit != null) && (unit.getSyntaxTree() != null))
		{
			return unit;
		}

		final String path = source.getName();
		ProgramNode node = null;

		CompilerContext context = new CompilerContext();

		Context cx = new Context(symbolTable.perCompileData);

		cx.setScriptName(source.getName());
		cx.setPath(source.getParent());

		cx.setEmitter(symbolTable.emitter);
		cx.setHandler(new As3Compiler.CompilerHandler()
		{
			public void error2(String filename, int ln, int col, Object msg, String source)
			{
				filename = (filename == null || filename.length() == 0) ? path : filename;
				ThreadLocalToolkit.log((flex2.compiler.util.CompilerMessage) msg, filename);
			}

			public void warning2(String filename, int ln, int col, Object msg, String source)
			{
				filename = (filename == null || filename.length() == 0) ? path : filename;
				ThreadLocalToolkit.log((CompilerMessage) msg, filename);
			}

			public void error(String filename, int ln, int col, String msg, String source, int errorCode)
			{
				filename = (filename == null || filename.length() == 0) ? path : filename;
				if (errorCode != -1)
				{
					ThreadLocalToolkit.logError(filename, msg, errorCode);
				}
				else
				{
					ThreadLocalToolkit.logError(filename, msg);
				}
			}

			public void warning(String filename, int ln, int col, String msg, String source, int errorCode)
			{
				filename = (filename == null || filename.length() == 0) ? path : filename;
				if (errorCode != -1)
				{
					ThreadLocalToolkit.logWarning(filename, msg, errorCode);
				}
				else
				{
					ThreadLocalToolkit.logWarning(filename, msg);
				}
			}

			public void error(String filename, int ln, int col, String msg, String source)
			{
				filename = (filename == null || filename.length() == 0) ? path : filename;
				ThreadLocalToolkit.logError(filename, msg);
			}

			public void warning(String filename, int ln, int col, String msg, String source)
			{
				filename = (filename == null || filename.length() == 0) ? path : filename;
				ThreadLocalToolkit.logWarning(filename, msg);
			}

			public FileInclude findFileInclude(String parentPath, String filespec)
			{
				return null;
			}
		});
		symbolTable.perCompileData.handler = cx.getHandler();

		context.setAscContext(cx);

		byte[] abc = null;
		try
		{
			abc = source.toByteArray();

			if (abc == null)
			{
				abc = FileUtils.toByteArray(source.getInputStream());
			}

			if (abc == null || abc.length == 0)
			{
				ThreadLocalToolkit.log(new NoBytecodeIsAvailable(), source);
			}
			else
			{
			    AbcParser parser = new AbcParser(cx, abc);
			    node = parser.parseAbc();

                if (node == null && ThreadLocalToolkit.errorCount() == 0)
                {
                    ThreadLocalToolkit.log(new BytecodeDecodingFailed(), source);
                }

                As3Compiler.cleanNodeFactory(cx.getNodeFactory());
			}
		}
		catch (IOException ex)
		{
			ThreadLocalToolkit.logError(source.getNameForReporting(), ex.getLocalizedMessage());
		}

		if (ThreadLocalToolkit.errorCount() > 0)
		{
			return null;
		}

        if (unit == null)
        {
            unit = source.newCompilationUnit(node, context);
        }
        else
        {
            unit.setSyntaxTree(node);
            unit.getContext().setAttributes(context);
        }

		unit.bytes.set(abc, abc.length);

		SyntaxTreeEvaluator treeEvaluator = new SyntaxTreeEvaluator(unit);
		treeEvaluator.setLocalizationManager(ThreadLocalToolkit.getLocalizationManager());
		node.evaluate(cx, treeEvaluator);

		for (int i = 0, length = compilerExtensions.size(); i < length; i++)
		{
			compilerExtensions.get(i).parse1(unit, null);

			if (ThreadLocalToolkit.errorCount() > 0)
			{
				return null;
			}
		}

        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.PARSE1);

		return unit;
	}
	
	public void parse2(CompilationUnit unit, SymbolTable symbolTable)
	{
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.PARSE2, unit.getSource().getNameForReporting());

        if (unit.hasTypeInfo)
		{
			return;
		}

		for (int i = 0, length = compilerExtensions.size(); i < length; i++)
		{
			compilerExtensions.get(i).parse2(unit, null);

			if (ThreadLocalToolkit.errorCount() > 0)
			{
				return;
			}
		}
        
        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.PARSE2);
	}

	public void analyze1(CompilationUnit unit, SymbolTable symbolTable)
	{
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.ANALYZE1, unit.getSource().getNameForReporting());
        
        if (unit.hasTypeInfo)
		{
			return;
		}

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

		unit.typeInfo = node.frame;

		for (int i = 0, length = compilerExtensions.size(); i < length; i++)
		{
			compilerExtensions.get(i).analyze1(unit, null);

			if (ThreadLocalToolkit.errorCount() > 0)
			{
				return;
			}
		}
        
        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.ANALYZE1);
	}

	public void analyze2(CompilationUnit unit, SymbolTable symbolTable)
	{
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.ANALYZE2, unit.getSource().getNameForReporting());

        if (unit.hasTypeInfo)
		{
			return;
		}

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

		for (int i = 0, length = compilerExtensions.size(); i < length; i++)
		{
			compilerExtensions.get(i).analyze2(unit, null);

			if (ThreadLocalToolkit.errorCount() > 0)
			{
				return;
			}
		}
        
        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.ANALYZE2);
	}

	public void analyze3(CompilationUnit unit, SymbolTable symbolTable)
	{
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.ANALYZE3, unit.getSource().getNameForReporting());

        if (unit.hasTypeInfo)
		{
			return;
		}

		ProgramNode node = (ProgramNode) unit.getSyntaxTree();

		CompilerContext context = unit.getContext();
		Context cx = context.getAscContext();
		symbolTable.perCompileData.handler = cx.getHandler();

		inheritSlots(unit, unit.types, symbolTable);
		inheritSlots(unit, unit.namespaces, symbolTable);

		// run ConstantEvaluator
		cx.pushScope(node.frame);
		ConstantEvaluator analyzer = new ConstantEvaluator(cx);
		analyzer.PreprocessDefinitionTypeInfo(cx, node);
		cx.popScope();
		context.setAttribute("ConstantEvaluator", analyzer);

		if (ThreadLocalToolkit.errorCount() > 0)
		{
		    return;
		}

		for (int i = 0, length = compilerExtensions.size(); i < length; i++)
		{
			compilerExtensions.get(i).analyze3(unit, null);

			if (ThreadLocalToolkit.errorCount() > 0)
			{
				return;
			}
		}
        
        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.ANALYZE3);

	}

	public void analyze4(CompilationUnit unit, SymbolTable symbolTable)
	{
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.ANALYZE4, unit.getSource().getNameForReporting());

		TypeTable typeTable = null;
		if (symbolTable != null)
		{
			typeTable = (TypeTable) symbolTable.getContext().getAttribute(As3Compiler.AttrTypeTable);
			if (typeTable == null)
			{
				typeTable = new TypeTable(symbolTable);
				symbolTable.getContext().setAttribute(As3Compiler.AttrTypeTable, typeTable);
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

			As3Compiler.evaluateLoaderClassBase(unit, typeTable);
			return;
		}

		ProgramNode node = (ProgramNode) unit.getSyntaxTree();

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

		if (symbolTable != null)
		{
			Map classMap = typeTable.createClasses(node.clsdefs, unit.topLevelDefinitions);
			for (Iterator i = classMap.keySet().iterator(); i.hasNext();)
			{
				String className = (String) i.next();
				flex2.compiler.abc.AbcClass c = (flex2.compiler.abc.AbcClass) classMap.get(className);
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

			As3Compiler.evaluateLoaderClassBase(unit, typeTable);
		}

		for (int i = 0, length = compilerExtensions.size(); i < length; i++)
		{
			compilerExtensions.get(i).analyze4(unit, typeTable);

			if (ThreadLocalToolkit.errorCount() > 0)
			{
				return;
			}
		}
        
        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.ANALYZE4);
	}

	public void generate(CompilationUnit unit, SymbolTable symbolTable)
	{
        if (benchmarkHelper != null)
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.GENERATE, unit.getSource().getNameForReporting());

		if (unit.hasTypeInfo)
		{
			return;
		}

		for (int i = 0, length = compilerExtensions.size(); i < length; i++)
		{
			compilerExtensions.get(i).generate(unit, null);

			if (ThreadLocalToolkit.errorCount() > 0)
			{
				return;
			}
		}

		Context cx = unit.getContext().removeAscContext();
		As3Compiler.cleanSlots(unit.typeInfo, cx, unit.topLevelDefinitions);
		cx.setHandler(null);

        if (benchmarkHelper != null)
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.GENERATE);
	}

	public void postprocess(CompilationUnit unit, SymbolTable symbolTable)
	{
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

	public static void copyBytecodes(Source source, CompilationUnit unit)
	{
		try
		{
			byte[] abc = source.toByteArray();

			if (abc == null)
			{
				abc = FileUtils.toByteArray(source.getInputStream());
			}

			if (abc == null || abc.length == 0)
			{
				ThreadLocalToolkit.log(new NoBytecodeIsAvailable(), source);
			}
			else
			{
			    unit.bytes.set(abc, abc.length);
			}
		}
		catch (IOException ex)
		{
			ThreadLocalToolkit.logError(source.getNameForReporting(), ex.getLocalizedMessage());
		}
	}

	// error messages

	public static class NoBytecodeIsAvailable extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = 2620612567115987550L;

        public NoBytecodeIsAvailable()
		{
			super();
		}
	}

	public static class BytecodeDecodingFailed extends CompilerMessage.CompilerError
	{
		private static final long serialVersionUID = -4085468421158774443L;

        public BytecodeDecodingFailed()
		{
			super();
		}
	}
}
