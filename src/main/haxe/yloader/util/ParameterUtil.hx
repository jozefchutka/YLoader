package yloader.util;

import yloader.valueObject.Parameter;

class ParameterUtil
{
	public static inline var PARAMETER_CONTENT_LENGTH = "content-length";

	public static function update(list:Array<Parameter>, parameter:Parameter)
	{
		var found:Bool = false;
		for(item in list)
			if(normalizeName(item.name) == normalizeName(parameter.name))
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

	public static function fromText(text:String):Array<Parameter>
	{
		var lines = text.split("\n");
		var result:Array<Parameter> = [];
		for(line in lines)
		{
			if(line == "")
				continue;
			var data = line.split(":");
			var name = StringTools.trim(data.shift());
			var value = StringTools.trim(data.join(":"));
			result.push(new Parameter(name, value));
		}
		return result;
	}

	public static function getContentLength(list:Array<Parameter>):Int
	{
		for (item in list)
			if (normalizeName(item.name) == PARAMETER_CONTENT_LENGTH)
				return Std.parseInt(item.value);
		return null;
	}

	public static function setContentLength(value:Int, target:Array<Parameter>):Void
	{
		update(target, new Parameter(PARAMETER_CONTENT_LENGTH, Std.string(value)));
	}

	public static function toObject(list:Array<Parameter>):Dynamic
	{
		var result = {};
		for (item in list)
			Reflect.setField(result, item.name, item.value);
		return result;
	}

	static function normalizeName(name:String):String
	{
		return name.toLowerCase();
	}
}
