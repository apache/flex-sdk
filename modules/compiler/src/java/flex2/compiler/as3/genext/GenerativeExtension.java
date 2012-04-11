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

package flex2.compiler.as3.genext;

import flex2.compiler.as3.Extension;
import flex2.compiler.as3.binding.ClassInfo;
import flex2.compiler.as3.binding.TypeAnalyzer;
import flex2.compiler.as3.reflect.TypeTable;
import flex2.compiler.CompilationUnit;
import java.util.Iterator;
import java.util.Map.Entry;
import macromedia.asc.parser.Evaluator;
import macromedia.asc.parser.Node;
import macromedia.asc.util.Context;

/**
 * A base class for compiler extension logic common to Bindable and
 * Managed metadata processing.
 *
 * @author Basil Hosmer
 * @author Paul Reilly
 */
public abstract class GenerativeExtension implements Extension
{
    public static final String IEVENT_DISPATCHER = "IEventDispatcher";

    protected String generatedOutputDirectory;
    protected boolean generateAbstractSyntaxTree;
    protected boolean processComments;

    /**
     *
     */
    public GenerativeExtension(String generatedOutputDirectory, boolean generateAbstractSyntaxTree, boolean processComments)
    {
        this.generatedOutputDirectory = generatedOutputDirectory;
        this.generateAbstractSyntaxTree = generateAbstractSyntaxTree;
        this.processComments = processComments;
    }

    /**
     *
     */
    protected abstract void addInheritance(CompilationUnit unit);

    /**
     *
     */
    protected abstract GenerativeFirstPassEvaluator getFirstPassEvaluator(CompilationUnit unit,
                                                                          TypeTable typeTable);

	/**
	 *
	 */
	protected abstract String getFirstPassEvaluatorKey();

    /**
     *
     */
    protected abstract Evaluator getSecondPassEvaluator(CompilationUnit unit, 
                                                        TypeAnalyzer typeAnalyzer,
                                                        GenerativeFirstPassEvaluator firstPassEvaluator);

    /**
     *
     */
    public void parse1(CompilationUnit unit, TypeTable typeTable)
    {
        Node node = (Node) unit.getSyntaxTree();
        Context cx = unit.getContext().getAscContext();
        GenerativeFirstPassEvaluator firstPassEvaluator = getFirstPassEvaluator(unit, typeTable);

        node.evaluate(cx, firstPassEvaluator);

        if ( firstPassEvaluator.makeSecondPass() )
        {
            addInheritance(unit);
        }

        unit.getContext().setAttribute(getFirstPassEvaluatorKey(), firstPassEvaluator);
    }

    public void parse2(CompilationUnit unit, TypeTable typeTable)
    {
        GenerativeFirstPassEvaluator firstPassEvaluator =
            (GenerativeFirstPassEvaluator) unit.getContext().removeAttribute(getFirstPassEvaluatorKey());

        if (firstPassEvaluator != null && firstPassEvaluator.makeSecondPass())
        {
            Node node = (Node) unit.getSyntaxTree();
            Context cx = unit.getContext().getAscContext();
            TypeAnalyzer typeAnalyzer = typeTable.getSymbolTable().getTypeAnalyzer();

            node.evaluate(cx, typeAnalyzer);

            Iterator iterator = firstPassEvaluator.getClassMap().entrySet().iterator();

            while ( iterator.hasNext() )
            {
                Entry entry = (Entry) iterator.next();
                String className = (String) entry.getKey();
                GenerativeClassInfo generativeClassInfo = (GenerativeClassInfo) entry.getValue();
                ClassInfo classInfo = typeAnalyzer.getClassInfo(className);
                generativeClassInfo.setClassInfo(classInfo);
            }

            Evaluator secondPassEvaluator = getSecondPassEvaluator(unit, typeAnalyzer, firstPassEvaluator);

            node.evaluate(cx, secondPassEvaluator);
        }
    }

    /**
     *
     */
    public void analyze1(CompilationUnit unit, TypeTable typeTable)
    {
    }

    /**
     *
     */
    public void analyze2(CompilationUnit unit, TypeTable typeTable)
    {
    }

    /**
     *
     */
    public void analyze3(CompilationUnit unit, TypeTable typeTable)
    {
    }

    /**
     *
     */
    public void analyze4(CompilationUnit unit, TypeTable typeTable)
    {
    }

    /**
     *
     */
    public void generate(CompilationUnit unit, TypeTable typeTable)
    {
    }
}
