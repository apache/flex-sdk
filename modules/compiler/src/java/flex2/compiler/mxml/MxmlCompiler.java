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

package flex2.compiler.mxml;

import flash.util.FileUtils;
import flex2.compiler.AbstractSubCompiler;
import flex2.compiler.CompilationUnit;
import flex2.compiler.CompilerBenchmarkHelper;
import flex2.compiler.Source;
import flex2.compiler.SymbolTable;
import flex2.compiler.Transcoder;
import flex2.compiler.abc.AbcClass;
import flex2.compiler.as3.As3Configuration;
import flex2.compiler.as3.As3Compiler;
import flex2.compiler.as3.Extension;
import flex2.compiler.as3.reflect.TypeTable;
import flex2.compiler.css.StyleConflictException;
import flex2.compiler.util.NameMappings;
import flex2.compiler.util.ThreadLocalToolkit;

import java.io.File;
import java.util.Iterator;
import java.util.Map;

/**
 * Wrapper for mxml interface and implementation compilers. The logic
 * here relies on the flex2.compiler.CompilerAPI workflow, in which
 * CompilationUnits that don't produce bytecode are "reset".  Here, we
 * use the reset to transition from interface to implementation
 * compilation.
 */
public class MxmlCompiler extends AbstractSubCompiler
{
	//	ATTR_STATE is used to indicate progress through double-pass compilation process.
	private static final String ATTR_STATE = "MxmlState";
    private static final String COMPILER_NAME = "mxml";

	//	values of ATTR_STATE - see later in class def for state mgmt logic
	private static final int
			STATE_INTERFACE_PARSED = 0,
			STATE_INTERFACE_GENERATED = 1,
			STATE_IMPLEMENTATION_PARSED = 2,
			STATE_IMPLEMENTATION_GENERATED = 3;

	//	MXML document state
	static final String DOCUMENT_INFO = "DocumentInfo";
	//	type table wrapper around symbol table, held to avoid
	//	recreation overhead.
	public static final String TYPE_TABLE = flex2.compiler.mxml.reflect.TypeTable.class.getName();
	//	line number map - maps regions of generated code back to original MXML. TODO fold into document info
	static final String LINE_NUMBER_MAP = "LineNumberMap";
	//	each subcompiler uses a delegate compilation unit for generated code
	static final String DELEGATE_UNIT = "DelegateUnit";
	//	context attribute used to maintain state during InterfaceCompiler.postprocess(). Checked in ImplementationCompiler.parse(), see comments there.
	static final String CHECK_NODES = "CheckNodes";
	
	//	subcompilers
	private InterfaceCompiler intfc;
	private ImplementationCompiler implc;

	public MxmlCompiler(MxmlConfiguration mxmlConfiguration,
					As3Configuration ascConfiguration,
					NameMappings mappings, Transcoder[] transcoders)
	{
		this(mxmlConfiguration, ascConfiguration, mappings, transcoders, false);
	}
	
	/**
	 * Overloaded constructor for mxml compiler. 
	 * This takes an extra parameter (processComments) - It is only set to true by asdoc tool
	 *  
	 * @param mxmlConfiguration
	 * @param ascConfiguration
	 * @param mappings
	 * @param transcoders
	 * @param processComments
	 */
    public MxmlCompiler(MxmlConfiguration mxmlConfiguration,
            As3Configuration ascConfiguration,
            NameMappings mappings, Transcoder[] transcoders, boolean processComments)
    {
        intfc = new InterfaceCompiler(mxmlConfiguration, ascConfiguration, mappings, processComments);
        implc = new ImplementationCompiler(mxmlConfiguration, ascConfiguration, mappings, transcoders, processComments);
    }	

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
	    return implc.isSupported(mimeType);
	}

	public String[] getSupportedMimeTypes()
	{
	    return implc.getSupportedMimeTypes();
	}

	public void addInterfaceCompilerExtension(Extension ext)
	{
		intfc.getASCompiler().addCompilerExtension(ext);
	}

	public void addImplementationCompilerExtension(Extension ext)
	{
		implc.getASCompiler().addCompilerExtension(ext);
	}

	public Source preprocess(Source source)
	{
        if (benchmarkHelper != null)
        {
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.PREPROCESS, source.getNameForReporting());
        }
        
        Source result = null;
        
		if (source.getCompilationUnit() == null)
			result = intfc.preprocess(source);
		else
			result = implc.preprocess(source);
        
        if (benchmarkHelper != null)
        {
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.PREPROCESS);
        }
        
        return result;
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

		if (unit == null)
		{
			//	first time through: begin the InterfaceCompiler pass
			unit = intfc.parse1(source, symbolTable);
			if (unit != null)
			{
				setState(unit, STATE_INTERFACE_PARSED);
			}
		}
		else
		{
			//	We're here (in parse() with unit non-null) for one of two reasons: a) this is the bona fide start of the
			// 	second pass, in which case we invoke ImplementationCompiler.parse(); b) we're actually still at the
			// 	beginning of the first pass, but parse() has already been called on this source due to TypeAnalyzer's
			// 	eager superclass parsing. In the latter case, we need to continue the InterfaceCompiler pass.
			
			if (getState(unit) == STATE_INTERFACE_GENERATED)
			{
				unit = implc.parse1(source, symbolTable);
				if (unit != null)
				{
					advanceState(unit);
				}
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

		if (unit != null && unit.hasTypeInfo)
		{
			return;
		}

		getSubCompiler(unit).parse2(unit, symbolTable);

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

		if (unit != null && unit.hasTypeInfo)
		{
			return;
		}

		getSubCompiler(unit).analyze1(unit, symbolTable);
        
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

		if (unit != null && unit.hasTypeInfo)
		{
			return;
		}

		getSubCompiler(unit).analyze2(unit, symbolTable);
        
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

		if (unit != null && unit.hasTypeInfo)
		{
			return;
		}

		getSubCompiler(unit).analyze3(unit, symbolTable);
        
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

		if (unit != null && unit.hasTypeInfo)
		{
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

		getSubCompiler(unit).analyze4(unit, symbolTable);
        
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

		if (unit != null && unit.hasTypeInfo)
		{
			return;
		}

		getSubCompiler(unit).generate(unit, symbolTable);
		advanceState(unit);
        
        if (benchmarkHelper != null)
        {
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.GENERATE);
        }
	}

	public void postprocess(CompilationUnit unit, SymbolTable symbolTable)
	{
        if (benchmarkHelper != null)
        {
            benchmarkHelper.startPhase(CompilerBenchmarkHelper.POSTPROCESS, unit.getSource().getNameForReporting());
        }

		if (unit != null && unit.hasTypeInfo)
		{
			return;
		}

		getSubCompiler(unit).postprocess(unit, symbolTable);
        
        if (benchmarkHelper != null)
        {
            benchmarkHelper.endPhase(CompilerBenchmarkHelper.POSTPROCESS);
        }
	}

	/**
	 * state mgmt
	 */

	private int getState(CompilationUnit unit)
	{
		assert unit.getContext().getAttribute(ATTR_STATE) != null : "unit lacks " + ATTR_STATE + " attribute";
		return ((Integer)unit.getContext().getAttribute(ATTR_STATE)).intValue();
	}

	private void setState(CompilationUnit unit, int state)
	{
		unit.getContext().setAttribute(ATTR_STATE, new Integer(state));
	}

	private void advanceState(CompilationUnit unit)
	{
		int state = getState(unit);
		// System.out.println(unit.getSource().getName() + ": advancing from " + state + " to " + (state + 1));
		assert state < STATE_IMPLEMENTATION_GENERATED : "advanceState called with state == " + state;
		setState(unit, state + 1);
	}

	/**
	 * pick subcompiler based on unit state
	 */
	private flex2.compiler.SubCompiler getSubCompiler(CompilationUnit unit)
	{
		return getState(unit) < STATE_IMPLEMENTATION_PARSED ? (flex2.compiler.SubCompiler)intfc : implc;
	}

	/**
	 * utilities used by both subcompilers
	 */
	
	static String getGeneratedName(MxmlConfiguration mxmlConfiguration,
								   String packageName, String className, String suffix)
	{
		String dir = mxmlConfiguration.getGeneratedDirectory();
		if ((packageName != null) && (packageName.length() > 0))
		{
			dir = FileUtils.addPathComponents(dir, packageName.replace('.', File.separatorChar), File.separatorChar);
		}

		return FileUtils.addPathComponents(dir, className + suffix, File.separatorChar);
	}
	
	/**
	 * override of initBechmarks allows us to collect staticstics on embedded compilers
	 */
    public void initBenchmarks()
    {
    	super.initBenchmarks();		// set up the primary benchmarkers
    	benchmarkEmbeddedHelper = new CompilerBenchmarkHelper(getName());
    	benchmarkEmbeddedHelper.initBenchmarks();
        
        // now pass down the embedded helper to our sub compilers.
        // (they will in turn send it as the main helper to their embedded asc compilers)
        intfc.setHelper(benchmarkEmbeddedHelper, true);
        implc.setHelper(benchmarkEmbeddedHelper, true);
    }


}
