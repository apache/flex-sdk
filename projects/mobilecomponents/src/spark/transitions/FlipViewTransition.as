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

import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.effects.IEffect;
import mx.events.EffectEvent;
import mx.events.FlexEvent;

import spark.components.Group;
import spark.components.TabbedViewNavigator;
import spark.components.ViewNavigator;
import spark.components.supportClasses.ButtonBarBase;
import spark.effects.Animate;
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
	private var savedMatrix:Matrix3D;
	
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
		cachedNavigator = getSnapshot(targetNavigator);
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
		// Don't bother transitioning if we're missing views (or if we 
		// don't support the requested mode)
		if (!startView || !endView || mode == FlipViewTransitionMode.CUBE)
			return null;
		
		// Initialize temporaries based on our currently flip direction.
		vertical = (direction == ViewTransitionDirection.DOWN ||
			direction == ViewTransitionDirection.UP);
		
		var viewWidth:Number = endView.width;
		var viewHeight:Number = endView.height;
		var animatedProperty:String = vertical ? "rotationX" : "rotationY";

		// Disable start view layout.
		startViewProps = { includeInLayout:startView.includeInLayout };
		startView.includeInLayout = false;
		
		// Disable end view layout.
		endViewProps = { includeInLayout:endView.includeInLayout };	
		endView.includeInLayout = false;
				
		// Save our end view's transform matrix.
		savedMatrix = endView.transform.matrix3D;
		
		// In order for device text to render properly when negatively scaled, we
		// must ensure our view has a transform matrix 3D active.
		endView.z = .01;
		
		// Mirror our end view so that it can serve as the reverse face of our
		// card transition.
		if (vertical)
		{
			endView.y += viewHeight;
			endView.scaleY = -1;
		}
		else
		{
			endView.x += viewWidth;
			endView.scaleX = -1;
		}
		
		// Create a temporary transition group to serve as the parent of our
		// views while flipping.  Offset our transition group as necessary to 
		// ensure we flip relative to our center.
		transitionGroup = new Group();
		transitionGroup.includeInLayout=false;
		addComponentToContainer(transitionGroup, UIComponent(endView.parent));
		transitionGroup.addElement(endView);
		transitionGroup.addElement(startView);
		
		// Setup our transition group's perspective projection properties.
		var projection:PerspectiveProjection = new PerspectiveProjection();
		projection.fieldOfView = 45;
		projection.projectionCenter = new Point(viewWidth / 2, viewHeight / 2);
		transitionGroup.transform.perspectiveProjection = projection;
		transitionGroup[animatedProperty] = 0;
		
		// Now offset our transform center as appropriate for the transition direction
		transitionGroup.transformX = viewWidth / 2;
		transitionGroup.transformY = viewHeight / 2;
		
		// Validate our transition group prior to the start of our animation.
		transitionGroup.validateNow();
		
		// Create and return our composite flip effect.
		var directionModifier:int = (direction == ViewTransitionDirection.LEFT || 
			direction == ViewTransitionDirection.DOWN) ? 1 : -1;
		
		return createFlipEffect(transitionGroup, endView.width, animatedProperty, directionModifier);	
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
		if (!cachedNavigator || mode == FlipViewTransitionMode.CUBE)
			return null;
				
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
		
		// Initialize temporaries based on our currently flip direction.
		vertical = (direction == ViewTransitionDirection.DOWN ||
			direction == ViewTransitionDirection.UP);
		
		var viewWidth:Number = targetNavigator.width;
		var viewHeight:Number = targetNavigator.height;
		var animatedProperty:String = vertical ? "rotationX" : "rotationY";
		
		// Save our end view's transform matrix.
		savedMatrix = targetNavigator.transform.matrix3D;
		
		// In order for device text to render properly when negatively scaled, we
		// must ensure our view has a transform matrix 3D active.
		targetNavigator.z = .01;
		
		// Mirror our end view so that it can serve as the reverse face of our
		// card transition.
		if (vertical)
		{
			targetNavigator.y += viewHeight;
			targetNavigator.scaleY = -1;
		}
		else
		{
			targetNavigator.x += viewWidth;
			targetNavigator.scaleX = -1;
		}
		
		// Setup our transition group's perspective projection properties.
		var projection:PerspectiveProjection = new PerspectiveProjection();
		projection.fieldOfView = 45;
		projection.projectionCenter = new Point(viewWidth / 2 - 1, viewHeight / 2 - 1);
		transitionGroup.transform.perspectiveProjection = projection;
		transitionGroup[animatedProperty] = 0;
		
		// Now offset our transform center as appropriate for the transition direction
		transitionGroup.transformX = targetNavigator.width / 2;
		transitionGroup.transformY = targetNavigator.height / 2;
		
		navigatorProps.targetNavigatorIncludeInLayout = targetNavigator.includeInLayout;
		targetNavigator.includeInLayout = false;
		
		// Validate our transition group prior to the start of our animation.
		transitionGroup.validateNow();
		
		// Create and return our composite flip effect.
		var directionModifier:int = (direction == ViewTransitionDirection.LEFT || 
			direction == ViewTransitionDirection.DOWN) ? 1 : -1;
		
		return createFlipEffect(transitionGroup, endView.width, animatedProperty, directionModifier);	
	}
	
	/**
	 *  @private
	 *  Cleanup helper method.
	 */
	protected function deferredCleanUp():void
	{
		
		if (!consolidatedTransition && transitionGroup)
		{
			if (endView)
				endView.transform.matrix3D = savedMatrix;
			
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
				targetNavigator.transform.matrix3D = savedMatrix;
			
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
	protected function enterFrameHandler(e:Event):void
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
	 *  Update listener on our flip effect that hides our start view
	 *  once the end view can be seen.
	 */
	private function effectUpdateHandler(e:EffectEvent):void
	{
		var animatedProp:String = vertical ? "rotationX" : "rotationY";
		
		if(Math.abs(transitionGroup[animatedProp]) > 90) 
		{
			if (!consolidatedTransition)
			    startView.visible = false;
			else
				cachedNavigator.visible = false;
		}
	}
	
	/**
	 *  @private
	 *  Shared helper routine which serves as our effect factory for both standard
	 *  and consolidated transitions.
	 */  
	protected function createFlipEffect(flipTarget:UIComponent, width:Number, 
										animatedProperty:String, directionModifier:int):IEffect
	{
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

}
}
