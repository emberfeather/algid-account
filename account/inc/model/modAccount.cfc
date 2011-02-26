component extends="plugins.mongodb.inc.resource.base.model" {
	public component function init(required component i18n, string locale = 'en_US') {
		super.init(arguments.i18n, arguments.locale);
		
		// Account ID
		add__attribute(
			attribute = '_id'
		);
		
		// Email
		add__attribute(
			attribute = 'email',
			form = {
				elementType: 'email',
				options: {
					required: true
				}
			}
		);
		
		// Full Name
		add__attribute(
			attribute = 'fullName',
			defaultValue = 'Guest',
			form = {
				elementType: 'text',
				options: {
					required: true
				}
			}
		);
		
		// Is Diety User?
		add__attribute(
			attribute = 'isDeity',
			defaultValue = false,
			form = {
				elementType: 'checkbox',
				options: {}
			}
		);
		
		// Language
		add__attribute(
			attribute = 'language',
			defaultValue = 'en-US'
		);
		
		// Password
		add__attribute(
			attribute = 'password',
			form = {
				elementType: 'password',
				options: {
					required: true
				},
				confirm: true
			}
		);
		
		// Password Hash
		add__attribute(
			attribute = 'passwordHash'
		);
		
		// Permissions
		add__attribute(
			attribute = 'permissions',
			defaultValue = {}
		);
		
		// Username
		add__attribute(
			attribute = 'username',
			form = {
				elementType: 'text',
				options: {
					required: true
				}
			}
		);
		
		// Set the bundle information for translation
		add__bundle('plugins/account/i18n/inc/model', 'modAccount');
		
		return this;
	}
	
	public void function addPermissions(required string scheme, required any permissions) {
		if( !isArray(arguments.permissions) ) {
			arguments.permissions = [ arguments.permissions ];
		}
		
		if (not structKeyExists(variables.instance['permissions'], arguments.scheme)) {
			variables.instance['permissions'][arguments.scheme] = [];
		}
		
		for( local.i = 1; local.i <= arrayLen(arguments.permissions); local.i++ ) {
			arrayAppend(variables.instance['permissions'][arguments.scheme], arguments.permissions[local.i]);
		}
	}
	
	public string function getDisplayName() {
		return this.getFullName();
	}
	
	public array function getPermissions(required any schemes) {
		local.permissions = [];
		
		if( !isArray(arguments.schemes) ) {
			// If wildcard, return them all
			if (arguments.schemes eq '*') {
				arguments.schemes = listToArray(structKeyList(variables.instance['permissions']));
			} else {
				arguments.schemes = [ arguments.schemes ];
			}
		}
		
		// Find all the permissions for each of the desired schemes
		for( local.i = 1; local.i <= arrayLen(arguments.schemes); local.i++ ) {
			local.scheme = arguments.schemes[i];
			
			if (structKeyExists(variables.instance['permissions'], local.scheme)) {
				for( local.j = 1; local.j <=  arrayLen(variables.instance['permissions'][local.scheme]); local.j++ ) {
					local.permission = variables.instance['permissions'][local.scheme][local.j];
					
					// Prevent duplicate permissions
					if (not arrayFind(permissions, local.permission)) {
						arrayAppend(permissions, local.permission);
					}
				}
			}
		}
		
		return permissions;
	}
	
	public boolean function hasPermission(required string permission, required any schemes) {
		// Check for master users
		if (this.getIsDeity() eq true) {
			return true;
		}
		
		if( !isArray(arguments.schemes) ) {
			arguments.schemes = [ arguments.schemes ];
		}
		
		for( local.i = 1; local.i <= arrayLen(arguments.schemes); local.i++ ) {
			local.scheme = arguments.schemes[i];
			
			if (structKeyExists(variables.instance['permissions'], scheme) and arrayFind(variables.instance['permissions'][scheme], arguments.permission)) {
				return true;
			}
		}
		
		return false;
	}
	
	public boolean function hasPermissions( required any permissions, required any schemes ) {
		// Check for master users
		if (this.getIsDeity() eq true) {
			return true;
		}
		
		if( !isArray(arguments.permissions) ) {
			arguments.permissions = [ arguments.permissions ];
		}
		
		for( local.i = 1; local.i <= arrayLen(arguments.permissions); local.i++ ) {
			local.permission = arguments.permissions[i];
			
			if (not hasPermission(permission, arguments.schemes)) {
				return false;
			}
		}
		
		return true;
	}
	
	public boolean function isLoggedIn() {
		return this.get_ID() neq '';
	}
}
