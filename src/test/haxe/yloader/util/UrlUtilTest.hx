package yloader.util;

import massive.munit.Assert;

class UrlUtilTest
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
	public function customSimpleUrl_parse_matches():Void
	{
		var url = "https://github.com";
		var result = UrlUtil.parse(url);

		Assert.areEqual("https:", result.protocol);
		Assert.areEqual(null, result.username);
		Assert.areEqual(null, result.password);
		Assert.areEqual("github.com", result.host);
		Assert.areEqual("github.com", result.hostname);
		Assert.areEqual(null, result.port);
		Assert.areEqual("/", result.pathname);
		Assert.areEqual("/", result.path);
		Assert.areEqual("", result.search);
		Assert.areEqual(null, result.hash);
	}

	@Test
	public function customComplexUrl_parse_matches():Void
	{
		var url = "https://jozefchutka:pwd@www.github.com:80/jozefchutka/YLoader?a=b&c=d#myHash";
		var result = UrlUtil.parse(url);

		Assert.areEqual("https:", result.protocol);
		Assert.areEqual("jozefchutka", result.username);
		Assert.areEqual("pwd", result.password);
		Assert.areEqual("www.github.com:80", result.host);
		Assert.areEqual("www.github.com", result.hostname);
		Assert.areEqual("80", result.port);
		Assert.areEqual("/jozefchutka/YLoader", result.pathname);
		Assert.areEqual("/jozefchutka/YLoader?a=b&c=d", result.path);
		Assert.areEqual("?a=b&c=d", result.search);
		Assert.areEqual("#myHash", result.hash);
	}
}
