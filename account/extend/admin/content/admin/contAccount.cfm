<cfset viewAccount = views.get('account', 'account') />

<cfoutput>
	#viewAccount.overview( account )#
</cfoutput>
