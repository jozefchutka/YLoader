package yloader.util;

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
}
