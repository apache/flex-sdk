package spark.skins.mobile
{
    import flash.display.Graphics;
    import flash.events.IEventDispatcher;
    
    import spark.components.ActionBar;
    import spark.components.Group;
    import spark.components.Label;
    
    public class ActionBarSkin extends SliderSkin
    {
        public function ActionBarSkin()
        {
            super();
        }
        
        public var hostComponent:ActionBar;
        public var titleField:Label;
        public var contentGroup:Group;
        
        override protected function createChildren():void
        {
            contentGroup = new Group();
            addChild(contentGroup);
            
            titleField = new Label();
            titleField.percentWidth = 100;
            titleField.setStyle("textAlign", "center");
            titleField.setStyle("verticalAlign", "middle");
            titleField.verticalCenter = 0;
//            titleField.minHeight = 20;
        }
        
        /**
         * 
         */	
        override protected function measure():void
        {
            super.measure();
            
//            minHeight = 20;
            measuredHeight = contentGroup.getExplicitOrMeasuredHeight() == 0 ? 0 : Math.max(20, contentGroup.getExplicitOrMeasuredHeight());
            measuredWidth = contentGroup.measuredWidth;
        }
        
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            contentGroup.setLayoutBoundsPosition(0, 0);
            contentGroup.setLayoutBoundsSize(unscaledWidth, unscaledHeight);
            
            // Draw background
            var g:Graphics = hostComponent.graphics;
            g.clear();
            g.beginFill(0xCCCCCC);
            g.drawRect(0, 0, unscaledWidth, unscaledHeight);
            g.endFill();
        }
    }
}