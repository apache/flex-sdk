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

package flex.layout
{

import flash.events.Event;
import flash.geom.Rectangle;
import flash.geom.Point;

import flex.core.GroupBase;
import flex.intf.ILayout;
import flex.intf.ILayoutItem;
import flash.events.EventDispatcher;

    
public class LayoutBase extends EventDispatcher implements ILayout
{
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    protected static function hasPercentWidth(layoutItem:ILayoutItem):Boolean
    {
        return !isNaN( layoutItem.percentSize.x );
    }
    
    protected static function hasPercentHeight(layoutItem:ILayoutItem):Boolean
    {
        return !isNaN( layoutItem.percentSize.y );
    }

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    public function LayoutBase()
    {
        super();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  target
    //----------------------------------    

    private var _target:GroupBase;
    
    public function get target():GroupBase
    {
        return _target;
    }
    
    public function set target(value:GroupBase):void
    {
        _target = value;
    }
    
    //----------------------------------
    //  horizontalScrollPosition
    //----------------------------------
        
    private var _horizontalScrollPosition:Number = 0;
    
    [Bindable]
    [Inspectable(category="General")]
    
    /**
     *  The X coordinate of the origin of the region the target is
     *  scrolled to.  
     * 
     *  Setting this property causes the target's 
     *  <code>scrollRect</code> to be set, if necessary, to:
     *  <pre>
     *  new Rectangle(horizontalScrollPosition, verticalScrollPosition, width, height)
     *  </pre>
     *  Where <code>width</code> and <code>height</code> are properties
     *  of the target.
     * 
     *  @default 0
     *  @see target
     *  @see verticalScrollPosition
     */
    public function get horizontalScrollPosition():Number 
    {
        return _horizontalScrollPosition;
    }
    
    /**
     *  @private
     */
    public function set horizontalScrollPosition(value:Number):void 
    {
        if (value == _horizontalScrollPosition) 
            return;
    
        _horizontalScrollPosition = value;
        scrollPositionChanged();
    }
    
    //----------------------------------
    //  verticalScrollPosition
    //----------------------------------

    private var _verticalScrollPosition:Number = 0;
    
    [Bindable]
    [Inspectable(category="General")]    
    
    /**
     *  The Y coordinate of the origin of the region this Group is
     *  scrolled to.  
     * 
     *  Setting this property causes the <code>scrollRect</code> to
     *  be set, if necessary, to:
     *  <pre>
     *  new Rectangle(horizontalScrollPosition, verticalScrollPosition, width, height)
     *  </pre>                 
     *  Where <code>width</code> and <code>height</code> are properties
     *  of the target.
     * 
     *  @default 0
     *  @see horizontalScrollPosition
     */
    public function get verticalScrollPosition():Number 
    {
        return _verticalScrollPosition;
    }
    
    /**
     *  @private
     */
    public function set verticalScrollPosition(value:Number):void 
    {
        if (value == _verticalScrollPosition)
            return;
            
        _verticalScrollPosition = value;
        scrollPositionChanged();
    }    

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Called when the verticalScrollPosition or horizontalScrollPosition 
     *  properties change.
     * 
     *  Resets the target's scrollRect property by calling
     *  <code>updateScrollRect()</code>.
     * 
     *  Subclasses can override this method to compute other values that are
     *  based on the current scrollPosition or scrollRect.
     * 
     *  @see updateScrollRect
     */  
    protected function scrollPositionChanged():void
    {
        var g:GroupBase = target;
        if (!g)
            return;

        updateScrollRect(g.width, g.height);
        // TBD: subclasses override to update first,lastIndexInView 
    }
    
    /**
     *  Conditionally sets the origin of the scrollRect to 
     *  verticalScrollPosition,horizontalScrollPosition and its width
     *  width,height to w,h (the target's unscaled width,height).
     * 
     *  This method must be called by updateDisplayList after the 
     *  target's contentWidth and contentHeight properties have been 
     *  set to the display list's actual limits.
     * 
     *  The target's scrollRect property is set if its contentWidth,Height
     *  is larger than its width,height, or the target's 
     *  vertical,horizontalScrollPosition is non-zero.
     * 
     *  If none of the above conditions are true, the scrollRect
     *  is set to null.
     * 
     *  @param w The target's unscaled width.
     *  @param h The target's unscaled height.
     * 
     *  @see target
     *  @see updateDisplayList
     *  @see flex.core.GroupBase#contentWidth
     *  @see flex.core.GroupBase#contentHeight
     */ 
    protected function updateScrollRect(w:Number, h:Number):void
    {
        var g:GroupBase = target;
        if (!g)
            return;

        var hsp:Number = horizontalScrollPosition;
        var vsp:Number = verticalScrollPosition;
        var cw:Number = g.contentWidth;
        var ch:Number = g.contentHeight;
            
        // Don't set the scrollRect needlessly.
        if ((hsp != 0) || (vsp != 0) || (cw > w) || (ch > h))
            g.scrollRect = new Rectangle(hsp, vsp, w, h);
        else 
            g.scrollRect = null;
    } 
    
    /**
     *  Convenience function for subclasses that invalidates the
     *  target's size and displayList if the target is non-null.
     * 
     *  @see mx.core.UIComponent#invalidateSize
     *  @see mx.core.UIComponent#invalidateDisplayList
     */
    protected function invalidateTargetSizeAndDisplayList():void
    {
        var g:GroupBase = target;
        if (!g)
            return;

        g.invalidateSize();
        g.invalidateDisplayList();
    }
    
    /**
     *  @copy mx.core.UIComponent#measure
     */
    public function measure():void
    {
    }
    
    /**
     *  @copy mx.core.UIComponent#updateDisplayList
     */
    public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
    }          
}

}