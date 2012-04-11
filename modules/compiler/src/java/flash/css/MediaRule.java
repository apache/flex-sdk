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
 * A CSS @media "at-rule".
 */
public class MediaRule extends Rule
{
    private MediaList mediaList;
    private List<Rule> rules;

    /**
     * Constructor.
     * 
     * @param mediaList - list of media queries
     * @param path - style sheet source location
     * @param lineNumber - line number on which this rule begins
     */
    public MediaRule(MediaList mediaList, String path, int lineNumber)
    {
        super(MEDIA_RULE, path, lineNumber);
        this.mediaList = mediaList;
    }

    /**
     * @return a list of media query Strings.
     */
    public MediaList getMediaList()
    {
        return mediaList;
    }
    
    /**
     * Add a CSS rule to this media rule.
     * 
     * @param rule
     */
    public void addRule(Rule rule)
    {
        if (rule instanceof StyleRule)
        {
            getRules().add(rule);
        }
    }

    /**
     * @return List of CSS rules for this media rule.
     */
    public List<Rule> getRules()
    {
        if (rules == null)
            rules = new ArrayList<Rule>();

        return rules;
    }
}
