package swag.interfaces.events {
		
	/**
	 * @private
	 * @author Patrick Bay 
	 */
	public interface ISwagEvent {	
		function set source(sourceSet:*):void;
		function get source():*;
		function set type(typeSet:String):void;
		function get type():String;
	}//IswagEvent interface
	
}//package