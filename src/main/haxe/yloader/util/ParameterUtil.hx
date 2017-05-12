package yloader.util;

import yloader.valueObject.Parameter;

class ParameterUtil
{
	public static function update(list:Array<Parameter>, parameter:Parameter)
	{
		var found:Bool = false;
		for(item in list)
			if(item.name == parameter.name)
			{
				item.value = parameter.value;
				found = true;
			}
		if(!found)
			list.push(parameter);
	}

	public static function urlEncode(list:Array<Parameter>):String
	{
		var result = null;
		for(item in list)
			result = ((result == null) ? "" : (result + "&"))
				+ StringTools.urlEncode(item.name) + "=" + StringTools.urlEncode(item.value);
		return result;
	}

	public static function fromQueryString(source:String):Array<Parameter>
	{
		if(source == null)
			return null;

		var queryString = source.substr(0, 1) == "?" ? source.substr(1) : source;
		if(queryString == "")
			return null;

		var result:Array<Parameter> = [];
		var pairs = queryString.split("&");
		for(pair in pairs)
			result.push(fromPair(pair));
		return result;
	}

	static function fromPair(pair:String):Parameter
	{
		var index = pair.indexOf("=");
		var name;
		var value = "";
		if(index >= 0)
		{
			name = StringTools.urlDecode(pair.substring(0, index));
			value = StringTools.urlDecode(pair.substring(index + 1));
		}
		else
		{
			name = StringTools.urlDecode(pair);
		}
		return new Parameter(name, value);
	}
}
