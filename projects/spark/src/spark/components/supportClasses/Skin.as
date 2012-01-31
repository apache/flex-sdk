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

// AdobePatentID="B976"

package spark.components.supportClasses
{   
    
import flash.display.DisplayObject;

import mx.core.FlexVersion;
import mx.core.UIComponent;
import mx.core.mx_internal;

import spark.components.Group;
import spark.core.DisplayObjectSharingMode;
import spark.core.IGraphicElement;
import spark.skins.IHighlightBitmapCaptureClient;

use namespace mx_internal;

/**
 *  The Skin class defines the base class for all skins used by skinnable components. 
 *  The SkinnableComponent class defines the base class for skinnable components.
 *
 *  <p>You typically write the skin classes in MXML, as the followiong example shows:</p>
 *
 *  <pre>  &lt;?xml version="1.0"?&gt;
 *  &lt;Skin xmlns="http://ns.adobe.com/mxml/2009"&gt;
 *  
 *  &lt;Metadata&gt;
 *          &lt;!-- Specify the component that uses this skin class. --&gt;
 *          [HostComponent("my.component.MyComponent")]
 *      &lt;/Metadata&gt; 
 *      
 *      &lt;states&gt;
 *          &lt;!-- Specify the states controlled by this skin. --&gt;
 *      &lt;/states&gt;
 *          
 *      &lt;!-- Define skin. --&gt;
 *  
 *  &lt;/Skin&gt;</pre>
 *
 *  @see mx.core.SkinnableComponent
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class Skin extends Group implements IHighlightBitmapCaptureClient
{
    include "../../core/Version.as";

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
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */    
    public function Skin()
    {
        super();
    }

    /**
     *  List of id's of items that should be excluded when rendering the focus ring.
     *  Only items of type DisplayObject or GraphicElement should be excluded. Items
     *  of other types will be ignored.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get focusSkinExclusions():Array 
    {
        return null;
    }
    
    private static var exclusionAlphaValues:Array;

    /**
     *  Called before a bitmap capture is made for this skin. The default implementation
     *  excludes items in the <code>focusSkinExclusions</code> array.
     * 
     *  @return <code>true</code> if the component must be redrawn. Otherwise, <code>false</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function beginHighlightBitmapCapture():Boolean
    {
        var exclusions:Array = focusSkinExclusions;
        if (!exclusions)
        {
            if (("hostComponent" in this) && this["hostComponent"] is SkinnableComponent)
                exclusions = SkinnableComponent(this["hostComponent"]).suggestedFocusSkinExclusions;
        }
        var exclusionCount:Number = (exclusions == null) ? 0 : exclusions.length;
        
        /* we'll store off the previous alpha of the exclusions so we
        can restore them when we're done
        */
        exclusionAlphaValues = [];
        var needRedraw:Boolean = false;
        
        for (var i:int = 0; i < exclusionCount; i++)        
        {
            // skip if the part isn't there
            if (!(exclusions[i] in this))
                continue;

            var ex:Object = this[exclusions[i]];
            /* we're going to go under the covers here to try and modify alpha with the least
            amount of disruption to the component.  For UIComponents, we go to Sprite's alpha property;
            */
            if (ex is UIComponent)
            {
                exclusionAlphaValues[i] = (ex as UIComponent).$alpha; 
                (ex as UIComponent).$alpha = 0;
            } 
            else if (ex is DisplayObject)
            {
                exclusionAlphaValues[i] = (ex as DisplayObject).alpha; 
                (ex as DisplayObject).alpha = 0;
            }
            else if (ex is IGraphicElement) 
            {
                /* if we're lucky, the IGE has its own DisplayObject, and we can just trip its alpha.
                If not, we're going to have to set it to 0, and force a redraw of the whole component */
                var ge:IGraphicElement = ex as IGraphicElement;
                if (ge.displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
                {
                    exclusionAlphaValues[i] = ge.displayObject.alpha;
                    ge.displayObject.alpha = 0;
                }
                else
                {
                    exclusionAlphaValues[i] = ge.alpha;
                    ge.alpha = 0;
                    needRedraw = true;
                }
            }
        }   
        
        /* if we excluded an IGE without its own DO, we need to update the component before grabbing the bitmap */
        return needRedraw;
    }
    
    /**
     *  Called after a bitmap capture is made for this skin. The default implementation 
     *  restores the items in the <code>focusSkinExclusions</code> array.
     * 
     *  @return <code>true</code> if the component must be redrawn. Otherwise, <code>false</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function endHighlightBitmapCapture():Boolean
    {
        var exclusions:Array = focusSkinExclusions;
        if (!exclusions)
        {
            if (this["hostComponent"] is SkinnableComponent)
                exclusions = SkinnableComponent(this["hostComponent"]).suggestedFocusSkinExclusions;
        }
        var exclusionCount:Number = (exclusions == null) ? 0 : exclusions.length;
        var needRedraw:Boolean = false;
        
        for (var i:int=0; i < exclusionCount; i++)      
        {
            // skip if the part isn't there
            if (!(exclusions[i] in this))
                continue;

            var ex:Object = this[exclusions[i]];
            if (ex is UIComponent)
            {
                (ex as UIComponent).$alpha = exclusionAlphaValues[i];
            } 
            else if (ex is DisplayObject)
            {
                (ex as DisplayObject).alpha = exclusionAlphaValues[i];
            }
            else if (ex is IGraphicElement) 
            {
                var ge:IGraphicElement = ex as IGraphicElement;
                if (ge.displayObjectSharingMode == DisplayObjectSharingMode.OWNS_UNSHARED_OBJECT)
                {
                    ge.displayObject.alpha = exclusionAlphaValues[i];
                }
                else
                {
                    ge.alpha = exclusionAlphaValues[i];         
                    needRedraw = true;
                }
            }
        }
        
        exclusionAlphaValues = null;
        
        return needRedraw;
    }
    
    /**
     *  @private 
     */ 
    override protected function initializeAccessibility():void
    {
        // Do nothing. Skins shouldn't support accessibility
    }

    /**
     *  @private
     *  Make the component's explicitMinWidth property override its skin's.
     *  This is useful for cases where the skin's minWidth constrains
     *  the skin's measured size. In those cases the user could set
     *  explicit limits on the component itself thus relaxing the
     *  hard-coded limits in the skin. See SDK-24741.
     */
    override public function get explicitMinWidth():Number
    {
        if (parent is SkinnableComponent)
        {
            var parentExplicitMinWidth:Number = SkinnableComponent(parent).explicitMinWidth;
            if (!isNaN(parentExplicitMinWidth))
                return parentExplicitMinWidth;
        }
        return super.explicitMinWidth;
    }

    /**
     *  @private
     *  Make the component's explicitMinWidth property override its skin's.
     *  This is useful for cases where the skin's minWidth constrains
     *  the skin's measured size. In those cases the user could set
     *  explicit limits on the component itself thus relaxing the
     *  hard-coded limits in the skin. See SDK-24741.
     */
    override public function get explicitMinHeight():Number
    {
        if (parent is SkinnableComponent)
        {
            var parentExplicitMinHeight:Number = SkinnableComponent(parent).explicitMinHeight;
            if (!isNaN(parentExplicitMinHeight))
                return parentExplicitMinHeight;
        }
        return super.explicitMinHeight;
    }

    /**
     *  @private
     *  Make the component's explicitMinWidth property override its skin's.
     *  This is useful for cases where the skin's minWidth constrains
     *  the skin's measured size. In those cases the user could set
     *  explicit limits on the component itself thus relaxing the
     *  hard-coded limits in the skin. See SDK-24741.
     */
    override public function get explicitMaxWidth():Number
    {
        if (parent is SkinnableComponent)
        {
            var parentExplicitMaxWidth:Number = SkinnableComponent(parent).explicitMaxWidth;
            if (!isNaN(parentExplicitMaxWidth))
                return parentExplicitMaxWidth;
        }
        return super.explicitMaxWidth;
    }

    /**
     *  @private
     *  Make the component's explicitMinWidth property override its skin's.
     *  This is useful for cases where the skin's minWidth constrains
     *  the skin's measured size. In those cases the user could set
     *  explicit limits on the component itself thus relaxing the
     *  hard-coded limits in the skin. See SDK-24741.
     */
    override public function get explicitMaxHeight():Number
    {
        if (parent is SkinnableComponent)
        {
            var parentExplicitMaxHeight:Number = SkinnableComponent(parent).explicitMaxHeight;
            if (!isNaN(parentExplicitMaxHeight))
                return parentExplicitMaxHeight;
        }
        return super.explicitMaxHeight;
    }
    
    /**
     *  @private 
     */
    override protected function canSkipMeasurement():Boolean
    {
        if (FlexVersion.compatibilityVersion < FlexVersion.VERSION_4_5)
        {
            return super.canSkipMeasurement();
        }

        // Explicit width/height on the skin should mean "the default size".
        // As such, we should still measure so that we get correct measuredWidth,
        // measuredHeight, measuredMinWidth, measuredMinHeight.
        // Look at the SkinnableComponent's measure() to see how these are used.
        return false;
    }
}

}
