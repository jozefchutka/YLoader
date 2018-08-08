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


## Compilation

YLoader contains multiple platform specific implementations. [NodeLoader](src/main/haxe/yloader/impl/js/NodeLoader.hx) requires [hxnodejs](https://lib.haxe.org/p/hxnodejs/) dependency which is part of haxelib.json and contains build macro to add extra line into the output.js file (`if (process.version < "v4.0.0") console.warn("Module " + (typeof(module) == "undefined" ? "" : module.filename) + " requires node.js version 4.0.0 or higher");`). To avoid this , either use YLoader as `-cp` flag or turn of the macro by `-lib yloader -D hxnodejs_no_version_warning`: 

```
haxe -main Main -js main.js -lib yloader -D hxnodejs_no_version_warning
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
