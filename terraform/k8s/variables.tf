variable "speakeasyName" {
  default = "speakeasy"
}

variable "namespace" {
  default     = "default"
  description = "Kubernetes namespace where speakeasy will be installed"
}

variable "apiHostnames" {
  type        = list(string)
  default     = null
  description = "List of domain names for registry api. You must set this variable if \"ingressNginxEnabled\" is set to true."
}

variable "webHostnames" {
  type        = list(string)
  default     = null
  description = "List of domain names for registry web UI. You must set this variable if \"ingressNginxEnabled\" is set to true."
}

variable "grpcHostnames" {
  type        = list(string)
  default     = null
  description = "List of domain names for gRPC service used for request capture. You must set this variable if \"ingressNginxEnabled\" is set to true."
}

variable "embedFixtureHostnames" {
  type        = list(string)
  default     = null
  description = "List of domain names for registry embed-fixture UI. You must set this variable if \"ingressNginxEnabled\" is set to true."
}

variable "createK8sPostgres" {
  default     = false
  description = "If true, a postgresql database will be installed on EKS alongside speakeasy. This is not recommended for production, you should think of this database as a non persistent database"
}

variable "postgresDSN" {
  default     = null
  description = "Connection string for a particular data source to store Speakeasy-maintained config and requests. Must be set if createK8sPostgres is false"
}

variable "signInURL" {
  default     = null
  description = "The full URL to the Speakeasy homepage the user will be redirected to upon signing in (e.g. \"https://www.selfhostspeakeasy.com\")"
}

variable "githubClientId" {
  default     = null
  description = "Client ID of the Github Oauth app."
}

variable "githubCallbackURL" {
  default     = null
  description = "Your application’s callback URL (e.g. \"https://api.selfhostspeakeasy.com/v1/auth/callback/github\")"
}

variable "githubClientSecretValue" {
  default     = null
  sensitive   = true
  description = "Client secret of the Github Oauth app. If not null then a kubernetes secret will be created containing this value."
}

variable "githubClientSecretName" {
  default     = null
  description = "Kubernetes secret name containing github client secret. Setting this value only makes sense when \"githubClientSecretValue\" is null (a kubernetes secret already exists contining the github secret)"
}

variable "githubClientSecretKey" {
  default     = null
  description = "Kubernetes secret key in \"githubClientSecretName\" that maps to the github client secret. Setting this value only makes sense when \"githubClientSecretValue\" is null (a kubernetes secret already exists contining the github secret)"
}

variable "serviceAccountSecretName" {
  default     = null
  description = "Kubernetes secret name containing a GCP service account private key (base64 encoded) used by speakeasy to authenticate with GCP. Setting this value only makes sense when \"serviceAccountSecretValue\" is null (a kubernetes secret already exists containing the service account private key)"
}

variable "serviceAccountSecretValue" {
  default     = null
  description = "GCP service account private key (base64 encoded) used by speakeay to authenticate with GCP (e.g. GOOGLE_APPLICATION_CREDENTIALS will be set to this value). For this value to be used \"createServiceAccountSecret\" should be set to true."
}

variable "serviceAccountSecretKey" {
  default     = null
  description = "Kubernetes secret key in \"serviceAccountSecretName\" that maps to the service account private key. Setting this value only makes sense when \"serviceAccountSecretValue\" is null (a kubernetes secret already exists containing the service account private key)"
}

variable "createServiceAccountSecret" {
  default     = false
  description = "If true a kubernetes secret will be created containing the non-null value specified in \"serviceAccountSecretValue\". If false, then \"serviceAccountSecretValue\" will be ignored."
}

variable "cloudProvider" {
  default     = null
  description = "Cloud provider where speakeasy will be running"
}

variable "ingressNginxEnabled" {
  default     = false
  description = "Whether or not ingress is enabled via nginx"
}

variable "controllerStaticIpOrHostname" {
  default     = null
  description = "static public hostname/ip to be used on nginx's controller."
}
