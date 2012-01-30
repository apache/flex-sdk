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
package spark.components
{    
    
import flash.events.Event;
import flash.events.MouseEvent;

import mx.core.mx_internal;

import spark.components.supportClasses.ButtonBase;

use namespace mx_internal;
    
/**
 *  The caret state of the button representing the menu item.
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[SkinState("showsCaret")]

/**
 *  The ViewMenuItem control displays a label and icon 
 *  for a menu item in the ViewMenu container. 
 *  Write an event handler for the <code>click</code> event 
 *  to perform an operation when the menu item is selected.
 *
 *  <p>The following image shows a ViewMenu container with five 
 *  ViewMenuItem controls:</p>
 *
 * <p>
 *  <img src="../../images/vm_open_menu_vm.png" alt="View menu" />
 * </p>
 *  
 *  @mxml <p>The <code>&lt;s:ViewMenuItem&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:ViewMenuItem/&gt;
 *  </pre>
 *
 *  @see spark.components.ViewMenu
 *  @see spark.layouts.ViewMenuLayout
 *  @see spark.components.supportClasses.ViewNavigatorApplicationBase
 *  @see spark.skins.mobile.ViewMenuItemSkin
 *
 *  @includeExample examples/ViewMenuExampleHome.mxml -noswf
 *  @includeExample examples/ViewMenuExample.mxml -noswf
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */ 
public class ViewMenuItem extends ButtonBase
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    /**
     *  Constructor. 
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */ 
    public function ViewMenuItem()
    {
        super();
        skinDestructionPolicy = "auto";
    }
    
    //----------------------------------
    //  showsCaret
    //----------------------------------
    
    /**
     *  @private
     *  Storage for the showsCaret property 
     */
    private var _showsCaret:Boolean = false;
    
    /**
     *  Contains <code>true</code> if the ViewMenuItem control 
     *  is in the caret state. 
     *
     *  @default false  
     *
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */    
    public function get showsCaret():Boolean
    {
        return _showsCaret;
    }
    
    /**
     *  @private
     */    
    public function set showsCaret(value:Boolean):void
    {
        if (value == _showsCaret)
            return;
        
        _showsCaret = value;
        invalidateSkinState();
        invalidateDisplayList();
    }
    
    /**
     *  @private
     */
    override protected function getCurrentSkinState():String
    {
        var skinState:String = super.getCurrentSkinState();
        
        // showsCaret has lower priority than disabled and down states
        if (showsCaret && enabled && skinState != "down")
            return "showsCaret";
        
        return skinState;
    }

}
}