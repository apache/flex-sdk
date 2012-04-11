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

package flex2.compiler.as3.binding;

import flex2.compiler.SymbolTable;
import flex2.compiler.as3.genext.GenerativeClassInfo;
import flex2.compiler.as3.reflect.NodeMagic;
import flex2.compiler.mxml.lang.StandardDefs;
import macromedia.asc.parser.DefinitionNode;
import macromedia.asc.util.Context;

/**
 * This value object holds the information collected during the first
 * pass and is used in the second pass to generate code.
 *
 * @author Paul Reilly
 */
public class BindableInfo extends GenerativeClassInfo
{
    private boolean needsToImplementIEventDispatcher;
    private boolean needsStaticEventDispatcher;
    private boolean requiresStaticEventDispatcher;

    public BindableInfo(Context context, SymbolTable symbolTable)
    {
        super(context, symbolTable);
    }

    public boolean needsAdditionalInterfaces()
    {
        return needsToImplementIEventDispatcher;
    }

    // Bean like methods for Velocity Template
    public boolean getNeedsToImplementIEventDispatcher()
    {
        return needsToImplementIEventDispatcher;
    }

    public boolean getNeedsStaticEventDispatcher()
    {
        return needsStaticEventDispatcher;
    }

    public boolean getRequiresStaticEventDispatcher()
    {
        return requiresStaticEventDispatcher;
    }

    public void removeOriginalMetaData(DefinitionNode definitionNode)
    {
        NodeMagic.removeMetaData(definitionNode, StandardDefs.MD_BINDABLE);
    }

    public void setNeedsToImplementIEventDispatcher(boolean needsToImplementIEventDispatcher)
    {
        this.needsToImplementIEventDispatcher = needsToImplementIEventDispatcher;
    }

    public void setNeedsStaticEventDispatcher(boolean needsStaticEventDispatcher)
    {
        this.needsStaticEventDispatcher = needsStaticEventDispatcher;
    }

    public void setRequiresStaticEventDispatcher(boolean requiresStaticEventDispatcher)
    {
        this.requiresStaticEventDispatcher = requiresStaticEventDispatcher;
    }
}
