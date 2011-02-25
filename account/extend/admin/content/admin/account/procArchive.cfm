<cfset servAccount = services.get('account', 'account') />

<cfif theUrl.search('account') neq ''>
	<!--- Retrieve the object --->
	<cfset account = servAccount.getAccount( theURL.search('account') ) />
	
	<cfset servAccount.archiveAccount( account ) />
	
	<!--- Redirect --->
	<cfset theURL.setRedirect('_base', '/admin/account/list') />
	<cfset theURL.removeRedirect('account') />
	
	<cfset theURL.redirectRedirect() />
</cfif>

<!--- Add a error message --->
<cfset transport.theSession.managers.singleton.getError().addMessages('No account was given to be archived.') />

<!--- Redirect --->
<cfset theURL.setRedirect('_base', '/admin/account/list') />
<cfset theURL.redirectRedirect() />
