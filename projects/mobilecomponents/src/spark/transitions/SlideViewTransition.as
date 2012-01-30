package spark.effects
{
import flash.display.BitmapData;
import flash.display.IBitmapDrawable;

import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.effects.Effect;
import mx.effects.Parallel;
import mx.events.EffectEvent;

import spark.components.ActionBar;
import spark.components.Group;
import spark.components.Image;
import spark.components.View;

use namespace mx_internal;

public class SlideViewTransition extends ViewTransition
{
    public static const SLIDE_LEFT:int = 0;
    public static const SLIDE_RIGHT:int = 1;
    public static const SLIDE_UP:int = 2;
    public static const SLIDE_DOWN:int = 3;
    public static const TYPE:String = "slide";
    
    public var direction:int = SLIDE_LEFT;
    
    private var actionBar:ActionBar;
    private var currentActionBarImage:Image;
    private var currentActionBarTitleImage:Image;
    private var currentViewImage:Image;
    
    private var nextViewImage:Image;
    private var nextActionBarTitleImage:Image;
    private var nextActionBarTitleVisibility:Array; /* Boolean */
    
    public function SlideViewTransition(duration:Number, direction:int = SLIDE_LEFT)
    {
        super();
        
        type = "slide";
        
        this.duration = duration;
        this.direction = direction;
    }
    
    override public function prepare():void
    {
        var bitmapData:BitmapData;
        var contentGroup:Group = navigator.contentGroup;
        actionBar = navigator.actionBar;
        
        bitmapData = new BitmapData(contentGroup.width, contentGroup.height);
        bitmapData.draw(contentGroup);
        
        currentViewImage = new Image();
        currentViewImage.source = bitmapData;
        currentViewImage.setActualSize(contentGroup.width, contentGroup.height);
        currentViewImage.includeInLayout = false;
        
        currentViewImage.x = contentGroup.x;
        currentViewImage.y = contentGroup.y;
        
        if (isActionBarVisible())
        {
            // full ActionBar image
            bitmapData = new BitmapData(actionBar.width, actionBar.height);
            bitmapData.draw(actionBar);
            
            currentActionBarImage = new Image();
            currentActionBarImage.source = bitmapData;
            currentActionBarImage.setActualSize(actionBar.width, actionBar.height);
            currentActionBarImage.includeInLayout = false;
            
            currentActionBarImage.x = actionBar.x;
            currentActionBarImage.y = actionBar.y;
            
            // ActionBar titleGroup only
            bitmapData = new BitmapData(actionBar.titleGroup.width, actionBar.titleGroup.height, true, 0);
            bitmapData.draw(actionBar.titleGroup);
            
            currentActionBarTitleImage = new Image();
            currentActionBarTitleImage.source = bitmapData;
            currentActionBarTitleImage.setActualSize(actionBar.titleGroup.width, actionBar.titleGroup.height);
            currentActionBarTitleImage.includeInLayout = false;
        }
    }
    
    private function isActionBarVisible():Boolean
    {
        return actionBar.visible && actionBar.width > 0 && actionBar.height > 0;
    }
    
    // Navigator has forced validation by now
    override public function play():void
    {
        // hide the previous view
        if (previousView)
        {
            previousView.visible = false;
            previousView.includeInLayout = false;
            //targets.push(currentView);
            //currentView.includeInLayout = false;
        }
        
        var targets:Array = new Array();
        
        // ActionBar can do an internal transition if it's not resized or doesn't change visible state
        var actionBarInternalTransition:Boolean = (currentActionBarImage && isActionBarVisible())
            && (actionBar.height == currentActionBarImage.height)
            && (actionBar.width == currentActionBarImage.width);
        
        // cache the next view
        var nextViewContent:UIComponent = (actionBarInternalTransition) ? navigator.contentGroup : navigator;
        var bitmapData:BitmapData = new BitmapData(nextViewContent.width, nextViewContent.height);
        bitmapData.draw(nextViewContent);
        nextViewImage = new Image();
        nextViewImage.source = bitmapData;
        nextViewImage.setActualSize(nextViewContent.width, nextViewContent.height);
        nextViewImage.includeInLayout = false;
        nextViewImage.x = nextViewContent.x;
        nextViewImage.y = nextViewContent.y;
        
        if (nextView)
        {
            nextView.visible = false;
            nextView.includeInLayout = false;
            //targets.push(nextView);
            //nextView.includeInLayout = false;
        }
        
        if (currentViewImage)
        {
            navigator.skin.addChildAt(currentViewImage, 0);
            targets.push(currentViewImage);
        }
        
        if (nextViewImage)
        {
            navigator.skin.addChildAt(nextViewImage, 0);
            targets.push(nextViewImage);
        }
        
        var actionBarInternalEffects:Vector.<Effect> = new Vector.<Effect>();
        
        if (currentActionBarImage)
        {
            if (actionBarInternalTransition)
            {
                // move effect for the title group
                var titleMoveEffect:Move = new Move();
                titleMoveEffect.duration = duration;
                
                // cache the new title group image
                bitmapData = new BitmapData(actionBar.titleGroup.width, actionBar.titleGroup.height, true, 0);
                bitmapData.draw(actionBar.titleGroup);
                nextActionBarTitleImage = new Image();
                nextActionBarTitleImage.source = bitmapData;
                nextActionBarTitleImage.setActualSize(actionBar.titleGroup.width, actionBar.titleGroup.height);
                nextActionBarTitleImage.includeInLayout = false;
                
                // position new title image at the right edge of the group
                switch (direction)
                {
                    case SLIDE_LEFT:
                        titleMoveEffect.xBy = -actionBar.titleGroup.width;
                        nextActionBarTitleImage.x = actionBar.titleGroup.width;
                        nextActionBarTitleImage.y = 0;
                        break;
                    case SLIDE_RIGHT:
                        titleMoveEffect.xBy = actionBar.titleGroup.width;
                        nextActionBarTitleImage.x = -actionBar.titleGroup.width;
                        nextActionBarTitleImage.y = 0;
                        break;
                    case SLIDE_UP:
                        titleMoveEffect.yBy = -actionBar.titleGroup.height;
                        nextActionBarTitleImage.x = 0;
                        nextActionBarTitleImage.y = actionBar.titleGroup.height;
                        break;
                    case SLIDE_DOWN:
                        titleMoveEffect.yBy = actionBar.titleGroup.height;
                        nextActionBarTitleImage.x = 0;
                        nextActionBarTitleImage.y = -actionBar.titleGroup.height;
                        break;
                }
                
                // hide the actionBar titleGroup content
                // TODO use DisplayObject mask instead? investigate performance
                nextActionBarTitleVisibility = new Array();
                
                var titleGroupContentIndex:uint = 0;
                for each (var content:IVisualElement in actionBar.titleGroup.getMXMLContent())
                {
                    nextActionBarTitleVisibility[titleGroupContentIndex] = false;
                    if (content is UIComponent)
                    {
                        var contentComponent:UIComponent = content as UIComponent;
                        nextActionBarTitleVisibility[titleGroupContentIndex] = contentComponent.visible;
                        contentComponent.visible = false;
                    }
                    
                    titleGroupContentIndex++;
                }
                
                // add images to titleGroup
                actionBar.titleGroup.addElement(nextActionBarTitleImage);
                actionBar.titleGroup.addElement(currentActionBarTitleImage);
                
                titleMoveEffect.targets = [currentActionBarTitleImage, nextActionBarTitleImage];
                
                actionBarInternalEffects.push(titleMoveEffect);
                
                var titleFadeEffect:Fade = new Fade();
                titleFadeEffect.duration = duration;
                titleFadeEffect.alphaTo = 0;
                titleFadeEffect.target = currentActionBarTitleImage;
                actionBarInternalEffects.push(titleFadeEffect);
                
                titleFadeEffect = new Fade();
                titleFadeEffect.duration = duration;
                titleFadeEffect.alphaFrom = 0;
                titleFadeEffect.alphaTo = 1;
                titleFadeEffect.target = nextActionBarTitleImage;
                actionBarInternalEffects.push(titleFadeEffect);
                
                currentActionBarImage = null;
            }
            else
            {
                navigator.skin.addChildAt(currentActionBarImage, 0);
                targets.push(currentActionBarImage);
                
                currentActionBarTitleImage = null;
            }
        }
        
        //targets.push(navigator.actionBar);
        actionBar.visible = actionBarInternalTransition;
        
        // slide effect for the View
        var slideAnimation:Move = new Move();
        
        if (direction == SLIDE_LEFT)
        {
            slideAnimation.xBy = -nextViewContent.width;
            if (nextViewImage)
                nextViewImage.x = nextViewContent.width;
            
            //                if (nextView)
            //                {
            //                    navigator.actionBar.x = navigator.width;
            //                    nextView.x = navigator.width;
            //                }
        }
        else if (direction == SLIDE_RIGHT)
        {
            slideAnimation.xBy = nextViewContent.width;
            if (nextViewImage)
                nextViewImage.x = -nextViewContent.width;
            
            //                if (nextView)
            //                {
            //                    nextView.x = -navigator.width;
            //                    navigator.actionBar.x = -navigator.width;
            //                }
        }
        else if (direction == SLIDE_UP)
        {
            slideAnimation.yBy = -nextViewContent.height;
            if (nextViewImage)
                nextViewImage.y = nextViewContent.height + nextViewContent.y;
        }
        else if (direction == SLIDE_DOWN)
        {
            slideAnimation.yBy = nextViewContent.height;
            if (nextViewImage)
                nextViewImage.y = -nextViewContent.height + nextViewContent.y;
        }
        
        slideAnimation.duration = duration;
        slideAnimation.addEventListener(EffectEvent.EFFECT_END, transitionComplete);
        slideAnimation.targets = targets;
        
        if (actionBarInternalEffects)
        {
            var parallel:Parallel = new Parallel();
            parallel.addChild(slideAnimation);
            
            for each (var childEffect:Effect in actionBarInternalEffects)
                parallel.addChild(childEffect);
            
            parallel.play();
        }
        else
        {
            slideAnimation.play();
        }
    }
    
    override public function end():void
    {
        
    }
    
    override public function transitionComplete(event:EffectEvent=null):void
    {
        event.target.removeEventListener(EffectEvent.EFFECT_END, transitionComplete);
        
        actionBar.visible = true;
        actionBar.includeInLayout = true;
        
        if (nextView)
        {
            nextView.visible = true;
            nextView.includeInLayout = true;
        }
        
        if (currentActionBarImage)
        {
            navigator.skin.removeChild(currentActionBarImage);
            currentActionBarImage = null;
        }
        
        if (currentActionBarTitleImage)
        {
            actionBar.titleGroup.removeElement(currentActionBarTitleImage);
            currentActionBarTitleImage = null;
        }
        
        if (nextActionBarTitleImage)
        {
            actionBar.titleGroup.removeElement(nextActionBarTitleImage);
            nextActionBarTitleImage = null;
            
            // show the actionBar titleGroup content
            var titleGroupContentIndex:uint = 0;
            for each (var content:IVisualElement in actionBar.titleGroup.getMXMLContent())
            {
                if (content is UIComponent)
                    (content as UIComponent).visible = nextActionBarTitleVisibility[titleGroupContentIndex];
                
                titleGroupContentIndex++;
            }
        }
        
        if (nextViewImage)
        {
            navigator.skin.removeChild(nextViewImage);
            nextViewImage = null;
        }
        
        navigator.skin.removeChild(currentViewImage);
        currentViewImage = null;
        
        super.transitionComplete(event);
    }
}
}