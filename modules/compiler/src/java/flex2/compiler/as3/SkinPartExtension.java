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

import flex2.compiler.CompilationUnit;
import flex2.compiler.CompilerContext;
import flex2.compiler.as3.reflect.TypeTable;
import flex2.compiler.util.ThreadLocalToolkit;
import macromedia.asc.parser.Node;
import macromedia.asc.util.Context;

/**
 * This extension handles running the SkinPartEvaluator in the parse2
 * phase.
 *
 * @author Greg Burch
 * @see flex2.compiler.as3.SkinPartEvaluator
 */
public final class SkinPartExtension implements Extension
{
    public void parse2(CompilationUnit unit, TypeTable typeTable)
    {
        SkinPartEvaluator spEvaluator = new SkinPartEvaluator(typeTable.getSymbolTable());
        spEvaluator.setLocalizationManager(ThreadLocalToolkit.getLocalizationManager());
        Node node = (Node) unit.getSyntaxTree();
        CompilerContext context = unit.getContext();
        Context cx = (Context) context.getAscContext();
        node.evaluate(cx, spEvaluator);
    }

    public void parse1(CompilationUnit unit, TypeTable typeTable)
    {
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
    }
}
