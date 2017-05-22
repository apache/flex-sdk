package spark.components {
    import mx.collections.ArrayCollection;

    [Bindable]
    public class _CompanyVO
    {
        private var _headquarter:_HeadquarterVO;
        private var _headquarterRewritten:Boolean = false;
        private var _originalHeadquarter:_HeadquarterVO;

        public var name:String;
        public var potentialHeadquarters:ArrayCollection;


        public function _CompanyVO(name:String, headquarter:_HeadquarterVO, potentialHeadquarters:ArrayCollection)
        {
            this.name = name;
            this._headquarter = headquarter;
            this._originalHeadquarter = headquarter;
            this.potentialHeadquarters = potentialHeadquarters;
        }

        public function get headquarter():_HeadquarterVO
        {
            return _headquarter;
        }

        public function set headquarter(value:_HeadquarterVO):void
        {
            _headquarterRewritten = true;
            _headquarter = value;
        }

        public function get headquarterRewritten():Boolean
        {
            return _headquarterRewritten;
        }

        public function get originalHeadquarter():_HeadquarterVO
        {
            return _originalHeadquarter;
        }

        public function toString():String
        {
            return "CompanyVO{name=" + String(name) + ", #hqs="+potentialHeadquarters.length+"}";
        }
    }
}
