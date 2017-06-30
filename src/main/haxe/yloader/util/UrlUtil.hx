package yloader.util;

import js.Browser;
import yloader.valueObject.ParsedUrl;

class UrlUtil
{
	public static function parse(url:String):ParsedUrl
	{
		var parser = Browser.document.createAnchorElement();
		parser.href = url;

		// IE is missing slash in hostname if Anchor not added to document.
		// https://stackoverflow.com/questions/956233/javascript-pathname-ie-quirk
		// https://connect.microsoft.com/ie/feedback/details/817343
		// https://connect.microsoft.com/IE/Feedback/Details/1002846
		if(parser.pathname.substr(0, 1) != "/" && Browser.document.head != null)
			Browser.document.head.appendChild(parser).parentElement.removeChild(parser);

		return new ParsedUrl(parser.protocol, parser.username, parser.password, parser.host, parser.hostname,
			parser.port, parser.pathname, parser.search, parser.hash);
	}
}
