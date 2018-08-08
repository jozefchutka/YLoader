package yloader.util;

import yloader.valueObject.ParsedUrl;

class UrlUtil
{
	public static function parse(url:String):ParsedUrl
	{
		#if nodejs
		var parser = js.node.Url.parse(url, true);
		var auth = parser.auth;
		var username = auth != null ? auth.split(":")[0] : null;
		var password = auth != null ? auth.split(":")[1] : null;
		return new ParsedUrl(parser.protocol, username, password, parser.host, parser.hostname,
			parser.port, parser.pathname, parser.path, parser.search, parser.hash);
		#else
		var document = js.Browser.document;
		var parser = document.createAnchorElement();
		parser.href = url;

		// IE is missing slash in hostname if Anchor not added to document.
		// https://stackoverflow.com/questions/956233/javascript-pathname-ie-quirk
		// https://connect.microsoft.com/ie/feedback/details/817343
		// https://connect.microsoft.com/IE/Feedback/Details/1002846
		if(parser.pathname.substr(0, 1) != "/" && document.head != null)
			document.head.appendChild(parser).parentElement.removeChild(parser);

		var port = parser.port == "" ? null : parser.port;
		var username = parser.username == "" ? null : parser.username;
		var password = parser.password == "" ? null : parser.password;
		var hash = parser.hash == "" ? null : parser.hash;
		return new ParsedUrl(parser.protocol, username, password, parser.host, parser.hostname,
			port, parser.pathname, parser.pathname + parser.search, parser.search, hash);
		#end
	}
}
