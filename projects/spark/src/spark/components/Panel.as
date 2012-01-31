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

package spark.components
{

import spark.primitives.supportClasses.TextGraphicElement;

[IconFile("Panel.png")]

/**
 *  The Panel class is container whose skin usually contains a title.
 *
 *  @includeExample examples/PanelExample.mxml
 *
 *  @see SkinnableContainer
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Panel extends SkinnableContainer
{
    include "../core/Version.as";

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
    public function Panel()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  middleButton
    //---------------------------------- 
    
    [SkinPart(required="true")]

    /**
     * A skin part that defines the middle button(s).
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var titleField:TextGraphicElement;

    //----------------------------------
    //  title
    //----------------------------------

    private var titleChanged:Boolean;

    private var _title:String = "";
    
	[Bindable]
    /**
     *  title that should appear in the header of the skin
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get title():String 
    {
        return _title;
    }

    /**
     *  @private
     */
    public function set title(value:String):void 
    {
        _title = value;

		if (titleField)
			titleField.text = title;
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden properties: UIComponent
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  baselinePosition
    //----------------------------------

    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
        return getBaselinePositionForPart(titleField);
    } 
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == titleField)
        {
            titleField.text = title;
        }
    }
}

}
