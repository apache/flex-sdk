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

     [pl]: GridColumnHeaderGroup padding left
     [lch]: still part of last column header, but beyond last column width
     c0: first column header starts here
     c1: first column header ends here, second column header (if it exists) starts, and column separator is here
     c2: second column header ends here; second column separator is here
     ...
     cx: last column header ends here; last column separator is here

     d0: first column ends at this x-axis coordinate (but the first header doesn't, due to [pl])
     d1: second column ends at this x-axis coordinate
     ...
     dx: last column ends at this x-axis coordinate

     e: table ends at this x-axis coordinate

     f0: header ends and grid starts at this y-coordinate
     f1: first column ends here and second column (if it exists) begins here
     f2: second column ends here and third column (if it exists) begins here
     ...
     fx: last column ends here

     g0: bottom-left point of first column header
     g1: bottom-right point of first column header
     g2: bottom-right point of second column header
     ...
     gx: bottom-right point of (last column header - [lch])

     h: bottom-right point of last column header and x-coordinate at end of data grid

     And for each point we generate the 8 adjacent points:
     (x+1, y), (x+1, y+1), (x+1, y-1),
     (x-1, y), (x-1, y+1), (x-1, y-1),
     (x, y-1), (x, y-1). For easier comprehension we mark them
     using cardinal points: N, NE, E, SE, S, SW, W, NW.
     ...and we check various boundaries against all of them

     a (0, 0)
     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
     ░░░░░b════c0══════d0═══c1════════════════════════════d1══c2═════════e░░░░░░░
     ░░░░░║▓▓▓▓║▓▓▓▓▓▓▓▓▓▓▓▓║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║▓▓▓▓▓▓▓▓▓▓║░░░░░░░
     ░░░░░║[pl]║▓▓▓INDEX▓▓▓▓║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓NAME▓▓▓▓▓▓▓▓▓▓▓▓▓║▓▓▓[lch]▓▓║░░░░░░░
     ░░░░░║▓▓▓▓║▓▓▓▓▓▓▓▓▓▓▓▓║▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║▓▓▓▓▓▓▓▓▓▓║░░░░░░░
     ░░░░░f0═══g0══════f1═══g1════════════════════════════f2══g2═════════h░░░░░░░
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
        private static const ENTIRE_HEADER_RECTANGLE:String = "headerRectangle";
        private static const MAIN_HEADER_VIEW_RECTANGLE:String = "mainHeaderViewRectangle";
        private static const FIXED_HEADER_VIEW_RECTANGLE:String = "fixedHeaderViewRectangle";

        private static var _dataGrid:DataGrid;

        private var _keyRectangles:Array;
        private var _keyPoints:Array;

        //@TODO we probably have to account for paddingTop and paddingBottom as well
        //@TODO add cases with horizontal scroll, with fixed columns, and RTL
        public static var dimensions:Array = [/*x, y, width, header padding left, header padding top, [column widths] */
            [[10, 0, 300, 5, 0, [25, 150]]],
            [[0, 0, 300, 5, 0, [25, 150]]]
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

        [Ignore]
        [Test]
        public function test_header_contains_global_coordinates(globalPoint:Array, headerShouldContainThisPoint:Boolean):void
        {
            //when
            var doesHeaderContainThisPoint:Boolean = _sut.containsGlobalCoordinates(new Point(globalPoint[0], globalPoint[1]));

            //then
            assertEquals(headerShouldContainThisPoint, doesHeaderContainThisPoint);
        }*/

        [Test(dataProvider="dimensions")]
        public function test_with_no_scroll(dimensions:Array):void
        {
            //given
            _dataGrid.width = getWidth(dimensions);
            _dataGrid.x = getX(dimensions);
            _dataGrid.y = getY(dimensions);

            _dataGrid.columnHeaderGroup.setStyle("paddingLeft", getHeaderPaddingLeft(dimensions));
            _dataGrid.columnHeaderGroup.setStyle("paddingTop", getHeaderPaddingTop(dimensions));

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

            for (var pointName:String in _keyPoints)
            {
                for (var i:int = 0; i < directions.length; i++)
                {
                    //given
                    var pointToTest:Point = getAdjacentPoint(_keyPoints[pointName], directions[i]);

                    //when
                    var expectedHeaderIndex:int = getHeaderIndexAssumption(pointToTest);
                    var actualHeaderIndex:int = getHeaderIndexAtGlobalPoint(pointToTest);
                    const errorMessageHeaderIndex:String = getHeaderIndexErrorMessage(pointName, directions[i], pointToTest, expectedHeaderIndex, actualHeaderIndex);

                    var shouldBeContainedInMainHeaderView:Boolean = getMainHeaderViewContainsPointAssumption(pointToTest);
                    var shouldBeContainedInFixedHeaderView:Boolean = getFixedHeaderViewContainsPointAssumption(pointToTest);
                    const shouldBeContainedInAHeaderView:Boolean = shouldBeContainedInMainHeaderView || shouldBeContainedInFixedHeaderView;
                    var actuallyContainedInAHeaderView:Boolean = _sut.areCoordinatesOverAHeaderView(pointToTest);
                    const errorMessageHeaderViewContainsPoint:String = getHeaderContainsPointErrorMessage(pointName, directions[i], pointToTest, shouldBeContainedInAHeaderView, actuallyContainedInAHeaderView);

                    //then
                    assertEquals(errorMessageHeaderIndex, expectedHeaderIndex, actualHeaderIndex);
                    assertEquals(errorMessageHeaderViewContainsPoint, shouldBeContainedInAHeaderView, actuallyContainedInAHeaderView);
                }
            }
        }

        private function getHeaderIndexErrorMessage(pointName:String, direction:Matrix, transformedPoint:Point, expectedColumnHeaderIndex:int, actualColumnHeaderIndex:int):String
        {
            return "The point " + pointName + " transformed with Matrix " + direction + " (resulting in " + transformedPoint + ") should be "
                    + (expectedColumnHeaderIndex == -1 ? "outside any header bounds" : "inside the column header with index " + expectedColumnHeaderIndex)
                    + " but was mistakenly found to be "
                    + (actualColumnHeaderIndex == -1 ? "outside any header bounds" : "inside the column header with index " + actualColumnHeaderIndex
                    + "\n DEBUG INFO: headerRectangles=" + columnHeaderRectangles);
        }

        private function getHeaderContainsPointErrorMessage(pointName:String, direction:Matrix, transformedPoint:Point, shouldBeContainedInHeader:Boolean, isActuallyContainedInHeader:Boolean):String
        {
            return "The point " + pointName + " transformed with Matrix " + direction + " (resulting in " + transformedPoint + ") should be "
                    + (shouldBeContainedInHeader ? "within " : "outside ") + "a header view"
                    + " but was mistakenly found to be "
                    + (isActuallyContainedInHeader ? "within" : "outside")
                    + "\n DEBUG INFO: header views=" + fixedHeaderViewRectangle + "; " + mainHeaderViewRectangle;
        }

        private function getHeaderIndexAtGlobalPoint(globalPoint:Point):int
        {
            var localPoint:Point = _sut.globalToLocal(globalPoint);
            return _sut.getHeaderIndexAt(localPoint.x, localPoint.y);
        }

        private function getHeaderContainsPointAssumption(point:Point):Boolean
        {
            return rectangleContainsPoint(headerRectangle, point);
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
            keyPoints["b"] = new Point(getX(dimensions), getY(dimensions));
            keyPoints["c0"] = new Point(getX(dimensions) + getHeaderPaddingLeft(dimensions), getY(dimensions));
            generateColumnIntermediates(keyPoints, dimensions, "c0");
            keyPoints["d0"] = new Point(getX(dimensions) + getColumnWidths(dimensions)[0], getY(dimensions));
            generateColumnIntermediates(keyPoints, dimensions, "d0");
            keyPoints["e"] = new Point(getX(dimensions) + getWidth(dimensions), getY(dimensions));

            const yUnderHeader:Number = getY(dimensions) + getActualHeaderHeight(grid);
            keyPoints["f0"] = new Point(getX(dimensions), yUnderHeader);
            generateColumnIntermediates(keyPoints, dimensions, "f0");
            keyPoints["g0"] = new Point(getX(dimensions) + getHeaderPaddingLeft(dimensions), yUnderHeader);
            generateColumnIntermediates(keyPoints, dimensions, "g0");
            keyPoints["h"] = new Point(getX(dimensions) + getWidth(dimensions), yUnderHeader);

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
            const topLeftCorner:Point = keyPoints["c0"];
            return new Rectangle(topLeftCorner.x, topLeftCorner.y, getHeaderWidthFromKeyPoints(keyPoints) - getHeaderPaddingLeft(dimensions), getHeaderHeightFromKeyPoints(keyPoints));
        }

        private function generateFixedHeaderViewRectangle(keyPoints:Array, dimensions:Array):Rectangle
        {
            //this is the GridColumnHeaderGroup.centerGridColumnHeaderView, which is holds the non-fixed columns; padding excluded
            const topLeftCorner:Point = keyPoints["b"];
            return new Rectangle(topLeftCorner.x, topLeftCorner.y, 0, 0);
        }

        private function generateVisibleHeaderRectangle(keyPoints:Array, dimensions:Array):Rectangle
        {
            const topLeftCorner:Point = keyPoints["b"];
            return new Rectangle(topLeftCorner.x, topLeftCorner.y, getHeaderWidthFromKeyPoints(keyPoints), getHeaderHeightFromKeyPoints(keyPoints));
        }

        private function generateHeaderColumnRectangles(keyPoints:Array, dimensions:Array):Array
        {
            var headerRectangles:Array = [];

            const headerHeight:Number = getHeaderHeightFromKeyPoints(keyPoints);
            for (var i:int = 0; i < getColumnWidths(dimensions).length; i++)
            {
                var topLeft:Point = keyPoints["c" + i];
                var topRight:Point = keyPoints["c" + (i+1)];
                headerRectangles.push(new Rectangle(topLeft.x, topLeft.y, topRight.x - topLeft.x, headerHeight));
            }

            //correct last header rectangle to extend to grid boundaries. This is one of the issues which prompted
            //this unit test in the first place.
            var lastHeaderRectangle:Rectangle = headerRectangles[headerRectangles.length - 1];
            lastHeaderRectangle.width = Point(keyPoints["e"]).x - lastHeaderRectangle.x;

            return headerRectangles;
        }

        private function get columnHeaderRectangles():Array
        {
            return _keyRectangles[COLUMN_HEADER_RECTANGLES];
        }

        private function get headerRectangle():Rectangle
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

        private function getColumnWidthFromKeyPoints(keyPoints:Array, columnIndex:int):Number
        {
            //we're assuming columnIndex has a valid value
            return Point(keyPoints["c" + (columnIndex + 1)]).x - Point(keyPoints["c" + columnIndex]).x;
        }

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

        private function getActualHeaderHeight(grid:DataGrid):Number
        {
            //Note that we're assuming the grid is on stage and validated by this point!
            return grid.columnHeaderGroup.height;
        }

        private function getHeaderHeightFromKeyPoints(keyPoints:Array):Number
        {
            return Point(keyPoints["h"]).y - Point(keyPoints["e"]).y;
        }

        private function getHeaderWidthFromKeyPoints(keyPoints:Array):Number
        {
            return Point(keyPoints["e"]).x - Point(keyPoints["b"]).x;
        }

        private function getColumnWidths(dimensions:Array):Array
        {
            return dimensions[5];
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