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
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.styles.StyleManager;

import spark.components.DataGroup;
import spark.components.Group;
import spark.components.IItemRenderer;
import spark.components.DataRenderer; 
import spark.components.supportClasses.TextBase;

use namespace mx_internal; 

/**
 *  The ItemRenderer class is the base class for Spark item renderers.
 * 
 *  @mxml
 *
 *  <p>The <code>&lt;s:ItemRenderer&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;s:ItemRenderer
 *    <strong>Properties</strong>
 *    selected="false"
 *    showsCaret="false"
 *  /&gt;
 *  </pre>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ItemRenderer extends DataRenderer implements IItemRenderer
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
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function ItemRenderer()
    {
        super();
        
        // Initially state is dirty
        rendererStateIsDirty = true;
        
        addHandlers();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Style-driven properties
    //
    //--------------------------------------------------------------------------
    
    [Bindable("contentBackgroundColorChanged")]
    [Bindable("dataChange")]
    /**
     *  Color of the fill of an item renderer
     *   
     *  @default 0xFFFFFF
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */ 
    public function get contentBackgroundColor():uint
    {
        var alternatingColors:Array = getStyle("alternatingItemColors");
        
        if (alternatingColors && alternatingColors.length > 0)
        {
            var idx:int;
            
            // translate these colors into uints
            styleManager.getColorNames(alternatingColors);
            
            if (parent is GroupBase)
                idx = GroupBase(parent).getElementIndex(this);
            else
                idx = parent.getChildIndex(this);
             
            return alternatingColors[idx % alternatingColors.length];
        }
        
        return getStyle("contentBackgroundColor");
    }
    
    /**
     *  @private
     */
    public function set contentBackgroundColor(value:uint):void
    {
        setStyle("contentBackgroundColor", value);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Flag that is set when the mouse is hovered over the item renderer.
     */
    private var hovered:Boolean = false;
    
    /**
     *  @private
     *  Whether the renderer's state is invalid or not.
     */
    private var rendererStateIsDirty:Boolean = false;
    
    /**
     *  @private
     *  A flag determining if this renderer should play any 
     *  associated transitions when a state change occurs. 
     */
    mx_internal var playTransitions:Boolean = true; 
    
    //--------------------------------------------------------------------------
    //
    //  Public Properties 
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  labelDisplay
    //----------------------------------
    
    /**
     *  Optional item renderer label component. 
     *  This component is used to determine the value of the 
     *  <code>baselinePosition</code> property in the host component of 
     *  the item renderer. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var labelDisplay:TextBase;
    
    //----------------------------------
    //  showsCaret
    //----------------------------------

    /**
     *  @private
     *  Storage for the showsCaret property 
     */
    private var _showsCaret:Boolean = false;

    /**
     *  @inheritDoc 
     *
     *  @default false  
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
        setCurrentState(getCurrentRendererState(), playTransitions);  
    }
    
    //----------------------------------
    //  selected
    //----------------------------------
    /**
     *  @private
     *  storage for the selected property 
     */    
    private var _selected:Boolean = false;
    
    /**
     *  @inheritDoc 
     *
     *  @default false
     */    
    public function get selected():Boolean
    {
        return _selected;
    }
    
    /**
     *  @private
     */    
    public function set selected(value:Boolean):void
    {
        if (value != _selected)
        {
            _selected = value;
            setCurrentState(getCurrentRendererState(), playTransitions); 
        }
    }
       
    //----------------------------------
    //  label
    //----------------------------------
    [Bindable("textChanged")]
    
    /**
     *  @private 
     *  Storage var for label
     */ 
    private var _label:String = "";
    
    /**
     *  @inheritDoc 
     *
     *  @default ""    
     */
    public function get label():String
    {
        return _label;
    }
    
    /**
     *  @private
     */ 
    public function set label(value:String):void
    {
        if (value != _label)
            _label = value;
            
        //Push the label down into the labelDisplay,
        //if it exists
        if (labelDisplay)
            labelDisplay.text = _label; 
            
        dispatchEvent(new FlexEvent("textChanged"));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Properties - UIComponent 
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
        if (!validateBaselinePosition() || !labelDisplay)
            return super.baselinePosition;

        var labelPosition:Point = globalToLocal(labelDisplay.parent.localToGlobal(
            new Point(labelDisplay.x, labelDisplay.y)));
            
        return labelPosition.y + labelDisplay.baselinePosition;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods - ItemRenderer State Support 
    //
    //--------------------------------------------------------------------------
    /**
     *  Returns the name of the state to be applied to the renderer. For example, a
     *  very basic List item renderer would return the String "normal", "hovered", 
     *  or "selected" to specify the renderer's state. 
     * 
     *  <p>A subclass of ItemRenderer must override this method to return a value 
     *  if the behavior desired differs from the default behavior.</p>
     * 
     *  @return A String specifying the name of the state to apply to the renderer. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    protected function getCurrentRendererState():String
    {
        if (selected && showsCaret && hasState("selectedAndShowsCaret"))
           return "selectedAndShowsCaret";
            
        if (hovered && showsCaret && hasState("hoveredAndShowsCaret"))
            return "hoveredAndShowsCaret";
             
        if (showsCaret && hasState("normalAndShowsCaret"))
            return "normalAndShowsCaret"; 
            
        if (selected && hasState("selected"))
            return "selected";
        
        if (hovered && hasState("hovered"))
            return "hovered";
        
        if (hasState("normal"))    
            return "normal";
        
        //If none of the above states are defined in the item renderer,
        //we return the empty string. This means the user-defined renderer
        //will display but essentially be non-interactive visually. 
        return null;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */ 
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (rendererStateIsDirty)
        {
            setCurrentState(getCurrentRendererState(), playTransitions); 
            rendererStateIsDirty = false;
        }
    }
    
    /**
     *  @private
     */ 
    override public function styleChanged(styleName:String):void
    {
        var allStyles:Boolean = styleName == null || styleName == "styleName";
        
        super.styleChanged(styleName);
        
        if (allStyles || styleName == "alternatingItemColors")
        {
            conditionalEventDispatch("contentBackgroundColorChanged");
        }
        
        if (allStyles || styleName == "contentBackgroundColor")
        {
            conditionalEventDispatch("contentBackgroundColorChanged");
        }
        
        if (allStyles || styleName == "rollOverColor")
        {
            conditionalEventDispatch("rollOverColorChanged");
        }
        
        if (allStyles || styleName == "selectionColor")
        {
            conditionalEventDispatch("selectionColorChanged");
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Attach the mouse events.
     */
    private function addHandlers():void
    {
        addEventListener(MouseEvent.ROLL_OVER, itemRenderer_rollOverHandler);
        addEventListener(MouseEvent.ROLL_OUT, itemRenderer_rollOutHandler);
    }
    
    /**
     *  @private
     */
    private function conditionalEventDispatch(eventName:String):void
    {
        if (hasEventListener(eventName))
           dispatchEvent(new Event(eventName));
    }
    
    private function anyButtonDown(event:MouseEvent):Boolean
    {
        var type:String = event.type;
        return event.buttonDown || (type == "middleMouseDown") || (type == "rightMouseDown"); 
    }
    
    /**
     *  @private
     *  Mouse rollOver event handler.
     */
    protected function itemRenderer_rollOverHandler(event:MouseEvent):void
    {
        if (!anyButtonDown(event))
        {
            hovered = true;
            setCurrentState(getCurrentRendererState(), playTransitions); 
        }
    }
    
    /**
     *  @private
     *  Mouse rollOut event handler.
     */
    protected function itemRenderer_rollOutHandler(event:MouseEvent):void
    {
        hovered = false;
        setCurrentState(getCurrentRendererState(), playTransitions); 
    }

}
}