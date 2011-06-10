package swag.events {
	
	/**
	 * @private
	 * @author Patrick Bay
	 */
	public class SwagSequenceEvent extends SwagEvent {
		
		public static const START:String="SwagEvent.SwagSequenceEvent.START";
		public static const STOP:String="SwagEvent.SwagSequenceEvent.START";
		public static const END:String="SwagEvent.SwagSequenceEvent.END";
		
		public function SwagSequenceEvent(eventType:String=null, ...args) {
			super(eventType, args);
		}//constructor
		
	}//SwagSequenceEvent class
	
}//package