component extends="plugins.widget.inc.resource.base.widget" {
	public component function init(required struct transport, required string path) {
		super.init(arguments.transport, arguments.path);
		
		variables.servAccount = getService('account', 'account');
		variables.viewAccount = getView('account', 'account');
		
		preventCaching();
		
		return this;
	}
	
	public string function process( required string content, required struct args ) {
		local.account = variables.transport.theSession.managers.singleton.getAccount();
		
		return variables.viewAccount.profile(local.account);
	}
}
