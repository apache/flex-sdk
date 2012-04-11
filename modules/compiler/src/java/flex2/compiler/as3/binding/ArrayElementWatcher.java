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
import macromedia.asc.parser.ArgumentListNode;

/**
 * This class represents the information needed to create a runtime
 * array element watcher.  For example, for the data binding
 * expression, "{foo[bar, baz]}", we need watchers for "bar" and
 * "baz", so when they change, the destination will update.
 *
 * @author Paul Reilly
 */
public class ArrayElementWatcher extends EvaluationWatcher
{
    public ArrayElementWatcher(int id, BindingExpression bindingExpression, ArgumentListNode args)
    {
        super(id, bindingExpression, args);
    }

    public boolean shouldWriteChildren()
    {
        return shouldWriteSelf();
    }

    public boolean shouldWriteSelf()
    {
        boolean result = true;
        Watcher parent = getParent();

        if ((parent != null) && ((parent instanceof XMLWatcher) || !parent.shouldWriteSelf()))
        {
            result = false;
        }

        return result;
    }
}
