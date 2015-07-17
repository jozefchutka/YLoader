package yloader.impl.js;

import js.html.XMLHttpRequest;
import js.Browser;

import yloader.enums.Status;
import yloader.util.HeaderUtil;
import yloader.valueObject.Request;
import yloader.valueObject.Parameter;
import yloader.valueObject.Response;

class XMLHttpRequestLoader implements ILoader
{
	public var onResponse:Response->Void;
	public var request:Request;
	public var xhr:XMLHttpRequest;
	public var withCredentials:Bool;

	public function new(?request:Request)
	{
		this.request = request;
	}

	public function createXHR():XMLHttpRequest
	{
		return Browser.createXMLHttpRequest();
	}

	public function load()
	{
		cancel();
		xhr = createXHR();
		prepareXHR(xhr);
		xhr.send(request.data);
	}

	public function cancel()
	{
		if(xhr != null)
			disposeXHR(xhr);
		xhr = null;
	}

	function getStatus(xhr:XMLHttpRequest):Int
	{
		var result = try xhr.status catch(error:Dynamic) Status.FAILED_TO_CONNECT_OR_RESOLVE_HOST;
		return (result == untyped __js__("undefined")) ? Status.FAILED_TO_CONNECT_OR_RESOLVE_HOST : result;
	}

	function getHeaders(xhr:XMLHttpRequest):Array<Parameter>
	{
		var text = xhr.getAllResponseHeaders();
		var result = HeaderUtil.toParameters(text);
		return result;
	}

	function getResponse(xhr:XMLHttpRequest):Response
	{
		var status = getStatus(xhr);
		var success = isSuccess(status);
		var headers = getHeaders(xhr);
		return new Response(success, xhr.responseText, status, xhr.statusText, headers);
	}

	function isSuccess(status:Int):Bool
	{
		return status >= 200 && status < 400;
	}

	function handleResponse(xhr:XMLHttpRequest)
	{
		if(onResponse == null)
			return;

		var response = getResponse(xhr);
		onResponse(response);
	}

	function dispose()
	{
		cancel();
	}

	function prepareXHR(xhr:XMLHttpRequest)
	{
		var method = Std.string(request.method);

		xhr.onreadystatechange = onXHRReadyStateChange;
		xhr.open(method, request.urlWithQuery, true);

		if(withCredentials)
			xhr.withCredentials = true;

		for(header in request.headers)
			xhr.setRequestHeader(header.name, header.value);
	}

	function disposeXHR(xhr:XMLHttpRequest)
	{
		xhr.onreadystatechange = null;
		try xhr.abort() catch(error:Dynamic){}
	}

	function onXHRReadyStateChange(event:Dynamic)
	{
		if(xhr.readyState != 4)
			return;

		handleResponse(xhr);
		dispose();
	}
}
