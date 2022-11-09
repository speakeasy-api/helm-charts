# Create Speakeasy instance on GKE cluster with enabled ingress and an externally created (sealed) github secret

Among other things, this example will do the following:

1. Create speakeasy containers
2. Create a postgres instance in kubernetes
3. Enable ingress to speakeasy instance
4. For the given `domain`, create a Cloud DNS Zone and its corresponding A Records
5. Create a sealed secret for Github's OAuth secret.

## Instructions

1. **Register a domain**: on GCP's [Cloud Domains](https://cloud.google.com/domains/docs/overview) (or any other domain registrar). The domain you register should be the same as the value you set on the `domain` variable of the module.
1. **Set up OAuth on Github**: Under settings for the Github Organization you'd like to authenticate (or your personal profile) , click `Developer Settings" > Oauth Apps > New Oauth App`. Fill in the fields as follows:

   - Homepage URL: `https://<domain>`
   - Authorization callback URL: `https://<domain>/v1/auth/callback/github`

   replacing `<domain>` with the domain you registered on the preivous step. Under `Application Name` set any value you want. Click on `Register application`.

1. **Get Client ID**: After registering your application in the previous step you'll be redirected to a configuration view of the application you just registered. The value under `Client ID` should be the value you set on the module's `githubClientId` variable.
1. **Get Client Secret**: On the same Github OAuth configuration view, click on `Generate a new client secret`. Keep this secret to use it on following steps.
1. **Create Sealed Secret**:
   - Install sealed secrets in your kubernetes cluster by running `helm install my-release sealed-secrets/sealed-secrets`
   - Install `kubeseal` locally (`brew install kubeseal` with homebrew)
   - Run `echo -n <SECRET> | kubeseal --scope strict --raw --namespace default --name github-client-secret --controller-name=my-release-sealed-secrets --controller-namespace=default` replacing `<SECRET>` with the secret you got on step 4. The output you get is your sealed secret
   - Replace `<MY_SEALED_SECRET>` in [sealedSecret.yaml](./sealedSecret.yaml) with the sealed secret you got in the previous step.
   - Run `kubectl apply -f sealedSecret.yaml`
1. **Set terraform module configuration**: At this point you should have all the values you need to use the module. Open the [main.tf](./main.tf) file and make the following changes:
   1. Change the `project` and `zone` fields under the google's provider to the GCP project and zone where your Speakeasy instance will be created.
   1. Change the `name` field under the `google_container_cluster` data source to the name of the GKE cluster where your Speakeasy instance will be created.
   1. Change the `domain` field under the `gcp_speakeasy` module to the domain you registered in the first step.
   1. Change `signInURL` to the same value you set the `Homepage URL` on the second step. Similarly, change `githubCallbackURL` to the same value you set on `Authorization callback URL`.
   1. Change `githubClientId` to the value you got on the third step.
1. Run `terraform init && terraform apply -auto-approve`! Wait for your resources to be created.
1. **Update the domain's name servers**: you need the domain's name servers to point to the ones in the newly created zone. To get the name servers used by the domain zone you can run `gcloud dns managed-zones describe <ZONE-NAME>` where `<ZONE-NAME>` is the value you set on the `domain` variable in the module, but replacing `.` with `-` (`my.domain.com` -> `my-domain-com`). Your speakeasy instance might not be available right away - you might have to wait a few minutes for the DNS changes to propagate.
1. Go to your speakeasy's website using your browser (`https://www.<YOUR_DOMAIN>`) and try to log in using your github account. You'll get an error that looks like this:
   ```
   email "YOUR_EMAIL" not added to the whitelist: please contact support to get whitelisted
   ```
   you need to add the email you are using on your github account to speakeasy's allowlist which is stored in the postgresql database the module created:
   1. Run `kubectl exec -it <POSTGRESQL_POD_NAME> -- /bin/bash`
   1. Run `psql -U postgres` in the pod
   1. Run `UPDATE users SET whitelisted=TRUE;` in your database
   1. Try logging in again.

Done!
