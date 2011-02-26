component extends="plugins.widget.inc.resource.base.widget" {
	public component function init(required struct transport) {
		super.init(arguments.transport);
		
		variables.servAccount = getService('account', 'account');
		variables.viewAccount = getView('account', 'account');
		
		preventCaching();
		
		return this;
	}
	
	public string function process( required string content, required struct args ) {
		try {
			if(variables.transport.theCgi.request_method == 'post') {
				processLogin(argumentCollection = arguments);
			}
		} catch(validation e) {
			variables.transport.theSession.managers.singleton.getError().addMessages(e.message);
		}
		
		return variables.viewAccount.login(variables.transport.theForm);
	}
	
	public void function processLogin( required string content, required struct args ) {
		// Attempt to login
		local.account = variables.servAccount.login(variables.transport.theForm.username, variables.transport.theForm.password);
		
		// Store the account
		variables.transport.theSession.managers.singleton.setAccount(local.account);
		
		// Redirect to homepage
		local.theUrl = variables.transport.theRequest.managers.singleton.getUrl();
		
		local.theUrl.cleanRedirect();
		local.theUrl.setRedirect('_base', '/');
		
		local.theUrl.redirectRedirect();
	}
}
