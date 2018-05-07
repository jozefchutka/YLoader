package yloader.sample;

class Main
{
	public static function main()
	{
		var a:Array<Dynamic> = [
			yloader.enums.Method,
			yloader.enums.Status,
			yloader.impl.js.Loader,
			yloader.impl.js.NodeLoader,
			yloader.impl.js.XDomainRequestLoader,
			yloader.impl.js.XMLHttpRequestLoader,
			yloader.util.HeaderUtil,
			yloader.util.ParameterUtil,
			yloader.valueObject.Parameter,
			yloader.valueObject.Request,
			yloader.valueObject.Response,
			yloader.ILoader
		];
	}
}
