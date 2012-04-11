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

import flex2.compiler.mxml.rep.BindingExpression;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import macromedia.asc.parser.ArgumentListNode;

/**
 * This is a common base class for Watcher's which have args.
 *
 * @author Paul Reilly
 */
public abstract class EvaluationWatcher extends Watcher
{
    private ArgumentListNode args;
    private BindingExpression bindingExpression;
    private Watcher parentWatcher;

    public EvaluationWatcher(int id, BindingExpression bindingExpression, ArgumentListNode args)
    {
        super(id);
        this.bindingExpression = bindingExpression;
        this.args = args;        
    }

    public String getEvaluationPart()
    {
        String result = "";

        if (args != null)
        {
            StringWriter stringWriter = new StringWriter();
            PrintWriter printWriter = new PrintWriter(stringWriter);

            PrefixedPrettyPrinter prettyPrinter = new PrefixedPrettyPrinter("target", printWriter);
        
            prettyPrinter.evaluate(null, args);
            result = stringWriter.toString();
        }

        return result;
    }

    public boolean shouldWriteSelf()
    {
        return getChildren().size() > 0;
    }

    public BindingExpression getBindingExpression()
    {
        return bindingExpression;
    }

    public Watcher getParentWatcher()
    {
        return parentWatcher;
    }

    public void setParentWatcher(Watcher parentWatcher)
    {
        this.parentWatcher = parentWatcher;
    }
}
