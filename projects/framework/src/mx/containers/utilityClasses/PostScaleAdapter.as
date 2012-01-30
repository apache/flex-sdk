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

package mx.containers.utilityClasses
{

import flash.accessibility.AccessibilityProperties;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Transform;

import mx.core.FlexVersion;
import mx.core.IConstraintClient;
import mx.core.IInvalidating;
import mx.core.IUIComponent;
import mx.managers.ISystemManager;

/**
 *  The PostScaleAdapter class is used as a compatibility layer for Flex 3 classes that 
 *  rely on width, height, min, max, explicit, measured, and other properties to be
 *  determined after scaling is applied. 
 *  This is useful since in Flex 4, the properties are calculated before scaling is applied.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class PostScaleAdapter implements IUIComponent,
                                         IConstraintClient,
                                         IInvalidating
{
    
    /**
     *  Call getCompatibleIUIComponent when you need to work with an IUIComponent that 
     *  reports width, height, min, max, explicit, measured, etc. in post-scale coordinates.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    static public function getCompatibleIUIComponent(obj:Object):IUIComponent
    {
        // We support only IUIComponent
        var uic:IUIComponent = obj as IUIComponent;
        if (!uic)
            return null;

        // If object is not scaled, then we don't need the adapter. We also don't
        // need the adapter if we are in compatibility mode.
        if (uic.scaleX == 1 && uic.scaleY == 1 || FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_0)
            return uic;

        // Make sure we don't adjust for scale twice!
        if (uic is PostScaleAdapter)
            return uic;
        
        // Flex4, we should adjust for scale
        return new PostScaleAdapter(uic);
    }
    
    private var obj:IUIComponent;
    
    public function PostScaleAdapter(obj:IUIComponent)
    {
        this.obj = obj;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  baselinePosition
    //----------------------------------

    /**
     *   
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get baselinePosition():Number
    { return obj.baselinePosition; }

    
    //----------------------------------
    //  document
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get document():Object
    {
        return obj.document;
    }

    /**
     *  @private
     */
    public function set document(value:Object):void
    {
        obj.document = value;
    }

    //----------------------------------
    //  enabled
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get enabled():Boolean
    {
        return obj.enabled;
    }

    /**
     *  @private
     */
    public function set enabled(value:Boolean):void
    {
        obj.enabled = value;
    }

    //----------------------------------
    //  explicitHeight
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get explicitHeight():Number
    {
        return obj.explicitHeight * Math.abs(obj.scaleY);
    }

    /**
     *  @private
     */
    public function set explicitHeight(value:Number):void
    {
        obj.explicitHeight = value / Math.abs(obj.scaleY);
    }

    //----------------------------------
    //  explicitMaxHeight
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get explicitMaxHeight():Number
    {
        return obj.explicitMaxHeight * Math.abs(obj.scaleY);
    }

    //----------------------------------
    //  explicitMaxWidth
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get explicitMaxWidth():Number
    {
        return obj.explicitMaxWidth * Math.abs(obj.scaleX);
    }

    //----------------------------------
    //  explicitMinHeight
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get explicitMinHeight():Number
    {
        return obj.explicitMinHeight * Math.abs(obj.scaleY);
    }

    //----------------------------------
    //  explicitMinWidth
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get explicitMinWidth():Number
    {
        return obj.explicitMinWidth * Math.abs(obj.scaleX);
    }

    //----------------------------------
    //  explicitWidth
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get explicitWidth():Number
    {
        return obj.explicitWidth * Math.abs(obj.scaleX);
    }

    /**
     *  @private
     */
    public function set explicitWidth(value:Number):void
    {
        obj.explicitWidth = value / Math.abs(obj.scaleX);
    }
    
    //----------------------------------
    //  focusPane
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get focusPane():Sprite
    {
        return obj.focusPane;
    }

    /**
     *  @private
     */
    public function set focusPane(value:Sprite):void
    {
        obj.focusPane = value;
    }

    //----------------------------------
    //  includeInLayout
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get includeInLayout():Boolean
    {
        return obj.includeInLayout;
    }

    /**
     *  @private
     */
    public function set includeInLayout(value:Boolean):void
    {
        obj.includeInLayout = value;
    }

    //----------------------------------
    //  isPopUp
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get isPopUp():Boolean
    {
        return obj.isPopUp;
    }

    /**
     *  @private
     */
    public function set isPopUp(value:Boolean):void
    {
        obj.isPopUp = value;
    }

    //----------------------------------
    //  maxHeight
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get maxHeight():Number
    {
        return obj.maxHeight * Math.abs(obj.scaleY);
    }

    //----------------------------------
    //  maxWidth
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get maxWidth():Number
    {
        return obj.maxWidth * Math.abs(obj.scaleX);
    }

    //----------------------------------
    //  measuredMinHeight
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get measuredMinHeight():Number
    {
        return obj.measuredMinHeight * Math.abs(obj.scaleY);
    }

    /**
     *  @private
     */
    public function set measuredMinHeight(value:Number):void
    {
        obj.measuredMinHeight = value / Math.abs(obj.scaleY);
    }

    //----------------------------------
    //  measuredMinWidth
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get measuredMinWidth():Number
    {
        return obj.measuredMinWidth * Math.abs(obj.scaleX);
    }

    /**
     *  @private
     */
    public function set measuredMinWidth(value:Number):void
    {
        obj.measuredMinWidth = value / Math.abs(obj.scaleX);
    }

    //----------------------------------
    //  minHeight
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get minHeight():Number
    {
        return obj.minHeight * Math.abs(obj.scaleY);
    }

    //----------------------------------
    //  minWidth
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get minWidth():Number
    {
        return obj.minWidth * Math.abs(obj.scaleX);
    }

    //----------------------------------
    //  owner
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get owner():DisplayObjectContainer
    {
        return obj.owner;
    }

    /**
     *  @private
     */
    public function set owner(value:DisplayObjectContainer):void
    {
        obj.owner = value;   
    }

    //----------------------------------
    //  percentHeight
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get percentHeight():Number
    {
        return obj.percentHeight;
    }

    /**
     *  @private
     */
    public function set percentHeight(value:Number):void
    {
        obj.percentHeight = value;
    }

    //----------------------------------
    //  percentWidth
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get percentWidth():Number
    {
        return obj.percentWidth;
    }

    /**
     *  @private
     */
    public function set percentWidth(value:Number):void
    {
        obj.percentWidth = value;
    }

    //----------------------------------
    //  systemManager
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get systemManager():ISystemManager
    {
        return obj.systemManager;
    }

    /**
     *  @private
     */
    public function set systemManager(value:ISystemManager):void
    {
        obj.systemManager = value;
    }
    
    //----------------------------------
    //  tweeningProperties
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get tweeningProperties():Array
    {
        return obj.tweeningProperties;
    }

    /**
     *  @private
     */
    public function set tweeningProperties(value:Array):void
    {
        obj.tweeningProperties = value;
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function initialize():void
    {
        obj.initialize();
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function parentChanged(p:DisplayObjectContainer):void
    {
        obj.parentChanged(p);
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getExplicitOrMeasuredWidth():Number
    {
        return obj.getExplicitOrMeasuredWidth() * Math.abs(obj.scaleX);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getExplicitOrMeasuredHeight():Number
    {
        return obj.getExplicitOrMeasuredHeight() * Math.abs(obj.scaleY);
    }
    
    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function setVisible(value:Boolean, noEvent:Boolean = false):void
    {
        obj.setVisible(value, noEvent);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function owns(displayObject:DisplayObject):Boolean
    {
        return obj.owns(displayObject);
    }

    
    //--------------------------------------------------------------------------
    //
    //
    // IFlexDisplayObject
    //
    //
    //--------------------------------------------------------------------------
    
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------


    //----------------------------------
    //  measuredHeight
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get measuredHeight():Number
    {
        return obj.measuredHeight * Math.abs(obj.scaleY);
    }

    //----------------------------------
    //  measuredWidth
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get measuredWidth():Number
    {
        return obj.measuredWidth * Math.abs(obj.scaleX);
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
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function move(x:Number, y:Number):void
    {
        obj.move(x, y);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function setActualSize(newWidth:Number, newHeight:Number):void
    {
        obj.setActualSize(newWidth / Math.abs(obj.scaleX), newHeight / Math.abs(obj.scaleY));
    }


    //--------------------------------------------------------------------------
    //
    //
    // IDisplayObject
    //
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get root():DisplayObject { return obj.root; }


    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get stage():Stage { return obj.stage; }


    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get name():String { return obj.name; }
    public function set name(value:String):void { obj.name = value; }


    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get parent():DisplayObjectContainer { return obj.parent; }


    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get mask():DisplayObject { return obj.mask; }
    public function set mask(value:DisplayObject):void { obj.mask = value; }


    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get visible():Boolean { return obj.visible; }
    public function set visible(value:Boolean):void { obj.visible = value; }


    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get x():Number { return obj.x; }
    public function set x(value:Number):void { obj.x = value; }


    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get y():Number { return obj.y; }
    public function set y(value:Number):void { obj.y = value; }


    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get scaleX():Number { return obj.scaleX; }
    public function set scaleX(value:Number):void { obj.scaleX = value; }


    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get scaleY():Number { return obj.scaleY; }
    public function set scaleY(value:Number):void { obj.scaleY = value; }


    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get mouseX():Number // note: no setter
    {
        return obj.mouseX;
    }


    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get mouseY():Number // note: no setter
    {
        return obj.mouseY;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get rotation():Number
    {
        return obj.rotation;
    }
    public function set rotation(value:Number):void
    {
        obj.rotation = value;
    }


    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get alpha():Number
    {
        return obj.alpha;
    }
    public function set alpha(value:Number):void
    {
        obj.alpha = value;
    }


    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get width():Number
    {
        return obj.width * Math.abs(obj.scaleX);   
    }
    public function set width(value:Number):void
    {
        obj.width = value / Math.abs(obj.scaleX);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get height():Number
    {
        return obj.height * Math.abs(obj.scaleY);
    }
    public function set height(value:Number):void
    {
        obj.height = value / Math.abs(obj.scaleY);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get cacheAsBitmap():Boolean
    {
        return obj.cacheAsBitmap;
    }
    public function set cacheAsBitmap(value:Boolean):void
    {
        obj.cacheAsBitmap = value;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get opaqueBackground():Object
    {
        return obj.opaqueBackground;
    }
    public function set opaqueBackground(value:Object):void
    {
        obj.opaqueBackground = value;
    }


    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get scrollRect():Rectangle
    {
        return obj.scrollRect;
    }
    public function set scrollRect(value:Rectangle):void
    {
        obj.scrollRect = value;
    }


    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get filters():Array
    {
        return obj.filters;
    }
    public function set filters(value:Array):void
    {
        obj.filters = value;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get blendMode():String
    {
        return obj.blendMode;
    }
    public function set blendMode(value:String):void
    {
        obj.blendMode = value;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get transform():Transform
    {
        return obj.transform;
    }
    public function set transform(value:Transform):void
    {
        obj.transform = value;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get scale9Grid():Rectangle
    {
        return obj.scale9Grid;
    }
    public function set scale9Grid(innerRectangle:Rectangle):void
    {
        obj.scale9Grid = innerRectangle;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function globalToLocal(point:Point):Point
    {
        return obj.globalToLocal(point);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function localToGlobal(point:Point):Point
    {
        return obj.localToGlobal(point);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getBounds(targetCoordinateSpace:DisplayObject):Rectangle
    {
        return obj.getBounds(targetCoordinateSpace);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getRect(targetCoordinateSpace:DisplayObject):Rectangle
    {
        return obj.getRect(targetCoordinateSpace);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get loaderInfo() : LoaderInfo
    {
        return obj.loaderInfo;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function hitTestObject(obj:DisplayObject):Boolean
    {
        return obj.hitTestObject(obj);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function hitTestPoint(x:Number, y:Number, shapeFlag:Boolean=false):Boolean
    {
        return hitTestPoint(x, y, shapeFlag);
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get accessibilityProperties() : AccessibilityProperties
    {
        return obj.accessibilityProperties;
    }
    public function set accessibilityProperties( value : AccessibilityProperties ) : void
    {
        obj.accessibilityProperties = value;
    }
    

    //--------------------------------------------------------------------------
    //
    //
    // IEventDispatcher
    //
    //
    //--------------------------------------------------------------------------
    
    
    public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
    {
        obj.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    public function dispatchEvent(event:Event):Boolean
    {
        return obj.dispatchEvent(event);
    }
    public function hasEventListener(type:String):Boolean
    {
        return obj.hasEventListener(type);
    }
    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
    {
        obj.removeEventListener(type, listener, useCapture);
    }
    
    public function willTrigger(type:String):Boolean
    {
        return obj.willTrigger(type);
    } 


    //--------------------------------------------------------------------------
    //
    //
    // IConstraintClient
    //
    //
    //--------------------------------------------------------------------------

    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  getConstraintValue
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getConstraintValue(constraintName:String):*
    {
        if (obj is IConstraintClient)
            return IConstraintClient(obj).getConstraintValue(constraintName);
        return null;
    }

    //----------------------------------
    //  setConstraintValue
    //----------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function setConstraintValue(constraintName:String, value:*):void
    {
        if (obj is IConstraintClient)
            IConstraintClient(obj).setConstraintValue(constraintName, value);
        else
            throw new Error("PostScaleAdapter can't set constraint value, underlying object is not an IConstraintClient");
    }
    
    //--------------------------------------------------------------------------
    //
    //
    // IInvalidating
    //
    //
    //--------------------------------------------------------------------------


    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function invalidateProperties():void
    {
        if (obj is IInvalidating)
            IInvalidating(obj).invalidateProperties();
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function invalidateSize():void
    {
        if (obj is IInvalidating)
            IInvalidating(obj).invalidateSize();
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function invalidateDisplayList():void
    {
        if (obj is IInvalidating)
            IInvalidating(obj).invalidateDisplayList();
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function validateNow():void
    {
        if (obj is IInvalidating)
            IInvalidating(obj).validateNow();
    }
}

}
