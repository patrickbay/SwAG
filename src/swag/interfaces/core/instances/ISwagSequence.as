package swag.interfaces.core.instances {
	
	/**
	 * @private
	 * @author Patrick Bay	 
	 */
	public interface ISwagSequence	{
		
		function start():void;
		function stop():void;
		function set method(methodSet:Function):void;		
		function get method():Function;
		
	}//ISwagSequence interface

}//package