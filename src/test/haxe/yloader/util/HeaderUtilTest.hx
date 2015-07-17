package yloader.util;

import massive.munit.async.AsyncFactory;
import massive.munit.Assert;

class HeaderUtilTest
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
	public function customHeader_toParameters_matches():Void
	{
		var header = "hello:world\nfoo : bar";
		var params = HeaderUtil.toParameters(header);

		Assert.areEqual(2, params.length);
		Assert.areEqual(params[0].name, "hello");
		Assert.areEqual(params[0].value, "world");
		Assert.areEqual(params[1].name, "foo");
		Assert.areEqual(params[1].value, "bar");
	}
}