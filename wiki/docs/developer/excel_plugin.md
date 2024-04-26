## C# plugin

release procedure:
	if you made incompatible changes, bump either client_version or templates_version or both. Bump the version in server too. Make sure DEBUG is off. PRIVATE_RELEASE maybe on. Keep in mind that when not running under debugger, when there are uncaught exceptions, excel will not tell you. Click build->publish, "to CD-ROM". In my setup, it synces automatically to the test windows machine.
