package mx.utils
{
import flash.display.DisplayObject;
import flash.utils.getTimer;

import mx.core.UIComponent;

CONFIG::performanceInstrumentation
public final class PerfUtil
{
	public function PerfUtil()
	{
		idVector = new Vector.<String>();
		timeVector = new Vector.<uint>();
	}
    
	private static var _instance:PerfUtil;
	
	private var idVector:Vector.<String>;
	private var timeVector:Vector.<uint>;
	private var startSamplingCount:int = 0;
	private var detailedSamplingCount:int = 0;
	
	/**
	 *  @return Returns the PerfUtil instance. 
	 */
	static public function getInstance():PerfUtil
	{
		if (!_instance)
			_instance = new PerfUtil();	
		return _instance;
	}
	
	// types of time stamps:
	private const MARK:uint 						= 0x00000000;
	private const START:uint 						= 0x20000000;
	private const END:uint 							= 0x40000000;
	private const TEST_CASE_START_ABSOLUTE:uint 	= 0x60000000;
	private const TEST_CASE_START_RELATIVE:uint 	= 0x80000000;
	private const TEST_CASE_END:uint 				= 0xA0000000;
	private const IGNORE:uint 						= 0xC0000000;
	private const TIME_MASK:uint 					= 0x1FFFFFFF;	// 29 bits for time values
	private const FLAG_MASK:uint 					= ~TIME_MASK;	// 3 bits for flags
    
    public static var detailedSampling:Boolean = false;

	/**
	 *  Starts gathering samples associated with the <code>testCase</code>
	 * 
	 *  @param testCase The name of the test case.
	 *  @param absoluteTime Whether to log samples relative to the startSampling() call or
	 *  relative to the run-time VM boot time.
	 */
	public function startSampling(testCase:String, absoluteTime:Boolean):void
	{
		++startSamplingCount;
		timeVector.push( absoluteTime ? TEST_CASE_START_ABSOLUTE : TEST_CASE_START_RELATIVE ); // Test case started
		idVector.push(testCase);
		markTime(testCase);
	}
	
	/**
	 *  Stops gathering samples for the specified testCase.
	 *
	 *  @param testCase The name of the test case.
	 */
	public function finishSampling(testCase:String):void
	{
		timeVector.push( TEST_CASE_END ); // Test case finished
		idVector.push(testCase);
		markTime(testCase);
		--startSamplingCount;
	}
	
	/**
	 *  Marks the start of an event to be measured. Call right before the event.
	 * 
	 *  @return Returns the token associated with the event being measured. This token is later on
	 *  passed to markEnd() when the event has completed.
	 */
	public function markStart():int
	{
		if (startSamplingCount <= 0)
			return -1;
		
		var time:uint = flash.utils.getTimer();
		idVector.push(null); // mark differently instead of pushing ".start" or ".end" - use the senior 2 bits from the time stamp, avoids unnecessary string operations
		
		// Start
		time |= START;
		timeVector.push(time);
		
		return timeVector.length - 1;
	}
	
	/**
	 *  Marks the end of an event being measured. Call right after the event.
	 *  If the event is logged, tolerance permitting, the summary
	 *  (through getSummary() method) will contain the following two entries:
	 *
	 *  "[time at markStart] : [name].start\n"
	 *  "[time at markEnt] : [name].end\n"
	 * 
	 *  @param name The event name, will be shown in the log
	 *  @param token The token returned by the markStart() method
	 *  @param tolerance Tolerance in miliseconds. If the event took less than the tolerance,
	 *  it will be omitted from the log.
	 */
	public function markEnd(name:String, token:int, tolerance:int = 0, idObject:Object = null):void
	{
		if (startSamplingCount <= 0 || token < 0 )
			return;
		
		var time:uint = flash.utils.getTimer();
		var startTime:uint = timeVector[token] & TIME_MASK;
		if (time - startTime < tolerance)
		{
			// If the start is the last element, then pop it off the stack,
			// otherwise set it to "ignore" (don't delete elements in the middle of the vector)
			if (token == timeVector.length - 1)
			{
				timeVector.pop();
				idVector.pop();
			}
			else
				timeVector[token] = IGNORE; 
			return;
		}
        
        if (idObject)
        {
            if (idObject is DisplayObject)
                name = (idObject as DisplayObject).name + name;
            else
                name = idObject.toString() + name;
        }
		
		idVector[token] = name; // Fix the start id
		idVector.push(name);
		time |= END;
		timeVector.push(time);
	}
	
	/**
	 *  Adds the following entry to the summary:
	 *
	 *  "[time at markTime] : [name]\n"
	 */
	public function markTime(name:String):void
	{
		if (startSamplingCount <= 0)
			return;
		var time:int = flash.utils.getTimer();
		timeVector.push(time);
		idVector.push(name);
	}
	
	/**
	 *  Returns the summary for the sampling session.
	 * 
	 * Example of instrumentation:
	 * class SystemManager
	 * { 
	 *    SystemManager():void
	 *    {
	 *       PerfUtil.getInstance().startSampling("Application Startup", true);
	 *       PerfUtil.getInstance().markTime("SystemManager c-tor");
	 *       ...
	 *    }
	 * 
	 *    initHandler()
	 *    {
	 *       var token:int = PerfUtil.getInstance().markStart();
	 *       ...
	 *       PerfUtil.getInstance().markEnd("SystemManager.initHandler()", token);
	 *    }
	 * 
	 *    kickOff()
	 *    {
	 *       var token:int = PerfUtil.getInstance().markStart();
	 *       ...
	 *       ResourceManager.getInstance();
	 *       ...
	 *       PerfUtil.getInstance().markEnd("SystemManager.kickOff()", token);
	 *       PerfUtil.getInstacne().finishSampling("Application Startup");
	 *    }
	 * }
	 * 
	 * class ResourceManager
	 * {
	 *    getInstance()
	 *    {
	 *       var token:int = PerfUtil.getInstance().markStart();
	 *       ...
	 *       PerfUtil.getInstance().markEnd("ResourceManager.getInstance()", token);
	 *    }
	 * }
	 * 
	 * When instrumentattion is completed, a call to PerfUtil.getInstance().getSummary() will
	 * return the following output:
	 * --------------------
	 * Application Startup
	 * 
	 * 225 : SystemManager c-tor
	 * 226 : SystemManager.initHandler().start
	 * 238 : SystemManager.initHandler().end
	 * 455 : SystemManager.kickOff().start
	 * 459 : ResourceManager.getInstance().start
	 * 489 : ResourceManager.getInstance().end
	 * 495 : SystemManager.kickOff().end 
	 */	
	public function getSummary():String
	{
		var testCases:Vector.<String> = new Vector.<String>();
		var testCasesStart:Vector.<int> = new Vector.<int>();
		
		var summary:String = "";
		
		var count:int = timeVector.length;
		for (var i:int = 0; i < count; i++)
		{
			var flag:uint = flagAt(i);
			
			if (flag == TEST_CASE_START_ABSOLUTE || flag == TEST_CASE_START_RELATIVE)
			{
				// A new test case
				testCasesStart.push(i);
				testCases.push(idVector[i]);
			}
			else if (flag == TEST_CASE_END)
			{
				// Finished a test case
				var testCaseName:String = this.idVector[i];
				
				// Close the last matching testCaseName
				for (var k:int = testCases.length - 1; k >= 0; k--)
				{
					if (testCases[k] == testCaseName)
					{
						// Print summary for the test case
						summary += getSummaryFor(testCaseName, testCasesStart[k], i + 1);
						break;
					}
				}
			}
		}
		
		return summary;
	}
	
	private function flagAt(index:int):uint
	{
		return timeVector[index] & FLAG_MASK;	
	}
	
	private function timeAt(index:int):uint
	{
		return timeVector[index] & TIME_MASK;
	}
	
	private function getSummaryFor(name:String, startIndex:int, endIndex:int):String
	{
		var timeOffset:int = (flagAt(startIndex) == TEST_CASE_START_ABSOLUTE) ? 0 : timeAt(startIndex + 1);
		var summary:String = "--------------------\n" + name;
		if (timeOffset > 0)
		{
			summary += ", time stamps relative to " + timeAt(startIndex + 1); 
		}
		summary += "\n" + "\n";
		
		var stampName:String;
		for (var i:int = startIndex; i < endIndex; i++)
		{
			var flag:uint = flagAt(i);
			if (flag == IGNORE)
				continue;
			
			if (flag == TEST_CASE_START_ABSOLUTE ||
				flag == TEST_CASE_START_RELATIVE ||
				flag == TEST_CASE_END)
			{
				i++;
				continue;
			}
			
			var timeStamp:uint = timeAt(i);
			stampName = idVector[i];
			
			if (flag == START)
				stampName += " .start";
			else if (flag == END)
				stampName += " .end";
			
			summary += ((timeStamp - timeOffset).toString() + " : " + stampName + "\n"); 
		}
		return summary;
	}
}
}