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
package spark.effects
{
import flash.display.BitmapData;    
import flash.display.IBitmapDrawable;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

import mx.core.IUIComponent;
import mx.effects.IEffectInstance;
import spark.effects.supportClasses.AnimateShaderTransitionInstance;
import spark.primitives.supportClasses.GraphicElement;
import mx.resources.IResourceManager;
import mx.resources.ResourceManager;

//--------------------------------------
//  Other metadata
//--------------------------------------

[ResourceBundle("sparkEffects")]

/**
 * The AnimateShaderTransition effect animates a transition between two bitmaps,
 * one representing the start state (<code>bitmapFrom</code>), and
 * the other representing the end state (<code>bitmapTo</code>).
 * 
 * <p>The animation is performed by running a pixel-shader program,
 * specified by the <code>shader</code> property,
 * using the two bitmaps as input. 
 * The bitmaps are represented by an instance of the flash.display.BitmapData class.
 * You can create your own pixel-shader program 
 * by using Adobe Pixel Bender Toolkit.</p>
 *
 * <p>If either bitmap is
 * not supplied, that value will be determined dynamically from
 * either the appropriate state of the target in a transition or, 
 * if the effect is not running in a transition, from the 
 * target directly. If
 * the effect is run in a transition and the target object either
 * goes away or comes into existence during that state change,
 * then a fully-transparent bitmap will be used to represent
 * that object when it does not exist.</p>
 * 
 * <p>This effect can only be run on targets that are either 
 * UIComponents or GraphicElements, since capturing the bitmap
 * of the object requires information about the object that only
 * exists in these classes.</p>
 * 
 * <p>Because the effect is bitmap-based, and the underlying
 * pixel-shader program expects both bitmaps to be the same size,
 * the effect will only work correctly when both bitmaps are
 * of the same size. This means that if the target object changes
 * size or changes orientation leading to a different size bounding
 * box, then the effect may not play correctly.</p>
 * 
 * <p>This effect and its subclasses differ from other effects in
 * Flex in that they are intended to work on their own, and may
 * not have the intended result when run in parallel with other effects.
 * This constraint comes from the fact that both of the before and after
 * bitmaps are captured prior to the start of the effect. So if something
 * happens to the target object after these bitmaps are calculated,
 * such as another effect changing the target's properties, then those
 * changes will not be accounted for in the pre-calculated bitmap and
 * the results may not be as expected. To ensure correct playing of
 * these bitmap-based effects, they should be played alone on
 * their target objects.</p>
 *  
 *  @mxml
 *
 *  <p>The <code>&lt;mx:AnimateShaderTransition&gt;</code> tag
 *  inherits all of the tag attributes of its superclass,
 *  and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;mx:AnimateShaderTransition
 *    <b>Properties</b>
 *    id="ID"
 *    bitmapFrom="no default"
 *    bitmapTo="no default"
 *    shaderCode="no default"
 *    sahderProperties="no default"
 *  /&gt;
 *  </pre>
 * 
 *  @see flash.display.BitmapData
 *  @see spark.effects.supportClasses.AnimateShaderTransitionInstance
 *  @see spark.primitives.GraphicElement
 *  @see flash.display.DisplayObject
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class AnimateShaderTransition extends Animate
{
    
    /**
     *  Constructor. 
     *
     *  @param target The Object to animate with this effect.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
     public function AnimateShaderTransition(target:Object=null)
    {
        super(target);

        instanceClass = AnimateShaderTransitionInstance;
    }
   
    
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Storage for the resourceManager getter.
     *  This gets initialized on first access,
     *  not at static initialization time, in order to ensure
     *  that the Singleton registry has already been initialized.
     */
    private static var _resourceManager:IResourceManager;
    
    /**
     *  @private
     *  A reference to the object which manages
     *  all of the application's localized resources.
     *  This is a singleton instance which implements
     *  the IResourceManager interface.
     */
    private static function get resourceManager():IResourceManager
    {
        if (!_resourceManager)
            _resourceManager = ResourceManager.getInstance();

        return _resourceManager;
    }
    
    /**
     * The bitmap data representing the start state of this effect.
     * If this property is not set, it is calculated automatically
     * when the effect is played by taking a snapshot of the target
     * object, or by using a transparent bitmap if the object does not
     * exist in the start view state of a transition.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var bitmapFrom:BitmapData;
    
    /**
     * The bitmap data representing the end state of this effect.
     * If this property is not set, it is calculated automatically
     * when the effect is played by taking a snapshot of the target
     * object, or by using a transparent bitmap if the object does not
     * exist in the end view state of a transition.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var bitmapTo:BitmapData;

    /**
     * The bytecode for the pixel-shader program that the effect uses
     * to animate between the two bitmaps. This
     * property can be represented as either a ByteArray or as a
     * Class representing a ByteArray (which is what results 
     * when you embed a resource).
     * 
     * <p>The pixel-shader program can have arbitrary functionality and inputs, but 
     * must, at a minimum, have three <code>image4</code> inputs.
     * The first input, which can be named anything, should go
     * unused by your pixel-shader program  code - it exists only to satisfy the
     * Flash requirement of assigning a filtered object to the
     * first input. Note that inputs that go completely unused in a
     * pixel-shader program might be optimized out, so your code should
     * at least reference this input once.</p>
     * 
     * <p>There must be at least two other input bitmaps
     * named <code>from</code> and <code>to</code> 
     * which represent the before and after bitmap images.
     * Finally, you must define one 
     * <code>float</code> parameter named <code>progress</code>
     * that contains the elapsed fraction of the effect.</p>
     * 
     * <p>You can specify two optional parameters, <code>width</code>
     * and <code>height</code>. If they exist, they 
     * are automatically set to the width and height of the
     * effect target.</p>
     * 
     * <p>See the Pixel Bender Toolkit documentation for more
     * information on writing pixel-shader programs for Flash. 
     * You can also look at the source code for the CrossFade.pbk file in the 
     * frameworks\projects\flex4\src\spark\effects directory of the Flex source code.</p>
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var shaderCode:Object;
    
    /**
     * A map of parameter name/value pairs passed to the pixel-shader program 
     * prior to playing. For example,
     * to set a parameter named <code>direction</code> in a
     * shader with a Pixel Bender pbj file in Wipe.pbj, the calling 
     * code could do the following:
     * 
     * @example <listing version="3.0">
     *   [Embed(source="Wipe.pbj", mimeType="application/octet-stream")]
     *   private var WipeCodeClass:Class;
     *   var shaderEffect = new AnimateShaderTransition();
     *   shaderEffect.shaderCode = WipeCodeClass;
     *   shaderEffect.shaderProperties = {direction : 1};
     * </listing>
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var shaderProperties:Object;
    
    /**
     *  @private
     */
    override public function getAffectedProperties():Array /* of String */
    {
        // We track visible and parent so that we can automatically
        // perform transitions from/to states where the target either
        // does not exist or is not visible
        return ["bitmap", "visible", "parent"];
    }

    /**
     *  @private
     */
    override protected function getValueFromTarget(target:Object, property:String):*
    {
        if (property != "bitmap")
            return super.getValueFromTarget(target, property);

        // Return a null bitmap for non-visible targets        
        if (!target.visible || !target.parent)
            return null;

        return getSnapshot(target);
    }
    
    /**
     *  Creates the bitmap image for either the before or after stateof the target, if necessary.
     *
     *  @param target The Object to animate with this effect.  
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public static function getSnapshot(target:Object):BitmapData
    {
        if (target is GraphicElement)
            return GraphicElement(target).getBitmapData(true, 0, false);
        else if (!(target is IUIComponent))
            throw new Error(resourceManager.getString("sparkEffects", "cannotOperateOn"));
        // TODO (chaase): Does this utility function belong in a more central
        // location, like UIComponent, or as part of ImageSnapshot?
        
        var topLevel:Sprite = Sprite(IUIComponent(target).systemManager);   
        var rectBounds:Rectangle = target.getBounds(topLevel);
        var m:Matrix = target.transform.concatenatedMatrix;
        // truncate position because the fractional offset will already be figured
        // into the filter placement onto the target. 
        // TODO (chaase): There are still some offset
        // problems with objects inside of rotated parents, depending on the angle.
        if (m)
            m.translate(-(Math.floor(rectBounds.x)), -(Math.floor(rectBounds.y)));
        var bmData:BitmapData = new BitmapData(rectBounds.width, 
            rectBounds.height, true, 0);
        bmData.draw(IBitmapDrawable(target), m);

        return bmData;
    }

    /**
     *  @private
     */
    override protected function initInstance(instance:IEffectInstance):void
    {
        super.initInstance(instance);
        
        var animateShaderTransitionInstance:AnimateShaderTransitionInstance = 
            AnimateShaderTransitionInstance(instance);

        animateShaderTransitionInstance.bitmapFrom = bitmapFrom;
        animateShaderTransitionInstance.bitmapTo = bitmapTo;

        if (!shaderCode)
            // User should always supply a shader, but if they don't just 
            // pass it on
            animateShaderTransitionInstance.shaderCode = null;
        else
            animateShaderTransitionInstance.shaderCode = 
                (shaderCode is ByteArray) ?
                ByteArray(shaderCode) :
                new shaderCode();
        animateShaderTransitionInstance.shaderProperties = shaderProperties;
    }
}
}