component extends="algid.inc.resource.base.event" {
	public void function beforeSave(required struct transport, required component account) {
		if(account.getPassword() != '') {
			// Validate the password confirmation matches
			if(account.getPassword() != account.getPasswordConfirm()) {
				throw('validation', 'Password confirmation did not match', 'The password confirmation did not match the password.');
			}
			
			// TODO Validate password strength against the password settings
			
			// Hash the new password
			local.bcrypt = arguments.transport.theApplication.managers.singleton.getBCrypt();
			
			arguments.account.setPasswordHash( local.bcrypt.hashpw(arguments.account.getPassword(), local.bcrypt.gensalt()) );
		}
		
		// Clear the plain text passwords
		arguments.account.setPassword('');
		arguments.account.setPasswordConfirm('');
	}
	
	public void function afterCreate( required struct transport, required component account ) {
		local.eventLog = arguments.transport.theApplication.managers.singleton.getEventLog();
		
		// TODO use i18n
		local.eventLog.logEvent('account', 'accountCreate', 'Created the account for ''' & arguments.account.getDisplayName() & '''.', arguments.transport.theSession.managers.singleton.getUser().getUserID(), arguments.account.get_ID());
		
		// Add success message
		arguments.transport.theSession.managers.singleton.getSuccess().addMessages('The ''' & arguments.account.getDisplayName() & ''' account was successfully created.');
	}
	
	public void function afterUpdate( required struct transport, required component account ) {
		local.eventLog = arguments.transport.theApplication.managers.singleton.getEventLog();
		
		// TODO use i18n
		local.eventLog.logEvent('account', 'accountUpdate', 'Updated the account for ''' & arguments.account.getDisplayName() & '''.', arguments.transport.theSession.managers.singleton.getUser().getUserID(), arguments.account.get_ID());
		
		// Add success message
		arguments.transport.theSession.managers.singleton.getSuccess().addMessages('The ''' & arguments.account.getDisplayName() & ''' account was successfully updated.');
	}
}
