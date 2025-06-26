resource "aws_wafv2_web_acl" "main" {
  name  = "${var.env}-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # Global visibility configuration for the entire ACL
  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = "${var.env}-waf"
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    # Required per-rule visibility config
    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "CommonRuleSet"
    }
  }
}

# Associate the WAF Web ACL with the ALB
resource "aws_wafv2_web_acl_association" "link" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}
