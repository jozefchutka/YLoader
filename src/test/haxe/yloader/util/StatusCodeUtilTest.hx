package yloader.util;

import massive.munit.Assert;

class StatusCodeUtilTest
{
	@BeforeClass
	public function beforeClass():Void
	{
	}

	@AfterClass
	public function afterClass():Void
	{
	}

	@Before
	public function setup():Void
	{
	}

	@After
	public function tearDown():Void
	{
	}

	@Test
	public function statusCode_isSuccess_matches():Void
	{
		var statusCodeNotFound:Int = 404;
		var statusCodeOk = 200;
		var statusCodeMovedPermanently = 301;

		Assert.isFalse(StatusCodeUtil.isSuccess(statusCodeNotFound));
		Assert.isTrue(StatusCodeUtil.isSuccess(statusCodeOk));
		Assert.isTrue(StatusCodeUtil.isSuccess(statusCodeMovedPermanently));
	}
}
