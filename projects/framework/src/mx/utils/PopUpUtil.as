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

package mx.utils
{
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.IFlexDisplayObject;
import mx.core.UIComponent;
import mx.managers.ISystemManager;

[ExcludeClass]

/**
 *  Helper functionality for working with pop-ups. 
 */
public class PopUpUtil
{
    
    /**
     *  Calculates the position for a pop-up in sanboxRoot coordinates (the pop-up coordinate space).
     * 
     *  @param component       The component that defines the component coordinate space.
     *  
     *  @param systemManager   The systemManager that defines the SandboxRoot.  Typically component.systemManager.
     * 
     *  @param popUpWidth      The width of the popup, in SandboxRoot coordinates (i.e. popUp.width).
     * 
     *  @param popUpHeight     The height of the popup, in SandboxRoot coordinates (i.e. popUp.height).
     * 
     *  @param verticalCenter  The desired distance from the center of the popUp to the top edge of the
     *                         component.  In component coordinates. For example, to center relative to the 
     *                         component, pass component.heihgt / 2.  To disable centering, pass NaN.
     * 
     *  @param popUpPosition   The position of the pop-up, specified in SandboxRoot coordinates (i.e. pupUp.x, popUp.y)
     * 
     *  @param regPoint        The position of the popUp, specified in the component's coordinate space.  This is ignored if 
     *                         popUpPosition is specified.
     * 
     *  @param ensureOnScreen  When true, will check against the visible screen of the application and adjust the position
     *                         if necessary. 
     *
     *  @return  The position of the pop-up in SandboxRoot coordinates.
     */
    public static function positionOverComponent(component:DisplayObject,
                                                 systemManager:ISystemManager, // The component's systemManager
                                                 popUpWidth:Number,            // in sandboxRoot coordinates
                                                 popUpHeight:Number,           // in sandboxRoot coordinates
                                                 verticalCenter:Number = NaN,  // in component coordinates, if NaN, it's ignored
                                                 popUpPosition:Point = null,   // in sandboxRoot coordinates, if specified, regPoint is ignored
                                                 regPoint:Point = null,        // in component coordinates, if not specified defaults to (0,0)
                                                 ensureOnScreen:Boolean = true):Point
    {
        // Original code:
        //        var toolTip:IToolTip = event.toolTip;
        //        
        //        // Calculate global position of label.
        //        var sm:ISystemManager = systemManager.topLevelSystemManager;
        //        var sbRoot:DisplayObject = sm.getSandboxRoot();
        //        var screen:Rectangle = sm.getVisibleApplicationRect(null, true);;
        //        var pt:Point = new Point(0, 0);
        //        pt = label.localToGlobal(pt);
        //        pt = sbRoot.globalToLocal(pt);
        //        
        //        toolTip.move(pt.x, pt.y + (height - toolTip.height) / 2);
        //        
        //        var screenRight:Number = screen.x + screen.width;
        //        pt.x = toolTip.x;
        //        pt.y = toolTip.y;
        //        pt = sbRoot.localToGlobal(pt);
        //        if (pt.x + toolTip.width > screenRight)
        //            toolTip.move(toolTip.x - (pt.x + toolTip.width - screenRight), toolTip.y);
        
        // Refactored for correctness when there's scale in play:
        
        //        var sm:ISystemManager = systemManager.topLevelSystemManager;
        //        var sbRoot:DisplayObject = sm.getSandboxRoot();
        //        
        //        // Calculate sbRoot position of label.
        //        var pt:Point = new Point(0, 0);
        //        pt = sbRoot.globalToLocal(localToGlobal(pt)); // point in sbRoot coordinates
        //
        //        // Screen in sbRoot cooridnates
        //        var screen:Rectangle = sm.getVisibleApplicationRect(null, true);
        //        var screenRight:Number = sbRoot.globalToLocal(screen.bottomRight).x; 
        //        
        //        // Height in sbRoot coordinates
        //        var h:Number = sbRoot.globalToLocal(localToGlobal(new Point(0, height))).y;
        //
        //        // Center vertically, make sure tooltip doesn't overlap right edge of the screen
        //        var x:Number = Math.min(pt.x, screenRight - toolTip.width);
        //        var y:Number = pt.y + (h - toolTip.height) / 2;
        //        toolTip.move(x, y);
        
        // Would translate to:
        
        //        var toolTip:IToolTip = event.toolTip;
        //        var pt:Point = PopUpUtil.positionOverComponent(DisplayObject(label),
        //                                                       systemManager,
        //                                                       toolTip.width, 
        //                                                       toolTip.height,
        //                                                       height / 2); 
        //        toolTip.move(pt.x, pt.y);
        
        
        var sm:ISystemManager = systemManager.topLevelSystemManager;
        var sbRoot:DisplayObject = sm.getSandboxRoot();
        
        // Find the position of the popup in sandboxRoot coordinates
        var x:Number = 0;
        var y:Number = 0;
        
        if (popUpPosition)
        {
            // Already in sandboxRoot coordinates
            x = popUpPosition.x;
            y = popUpPosition.y;
        }
        else
        {
            // If not specified, regPoint defaults to component's (0,0).
            if (!regPoint)
                regPoint = new Point(0, 0);
            
            // Convert to sandboxRoot coordinates
            var position:Point = sbRoot.globalToLocal(component.localToGlobal(regPoint));
            x = position.x;
            y = position.y;
        }
        
        // Do we need to center vertically?
        if (!isNaN(verticalCenter))
        {
            // verticalCenter is in component coordinates, convert to sandboxRoot
            var vc:Number = sbRoot.globalToLocal(component.localToGlobal(new Point(0, verticalCenter))).y;
            y = vc - popUpHeight / 2;
        }
        
        if (ensureOnScreen)
        {
            // Convert screen to sandboxRoot cooridnates
            var screen:Rectangle  = sm.getVisibleApplicationRect(null, true);
            var topLeft:Point     = sbRoot.globalToLocal(screen.topLeft);
            var bottomRight:Point = sbRoot.globalToLocal(screen.bottomRight); 
            
            // clamp position, don't round
            x = Math.max(topLeft.x, Math.min(bottomRight.x - popUpWidth, x));
            y = Math.max(topLeft.y, Math.min(bottomRight.y - popUpHeight, y));
        }
        
        return new Point(x, y);
    }
}
}

