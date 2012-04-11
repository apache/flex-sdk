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

package flash.swf.types;

import flash.swf.types.GlyphEntry;
import junit.framework.TestCase;
import junit.framework.Test;
import junit.framework.TestSuite;

/**
 * @author Paul Reilly
 */
public class GlyphEntryTest extends TestCase
{
    public GlyphEntryTest()
    {
        super("GlyphEntryTest");
    }

    public static Test suite()
    {
        return new TestSuite(GlyphEntryTest.class);
    }

    public void testClonePositive()
    {
        GlyphEntry glyphEntry1 = new GlyphEntry();
        glyphEntry1.setIndex(1);
        glyphEntry1.advance = 1;

        GlyphEntry glyphEntry2 = (GlyphEntry) glyphEntry1.clone();

        assertEquals("glyphEntry1 should be equal to glyphEntry2",
                     glyphEntry1, glyphEntry2);
    }

    public void testEqualsPositive()
    {
        GlyphEntry glyphEntry1 = new GlyphEntry();
        glyphEntry1.setIndex(1);
        glyphEntry1.advance = 1;

        GlyphEntry glyphEntry2 = new GlyphEntry();
        glyphEntry2.setIndex(1);
        glyphEntry2.advance = 1;

        assertEquals("glyphEntry1 should be equal to glyphEntry2",
                     glyphEntry1, glyphEntry2);
    }

    public void testEqualsNegative()
    {
        GlyphEntry glyphEntry1 = new GlyphEntry();
        glyphEntry1.setIndex(1);
        glyphEntry1.advance = 1;

        GlyphEntry glyphEntry2 = new GlyphEntry();
        glyphEntry2.setIndex(2);
        glyphEntry2.advance = 2;
        assertFalse("glyphEntry1 should not be equal to glyphEntry2",
                    glyphEntry1.equals(glyphEntry2));
    }

    public static void main(String args[])
    {
        GlyphEntryTest glyphEntryTest = new GlyphEntryTest();

        glyphEntryTest.testClonePositive();
        glyphEntryTest.testEqualsPositive();
        glyphEntryTest.testEqualsNegative();
    }
}
