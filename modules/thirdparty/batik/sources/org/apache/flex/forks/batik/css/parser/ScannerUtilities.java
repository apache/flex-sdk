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

package org.apache.flex.forks.batik.css.parser;

/**
 * A collection of utility functions for a CSS scanner.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @version $Id: ScannerUtilities.java 478283 2006-11-22 18:53:40Z dvholten $
 */
public class ScannerUtilities {

    /**
     * The set of the valid identifier start characters.
     */
    protected static final int[] IDENTIFIER_START =
    { 0x0, 0x0, 0x87FFFFFE, 0x7FFFFFE };

    /**
     * The set of the valid name characters.
     */
    protected static final int[] NAME =
    { 0, 0x3FF2000, 0x87FFFFFE, 0x7FFFFFE };

    /**
     * The set of the valid hexadecimal characters.
     */
    protected static final int[] HEXADECIMAL =
    { 0, 0x3FF0000, 0x7E, 0x7E };

    /**
     * The set of the valid string characters.
     */
    protected static final int[] STRING =
    { 0x200, 0xFFFFFF7B, 0xFFFFFFFF, 0x7FFFFFFF };

    /**
     * The set of the valid uri characters.
     */
    protected static final int[] URI =
    { 0x0, 0xFFFFFC7A, 0xFFFFFFFF, 0x7FFFFFFF };

    /**
     * This class does not need to be instantiated.
     */
    protected ScannerUtilities() {
    }

    /**
     * Tests whether the given character is a valid space.
     */
    public static boolean isCSSSpace(char c) {
      return (c <= 0x0020) &&
             (((((1L << '\t') |
                 (1L << '\n') |
                 (1L << '\r') |
                 (1L << '\f') |
                 (1L << 0x0020)) >> c) & 1L) != 0);
    }

    /**
     * Tests whether the given character is a valid identifier start character.
     */
    public static boolean isCSSIdentifierStartCharacter(char c) {
        return c >= 128 || ((IDENTIFIER_START[c>>5] & (1 << (c &0x1F))) != 0);
    }

    /**
     * Tests whether the given character is a valid name character.
     */
    public static boolean isCSSNameCharacter(char c) {
        return c >= 128 || ((NAME[c >>5] & (1 << (c &0x1F))) != 0);
    }

    /**
     * Tests whether the given character is a valid hexadecimal character.
     */
    public static boolean isCSSHexadecimalCharacter(char c) {
        return c < 128 && ((HEXADECIMAL[c>>5] & (1 << (c&0x1F))) != 0);
    }

    /**
     * Tests whether the given character is a valid string character.
     */
    public static boolean isCSSStringCharacter(char c) {
        return c >= 128 || ((STRING[c>>5] & (1 << (c&0x1F))) != 0);
    }

    /**
     * Tests whether the given character is a valid URI character.
     */
    public static boolean isCSSURICharacter(char c) {
        return c >= 128 || ((URI[c>>5] & (1 << (c&0x1F))) != 0);
    }
}
