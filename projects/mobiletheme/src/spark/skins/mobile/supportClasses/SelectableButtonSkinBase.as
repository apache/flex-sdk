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
import flash.display.Graphics;
    
/**
 *  Actionscript based skin for toggle buttons. This class can not be used 
 *  by itself. You must subclass and specify a 
 *  backgroundClass and selectedBackgroundClass
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
        useChromeColor = true;
        useSymbolColor = true;
    }
    
    /**
     *  The Class used to create the icon in the up state
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected var upIconClass:Class;
    
    /**
     *  The Class used to create the icon in the selected up state 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected var upSelectedIconClass:Class;
    
    /**
     *  The Class used to create the icon in the down state
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected var downIconClass:Class;
    
    /**
     *  The Class used to create the icon in the selected down state 
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected var downSelectedIconClass:Class;
    
    /**
     *  The Class used to create the symbol icon in all selected states 
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    protected var symbolIconClass:Class;
    
    /**
     *  Optional symbol to display selection state 
     *
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5 
     *  @productversion Flex 4.5
     */
    public var symbolIcon:Object;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    override protected function createChildren():void
    {
        super.createChildren();
    }
    
    override public function get symbolItems():Array
    {
        return symbols;
    }
    
    /**
     *  @private 
     */
    override protected function commitCurrentState():void
    {    
        super.commitCurrentState();
        
        // Check for selected or not selected
        if (currentState != null)
        {
            var currentStateIconClass:Class = upIconClass;
            var isSelected:Boolean = false;
            
            if (currentState == "down")
            {
                currentStateIconClass = downIconClass;
            }
            else if (currentState == "upAndSelected")
            {
                currentStateIconClass = upSelectedIconClass;
                isSelected = true;
            }
            else if (currentState == "downAndSelected")
            {
                currentStateIconClass = downSelectedIconClass;
                isSelected = true;
            }
            else if (currentState.indexOf("AndSelected") != -1)
            {
                currentStateIconClass = upSelectedIconClass;
                isSelected = true;
            }
            
            setIcon(currentStateIconClass);
            
            // swap symbol based on selection state
            var symbolObj:DisplayObject = (symbolIcon && (symbolIcon is DisplayObject))
                ? DisplayObject(symbolIcon) : null;
            var hasSymbol:Boolean = (symbolObj) && contains(symbolObj);
            
            if (hasSymbol && !isSelected)
            {
                removeChild(DisplayObject(symbolObj));
                invalidateDisplayList();
            }
            else if (!hasSymbol && isSelected)
            {
                symbolIcon = new symbolIconClass();
                
                addChild(DisplayObject(symbolIcon));
                invalidateDisplayList();
            }
        }
    }

    /**
     *  @private 
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        graphics.clear();
        
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        // TODO (jszeto) Does this need to go into a seperate DisplayObject to avoid it from getting 
        // clobbered by subclasses?
        
        // Draw a transparent hit area
        graphics.beginFill(0,0);
        graphics.drawRect(0,0,unscaledWidth, unscaledHeight);
        graphics.endFill();
        
        // position the symbols to align with the background "icon"
        if (symbolIcon)
        {
            var currentIcon:DisplayObject = getIconDisplay();
            positionElement(symbolIcon, currentIcon.x, currentIcon.y);
        }
    }
}
}