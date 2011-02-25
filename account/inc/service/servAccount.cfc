component extends="algid.inc.resource.base.service" {
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
	
	public component function getAccount(required string userID) {
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
		
		// Expand the with defaults
		arguments.filter = extend({
			'orderBy': 'fullName',
			'search': ''
		}, arguments.filter);
		
		/**
		 * Query building
		 */
		local.query = {};
		
		// Search
		if (arguments.filter.search neq '') {
			local.query['$or'] = [
				{ 'username': collection.regex(arguments.filter.search, 'i') },
				{ 'fullName': collection.regex(arguments.filter.search, 'i') },
				{ 'email': collection.regex(arguments.filter.search, 'i') }
			];
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
		
		// In ID
		if (structKeyExists(arguments.filter, 'in_id')) {
			local.query['_id'] = { '$in': arguments.filter.in_id };
		}
		
		// Sorting
		local.sort = {};
		
		switch (arguments.filter.orderBy) {
			defaultcase: {
				local.sort['account'] = 1;
			}
		}
		
		return collection.find( local.query ).sort(local.sort);
	}
	
	public void function setAccount(required component account) {
		local.observer = getPluginObserver('account', 'account');
		local.collection = variables.db.getCollection( 'account.account' );
		
		local.modelSerial = variables.transport.theApplication.factories.transient.getModelSerial(variables.transport);
		
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
