/**********************************************************************************
 * Copyright 2023 Comprinno Technologies Pvt. Ltd.
 *
 * Comprinno Technologies Pvt. Ltd. owns all intellectual property rights in the software and associated
 * documentation files (the "Software"). Permission is hereby granted, to any person
 * obtaining a copy of this software, to use the Software only for internal use by
 * the licensee. Transfer, distribution, and sale of copies of the Software or any
 * derivative works based on the Software, are not permitted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 **********************************************************************************/

variable "cni_metrics_helper_conf" {
  description = "All required cni metrics helper configuration"
}

variable "region" {
  description = "AWS Region in which AWS EKS is deployed"
}
#https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
variable "public_image_account" {
  description = "Public ECR image repository account from which image will be pulled"
  default = {
    af-south-1     = 877085696533
    ap-east-1      = 800184023465
    ap-northeast-1 = 602401143452
    ap-northeast-2 = 602401143452
    ap-northeast-3 = 602401143452
    ap-south-1     = 602401143452
    ap-south-2     = 900889452093
    ap-southeast-1 = 602401143452
    ap-southeast-2 = 602401143452
    ap-southeast-3 = 296578399912
    ap-southeast-4 = 491585149902
    ca-central-1   = 602401143452
    ca-west-1      = 761377655185
    cn-north-1     = 918309763551
    cn-northwest-1 = 961992271922
    eu-central-1   = 602401143452
    eu-central-2   = 900612956339
    eu-north-1     = 602401143452
    eu-south-1     = 590381155156
    eu-south-2     = 455263428931
    eu-west-1      = 602401143452
    eu-west-2      = 602401143452
    eu-west-3      = 602401143452
    il-central-1   = 066635153087
    me-south-1     = 558608220178
    me-central-1   = 759879836304
    sa-east-1      = 602401143452
    us-east-1      = 602401143452
    us-east-2      = 602401143452
    us-gov-east-1  = 151742754352
    us-gov-west-1  = 013241004608
    us-west-1      = 602401143452
    us-west-2      = 602401143452
  }
}

variable "cluster_name" {
  description = "AWS EKS Cluster name in which CNI metric helper will be deployed"
}
