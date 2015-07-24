package spark.skins.spark {
    import org.flexunit.asserts.assertEquals;
    import org.flexunit.asserts.assertFalse;

    import spark.collections.SortField;

    public class SortField_Tests {
        private var _sut:SortField;

        [Test]
        public function fix_mustella_failure_due_to_FLEX_34852():void
        {
            //given
            _sut = new SortField("someField");

            //when
            const emptyObject:Object = {};
            var emptyObjectHasASortField:Boolean = _sut.objectHasSortField(emptyObject);

            //then
            assertFalse(emptyObjectHasASortField);
        }

        [Test]
        public function locale_setting_and_retrieving_work():void
        {
            //given
            _sut = new SortField("someField");

            //when
            _sut.setStyle("locale", "ru-RU");

            //then
            assertEquals("ru-RU", _sut.getStyle("locale"));
        }
    }
}
