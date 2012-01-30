////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.skins.mobile.supportClasses
{
import flash.display.DisplayObject;

/**
 *  ActionScript-based skin for toggle buttons. This class can not be used 
 *  by itself. You must subclass and specify a 
 *  backgroundClass and selectedBackgroundClass.
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5 
 *  @productversion Flex 4.5
 */    
public class SelectableButtonSkinBase extends ButtonSkinBase
{
    /* Define the symbol fill items that should be colored by the "symbolColor" style. */
    static private const symbols:Array = ["symbolIcon"];
    
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     * 
     */
    public function SelectableButtonSkinBase()
    {
        super();
        layoutGap = 15;
        layoutPaddingLeft = 15;
        layoutPaddingRight = 15;
        layoutPaddingTop = 15;
        layoutPaddingBottom = 15;
        
        // Instruct the super class to ignore the "icon" style.
        // Instead, we're going to use the protected members
        // (initialized in the sub-classes):
        // upIconClass, 
        // upSelectedIconClass, 
        // downIconClass,
        // downSelectedIconClass
        useIconStyle = false;
        useSymbolColor = true;
        useCenterAlignment = false;
    }
    
    /**
     *  The class used to create the icon in the up state.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected var upIconClass:Class;
    
    /**
     *  The class used to create the icon in the selected upSelected state .
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected var upSelectedIconClass:Class;
    
    /**
     *  The class used to create the icon in the down state.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected var downIconClass:Class;
    
    /**
     *  The class used to create the icon in the selected downSelected state .
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected var downSelectedIconClass:Class;
    
    /**
     *  The class used to create the symbol icon in all deselected states .
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected var upSymbolIconClass:Class;
    
    /**
     *  The class used to create the selected symbol icon in all selected states.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected var upSymbolIconSelectedClass:Class;
    
    /**
     *  The class used to create the symbol icon in all deselected states. 
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected var downSymbolIconClass:Class;
    
    /**
     *  The class used to create the selected symbol icon in all selected states. 
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected var downSymbolIconSelectedClass:Class;
    
    /**
     *  Optional symbol to display selection state. 
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    private var _symbolIcon:DisplayObject;
    
    /**
     *  Read-only button symbol graphic. Use commitCurrentState() to specify
     *  a symbol graphic per-state.
     * 
     *  @see #commitCurrentState()
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    public function get symbolIcon():DisplayObject
    {
        return _symbolIcon;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();
    }
    
    /**
     *  @private
     */
    override protected function get symbolItems():Array
    {
        return symbols;
    }
    
    /**
     *  @private 
     */
    override protected function commitCurrentState():void
    {    
        super.commitCurrentState();
        
        // check for selected or not selected
        if (currentState != null)
        {
            // if (currentState == "up" || currentState == "disabled")
            var currentStateIconClass:Class = upIconClass;
            var currentSymbolClass:Class = upSymbolIconClass;
            var isSelected:Boolean = false;
            
            if (currentState == "down")
            {
                currentStateIconClass = downIconClass;
                currentSymbolClass = downSymbolIconClass;
            }
            else if ((currentState == "upAndSelected")
                || (currentState == "disabledAndSelected"))
            {
                currentStateIconClass = upSelectedIconClass;
                currentSymbolClass = upSymbolIconSelectedClass;
                isSelected = true;
            }
            else if (currentState == "downAndSelected")
            {
                currentStateIconClass = downSelectedIconClass;
                currentSymbolClass = downSymbolIconSelectedClass;
                isSelected = true;
            }
            
            setIcon(currentStateIconClass);
            
            // swap symbol based on selection state
            var hasSymbol:Boolean = (_symbolIcon) && contains(_symbolIcon);
            
            // remove the old symbol
            if (hasSymbol)
            {
                // no current symbol exists
                // or is existing symbol different than the current symbol
                if ((currentSymbolClass == null)
                    || !(_symbolIcon is currentSymbolClass))
                {
                    removeChild(_symbolIcon);
                    _symbolIcon = null;
                    
                    invalidateDisplayList();
                }
            }
            
            // add the current symbol
            if ((_symbolIcon == null) && (currentSymbolClass != null))
            {
                var currentSymbolInstance:Object = new currentSymbolClass();
                
                if (currentSymbolInstance is DisplayObject)
                {
                    _symbolIcon = DisplayObject(currentSymbolInstance);
                    addChild(_symbolIcon);
                    
                    invalidateDisplayList();
                }
            }
        }
    }
    
    /**
     *  @private 
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
        
        // position the symbols to align with the background "icon"
        if (_symbolIcon)
        {
            var currentIcon:DisplayObject = getIconDisplay();
            setElementPosition(_symbolIcon, currentIcon.x, currentIcon.y);
        }
    }
    
    /**
     *  @private 
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.drawBackground(unscaledWidth, unscaledHeight);
        
        // Draw a transparent hit area
        graphics.beginFill(0, 0);
        graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
        graphics.endFill();
    }
}
}