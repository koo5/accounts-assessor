
## current good version combinations 
(to be done)
```
currently shaping up:
	robust: 
		branch smsf_docker
	excel:
		...
	ic template 
	

```

## theory
```
:request l:templates_version "2".
```
```
_g.Assert(new Triple(u(":request"), u("l:client_version"), _g.CreateLiteralNode("2")));
```



https://news.ycombinator.com/item?id=26939929
	https://apisyouwonthate.com/blog/api-versioning-has-no-right-way



how to relate format changes to API versions. In short, they should be completely separate; formats can have lives of their own, and to get the most value out of them, they should do so. It’s fine to say “Version 2 of the API requires the foo resource to support version 5 of the bar format,” of course.

Tying this information up in a version number only makes the client go and look up a chart of version numbers to see whether the feature they want is supported by the given version; instead, if they can directly interrogate the interface to see if it supports the fancy new “ladder cover” feature (or whatever), it’s a lot more flexible and useful. The same goes for new resources, new formats, and so on.

Aside from that, using linear, numeric minor versions for negotiating new features is really, really limiting; complex APIs will find this especially impractical.
