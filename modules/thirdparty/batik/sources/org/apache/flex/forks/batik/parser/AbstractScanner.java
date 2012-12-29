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
package org.apache.flex.forks.batik.parser;

import java.io.IOException;
import java.io.InputStream;
import java.io.Reader;

import org.apache.flex.forks.batik.util.io.NormalizingReader;
import org.apache.flex.forks.batik.util.io.StreamNormalizingReader;
import org.apache.flex.forks.batik.util.io.StringNormalizingReader;

/**
 * An abstract scanner class to be extended.
 *
 * @author <a href="mailto:stephane@hillion.org">Stephane Hillion</a>
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: AbstractScanner.java 478188 2006-11-22 15:19:17Z dvholten $
 */
public abstract class AbstractScanner {

    /**
     * The reader.
     */
    protected NormalizingReader reader;

    /**
     * The current char.
     */
    protected int current;

    /**
     * The recording buffer.
     */
    protected char[] buffer = new char[128];

    /**
     * The current position in the buffer.
     */
    protected int position;

    /**
     * The type of the current lexical unit.
     */
    protected int type;

    /**
     * The previous lexical unit type that was scanned.
     */
    protected int previousType;

    /**
     * The start offset of the last lexical unit.
     */
    protected int start;

    /**
     * The end offset of the last lexical unit.
     */
    protected int end;

    /**
     * The characters to skip to create the string which represents the
     * current token.
     */
    protected int blankCharacters;

    /**
     * Creates a new AbstractScanner object.
     * @param r The reader to scan.
     */
    public AbstractScanner(Reader r) throws ParseException {
        try {
            reader = new StreamNormalizingReader(r);
            current = nextChar();
        } catch (IOException e) {
            throw new ParseException(e);
        }
    }

    /**
     * Creates a new AbstractScanner object.
     * @param is The input stream to scan.
     * @param enc The encoding to use to decode the input stream, or null.
     */
    public AbstractScanner(InputStream is, String enc) throws ParseException {
        try {
            reader = new StreamNormalizingReader(is, enc);
            current = nextChar();
        } catch (IOException e) {
            throw new ParseException(e);
        }
    }

    /**
     * Creates a new AbstractScanner object.
     * @param s The string to scan.
     */
    public AbstractScanner(String s) throws ParseException {
        try {
            reader = new StringNormalizingReader(s);
            current = nextChar();
        } catch (IOException e) {
            throw new ParseException(e);
        }
    }

    /**
     * Returns the current line.
     */
    public int getLine() {
        return reader.getLine();
    }

    /**
     * Returns the current column.
     */
    public int getColumn() {
        return reader.getColumn();
    }

    /**
     * Returns the buffer used to store the chars.
     */
    public char[] getBuffer() {
        return buffer;
    }

    /**
     * Returns the start offset of the last lexical unit.
     */
    public int getStart() {
        return start;
    }

    /**
     * Returns the end offset of the last lexical unit.
     */
    public int getEnd() {
        return end;
    }

    /**
     * Clears the buffer.
     */
    public void clearBuffer() {
        if (position <= 0) {
            position = 0;
        } else {
            buffer[0] = buffer[position-1];
            position = 1;
        }
    }

    /**
     * The current lexical unit type like defined in LexicalUnits.
     */
    public int getType() {
        return type;
    }

    /**
     * Returns the string representation of the current lexical unit.
     */
    public String getStringValue() {
        return new String(buffer, start, end - start);
    }

    /**
     * Returns the next token.
     */
    public int next() throws ParseException {
        blankCharacters = 0;
        start = position - 1;
        previousType = type;
        nextToken();
        end = position - endGap();
        return type;
    }

    /**
     * Returns the end gap of the current lexical unit.
     */
    protected abstract int endGap();

    /**
     * Returns the next token.
     */
    protected abstract void nextToken() throws ParseException;

    /**
     * Compares the given int with the given character, ignoring case.
     */
    protected static boolean isEqualIgnoreCase(int i, char c) {
        return (i == -1) ? false : Character.toLowerCase((char)i) == c;
    }

    /**
     * Sets the value of the current char to the next character or -1 if the
     * end of stream has been reached.
     */
    protected int nextChar() throws IOException {
        current = reader.read();

        if (current == -1) {
            return current;
        }

        if (position == buffer.length) {
            char[] t = new char[ 1 + position + position / 2];
            System.arraycopy( buffer, 0, t, 0, position );
            buffer = t;
        }

        return buffer[position++] = (char)current;
    }
}
