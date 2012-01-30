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

package spark.skins.mobile
{
    
/**
 *  Actionscript based skin for toggle buttons. This class can not be used 
 *  by itself. You must subclass and specify a 
 *  backgroundClass and selectedBackgroundClass
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */    
public class ToggleButtonSkinBase extends ButtonSkinBase
{
    public function ToggleButtonSkinBase()
    {
        super();
        gap = 15;
        paddingLeft = 15;
        paddingRight = 15;
        paddingTop = 15;
        paddingBottom = 15;
    }
    
    
    private var changeFXGSkin:Boolean = false;
    private var currentStateIconClass:Class;
    
    /**
     *  The Class used to create the icon in the up state
     */
    protected var upIconClass:Class;
    
    /**
     *  The Class used to create the icon in the selected up state 
     */
    protected var upSelectedIconClass:Class;
    
    /**
     *  The Class used to create the icon in the down state
     */
    protected var downIconClass:Class;
    
    /**
     *  The Class used to create the icon in the selected down state 
     */
    protected var downSelectedIconClass:Class;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private 
     */
    override protected function commitCurrentState():void
    {    
        super.commitCurrentState();
        
        // Check for selected or not selected
        if (currentState != null)
        {
            if (currentState == "up")
                currentStateIconClass = upIconClass;
            else if (currentState == "down")
                currentStateIconClass = downIconClass;
            else if (currentState == "upAndSelected")
                currentStateIconClass = upSelectedIconClass;
            else if (currentState == "downAndSelected")
                currentStateIconClass = downSelectedIconClass;
            else if (currentState.indexOf("AndSelected") != -1)
                currentStateIconClass = upSelectedIconClass;
            else
                currentStateIconClass = upIconClass;
                        
            if (!(iconDisplay is currentStateIconClass))
            {
                changeFXGSkin = true;
                invalidateProperties();
                invalidateSize();
                invalidateDisplayList();
            }
        }
    }
    
    /**
     *  @private 
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (changeFXGSkin)
        {
            changeFXGSkin = false;
            
            if (currentStateIconClass)
            {
                // Remove iconDisplay
                if (iconDisplay != null)
                    removeChild(iconDisplay);
                
                iconDisplay = new currentStateIconClass();  
                
                addChild(iconDisplay);
            }
        }
    }
    
    /**
     *  @private 
     */
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
        
        // TODO (jszeto) Does this need to go into a seperate DisplayObject to avoid it from getting 
        // clobbered by subclasses?
        // Draw a transparent hit area
        graphics.clear();
        graphics.beginFill(0,0);
        graphics.drawRect(0,0,unscaledWidth, unscaledHeight);
        graphics.endFill();
    }
    
    
    
}
}