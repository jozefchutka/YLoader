package yloader;

import yloader.valueObject.Response;
import yloader.valueObject.Request;

interface ILoader
{
	var onResponse:Response->Void;
	var request:Request;

	/**
	 * Sends the header and request data. Multiple load()s can be executed on the same loader instance. With each
	 * load() the previous request is cancelled if pending.
	 **/
	function load():Void;

	/**
	 * After cancel() is called, the class is ready to be garbage collected as well as another load() can be executed
	 * again.
	 **/
	function cancel():Void;
}
