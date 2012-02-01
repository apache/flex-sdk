package spark.filters
{
	import flash.filters.BitmapFilter;
	import flash.filters.GradientGlowFilter;
	import mx.core.mx_internal;
	import mx.filters.IBitmapFilter;
	
	use namespace mx_internal;
	
public class GradientGlowFilter extends GradientFilter implements IBitmapFilter
{
	public function GradientGlowFilter(distance:Number = 4.0, angle:Number = 45, 
									   colors:Array = null, alphas:Array = null, 
									   ratios:Array = null, blurX:Number = 4.0, 
									   blurY:Number = 4.0, strength:Number = 1, 
									   quality:int = 1, type:String = "inner", 
									   knockout:Boolean = false)
	{
		this.distance = distance;
		this.angle = angle;
		this.blurX = blurX;
		this.blurY = blurY;
		this.strength = strength;
		this.quality = quality;
		this.type = type;
		this.knockout = knockout;
		
		super(colors, alphas, ratios);
	}
	
	public function clone():BitmapFilter
	{
		return new flash.filters.GradientGlowFilter(distance, angle, colors, alphas, ratios, 
										blurX, blurY, strength, quality, type,
										knockout); 
	} 
		
}
}