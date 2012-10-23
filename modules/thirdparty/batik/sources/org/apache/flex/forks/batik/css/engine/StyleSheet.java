/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.css.engine;

import org.w3c.css.sac.SACMediaList;

/**
 * This class represents a list of rules.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: StyleSheet.java 476924 2006-11-19 21:13:26Z dvholten $
 */
public class StyleSheet {

    /**
     * The rules.
     */
    protected Rule[] rules = new Rule[16];

    /**
     * The number of rules.
     */
    protected int size;

    /**
     * The parent sheet, if any.
     */
    protected StyleSheet parent;

    /**
     * Whether or not this stylesheet is alternate.
     */
    protected boolean alternate;

    /**
     * The media to use to cascade properties.
     */
    protected SACMediaList media;

    /**
     * The style sheet title.
     */
    protected String title;

    /**
     * Sets the media to use to compute the styles.
     */
    public void setMedia(SACMediaList m) {
        media = m;
    }

    /**
     * Returns the media to use to compute the styles.
     */
    public SACMediaList getMedia() {
        return media;
    }

    /**
     * Returns the parent sheet.
     */
    public StyleSheet getParent() {
        return parent;
    }

    /**
     * Sets the parent sheet.
     */
    public void setParent(StyleSheet ss) {
        parent = ss;
    }

    /**
     * Sets the 'alternate' attribute of this style-sheet.
     */
    public void setAlternate(boolean b) {
        alternate = b;
    }

    /**
     * Tells whether or not this stylesheet is alternate.
     */
    public boolean isAlternate() {
        return alternate;
    }

    /**
     * Sets the 'title' attribute of this style-sheet.
     */
    public void setTitle(String t) {
        title = t;
    }

    /**
     * Returns the title of this style-sheet.
     */
    public String getTitle() {
        return title;
    }

    /**
     * Returns the number of rules.
     */
    public int getSize() {
        return size;
    }

    /**
     * Returns the rule at the given index.
     */
    public Rule getRule(int i) {
        return rules[i];
    }

    /**
     * Clears the content.
     */
    public void clear() {
        size = 0;
        rules = new Rule[10];
    }

    /**
     * Appends a rule to the stylesheet.
     */
    public void append(Rule r) {
        if (size == rules.length) {
            Rule[] t = new Rule[size * 2];
            System.arraycopy( rules, 0, t, 0, size );
            rules = t;
        }
        rules[size++] = r;
    }

    /**
     * Returns a printable representation of this style-sheet.
     */
    public String toString(CSSEngine eng) {
        StringBuffer sb = new StringBuffer( size * 8 );
        for (int i = 0; i < size; i++) {
            sb.append(rules[i].toString(eng));
        }
        return sb.toString();
    }
}
