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

package mx.components
{
import mx.graphics.graphicsClasses.TextGraphicElement;

[IconFile("FxPanel.png")]

/**
 *  The FxPanel class is container whose skin usually contains a title
 *
 *  @see FxContainer
 */
public class FxPanel extends FxContainer 
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor. 
     */
    public function FxPanel()
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
    
    [SkinPart]
    /**
     * A skin part that defines the middle button(s).
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

    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == titleField)
        {
            titleField.text = title;
            
            // TODO: Remove this hard-coded styleName assignment
            // once all global text styles are moved to the global
            // stylesheet. This is a temporary workaround to support
            // inline text styles for Buttons and subclasses.
            titleField.styleName = this;
        }
    }

}

}
