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

package macromedia.asc.parser;

import macromedia.asc.util.*;
import macromedia.asc.semantics.*;

/**
 * Node
 */
public class LabeledStatementNode extends Node
{
    public Node label;
    public Node statement;
    public int loop_index;
    public boolean is_loop_label;

    public LabeledStatementNode(Node label, boolean is_loop_label, Node statement)
    {
        this.label = label;
        this.statement = statement;
        this.loop_index = 0;
        this.is_loop_label = is_loop_label;
    }

    public Value evaluate(Context cx, Evaluator evaluator)
    {
        if (evaluator.checkFeature(cx, this))
        {
            return evaluator.evaluate(cx, this);
        }
        else
        {
            return null;
        }
    }

    public int countVars()
    {
        return statement.countVars();
    }

    public boolean isBranch()
    {
        return true;
    }

    public boolean isLabeledStatement()
    {
        return true;
    }

    public String toString()
    {
        return "LabeledStatement";
    }
}
