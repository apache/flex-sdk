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

import flash.swf.tools.as3.EvaluatorAdapter;
import flex2.compiler.util.CompilerMessage.CompilerError;
import macromedia.asc.parser.MetaDataNode;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;

/**
 * This class handles reporting an error for misplaced metadata.
 */
public class MetaDataEvaluator extends EvaluatorAdapter
{
	public Value evaluate(Context context, MetaDataNode metaDataNode)
	{
        if (metaDataNode.def == null)
        {
            context.localizedError2(metaDataNode.pos(), new MetaDataRequiresDefinition());
        }

        return null;
    }

    public static class MetaDataRequiresDefinition extends CompilerError
    {
        private static final long serialVersionUID = -3769488225390575289L;
    }
}
