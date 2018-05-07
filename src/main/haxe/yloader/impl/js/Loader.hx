package yloader.impl.js;

import yloader.valueObject.Request;

class Loader
{
	public dynamic static function create(request:Request):XMLHttpRequestLoader
	{
		return XDomainRequestLoader.isPreferred(request.url)
			? new XDomainRequestLoader(request)
			: new XMLHttpRequestLoader(request);
	}
}
