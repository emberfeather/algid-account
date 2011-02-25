<cfset servAccount = services.get('account', 'account') />

<!--- Retrieve the object --->
<cfset account = servAccount.getAccount( theURL.search('account') ) />

<cfif cgi.request_method eq 'post'>
	<!--- Process the form submission --->
	<cfset modelSerial.deserialize(form, account) />
	
	<cfset servAccount.setAccount( account ) />
	
	<!--- Redirect --->
	<cfset theURL.setRedirect('_base', '/admin/account/list') />
	<cfset theURL.removeRedirect('account') />
	
	<cfset theURL.redirectRedirect() />
</cfif>
