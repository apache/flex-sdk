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

package flash.swf.tags;

import flash.swf.tags.DefineText;
import junit.framework.TestCase;
import junit.framework.Test;
import junit.framework.TestSuite;

/**
 * @author Paul Reilly
 */
public class DefineTextTest extends TestCase
{
    public DefineTextTest()
    {
        super("DefineTextTest");
    }

    public static Test suite()
    {
        return new TestSuite(DefineTextTest.class);
    }

    public void testEqualsPositive()
    {
        DefineText defineText1 = new DefineText(DefineText.stagDefineText2);
        DefineText defineText2 = new DefineText(DefineText.stagDefineText2);
        assertEquals("defineText1 should be equal to defineText2",
                     defineText1, defineText2);
    }

    public void testEqualsNegative()
    {
        DefineText defineText1 = new DefineText(DefineText.stagDefineText);
        DefineText defineText2 = new DefineText(DefineText.stagDefineText2);
        assertFalse("defineText1 should not be equal to defineText2",
                    defineText1.equals(defineText2));
    }

    public void testHashCodePositive()
    {
        DefineText defineText1 = new DefineText(DefineText.stagDefineText2);
        DefineText defineText2 = new DefineText(DefineText.stagDefineText2);        
        assertEquals("the two hash codes should be equal",
                     defineText1.hashCode(), defineText2.hashCode());
    }

    public void testHashCodeNegative()
    {
        DefineText defineText1 = new DefineText(DefineText.stagDefineText);
        DefineText defineText2 = new DefineText(DefineText.stagDefineText2);        
        assertFalse("the two hash codes should not be equal",
                    defineText1.hashCode() == defineText2.hashCode());
    }

    public static void main(String args[])
    {
        DefineTextTest defineTextTest = new DefineTextTest();

        defineTextTest.testEqualsPositive();
        defineTextTest.testEqualsNegative();
        defineTextTest.testHashCodePositive();
        defineTextTest.testHashCodeNegative();
    }
}
