<cfcomponent extends="algid.inc.resource.base.event" output="false">
	<cffunction name="generate" access="public" returntype="void" output="false">
		<cfargument name="transport" type="struct" required="true" />
		<cfargument name="task" type="component" required="true" />
		<cfargument name="options" type="struct" required="true" />
		<cfargument name="report" type="component" required="true" />
		
		<cfset local.servAccount = getService(arguments.transport, 'account', 'account') />
		
		<cfset local.section = local.servAccount.getModel('admin', 'reportSection') />
		
		<cfset local.section.setTitle('Accounts') />
		<cfset local.section.setContent('Testing accounts!') />
		
		<cfif not local.section.isBlank()>
			<cfset report.addSections(local.section) />
		</cfif>
	</cffunction>
</cfcomponent>
