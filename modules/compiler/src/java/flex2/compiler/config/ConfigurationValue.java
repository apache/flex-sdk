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

package flex2.compiler.config;

import java.util.List;
import java.util.LinkedList;

/**
 * This class represents an instance of a configuration option.  For
 * example, "-debug=true".
 *
 * @author Roger Gonzalez
 */
public class ConfigurationValue
{
    protected ConfigurationValue( ConfigurationBuffer buffer, String var, List<String> args, String source, int line, String context )
    {
        this.buffer = buffer;
        this.var = var;
        this.args = new LinkedList<String>( args );
        this.source = source;
        this.line = line;
        this.context = context;
    }

    /**
     * getArgs
     *
     * @return list of values provided, in schema order
     */
    public final List<String> getArgs()
    {
        return args;
    }

    /**
     * getBuffer
     *
     * @return a handle to the associated buffer holding this value
     */
    public final ConfigurationBuffer getBuffer()
    {
        return buffer;
    }

    /**
     * getSource
     *
     * @return a string representing the origin of this value, or null if unknown
     */
    public final String getSource()
    {
        return source;
    }

    /**
     * getLine
     *
     * @return the line number of the origin of this value, or -1 if unknown
     */
    public final int getLine()
    {
        return line;
    }

    /**
     * getVar
     *
     * @return the full name of this configuration variable in the hierarchy
     */
    public final String getVar()
    {
        return var;
    }

    /**
     * getContext
     *
     * @return the path of the enclosing context where the variable was set
     * (i.e. the directory where the config file was found)
     */
    public final String getContext()
    {
        return context;
    }

    private final ConfigurationBuffer buffer;
    private final String var;
    private final List<String> args;
    private final String source;
    private final int line;
    private final String context;
}
