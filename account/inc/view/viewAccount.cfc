<cfcomponent extends="algid.inc.resource.base.view">
<cfscript>
	public string function datagrid(required any data, struct options) {
		var datagrid = '';
		var i18n = '';
		
		arguments.options.theURL = variables.transport.theRequest.managers.singleton.getURL();
		i18n = variables.transport.theApplication.managers.singleton.getI18N();
		datagrid = variables.transport.theApplication.factories.transient.getDatagrid(i18n, variables.transport.theSession.managers.singleton.getSession().getLocale());
		
		// Add the resource bundle for the view
		datagrid.addBundle('plugins/account/i18n/inc/view', 'viewAccount');
		datagrid.addBundle('plugins/account/i18n/inc/model', 'modAccount');
		
		datagrid.addColumn({
			key = 'username',
			label = 'username',
			link = {
				'_base' = '/admin/account',
				'account' = '_id'
			}
		});
		
		datagrid.addColumn({
			key = 'fullName',
			label = 'fullName',
			link = {
				'_base' = '/admin/account',
				'account' = '_id'
			}
		});
		
		datagrid.addColumn({
			class = 'phantom align-right',
			value = [ 'delete', 'edit' ],
			link = [
				{
					'account' = '_id',
					'_base' = '/admin/account/archive'
				},
				{
					'account' = '_id',
					'_base' = '/admin/account/edit'
				}
			],
			linkClass = [ 'delete', '' ]
		});
		
		// Filter to only show the desired rows
		local.results = arguments.data.skip(arguments.options.startRow - 1).limit(arguments.options.numPerPage);
		
		// Reset the options for the start row so that the datagrid doesn't get confused
		arguments.options.startRow = 1;
		
		return datagrid.toHTML( local.results.toArray(), arguments.options );
	}
	
	public string function edit(required component account, struct request) {
		var address = '';
		var i = '';
		var i18n = '';
		var theForm = '';
		var theURL = '';
		var question = '';
		var questions = '';
		
		i18n = variables.transport.theApplication.managers.singleton.getI18N();
		theURL = variables.transport.theRequest.managers.singleton.getUrl();
		theForm = variables.transport.theApplication.factories.transient.getFormStandard('account', i18n);
		
		// Add the resource bundle for the view
		theForm.addBundle('plugins/account/i18n/inc/view', 'viewAccount');
		theForm.addBundle('plugins/account/i18n/inc/model', 'modAccount');
		
		address = arguments.account.getAddress();
		
		theForm.addElement('text', {
			name = "username",
			label = "username",
			required = true,
			value = ( structKeyExists(arguments.request, 'username') ? arguments.request.username : arguments.account.getUsername() )
		});
		
		theForm.addElement('text', {
			name = "fullName",
			label = "fullName",
			required = true,
			value = ( structKeyExists(arguments.request, 'fullName') ? arguments.request.fullName : arguments.account.getFullName() )
		});
		
		theForm.addElement('password', {
			name = "password",
			label = "password",
			required = arguments.account.getPasswordHash() == '',
			value = ( structKeyExists(arguments.request, 'password') ? arguments.request.password : '' )
		});
		
		theForm.addElement('password', {
			name = "passwordConfirm",
			label = "passwordConfirm",
			required = arguments.account.getPasswordHash() == '',
			value = ( structKeyExists(arguments.request, 'password') ? arguments.request.password : '' )
		});
		
		return theForm.toHTML(theURL.get());
	}
	
	public string function filterActive(struct filter) {
		var filterActive = '';
		var options = '';
		var results = '';
		
		filterActive = variables.transport.theApplication.factories.transient.getFilterActive(variables.transport.theApplication.managers.singleton.getI18N());
		
		// Add the resource bundle for the view
		filterActive.addBundle('plugins/account/i18n/inc/view', 'viewAccount');
		
		return filterActive.toHTML(arguments.filter, variables.transport.theRequest.managers.singleton.getURL(), 'search');
	}
	
	public string function filter(struct values) {
		var filter = '';
		var options = '';
		var results = '';
		
		filter = variables.transport.theApplication.factories.transient.getFilterVertical(variables.transport.theApplication.managers.singleton.getI18N());
		
		// Add the resource bundle for the view
		filter.addBundle('plugins/account/i18n/inc/view', 'viewAccount');
		
		// Search
		filter.addFilter('search');
		
		return filter.toHTML(variables.transport.theRequest.managers.singleton.getURL(), arguments.values);
	}
	
	public string function overview(required component account) {
		local.html = '';
		
		return local.html;
	}
</cfscript>
</cfcomponent>
