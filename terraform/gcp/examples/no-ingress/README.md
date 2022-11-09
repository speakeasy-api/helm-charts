# Create Speakeasy instance on GKE cluster with ingress disabled

Among other things, this example will do the following:

1. Create speakeasy containers
2. Create a postgres instance in kubernetes

## Instructions

1. **Set up OAuth on Github**: Under settings for the Github Organization you'd like to authenticate (or your personal profile) , click `Developer Settings" > Oauth Apps > New Oauth App`. Fill in the fields as follows:

   - Homepage URL: `http://localhost:35291`
   - Authorization callback URL: `http://localhost:35290/v1/auth/callback/github`

   Under `Application Name` set any value you want. Click on `Register application`.

1. **Get Client ID and Client Secret**: After registering your application in the previous step you'll be redirected to a configuration view of the application you just registered. The value under `Client ID` should be the value you set on the module's `githubClientId` variable. Similarly, under `Client secrets` you'll click on `Generate a new client secret` and the provided secret should be the value you set on the module's `githubClientSecretValue`.
1. **Set terraform module configuration**: At this point you should have all the values you need to use the module. Open the [main.tf](./main.tf) file and make the following changes:
   1. Change the `project` and `zone` fields under the google's provider to the GCP project and zone where your Speakeasy instance will be created.
   1. Change the `name` field under the `google_container_cluster` data source to the name of the GKE cluster where your Speakeasy instance will be created.
   1. Change `githubClientId` and `githubClientSecretValue` to the values you got on the third step.
1. Run `terraform init && terraform apply -auto-approve`! Wait for your resources to be created.
1. **Port-forward**: Run `kubectl port-forward <SPEAKEASY_POD_NAME> 35291:35291` and `kubectl port-forward <SPEAKEASY_POD_NAME> 35290:35290`
1. Go to your speakeasy's website using your browser (`http://localhost:35291`) and try to log in using your github account. You'll get an error that looks like this:
   ```
   email "YOUR_EMAIL" not added to the whitelist: please contact support to get whitelisted
   ```
   you need to add the email you are using on your github account to speakeasy's allowlist which is stored in the postgresql database the module created:
   1. Run `kubectl exec -it <POSTGRESQL_POD_NAME> -- /bin/bash`
   1. Run `psql -U postgres` in the pod
   1. Run `UPDATE users SET whitelisted=TRUE;` in your database
   1. Try logging in again.

Done!
