package spark.core.managers
{
    import flash.net.SharedObject;
    
    public class PersistenceManager implements IPersistenceManager
    {
        private var so:SharedObject;
        public var initialized:Boolean = false;
        
        public function PersistenceManager()
        {
        }
        
        
        private var _enabled:Boolean = true;
        
        public function get enabled():Boolean
        {
            return _enabled;
        }
        
        public function set enabled(value:Boolean):void
        {
            _enabled = value;
        }
        
        public function initialize(id:String = null):void
        {
            try
            {
                so = SharedObject.getLocal("FXAppCache");
                initialized = true;
				enabled = (so != null);
            }
            catch (e:Error)
            {
                // TODO (chiedozi): Should save errors to log
                enabled = false;
            }
        }
        
        public function setProperty(key:String, value:Object):void
        {
            if (!initialized)
                initialize();
            
            if (enabled)
            {
                so.data[key] = value;
//                so.flush();
            }
        }
        
        public function getProperty(key:String):Object
        {
            if (!initialized)
                initialize();
            
            if (enabled)
                return so.data[key];
            
            return null;
        }
        
        public function clear():void
        {
            if (!initialized)
                initialize();
            
			if (enabled)
			{
	            so.clear();
	            so.flush();
			}
        }
        
        public function flush():void
        {
			if (enabled)
            	so.flush();
        }
        
    }
}