package spark.skins.mobile
{
    import spark.components.ActionBar;
    import spark.components.ButtonBar;
    import spark.components.Group;
    import spark.components.ViewNavigator;
    import spark.effects.IViewTransition;
    import spark.effects.SlideViewTransition;
    
    public class ViewNavigatorSkin extends SliderSkin
    {
        //--------------------------------------------------------------------------
        //
        //  Constructor
        //
        //--------------------------------------------------------------------------
        public function ViewNavigatorSkin()
        {
            super();
        }
        
        //--------------------------------------------------------------------------
        //
        //  Variables
        //
        //--------------------------------------------------------------------------
        public var hostComponent:ViewNavigator;
        
        // Groups and UIControls
        public var contentGroup:Group;
        public var actionBar:ActionBar;
        public var tabBar:ButtonBar;
        
        // Transitions
        public var defaultPushTransition:IViewTransition;
        public var defaultPopTransition:IViewTransition;
        
        //--------------------------------------------------------------------------
        //
        // Methods
        //
        //--------------------------------------------------------------------------
        
        /**
         * 
         */
        override protected function createChildren():void
        {
            contentGroup = new Group();
            contentGroup.minHeight = 0;
			
            tabBar = new ButtonBar();
            tabBar.requireSelection = true;
            tabBar.height = 40;
            
            actionBar = new ActionBar();
            
            addChild(contentGroup);
            addChild(actionBar);
            addChild(tabBar);
            
            tabBar.dataProvider = hostComponent;
            
            defaultPushTransition = new SlideViewTransition(300, SlideViewTransition.SLIDE_LEFT);
            defaultPopTransition = new SlideViewTransition(300, SlideViewTransition.SLIDE_RIGHT);
        }
        
        /**
         * 
         */
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            var top:Number = 0;
            var bottom:Number = unscaledHeight;
            
            if (tabBar.includeInLayout)
            {
                var tabBarHeight:Number = tabBar.getExplicitOrMeasuredHeight();
                tabBar.setLayoutBoundsSize(unscaledWidth, tabBarHeight);
                tabBar.setLayoutBoundsPosition(0, top);
                
                top += tabBarHeight;
            }
            
            if (actionBar.includeInLayout)
            {
                var actionBarHeight:Number = actionBar.getExplicitOrMeasuredHeight();
                
                actionBar.setLayoutBoundsSize(unscaledWidth, actionBarHeight);
                actionBar.setLayoutBoundsPosition(0, top);
                
                top += actionBarHeight;
            }
            
			if (contentGroup.includeInLayout)
			{
				var contentGroupHeight:Number = bottom - top;
				
				if (contentGroupHeight < contentGroup.minHeight)
					contentGroupHeight = contentGroup.minHeight;
				
	            contentGroup.setLayoutBoundsPosition(0, top);
	            contentGroup.setLayoutBoundsSize(unscaledWidth, contentGroupHeight);
			}
        }
    }
}