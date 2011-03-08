component extends="algid.inc.resource.base.event" {
	public void function beforeSave(required struct transport, required component account) {
		local.servAccount = getService(arguments.transport, 'account', 'account');
		
		// Validate the submission
		if(arguments.account.get_id() eq '') {
			if(arguments.account.getPassword() == '') {
				throw(type = 'validation', message = 'Missing password', detail = 'The password is required.');
			}
		}
		
		// Make sure that the username is unique
		local.accounts = local.servAccount.getAccounts({ username: arguments.account.getUsername(), nin_id: [ arguments.account.get_id() ] });
		
		if(local.accounts.count() > 0) {
			throw(type = 'validation', message = 'Username already in use', detail = 'The username ''' & arguments.account.getUsername() & ''' is unavailable.');
		}
		
		// Make sure that the email is unique
		local.accounts = local.servAccount.getAccounts({ email: arguments.account.getEmail(), nin_id: [ arguments.account.get_id() ] });
		
		if(local.accounts.count() > 0) {
			throw(type = 'validation', message = 'Email already in use', detail = 'The email ''' & arguments.account.getEmail() & ''' is already being used.');
		}
		
		if(arguments.account.getPassword() != '') {
			// Validate the password confirmation matches
			if(arguments.account.getPassword() != arguments.account.getPasswordConfirm()) {
				throw(type = 'validation', message = 'Password confirmation did not match', 'The password confirmation did not match the password.');
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
		local.eventLog.logEvent('account', 'accountCreate', detail = 'Created the account for ''' & arguments.account.getDisplayName() & '''.', arguments.transport.theSession.managers.singleton.getUser().getUserID(), arguments.account.get_ID());
		
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
