package yloader.valueObject;

import yloader.enums.Method;
import yloader.util.ParameterUtil;

class Request
{
	public var url:String;
	public var method:Method;
	public var headers:Array<Parameter>;
	public var getParameters:Array<Parameter>;
	public var data:String;

	public var urlWithQuery(get, never):String;

	public function new(?url:String)
	{
		this.url = url;
		this.method = Method.GET;

		headers = [];
		getParameters = [];
	}

	function get_urlWithQuery()
	{
		var query:String = ParameterUtil.urlEncode(getParameters);
		var result:String = url;
		if(query != null)
			result += ((result.indexOf("?") == -1) ? "?" : "&") + query;
		return result;
	}

	public function setHeader(header:Parameter)
	{
		ParameterUtil.update(headers, header);
	}

	public function setGetParameter(parameter:Parameter)
	{
		ParameterUtil.update(getParameters, parameter);
	}
}
