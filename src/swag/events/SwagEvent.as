package swag.events {
	
	import swag.interfaces.events.ISwagEvent;
	
	/**
	 * The base class for all Swag events. This class may be sub-classed, or sent directly, to the <code>SwagDispatcher</code>.
	 * 
	 * @author Patrick Bay
	 * 
	 */	
	public class SwagEvent implements ISwagEvent {
		
		/**
		 * The default <code>SwagEvent</code> type. The string value "swagDefaultEvent" may also be used but
		 * using this constant value is advisable in order to prevent potentially numerous code updates if it ever changes. 
		 */
		public static const DEFAULT:String="swagDefaultEvent";
		private var _type:String=null;
		private var _parameters:Array=null;
		
		/**
		 * The default constructor for the SwagEvent class. 
		 *  
		 * @param eventType The type of event to created. It's highly advisable to use one of the event constant strings provided
		 * with the various event types in order to easily maintain code changes (especially if event types change in future revisions).
		 * @param args Additional arguments to provide to the event. These include:
		 * <ul>
		 * <li>parameters (<code>Array</code>) - Optional parameters to pass to the receiving listener. The parameters specified here
		 * are persistent -- they are maintained while the event object remains active. This allows updated values to be passed to
		 * subsequent listeners, but for the same reason the <code>parameters</code> object should not be assumed to have the same
		 * properties as when the event dispatch began.</li>
		 * </ul>
		 * 
		 * @see swag.core.SwagDispatcher
		 */
		public function SwagEvent(eventType:String=null, ... args) {
			this._type=eventType;
			this._parameters=args;
		}//constructor		
		
		/**
		 * 
		 * @return Returns the event type which should, ideally, match one of the constant <code>SwagEvent</code> types defined 
		 * in the toolkit.
		 * 
		 */
		public function get type():String {
			return (this._type);
		}//get type
		
		/**
		 * 
		 * @return Returns the associated parameters object associated with the event, or <em>null</em> if not defined.
		 * 
		 */
		public function get parameters():Array {
			return (this._parameters);
		}//get parameters
		
	}//SwagEvent class
	
}//package