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

variable "domain" {
  type        = string
  default     = null
  description = "Domain that will point to your speakeasy instance (e.g. `speakeasyplatform.com`. If set this value will be used to create a zone on cloud dns. Do not set if you don't need this module to create a cloud dns zone."
}

variable "domainZoneVisibility" {
  type        = string
  default     = "public"
  description = "A private DNS zone contains DNS records that are only visible internally within your Google Cloud network(s). A public zone is visible to the internet."

  validation {
    condition     = contains(["public", "private"], var.domainZoneVisibility)
    error_message = "Allowed values for input_parameter are `public` or `private`."
  }
}

variable "apiHostnames" {
  type        = list(string)
  default     = null
  description = "List of domain names for registry api. Setting this var only makes sense if `ingressNginxEnabled` is set to true. If `ingressNginxEnabled` is set to true and `domain` is not set then this variable can't be null. If `ingressNginxEnabled` is set to true and `domain` is set as well then the modules will set the hostnames for you (api.<DOMAIN> will be the api hostname)"
}

variable "webHostnames" {
  type        = list(string)
  description = "List of domain names for registry web UI.  Setting this var only makes sense if `ingressNginxEnabled` is set to true. If `ingressNginxEnabled` is set to true and `domain` is not set then this variable can't be null. If `ingressNginxEnabled` is set to true and `domain` is set as well then the modules will set the hostnames for you (www.<DOMAIN> and <DOMAIN> will be the web hostnames)"
  default     = null
}

variable "grpcHostnames" {
  type        = list(string)
  default     = null
  description = "List of domain names for gRPC service used for request capture. Setting this var only makes sense if `ingressNginxEnabled` is set to true. If `ingressNginxEnabled` is set to true and `domain` is not set then this variable can't be null. If `ingressNginxEnabled` is set to true and `domain` is set as well then the modules will set the hostnames for you (grpc.<DOMAIN> will be the grpc hostname)"
}

variable "embedFixtureHostnames" {
  type        = list(string)
  default     = null
  description = "List of domain names for registry embed-fixture UI. Setting this var only makes sense if `ingressNginxEnabled` is set to true. If `ingressNginxEnabled` is set to true and `domain` is not set then this variable can't be null. If `ingressNginxEnabled` is set to true and `domain` is set as well then the modules will set the hostnames for you (embed.<DOMAIN> will be the embed hostname)"
}

variable "createK8sPostgres" {
  type        = bool
  default     = false
  nullable    = false
  description = "If true, a postgresql database will be installed on GKE alongside speakeasy. This is not recommended for production, you should think of this database as a non persistent database"
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
  description = "Kubernetes secret key  in `githubClientSecretName` that maps to the github client secret. Setting this value only makes sense when `githubClientSecretValue` is null (a kubernetes secret already exists contining the github secret)"
}

variable "ingressNginxEnabled" {
  type        = bool
  default     = false
  nullable    = false
  description = "Whether or not ingress is enabled via nginx"
}

variable "controllerIp" {
  type        = string
  default     = null
  description = "static public IP to be used on nginx's controller. If null then GCP will assign an IP for you."
}

variable "serviceAccountSecretName" {
  default     = null
  description = "Kubernetes secret name containing a GCP service account private key (base64 encoded) used by speakeasy to authenticate with GCP. Setting this value only makes sense when `serviceAccountSecretValue` is null (a kubernetes secret already exists containing the service account private key)"
}

variable "serviceAccountSecretValue" {
  default     = null
  description = "GCP service account private key (base64 encoded) used by speakeasy to authenticate with GCP (e.g. GOOGLE_APPLICATION_CREDENTIALS will be set to this value). For this value to be used `createServiceAccountSecret` should be set to true."
}

variable "serviceAccountSecretKey" {
  default     = null
  description = "Kubernetes secret key in `serviceAccountSecretName` that maps to the service account private key. Setting this value only makes sense when `serviceAccountSecretValue` is null (a kubernetes secret already exists containing the service account private key)"
}

variable "createServiceAccountSecret" {
  default     = true
  nullable    = false
  description = "If true a kubernetes secret will be created containing the the private key used by speakeasy to authenticate with GCP."
}

variable "serviceAccountId" {
  default     = null
  description = "If non-null a private key will be created for the given service accound id and used by speakeasy to authenticate with GCP. This private key will be used instead of the value set in `serviceAccountSecretValue`."
}

variable "createServiceAccount" {
  default     = true
  nullable    = false
  description = "If true creates a new service account for which a private key will be created and used by speakeasy to authenticate with GCP. This private key will be used instead of the value set in `serviceAccountSecretValue`."
}
