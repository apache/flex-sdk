package spark.components {
    [Bindable]
    public class _HeadquarterVO {
        public var name:String;
        public var address:String;

        public function _HeadquarterVO(name:String, address:String)
        {
            this.name = name;
            this.address = address;
        }

        public function get label():String
        {
            return name;
        }

        public function toString():String
        {
            return "HeadquarterVO{name=" + String(name) + "}";
        }
    }
}
