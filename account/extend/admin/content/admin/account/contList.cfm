<cfset accounts = servAccount.getAccounts( filter ) />

<cfset paginate = variables.transport.theApplication.factories.transient.getPaginate(accounts.count(), transport.theSession.numPerPage, theURL.searchID('onPage')) />

<cfoutput>#viewMaster.datagrid(transport, accounts, viewAccount, paginate, filter)#</cfoutput>
