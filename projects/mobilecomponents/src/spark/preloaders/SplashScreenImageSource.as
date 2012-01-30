package spark.preloaders
{
import mx.core.INavigatorContent;
import mx.core.mx_internal;

use namespace mx_internal;

/**
 *  SplashScreenImageSource specifies a Class (typically an embedded image)
 *  to be displayed as splash screen at a particular device configuration such as
 *  DPI, orientation and resolution.
 *
 *  Developers typically use one or more <code>SplashScreenImageSource</code>
 *  objects to define a <code>SplashScreenImage</code> class in MXML
 *  and set the Application's <code>splashScreenImage</code> property to that class.
 *
 *  @see spark.preloaders.SplashScreenImage
 *  @see spark.components.Application#splashScreenImage
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
     *  The required aspectRatio of the device.
     *  Can be either StageAspectRatio.PORTRAIT or StageAspectRatio.LANDSCAPE.
     * 
     *  <p>If not set <code>SplashScreenImage</code> ignores this.</p> 
     */ 
    public var aspectRatio:String = null;
    
    //----------------------------------
    //  dpi
    //----------------------------------

    [Inspectable(category="General", enumeration="160,240,320")]
    
    /**
     *  The required dpi of the device.
     *  
     *  <p>A value of NaN is ignored by <code>SplashScreenImage</code>.</p>
     * 
     *  @default NaN
     */ 
    public var dpi:Number = NaN;
    
    //----------------------------------
    //  minResolution
    //----------------------------------

    [Inspectable(category="General")]
    
    /**  
     *  The required minimum size of the device resolution needed to display the image.
     *  The device resolution is the maximum of the stage width and height, in pixels.
     * 
     *  This property can be used to display different images based on the pixel 
     *  resolution of a device.
     *
     *  <p>A value of NaN is ignored by the <code>SplashScreenImage</code>.</p>
     * 
     *  @default NaN
     */ 
    public var minResolution:Number = NaN;
    
    //----------------------------------
    //  source
    //----------------------------------

    [Inspectable(category="General")]

    /**
     *  The image class for the splash screen to use for the defined
     *  device configuration.  Typically you set this property to an 
     *  embedded resource.
     * 
     *  For example:
     *
     *  <pre>source="&#64;Embed('Default.png')"</pre>
     * 
     *  @see spark.preloaders.SplashScreenImage
     *
     *  @default null
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