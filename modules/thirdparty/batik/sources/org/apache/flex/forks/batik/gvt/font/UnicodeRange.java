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
package org.apache.flex.forks.batik.gvt.font;


/**
 * A class that represents a CSS unicode range.  This only handles
 * a single range of contigous chars, to handle multiple ranges
 * (comma seperated) use a list of these.
 *
 * @author <a href="mailto:bella.robinson@cmis.csiro.au">Bella Robinson</a>
 * @version $Id: UnicodeRange.java 475477 2006-11-15 22:44:28Z cam $
 */
public class UnicodeRange {

    private int firstUnicodeValue;
    private int lastUnicodeValue;

    /**
     * Constructs a unicode range from a CSS unicode range string.
     */
    public UnicodeRange(String unicodeRange) {

        if (unicodeRange.startsWith("U+") && unicodeRange.length() > 2) {
            // strip off the U+
            unicodeRange = unicodeRange.substring(2);
            int dashIndex = unicodeRange.indexOf('-');
            String firstValue;
            String lastValue;

            if (dashIndex != -1) { // it is a simple 2 value range
                firstValue = unicodeRange.substring(0, dashIndex);
                lastValue = unicodeRange.substring(dashIndex+1);

            } else {
                firstValue = unicodeRange;
                lastValue = unicodeRange;
                if (unicodeRange.indexOf('?') != -1) {
                    firstValue = firstValue.replace('?', '0');
                    lastValue = lastValue.replace('?', 'F');
                }
            }
            try {
                firstUnicodeValue = Integer.parseInt(firstValue, 16);
                lastUnicodeValue = Integer.parseInt(lastValue, 16);
            } catch (NumberFormatException e) {
                firstUnicodeValue = -1;
                lastUnicodeValue = -1;
            }
        } else {
            // not a valid unicode range
            firstUnicodeValue = -1;
            lastUnicodeValue = -1;
        }
    }

    /**
     * Returns true if the specified unicode value is within this range.
     */
    public boolean contains(String unicode) {
        if (unicode.length() == 1) {
            int unicodeVal = unicode.charAt(0);
            return contains(unicodeVal);
        }
        return false;
    }

    public boolean contains(int unicodeVal) {
        return ((unicodeVal >= firstUnicodeValue) &&
                (unicodeVal <= lastUnicodeValue));
    }

}
