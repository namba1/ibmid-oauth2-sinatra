Get started with ${app}
-----------------------------------
Welcome to your new Ruby Sinatra app!

Focused on quickly creating web applications in Ruby with minimal effort.

1. [Install the cf command-line tool](${doc-url}/#starters/BuildingWeb.html#install_cf).
2. [Download the starter application package](${ace-url}/rest/apps/${app-guid}/starter-download).
3. Extract the package and `cd` to it.
4. Connect to Bluemix:

		cf api ${api-url}

5. Log into Bluemix:

		cf login -u ${username}
		cf target -o ${org} -s ${space}

6. Deploy your app:

		cf push ${app}

7. Access your app: [${route}](//${route})
