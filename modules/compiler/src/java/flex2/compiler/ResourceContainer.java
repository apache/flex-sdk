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

package flex2.compiler;

import flex2.compiler.util.QName;
import flex2.compiler.util.QNameMap;
import flex2.tools.oem.ApplicationCache;

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * This class acts as a container for extra <code>Source</code>
 * objects, which are created in the process of compiling other
 * <code>Source</code> objects.  For example, when compiling an MXML
 * document, which includes data binding expressions, we create a new
 * <code>Source</code> for the <code>WatcherSetupUtil</code> class.
 *
 * @author Clement Wong
 */
public final class ResourceContainer
{
	public ResourceContainer()
	{
		name2source = new LinkedHashMap<String, Source>();
		qname2source = new QNameMap<Source>();
	}

	private Map<String, Source> name2source;
	private QNameMap<Source> qname2source;
    private ApplicationCache applicationCache;

	public Source addResource(Source s)
	{
		Source old = name2source.get(s.getName());
		CompilationUnit u = old != null ? old.getCompilationUnit() : null;

		if (u == null || 
			(u != null && !u.isDone()) || 
			(old.getLastModified() != s.getLastModified()) ||
			old.isUpdated(s))
		{
			s.setOwner(this);
			name2source.put(s.getName(), s);
			return s;
		}
		else // if (u != null && u.isDone())
		{
			return old.copy();
		}
	}

	public Source findSource(String name)
	{
        if (applicationCache != null)
        {
            Source cachedSource = applicationCache.getSource(name);

            if ((cachedSource != null) && !cachedSource.isUpdated())
            {
                CompilationUnit cachedCompilationUnit = cachedSource.getCompilationUnit();

                if ((cachedCompilationUnit != null) && cachedCompilationUnit.hasTypeInfo)
                {
                    Source source = cachedSource.copy();
                    cachedSource.reused();
                    name2source.put(name, source);
                    return source;
                }
            }
        }

		return checkSource(name2source.get(name));
	}

	Source findSource(String namespaceURI, String localPart)
	{
		assert localPart.indexOf('.') == -1 && localPart.indexOf('/') == -1 && localPart.indexOf(':') == -1
                : "findSource(" + namespaceURI + "," + localPart + ") has bad localPart";

        if (applicationCache != null)
        {
            String className = CompilerAPI.constructClassName(namespaceURI, localPart);
            Source cachedSource = applicationCache.getSource(className);

            if ((cachedSource != null) && !cachedSource.isUpdated())
            {
                CompilationUnit cachedCompilationUnit = cachedSource.getCompilationUnit();

                if ((cachedCompilationUnit != null) && cachedCompilationUnit.hasTypeInfo
                        // If isDone is false, then cachedSource.copy() below will just bail, and return null
                        && cachedCompilationUnit.isDone())
                {
                    Source source = cachedSource.copy();
                    cachedSource.reused();
                    name2source.put(source.getName(), source);
                    qname2source.put(namespaceURI, localPart, source);
                    return source;
                }
            }
        }

		return checkSource(qname2source.get(namespaceURI, localPart));
	}

	private Source checkSource(Source s)
	{
		CompilationUnit u = s != null ? s.getCompilationUnit() : null;

		if ((u != null && !u.isDone()) || (s != null && s.isUpdated()))
		{
			// s.removeCompilationUnit();
		}
		else if (u != null)
		{
			s = s.copy();
			assert s != null;
		}

		return s;
	}

	public void refresh()
	{
		qname2source.clear();
		
		for (Iterator<Source> i = name2source.values().iterator(); i.hasNext();)
		{
			Source s = i.next();
			CompilationUnit u = s.getCompilationUnit();
			if (u != null)
			{
				for (int j = 0, size = u.topLevelDefinitions.size(); j < size; j++)
				{
					QName qName = u.topLevelDefinitions.get(j);
					qname2source.put(qName, s);
				}
			}
		}
	}

	public Map<String, Source> sources()
	{
        Map result = new HashMap<String, Source>(qname2source.size());

        for (Map.Entry<QName, Source> entry : qname2source.entrySet())
        {
            result.put(entry.getKey().toString(), entry.getValue());
        }

		return result;
	}

    public void setApplicationCache(ApplicationCache applicationCache)
    {
        this.applicationCache = applicationCache;
    }
}
