component extends="plugins.mongodb.inc.resource.base.service" {
	public void function archiveAccount(required component account) {
		local.observer = getPluginObserver('account', 'account');
		local.collection = variables.db.getCollection( 'account.account' );
		
		// Before Archive Event
		observer.beforeArchive(variables.transport, arguments.account);
		
		// Archive the account
		collection.update({ '_id': arguments.account.get_ID() }, { '$set': { 'archivedOn': now() } });
		
		// After Archive Event
		observer.afterArchive(variables.transport, arguments.account);
	}
	
	public component function getAccount(required string accountID) {
		local.account = getModel('account', 'account');
		
		if (arguments.accountID neq '') {
			local.collection = variables.db.getCollection( 'account.account' );
			
			// Retrieve School
			local.result = local.collection.findOne({ '_id': arguments.accountID });
			
			if (not structIsEmpty(local.result)) {
				local.modelSerial = variables.transport.theApplication.factories.transient.getModelSerial(variables.transport);
				
				local.modelSerial.deserialize(local.result, local.account, true, true);
			}
		}
		
		return local.account;
	}
	
	public component function getAccounts(struct filter = {}) {
		local.collection = variables.db.getCollection( 'account.account' );
		local.utility = variables.transport.theApplication.managers.singleton.getMongoUtility();
		
		// Expand the with defaults
		arguments.filter = extend({
			'orderBy': 'username',
			'search': ''
		}, arguments.filter);
		
		/**
		 * Query building
		 */
		local.query = {};
		
		// Search
		if (arguments.filter.search neq '') {
			local.query['$or'] = [
				{ 'username': local.utility.regex( local.utility.reEscape(arguments.filter.search), 'i') },
				{ 'fullName': local.utility.regex( local.utility.reEscape(arguments.filter.search), 'i') },
				{ 'email': local.utility.regex( local.utility.reEscape(arguments.filter.search), 'i') }
			];
		}
		
		// Email exact case-insensitive match
		if (structKeyExists(arguments.filter, 'email')) {
			local.query['email'] = local.utility.regex( '^' & local.utility.reEscape(arguments.filter.email) & '$', 'i');
		}
		
		// Username exact case-insensitive match
		if (structKeyExists(arguments.filter, 'username')) {
			local.query['username'] = local.utility.regex( '^' & local.utility.reEscape(arguments.filter.username) & '$', 'i');
		}
		
		// Is Archived?
		if (structKeyExists(arguments.filter, 'isArchived')) {
			if (arguments.filter.isArchived) {
				local.query['archivedOn'] = { '$exists': true };
			} else {
				local.query['archivedOn'] = { '$exists': false };
			}
		}
		
		// Is Diety?
		if (structKeyExists(arguments.filter, 'isDiety')) {
			if (arguments.filter.isDiety) {
				local.query['isDiety'] = true;
			} else {
				local.query['isDiety'] = false;
			}
		}
		
		// Not in ID
		if (structKeyExists(arguments.filter, 'nin_id')) {
			local.query['_id'] = { '$nin': arguments.filter.nin_id };
		}
		
		// In ID
		if (structKeyExists(arguments.filter, 'in_id')) {
			local.query['_id'] = { '$in': arguments.filter.in_id };
		}
		
		// Created After
		if (structKeyExists(arguments.filter, 'createdAfter')) {
			local.query['createdOn'] = { '$gte': arguments.filter.createdAfter };
		}
		
		// Created Before
		if (structKeyExists(arguments.filter, 'createdBefore')) {
			local.query['createdOn'] = { '$lte': arguments.filter.createdBefore };
		}
		
		// Logged In After
		if (structKeyExists(arguments.filter, 'loginAfter')) {
			local.query['loginOn'] = { '$gte': arguments.filter.loginAfter };
		}
		
		// Logged In Before
		if (structKeyExists(arguments.filter, 'loginBefore')) {
			local.query['loginOn'] = { '$lte': arguments.filter.loginBefore };
		}
		
		// Sorting
		local.sort = {};
		
		switch (arguments.filter.orderBy) {
		case 'fullName':
			local.sort['fullName'] = 1;
			
			break;
		default:
			local.sort['username'] = 1;
			
			break;
		}
		
		return collection.find( local.query ).sort(local.sort);
	}
	
	public component function login(required string username, required string password) {
		local.observer = getPluginObserver('account', 'account');
		local.collection = variables.db.getCollection( 'account.account' );
		
		// Find a matching account
		local.query = {
			'username': arguments.username
		};
		
		local.results = local.collection.find(local.query, { 'username': 1, 'passwordHash': 1 });
		
		if(local.results.count() == 1) {
			local.bcrypt = variables.transport.theApplication.managers.singleton.getBCrypt();
			local.account = local.results.next();
			
			// Check for failed password
			if(!local.bcrypt.checkpw(arguments.password, local.account.passwordHash)) {
				throw('Username or password incorrect', 'validation', 'The username or password did not match');
			}
			
			local.account = getAccount(local.account._id);
			
			// Update the last login
			local.account.setLoginOn(now());
			
			collection.update({ '_id': local.account.get_ID() }, { '$set': { 'loginOn': local.account.getLoginOn() }});
			
			local.observer.afterLogin(variables.transport, local.account);
			
			return local.account;
		} else {
			throw('Username or password incorrect', 'validation', 'The username or password did not match');
		}
	}
	
	public void function setAccount(required component account) {
		local.observer = getPluginObserver('account', 'account');
		local.collection = variables.db.getCollection( 'account.account' );
		
		local.modelSerial = variables.transport.theApplication.factories.transient.getModelSerial(variables.transport);
		
		scrub__model(arguments.account);
		validate__model(arguments.account);
		
		// Before Save Event
		local.observer.beforeSave(variables.transport, arguments.account);
		
		if (arguments.account.get_ID() neq '') {
			// Before Update Event
			observer.beforeUpdate(variables.transport, arguments.account);
			
			// Update existing account
			collection.save(modelSerial.serialize(arguments.account, 'struct'));
			
			// After Update Event
			observer.afterUpdate(variables.transport, arguments.account);
		} else {
			// Before Create Event
			observer.beforeCreate(variables.transport, arguments.account);
			
			// Insert as a new record
			collection.save(modelSerial.serialize(arguments.account, 'struct'));
			
			// After Create Event
			observer.afterCreate(variables.transport, arguments.account);
		}
		
		// After Save Event
		observer.afterSave(variables.transport, arguments.account);
	}
}
