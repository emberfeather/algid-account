component extends="algid.inc.resource.base.event" {
	public void function generate(required struct transport, required component task, required struct options, required component report) {
		local.servAccount = getService(arguments.transport, 'account', 'account');
		
		local.recentlyCreated = local.servAccount.getAccounts({ createdAfter: dateAdd('s', -1 * arguments.task.getInterval(), now()) });
		local.recentlyLoggedIn = local.servAccount.getAccounts({ loginAfter: dateAdd('s', -1 * arguments.task.getInterval(), now()) });
		
		// Only need more if there are accounts to report on
		if (local.recentlyCreated.count() or local.recentlyLoggedIn.count()) {
			local.viewAccount = getView(arguments.transport, 'account', 'account');
			
			local.section = local.servAccount.getModel('admin', 'reportSection');
			
			local.section.setTitle('Accounts');
			local.section.setContent(local.viewAccount.reportAccounts(local.recentlyCreated, local.recentlyLoggedIn));
			
			report.addSections(local.section);
		}
	}
}
