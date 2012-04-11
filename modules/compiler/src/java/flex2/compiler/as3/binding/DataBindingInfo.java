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

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * This value object is used to pass information from the
 * DataBindingFirstPassEvaluator back to DataBindingExtension.
 * 
 * @author Paul Reilly
 */
public class DataBindingInfo
{
    private String className;
    /**
     * Root watchers are watchers that watch things hanging off the
     * document (as opposed to children).
     */
    private Map<String, Watcher> rootWatchers;
    private List<BindingExpression> bindingExpressions;
    private String watcherSetupUtilClassName;
    private Set<String> imports;

    public DataBindingInfo(Set<String> imports)
    {
        this.imports = imports;
        rootWatchers = new HashMap<String, Watcher>();
    }

    public List<BindingExpression> getBindingExpressions()
    {
        return bindingExpressions;
    }

    public String getClassName()
    {
        return className;
    }

    public Set<String> getImports()
    {
        return imports;
    }

    public Map<String, Watcher> getRootWatchers()
    {
        return rootWatchers;
    }

    public String getWatcherSetupUtilClassName()
    {
        return watcherSetupUtilClassName;
    }

    public void setBindingExpressions(List<BindingExpression> bindingExpressions)
    {
        this.bindingExpressions = bindingExpressions;
    }

    public void setClassName(String className)
    {
        this.className = NameFormatter.toDot(className);
        watcherSetupUtilClassName = "_" + this.className.replace('.', '_') + "WatcherSetupUtil";
    }
}
