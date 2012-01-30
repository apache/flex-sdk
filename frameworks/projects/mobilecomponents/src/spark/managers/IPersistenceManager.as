package spark.core.managers
{
public interface IPersistenceManager
{
    function initialize(id:String = null):void;
    
    function setProperty(key:String, value:Object):void;
    
    function getProperty(key:String):Object;
    
    function clear():void;
    
    function flush():void;
    
    function get enabled():Boolean;
    
    function set enabled(value:Boolean):void;
}
}