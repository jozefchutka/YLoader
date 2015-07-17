package yloader.impl.js;

import yloader.impl.js.XDomainRequestLoader;

import massive.munit.Assert;

class XDomainRequestLoaderTest
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
	public function isPreferred():Void
	{
		if(!XDomainRequestLoader.isAvailable)
		{
			trace("XDomainRequestLoader is only available in IE9, IE10");
			return;
		}
	
		Assert.areEqual(true, XDomainRequestLoader.isPreferred("http://abc.com"));
		Assert.areEqual(true, XDomainRequestLoader.isPreferred("https://abc.com"));
		Assert.areEqual(false, XDomainRequestLoader.isPreferred("test"));
		Assert.areEqual(false, XDomainRequestLoader.isPreferred(js.Browser.document.location.href));
	}
}