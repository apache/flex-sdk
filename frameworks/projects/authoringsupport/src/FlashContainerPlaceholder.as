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

package
{
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.flash.ContainerMovieClip;
	
	[IconFile("flash_container_icon_small.png")]
	public class FlashContainerPlaceholder extends ContainerMovieClip
	{
		protected var image1:Image;
		
		public function FlashContainerPlaceholder()
		{
			super();

			var fch:FlexContentHolder = new FlexContentHolder();
			fch.percentHeight = 100;
			fch.percentWidth = 100;
						
	       	var canvas1:Canvas = new Canvas();
	       	canvas1.horizontalScrollPolicy = "off";
	       	canvas1.verticalScrollPolicy = "off";
	       	canvas1.setStyle('borderStyle', 'solid');
	       	canvas1.setStyle('borderThickness', '2');
	       	canvas1.setStyle('borderColor', '0xCCCCCC');
	       	canvas1.percentHeight = 100;
	       	canvas1.percentWidth = 100;
	    	canvas1.addChild(createImage());

			this.addChild(fch);
			
			this.content = canvas1;			
		}
		
		protected function createImage():Image
		{
	       	image1 = new Image();
	       	image1.source = _embed_mxml_flash_container_icon_png;
	       	image1.scaleContent = false;
	       	image1.percentHeight = 100;
	       	image1.percentWidth = 100;
	       	image1.setStyle('horizontalAlign' , 'center');
	       	image1.setStyle('verticalAlign' , 'middle');
	       	return image1;			
		}
		
		override public function setActualSize(newWidth:Number, newHeight:Number):void
		{
			if (image1 != null) {
				if (newWidth < 128 || newHeight < 128)
					image1.scaleContent = true;
				else
					image1.scaleContent = false;
			}

			contentHolderObj.setActualSize(newWidth, newHeight);
			_width = newWidth;
			_height = newHeight;
		}

		[Embed(source='flash_container_icon.png')]
		private var _embed_mxml_flash_container_icon_png:Class;
	}
}