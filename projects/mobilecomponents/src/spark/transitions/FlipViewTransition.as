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
    
import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.geom.PerspectiveProjection;
import flash.geom.Point;

import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.effects.IEffect;
import mx.effects.Parallel;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.managers.SystemManager;

import spark.components.Group;
import spark.components.TabbedViewNavigator;
import spark.components.ViewNavigator;
import spark.components.supportClasses.ButtonBarBase;
import spark.effects.*;
import spark.effects.animation.Keyframe;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.primitives.BitmapImage;

use namespace mx_internal;

/**
 *  The FlipViewTransition class serves as a simple flip transition for 
 *  views.  The flip transition supports two modes (card and cube)
 *  as well as an optional direction (up, down, left, or right).
 * 
 *  The default duration of a FlipViewTransition is 400 ms.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class FlipViewTransition extends ViewTransitionBase
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
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function FlipViewTransition()
    {
        super();
        
        // Defaut duration of 450 yields a smoother result.
        duration = 450;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Property bag used to save any start view properties that 
     *  are then restored after the transition is complete.
     */
    private var startViewProps:Object = {};
    
    /**
     *  @private
     *  Property bag used to save any end view properties that 
     *  are then restored after the transition is complete.
     */
    private var endViewProps:Object = {};
    
    /**
     *  @private
     *  Property bag used to save any navigator centric properties that 
     *  are then restored after the transition is complete.
     */
    private var navigatorProps:Object = {};
    
    /**
     *  @private
     *  Parents our start and end view elements while flipping.
     */
    private var transitionGroup:Group;
    
    /**
     *  @private
     *  Flag to denote if we're flipping vertically or horizontally.
     */
    private var vertical:Boolean;
    
    /**
     *  @private
     *  Used to save off our pending view's transform matrix while we animate.
     */
    private var savedStartMatrix:Matrix3D;
    
    /**
     *  @private
     *  Used to save off our pending view's transform matrix while we animate.
     */
    private var savedEndMatrix:Matrix3D;
    
    /**
     *  @private
     */
    private var viewWidth:Number;
    
    /**
     *  @private
     */
    private var viewHeight:Number;
        
    /**
     *  @private
     */
    private var directionModifier:int;
    
    /**
     *  @private
     */
    private var animatedProperty:String;
    
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //---------------------------------
    // direction
    //---------------------------------
    
    private var _direction:String = ViewTransitionDirection.LEFT;
    
    /**
     *  Specifies the direction of flip transition.
     *
     *  @default ViewTransitionDirection.LEFT
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get direction():String
    {
        return _direction;
    }
    
    /**
     *  @private
     */ 
    public function set direction(value:String):void
    {
        _direction = value;
    }
    
    //---------------------------------
    // mode
    //---------------------------------
    
    private var _mode:String = FlipViewTransitionMode.CARD;
    
    /**
     *  Specifies the type of flip transition to perform.
     *
     *  @default FlipViewTransitionMode.CARD
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get mode():String
    {
        return _mode;
    }
    
    /**
     *  @private
     */ 
    public function set mode(value:String):void
    {
        _mode = value;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function captureStartValues():void
    {
        super.captureStartValues();
        
        // Initialize the property bag used to save some of our
        // properties that are then restored after the transition is over.
        navigatorProps = new Object(); 
        
        // Snapshot the entire navigator.
        var oldVisibility:Boolean = endView.visible;
        endView.visible = false;
        cachedNavigator = getSnapshot(targetNavigator, 0);
        endView.visible = oldVisibility;
    }
            
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function createViewEffect():IEffect
    {   
        // Don't bother transitioning if we're missing views.
        if (!startView || !endView)
            return null;

        return (mode == FlipViewTransitionMode.CARD) ? 
            prepareCardViewEffect() : 
            prepareCubeViewEffect();    
    }
        
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override protected function createConsolidatedEffect():IEffect
    {  
        // If we have no cachedNavigator then there is not much we can do.
        if (!cachedNavigator)
            return null;
        
        return mode == FlipViewTransitionMode.CARD ? 
            prepareConsolidatedCardViewEffect() : 
            prepareConsolidatedCubeViewEffect();
    }
        
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @inheritDoc
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function prepareForPlay():void
    {
        actionBarTransitionDirection = direction;
        super.prepareForPlay();
    }
    
    //--------------------------------------------------------------------------
    //  Card Flip Effect
    //--------------------------------------------------------------------------
            
    /**
     *  @private
     */  
    private function prepareCardViewEffect():IEffect
    {
        // Initialize are transition parameters, create our temporary
        // transitionGroup, and parent our view elements.
        setupTransition();
                
        // Align underside 'face' of our card.
        alignCardFaces(endView);
                        
        return createCardFlipAnimation(transitionGroup, endView.width); 
    }
    
    /**
     *  @private
     */  
    private function prepareConsolidatedCardViewEffect():IEffect
    {       
        // Initialize are transition parameters, create our temporary
        // transitionGroup, and parent our view elements.
        setupConsolidatedTransition();
                        
        // Align underside 'face' of our card.
        alignCardFaces(targetNavigator);
                        
        return createCardFlipAnimation(transitionGroup, endView.width);     
    }
        
    /**
     *  @private
     *  Shared helper routine which serves as our effect factory for both standard
     *  and consolidated transitions.
     */  
    protected function createCardFlipAnimation(flipTarget:UIComponent, width:Number):IEffect
    {
        // Now offset our transform center as appropriate for the transition direction
        transitionGroup.transformX = viewWidth / 2;
        transitionGroup.transformY = viewHeight / 2;
        
        // Validate our transition group prior to the start of our animation.
        transitionGroup.validateNow();
        
        var animation:Animate = new Animate();
        
        // Create motion path for our rotation property.
        var vector:Vector.<MotionPath> = new Vector.<MotionPath>();
        vector.push(new SimpleMotionPath(animatedProperty, 0, directionModifier * 180));
        
        // Creation motion path for the target's z property.
        var mp:MotionPath = new MotionPath("z");
        vector.push(mp);
        
        // Generate key frames for the z animation
        var keyframes:Vector.<Keyframe> = new Vector.<Keyframe>();
        
        var keyFrame:Keyframe = new Keyframe();
        keyFrame.time = 0;
        keyFrame.value = 0;
        keyframes.push(keyFrame);
        
        keyFrame = new Keyframe();
        keyFrame.time = duration / 2;
        keyFrame.value = width / 2;
        keyframes.push(keyFrame);
        
        keyFrame = new Keyframe();
        keyFrame.time = duration;
        keyFrame.value = 0;
        keyframes.push(keyFrame);
        
        mp.keyframes = keyframes;
        
        // Configure the remainder of our animation parameters and install
        // an update listener so that we can hide the old view once it's out
        // of view.
        animation.motionPaths = vector;
        animation.target = flipTarget;
        animation.duration = duration;
        animation.addEventListener("effectUpdate", effectUpdateHandler);
        animation.easer = easer;
        
        return animation;  
    }
    
    /**
     *  @private
     *  Update listener on our flip effect that hides our start view
     *  once it is no longer visible to the user.
     */
    private function effectUpdateHandler(event:EffectEvent):void
    {
        var animatedProp:String = vertical ? "rotationX" : "rotationY";
        
        if(Math.abs(transitionGroup[animatedProp]) > 90) 
        {
            if (!consolidatedTransition)
                startView.visible = false;
            else
                cachedNavigator.visible = false;
			
            event.target.removeEventListener("effectUpdate", effectUpdateHandler);
        }
    }
    
    //--------------------------------------------------------------------------
    //  Cube Flip Effect
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */  
    private function prepareCubeViewEffect():IEffect
    {
        // Initialize are transition parameters, create our temporary
        // transitionGroup, and parent our view elements.
        setupTransition();
        
        // Position the 'faces' of our cube.
        alignCubeFaces(startView, endView);
        
        // Construct our animation sequence now that actors are configured.
        return createCubeFlipAnimation(transitionGroup, vertical ? viewHeight : viewWidth);
    }
    
    /**
     *  @private
     */  
    private function prepareConsolidatedCubeViewEffect():IEffect
    {
        // Initialize are transition parameters, create our temporary
        // transitionGroup, and parent our view elements.
        setupConsolidatedTransition();
                
        // Position the 'faces' of our cube.
        alignCubeFaces(cachedNavigator, targetNavigator);
                        
        // Construct our animation sequence now that actors are configured.
        return createCubeFlipAnimation(transitionGroup, vertical ? viewHeight : viewWidth); 
    }
    
    /**
     *  @private
     *  Shared helper routine which serves as our effect factory for both standard
     *  and consolidated transitions.
     */  
    protected function createCubeFlipAnimation(flipTarget:UIComponent, depth:Number):IEffect
    {
        // Validate our transition group prior to the start of our animation.
        transitionGroup.validateNow();
        
        var p:Parallel = new Parallel();
        p.target = flipTarget;
        
        // Zoom out
        var m1:Move3D = new Move3D();
        m1.zTo = depth / 1.45;
        m1.duration = duration/2;
        m1.addEventListener("effectUpdate", cubeEffectUpdateHandler);
        
        // Zoom back in
        var m2:Move3D = new Move3D();
        m2.zTo = depth / 2;
        m2.duration = duration/2;
        m2.startDelay = duration/2;
        
        // Rotate our 'cube'.
        var r1:Rotate3D = new Rotate3D();
        if (animatedProperty == "rotationY")
            r1.angleYTo= directionModifier * 90;
        else
            r1.angleXTo = directionModifier * 90;
        r1.duration = duration;
        
        p.addChild(m1);
        p.addChild(m2);
        p.addChild(r1);
        
        return p;
    }
    
    /**
     *  @private
     *  Update listener on our cube flip effect that hides our start view
     *  once it's no longer facing the user.
     */
    private function cubeEffectUpdateHandler(event:EffectEvent):void
    {       
        var face:DisplayObject = (!consolidatedTransition) ? 
            startView : cachedNavigator.displayObject;
            
        var frontFacing:Boolean = isFrontFacing(face);
        if (!frontFacing)
        {
            face.visible = false;
            event.target.removeEventListener("effectUpdate", cubeEffectUpdateHandler);
        }
    }
        
    /**
     *  @private
     *  Determine if a given display object with 2.5d transform 
     *  is front facing, by testing the winding direction of three
     *  points on the object translated to user viewport (via cross
     *  product of vectors).
     */
    private function isFrontFacing(target:DisplayObject):Boolean 
    {
        var pA:Point = target.localToGlobal( POINT_A );
        var pB:Point = target.localToGlobal( POINT_B );
        var pC:Point = target.localToGlobal( POINT_C );
        
        return (pB.x-pA.x) * (pC.y-pA.y) - (pB.y-pA.y) * (pC.x-pA.x) > 0;
    }
    
    private static const POINT_A:Point = new Point(0,   0);
    private static const POINT_B:Point = new Point(100, 0);
    private static const POINT_C:Point = new Point(0, 100);
    
    //--------------------------------------------------------------------------
    // Shared helpers
    //--------------------------------------------------------------------------
 
    /**
     *  @private
     */
    private function alignCardFaces(face:DisplayObject):void
    {
        // In order for device text to render properly when negatively scaled, we
        // must ensure our view has a transform matrix 3D active.
        face.z = .01;
        
        // Mirror our end view so that it can serve as the reverse face of our
        // card transition.
        if (vertical)
        {
            face.y += viewHeight;
            face.scaleY = -1;
        }
        else
        {
            face.x += viewWidth;
            face.scaleX = -1;
        }
    }
    
    /**
     *  @private
     */
    private function alignCubeFaces(startFace:Object, endFace:Object):void
    {
        // Position the xform center of outer transitionGroup.
        transitionGroup.x = viewWidth / 2;
        transitionGroup.y = viewHeight / 2;
        transitionGroup.z = vertical ? (viewHeight / 2) : (viewWidth / 2);
        
        // Position the 'faces' of our cube.
        if (vertical)
        {
            endFace.x = -viewWidth / 2;
            endFace.y = -directionModifier * viewHeight / 2;
            endFace.z = directionModifier * viewHeight / 2;
            endFace["rotationX"] = -directionModifier * 90;
        }
        else
        {
            endFace.x = directionModifier * viewWidth / 2;
            endFace.y = -viewHeight / 2;
            endFace.z = -directionModifier * viewWidth / 2;
            endFace["rotationY"] = -directionModifier * 90;
        }
        
        startFace.x = -viewWidth/2;
        startFace.y = -viewHeight/2;
        startFace.z = vertical ? (-viewHeight/2) : (-viewWidth/2);
    }
    
    /**
     *  @private
     */
    private function createCenteredProjection():PerspectiveProjection
    {
        var projection:PerspectiveProjection = new PerspectiveProjection();
        projection.fieldOfView = 45;
        projection.projectionCenter = new Point(viewWidth / 2, viewHeight / 2);
        return projection;
    }
    
    /**
     *  @private
     *  Initializes our vertical, viewWidth, viewHeight, animatedProperty,
     *  and directionModifier properties.
     */
    private function initTransitionParameters(width:Number, height:Number):void
    {
        vertical = (direction == ViewTransitionDirection.DOWN ||
            direction == ViewTransitionDirection.UP);
        
        viewWidth = width;
        viewHeight = height;
        
        animatedProperty = vertical ? "rotationX" : "rotationY";
        
        directionModifier = (direction == ViewTransitionDirection.LEFT || 
            direction == ViewTransitionDirection.DOWN) ? 1 : -1;
    }
    
    /**
     *  @private
     *  Initialize are transition parameters, create our temporary
     *  transitionGroup, and parent our view elements.
     */
    private function setupTransition():void
    {
        // Initialize temporaries based on our currently flip direction.
        initTransitionParameters(endView.width, endView.height);
        
        // Disable start view layout.
        startViewProps = { includeInLayout:startView.includeInLayout };
        startView.includeInLayout = false;
        
        // Disable end view layout.
        endViewProps = { includeInLayout:endView.includeInLayout }; 
        endView.includeInLayout = false;
        
        // Save our end view's transform matrix.
        savedEndMatrix = endView.transform.matrix3D;
        
        // Create a temporary transition group to serve as the parent of our
        // views while flipping.  Offset our transition group as necessary to 
        // ensure we flip relative to our center.
        transitionGroup = new Group();
        transitionGroup.includeInLayout=false;
        addComponentToContainer(transitionGroup, UIComponent(endView.parent));
        transitionGroup.addElement(endView);
        transitionGroup.addElement(startView);
        
        // Setup our transition group's perspective projection properties.
        transitionGroup.transform.perspectiveProjection = createCenteredProjection();
    }
    
    /**
     *  @private
     *  Initialize are transition parameters, create our temporary
     *  transitionGroup, and parent our view elements (for a consolidated
     *  transition).
     */
    private function setupConsolidatedTransition():void
    {
        // Initialize temporaries based on our currently flip direction.
        initTransitionParameters(targetNavigator.width, targetNavigator.height);
        
        // Since we are using it to host our transition group, ensure the 
        // parent of our targetNavigator is fully validated, when its not 
        // our transition goes haywire because our bounds are wrong.
        UIComponent(targetNavigator.parent).validateNow();
        
        // Add a temporary group to contain our snapshot view of the navigator
        // while we animate.
        transitionGroup = new Group();
        transitionGroup.includeInLayout = false;
        addComponentToContainer(transitionGroup, DisplayObject(targetNavigator).parent as UIComponent);
        
        transitionGroup.addElement(targetNavigator);
        cachedNavigator.includeInLayout = false;
        transitionGroup.addElement(cachedNavigator);
        
        transitionGroup.x = transitionGroup.y = 0;
        transitionGroup.width = cachedNavigator.width;
        transitionGroup.height = cachedNavigator.height;
        
        // Save our end view's transform matrix.
        savedEndMatrix = targetNavigator.transform.matrix3D;
        
        // Setup our transition group's perspective projection properties.
        transitionGroup.transform.perspectiveProjection = createCenteredProjection();
                
        // Disable layout for our targetNavigator temporarily.
        navigatorProps.targetNavigatorIncludeInLayout = targetNavigator.includeInLayout;
        targetNavigator.includeInLayout = false;
    }
    
    //--------------------------------------------------------------------------
    //  Cleanup related methods.
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Override transitionComplete so that we can defer clean up 
     *  until after we've rendered the last frame of the 3d transition.
     */
    override protected function transitionComplete():void
    {
        navigator.addEventListener("enterFrame", enterFrameHandler);
    }
    
    /**
     *  @private
     */
    private function enterFrameHandler(e:Event):void
    {
        navigator.removeEventListener("enterFrame", enterFrameHandler);
        
        // Invoke our cleanup now that we've rendered the last frame of
        // animation.
        deferredCleanUp();
        
        // Now dispatch our transition end event.
        if (hasEventListener(FlexEvent.TRANSITION_END))
            dispatchEvent(new FlexEvent(FlexEvent.TRANSITION_END));
    }
    
    /**
     *  @private
     *  Cleanup method which restores any temporary properties set up 
     *  on our view elements.
     */
    protected function deferredCleanUp():void
    {
        
        if (!consolidatedTransition && transitionGroup)
        {
            if (endView)
                endView.transform.matrix3D = savedEndMatrix;
            
            // Restore our views to their natural location.
            if (startView && endView)
            {
                navigator.contentGroup.addElement(startView);
                navigator.contentGroup.addElement(endView);
            }
            
            // Extract our temporary transition group.
            Group(transitionGroup.parent).removeElement(transitionGroup);
            
            // Restore startView properties.
            if (startView)
            {
                startView.includeInLayout = startViewProps.includeInLayout;
                startViewProps = null;
            }
            
            // Restore endView properties.
            if (endView)
            {
                endView.includeInLayout = endViewProps.includeInLayout;
                endViewProps = null;
            }
        }
        else if (transitionGroup)
        {
            if (targetNavigator)
                targetNavigator.transform.matrix3D = savedEndMatrix;
            
            // Restore our views to their natural location.
            removeComponentFromContainer(targetNavigator as UIComponent, transitionGroup as UIComponent);
            addComponentToContainer(targetNavigator as UIComponent, transitionGroup.parent as UIComponent);
            removeComponentFromContainer(transitionGroup as UIComponent, transitionGroup.parent as UIComponent);
            
            // Restore targetNavigator properties.
            targetNavigator.includeInLayout = navigatorProps.targetNavigatorIncludeInLayout;
        }
        
        transitionGroup = null;
        cachedNavigator = null;
        
        super.cleanUp();
    }
    

}
}
