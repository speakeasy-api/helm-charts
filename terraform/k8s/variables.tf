variable "speakeasyName" {
  type        = string
  default     = "speakeasy"
  nullable    = false
  description = "Prefix of most resources names"
}

variable "namespace" {
  type        = string
  default     = "default"
  nullable    = false
  description = "Kubernetes namespace where speakeasy will be installed"
}

variable "apiHostnames" {
  type        = list(string)
  default     = null
  description = "List of domain names for registry api. You must set this variable if `ingressNginxEnabled` is set to true."
}

variable "webHostnames" {
  type        = list(string)
  default     = null
  description = "List of domain names for registry web UI. You must set this variable if `ingressNginxEnabled` is set to true."
}

variable "grpcHostnames" {
  type        = list(string)
  default     = null
  description = "List of domain names for gRPC service used for request capture. You must set this variable if `ingressNginxEnabled` is set to true."
}

variable "embedFixtureHostnames" {
  type        = list(string)
  default     = null
  description = "List of domain names for registry embed-fixture UI. You must set this variable if `ingressNginxEnabled` is set to true."
}

variable "createK8sPostgres" {
  type        = bool
  default     = false
  nullable    = false
  description = "If true, a postgresql database will be installed on EKS alongside speakeasy. This is not recommended for production, you should think of this database as a non persistent database"
}

variable "postgresDSN" {
  type        = string
  default     = null
  description = "Connection string for a particular data source to store Speakeasy-maintained config and requests. Must be set if createK8sPostgres is false"
}

variable "signInURL" {
  type        = string
  nullable    = false
  description = "The full URL to the Speakeasy homepage the user will be redirected to upon signing in (e.g. `https://www.selfhostspeakeasy.com`)"
}

variable "githubClientId" {
  type        = string
  nullable    = false
  description = "Client ID of the Github OAuth app."
}

variable "githubCallbackURL" {
  type        = string
  nullable    = false
  description = "Authorization callback URL of the Github OAuth app"
}

variable "githubClientSecretValue" {
  type        = string
  default     = null
  sensitive   = true
  description = "Client secret of the Github OAuth app. If not null then a kubernetes secret will be created containing this value."
}

variable "githubClientSecretName" {
  type        = string
  default     = null
  description = "Kubernetes secret name containing github client secret. Setting this value only makes sense when `githubClientSecretValue` is null (a kubernetes secret already exists contining the github secret)"
}

variable "githubClientSecretKey" {
  type        = string
  default     = null
  description = "Kubernetes secret key in `githubClientSecretName` that maps to the github client secret. Setting this value only makes sense when `githubClientSecretValue` is null (a kubernetes secret already exists contining the github secret)"
}

variable "serviceAccountSecretName" {
  type        = string
  default     = null
  description = "Kubernetes secret name containing a GCP service account private key (base64 encoded) used by speakeasy to authenticate with GCP. Setting this value only makes sense when `serviceAccountSecretValue` is null (a kubernetes secret already exists containing the service account private key)"
}

variable "serviceAccountSecretValue" {
  type        = string
  default     = null
  description = "GCP service account private key (base64 encoded) used by speakeasy to authenticate with GCP (e.g. GOOGLE_APPLICATION_CREDENTIALS will be set to this value). For this value to be used `createServiceAccountSecret` should be set to true."
}

variable "serviceAccountSecretKey" {
  type        = string
  default     = null
  description = "Kubernetes secret key in `serviceAccountSecretName` that maps to the service account private key. Setting this value only makes sense when `serviceAccountSecretValue` is null (a kubernetes secret already exists containing the service account private key)"
}

variable "createServiceAccountSecret" {
  type        = bool
  default     = false
  nullable    = false
  description = "If true a kubernetes secret will be created containing the non-null value specified in `serviceAccountSecretValue`. If false, then `serviceAccountSecretValue` will be ignored."
}

variable "cloudProvider" {
  type        = string
  default     = null
  description = "Cloud provider where speakeasy will be running. Set to null if speakeasy won't be running in the cloud"
}

variable "ingressNginxEnabled" {
  type        = bool
  default     = false
  nullable    = false
  description = "Whether or not ingress is enabled via nginx"
}

variable "controllerStaticIpOrHostname" {
  type        = string
  default     = null
  description = "static public hostname/ip to be used on nginx's controller."
}
