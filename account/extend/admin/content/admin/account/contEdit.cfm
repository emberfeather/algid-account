<cfset viewAccount = views.get('account', 'account') />

<cfoutput>
	#viewAccount.edit(account, form)#
</cfoutput>
