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
import flash.geom.Vector3D;

import mx.core.AdvancedLayoutFeatures;

[ExcludeClass]

/**
 *  @private
 *  The TransformUtil class is for internal use only.
 *  It is used for shared code between UIComponent, SpriteVisualElement, and
 *  UIMovieClip.
 */
public final class TransformUtil
{
    include "../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
   
    /**
     *  Returns true if the parameters indicate that AdvancedLayoutFeatures is
     *  needed.
     */
    private static function needAdvancedLayout(transformCenter:Vector3D,
                                               scale:Vector3D,
                                               rotation:Vector3D,
                                               translation:Vector3D,
                                               postLayoutScale:Vector3D,
                                               postLayoutRotation:Vector3D,
                                               postLayoutTranslation:Vector3D):Boolean
    {
        var needAdvancedLayout:Boolean = 
            (scale != null && ((!isNaN(scale.x) && scale.x != 1) || 
                (!isNaN(scale.y) && scale.y != 1) ||
                (!isNaN(scale.z) && scale.z != 1))) || 
            (rotation != null && ((!isNaN(rotation.x) && rotation.x != 0) || 
                (!isNaN(rotation.y) && rotation.y != 0) ||
                (!isNaN(rotation.z) && rotation.z != 0))) || 
            (translation != null && translation.z != 0 && !isNaN(translation.z)) ||
            postLayoutScale != null ||
            postLayoutRotation != null ||
            (postLayoutTranslation != null && 
                (translation == null ||
                    postLayoutTranslation.x != translation.x ||
                    postLayoutTranslation.y != translation.y ||
                    postLayoutTranslation.z != translation.z));
        
        return needAdvancedLayout;
    }
    
    private static var xformPt:Point;
    
    /**
     *  A utility method to update the rotation, scale, and translation of the 
     *  transform while keeping a particular point, specified in the component's 
     *  own coordinate space, fixed in the parent's coordinate space.  
     *  This function will assign the rotation, scale, and translation values 
     *  provided, then update the x/y/z properties as necessary to keep 
     *  the transform center fixed.
     *  
     *  If layoutFeatures is specified, then we delegate the calculations to 
     *  layoutFeatures. If layoutFeatures is null and an initLayoutFeatures function
     *  is specified, then we use the function to create the layoutFeatures object.
     */
    public static function transformAround(obj:DisplayObject,
                                           transformCenter:Vector3D,
                                           scale:Vector3D = null,
                                           rotation:Vector3D = null,
                                           translation:Vector3D = null,
                                           postLayoutScale:Vector3D = null,
                                           postLayoutRotation:Vector3D = null,
                                           postLayoutTranslation:Vector3D = null,
                                           layoutFeatures:AdvancedLayoutFeatures = null, 
                                           initLayoutFeatures:Function = null):void
    {
        var needAdvancedLayout:Boolean = (layoutFeatures ||
                                          needAdvancedLayout(transformCenter,
                                                             scale,
                                                             rotation,
                                                             translation,
                                                             postLayoutScale,
                                                             postLayoutRotation,
                                                             postLayoutTranslation));
        
        if (needAdvancedLayout)
        {
            // TODO (chaase): should provide a way to return to having no
            // layoutFeatures if we call this later with a more trivial
            // situation
            if (!layoutFeatures && initLayoutFeatures != null)
                layoutFeatures = initLayoutFeatures();
            
            if (layoutFeatures)
            {
                layoutFeatures.transformAround(transformCenter, scale, rotation,
                    translation, postLayoutScale, postLayoutRotation,
                    postLayoutTranslation);
            }
            return;
        }
        
        if (translation == null && transformCenter != null)
        {
            if (xformPt == null)
                xformPt = new Point();
            xformPt.x = transformCenter.x;
            xformPt.y = transformCenter.y;
            var xformedPt:Point =
                obj.transform.matrix.transformPoint(xformPt);
        }
        if (rotation != null && !isNaN(rotation.z))
            obj.rotation = rotation.z;
        if (scale != null)
        {
            obj.scaleX = scale.x;
            obj.scaleY = scale.y;
        }
        if (transformCenter == null)
        {
            if (translation != null)
            {
                obj.x = translation.x;
                obj.y = translation.y;
            }
        }
        else
        {
            if (xformPt == null)
                xformPt = new Point();
            xformPt.x = transformCenter.x;
            xformPt.y = transformCenter.y;
            var postXFormPoint:Point =
                obj.transform.matrix.transformPoint(xformPt);
            if (translation != null)
            {
                obj.x += translation.x - postXFormPoint.x;
                obj.y += translation.y - postXFormPoint.y;
            }
            else
            {
                obj.x += xformedPt.x - postXFormPoint.x;
                obj.y += xformedPt.y - postXFormPoint.y;
            }
        }
    }
    
    /**
     *  A utility method to transform a point specified in the local
     *  coordinates of the specified object to its location in the object's parent's
     *  coordinates. The pre-layout and post-layout result will be set on
     *  the <code>position</code> and <code>postLayoutPosition</code>
     *  parameters, if they are non-null.
     *  
     *  If layoutFeatures is specified, then we delegate the calculations to 
     *  layoutFeatures.
     * 
     *  @param obj The object whose local coordinates are used to transform the point.
     *  @param localPosition The point to be transformed, specified in the
     *  local coordinates of the object.
     *  @param position A Vector3D point that will hold the pre-layout
     *  result. If null, the parameter is ignored.
     *  @param postLayoutPosition A Vector3D point that will hold the post-layout
     *  result. If null, the parameter is ignored.
     *  @param layoutFeatures The layoutFeatures object to delegate these calculations to.
     */
    public static function transformPointToParent(obj:DisplayObject,
                                                  localPosition:Vector3D,
                                                  position:Vector3D, 
                                                  postLayoutPosition:Vector3D,
                                                  layoutFeatures:AdvancedLayoutFeatures):void
    {
        if (layoutFeatures)
        {
            layoutFeatures.transformPointToParent(true, localPosition,
                position, postLayoutPosition);
            return;
        }
        
        if (xformPt == null)
            xformPt = new Point();
        if (localPosition)
        {
            xformPt.x = localPosition.x;
            xformPt.y = localPosition.y;
        }
        else
        {
            xformPt.x = 0;
            xformPt.y = 0;
        }
        var tmp:Point = (obj.transform.matrix != null) ?
            obj.transform.matrix.transformPoint(xformPt) :
            xformPt;
        if (position != null)
        {            
            position.x = tmp.x;
            position.y = tmp.y;
            position.z = 0;
        }
        if (postLayoutPosition != null)
        {
            postLayoutPosition.x = tmp.x;
            postLayoutPosition.y = tmp.y;
            postLayoutPosition.z = 0;
        }
    }
}
}