////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package mx.automation
{
import flash.display.DisplayObject;

/**
 * The IAutomationMouseSimulator interface describes an object 
 * that simulates mouse movement so that components
 * capturing the mouse use the simulated versions of the mouse
 * cursor instead of the live Flash Player version. Implementors of
 * the IUIComponent interface should override the 
 * <code>mouseX</code> and <code>mouseY</code> properties and
 * call the active simulator's version if a simulator is present.
 *
 *  @see mx.core.IUIComponent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IAutomationMouseSimulator
{
    /**
     *  Called when a DisplayObject retrieves the <code>mouseX</code> property.
     *
     *  @param item DisplayObject that simulates mouse movement.
     *
     *  @return The x coordinate of the mouse position relative to item.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getMouseX(item:DisplayObject):Number;

    /**
     *  Called when a DisplayObject retrieves <code>mouseY</code> property.
     *
     *  @param item DisplayObject that simulates mouse movement.
     *
     *  @return The y coordinate of the mouse position relative to item.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function getMouseY(item:DisplayObject):Number;
}

}
