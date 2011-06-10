package swag.core.instances {
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import swag.core.SwagDataTools;
	import swag.interfaces.core.instances.ISwagSequence;
	
	/**
	 * @private
	 * 
	 * Controls the monitoring and execution of a single sequence instance within a <code>SwagSequencer</code> execution stack.
	 * <p>Typically, the <code>SwagSequence</code> class is not instantiated or used alone and is instead created by the <code>SwagSequencer</code>.
	 * However, properties of the sequence class may be inspected and updated directly once created.</p>
	 * 
	 * @author Patrick Bay
	 * 
	 * @see swag.core.SwagSequencer
	 * 
	 */
	public class SwagSequence implements ISwagSequence {
		
		public static const TIMETYPE:String="SwagSequence.TIMETYPE";
		
		private var _type:String=null;
		
		public function SwagSequence(type:String=null, ... args) {
			this._type=type;
		}//constructor
		
		
	}//SwagSequence class
	
}//package