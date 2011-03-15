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
			processRegister(argumentCollection = arguments);
		}
		
		local.account = variables.transport.theSession.managers.singleton.getAccount();
		
		return variables.viewAccount.register(local.account, variables.transport.theForm);
	}
	
	public void function processRegister( required string content, required struct args ) {
		try {
			// Use the current account and just override the portions so session settings are saved
			local.account = variables.transport.theSession.managers.singleton.getAccount();
			
			if(local.account.isLoggedIn()) {
				throw('validation', 'Please logout before attempting to register.', 'Already logged in to an account and cannot register while logged in.');
			}
			
			// Pull in the form submission
			local.account.setUsername(variables.transport.theForm.username);
			local.account.setFullName(variables.transport.theForm.fullName);
			local.account.setEmail(variables.transport.theForm.email);
			local.account.setPassword(variables.transport.theForm.password);
			local.account.setPasswordConfirm(variables.transport.theForm.passwordConfirm);
			
			variables.servAccount.setAccount(local.account);
			
			// Redirect
			local.theUrl = variables.transport.theRequest.managers.singleton.getUrl();
			
			local.theUrl.cleanRedirect();
			// TODO Determine the page base dynamically
			local.theUrl.setRedirect('_base', '/account');
			
			local.theUrl.redirectRedirect();
		} catch(validation e) {
			variables.transport.theSession.managers.singleton.getError().addMessages(e.message);
		}
	}
}
