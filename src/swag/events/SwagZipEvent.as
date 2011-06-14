package swag.events {
	
	import swag.events.SwagEvent;
	import swag.interfaces.core.instances.ISwagZipEvent;
	
	public class SwagZipEvent extends SwagEvent implements ISwagZipEvent {
		
		/**
		 * Invoked when the associated <code>SwagZip</code> object has completed parsing the Zip file's directory info.
		 * <p>The Zip data of the <code>SwagZip</code> can only be used once this information has been
		 * parsed, otherwise it's not possible to know where individual files / directories begin, how
		 * large they are, etc.</p>
		 */
		public static const PARSEDIRECTORY:String="SwagEvent.SwagZipEvent.PARSEDIRECTORY";
		/**
		 * Invoked when the associated <code>SwagZip</code> object has completed parsing the Zip file's
		 * main header information.
		 * <p>This event will be broadcast first, before <code>SwagZipEvent.PARSEDIRECTORY</code>.</p>
		 */
		public static const PARSEHEADER:String="SwagEvent.SwagZipEvent.PARSEHEADER";
		
		/**
		 * Default constructor for the class.
		 *  
		 * @param eventType The type of event to create.
		 * @param args Additional arguments to provide to the event. These include:
		 * <ul>
		 * <li>parameters (<code>Array</code>) - Optional parameters to pass to the receiving listener. The parameters specified here
		 * are persistent -- they are maintained while the event object remains active. This allows updated values to be passed to
		 * subsequent listeners, but for the same reason the <code>parameters</code> object should not be assumed to have the same
		 * properties as when the event dispatch began.</li>
		 * </ul>
		 * 
		 */
		public function SwagZipEvent(eventType:String=null, ... args) {
			super(eventType, args);
		}//constructor
		
	}//SwagZipEvent class
	
}//package