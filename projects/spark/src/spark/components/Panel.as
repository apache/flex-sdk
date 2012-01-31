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
 *  The Panel class defines a container that includes a title bar, 
 *  a caption, a border, and a content area for its children.
 *
 *  @mxml
 *  
 *  <p>The <code>&lt;mx:Panel&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;s:Panel
 *   <strong>Properties</strong>
 *   title=""
 *   &gt;
 *      ...
 *      <i>child tags</i>
 *      ...
 *  &lt;/mx:Panel&gt;
 *  </pre>
 *
 *  @includeExample examples/PanelExample.mxml
 *
 *  @see SkinnableContainer
 *  @see spark.skins.spark.PanelSkin
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
    //  titleField
    //---------------------------------- 
    
    [SkinPart(required="false")]

    /**
     *  The skin part that defines the appearance of the 
     *  title text in the container.
     *
     *  @see spark.skins.spark.PanelSkin
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var titleDisplay:TextGraphicElement;

    //----------------------------------
    //  title
    //----------------------------------

    private var titleChanged:Boolean;

    private var _title:String = "";
    
    [Bindable]
    /**
     *  Title or caption displayed in the title bar. 
     *
     *  @default ""
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

        if (titleDisplay)
            titleDisplay.text = title;
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
        return getBaselinePositionForPart(titleDisplay);
    } 
    
    /**
     *  @private
     */
    override protected function partAdded(partName:String, instance:Object):void
    {
        super.partAdded(partName, instance);
        
        if (instance == titleDisplay)
        {
            titleDisplay.text = title;
        }
    }
}

}
