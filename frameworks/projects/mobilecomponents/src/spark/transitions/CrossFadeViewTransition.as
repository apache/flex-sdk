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

package spark.transitions
{
    
import flash.display.BlendMode;
import flash.geom.Point;

import mx.core.mx_internal;
import mx.effects.IEffect;

import spark.components.Group;
import spark.effects.Animate;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;

use namespace mx_internal;

/**
 *  The CrossFadeViewTransition class serves as a simple cross fade transition 
 *  for views.  
 *  It performs its transition by fading out the existing view to reveal
 *  the new view. 
 *  The cross fade transitions the control bar and view content as one item.  
 *
 *  <p><strong>Note:</strong>Create and configure view transitions in ActionScript;
 *  you cannot create them in MXML.</p>
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class CrossFadeViewTransition extends ViewTransitionBase
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function CrossFadeViewTransition()
    {
        super();
        
        // Defaut duration of 400 yields a smoother result.
        duration = 400;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private var transitionGroup:Group;
    
    /**
     *  @private
     */
    private var savedCacheAsBitmap:Boolean;
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function captureStartValues():void
    {
        // With the cross fade transition we always want to transition the
        // complete navigator.
        consolidatedTransition = true;
        
        super.captureStartValues();
        
        var oldVisibility:Boolean = endView.visible;
        endView.visible = false;
        cachedNavigator = getSnapshot(targetNavigator, 0, cachedNavigatorGlobalPosition);
        endView.visible = oldVisibility;
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function createConsolidatedEffect():IEffect
    {        
        // If we have no cachedNavigator then there is not much we can do.
        if (!cachedNavigator)
            return null;
        
        // Add a group to contain our snapshot view of the navigator while
        // we animate.
        transitionGroup = new Group();
        transitionGroup.includeInLayout=false;
        addComponentToContainer(transitionGroup, targetNavigator.skin);
        
        // Position our snapshot above endView.
        transitionGroup.x = 0; 
        transitionGroup.y = 0;
        
        cachedNavigator.includeInLayout = false;
        addCachedElementToGroup(transitionGroup, cachedNavigator, cachedNavigatorGlobalPosition);
        
        // Ensure that appropriate surfaces are cached and snapshots rendered.
        transitionGroup.validateNow();
        transitionGroup.cacheAsBitmap = true;
        
        if (targetNavigator.contentGroup)
        {
            savedCacheAsBitmap = targetNavigator.contentGroup.cacheAsBitmap;
            targetNavigator.contentGroup.cacheAsBitmap = true;
        }
        
        // We don't want to do the extra work involved with BlendMode.AUTO.
        transitionGroup.blendMode = BlendMode.NORMAL;
        
        // Ensure our snapshot is rendered.
        transitionGroup.validateNow();
        
        // Construction fade animation sequence.
        var animation:Animate = new Animate(transitionGroup);
        var vector:Vector.<MotionPath> = new Vector.<MotionPath>();
        vector.push(new SimpleMotionPath("alpha", 1, 0));
        animation.motionPaths = vector;
        animation.easer = easer;
        animation.duration = duration;
        
        return animation;
    }
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function cleanUp():void
    {
        if (transitionGroup)
            removeComponentFromContainer(transitionGroup, targetNavigator.skin);
        
        if (targetNavigator.contentGroup)
            targetNavigator.contentGroup.cacheAsBitmap = savedCacheAsBitmap;
        
        transitionGroup = null;
        cachedNavigator = null;
        
        super.cleanUp();
    }
    
}
}
