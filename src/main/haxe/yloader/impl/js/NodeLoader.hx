package main.haxe.yloader.impl.js;

import haxe.DynamicAccess;
import js.node.buffer.Buffer;
import js.node.http.ClientRequest;
import js.node.Http.HttpRequestOptions;
import js.node.http.IncomingMessage;
import js.node.Http;
import js.node.Https.HttpsRequestOptions;
import js.node.Https;
import js.node.Url;
import yloader.ILoader;
import yloader.util.HeaderUtil;
import yloader.valueObject.Parameter;
import yloader.valueObject.Request;
import yloader.valueObject.Response;

class NodeLoader implements ILoader
{
	public var onResponse:Response->Void;
	public var request:Request;

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
		createClientRequest();
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

	function createClientRequest():Void
	{
		var url:UrlData = Url.parse(request.urlWithQuery, true);
		if (url.protocol == "http:")
			clientRequest = createHttpRequest(url);
		else if (url.protocol == "https:")
			clientRequest = createHttpsRequest(url);
	}

	function addClientRequestListeners():Void
	{
		clientRequest.on("error", onClientRequestError);
	}

	function removeClientRequestListeners():Void
	{
		clientRequest.removeAllListeners("error");
	}

	function writeData():Void
	{
		if (request.data == null || request.data.length < 1)
			return;

		if (clientRequest != null)
			clientRequest.write(request.data);
	}

	function endRequest():Void
	{
		if (clientRequest != null)
			clientRequest.end();
	}

	function createHttpRequest(url:UrlData):ClientRequest
	{
		var options:HttpRequestOptions = createOptions(url);
		options.headers = getHeaders();
		return Http.request(options, onRequestResponse);
	}

	function createHttpsRequest(url:UrlData):ClientRequest
	{
		var options:HttpsRequestOptions = createOptions(url);
		options.headers = getHeaders();
		return Https.request(options, onRequestResponse);
	}

	function createOptions(url:UrlData):Dynamic
	{
		return {
			host: url.host,
			port: Std.parseInt(url.port),
			path: url.path,
			method: Std.string(request.method)
		};
	}

	function getHeaders():Dynamic
	{
		var headers:Dynamic;
		headers = HeaderUtil.toObject(request.headers);
		setContentLengthHeader(headers);
		return headers;
	}

	function setContentLengthHeader(headers:Dynamic):Void
	{
		if (request.data == null || request.data.length < 1 || headers == null)
			return;

		if (Reflect.hasField(headers, "content-length") || Reflect.hasField(headers, "Content-Length"))
			return;

		Reflect.setField(headers, "Content-Length", Std.string(Buffer.byteLength(request.data)));
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
		return new Response(isSuccess(), responseObject, response.statusCode,
		response.statusMessage, getResponseHeaders(response));
	}

	function isSuccess():Bool
	{
		return response.statusCode >= 200 && response.statusCode < 400;
	}

	function getResponseHeaders(source:IncomingMessage):Array<Parameter>
	{
		var ret:Array<Parameter> = [];
		for (key in source.headers.keys())
			ret.push(new Parameter(key, source.headers.get(key)));

		return ret;
	}

	function onRequestResponse(response:IncomingMessage):Void
	{
		this.response = response;
		response.setEncoding("utf-8");
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
		cancel();
	}
}