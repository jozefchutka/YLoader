package yloader.util;

import massive.munit.async.AsyncFactory;
import massive.munit.Assert;

import yloader.valueObject.Parameter;

class ParameterUtilTest
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
	public function customList_update_replacesValue():Void
	{
		var list:Array<Parameter> = [];

		ParameterUtil.update(list, new Parameter("p1", "v1"));
		ParameterUtil.update(list, new Parameter("p2", "v2"));
		ParameterUtil.update(list, new Parameter("p1", "v11"));
		ParameterUtil.update(list, new Parameter("p2", "v22"));
		ParameterUtil.update(list, new Parameter("p3", "v3"));
		ParameterUtil.update(list, new Parameter("p3", "v33"));

		Assert.areEqual(3, list.length);
		Assert.areEqual(list[0].name, "p1");
		Assert.areEqual(list[0].value, "v11");
		Assert.areEqual(list[1].name, "p2");
		Assert.areEqual(list[1].value, "v22");
		Assert.areEqual(list[2].name, "p3");
		Assert.areEqual(list[2].value, "v33");
	}

	@Test
	public function customParams_urlEncode_escapes():Void
	{
		var list:Array<Parameter> = [new Parameter("p1", "a b"), new Parameter("p 2", "a=b")];
		var result = ParameterUtil.urlEncode(list);

		Assert.areEqual(result, "p1=a%20b&p%202=a%3Db");
	}
}