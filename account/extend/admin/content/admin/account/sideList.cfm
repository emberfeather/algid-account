<cfset viewAccount = views.get('account', 'account') />

<cfset filter = {
	'search' = theURL.search('search'),
	'isArchived' = false
} />

<cfoutput>
	#viewAccount.filter( filter )#
</cfoutput>
