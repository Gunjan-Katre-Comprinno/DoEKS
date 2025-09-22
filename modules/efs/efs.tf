# /**********************************************************************************
#  * Copyright 2023 Comprinno Technologies Pvt. Ltd.
#  *
#  * Comprinno Technologies Pvt. Ltd. owns all intellectual property rights in the software and associated
#  * documentation files (the "Software"). Permission is hereby granted, to any person
#  * obtaining a copy of this software, to use the Software only for internal use by
#  * the licensee. Transfer, distribution, and sale of copies of the Software or any
#  * derivative works based on the Software, are not permitted.
#  *
#  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
#  * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#  * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#  * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#  * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#  * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#  **********************************************************************************/

//=======================================================================================================
//                              AWS Elastic File System
//=======================================================================================================
resource "aws_efs_file_system" "efs" {
  encrypted                       = try(var.efs_conf.encrypted, true)
  kms_key_id                      = aws_kms_key.key.arn
  performance_mode                = try(var.efs_conf.performance_mode, "generalPurpose")
  throughput_mode                 = try(var.efs_conf.throughput_mode, "bursting")
  provisioned_throughput_in_mibps = try(var.efs_conf.provisioned_throughput_in_mibps, 0)
  tags = merge(
    {
      Name        = try("${var.environment}-${var.efs_conf.name}", "${var.environment}-csi-efs")
      Environment = var.environment
    },
    try(var.efs_conf.additional_tags, {})
  )

  depends_on = [aws_kms_key.key]
}

//=======================================================================================================
//                              AWS EFS Backup Policy
//=======================================================================================================
resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.efs.id
  backup_policy {
    status = try(var.efs_conf.backup_policy_status, "ENABLED")
  }
  depends_on = [aws_efs_file_system.efs]
}

//=======================================================================================================
//                              AWS EFS Mount Targets
//=======================================================================================================
resource "aws_efs_mount_target" "mount_target" {
  count           = length(var.db_subnets)
  file_system_id  = aws_efs_file_system.efs.id
  security_groups = [aws_security_group.efs_sg.id]
  subnet_id       = var.db_subnets["${count.index}"]
  depends_on      = [aws_kms_key.key, aws_security_group.efs_sg]
}

//=======================================================================================================
//                              AWS Security Group for EFS
//=======================================================================================================
resource "aws_security_group" "efs_sg" {
  name        = try("${var.environment}-${var.efs_conf.name}-security-group", "${var.environment}-csi-efs-security-group")
  description = "Allows access to AWS Elastic File System"
  vpc_id      = var.vpc_id
  ingress {
    description = "EFS Access from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }
  tags = merge(
    {
      Name        = try("${var.environment}-${var.efs_conf.name}-security-group", "${var.environment}-csi-efs-security-group")
      Environment = var.environment
    },
    var.efs_conf.additional_tags
  )
}