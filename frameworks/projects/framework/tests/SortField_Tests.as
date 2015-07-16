package {
    import mx.collections.SortField;

    import org.flexunit.asserts.assertFalse;

    public class SortField_Tests {
        private var _sut:SortField;

        [Test]
        public function fix_mustella_failure_due_to_FLEX_34852():void
        {
            //given
            _sut = new SortField("someField");

            //when
            var emptyObjectHasASortField:Boolean = _sut.objectHasSortField({});

            //then
            assertFalse(emptyObjectHasASortField);
        }
    }
}
