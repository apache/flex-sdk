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
import flex2.compiler.util.NameFormatter;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.HashSet;
import java.util.Set;
import java.util.TreeSet;

/**
 * This class represents the information needed to construct the code
 * for a runtime watcher.
 *
 * @author Paul Reilly
 */
public abstract class Watcher
{
    protected Map<Object, Watcher> childWatchers;
    private int id;
    private Watcher parent;
    private boolean isPartOfAnonObjectGraph;
    private Set<ChangeEvent> changeEvents;
    private boolean shouldWriteChildren;
    private boolean operation;
    private String className;
    private Set<BindingExpression> bindingExpressions;

    protected static final ChangeEvent NO_CHANGE_EVENT = new ChangeEvent("__NoChangeEvent__", true);

    public Watcher(int id)
    {
        this.id = id;
        childWatchers = new HashMap<Object, Watcher>();
        isPartOfAnonObjectGraph = false;
        changeEvents = new HashSet<ChangeEvent>();
        shouldWriteChildren = true;
    }

    public void addBindingExpression(BindingExpression bindingExpression)
    {
        if (bindingExpressions == null)
        {
            bindingExpressions = new TreeSet<BindingExpression>();
        }

        bindingExpressions.add(bindingExpression);
    }

    public Set<BindingExpression> getBindingExpressions()
    {
        return bindingExpressions;
    }

    public Set<ChangeEvent> getChangeEvents()
    {
        return changeEvents;
    }

    public String getClassName()
    {
        return className;
    }

    public int getId()
    {
        return id;
    }

    public Watcher getParent()
    {
        return parent;
    }

    public boolean shouldWriteChildren()
    {
        return shouldWriteChildren;
    }

    public boolean isPartOfAnonObjectGraph()
    {
        return isPartOfAnonObjectGraph;
    }

    public void setPartOfAnonObjectGraph(boolean isPartOfAnonObjectGraph)
    {
        this.isPartOfAnonObjectGraph = isPartOfAnonObjectGraph;
    }

    public void setShouldWriteChildren(boolean shouldWriteChildren)
    {
        this.shouldWriteChildren = shouldWriteChildren;
    }

    public boolean shouldWriteSelf()
    {
        return true;
    }

    public void addChild(Watcher child)
    {
        if (child instanceof PropertyWatcher)
        {
            childWatchers.put(((PropertyWatcher) child).getProperty(), child);
        }
        else
        {
            childWatchers.put(new Integer(child.id), child);
        }

        child.parent = this;
    }

    public PropertyWatcher getChild(String property)
    {
        if (childWatchers.containsKey(property))
        {
            return (PropertyWatcher) childWatchers.get(property);
        }
        else
        {
            return null;
        }
    }

    public Collection<Watcher> getChildren()
    {
        return childWatchers.values();
    }

    public void addChangeEvent(String name)
    {
        addChangeEvent(name, true);
    }

    public void addChangeEvent(String name, boolean validate)
    {
        changeEvents.add(new ChangeEvent(name, validate));
    }

    public void addNoChangeEvent()
    {
        changeEvents.add(NO_CHANGE_EVENT);
    }

    public boolean isOperation()
    {
        return operation;
    }

    public void setClassName(String className)
    {
        this.className = NameFormatter.toDot(className);
    }

    public void setOperation(boolean operation)
    {
        this.operation = operation;
    }
}
