component extends="plugins.widget.inc.resource.base.widget" {
	public component function init(required struct transport) {
		super.init(arguments.transport);
		
		variables.servAccount = getService('account', 'account');
		variables.viewAccount = getView('account', 'account');
		
		preventCaching();
		
		return this;
	}
	
	public string function process( required string content, required struct args ) {
		if(variables.transport.theCgi.request_method == 'post') {
			processSettings(argumentCollection = arguments);
		}
		
		local.account = variables.transport.theSession.managers.singleton.getAccount();
		
		return variables.viewAccount.settings(local.account, variables.transport.theForm);
	}
	
	public void function processSettings( required string content, required struct args ) {
		try {
			local.account = variables.transport.theSession.managers.singleton.getAccount();
			
			if(!local.account.isLoggedIn()) {
				throw('validation', 'Only users that are logged in can edit their settings');
			}
			
			// Pull in the form submission
			local.account.setFullName(variables.transport.theForm.fullName);
			local.account.setEmail(variables.transport.theForm.email);
			local.account.setPassword(variables.transport.theForm.password);
			local.account.setPasswordConfirm(variables.transport.theForm.passwordConfirm);
			
			variables.servAccount.setAccount(local.account);
			
			// Redirect
			local.theUrl = variables.transport.theRequest.managers.singleton.getUrl();
			
			local.theUrl.cleanRedirect();
			// TODO Determine the page base dynamically
			local.theUrl.setRedirect('_base', '/account/settings');
			
			local.theUrl.redirectRedirect();
		} catch(validation e) {
			variables.transport.theSession.managers.singleton.getError().addMessages(e.message);
		}
	}
}
