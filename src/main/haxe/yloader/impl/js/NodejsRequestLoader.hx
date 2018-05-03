package main.haxe.yloader.impl.js;

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

class NodejsRequestLoader implements ILoader
{
	public var onResponse:Response->Void;
	public var request:Request;

	var clientRequest:ClientRequest;
	var responseString:String;
	var statusCode:Int;
	var statusText:String;
	var responseHeaders:Array<Parameter>;

	public function new(?request:Request)
	{
		this.request = request;
	}

	public function load():Void
	{
		cancel();
		createRequest();
		writeData();
		endRequest();
	}

	public function cancel():Void
	{
		if (clientRequest != null)
			clientRequest.abort();
		clientRequest = null;
		responseString = "";
		statusCode = 0;
		statusText = "";
	}

	function createRequest():Void
	{
		var url:UrlData = Url.parse(request.urlWithQuery, true);
		switch (url.protocol)
		{
			case "http:":
				clientRequest = createHttpRequest(url);
			case "https:":
				clientRequest = createHttpsRequest(url);
			default:
		}
		clientRequest.on("error", onError);
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
		var options:HttpRequestOptions = {
			host: url.host,
			port: url.port == "" ? 80 : Std.parseInt(url.port),
			path: url.path,
			method: Std.string(request.method)
		};

		setContentLengthHeader();
		if (request.headers != null && request.headers.length > 0)
			options.headers = HeaderUtil.arrayToJson(request.headers);

		return Http.request(options, onRequestResponse);
	}

	function createHttpsRequest(url:UrlData):ClientRequest
	{
		var options:HttpsRequestOptions = {
			host: url.host,
			port: url.port == "" ? 443 : Std.parseInt(url.port),
			path: url.path,
			method: Std.string(request.method)
		};

		setContentLengthHeader();
		if (request.headers != null && request.headers.length > 0)
			options.headers = HeaderUtil.arrayToJson(request.headers);

		return Https.request(options, onRequestResponse);
	}

	function setContentLengthHeader():Void
	{
		if (request.data == null || request.data.length < 1)
			return;

		for (header in request.headers)
			if (header.name.toLowerCase().indexOf("content-length") > -1)
				return;
		request.headers.push(new Parameter("Content-Length", Std.string(Buffer._byteLength(request.data))));
	}

	function handleResponse(responseObject:Dynamic)
	{
		if(onResponse == null)
			return;

		var response = getResponse(responseObject);
		onResponse(response);
	}

	function getResponse(responseObject:Dynamic):Response
	{
		return new Response(isSuccess(), responseObject , statusCode, statusText, responseHeaders);
	}

	function isSuccess():Bool
	{
		return statusCode >= 200 && statusCode < 400;
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
		statusCode = response.statusCode;
		statusText = response.statusMessage;
		responseHeaders = getResponseHeaders(response);
		response.setEncoding("utf-8");
		response.on('data', onData);
		response.on('end', onEnd);
	}

	function onData(data:String):Void
	{
		responseString += data;
	}

	function onEnd(data:Dynamic):Void
	{
		handleResponse(responseString);
		cancel();
	}

	function onError(error:Dynamic):Void
	{
		cancel();
	}
}
