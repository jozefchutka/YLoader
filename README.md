YLoader provides a per platform http loader class.

# Example

```haxe
import yloader.impl.js.XMLHttpRequestLoader;
import yloader.valueObject.Parameter;
import yloader.valueObject.Request;
import yloader.valueObject.Response;

var request = new Request("http://domain.com/service");
request.setHeader(new Parameter("header1", "value1"));
request.setGetParameter(new Parameter("param1", "value1"));

var loader = new XMLHttpRequestLoader(request); // or use Loader.create()
loader.onResponse = onResponse;
loader.load();

function onResponse(response:Response)
{
	if(response.success)
		trace("Response received " + response.data);
	else
		trace("Request failed");
}
```

## Loading Bytes

```haxe
import haxe.io.Bytes;
import js.html.XMLHttpRequestResponseType;

var loader = Loader.create(request);
loader.onResponse = onResponse
loader.load();
cast(loader, XMLHttpRequestLoader).xhr.responseType = XMLHttpRequestResponseType.ARRAYBUFFER;

function onResponse(response:Response)
{
	var bytes = Bytes.ofData(response.data);
}
```

# Release

```
haxelib run yhaxen release -version 0.0.5 -message "Changes..."
```

# Install

Recommended installation from haxelib:

```
haxelib install yloader
```
