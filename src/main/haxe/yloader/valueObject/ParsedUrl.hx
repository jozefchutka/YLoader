package yloader.valueObject;

class ParsedUrl
{
	public var protocol(default, null):String;
	public var username(default, null):String;
	public var password(default, null):String;
	public var host(default, null):String;
	public var hostname(default, null):String;
	public var port(default, null):String;
	public var pathname(default, null):String;
	public var path(default, null):String;
	public var search(default, null):String;
	public var hash(default, null):String;

	public function new(protocol:String, username:String, password:String, host:String, hostname:String, port:String,
		pathname:String, path:String, search:String, hash:String)
	{
		this.protocol = protocol;
		this.username = username;
		this.password = password;
		this.host = host;
		this.hostname = hostname;
		this.port = port;
		this.pathname = pathname;
		this.path = path;
		this.search = search;
		this.hash = hash;
	}
}
