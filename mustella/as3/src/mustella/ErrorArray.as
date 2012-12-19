package {
    public class ErrorArray {
        private var _parts:Array;

        public function ErrorArray(parts:Array) {
            _parts = parts;
        }

        public function get parts():Array {
            return _parts;
        }

        /**
         *  customize string representation
         */
        public function toString():String {
            var s:String;
            if (parts && parts.length > 0)
                s = '"' + parts.join('"..."') + '"';
            return s;
        }
    }
}
