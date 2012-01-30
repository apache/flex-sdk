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

package mx.geom
{
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.PerspectiveProjection;
import flash.geom.Rectangle;
import flash.geom.Transform;

import mx.core.ILayoutElement;
import mx.core.IVisualElement;
import mx.core.mx_internal;

use namespace mx_internal;
	
/**
 *  The mx.geom.Transform class adds synchronization support on top of the flash.geom.Transform class.  
 *  The class has a target property which is the IVisualElement that the Transform has been assigned to. 
 *  The IVisualElement implementations will typically set the target to themselves when the Transform
 *  is assigned to their transform property. 
 * 
 *  Changes to the Transform properties automatically get pushed to the target. Reading from the Transform
 *  properties reads directly from the target's transform. 
 * 
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */	
public class Transform extends flash.geom.Transform
{
    /**
     *  Constructor
     * 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */        
    public function Transform(src:DisplayObject = null)
    {        
        if (src == null)
            src = new Shape();
        super(src);        
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden flash.geom.Transform Properties
    //
    //--------------------------------------------------------------------------

    mx_internal var applyColorTransformAlpha:Boolean = false;
    
    mx_internal var applyMatrix:Boolean = false;
    
    mx_internal var applyMatrix3D:Boolean = false;
    
    /**
     *  @private
     */ 
    override public function set colorTransform(value:ColorTransform):void
    {   
        if (target && "$transform" in target) // UIComponent/UIMovieClip
            target["$transform"]["colorTransform"] = value;
        else if (target && "setColorTransform" in target)
            target["setColorTransform"](value);            
        else
            super.colorTransform = value;
        
        applyColorTransformAlpha = true;
    }
    
    /**
     *  @private
     */     
    override public function get colorTransform():ColorTransform
    {
        if (target && "$transform" in target) // UIComponent/UIMovieClip    
            return target["$transform"]["colorTransform"];
        else if (target && "displayObject" in target && target["displayObject"] != null)
            return target["displayObject"]["transform"]["colorTransform"];
        else
            return super.colorTransform;    
    }
    
    /**
     *  @private
     */     
    override public function get concatenatedColorTransform():ColorTransform
    {
        if (target && "$transform" in target) // UIComponent/UIMovieClip
            return target["$transform"]["concatenatedColorTransform"];
        else if (target && "displayObject" in target && target["displayObject"] != null)
            return target["displayObject"]["transform"]["concatenatedColorTransform"];
        else
            return super.concatenatedColorTransform;    
    }

    /**
     *  @private
     */     
    override public function get concatenatedMatrix():Matrix
    {
        if (target && "$transform" in target) // UIComponent/UIMovieClip
            return target["$transform"]["concatenatedMatrix"];
        else if (target && "displayObject" in target && target["displayObject"] != null)
            return target["displayObject"]["transform"]["concatenatedMatrix"];
        else
            return super.concatenatedMatrix;
    }

    /**
     *  @private
     */ 
    override public function set matrix(value:Matrix):void
    {
        if (target is ILayoutElement && value != null)
            ILayoutElement(target).setLayoutMatrix(value, true);
        else 
            super.matrix = value;
        
        applyMatrix = value != null;
        applyMatrix3D = false;
    }

    /**
     *  @private
     */     
    override public function get matrix():Matrix
    {
        if (target is ILayoutElement)
            return ILayoutElement(target).getLayoutMatrix();
        else
            return super.matrix;
    }
    
    // TODO (jszeto): SDK-22046 If the Player team changes the return type, 
    // we will need to update
    override public function set matrix3D(value:Matrix3D):* 
    {
        if (target is ILayoutElement && value != null)
            ILayoutElement(target).setLayoutMatrix3D(value, true);
        else 
            super.matrix3D = value;
        
        applyMatrix3D = value != null;
        applyMatrix = false;
    }

    /**
     *  @private
     */     
    override public function get matrix3D():Matrix3D
    {
        if (target is ILayoutElement)
            return ILayoutElement(target).getLayoutMatrix3D();
        else
            return super.matrix3D;
    }

    /**
     *  @private
     */     
    override public function set perspectiveProjection(value:PerspectiveProjection):void
    {
        // TODO (jszeto): Implement this
        var oldValue:PerspectiveProjection = super.perspectiveProjection;
        super.perspectiveProjection = value;    
        
    }

    /**
     *  @private
     */     
    override public function get perspectiveProjection():PerspectiveProjection
    {
        if (target && "$transform" in target) // UIComponent/UIMovieClip
            return target["$transform"]["perspectiveProjection"];
        else if (target && "displayObject" in target && target["displayObject"] != null)
            return target["displayObject"]["transform"]["perspectiveProjection"];
        else
            return super.perspectiveProjection;    
    }
    
    /**
     *  @private
     */     
    override public function get pixelBounds():Rectangle
    {
        if (target && "$transform" in target) // UIComponent/UIMovieClip
            return target["$transform"]["pixelBounds"];
        else if (target && "displayObject" in target && target["displayObject"] != null)
            return target["displayObject"]["transform"]["pixelBounds"];
        else
            return super.pixelBounds;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------    
    
    private var _target:IVisualElement;

    /**
     *  The IVisualElement with which the Transform will keep in synch. 
     *  The IVisualElement implementations will typically set the target to
     *  themselves when the Transform is assigned to their transform property. 
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */     
    public function set target(value:IVisualElement):void
    {
        if (value !== _target)
            _target = value;
    }
    
    /**
     *  @private
     */ 
    public function get target():IVisualElement
    {
        return _target;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden flash.geom.Transform Methods
    //
    //--------------------------------------------------------------------------

    override public function getRelativeMatrix3D(relativeTo:DisplayObject):Matrix3D
    {
        if (target && "$transform" in target) // UIComponent/UIMovieClip
            return target["$transform"]["getRelativeMatrix3D"](relativeTo);
        else if (target && "displayObject" in target && target["displayObject"] != null)
            return target["displayObject"]["transform"]["getRelativeMatrix3D"](relativeTo);
        else
            return super.getRelativeMatrix3D(relativeTo);
    }
}
}