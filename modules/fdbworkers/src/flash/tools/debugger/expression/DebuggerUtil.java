/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package flash.tools.debugger.expression;

import java.io.StringReader;
import java.util.EnumSet;
import java.util.List;

import com.adobe.flash.compiler.common.SourceLocation;
import com.adobe.flash.compiler.internal.parsing.as.FrontEnd;
import com.adobe.flash.compiler.internal.scopes.ASFileScope;
import com.adobe.flash.compiler.internal.semantics.PostProcessStep;
import com.adobe.flash.compiler.internal.tree.as.NodeBase;
import com.adobe.flash.compiler.internal.tree.as.ScopedBlockNode;
import com.adobe.flash.compiler.internal.workspaces.Workspace;
import com.adobe.flash.compiler.problems.ICompilerProblem;
import com.adobe.flash.compiler.projects.ASDialect;
import com.adobe.flash.compiler.tree.as.IASNode;
import com.adobe.flash.compiler.workspaces.IWorkspace;

/**
 * 
 * @author ggv
 */
public class DebuggerUtil
{

    /**
     * 
     * @param code
     * @param problems
     * @return
     */
    public static IASNode parseExpression(String code, List<ICompilerProblem> problems)
    {
    	        IWorkspace workspace = new Workspace();
        IASNode exprAST = FrontEnd.parseExpression(ASDialect.AS30, workspace, new StringReader(code), problems, null, new SourceLocation("", -1, -1, -1, -1));

        // Have to create a fake ScopedBlockNode so the expression can do things
        // like resolve, which means it has to be able to find a scope.
        // For parsing an expression in a file, one would hook up the expression
        // AST to whatever the real scope was.
        ScopedBlockNode scopedNode = new ScopedBlockNode();
        scopedNode.addChild((NodeBase)exprAST);
        scopedNode.setScope(new ASFileScope(workspace, "fake", ASDialect.AS30));
        scopedNode.runPostProcess(EnumSet.of(PostProcessStep.CALCULATE_OFFSETS));

        return exprAST;
    }

  

}
