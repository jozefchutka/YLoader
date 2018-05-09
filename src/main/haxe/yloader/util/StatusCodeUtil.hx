package yloader.util;

class StatusCodeUtil
{
	public static function isSuccess(statusCode:Int):Bool
	{
		return statusCode >= 200 && statusCode < 400;
	}
}
