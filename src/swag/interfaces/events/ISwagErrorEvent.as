package swag.interfaces.events {
	
	/**
	 * @private
	 * @author Patrick Bay 
	 */
	public interface ISwagErrorEvent {
		
		function set description(descriptionSet:String):void;
		function get description():String;
		function set remedy(remedySet:String):void;		
		function get remedy():String;
		
	}//ISwagErrorEvent interface
	
}//package