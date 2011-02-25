component extends="algid.inc.resource.plugin.configure" {
	public void function onSessionStart(required struct theApplication, required struct theSession) {
		// Add the user singleton
		local.temp = arguments.theApplication.factories.transient.getModAccountForAccount(arguments.theApplication.managers.singleton.getI18N());
		
		arguments.theSession.managers.singleton.setAccount(local.temp);
	}
}
