component extends="plugins.mongodb.inc.resource.base.model" {
	public component function init(required component i18n, string locale = 'en_US') {
		super.init(arguments.i18n, arguments.locale);
		
		// Set the bundle information for translation
		add__bundle('plugins/account/i18n/inc/model', 'modAccount');
		
		// Account ID
		add__attribute(
			attribute = '_id'
		);
		
		// Email
		add__attribute(
			attribute = 'email',
			validation = {
				notEmpty: true,
				validEmail = true
			}
		);
		
		// Full Name
		add__attribute(
			attribute = 'fullName',
			defaultValue = 'Guest',
			validation = {
				minLength: 2,
				notEmpty: true
			}
		);
		
		// Is Diety User?
		add__attribute(
			attribute = 'isDeity',
			defaultValue = false,
			validation = {
				isBoolean: true
			}
		);
		
		// Language
		add__attribute(
			attribute = 'language',
			defaultValue = 'en-US'
		);
		
		// Password
		add__attribute(
			attribute = 'password'
		);
		
		// Password Confirmation
		add__attribute(
			attribute = 'passwordConfirm'
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
		
		// Settings
		add__attribute(
			attribute = 'settings',
			defaultValue = {}
		);
		
		// Username
		add__attribute(
			attribute = 'username',
			validation = {
				minLength: 2,
				noWhitespace: true,
				notEmpty: true,
				notIn: 'admin, administrator, anonymous, guest, moderator, nobody, owner, root, test, user'
			}
		);
		
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
	
	public string function getGravatar(numeric size = 80, string default = 'identicon') {
		local.img = 'http://www.gravatar.com/avatar/' & lcase(hash(lcase(this.getEmail()), 'md5')) & '?s=' & arguments.size & '&d=' & arguments.default & '&r=g';
		
		return '<img src="' & local.img & '" title="' & this.getUsername() & '" />';
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
	
	public any function getSetting(required string key) {
		if(not structKeyExists(variables.instance.settings, arguments.key)) {
			return '';
		}
		
		return variables.instance['settings'][arguments.key];
	}
	
	public struct function getSettings(string regex = '') {
		local.results = {};
		
		if(len(arguments.regex)) {
			local.keys = listToArray(structKeyList(variables.instance['settings']));
			
			for( local.i = 1; local.i <= arrayLen(local.keys); local.i++ ) {
				if(reFindNoCase(arguments.regex, local.keys[local.i])) {
					local.results[local.keys[local.i]] = variables.instance['settings'][local.keys[local.i]];
				}
			}
			
			return local.results;
		}
		
		return variables.instance['settings'];
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
	
	public void function setSetting(required string setting, required any value) {
		variables.instance['settings'][arguments.setting] = arguments.value;
	}
	
	public void function setSettings(required struct settings) {
		local.keys = listToArray(structKeyList(arguments.settings));
		
		for( local.i = 1; local.i <= arrayLen(local.keys); local.i++ ) {
			variables.instance['settings'][local.keys[local.i]] = arguments.settings[local.keys[local.i]]
		}
	}
}
