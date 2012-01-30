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
    }
    
    
    private var changeFXGSkin:Boolean = false;
    private var currentStateIconClass:Class;
    
    /**
     *  The Class used to create the icon in the unselected state
     */
    protected var backgroundClass:Class;
    
    /**
     *  The Class used to create the icon in the selected state 
     */
    protected var selectedBackgroundClass:Class;
    
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
        // Check for selected or not selected
        if (currentState != null)
        {
            changeFXGSkin = true;
            invalidateProperties();
            invalidateSize();
            invalidateDisplayList();
        }
    }
    
    /**
     *  @private 
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        // TODO (jszeto) needs optimization
        if (changeFXGSkin)
        {
            changeFXGSkin = false;
            
            // Remove iconDisplay
            if (iconDisplay != null && iconDisplay.parent != null)
                removeChild(iconDisplay);
            
            // TODO (jszeto) add null checks for the backgroundClasses
            if (currentState.indexOf("AndSelected") != -1)
            {
                iconDisplay = new selectedBackgroundClass();  
            }
            else
            {
                iconDisplay = new backgroundClass();   
            }
            
            addChild(iconDisplay);
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
        
		// Force strokes to be aligned on the pixel boundries.
		iconDisplay.x += .5;
		iconDisplay.y += .5;
    }
    
    
    
}
}