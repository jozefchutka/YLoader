package yloader.valueObject;

class Response
{
	public var success(default, null):Bool;
	public var data(default, null):String;
	public var status(default, null):Int;
	public var statusText(default, null):String;
	public var headers(default, null):Array<Parameter>;

	public function new(success:Bool, data:String, status:Int, statusText:String=null, headers:Array<Parameter>=null)
	{
		this.success = success;
		this.data = data;
		this.status = status;
		this.statusText = statusText;
		this.headers = headers;
	}
}
