package yloader.impl.js;

import js.Browser;
import js.html.XMLHttpRequest;
import yloader.enums.Status;
import yloader.util.UrlUtil;
import yloader.valueObject.Response;

class XDomainRequestLoader extends XMLHttpRequestLoader
{
	public static var isAvailable(get, never):Bool;

	var response:Response;

	override function createXHR():XMLHttpRequest
	{
		return untyped __new__("XDomainRequest");
	}

	static function get_isAvailable():Bool
	{
		return untyped __js__("typeof XDomainRequest") != "undefined";
	}

	public static function isPreferred(url:String):Bool
	{
		if(!isAvailable)
			return false;

		if(url.indexOf('http://') != 0 && url.indexOf('https://') != 0)
			return false;

		var originParser = UrlUtil.parse(Browser.document.location.href);
		var urlParser = UrlUtil.parse(url);

		if(originParser.protocol != urlParser.protocol)
			return false;

		if(originParser.host == urlParser.host)
			return false;

		return true;
	}

	override function load()
	{
		response = null;

		super.load();
	}

	override function isSuccess(status:Int):Bool
	{
		return (response != null) || super.isSuccess(status);
	}

	override function getHeaders(xhr:XMLHttpRequest)
	{
		return null;
	}

	override function getResponse(xhr:XMLHttpRequest):Response
	{
		return response;
	}

	override function prepareXHR(xhr:XMLHttpRequest)
	{
		super.prepareXHR(xhr);

		xhr.onreadystatechange = null;
		xhr.onload = onXDomainRequestOnLoad;
		xhr.onerror = onXDomainRequestOnError;
		xhr.onprogress = onXDomainRequestOnProgress;
	}

	override function disposeXHR(xhr:XMLHttpRequest)
	{
		xhr.onload = null;
		xhr.onerror = null;
		xhr.onprogress = null;

		super.disposeXHR(xhr);
	}

	function onXDomainRequestOnLoad(event:Dynamic)
	{
		response = new Response(true, xhr.responseText, Status.UNKNOWN);
		handleResponse(xhr);
		dispose();
	}

	function onXDomainRequestOnError(event:Dynamic)
	{
		response = new Response(false, xhr.responseText, Status.UNKNOWN);
		handleResponse(xhr);
		dispose();
	}

	function onXDomainRequestOnProgress(event:Dynamic)
	{
	}
}