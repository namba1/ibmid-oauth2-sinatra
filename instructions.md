Get started with ${app}
-----------------------------------
Welcome to your new Ruby Sinatra app!

Focused on quickly creating web applications in Ruby with minimal effort.

1. [Install the cf command-line tool](${doc-url}/#starters/BuildingWeb.html#install_cf).
2. [Download the starter application package](${ace-url}/rest/apps/${app-guid}/starter-download).
3. Extract the package and `cd` to it.
4. Connect to Bluemix:

		cf api https://api.ng.bluemix.net
5. Log into Bluemix:

		cf login -u namba1@jp.ibm.com
		cf target -o namba1@jp.ibm.com -s dev

6. Deploy your app:

		cf push sinatra99

7. Access your app: sinatra99.mybluemix.net
