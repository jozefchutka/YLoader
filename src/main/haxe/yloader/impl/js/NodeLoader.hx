package yloader.impl.js;

import js.node.buffer.Buffer;
import js.node.http.ClientRequest;
import js.node.Http.HttpRequestOptions;
import js.node.http.IncomingMessage;
import js.node.Http;
import js.node.Https.HttpsRequestOptions;
import js.node.Https;
import js.node.Url;
import yloader.ILoader;
import yloader.util.ParameterUtil;
import yloader.util.StatusCodeUtil;
import yloader.valueObject.Parameter;
import yloader.valueObject.Request;
import yloader.valueObject.Response;

class NodeLoader implements ILoader
{
	public var onResponse:Response->Void;
	public var request:Request;
	public var responseEncoding = "utf-8";

	var clientRequest:ClientRequest;
	var response:IncomingMessage;
	var responseString:String;

	public function new(?request:Request)
	{
		this.request = request;
	}

	public function load():Void
	{
		cancel();
		clientRequest = createClientRequest();
		addClientRequestListeners();
		writeData();
		endRequest();
	}

	public function cancel():Void
	{
		if (clientRequest != null)
		{
			removeClientRequestListeners();
			clientRequest.abort();
		}
		clientRequest = null;
		response = null;
		responseString = "";
	}

	function createClientRequest():ClientRequest
	{
		var url = Url.parse(request.urlWithQuery, true);
		var options = createOptions(url);

		if (url.protocol == "http:")
			return Http.request(options, onRequestResponse);
		if (url.protocol == "https:")
			return Https.request(options, onRequestResponse);

		return null;
	}

	function createOptions(url:UrlData):HttpsRequestOptions
	{
		return {
			host: url.host,
			port: Std.parseInt(url.port),
			path: url.path,
			method: Std.string(request.method),
			headers: ParameterUtil.toObject(createHeaders())
		};
	}

	function createHeaders():Array<Parameter>
	{
		var result = request.headers.copy();

		if (requestHasData() && ParameterUtil.getContentLength(result) == null)
			ParameterUtil.setContentLength(Buffer.byteLength(request.data), result);

		return result;
	}

	function addClientRequestListeners():Void
	{
		clientRequest.on("error", onClientRequestError);
	}

	function removeClientRequestListeners():Void
	{
		clientRequest.removeListener("error", onClientRequestError);
	}

	function writeData():Void
	{
		if (requestHasData())
			clientRequest.write(request.data);
	}

	function endRequest():Void
	{
		clientRequest.end();
	}

	function requestHasData():Bool
	{
		return request.data != null && request.data.length > 0;
	}

	function handleResponse(responseObject:Dynamic)
	{
		if(onResponse == null || response == null)
			return;

		var response = getResponse(responseObject);
		onResponse(response);
	}

	function getResponse(responseObject:Dynamic):Response
	{
		return new Response(isSuccess(response.statusCode), responseObject, response.statusCode,
			response.statusMessage, rawHeadersToParameters(response.rawHeaders));
	}

	function isSuccess(statusCode:Int):Bool
	{
		return StatusCodeUtil.isSuccess(statusCode);
	}

	function rawHeadersToParameters(source:Array<String>):Array<Parameter>
	{
		var i = 0, result:Array<Parameter> = [];
		while (i < source.length)
			result.push(new Parameter(source[i++], source[i++]));

		return result;
	}

	function onRequestResponse(response:IncomingMessage):Void
	{
		this.response = response;
		response.setEncoding(responseEncoding);
		response.on("data", onIncomingMessageData);
		response.on("end", onIncomingMessageEnd);
	}

	function onIncomingMessageData(data:String):Void
	{
		responseString += data;
	}

	function onIncomingMessageEnd(data:Dynamic):Void
	{
		handleResponse(responseString);
		cancel();
	}

	function onClientRequestError(error:Dynamic):Void
	{
		if (onResponse != null)
			onResponse(new Response(false, null, 0, null, null));
	}
}