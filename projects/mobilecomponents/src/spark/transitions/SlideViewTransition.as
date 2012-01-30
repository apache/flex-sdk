package spark.effects
{
    import flash.display.BitmapData;
    
    import mx.core.UIComponent;
    import mx.events.EffectEvent;
    
    import spark.components.Group;
    import spark.components.Image;
    import spark.components.View;

    
    
    public class SlideViewTransition extends ViewTransition
    {
        public static const SLIDE_LEFT:int = 0;
        public static const SLIDE_RIGHT:int = 1;
        public static const SLIDE_UP:int = 2;
        public static const SLIDE_DOWN:int = 3;
        public static const TYPE:String = "slide";
        
        public var direction:int = SLIDE_LEFT;
        
        private var image:Image;
        private var actionBarBitmapData:BitmapData;
        private var actionBar:UIComponent;
        private var actionBarImage:Image;
        private var contentGroupImage:Image;
        
        public function SlideViewTransition(duration:Number, direction:int = SLIDE_LEFT)
        {
            super();
            
            type = "slide";
            
            this.duration = duration;
            this.direction = direction;
        }
        
        override public function prepare():void
        {
            var bitmapData:BitmapData;
            var contentGroup:Group = navigator.contentGroup;
            actionBar = navigator.actionBar;
            
            bitmapData = new BitmapData(contentGroup.width, contentGroup.height);
            bitmapData.draw(contentGroup);
            
            contentGroupImage = new Image();
            contentGroupImage.source = bitmapData;
            contentGroupImage.setActualSize(contentGroup.width, contentGroup.height);
            contentGroupImage.includeInLayout = false;
            
            contentGroupImage.x = contentGroup.x;
            contentGroupImage.y = contentGroup.y;
            
            if (actionBar.visible && actionBar.width > 0 && actionBar.height > 0)
            {
                bitmapData = new BitmapData(actionBar.width, actionBar.height);
                bitmapData.draw(actionBar);
                
                actionBarImage = new Image();
                actionBarImage.source = bitmapData;
                actionBarImage.setActualSize(actionBar.width, actionBar.height);
                actionBarImage.includeInLayout = false;
                
                actionBarImage.x = actionBar.x;
                actionBarImage.y = actionBar.y;
            }
        }
        
        // Navigator has forced validation by now
        override public function play():void
        {
            var slideAmount:int;
            var view:View = currentView ? currentView : nextView;
            var targets:Array = new Array();
            
            var contentGroup:Group = navigator.contentGroup;
            var bitmapData:BitmapData = new BitmapData(navigator.width, navigator.height);
            bitmapData.draw(navigator);
            image = new Image();
            image.source = bitmapData;
            image.setActualSize(navigator.width, navigator.height);
            image.includeInLayout = false;
            
            if (currentView)
            {
                currentView.visible = false;
                currentView.includeInLayout = false;
//                targets.push(currentView);
//                currentView.includeInLayout = false;
            }
            
            if (nextView)
            {
                nextView.visible = false;
                nextView.includeInLayout = false;
//                targets.push(nextView);
//                nextView.includeInLayout = false;
            }
            
            if (contentGroupImage)
            {
                navigator.skin.addChild(contentGroupImage);
                targets.push(contentGroupImage);
            }
            
            if (actionBarImage)
            {
                navigator.skin.addChild(actionBarImage);
                targets.push(actionBarImage);
            }
            
            if (image)
            {
                navigator.skin.addChild(image);
                targets.push(image);
            }
            
//            targets.push(navigator.actionBar);
            actionBar.visible = false;
            
            if (direction == SLIDE_LEFT)
            {
                slideAmount = -navigator.width;
                if (image)
                    image.x = navigator.width;
                
//                if (nextView)
//                {
//                    navigator.actionBar.x = navigator.width;
//                    nextView.x = navigator.width;
//                }
            }
            else if (direction == SLIDE_RIGHT)
            {
                slideAmount = navigator.width;
                if (image)
                    image.x = -navigator.width;
                
//                if (nextView)
//                {
//                    nextView.x = -navigator.width;
//                    navigator.actionBar.x = -navigator.width;
//                }
            }
            else if (direction == SLIDE_UP)
            {
                
            }
            else if (direction == SLIDE_DOWN)
            {
                
            }
            
            var slideAnimation:Move = new Move();
            
            slideAnimation.duration = duration;
            slideAnimation.xBy = slideAmount;
            slideAnimation.addEventListener(EffectEvent.EFFECT_END, transitionComplete);
            
            slideAnimation.play(targets);
        }
        
        override public function end():void
        {
            
        }
        
        override public function transitionComplete(event:EffectEvent=null):void
        {
            event.target.removeEventListener(EffectEvent.EFFECT_END, transitionComplete);
            
            actionBar.visible = true;
            actionBar.includeInLayout = true;
            
            if (nextView)
            {
                nextView.visible = true;
                nextView.includeInLayout = true;
            }
            
            if (actionBarImage)
            {
                navigator.skin.removeChild(actionBarImage);
                actionBarImage = null;
            }
            
            if (image)
            {
                navigator.skin.removeChild(image);
                image = null;
            }
            
            navigator.skin.removeChild(contentGroupImage);
            contentGroupImage = null;
            
            super.transitionComplete(event);
        }
    }
}