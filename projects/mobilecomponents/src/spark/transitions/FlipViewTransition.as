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
import flash.geom.Vector3D;

import mx.core.FlexGlobals;
import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.effects.IEffect;
import mx.effects.Parallel;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.geom.TransformOffsets;
import mx.managers.SystemManager;

import spark.components.Application;
import spark.components.Group;
import spark.components.TabbedViewNavigator;
import spark.components.ViewNavigator;
import spark.components.supportClasses.ButtonBarBase;
import spark.components.supportClasses.SkinnableComponent;
import spark.effects.*;
import spark.effects.animation.Keyframe;
import spark.effects.animation.MotionPath;
import spark.effects.animation.SimpleMotionPath;
import spark.primitives.BitmapImage;

use namespace mx_internal;

/**
 *  The FlipViewTransition class performs a simple flip transition for  views.  
 *  The flip transition supports two modes (card and cube)
 *  as well as an optional direction (up, down, left, or right).
 * 
 *  <p>The default duration of a FlipViewTransition is 400 ms.</p>
 *
 *  <p><strong>Note:</strong>Create and configure view transitions in ActionScript;
 *  you cannot create them in MXML.</p>
 *
 *  @see FlipViewTransitionMode
 *  @see ViewTransitionDirection
 *  
 *  @langversion 3.0
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
[Deprecated(since="4.6")] 
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
    
    /**
     *  @private
     */
    private var flipEffect:IEffect;
        
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //---------------------------------
    // direction
    //---------------------------------
    
    private var _direction:String = ViewTransitionDirection.LEFT;
    
    [Inspectable(category="General", enumeration="left,right,up,down", defaultValue="left")]
    /**
     *  Specifies the direction of flip transition.
     *
     *  @default ViewTransitionDirection.LEFT
     *
     *  @see ViewTransitionDirection
     * 
     *  @langversion 3.0
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
    
    private var _mode:String = "card"; // avoid deprecation warning for FlipViewTransitionMode.CARD;
    
    [Inspectable(category="General", enumeration="card,cube", defaultValue="card")]
    /**
     *  Specifies the type of flip transition to perform.
     *
     *  @default FlipViewTransitionMode.CARD
     *
     *  @see FlipViewTransitionMode
     * 
     *  @langversion 3.0
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
     *  @private
     * 
     *  @langversion 3.0
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
    override protected function createViewEffect():IEffect
    {   
        // Don't bother transitioning if we're missing views.
        if (!startView || !endView)
            return null;

        return (mode == "card") ? // avoid deprecation warning for FlipViewTransitionMode.CARD
            prepareCardViewEffect() : 
            prepareCubeViewEffect();
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
        
        return mode == "card" ? // avoid deprecation warning for FlipViewTransitionMode.CARD 
            prepareConsolidatedCardViewEffect() : 
            prepareConsolidatedCubeViewEffect();
    }
        
    //--------------------------------------------------------------------------
    //
    //  Private Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     * 
     *  @langversion 3.0
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    override public function prepareForPlay():void
    {
        actionBarTransitionDirection = direction;
        super.prepareForPlay();

        // Enable clipping on the contentGroups of the views
        if (startView && startView.contentGroup)
        {
            startViewProps.clipAndEnableScrolling = startView.contentGroup.clipAndEnableScrolling;
            startView.contentGroup.clipAndEnableScrolling = true;
        }
        
        if (endView && endView.contentGroup)
        {
            endViewProps.clipAndEnableScrolling = endView.contentGroup.clipAndEnableScrolling;
            endView.contentGroup.clipAndEnableScrolling = true;
        }
        
        // Work-around for SDK-29118
        if (dpiScale != 1 && transitionGroup)
            applyDPIScaleToElements(transitionGroup, dpiScale);
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
                        
        return createCardFlipAnimation(endView.width); 
    }
    
    /**
     *  @private
     */  
    private function prepareConsolidatedCardViewEffect():IEffect
    {       
        // Initialize are transition parameters, create our temporary
        // transitionGroup, and parent our view elements.
        setupConsolidatedTransition();
                        
        // Capture original targetNavigator x and y coordinates before
        // alignCardFaces changes them
        navigatorProps.x = targetNavigator.x;
        navigatorProps.y = targetNavigator.y;
        
        // Align underside 'face' of our card.
        alignCardFaces(targetNavigator);
                        
        // When doing a consolidated card effect, the targetNavigator and actionBar
        // need to be hidden in some use cases to prevent them from renderering
        // through transparent backgrounds.  The visibility of the elements
        // are retoggled in effectUpdateHandler().
        if (actionBar)
        {
            navigatorProps.actionBarVisible = actionBar.visible;
            actionBar.visible = false;
        }
        
        targetNavigator.setVisible(false, true);
        
        return createCardFlipAnimation(endView.width);     
    }
    
    /**
     *  @private
     */  
    private function get dpiScale():Number
    {
        return (Application(FlexGlobals.topLevelApplication).runtimeDPI / 
                Application(FlexGlobals.topLevelApplication).applicationDPI); 
    }

    /**
     *  @private
     *  Shared helper routine which serves as our effect factory for both standard
     *  and consolidated transitions.
     */  
    protected function createCardFlipAnimation(width:Number):IEffect
    {
        // Now offset our transform center as appropriate for the transition direction
        transitionGroup.transformX = viewWidth / 2;
        transitionGroup.transformY = viewHeight / 2;
        
        // If we are doing a consolidate flip effect, the transform center needs
        // to be translated by the parents x and y since the transition group is not
        // the view but the navigators parent
        if (consolidatedTransition)
        {
            transitionGroup.transformX += navigatorProps.x;
            transitionGroup.transformY += navigatorProps.y;
        }
                
        // Validate our transition group prior to the start of our animation.
        transitionGroup.validateNow();

        var animation:Animate = new Animate();
        
        // Create motion path for our rotation property.
        var vector:Vector.<MotionPath> = new Vector.<MotionPath>();
        vector.push(new SimpleMotionPath(animatedProperty, 0, directionModifier * 180));
        
        // Configure the remainder of our animation parameters and install
        // an update listener so that we can hide the old view once it's out
        // of view.
        animation.motionPaths = vector;
        animation.target = transitionGroup;
        animation.duration = duration;
        animation.addEventListener("effectUpdate", effectUpdateHandler);
        animation.easer = easer;
        flipEffect = animation;
        
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
            {
                startView.visible = false;
            }
            else
            {
                targetNavigator.setVisible(true, true);
                
                if (actionBar)
                    actionBar.visible = navigatorProps.actionBarVisible;
                
                cachedNavigator.displayObject.visible = false;
            }
        }

        if (mode == "card") // avoid deprecation warning for FlipViewTransitionMode.CARD
        {
            var topRight:Vector3D = new Vector3D(viewWidth, 0, 0);
            var bottomLeft:Vector3D = new Vector3D(0, viewHeight, 0);
                
            var matrix:Matrix3D = new Matrix3D();
            matrix.identity();
            
            if (vertical)
            {
            	// Flipping around X axis
                matrix.appendTranslation(0, -viewHeight/2, 0);
                matrix.appendRotation(transitionGroup.rotationX, new Vector3D(1, 0, 0));
                matrix.appendTranslation(0, viewHeight/2, 0);
                
            }
            else
            {
            	// Flipping around Y axis
                matrix.appendTranslation(-viewWidth/2, 0, 0);
                matrix.appendRotation(transitionGroup.rotationY, new Vector3D(0, 1, 0));
                matrix.appendTranslation(viewWidth/2, 0, 0);
            }
            
            var newTopRight:Vector3D = matrix.transformVector(topRight);
            var newBottomLeft:Vector3D = matrix.transformVector(bottomLeft);
            
            if (!transitionGroup.postLayoutTransformOffsets)
                transitionGroup.postLayoutTransformOffsets = new TransformOffsets();
            
            transitionGroup.postLayoutTransformOffsets.z = -Math.min(newTopRight.z, newBottomLeft.z);    
        }
        
        // Ensure transform matrix is updated even when layout is disabled.
        transitionGroup.validateDisplayList();
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
        return createCubeFlipAnimation(vertical ? viewHeight : viewWidth);
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
        return createCubeFlipAnimation(vertical ? viewHeight : viewWidth); 
    }
    
    /**
     *  @private
     *  Shared helper routine which serves as our effect factory for both standard
     *  and consolidated transitions.
     */  
    protected function createCubeFlipAnimation(depth:Number):IEffect
    {
        // Validate our transition group prior to the start of our animation.
        transitionGroup.validateNow();
        
        var p:Parallel = new Parallel();
        p.target = transitionGroup;
        
        // Zoom out
        var m1:Move3D = new Move3D();
        m1.zTo = depth / 1.45;
        m1.duration = duration/2;
        m1.addEventListener("effectUpdate", cubeEffectUpdateHandler);
        flipEffect = m1;
        
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
            face.visible = false;
        
        // Ensure transform matrix is updated even when layout is disabled.
        transitionGroup.validateDisplayList();
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
        transitionGroup.x += viewWidth / 2;
        transitionGroup.y += viewHeight / 2;
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
        
        var centerPoint:Point = new Point(viewWidth / 2, viewHeight / 2);
        
        if (consolidatedTransition)
        {
            centerPoint.x += transitionGroup.x;
            centerPoint.y += transitionGroup.y;
        }
        
        projection.projectionCenter = centerPoint;
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
        endViewProps = { includeInLayout:endView.includeInLayout, usesAdvancedLayout:(endView._layoutFeatures != null) }; 
        endView.includeInLayout = false;
        
        // Save our end view's transform matrix.
        savedEndMatrix = endView.transform.matrix3D;
        
        // Create a temporary transition group to serve as the parent of our
        // views while flipping.  Offset our transition group as necessary to 
        // ensure we flip relative to our center.
        transitionGroup = new Group();
        
        // Add transition group to the parent of the endView
        addComponentToContainer(transitionGroup, UIComponent(endView.parent));
        
        // This transition does a lot of reparenting of the views which will cause
        // multiple ADD and REMOVE events to be dispatched.  Since this event was already
        // dispatched before the transition began, we don't want that setup code
        // to be run multiple times.  So we listen for the events and prevent
        // them from propagating.
        if (endView.hasEventListener(FlexEvent.ADD))
            endView.addEventListener(FlexEvent.ADD, stopNavigatorEventFromPropagating, false, 1);
        
        if (endView.hasEventListener(FlexEvent.REMOVE))
            endView.addEventListener(FlexEvent.REMOVE, stopNavigatorEventFromPropagating, false, 1);
        
        if (startView.hasEventListener(FlexEvent.ADD))
            startView.addEventListener(FlexEvent.ADD, stopNavigatorEventFromPropagating, false, 1);
        
        if (startView.hasEventListener(FlexEvent.REMOVE))
            startView.addEventListener(FlexEvent.REMOVE, stopNavigatorEventFromPropagating, false, 1);
        
        // Reparent the start and end views into the transition group
        transitionGroup.addElement(endView);
        transitionGroup.addElement(startView);
        
        // Setup our transition group's perspective projection properties.
        transitionGroup.transform.perspectiveProjection = createCenteredProjection();
    }
    
    /**
     *  @private
     */
    private function stopNavigatorEventFromPropagating(event:FlexEvent):void
    {
        event.stopImmediatePropagation();
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
        
        // Save the child index of the target navigator
        navigatorProps.childIndex = getComponentChildIndex(targetNavigator, targetNavigator.parent as UIComponent);

        // Add a temporary group to contain our snapshot view of the navigator
        // while we animate.
        transitionGroup = new Group();

        // Size the transitionGroup to match the width and height of the navigator
        // so that the parent of the targetNavigator's layout remains unchanged 
        transitionGroup.width = targetNavigator.width;
        transitionGroup.height = targetNavigator.height;
        transitionGroup.x = targetNavigator.x;
        transitionGroup.y = targetNavigator.y;
        
        // The cached navigator and targetNavigator are currently position at their original
        // coordinates.  Since they will be parented into the transition group that already
        // takes that into consideration, we want to reposition the components to be at the
        // origin of the container.
        targetNavigator.x -= transitionGroup.x;
        targetNavigator.y -= transitionGroup.y;
        
        // Add the transition group at the same index of the target navigator
        addComponentToContainerAt(transitionGroup, DisplayObject(targetNavigator).parent as UIComponent, navigatorProps.childIndex);
        
        transitionGroup.addElement(targetNavigator);
        cachedNavigator.includeInLayout = false;
        addCachedElementToGroup(transitionGroup, cachedNavigator, cachedNavigatorGlobalPosition);
        
        // Save our end view's transform matrix.
        savedEndMatrix = targetNavigator.transform.matrix3D;
        
        // Setup our transition group's perspective projection properties.
        transitionGroup.transform.perspectiveProjection = createCenteredProjection();
                
        // Disable layout for our targetNavigator temporarily.
        navigatorProps.targetNavigatorIncludeInLayout = targetNavigator.includeInLayout;
        navigatorProps.usesAdvancedLayout = (targetNavigator._layoutFeatures != null);
        targetNavigator.includeInLayout = false;
    }

    /**
     *  @private
     *  For all children of the group, if they are SkinnableComponents:
     *  then applies "scale" to the skin and inverse scale to the component.
     *  If "scale" is "1", then it clears the scale from both the component
     *  and its skin.
     * 
     *  This is used as a work-around for SDK-29118, to force the player to
     *  use texture with size that takes the dpi scale into account.
     */  
    private function applyDPIScaleToElements(group:Group, scale:Number):void
    {
        var count:int = group.numElements;
        for (var i:int = 0; i < count; i++)
        {
            var element:IVisualElement = group.getElementAt(i);
            if (element is SkinnableComponent)
            {
                var comp:SkinnableComponent = SkinnableComponent(element);
                comp.skin.scaleX = scale;
                comp.skin.scaleY = scale;
                
                if (scale == 1)
                {
                    comp.scaleX = scale;
                    comp.scaleY = scale;
                }
                else
                {
                    comp.scaleX /= scale;
                    comp.scaleY /= scale;
                }
                
                comp.validateDisplayList();
            }
        }
    }

    //--------------------------------------------------------------------------
    //  Cleanup related methods.
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Cleanup method which restores any temporary properties set up 
     *  on our view elements.
     */
    override protected function cleanUp():void
    {
        // Work-around for SDK-29118
        // Clean-up any scale that we have applied to the elements
        if (dpiScale != 1 && transitionGroup)
            applyDPIScaleToElements(transitionGroup, 1);

        // Clean up clipping on the contentGroups of the views
        if (startView && startView.contentGroup)
            startView.contentGroup.clipAndEnableScrolling = startViewProps.clipAndEnableScrolling;
        
        if (endView && endView.contentGroup)
            endView.contentGroup.clipAndEnableScrolling = endViewProps.clipAndEnableScrolling;
        
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
            
            // Remove add handlers added to the views
            if (endView.hasEventListener(FlexEvent.ADD))
                endView.removeEventListener(FlexEvent.ADD, stopNavigatorEventFromPropagating);
            
            if (endView.hasEventListener(FlexEvent.REMOVE))
                endView.removeEventListener(FlexEvent.REMOVE, stopNavigatorEventFromPropagating);
            
            if (startView.hasEventListener(FlexEvent.ADD))
                startView.removeEventListener(FlexEvent.ADD, stopNavigatorEventFromPropagating);
            
            if (startView.hasEventListener(FlexEvent.REMOVE))
                startView.removeEventListener(FlexEvent.REMOVE, stopNavigatorEventFromPropagating);
            
            // Extract our temporary transition group.
            Group(transitionGroup.parent).removeElement(transitionGroup);
            
            // Restore startView properties.
            if (startView)
            {
                startView.includeInLayout = startViewProps.includeInLayout;
                startView.visible = true;
                startViewProps = null;
            }
            
            // Restore endView properties.
            if (endView)
            {
                endView.includeInLayout = endViewProps.includeInLayout;
                
                // Restore the end view to normal layout mode if if 
                // that's the mode it was in before the transition.
                if (!endViewProps.usesAdvancedLayout)
                    endView.clearAdvancedLayoutFeatures();
                endViewProps = null;
            }
        }
        else if (transitionGroup)
        {
            if (targetNavigator)
                targetNavigator.transform.matrix3D = savedEndMatrix;
            
            // Restore our views to their natural location.
            removeComponentFromContainer(targetNavigator as UIComponent, transitionGroup as UIComponent);
            addComponentToContainerAt(targetNavigator as UIComponent, transitionGroup.parent as UIComponent, navigatorProps.childIndex);
            removeComponentFromContainer(transitionGroup as UIComponent, transitionGroup.parent as UIComponent);
            
            // Restore targetNavigator properties.
            targetNavigator.includeInLayout = navigatorProps.targetNavigatorIncludeInLayout;

            // Restore the target navigator to normal layout mode if 
            // that's the mode it was in before the transition.
            if (!navigatorProps.usesAdvancedLayout)
                targetNavigator.clearAdvancedLayoutFeatures();
        }

        transitionGroup = null;
        cachedNavigator = null;
        
        flipEffect.removeEventListener("effectUpdate", cubeEffectUpdateHandler);
        flipEffect.removeEventListener("effectUpdate", effectUpdateHandler);
        flipEffect = null;
        
        super.cleanUp();
    }

}
}
