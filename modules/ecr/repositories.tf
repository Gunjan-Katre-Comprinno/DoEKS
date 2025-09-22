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

//=======================================================================================================
//                              AWS ECR Resources
//=======================================================================================================
resource "aws_ecr_repository" "repositories" {
  for_each             = var.ecr_repository_conf.repositories
  name                 = lower("${var.environment}-${each.value.repository_name}")
  image_tag_mutability = try(each.value.is_mutable == true ? "MUTABLE" : "IMMUTABLE", "IMMUTABLE")
  force_delete         = true

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.key.arn
  }

  image_scanning_configuration {
    scan_on_push = try(each.value.enable_scan_on_push, true)
  }

  tags = merge(
    {
      Name        = "${var.environment}-${each.value.repository_name}"
      Environment = var.environment
    },
    try(each.value.additional_tags, {})
  )

  depends_on = [aws_kms_key.key]
}