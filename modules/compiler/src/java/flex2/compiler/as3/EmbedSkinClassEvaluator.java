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
import flex2.compiler.CompilationUnit;
import flex2.compiler.Transcoder;
import flex2.compiler.as3.reflect.MetaData;
import flex2.compiler.util.MultiName;
import flex2.compiler.util.NameFormatter;
import macromedia.asc.parser.MetaDataNode;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;

/**
 * Evaluator that is meant to be used during the parse1 phase to
 * insure that skin classes are parsed, so the EmbedEvaluator, which
 * runs in parse2 phase, can look up information about the skin class.
 *
 * @author Paul Reilly
 */
class EmbedSkinClassEvaluator extends EvaluatorAdapter
{
    private CompilationUnit unit;

    EmbedSkinClassEvaluator(CompilationUnit unit)
    {
        this.unit = unit;
    }

    public Value evaluate(Context context, MetaDataNode node)
    {
        if ("Embed".equals(node.getId()))
        {
            MetaData metaData = new MetaData(node);
            int len = metaData.count();

            for (int i = 0; i < len; i++)
            {
                String key = metaData.getKey(i);

                if ((key != null) && key.equals(Transcoder.SKINCLASS))
                {
                    String skinClass = metaData.getValue(i);
                    unit.inheritance.add(new MultiName(NameFormatter.toColon(skinClass)));
                }
            }
        }

        return null;
    }
}
