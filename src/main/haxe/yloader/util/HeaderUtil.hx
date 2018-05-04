package yloader.util;

import haxe.DynamicAccess;
import yloader.valueObject.Parameter;

class HeaderUtil
{
	public static function toParameters(text:String):Array<Parameter>
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

	public static function arrayToJson(list:Array<Parameter>):DynamicAccess<Dynamic>
	{
		if (list == null)
			return {};

		var ret:DynamicAccess<Dynamic> = {};
		for (header in list)
			ret.set(header.name, header.value);

		return ret;
	}
}
