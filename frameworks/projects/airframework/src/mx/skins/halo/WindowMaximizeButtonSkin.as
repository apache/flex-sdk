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

package mx.skins.halo
{

import flash.system.Capabilities;
import mx.controls.Image;
import mx.core.UIComponent;
import mx.states.SetProperty;
import mx.states.State;
import mx.utils.Platform;

/**
 *  The skin for the maximize button in the TitleBar
 *  of a WindowedApplication or Window.
 * 
 *  
 *  @langversion 3.0
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class WindowMaximizeButtonSkin extends UIComponent
{
    include "../../core/Version.as";    
    
    //--------------------------------------------------------------------------
    //
    //  Class assets
    //
    //--------------------------------------------------------------------------

    [Embed(source="../../../../assets/mac_max_up.png")]
    private static var macMaxUpSkin:Class;

    [Embed(source="../../../../assets/win_max_up.png")]
    private static var winMaxUpSkin:Class;
       
    [Embed(source="../../../../assets/mac_max_over.png")]
    private static var macMaxOverSkin:Class;
    
    [Embed(source="../../../../assets/win_max_over.png")]
    private static var winMaxOverSkin:Class;

    [Embed(source="../../../../assets/mac_max_down.png")]
    private static var macMaxDownSkin:Class;

    [Embed(source="../../../../assets/win_max_down.png")]
    private static var winMaxDownSkin:Class;
    
    [Embed(source="../../../../assets/mac_max_dis.png")]
    private static var macMaxDisabledSkin:Class;

    [Embed(source="../../../../assets/win_max_dis.png")]
    private static var winMaxDisabledSkin:Class;
    
    [Embed(source="../../../../assets/win_restore_up.png")]
    private static var winRestoreUpSkin:Class;
    
    [Embed(source="../../../../assets/win_restore_down.png")]
    private static var winRestoreDownSkin:Class;
    
    [Embed(source="../../../../assets/win_restore_over.png")]
    private static var winRestoreOverSkin:Class;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function WindowMaximizeButtonSkin()
    {
        super();

        isMac = Platform.isMac;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var isMac:Boolean;
    
    /**
     *  @private
     */
    private var skinImage:Image;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  measuredHeight
    //----------------------------------

    /**
     *  @private
     */
    override public function get measuredHeight():Number
    {
        if (skinImage.measuredHeight)
            return skinImage.measuredHeight;
        else
            return 13;
    }

    //----------------------------------
    //  measuredWidth
    //----------------------------------

    /**
     *  @private
     */
    override public function get measuredWidth():Number
    {
        if (skinImage.measuredWidth)
            return skinImage.measuredWidth;
        else
            return 12;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: UIComponent
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function createChildren():void
    {
        skinImage = new Image();
        addChild(skinImage);

        initializeStates();

        skinImage.setActualSize(12, 13);
        skinImage.move(0, 0);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    private function initializeStates():void
    {
        var upState:State = new State();
        upState.name = "up";
        var upProp:SetProperty = new SetProperty();
        upProp.name = "source";
        upProp.target = skinImage;
        upProp.value = isMac ? macMaxUpSkin : winMaxUpSkin;
        upState.overrides.push(upProp);
        states.push(upState);
        
        var downState:State = new State();
        downState.name = "down";
        var downProp:SetProperty = new SetProperty();
        downProp.name = "source";
        downProp.target = skinImage;
        downProp.value = isMac ? macMaxDownSkin : winMaxDownSkin;
        downState.overrides.push(downProp);
        states.push(downState);
        
        var overState:State = new State();
        overState.name = "over";
        var overProp:SetProperty = new SetProperty();
        overProp.name = "source";
        overProp.target = skinImage;
        overProp.value = isMac ? macMaxOverSkin : winMaxOverSkin;
        overState.overrides.push(overProp);
        states.push(overState);
        
        var disabledState:State = new State();
        disabledState.name = "disabled";
        var disabledProp:SetProperty = new SetProperty();
        disabledProp.name = "source";
        disabledProp.target = skinImage;
        disabledProp.value = isMac ? macMaxDisabledSkin : winMaxDisabledSkin;
        disabledState.overrides.push(disabledProp);
        states.push(disabledState);
    }
}

}
