<cfcomponent extends='algid.inc.resource.base.view'>
<cfscript>
	public string function datagrid(required any data, struct options = {}) {
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
	
	public string function edit(required component account, struct request = {}) {
		var address = '';
		var i = '';
		var i18n = '';
		var theForm = '';
		var theURL = '';
		var question = '';
		var questions = '';
		
		i18n = variables.transport.theApplication.managers.singleton.getI18N();
		theURL = variables.transport.theRequest.managers.singleton.getUrl();
		theForm = variables.transport.theApplication.factories.transient.getForm('account', i18n);
		
		// Add the resource bundle for the view
		theForm.addBundle('plugins/account/i18n/inc/view', 'viewAccount');
		theForm.addBundle('plugins/account/i18n/inc/model', 'modAccount');
		
		theForm.addElement('text', {
			name = 'username',
			label = 'username',
			required = true,
			value = ( structKeyExists(arguments.request, 'username') ? arguments.request.username : arguments.account.getUsername() )
		});
		
		theForm.addElement('text', {
			name = 'fullName',
			label = 'fullName',
			required = true,
			value = ( structKeyExists(arguments.request, 'fullName') ? arguments.request.fullName : arguments.account.getFullName() )
		});
		
		theForm.addElement('email', {
			name = 'email',
			label = 'email',
			required = true,
			value = ( structKeyExists(arguments.request, 'email') ? arguments.request.email : arguments.account.getEmail() )
		});
		
		theForm.addElement('password', {
			name = 'password',
			label = 'password',
			required = arguments.account.getPasswordHash() == '',
			value = ( structKeyExists(arguments.request, 'password') ? arguments.request.password : '' )
		});
		
		theForm.addElement('password', {
			name = 'passwordConfirm',
			label = 'passwordConfirm',
			required = arguments.account.getPasswordHash() == '',
			value = ( structKeyExists(arguments.request, 'passwordConfirm') ? arguments.request.passwordConfirm : '' )
		});
		
		return theForm.toHTML(theURL.get());
	}
	
	public string function filterActive(struct filter = {}) {
		var filterActive = '';
		var options = '';
		var results = '';
		
		filterActive = variables.transport.theApplication.factories.transient.getFilterActive(variables.transport.theApplication.managers.singleton.getI18N());
		
		// Add the resource bundle for the view
		filterActive.addBundle('plugins/account/i18n/inc/view', 'viewAccount');
		
		return filterActive.toHTML(arguments.filter, variables.transport.theRequest.managers.singleton.getURL(), 'search');
	}
	
	public string function filter(struct values = {}) {
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
	
	public string function login(struct request = {}) {
		var address = '';
		var i = '';
		var i18n = '';
		var theForm = '';
		var theURL = '';
		var question = '';
		var questions = '';
		
		i18n = variables.transport.theApplication.managers.singleton.getI18N();
		theURL = variables.transport.theRequest.managers.singleton.getUrl();
		theForm = variables.transport.theApplication.factories.transient.getForm('accountLogin', i18n);
		
		// Add the resource bundle for the view
		theForm.addBundle('plugins/account/i18n/inc/view', 'viewAccount');
		theForm.addBundle('plugins/account/i18n/inc/model', 'modAccount');
		
		theForm.addElement('text', {
			name = 'username',
			label = 'username',
			required = true,
			value = ( structKeyExists(arguments.request, 'username') ? arguments.request.username : '' )
		});
		
		theForm.addElement('password', {
			name = 'password',
			label = 'password',
			required = true,
			value = ( structKeyExists(arguments.request, 'password') ? arguments.request.password : '' )
		});
		
		return theForm.toHTML(theURL.get());
	}
	
	public string function overview(required component account) {
		local.html = '';
		
		return local.html;
	}
	
	public string function profile(required component account) {
		saveContent variable='local.html' {
			writeOutput('<div class="image-right">' & arguments.account.getGravatar(110, 'retro') & '</div>');
			
			writeOutput('<h3>' & arguments.account.getFullName() & '</h3>');
			
			writeOutput('<dl>');
			
			writeOutput('<dt>Email</dt>');
			writeOutput('<dd>' & arguments.account.getEmail() & '</dd>');
			
			writeOutput('</dl>');
		}
		
		return local.html;
	}
	
	public string function register(required component account, required struct recaptcha) {
		// TODO Make this better
		if(arguments.account.isLoggedIn()) {
			return 'Please logout to register for an account.';
		}
		
		local.i18n = variables.transport.theApplication.managers.singleton.getI18N();
		local.theURL = variables.transport.theRequest.managers.singleton.getUrl();
		local.theForm = variables.transport.theApplication.factories.transient.getForm('account', local.i18n);
		
		// Add the resource bundle for the view
		local.theForm.addBundle('plugins/account/i18n/inc/view', 'viewAccount');
		local.theForm.addBundle('plugins/account/i18n/inc/model', 'modAccount');
		
		local.error = '';
		
		if(arguments.account.hasError()) {
			local.error = arguments.account.getError();
			
			arguments.account.unsetError();
		}
		
		local.theForm.addElement('text', {
			name = 'username',
			label = 'username',
			required = true,
			value = arguments.account.getUsername()
		});
		
		local.theForm.addElement('text', {
			name = 'fullName',
			label = 'fullName',
			required = true,
			value = arguments.account.getFullName() != 'guest' ? arguments.account.getFullName() : ''
		});
		
		local.theForm.addElement('email', {
			name = 'email',
			label = 'email',
			required = true,
			value = arguments.account.getEmail()
		});
		
		local.theForm.addElement('password', {
			name = 'password',
			label = 'password',
			required = arguments.account.getPasswordHash() == '',
			value = ''
		});
		
		local.theForm.addElement('password', {
			name = 'passwordConfirm',
			label = 'passwordConfirm',
			required = arguments.account.getPasswordHash() == '',
			value = ''
		});
		
		local.theForm.addElement('recaptcha', {
			name = 'recaptcha',
			label = 'recaptcha',
			required = true,
			value = arguments.recaptcha.public,
			error = local.error,
			theme = 'white'
		});
		
		return local.theForm.toHTML(theURL.get());
	}
	
	public string function reportAccounts(required component recentlyCreated, required component recentlyLoggedIn) {
		local.html = '<dl>';
		
		local.html &= '<dt>Accounts created</dt>';
		local.html &= '<dd>' & arguments.recentlyCreated.count() & '</dd>';
		
		local.html &= '<dt>Accounts logged in</dt>';
		local.html &= '<dd>' & arguments.recentlyLoggedIn.count() & '</dd>';
		
		local.html &= '</dl>';
		
		return local.html;
	}
	
	public string function settings(required component account, struct request = {}) {
		// TODO Make this better
		if(!arguments.account.isLoggedIn()) {
			return 'Please login to edit account settings.';
		}
		
		local.i18n = variables.transport.theApplication.managers.singleton.getI18N();
		local.theURL = variables.transport.theRequest.managers.singleton.getUrl();
		local.theForm = variables.transport.theApplication.factories.transient.getForm('account', local.i18n);
		
		// Add the resource bundle for the view
		local.theForm.addBundle('plugins/account/i18n/inc/view', 'viewAccount');
		local.theForm.addBundle('plugins/account/i18n/inc/model', 'modAccount');
		
		local.theForm.addElement('text', {
			name = 'username',
			label = 'username',
			disabled = true,
			value = arguments.account.getUsername()
		});
		
		local.theForm.addElement('text', {
			name = 'fullName',
			label = 'fullName',
			required = true,
			value = ( structKeyExists(arguments.request, 'fullName') ? arguments.request.fullName : arguments.account.getFullName() )
		});
		
		local.theForm.addElement('email', {
			name = 'email',
			label = 'email',
			required = true,
			value = ( structKeyExists(arguments.request, 'email') ? arguments.request.email : arguments.account.getEmail() )
		});
		
		local.theForm.addElement('password', {
			name = 'password',
			label = 'password',
			required = arguments.account.getPasswordHash() == '',
			value = ( structKeyExists(arguments.request, 'password') ? arguments.request.password : '' )
		});
		
		local.theForm.addElement('password', {
			name = 'passwordConfirm',
			label = 'passwordConfirm',
			required = arguments.account.getPasswordHash() == '',
			value = ( structKeyExists(arguments.request, 'passwordConfirm') ? arguments.request.passwordConfirm : '' )
		});
		
		return local.theForm.toHTML(theURL.get());
	}
</cfscript>
</cfcomponent>
