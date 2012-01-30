package spark.components
{
    import spark.components.supportClasses.SkinnableComponent;
    import spark.events.ViewNavigatorEvent;
    
    public class ActionBar extends SkinnableComponent
    {
        public function ActionBar()
        {
            super();
            
            title = "Title";
        }
        
        
        [SkinPart(required="false")]
        public var titleField:Label;
        
        [SkinPart(required="false")]
        public var contentGroup:Group;
        
        private var _titleChanged:Boolean = false;
        
        // dataProvider
        private var _dataProvider:ViewNavigator;
        public function get dataProvider():ViewNavigator
        {
            return _dataProvider;   
        }
        public function set dataProvider(value:ViewNavigator):void
        {
            if (_dataProvider)
            {
                _dataProvider.removeEventListener(ViewNavigatorEvent.VIEW_ADD, viewChanged);
            }
            
            _dataProvider = value;
            _dataProvider.addEventListener(ViewNavigatorEvent.VIEW_ADD, viewChanged);
        }

        // title
        private var _title:String;
        public function get title():String
        {
            return _title;            
        }
        public function set title(value:String):void
        {
            setTitle(value, true);
        }
        public function setTitle(value:String, animate:Boolean):void
        {
            _title = value;
            _titleChanged = true;
            
            invalidateProperties();
        }
        
        // titleContent
        private var _titleContent:Array;
        public function get titleContent():Array
        {
            return _titleContent;
        }
        public function set titleContent(value:Array):void
        {
        }
        public function setTitleContent(value:Array, animate:Boolean):void
        {
        }
        
        protected function viewChanged(event:ViewNavigatorEvent):void
        {
            if (event.view)
                title = event.view.title;
            else
                title = "";
        }
        
        
        override protected function commitProperties():void
        {
            super.commitProperties();
            
            if (titleField && _titleChanged)
            {
                titleField.text = _title;
                titleField.includeInLayout = (_title != "" && _title != null);
            }
        }
        
        override protected function partAdded(partName:String, instance:Object):void
        {
            super.partAdded(partName, instance);
            
            if (instance == contentGroup)
            {
                if (_titleContent == null)
                {
                    if (titleField != null)
                        contentGroup.mxmlContent = [titleField];
                }
                else
                {
                    contentGroup.mxmlContent = _titleContent;
                }
                
                _titleChanged = true;
            }
            else if (instance == titleField)
            {
                if (contentGroup && _titleContent == null)
                    contentGroup.mxmlContent = [titleField];
            }
        }
    }
}