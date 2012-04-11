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

package flash.css;

import java.util.ArrayList;
import java.util.List;

/**
 * A list of CSS media queries that restrict which styles apply at runtime
 * based on device capabilities.
 */
public class MediaList
{
    private List<String> queries;

    /**
     * Constructor.
     */
    public MediaList()
    {
        queries = new ArrayList<String>(4);
    }

    /**
     * Add a CSS media query to the list.
     * 
     * @param query - a media query to add to the list.
     */
    public void addQuery(String query)
    {
        queries.add(query);
    }

    /**
     * @return the list of media queries.
     */
    public List<String> getQueries()
    {
        return queries;
    }

    /**
     * @return a comma delimited list of media query Strings, with literal
     * double quotes escaped for inclusion in ActionScript source.
     */
    public String toEscapedString()
    {
        String s = toString();
        s = s.replace("\"", "\\\"");
        return s;
    }

    
    /**
     * @return a comma delimited list of media query Strings.
     */
    public String toString()
    {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < queries.size(); i++)
        {
            sb.append(queries.get(i));
            if (i < queries.size() - 1)
            {
                sb.append(", ");
            }
        }
        return sb.toString();
    }
}
