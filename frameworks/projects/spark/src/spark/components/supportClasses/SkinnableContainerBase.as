////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{
    
import flash.display.DisplayObject;

import mx.core.ContainerGlobals;
import mx.core.IFlexDisplayObject;
import mx.managers.IFocusManagerContainer;

/**
 *  Normal State
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("normal")]

/**
 *  Disabled State
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[SkinState("disabled")]

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="focusThickness", kind="style")]

/**
 *  Base class for skinnable container components.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class SkinnableContainerBase extends SkinnableComponent implements IFocusManagerContainer
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function SkinnableContainerBase()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  defaultButton
    //----------------------------------

    /**
     *  @private
     *  Storage for the defaultButton property.
     */
    private var _defaultButton:IFlexDisplayObject;

    [Inspectable(category="General")]

    /**
     *  The Button control designated as the default button for the container.
     *  When controls in the container have focus, pressing the
     *  Enter key is the same as clicking this Button control.
     *
     *  @default null
     */
    public function get defaultButton():IFlexDisplayObject
    {
        return _defaultButton;
    }

    /**
     *  @private
     */
    public function set defaultButton(value:IFlexDisplayObject):void
    {
        _defaultButton = value;
        ContainerGlobals.focusedContainer = null;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
 
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    override protected function getCurrentSkinState():String
    {
        return enabled ? "normal" : "disabled";
    }
}
}