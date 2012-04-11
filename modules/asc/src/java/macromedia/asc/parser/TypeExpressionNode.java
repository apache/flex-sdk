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

package macromedia.asc.parser;

import macromedia.asc.semantics.Value;
import macromedia.asc.util.Context;

/**
 * Created by IntelliJ IDEA.
 * User: tierney
 * Date: Nov 20, 2006
 * Time: 3:40:53 PM
 * To change this template use File | Settings | File Templates.
 */
public class TypeExpressionNode extends Node
{
    public boolean nullable_annotation;
    public boolean is_nullable;

    public Node expr;
    public TypeExpressionNode(Node expr, boolean is_nullable, boolean is_explicit)
    {
        this.expr = expr;

        this.is_nullable = is_nullable;

        this.nullable_annotation = is_explicit;
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

    public void voidResult()
    {
        expr.voidResult();
    }

    public String toString()
    {
        if(Node.useDebugToStrings)
        {
            return "TypeExpression@" + pos();
        }
        else
        {
            return "TypeEpression";
        }
    }

    public boolean hasAttribute(String name)
    {
        return expr.hasAttribute(name);
    }

    public boolean hasSideEffect()
    {
        return expr.hasSideEffect();
    }

    public boolean isLValue()
    {
        return this.expr.isLValue();
    }

    public StringBuilder toCanonicalString(Context cx, StringBuilder buf)
    {
        return this.expr != null ? this.expr.toCanonicalString(cx, buf) : buf;
    }
    
}
