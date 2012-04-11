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

package flash.fonts;

import junit.framework.TestCase;
import flash.swf.Tag;
import flash.swf.builder.tags.FontBuilder;

import java.awt.GraphicsEnvironment;

/**
 * A simple test to check that the FontManager is caching font loading and glyph generation by
 * checking that a second call takes less than 10% of the initial load time.
 *
 * @author Peter Farland
 */
public class FontCacheTest extends TestCase
{
    private String family;
    private FontManager fontManager;

    public FontCacheTest(String test)
    {
        super(test);
    }

    protected void setUp() throws Exception
    {
        fontManager = new JREFontManager();

        //Find a local font on the System...
        GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
        String[] allFonts = ge.getAvailableFontFamilyNames();

        //Choose a random font name
        int i = 0;
        while (family == null && i < allFonts.length)
        {
            int randomIndex = (int)Math.rint((allFonts.length - 1) * Math.random());
            family = allFonts[randomIndex];
            i++;
        }

        //Nullify JIT considerations by running a dummy test
        try
        {
            //FontBuilder fontBuilder = new FontBuilder(Tag.stagDefineFont2, fontManager, "Nothing", "", 0, true);
        }
        catch (Throwable t)
        {
        }
    }

    protected long time() throws Throwable
    {
        long start = System.currentTimeMillis();

        FontBuilder fontBuilder = new FontBuilder(Tag.stagDefineFont2, fontManager, "TemporaryFont", family, 0, true, false);
        fontBuilder.addCharset("1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcedefghijklmnopqrstuvwxyz".toCharArray());
        fontBuilder.build();

        return System.currentTimeMillis() - start;
    }

    protected void tearDown() throws Exception
    {
        fontManager = null;
        family = null;
    }


    public void testCache() throws Throwable
    {
        //Capture initial load time...
        long initialTime = time();

        //Test against second call... should be less than 10% of initial load time!
        long secondTime = time();

        assertFalse("FontCacheTest for " + family + " ran slower than 10% of initial load time! Initial time: " + initialTime + "ms, Second time: " + secondTime + "ms. Failed.",
                secondTime > (initialTime * 0.1));
    }

    protected void runTest() throws Throwable
    {
        setUp();

        testCache();

        tearDown();
    }

    public static void main(String[] args)
    {
        FontCacheTest test = new FontCacheTest("Font Cache Test");

        try
        {
            test.runTest();
        }
        catch (Throwable t)
        {
            t.printStackTrace();
        }
    }
}
