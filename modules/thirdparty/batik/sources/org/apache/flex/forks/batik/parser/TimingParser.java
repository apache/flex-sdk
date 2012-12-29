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
import java.util.Calendar;
import java.util.SimpleTimeZone;

import org.apache.flex.forks.batik.xml.XMLUtilities;

/**
 * An abstract base class for SMIL timing value parsers.
 *
 * @author <a href="mailto:cam%40mcc%2eid%2eau">Cameron McCormack</a>
 * @version $Id: TimingParser.java 502167 2007-02-01 09:26:51Z dvholten $
 */
public abstract class TimingParser extends AbstractParser {

    // Constants used in the return values of parseTimingSpecifier.
    protected static final int TIME_OFFSET          = 0;
    protected static final int TIME_SYNCBASE        = 1;
    protected static final int TIME_EVENTBASE       = 2;
    protected static final int TIME_REPEAT          = 3;
    protected static final int TIME_ACCESSKEY       = 4;
    protected static final int TIME_ACCESSKEY_SVG12 = 5;
    protected static final int TIME_MEDIA_MARKER    = 6;
    protected static final int TIME_WALLCLOCK       = 7;
    protected static final int TIME_INDEFINITE      = 8;

    /**
     * Allows the use of accessKey() timing specifiers with a single
     * character, as specified in SVG 1.1.
     */
    protected boolean useSVG11AccessKeys;

    /**
     * Allows the use of accessKey() timing specifiers with a DOM 3
     * key name, as specified in SVG 1.2.
     */
    protected boolean useSVG12AccessKeys;

    /**
     * Creates a new TimingParser.
     * @param useSVG11AccessKeys allows the use of accessKey() timing
     *                           specifiers with a single character
     * @param useSVG12AccessKeys allows the use of accessKey() with a
     *                           DOM 3 key name
     */
    public TimingParser(boolean useSVG11AccessKeys,
                        boolean useSVG12AccessKeys) {
        this.useSVG11AccessKeys = useSVG11AccessKeys;
        this.useSVG12AccessKeys = useSVG12AccessKeys;
    }

    /**
     * Parses a timing specifier.  Returns an array of Objects of the
     * form:
     * <ul>
     *   <li>{ TIME_OFFSET,          offset }</li>
     *   <li>{ TIME_SYNCBASE,        offset, id, time-symbol }</li>
     *   <li>{ TIME_EVENTBASE,       offset, id, event-ref }</li>
     *   <li>{ TIME_REPEAT,          offset, id, repeat-count }</li>
     *   <li>{ TIME_ACCESSKEY,       offset, character }</li>
     *   <li>{ TIME_ACCESSKEY_SVG12, offset, key-name }</li>
     *   <li>{ TIME_MEDIA_MARKER,    id, marker-name }</li>
     *   <li>{ TIME_WALLCLOCK,       wallclock-value }</li>
     *   <li>{ TIME_INDEFINITE }</li>
     * </ul>
     */
    protected Object[] parseTimingSpecifier() throws ParseException, IOException {
        skipSpaces();
        boolean escaped = false;
        if (current == '\\') {
            escaped = true;
            current = reader.read();
        }
        Object[] ret = null;
        if (current == '+' || (current == '-' && !escaped)
                || (current >= '0' && current <= '9')) {
            float offset = parseOffset();
            ret = new Object[] { new Integer(TIME_OFFSET), new Float(offset) };
        } else if (XMLUtilities.isXMLNameFirstCharacter((char) current)) {
            ret = parseIDValue(escaped);
        } else {
            reportUnexpectedCharacterError( current );
        }
        return ret;
    }

    /**
     * Parses an XML name with optional escaping in the middle.
     */
    protected String parseName() throws ParseException, IOException {
        StringBuffer sb = new StringBuffer();
        boolean midEscaped = false;
        do {
            sb.append((char) current);
            current = reader.read();
            midEscaped = false;
            if (current == '\\') {
                midEscaped = true;
                current = reader.read();
            }
        } while (XMLUtilities.isXMLNameCharacter((char) current)
                && (midEscaped || (current != '-' && current != '.')));
        return sb.toString();
    }

    /**
     * Parses a timing specifier that starts with a word.
     * @param escaped whether a backslash appeared before this timing specifier
     */
    protected Object[] parseIDValue(boolean escaped)
            throws ParseException, IOException {
        String id = parseName();
        if ((id.equals("accessKey") && useSVG11AccessKeys
                || id.equals("accesskey"))
                && !escaped) {
            if (current != '(') {
                reportUnexpectedCharacterError( current );
            }
            current = reader.read();
            if (current == -1) {
                reportError("end.of.stream", new Object[0]);
            }
            char key = (char) current;
            current = reader.read();
            if (current != ')') {
                reportUnexpectedCharacterError( current );
            }
            current = reader.read();
            skipSpaces();
            float offset = 0;
            if (current == '+' || current == '-') {
                offset = parseOffset();
            }
            return new Object[] { new Integer(TIME_ACCESSKEY),
                                  new Float(offset),
                                  new Character(key) };
        } else if (id.equals("accessKey") && useSVG12AccessKeys && !escaped) {
            if (current != '(') {
                reportUnexpectedCharacterError( current );
            }
            current = reader.read();
            StringBuffer keyName = new StringBuffer();
            while (current >= 'A' && current <= 'Z'
                    || current >= 'a' && current <= 'z'
                    || current >= '0' && current <= '9'
                    || current == '+') {
                keyName.append((char) current);
                current = reader.read();
            }
            if (current != ')') {
                reportUnexpectedCharacterError( current );
            }
            current = reader.read();
            skipSpaces();
            float offset = 0;
            if (current == '+' || current == '-') {
                offset = parseOffset();
            }
            return new Object[] { new Integer(TIME_ACCESSKEY_SVG12),
                                  new Float(offset),
                                  keyName.toString() };
        } else if (id.equals("wallclock") && !escaped) {
            if (current != '(') {
                reportUnexpectedCharacterError( current );
            }
            current = reader.read();
            skipSpaces();
            Calendar wallclockValue = parseWallclockValue();
            skipSpaces();
            if (current != ')') {
                reportError("character.unexpected",
                            new Object[] { new Integer(current) });
            }
            current = reader.read();
            return new Object[] { new Integer(TIME_WALLCLOCK), wallclockValue };
        } else if (id.equals("indefinite") && !escaped) {
            return new Object[] { new Integer(TIME_INDEFINITE) };
        } else {
            if (current == '.') {
                current = reader.read();
                if (current == '\\') {
                    escaped = true;
                    current = reader.read();
                }
                if (!XMLUtilities.isXMLNameFirstCharacter((char) current)) {
                    reportUnexpectedCharacterError( current );
                }
                String id2 = parseName();
                if ((id2.equals("begin") || id2.equals("end")) && !escaped) {
                    skipSpaces();
                    float offset = 0;
                    if (current == '+' || current == '-') {
                        offset = parseOffset();
                    }
                    return new Object[] { new Integer(TIME_SYNCBASE),
                                          new Float(offset),
                                          id,
                                          id2 };
                } else if (id2.equals("repeat") && !escaped) {
                    Integer repeatIteration = null;
                    if (current == '(') {
                        current = reader.read();
                        repeatIteration = new Integer(parseDigits());
                        if (current != ')') {
                            reportUnexpectedCharacterError( current );
                        }
                        current = reader.read();
                    }
                    skipSpaces();
                    float offset = 0;
                    if (current == '+' || current == '-') {
                        offset = parseOffset();
                    }
                    return new Object[] { new Integer(TIME_REPEAT),
                                          new Float(offset),
                                          id,
                                          repeatIteration };
                } else if (id2.equals("marker") && !escaped) {
                    if (current != '(') {
                        reportUnexpectedCharacterError( current );
                    }
                    String markerName = parseName();
                    if (current != ')') {
                        reportUnexpectedCharacterError( current );
                    }
                    current = reader.read();
                    return new Object[] { new Integer(TIME_MEDIA_MARKER),
                                          id,
                                          markerName };
                } else {
                    skipSpaces();
                    float offset = 0;
                    if (current == '+' || current == '-') {
                        offset = parseOffset();
                    }
                    return new Object[] { new Integer(TIME_EVENTBASE),
                                          new Float(offset),
                                          id,
                                          id2 };
                }
            } else {
                skipSpaces();
                float offset = 0;
                if (current == '+' || current == '-') {
                    offset = parseOffset();
                }
                return new Object[] { new Integer(TIME_EVENTBASE),
                                      new Float(offset),
                                      null,
                                      id };
            }
        }
    }

    /**
     * Parses a clock value.
     */
    protected float parseClockValue() throws ParseException, IOException {
        int d1 = parseDigits();
        float offset;
        if (current == ':') {
            current = reader.read();
            int d2 = parseDigits();
            if (current == ':') {
                current = reader.read();
                int d3 = parseDigits();
                offset = d1 * 3600 + d2 * 60 + d3;
            } else {
                offset = d1 * 60 + d2;
            }
            if (current == '.') {
                current = reader.read();
                offset += parseFraction();
            }
        } else if (current == '.') {
            current = reader.read();
            offset = (parseFraction() + d1) * parseUnit();
        } else {
            offset = d1 * parseUnit();
        }
        return offset;
    }

    /**
     * Parses an offset value.
     */
    protected float parseOffset() throws ParseException, IOException {
        boolean offsetNegative = false;
        if (current == '-') {
            offsetNegative = true;
            current = reader.read();
            skipSpaces();
        } else if (current == '+') {
            current = reader.read();
            skipSpaces();
        }
        if (offsetNegative) {
            return -parseClockValue();
        }
        return parseClockValue();
    }

    /**
     * Parses a sequence of digits and returns the integer.
     */
    protected int parseDigits() throws ParseException, IOException {
        int value = 0;
        if (current < '0' || current > '9') {
            reportUnexpectedCharacterError( current );
        }
        do {
            value = value * 10 + (current - '0');
            current = reader.read();
        } while (current >= '0' && current <= '9');
        return value;
    }

    /**
     * Parses a '.' and a sequence of digits and returns the float.
     */
    protected float parseFraction() throws ParseException, IOException {
        float value = 0;
        if (current < '0' || current > '9') {
            reportUnexpectedCharacterError( current );
        }
        float weight = 0.1f;
        do {
            value += weight * (current - '0');
            weight *= 0.1f;
            current = reader.read();
        } while (current >= '0' && current <= '9');
        return value;
    }

    /**
     * Parses a time unit and returns the float for the multiplier.
     */
    protected float parseUnit() throws ParseException, IOException {
        if (current == 'h') {
            current = reader.read();
            return 3600;
        } else if (current == 'm') {
            current = reader.read();
            if (current == 'i') {
                current = reader.read();
                if (current != 'n') {
                    reportUnexpectedCharacterError( current );
                }
                current = reader.read();
                return 60;
            } else if (current == 's') {
                current = reader.read();
                return 0.001f;
            } else {
                reportUnexpectedCharacterError( current );
            }
        } else if (current == 's') {
            current = reader.read();
        }
        return 1;
    }

    /**
     * Parses a wallclock value and returns it as a {@link Calendar}.
     */
    protected Calendar parseWallclockValue()
            throws ParseException, IOException {
        int y = 0, M = 0, d = 0, h = 0, m = 0, s = 0, tzh = 0, tzm = 0;
        float frac = 0;
        boolean dateSpecified = false;
        boolean timeSpecified = false;
        boolean tzSpecified = false;
        boolean tzNegative = false;
        String tzn = null;

        int digits1 = parseDigits();
        do {
            if (current == '-') {
                dateSpecified = true;
                y = digits1;
                current = reader.read();
                M = parseDigits();
                if (current != '-') {
                    reportUnexpectedCharacterError( current );
                }
                current = reader.read();
                d = parseDigits();
                if (current != 'T') {
                    break;
                }
                current = reader.read();
                digits1 = parseDigits();
                if (current != ':') {
                    reportUnexpectedCharacterError( current );
                }
            }
            if (current == ':') {
                timeSpecified = true;
                h = digits1;
                current = reader.read();
                m = parseDigits();
                if (current == ':') {
                    current = reader.read();
                    s = parseDigits();
                    if (current == '.') {
                        current = reader.read();
                        frac = parseFraction();
                    }
                }
                if (current == 'Z') {
                    tzSpecified = true;
                    tzn = "UTC";
                    current = reader.read();
                } else if (current == '+' || current == '-') {
                    StringBuffer tznb = new StringBuffer();
                    tzSpecified = true;
                    if (current == '-') {
                        tzNegative = true;
                        tznb.append('-');
                    } else {
                        tznb.append('+');
                    }
                    current = reader.read();
                    tzh = parseDigits();
                    if (tzh < 10) {
                        tznb.append('0');
                    }
                    tznb.append(tzh);
                    if (current != ':') {
                        reportUnexpectedCharacterError( current );
                    }
                    tznb.append(':');
                    current = reader.read();
                    tzm = parseDigits();
                    if (tzm < 10) {
                        tznb.append('0');
                    }
                    tznb.append(tzm);
                    tzn = tznb.toString();
                }
            }
        } while (false);
        if (!dateSpecified && !timeSpecified) {
            reportUnexpectedCharacterError( current );
        }
        Calendar wallclockTime;
        if (tzSpecified) {
            int offset = (tzNegative ? -1 : 1)
                * (tzh * 3600000 + tzm * 60000);
            wallclockTime = Calendar.getInstance(new SimpleTimeZone(offset, tzn));
        } else {
            wallclockTime = Calendar.getInstance();
        }
        if (dateSpecified && timeSpecified) {
            wallclockTime.set(y, M, d, h, m, s);
        } else if (dateSpecified) {
            wallclockTime.set(y, M, d, 0, 0, 0);
        } else {
            wallclockTime.set(Calendar.HOUR, h);
            wallclockTime.set(Calendar.MINUTE, m);
            wallclockTime.set(Calendar.SECOND, s);
        }
        if (frac == 0.0f) {
            wallclockTime.set(Calendar.MILLISECOND, (int) (frac * 1000));
        } else {
            wallclockTime.set(Calendar.MILLISECOND, 0);
        }
        return wallclockTime;
    }
}
