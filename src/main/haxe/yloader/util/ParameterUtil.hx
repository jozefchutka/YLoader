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
}
