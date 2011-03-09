component extends="algid.inc.resource.base.modelTest" {
	public void function setup() {
		super.setup();
		
		variables.account = createObject('component', 'plugins.account.inc.model.modAccount').init(variables.i18n);
	}
	
	public void function testGetPermissions() {
		variables.account.addPermissions('scheme', 'take');
		variables.account.addPermissions('scheme', 'give');
		
		assertEquals('give,take', listSort(arrayToList(variables.account.getPermissions('scheme')), 'text'));
	}
	
	public void function testGetPermissionsWithMultiScheme() {
		variables.account.addPermissions('scheme', 'take');
		variables.account.addPermissions('plan', 'give');
		
		assertEquals('give,take', listSort(arrayToList(variables.account.getPermissions(['scheme', 'plan'])), 'text'));
	}
	
	public void function testGetPermissionsWithMultiSchemeDuplicates() {
		variables.account.addPermissions('scheme', 'take');
		variables.account.addPermissions('plan', 'give');
		variables.account.addPermissions('plan', 'take');
		
		assertEquals('give,take', listSort(arrayToList(variables.account.getPermissions(['scheme', 'plan'])), 'text'));
	}
	
	public void function testGetPermissionsWithMultiSchemeWildcard() {
		variables.account.addPermissions('scheme', 'take');
		variables.account.addPermissions('plan', 'give');
		variables.account.addPermissions('devise', 'plunder');
		
		assertEquals('give,plunder,take', listSort(arrayToList(variables.account.getPermissions('*')), 'text'));
	}
	
	public void function testGetSettingWithoutSetting() {
		assertEquals('', variables.account.getSetting('hobbit'));
	}
	
	public void function testGetSettingsWithWildcard() {
		variables.account.setSettings({
			'bread.top': 'wheat',
			'topping.top': 'peanut butter',
			'topping.bottom': 'raspberry jelly',
			'bread.bottom': 'rye'
		});
		
		local.results = variables.account.getSettings('^topping.*');
		
		assertEquals('topping.bottom,topping.top', listSort(structKeyList(local.results), 'text'));
		assertEquals('peanut butter', local.results['topping.top']);
		assertEquals('raspberry jelly', local.results['topping.bottom']);
	}
	
	public void function testHasPermission() {
		variables.account.addPermissions('scheme', 'give');
		
		assertTrue(variables.account.hasPermission('give', 'scheme'), 'The permission should exist for the scheme.');
	}
	
	public void function testHasPermissionSansPermission() {
		assertFalse(variables.account.hasPermission('give', 'scheme'), 'The permission should not exist for the scheme');
	}
	
	public void function testHasPermissionWithMultiScheme() {
		variables.account.addPermissions('scheme', 'take');
		variables.account.addPermissions('plan', 'give');
		
		assertTrue(variables.account.hasPermission('give', ['scheme', 'plan']), 'The permission should exist in one of the scheme.');
	}
	
	public void function testHasPermissionsWithOneScheme() {
		variables.account.addPermissions('scheme', ['give', 'grant']);
		
		assertTrue(variables.account.hasPermissions(['give', 'grant'], 'scheme'), 'The permissions should exist for the scheme.');
	}
	
	public void function testHasPermissionsWithOneSchemeFailMissingPermission() {
		variables.account.addPermissions('scheme', 'give');
		
		assertFalse(variables.account.hasPermissions(['give', 'steal'], 'scheme'), 'The permissions do not exist in their entirety.');
	}
	
	public void function testHasPermissionsWithMultiSchemeParts() {
		variables.account.addPermissions('scheme', 'give');
		variables.account.addPermissions('plan', 'grant');
		
		assertTrue(variables.account.hasPermissions(['give', 'grant'], ['scheme', 'plan']), 'The permissions should exist for the scheme.');
	}
	
	public void function testHasPermissionsWithMultiSchemeFailMissingPermission() {
		variables.account.addPermissions('scheme', 'give');
		variables.account.addPermissions('plan', 'steal');
		
		assertFalse(variables.account.hasPermissions(['give', 'steal'], 'scheme'), 'The permissions do not exist in their entirety.');
	}
	
	public void function testSetSetting() {
		variables.account.setSetting('setting', 'value');
		
		assertEquals('setting', listSort(structKeyList(variables.account.getSettings()), 'text'));
		assertEquals('value', variables.account.getSetting('setting'));
	}
	
	public void function testSetSettings() {
		variables.account.setSettings({
			'peanut': 'butter',
			'raspberry': 'jelly'
		});
		
		assertEquals('peanut,raspberry', listSort(structKeyList(variables.account.getSettings()), 'text'));
		assertEquals('butter', variables.account.getSetting('peanut'));
		assertEquals('jelly', variables.account.getSetting('raspberry'));
	}
}
