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
  description = "Domain that will point to your speakeasy instance (e.g. `speakeasyplatform.com`. If set this value will be used to create a zone on Route 53. Do not set if you don't need this module to create a Route 53 zone."
}

variable "privateZoneVpcId" {
  type        = string
  default     = null
  description = "A private DNS zone contains DNS records that are only visible internally within your AWS network(s). A public zone is visible to the internet. This variable specifies the VPC associated with the speakeasy's PRIVATE zone. If null, a public zone will be used."
}

variable "apiHostnames" {
  type        = list(string)
  default     = null
  description = "List of domain names for registry api. Setting this var only makes sense if `ingressNginxEnabled` is set to true. If `ingressNginxEnabled` is set to true and `domain` is not set then this variable can't be null. If `ingressNginxEnabled` is set to true and `domain` is set as well then the modules will set the hostnames for you (api.<DOMAIN> will be the api hostname)"
}

variable "webHostnames" {
  type        = list(string)
  default     = null
  description = "List of domain names for registry web UI.  Setting this var only makes sense if `ingressNginxEnabled` is set to true. If `ingressNginxEnabled` is set to true and `domain` is not set then this variable can't be null. If `ingressNginxEnabled` is set to true and `domain` is set as well then the modules will set the hostnames for you (www.<DOMAIN> and <DOMAIN> will be the web hostnames)"
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
  description = "If true, a postgresql database will be installed on EKS alongside speakeasy. This is not recommended for production, you should think of this database as a non persistent database"
}

variable "postgresDSN" {
  type        = string
  default     = null
  description = "Connection string for a particular data source to store Speakeasy-maintained config and requests. Must be set if createK8sPostgres is false"
}

variable "signInURL" {
  type        = string
  default     = null
  nullable    = false
  description = "The full URL to the Speakeasy homepage the user will be redirected to upon signing in (e.g. `https://www.selfhostspeakeasy.com`)"
}

variable "githubClientId" {
  type        = string
  default     = null
  nullable    = false
  description = "Client ID of the Github Oauth app."
}

variable "githubCallbackURL" {
  type        = string
  default     = null
  nullable    = false
  description = "Your application’s callback URL (e.g. `https://api.selfhostspeakeasy.com/v1/auth/callback/github`)"
}

variable "githubClientSecretValue" {
  type        = string
  default     = null
  sensitive   = true
  nullable    = false
  description = "Client secret of the Github Oauth app. If not null then a kubernetes secret will be created containing this value."
}

variable "githubClientSecretName" {
  type        = string
  default     = null
  nullable    = false
  description = "Kubernetes secret name containing github client secret. Setting this value only makes sense when `githubClientSecretValue` is null (a kubernetes secret already exists contining the github secret)"
}

variable "githubClientSecretKey" {
  type        = string
  default     = null
  nullable    = false
  description = "Kubernetes secret key  in `githubClientSecretName` that maps to the github client secret. Setting this value only makes sense when `githubClientSecretValue` is null (a kubernetes secret already exists contining the github secret)"
}

variable "ingressNginxEnabled" {
  type        = bool
  default     = false
  nullable    = false
  description = "Whether or not ingress is enabled via nginx"
}

variable "controllerHostname" {
  type        = string
  default     = null
  description = "static public hostname to be used on nginx's controller. If null then AWS will assign a hostname for you."
}
