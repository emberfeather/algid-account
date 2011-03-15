<!--- Redirect to the list page if no account chosen --->
<cfif theUrl.search('account') eq ''>
	<cfset theURL.setRedirect('_base', '/admin/account/list') />
	<cfset theURL.redirectRedirect() />
</cfif>

<cfset servAccount = services.get('account', 'account') />

<!--- Retrieve the object --->
<cfset account = servAccount.getAccount( theURL.search('account') ) />

<!--- Add to the current levels --->
<cfset template.addLevel(account.getUsername(), account.getUsername(), theUrl.get(), 0, true) />
