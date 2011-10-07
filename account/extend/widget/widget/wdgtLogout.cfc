component extends="plugins.widget.inc.resource.base.widget" {
	public component function init(required struct transport, required string path) {
		super.init(arguments.transport, arguments.path);
		
		variables.servAccount = getService('account', 'account');
		variables.viewAccount = getView('account', 'account');
		
		preventCaching();
		
		return this;
	}
	
	public string function process( required string content, required struct args ) {
		// Get a blank guest account
		local.account = variables.servAccount.getModel('account', 'account');
		
		// Store the account
		variables.transport.theSession.managers.singleton.setAccount(local.account);
		
		// Redirect to homepage
		local.theUrl = variables.transport.theRequest.managers.singleton.getUrl();
		
		local.theUrl.cleanRedirect();
		local.theUrl.setRedirect('_base', '/');
		
		local.theUrl.redirectRedirect();
	}
}
