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

package flex2.compiler.mxml;

import flash.localization.LocalizationManager;
import flex2.compiler.ILocalizableMessage;
import flex2.compiler.Logger;
import flex2.compiler.util.AbstractLogAdapter;
import flex2.compiler.util.LineNumberMap;

import java.util.*;
import java.util.Map.Entry;

/**
 * This is a Logger implementation, which handles mapping generated
 * line numbers and renamed variables back to the mxml line numbers
 * and variable names.
 *
 * @author Clement Wong
 */
public final class MxmlLogAdapter extends AbstractLogAdapter
{
    public MxmlLogAdapter(Logger original, LineNumberMap map)
    {
        super(original);
        this.map = map;
    }

    private LineNumberMap map;
    private List<LineNumberMap> extras;
    private Map renamedVariableMap;
    // Some ASC errors and warnings, like those caused by data binding expressions, will
    // get reported twice, so we store them in the following Map and only report them to
    // the user the first time we see them.
    private Map<String, String> messages;

    public void setRenamedVariableMap(Map renamedVariableMap)
    {
        this.renamedVariableMap = renamedVariableMap;
    }

	public void addLineNumberMap(LineNumberMap map)
	{
		if (extras == null)
		{
			extras = new ArrayList<LineNumberMap>(5);
		}
		extras.add(map);
	}

	public void addLineNumberMaps(Collection<LineNumberMap> c)
	{
		if (c != null && extras == null)
		{
			extras = new ArrayList<LineNumberMap>(5);
		}
		if (c != null)
		{
			extras.addAll(c);
		}
	}

    public void logInfo(String path, String info)
    {
        LineNumberMap map = null;
        if ((map = matchPath(path)) != null)
        {
            original.logInfo(map.getOldName(), info);
        }
        else
        {
            original.logInfo(path, info);
        }
    }

    public void logDebug(String path, String debug)
    {
        LineNumberMap map = null;
        if ((map = matchPath(path)) != null)
        {
            original.logDebug(map.getOldName(), debug);
        }
        else
        {
            original.logDebug(path, debug);
        }
    }

    public void logWarning(String path, String warning)
    {
        LineNumberMap map = null;
        if ((map = matchPath(path)) != null)
        {
            original.logWarning(map.getOldName(), warning);
        }
        else
        {
            original.logWarning(path, warning);
        }
    }

	public void logWarning(String path, String warning, int errorCode)
	{
	    LineNumberMap map = null;
	    if ((map = matchPath(path)) != null)
	    {
	        original.logWarning(map.getOldName(), warning, errorCode);
	    }
	    else
	    {
	        original.logWarning(path, warning, errorCode);
	    }
	}

    public void logError(String path, String error)
    {
        LineNumberMap map = null;
        if ((map = matchPath(path)) != null)
        {
            original.logError(map.getOldName(), error);
        }
        else
        {
            original.logError(path, error);
        }
    }

	public void logError(String path, String error, int errorCode)
	{
	    LineNumberMap map = null;
	    if ((map = matchPath(path)) != null)
	    {
	        original.logError(map.getOldName(), error, errorCode);
	    }
	    else
	    {
	        original.logError(path, error, errorCode);
	    }
	}

    public void logInfo(String path, int line, String info)
    {
        LineNumberMap map = null;
        if ((map = matchPath(path)) != null)
        {
            if (isUserDefined(map, line))
            {
                original.logInfo(map.getOldName(), map.get(line), info);
            }
            else
            {
                original.logInfo(path, line, info);
            }
        }
        else
        {
            original.logInfo(path, line, info);
        }
    }

    public void logDebug(String path, int line, String debug)
    {
        LineNumberMap map = null;
        if ((map = matchPath(path)) != null)
        {
            if (isUserDefined(map, line))
            {
                original.logDebug(map.getOldName(), map.get(line), debug);
            }
            else
            {
                original.logDebug(path, line, debug);
            }
        }
        else
        {
            original.logDebug(path, line, debug);
        }
    }

    public void logWarning(String path, int line, String warning)
    {
        LineNumberMap map = null;
        if ((map = matchPath(path)) != null)
        {
            if (isUserDefined(map, line))
            {
                original.logWarning(map.getOldName(), map.get(line), warning);
            }
            else
            {
                original.logWarning(path, line, warning);
            }
        }
        else
        {
            original.logWarning(path, line, warning);
        }
    }

	public void logWarning(String path, int line, String warning, int errorCode)
	{
	    LineNumberMap map = null;
	    if ((map = matchPath(path)) != null)
	    {
	        if (isUserDefined(map, line))
	        {
	            original.logWarning(map.getOldName(), map.get(line), warning, errorCode);
	        }
	        else
	        {
	            original.logWarning(path, line, warning, errorCode);
	        }
	    }
	    else
	    {
	        original.logWarning(path, line, warning, errorCode);
	    }
	}

    public void logError(String path, int line, String error)
    {
        LineNumberMap map = null;
        if ((map = matchPath(path)) != null)
        {
            if (isUserDefined(map, line))
            {
                original.logError(map.getOldName(), map.get(line), error);
            }
            else
            {
                original.logError(path, line, error);
            }
        }
        else
        {
            original.logError(path, line, error);
        }
    }

	public void logError(String path, int line, String error, int errorCode)
	{
	    LineNumberMap map = null;
	    if ((map = matchPath(path)) != null)
	    {
	        if (isUserDefined(map, line))
	        {
	            original.logError(map.getOldName(), map.get(line), error, errorCode);
	        }
	        else
	        {
	            original.logError(path, line, error, errorCode);
	        }
	    }
	    else
	    {
	        original.logError(path, line, error, errorCode);
	    }
	}

    public void logInfo(String path, int line, int col, String info)
    {
        LineNumberMap map = null;
        if ((map = matchPath(path)) != null)
        {
            if (isUserDefined(map, line))
            {
                original.logInfo(map.getOldName(), map.get(line), info);
            }
            else
            {
                original.logInfo(path, line, col, info);
            }
        }
        else
        {
            original.logInfo(path, line, col, info);
        }
    }

    public void logDebug(String path, int line, int col, String debug)
    {
        LineNumberMap map = null;
        if ((map = matchPath(path)) != null)
        {
            if (isUserDefined(map, line))
            {
                original.logDebug(map.getOldName(), map.get(line), debug);
            }
            else
            {
                original.logDebug(path, line, col, debug);
            }
        }
        else
        {
            original.logDebug(path, line, col, debug);
        }
    }

    public void logWarning(String path, int line, int col, String warning)
    {
        LineNumberMap map = null;
        if ((map = matchPath(path)) != null)
        {
            if (isUserDefined(map, line))
            {
                original.logWarning(map.getOldName(), map.get(line), warning);
            }
            else
            {
                original.logWarning(path, line, col, warning);
            }
        }
        else
        {
            original.logWarning(path, line, col, warning);
        }
    }

    public void logError(String path, int line, int col, String error)
    {
        LineNumberMap map = null;
        if ((map = matchPath(path)) != null)
        {
            if (isUserDefined(map, line))
            {
                original.logError(map.getOldName(), map.get(line), error);
            }
            else
            {
                original.logError(path, line, col, error);
            }
        }
        else
        {
            original.logError(path, line, col, error);
        }
    }

    public void logWarning(String path, int line, int col, String warning, String source)
    {
        warning = mapRenamedVariables(warning);

        LineNumberMap map = null;
        if ((map = matchPath(path)) != null)
        {
            if (isUserDefined(map, line))
            {
                if (messages == null)
                {
                    messages = new HashMap<String, String>();
                }

                String key = map.getOldName() + map.get(line);
                if (!warning.equals(messages.get(key)))
                {
                    original.logWarning(map.getOldName(), map.get(line), warning);
                    messages.put(key, warning);
                }
            }
            else
            {
                original.logWarning(path, line, col, warning, source);
            }
        }
        else
        {
            original.logWarning(path, line, col, warning, source);
        }
    }

	public void logWarning(String path, int line, int col, String warning, String source, int errorCode)
	{
	    warning = mapRenamedVariables(warning);

	    LineNumberMap map = null;
	    if ((map = matchPath(path)) != null)
	    {
	        if (isUserDefined(map, line))
	        {
	            if (messages == null)
	            {
	                messages = new HashMap<String, String>();
	            }

	            String key = map.getOldName() + map.get(line);
	            if (!warning.equals(messages.get(key)))
	            {
	                original.logWarning(map.getOldName(), map.get(line), warning, errorCode);
	                messages.put(key, warning);
	            }
	        }
	        else
	        {
	            original.logWarning(path, line, col, warning, source, errorCode);
	        }
	    }
	    else
	    {
	        original.logWarning(path, line, col, warning, source, errorCode);
	    }
	}

    public void logError(String path, int line, int col, String error, String source)
    {
        LineNumberMap map = null;
        if ((map = matchPath(path)) != null)
        {
            if (isUserDefined(map, line))
            {
                if (messages == null)
                {
                    messages = new HashMap<String, String>();
                }

                String key = map.getOldName() + map.get(line);
                if (!error.equals(messages.get(key)))
                {
                    //	don't pass source from "new" file; force logger to look up "old" line
                    original.logError(map.getOldName(), map.get(line), error);
                    messages.put(key, error);
                }
            }
            else
            {
                original.logError(path, line, col, error, source);
            }
        }
        else
        {
            original.logError(path, line, col, error, source);
        }
    }

	public void logError(String path, int line, int col, String error, String source, int errorCode)
	{
	    LineNumberMap map = null;
	    if ((map = matchPath(path)) != null)
	    {
	        if (isUserDefined(map, line))
	        {
	            if (messages == null)
	            {
	                messages = new HashMap<String, String>();
	            }

	            String key = map.getOldName() + map.get(line);
	            if (!error.equals(messages.get(key)))
	            {
	                //	don't pass source from "new" file; force logger to look up "old" line
	                original.logError(map.getOldName(), map.get(line), error, errorCode);
	                messages.put(key, error);
	            }
	        }
	        else
	        {
	            original.logError(path, line, col, error, source, errorCode);
	        }
	    }
	    else
	    {
	        original.logError(path, line, col, error, source, errorCode);
	    }
	}

    public void log( ILocalizableMessage m )
    {
	    log(m, null);
    }

	public void log( ILocalizableMessage m, String source)
	{
	    // C: If we encounter the asserts, we'll have to fix ILocalizableMessage.
	    LineNumberMap map = null;
	    if ((map = matchPath(m.getPath())) != null)
	    {
	        if (isUserDefined(map, m.getLine()))
	        {
	            m.setPath( map.getOldName() );
	            m.setLine( map.get( m.getLine() ) );
	            m.setColumn(-1);
		        source = null;
	        }
	        else
	        {
	            // m.message = addCodeGenMarker(map.getOldName(), m.message);
	            assert false: "codegen-specific error...";
	        }
	    }

	    if (source == null)
	    {
		    original.log( m );
	    }
		else
		{
			original.log( m, source);
		}
	}

    public void needsCompilation(String path, String reason)
    {
        // C: don't need path remapping here because it's only called by CompilerAPI.validateCompilationUnits()...
        original.needsCompilation(path, reason);
    }

	public void includedFileUpdated(String path)
	{
		// C: don't need path remapping here because it's only called by CompilerAPI.validateCompilationUnits()...
		original.includedFileUpdated(path);
	}

	public void includedFileAffected(String path)
	{
		// C: don't need path remapping here because it's only called by CompilerAPI.validateCompilationUnits()...
		original.includedFileAffected(path);
	}

	public void setLocalizationManager(LocalizationManager mgr)
	{
	}

	private LineNumberMap matchPath(String path)
	{
		if (map != null && map.getNewName().equals(path))
		{
			return map;
		}

		for (int i = 0, size = extras == null ? 0 : extras.size(); i < size; i++)
		{
			LineNumberMap m = extras.get(i);
			if (m.getNewName().equals(path))
			{
				return m;
			}
		}

		return null;
	}

	private boolean isUserDefined(LineNumberMap map, int line)
    {
        return map.get(line) > 0;
    }

    private String mapRenamedVariables(String message)
    {
        if (renamedVariableMap != null)
        {
            Iterator iterator = renamedVariableMap.entrySet().iterator();

            while ( iterator.hasNext() )
            {
                Entry entry = (Entry) iterator.next();
                String newVariableName = (String) entry.getKey();
                String oldVariableName = (String) entry.getValue();
                message = message.replaceAll("'" + newVariableName + "'", "'" + oldVariableName + "'");
            }
        }

        return message;
    }
}
