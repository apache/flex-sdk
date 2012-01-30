////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2011 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.preloaders
{
import mx.core.INavigatorContent;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  Use the SplashScreenImageSource class to specify a Class (typically an embedded image)
 *  to be displayed as splash screen at a particular device configuration such as
 *  DPI, orientation and resolution.
 *
 *  <p>You typically use one or more SplashScreenImageSource
 *  objects to define a SplashScreenImage class in MXML
 *  and set the application's <code>splashScreenImage</code> property to that class.</p>
 *
 *  <p>Shown below is SplashScreenImage component with three different 
 *  definitions for SplashScreenImageSource:</p>
 *
 *  <pre>
 *    &lt;?xml version="1.0" encoding="utf-8"?&gt; 
 *    &lt;s:SplashScreenImage xmlns:fx="http://ns.adobe.com/mxml/2009" 
 *        xmlns:s="library://ns.adobe.com/flex/spark"&gt; 
 *     
 *        &lt;!-- Default splashscreen image. --&gt; 
 *        &lt;s:SplashScreenImageSource 
 *            source="&#64;Embed('assets/logoDefault.jpg')"/&gt; 
 *        
 *        &lt;s:SplashScreenImageSource 
 *            source="&#64;Embed('assets/logo240Portrait.jpg')" 
 *            dpi="240" 
 *            aspectRatio="portrait"/&gt; 
 *        
 *        &lt;s:SplashScreenImageSource 
 *            source="&#64;Embed('assets/logo240Landscape.jpg')" 
 *            dpi="240" 
 *            aspectRatio="landscape"/&gt; 
 *        
 *    &lt;/s:SplashScreenImage&gt;      
 *  </pre>
 *
 *  @mxml
 *  
 *  <p>The <code>&lt;s:SplashScreenImageSource&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *  
 *  <pre>
 *  &lt;s:SplashScreenImageSource
 *   <strong>Properties</strong>
 *    aspectRatio="null"
 *    dpi="NaN"
 *    minResolution="NaN"
 *    source="null"
 *  &gt;
 *  </pre>
 *
 *  @see spark.preloaders.SplashScreenImage
 *  @see spark.components.Application#splashScreenImage
 *  
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */  
public class SplashScreenImageSource
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
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public function SplashScreenImageSource()
    {
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  aspectRatio
    //----------------------------------

    [Inspectable(category="General", enumeration="portrait,landscape")]

    /**
     *  The required aspect ratio of the mobile device.
     *  This property can be either <code>flash.display.StageAspectRatio.PORTRAIT</code> 
     *  or <code>flash.display.StageAspectRatio.LANDSCAPE</code>.
     * 
     *  <p>If not set, then <code>SplashScreenImage</code> ignores this property.</p> 
     *
     *  @see flash.display.StageAspectRatio
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public var aspectRatio:String = null;
    
    //----------------------------------
    //  dpi
    //----------------------------------

    [Inspectable(category="General", enumeration="160,240,320")]
    
    /**
     *  The required DPI of the device to display the associated image.
     *  
     *  <p>A value of NaN means the property is ignored by SplashScreenImage.</p>
     * 
     *  @default NaN
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public var dpi:Number = NaN;
    
    //----------------------------------
    //  minResolution
    //----------------------------------

    [Inspectable(category="General")]
    
    /**  
     *  The required minimum size of the mobile device's resolution needed 
     *  to display the image.
     *  The device resolution is the maximum of the stage width and height, in pixels.
     *  The value of the <code>minResolution</code> property is compared against the larger 
     *  of the values of the <code>Stage.stageWidth</code> and <code>Stage.stageHeight</code> properties. 
     *  The larger of the two values must be equal to or greater than the <code>minResolution</code> property.
     * 
     *  <p>You can use this property to display different images based on the pixel 
     *  resolution of a device.</p>
     *
     *  <p>A value of NaN means the property is ignored by the SplashScreenImage.</p>
     * 
     *  @default NaN
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public var minResolution:Number = NaN;
    
    //----------------------------------
    //  source
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  The image class for the splash screen to use for the defined
     *  device configuration.  
     *  Typically you set this property to an embedded resource.
     * 
     *  <p>For example:</p>
     *
     *  <pre>
     *        &lt;s:SplashScreenImageSource 
     *            source="&#64;Embed('assets/logo240Portrait.jpg')" 
     *            dpi="240" 
     *            aspectRatio="portrait"/&gt; 
     *  </pre>
     * 
     *  @see spark.preloaders.SplashScreenImage
     *
     *  @default null
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */ 
    public var source:Class;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *
     *  Returns true when this SplashScreenImageSource is applicable to the
     *  specified device config. 
     */
    mx_internal function matches(aspectRatio:String, dpi:Number, resolution:Number):Boolean
    {
        return (!this.aspectRatio || this.aspectRatio == aspectRatio) &&
               (isNaN(this.dpi) || this.dpi == dpi) &&
               (isNaN(this.minResolution) || this.minResolution <= resolution);       
    }

    /**
     *  @private
     * 
     *  Helper function to use when sorting SplashScreenImageSource objects.
     * 
     *  More specific (with more explicit settings) objects will end up in the beginning of
     *  the sorted array.
     */
    mx_internal function betterThan(source:SplashScreenImageSource):Boolean
    {
        if (this.specificity() != source.specificity())
        {
            return this.specificity() > source.specificity();
        }
        else
        {
           return getMinResolution() > source.getMinResolution();
        }
    }
    
    /**
     *  @private 
     *  Helper function used when comparing two SplashScreenImageSource objects 
     */
    private function getMinResolution():Number
    {
        return isNaN(minResolution) ? 0 : minResolution;
    }

    /**
     *  @private
     *  Returns how many explicit settings there are for this SplashScreenImageSource 
     */    
    private function specificity():int
    {
        var result:int = 0;
        
        if (aspectRatio)
            result++;
        
        if (!isNaN(dpi))
            result++;
        
        if (!isNaN(minResolution))
            result++;

        return result;
    }
}
}