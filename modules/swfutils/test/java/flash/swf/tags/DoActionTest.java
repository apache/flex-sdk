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

import flash.swf.ActionFactory;
import flash.swf.actions.Branch;
import flash.swf.actions.Push;
import flash.swf.types.ActionList;
import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

/**
 * @author Paul Reilly
 */
public class DoActionTest extends TestCase
{
    public DoActionTest()
    {
        super("DoActionTest");
    }

    public static Test suite()
    {
        return new TestSuite(DoActionTest.class);
    }

    public void testEqualsPositive()
    {
        DoAction doAction1 = new DoAction(new ActionList());
        doAction1.actionList.insert(0, new Branch(Branch.sactionJump));
        DoAction doAction2 = new DoAction(new ActionList());
        doAction2.actionList.insert(0, new Branch(Branch.sactionJump));
        assertEquals("doAction1 should be equal to doAction2",
                     doAction1, doAction2);
    }

    public void testEqualsNegative()
    {
        DoAction doAction1 = new DoAction(new ActionList());
        doAction1.actionList.insert(0, new Branch(Branch.sactionJump));
        DoAction doAction2 = new DoAction(new ActionList());
        doAction2.actionList.insert(0, new Push(ActionFactory.UNDEFINED));
        assertFalse("doAction1 should not be equal to doAction2",
                    doAction1.equals(doAction2));
    }

    public void testHashCodePositive()
    {
        DoAction doAction1 = new DoAction(new ActionList());
        DoAction doAction2 = new DoAction(new ActionList());
        assertEquals("the two hash codes should be equal",
                     doAction1.hashCode(), doAction2.hashCode());
    }

    public void testHashCodeNegative()
    {
        DoAction doAction = new DoAction(new ActionList());
        DoInitAction doInitAction = new DoInitAction();
        assertFalse("the two hash codes should not be equal",
                    doAction.hashCode() == doInitAction.hashCode());
    }

    public static void main(String args[])
    {
        DoActionTest doActionTest = new DoActionTest();

        doActionTest.testEqualsPositive();
        doActionTest.testEqualsNegative();
        doActionTest.testHashCodePositive();
        doActionTest.testHashCodeNegative();
    }
}
