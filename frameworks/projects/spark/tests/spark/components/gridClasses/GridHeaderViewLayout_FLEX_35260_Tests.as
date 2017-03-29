package spark.components.gridClasses {
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    import mx.collections.ArrayCollection;

    import org.flexunit.assertThat;

    import org.flexunit.asserts.assertEquals;
    import org.flexunit.runners.Parameterized;
    import org.fluint.uiImpersonation.UIImpersonator;

    import spark.components.DataGrid;
    import spark.components.GridColumnHeaderGroup;

    /*
     Example for two-column table (with no horizontal scroll):

     [pt]: GridColumnHeaderGroup padding top
     [pl]: GridColumnHeaderGroup padding left
     [lch]: still part of last column header, but beyond last column width

     b0: top-left corner of the data grid. Also, first column starts at this x-coordinate
     b1: first column ends at this x-coordinate (but the first header usually doesn't, due to [pl])
     b2: second column ends at this x-coordinate (but the second header usually doesn't, due to [pl])
     ...
     bx: last column ends at this x-coordinate

     c0: first column header starts at this x-coordinate
     c1: first column header ends at this x-coordinate, separator starts at this x-coordinate, and
         second column header (if it exists) starts at this x-coordinate + separator.width
     c1: second column header ends at this x-coordinate, next separator (if it exists) starts at
     this x-coordinate, and third column header (if it exists) starts at this x-coordinate + separator.width
     ...
     cx: last column header ends at this x-coordinate; last column separator starts at this x-coordinate

     d: table ends at this x-axis coordinate
     e: top-left corner of header. If [pt] and [pl] are 0, this coincides with b0
     f: b0ttom-left corner of header. If [pb] and [pl] are 0, this coincides with g0

     g0: header ends and grid starts at this y-coordinate
     g1: first column ends at this x-coordinate and second column (if it exists) begins at this x-coordinate
     g2: second column ends at this x-coordinate and third column (if it exists) begins at this x-coordinate
     ...
     gx: last column ends at this x-coordinate

     i: bottom-right point of last column header and x-coordinate at end of data grid

     And for each point we generate the 8 adjacent points:
     (x+1, y), (x+1, y+1), (x+1, y-1),
     (x-1, y), (x-1, y+1), (x-1, y-1),
     (x, y-1), (x, y-1). For easier comprehension we mark them
     using cardinal points: N, NE, E, SE, S, SW, W, NW.
     ...and we check various boundaries against all of them

     a (0, 0)
     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
     ░░░░░b0═══c0══════b1═══c1════════════════════════════b2══c2═════════d░░░░░░░
     ░░░░░║                              [pt]                            ║░░░░░░░
     ░░░░░║    e▓▓▓▓▓▓▓▓▓▓▓▓║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║▓▓▓▓▓▓▓▓▓▓║░░░░░░░
     ░░░░░║[pl]║▓▓▓INDEX▓▓▓▓║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓NAME▓▓▓▓▓▓▓▓▓▓▓▓▓║▓▓▓[lch]▓▓║░░░░░░░
     ░░░░░║    f▓▓▓▓▓▓▓▓▓▓▓▓║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║▓▓▓▓▓▓▓▓▓▓║░░░░░░░
     ░░░░░║                              [pb]                            ║░░░░░░░
     ░░░░░g0═══════════g1═════════════════════════════════g2═════════════i░░░░░░░
     ░░░░░║     01     ║     John                         ║              ║░░░░░░░
     ░░░░░║     02     ║     Jane                         ║              ║░░░░░░░
     ░░░░░║     03     ║     Judy                         ║              ║░░░░░░░
     ░░░░░║     04     ║     James                        ║              ║░░░░░░░
     ░░░░░╚════════════╩══════════════════════════════════╩══════════════╝░░░░░░░
     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
     */

    [RunWith("org.flexunit.runners.Parameterized")]
    public class GridHeaderViewLayout_FLEX_35260_Tests
    {
        private static var foo:Parameterized;
        private static const N:Matrix = new Matrix(1, 0, 0, 1, 0, -1);
        private static const NE:Matrix = new Matrix(1, 0, 0, 1, 1, -1);
        private static const E:Matrix = new Matrix(1, 0, 0, 1, 1, 0);
        private static const SE:Matrix = new Matrix(1, 0, 0, 1, 1, 1);
        private static const S:Matrix = new Matrix(1, 0, 0, 1, 0, 1);
        private static const SW:Matrix = new Matrix(1, 0, 0, 1, -1, 1);
        private static const W:Matrix = new Matrix(1, 0, 0, 1, -1, 0);
        private static const NW:Matrix = new Matrix(1, 0, 0, 1, -1, -1);
        private static const ITSELF:Matrix = new Matrix(1, 0, 0, 1, 0, 0); //the point, unmodified
        private static const directions:Array = [ITSELF, N, NE, E, SE, S, SW, W, NW];

        private static const COLUMN_HEADER_RECTANGLES:String = "columnHeaderRectangles";
        private static const ENTIRE_HEADER_RECTANGLE:String = "headerRectangle"; //includes padding
        private static const MAIN_HEADER_VIEW_RECTANGLE:String = "mainHeaderViewRectangle";
        private static const FIXED_HEADER_VIEW_RECTANGLE:String = "fixedHeaderViewRectangle";

        private static var _dataGrid:DataGrid;

        private var _keyRectangles:Array;
        private var _keyPoints:Array;

        //@TODO add cases with horizontal scroll, and also with fixed columns
        //@TODO we probably have to account for paddingTop and paddingBottom as well
        public static var dimensions:Array = [
            /*x, y, width, header padding left, header padding top, header padding bottom, [column widths] */
            [[10, 0, 300, 5, 0, 5, [25, 150]]],
            [[0, 0, 300, 5, 0, 0, [25, 150]]]
        ];


        [BeforeClass]
        public static function setUpBeforeClass():void
        {
            _dataGrid = new DataGrid();
            _dataGrid.setStyle("borderVisible", false); //to not deal with the complications of Scroller.minViewportInset
            UIImpersonator.addChild(_dataGrid);
        }

        [AfterClass]
        public static function tearDownAfterClass():void
        {
            UIImpersonator.removeAllChildren();

            _dataGrid = null;
        }

        [Before]
        public function setUp():void
        {

        }

        [After]
        public function tearDown():void
        {
            _keyRectangles = null;
            _keyPoints = null;
        }

        /*
        [Ignore]
        [Test]
        public function test_column_index(globalPoint:Array, expectedColumnIndex:int):void
        {
            //given
            var localPoint:Point = _dataGrid.grid.globalToLocal(new Point(globalPoint[0], globalPoint[1]));

            //when
            var columnIndex:int = _dataGrid.grid.getColumnIndexAt(localPoint.x, 0);

            //then
            assertEquals(expectedColumnIndex, columnIndex);
        }
*/


        [Test(dataProvider="dimensions")]
        public function test_with_no_scroll(dimensions:Array):void
        {
            //given
            _dataGrid.width = getWidth(dimensions);
            _dataGrid.x = getX(dimensions);
            _dataGrid.y = getY(dimensions);

            _dataGrid.columnHeaderGroup.setStyle("paddingLeft", getHeaderPaddingLeft(dimensions));
            _dataGrid.columnHeaderGroup.setStyle("paddingTop", getHeaderPaddingTop(dimensions));
            _dataGrid.columnHeaderGroup.setStyle("paddingBottom", getHeaderPaddingBottom(dimensions));

            var gridColumns:Array = [];
            for (var i:int = 0; i < getColumnWidths(dimensions).length; i++)
            {
                var column:GridColumn = new GridColumn();
                column.width = getColumnWidth(dimensions, i);
                gridColumns.push(column);
            }
            _dataGrid.columns = new ArrayCollection(gridColumns);

            _dataGrid.validateNow();

            _keyPoints = generateKeyPoints(dimensions, _dataGrid);
            _keyRectangles = generateKeyRectangles(_keyPoints, dimensions);

            //then
            //first, make sure that the dataGrid was rendered correctly
            assertThat("The dataGrid has not yet been correctly rendered on stage", getActualHeaderHeight(_dataGrid) > 0);

            forEachPoint(assertAssumptionsAboutPoint);
        }

        private function assertAssumptionsAboutPoint(point:Point, pointName:String, currentTransformation:Matrix):void
            {
            assertThatHeaderContainsPointOrNot(point, pointName, currentTransformation);
            assertThatHeaderIndexIsCorrect(point, pointName, currentTransformation);
            assertThatCoordinatesOverHeaderViewOrNot(point, pointName, currentTransformation);
        }

        private function assertThatHeaderContainsPointOrNot(point:Point, pointName:String, currentTransformation:Matrix):void
        {
                    //when
            var headerShouldContainThisPoint:Boolean = getHeaderShouldContainPointAssumption(point);
            var doesHeaderContainThisPoint:Boolean = _sut.containsGlobalCoordinates(point);
            const errorMessageHeaderContainsPoint:String = getHeaderContainsPointErrorMessage(pointName, currentTransformation, point, headerShouldContainThisPoint, doesHeaderContainThisPoint);

            //then
            assertEquals(errorMessageHeaderContainsPoint, headerShouldContainThisPoint, doesHeaderContainThisPoint);
        }

        private function assertThatCoordinatesOverHeaderViewOrNot(point:Point, pointName:String, currentTransformation:Matrix):void
        {
            //when
            var shouldBeContainedInMainHeaderView:Boolean = getMainHeaderViewContainsPointAssumption(point);
            var shouldBeContainedInFixedHeaderView:Boolean = getFixedHeaderViewContainsPointAssumption(point);
                    const shouldBeContainedInAHeaderView:Boolean = shouldBeContainedInMainHeaderView || shouldBeContainedInFixedHeaderView;
            var actuallyContainedInAHeaderView:Boolean = _sut.areCoordinatesOverAHeaderView(point);
            const errorMessageHeaderViewContainsPoint:String = getHeaderViewContainsPointErrorMessage(pointName, currentTransformation, point, shouldBeContainedInAHeaderView, actuallyContainedInAHeaderView);

                    //then
                    assertEquals(errorMessageHeaderViewContainsPoint, shouldBeContainedInAHeaderView, actuallyContainedInAHeaderView);
                }

        private function assertThatHeaderIndexIsCorrect(point:Point, pointName:String, currentTransformation:Matrix):void
        {
            //when
            var expectedHeaderIndex:int = getHeaderIndexAssumption(point);
            var actualHeaderIndex:int = getHeaderIndexAtGlobalPoint(point);
            const errorMessageHeaderIndex:String = getHeaderIndexErrorMessage(pointName, currentTransformation, point, expectedHeaderIndex, actualHeaderIndex);

            //then
            assertEquals(errorMessageHeaderIndex, expectedHeaderIndex, actualHeaderIndex);
        }

        private function getHeaderIndexErrorMessage(pointName:String, direction:Matrix, transformedPoint:Point, expectedColumnHeaderIndex:int, actualColumnHeaderIndex:int):String
        {
            return "The point " + pointName + " transformed with Matrix " + direction + " (resulting in " + transformedPoint + ") should be "
                    + (expectedColumnHeaderIndex == -1 ? "outside any column header bounds" : "inside the column header with index " + expectedColumnHeaderIndex)
                    + " but was mistakenly found to be "
                    + (actualColumnHeaderIndex == -1 ? "outside any column header bounds" : "inside the column header with index " + actualColumnHeaderIndex
                    + "\n DEBUG INFO: headerRectangles=" + columnHeaderRectangles);
        }

        private function getHeaderContainsPointErrorMessage(pointName:String, direction:Matrix, transformedPoint:Point, shouldBeContainedInHeader:Boolean, isActuallyContainedInHeader:Boolean):String
        {
            return "The point " + pointName + " transformed with Matrix " + direction + " (resulting in " + transformedPoint + ") should be "
                    + (shouldBeContainedInHeader ? "within " : "outside ") + "the header bounds"
                    + " but was mistakenly found to be "
                    + (isActuallyContainedInHeader ? "within" : "outside")
                    + "\n DEBUG INFO: header rectangle=" + entireHeaderRectangle;
        }

        private function getHeaderViewContainsPointErrorMessage(pointName:String, direction:Matrix, transformedPoint:Point, shouldBeContainedInAHeaderView:Boolean, isActuallyContainedByAHeaderView:Boolean):String
        {
            return "The point " + pointName + " transformed with Matrix " + direction + " (resulting in " + transformedPoint + ") should be "
                    + (shouldBeContainedInAHeaderView ? "within " : "outside ") + "a header view"
                    + " but was mistakenly found to be "
                    + (isActuallyContainedByAHeaderView ? "within" : "outside")
                    + "\n DEBUG INFO: header views=" + fixedHeaderViewRectangle + "; " + mainHeaderViewRectangle;
        }

        private function getHeaderIndexAtGlobalPoint(globalPoint:Point):int
        {
            var localPoint:Point = _sut.globalToLocal(globalPoint);
            return _sut.getHeaderIndexAt(localPoint.x, localPoint.y);
        }

        private function getHeaderShouldContainPointAssumption(point:Point):Boolean
        {
            return rectangleContainsPoint(entireHeaderRectangle, point);
        }

        private function getFixedHeaderViewContainsPointAssumption(point:Point):Boolean
        {
            return rectangleContainsPoint(fixedHeaderViewRectangle, point);
        }

        private function getMainHeaderViewContainsPointAssumption(point:Point):Boolean
        {
            return rectangleContainsPoint(mainHeaderViewRectangle, point);
        }

        private function getHeaderIndexAssumption(point:Point):int
        {
            return getIndexOfHeaderRectangleWhichContainsPoint(point, columnHeaderRectangles);
        }

        private function getAdjacentPoint(point:Point, direction:Matrix):Point
        {
            return direction.transformPoint(point);
        }

        private function getIndexOfHeaderRectangleWhichContainsPoint(point:Point, rectangles:Array):int
        {
            for (var i:int = 0; i < rectangles.length; i++)
            {
                if(rectangleContainsPoint(rectangles[i], point))
                    return i;
            }

            return -1;
        }

        private function rectangleContainsPoint(rectangle:Rectangle, point:Point):Boolean
        {
            return rectangle.containsPoint(point);
        }

        private function generateKeyPoints(dimensions:Array, grid:DataGrid):Array
        {
            var keyPoints:Array = [];
            //TODO this code does not yet account for horizontal scrolling!

            keyPoints["a"] = new Point(0, 0);
            keyPoints["b0"] = new Point(getX(dimensions), getY(dimensions));
            generateColumnIntermediates(keyPoints, dimensions, "b0");
            keyPoints["c0"] = new Point(getX(dimensions) + getHeaderPaddingLeft(dimensions), getY(dimensions));
            generateColumnIntermediates(keyPoints, dimensions, "c0");
            keyPoints["d"] = new Point(getX(dimensions) + getWidth(dimensions), getY(dimensions));
            keyPoints["e"] = new Point(Point(keyPoints["c0"]).x, getY(dimensions) + getHeaderPaddingTop(dimensions));
            keyPoints["f"] = new Point(Point(keyPoints["c0"]).x, getY(dimensions) + getActualHeaderHeight(grid) - getHeaderPaddingBottom(dimensions));
            keyPoints["g0"] = new Point(getX(dimensions), getY(dimensions) + getActualHeaderHeight(grid));
            generateColumnIntermediates(keyPoints, dimensions, "g0");
            keyPoints["i"] = new Point(getX(dimensions) + getWidth(dimensions), Point(keyPoints["g0"]).y);
            return keyPoints;
        }

        private function generateColumnIntermediates(keyPoints:Array, dimensions:Array, initialPointName:String):void
        {
            const initialPoint:Point = keyPoints[initialPointName];
            const y:Number = initialPoint.y;
            var currentX:Number = initialPoint.x;
            const initialPointFirstCharacter:String = initialPointName.charAt(0);
            for (var i:int = 0; i < getColumnWidths(dimensions).length; i++)
            {
                currentX += getColumnWidth(dimensions, i);
                keyPoints[initialPointFirstCharacter + (i+1)] = new Point(currentX, y);
            }
        }

        private function generateKeyRectangles(keyPoints:Array, dimensions:Array):Array
        {
            var keyRectangles:Array = [];

            keyRectangles[COLUMN_HEADER_RECTANGLES] = generateHeaderColumnRectangles(keyPoints, dimensions);
            keyRectangles[ENTIRE_HEADER_RECTANGLE] = generateVisibleHeaderRectangle(keyPoints, dimensions);
            keyRectangles[MAIN_HEADER_VIEW_RECTANGLE] = generateMainHeaderViewRectangle(keyPoints, dimensions);
            keyRectangles[FIXED_HEADER_VIEW_RECTANGLE] = generateFixedHeaderViewRectangle(keyPoints, dimensions);

            return keyRectangles;
        }

        private function generateMainHeaderViewRectangle(keyPoints:Array, dimensions:Array):Rectangle
        {
            //this is the GridColumnHeaderGroup.centerGridColumnHeaderView, which is holds the non-fixed columns; padding excluded
            const topLeftCorner:Point = keyPoints["e"];
            return new Rectangle(topLeftCorner.x, topLeftCorner.y,
                    getHeaderWidthFromKeyPoints(keyPoints) - getHeaderPaddingLeft(dimensions),
                    getHeaderHeightFromKeyPoints(keyPoints) - getHeaderPaddingTop(dimensions) - getHeaderPaddingBottom(dimensions));
        }

        private function generateFixedHeaderViewRectangle(keyPoints:Array, dimensions:Array):Rectangle
        {
            //this is the GridColumnHeaderGroup.centerGridColumnHeaderView, which is holds the non-fixed columns; padding excluded
            const topLeftCorner:Point = keyPoints["e"];
            return new Rectangle(topLeftCorner.x, topLeftCorner.y, 0, 0);
        }

        private function generateVisibleHeaderRectangle(keyPoints:Array, dimensions:Array):Rectangle
        {
            const topLeftCorner:Point = keyPoints["b0"];
            const bottomRightCorner:Point = keyPoints["i"];
            return new Rectangle(topLeftCorner.x, topLeftCorner.y, bottomRightCorner.x - topLeftCorner.x, bottomRightCorner.y - topLeftCorner.y);
        }

        private function generateHeaderColumnRectangles(keyPoints:Array, dimensions:Array):Array
        {
            var headerRectangles:Array = [];

            const headerPaddingTop:Number = getHeaderPaddingTop(dimensions);
            const headerPaddingBottom:Number = getHeaderPaddingBottom(dimensions);
            const headerHeight:Number = getHeaderHeightFromKeyPoints(keyPoints) - headerPaddingTop - headerPaddingBottom;
            for (var i:int = 0; i < getColumnWidths(dimensions).length; i++)
            {
                var topLeft:Point = keyPoints["c" + i];
                var topRight:Point = keyPoints["c" + (i+1)];
                headerRectangles.push(new Rectangle(topLeft.x, topLeft.y + headerPaddingTop, topRight.x - topLeft.x, headerHeight));
            }

            //correct last header rectangle to extend to grid boundaries. This is one of the issues which prompted
            //this unit test in the first place.
            var lastHeaderRectangle:Rectangle = headerRectangles[headerRectangles.length - 1];
            lastHeaderRectangle.width = Point(keyPoints["d"]).x - lastHeaderRectangle.x;

            return headerRectangles;
        }

        private function forEachPoint(assertThat_:Function):void
        {
            for (var pointName:String in _keyPoints)
            {
                for (var i:int = 0; i < directions.length; i++)
                {
                    assertThat_(getAdjacentPoint(_keyPoints[pointName], directions[i]), pointName, directions[i]);
                }
            }
        }


        private function getActualHeaderHeight(grid:DataGrid):Number
        {
            //Note that we're assuming the grid is on stage and validated by this point!
            return grid.columnHeaderGroup.height;
        }

        /* key rectangles getters */

        private function get columnHeaderRectangles():Array
        {
            return _keyRectangles[COLUMN_HEADER_RECTANGLES];
        }

        private function get entireHeaderRectangle():Rectangle //includes padding
        {
            return _keyRectangles[ENTIRE_HEADER_RECTANGLE] as Rectangle;
        }

        private function get mainHeaderViewRectangle():Rectangle
        {
            return _keyRectangles[MAIN_HEADER_VIEW_RECTANGLE] as Rectangle;
        }

        private function get fixedHeaderViewRectangle():Rectangle
        {
            return _keyRectangles[FIXED_HEADER_VIEW_RECTANGLE] as Rectangle;
        }

        /* key points getters */

        private function getColumnWidthFromKeyPoints(keyPoints:Array, columnIndex:int):Number
        {
            //we're assuming columnIndex has a valid value
            return Point(keyPoints["c" + (columnIndex + 1)]).x - Point(keyPoints["c" + columnIndex]).x;
        }

        private function getHeaderHeightFromKeyPoints(keyPoints:Array):Number
        {
            return Point(keyPoints["i"]).y - Point(keyPoints["d"]).y;
        }

        private function getHeaderWidthFromKeyPoints(keyPoints:Array):Number
        {
            return Point(keyPoints["d"]).x - Point(keyPoints["b0"]).x;
        }

        /* dimensions getters */

        private function getX(dimensions:Array):Number
        {
            return dimensions[0];
        }

        private function getY(dimensions:Array):Number
        {
            return dimensions[1];
        }

        private function getWidth(dimensions:Array):Number
        {
            return dimensions[2];
        }

        private function getHeaderPaddingLeft(dimensions:Array):Number
        {
            return dimensions[3];
        }

        private function getHeaderPaddingTop(dimensions:Array):Number
        {
            return dimensions[4];
        }

        private function getHeaderPaddingBottom(dimensions:Array):Number
        {
            return dimensions[5];
        }

        private function getColumnWidths(dimensions:Array):Array
        {
            return dimensions[6];
        }

        private function getColumnWidth(dimensions:Array, columnIndex:int):Number
        {
            return getColumnWidths(dimensions)[columnIndex];
        }

        private function getTotalColumnWidths(dimensions:Array):Number
        {
            var sum:Number = 0;
            getColumnWidths(dimensions).forEach(function (item:*, index:int, arr:Array):void {sum += item;});
            return sum;
        }


        private function get _sut():GridColumnHeaderGroup
        {
            return _dataGrid.columnHeaderGroup;
        }
    }
}