package flex.filters
{
	
import flash.filters.BitmapFilter;
import flash.filters.GradientBevelFilter;

import mx.core.mx_internal;
import mx.filters.BaseFilter;
import mx.filters.IBitmapFilter;

use namespace mx_internal;

[DefaultProperty("entries")]
	
public class GradientBevelFilter extends GradientFilter implements IBitmapFilter
{
	public function GradientBevelFilter(distance:Number = 4.0, angle:Number = 45, 
									    colors:Array = null, alphas:Array = null, 
									    ratios:Array = null, blurX:Number = 4.0, 
									    blurY:Number = 4.0, strength:Number = 1, 
									    quality:int = 1, type:String = "inner", 
									    knockout:Boolean = false)
	{
		this.distance = distance;
		this.angle = angle;
		this.blurX =blurX ;
		this.blurY = blurY;
		this.strength = strength;
		this.quality = quality;
		this.type = type;
		this.knockout = knockout;
		
		super(colors, alphas, ratios);		
	}
	
	public function clone():BitmapFilter 
	{
		return new flash.filters.GradientBevelFilter(distance, angle, colors, alphas, ratios, 
										blurX, blurY, strength, quality, type,
										knockout); 
	} 
		
}
}
