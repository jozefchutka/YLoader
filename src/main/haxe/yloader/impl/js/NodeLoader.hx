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
import yloader.util.HeaderUtil;
import yloader.valueObject.Parameter;
import yloader.valueObject.Request;
import yloader.valueObject.Response;

class NodeLoader implements ILoader
{
	public var onResponse:Response->Void;
	public var request:Request;

	private inline static var RESPONSE_ENCODING = "utf-8";

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
		var url:UrlData = Url.parse(request.urlWithQuery, true);
		switch (url.protocol)
		{
			case "http:":
				return createHttpRequest(url);
			case "https:":
				return createHttpsRequest(url);
			default:
				throw "Unrecognized protocol. Failed to create request.";
		}
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
		if (clientRequest != null)
			clientRequest.end();
	}

	function createHttpRequest(url:UrlData):ClientRequest
	{
		var options:HttpRequestOptions = createOptions(url);
		return Http.request(options, onRequestResponse);
	}

	function createHttpsRequest(url:UrlData):ClientRequest
	{
		var options:HttpsRequestOptions = cast createOptions(url);
		return Https.request(options, onRequestResponse);
	}

	function createOptions(url:UrlData):HttpRequestOptions
	{
		var options:HttpRequestOptions = {
			host: url.host,
			port: Std.parseInt(url.port),
			path: url.path,
			method: Std.string(request.method)
		};

		options.headers = getHeaders();
		return options;
	}

	function getHeaders():Dynamic
	{
		var headers = HeaderUtil.toObject(request.headers);
		setContentLengthHeader(headers);
		return headers;
	}

	function setContentLengthHeader(headers:Dynamic):Void
	{
		if (!requestHasData()
			|| Reflect.hasField(headers, "content-length")
			|| Reflect.hasField(headers, "Content-Length"))
			return;

		Reflect.setField(headers, "Content-Length", Std.string(Buffer.byteLength(request.data)));
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
		return new Response(isSuccess(), responseObject, response.statusCode,
			response.statusMessage, getResponseHeaders(response));
	}

	function isSuccess():Bool
	{
		return response.statusCode >= 200 && response.statusCode < 400;
	}

	function getResponseHeaders(source:IncomingMessage):Array<Parameter>
	{
		var result:Array<Parameter> = [];
		for (key in source.headers.keys())
			result.push(new Parameter(key, source.headers.get(key)));

		return result;
	}

	function onRequestResponse(response:IncomingMessage):Void
	{
		this.response = response;
		response.setEncoding(RESPONSE_ENCODING);
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
		throw error;
	}
}