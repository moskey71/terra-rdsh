resource "aws_cloudformation_stack" "this" {
  template_body = file(
    "${path.module}/ra_guac_autoscale_public_alb.template.cfn.yaml",
  )

  name               = var.StackName
  capabilities       = var.Capabilities
  disable_rollback   = var.DisableRollback
  iam_role_arn       = var.IamRoleArn
  notification_arns  = var.NotificationArns
  on_failure         = var.OnFailureAction
  policy_body        = var.PolicyBody
  policy_url         = var.PolicyUrl
  tags               = var.StackTags
  timeout_in_minutes = var.StackCreateTimeout

  parameters = {
    "AmiId"                    = var.AmiId
    "AmiNameSearchString"      = var.AmiNameSearchString
    "BrandText"                = var.BrandText
    "CloudWatchAgentUrl"       = var.CloudWatchAgentUrl
    "DesiredCapacity"          = var.DesiredCapacity
    "ForceUpdateToggle"        = var.ForceUpdateToggle
    "GuacBaseDN"               = var.GuacBaseDN
    "GuacamoleVersion"         = var.GuacamoleVersion
    "GuacdVersion"             = var.GuacdVersion
    "InstanceType"             = var.InstanceType
    "KeyPairName"              = var.KeyPairName
    "LdapDN"                   = var.LdapDN
    "LdapServer"               = var.LdapServer
    "MaxCapacity"              = var.MaxCapacity
    "MinCapacity"              = var.MinCapacity
    "PrivateSubnetIds"         = join(",", var.PrivateSubnetIds)
    "PublicSubnetIds"          = join(",", var.PublicSubnetIds)
    "ScaleDownDesiredCapacity" = var.ScaleDownDesiredCapacity
    "ScaleDownSchedule"        = var.ScaleDownSchedule
    "ScaleUpSchedule"          = var.ScaleUpSchedule
    "SslCertificateName"       = var.SslCertificateName
    "SslCertificateService"    = var.SslCertificateService
    "URL1"                     = var.URL1
    "URL2"                     = var.URL2
    "URLText1"                 = var.URLText1
    "URLText2"                 = var.URLText2
    "UpdateSchedule"           = var.UpdateSchedule
    "VpcId"                    = var.VpcId
  }

  timeouts {
    create = "${var.StackCreateTimeout}m"
    delete = "${var.StackDeleteTimeout}m"
    update = "${var.StackUpdateTimeout}m"
  }
}

data "aws_region" "current" {
}

resource "aws_route53_record" "this" {
  zone_id = var.GuacDnsZoneId
  name    = var.GuacPublicDnsHostname
  type    = "A"

  alias {
    name                   = lookup(aws_cloudformation_stack.this.outputs, "LoadBalancerDns", "")
    zone_id                = var.ElbZones[data.aws_region.current.name]
    evaluate_target_health = true
  }
}

