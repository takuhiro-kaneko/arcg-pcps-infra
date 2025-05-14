# Definition of lambda 03 
# ローカルにあるlambdaのソースコード
data "archive_file" "lambda-kkc-d2pf-ssmmanage" {
  type        = "zip"
  source_dir  = "lambda/src"
  output_path = "lambda/src/lambda-kkc-d2pf-ssmmanage.zip"
}

data "aws_iam_policy_document" "assume_role_03" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda_03" {
  name               = "iam_for_lambda_03"
  assume_role_policy = data.aws_iam_policy_document.assume_role_03.json
}

# lambda用Policyの作成
resource "aws_iam_role_policy_attachment" "lambda_access_policy_03_01" {
  role   = aws_iam_role.iam_for_lambda_03.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}
resource "aws_iam_role_policy_attachment" "lambda_access_policy_03_02" {
  role   = aws_iam_role.iam_for_lambda_03.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/ROSAKMSProviderPolicy"
}
# AWSLambdaBasicExecutionRole
resource "aws_iam_role_policy" "lambda_access_policy_03_03" {
  name   = "d2pf-ssmmanage-AWSLambdaBasicExecutionRole"
  role   = aws_iam_role.iam_for_lambda_03.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:ap-northeast-1:ID:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:ap-northeast-1:ID:log-group:/aws/lambda/lambda-kkc-d2pf-ssmmanage:*"
            ]
        }
    ]
}
POLICY
}

# AWSへ作るlambda function
resource "aws_lambda_function" "lambda-kkc-d2pf-ssmmanage" {
  function_name    = "lambda-kkc-d2pf-ssmmanage"
  filename         = data.archive_file.lambda-kkc-d2pf-ssmmanage.output_path
  source_code_hash = data.archive_file.lambda-kkc-d2pf-ssmmanage.output_base64sha256
  runtime          = "nodejs22.x"
  role             = aws_iam_role.iam_for_lambda_03.arn
  handler          = "lambda-kkc-d2pf-ssmmanage.index.handler"
}



# API Gateway トリガー
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "apigateway-kkc-d2pf-01"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.lambda_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.lambda-kkc-d2pf-ssmmanage.invoke_arn
  integration_method = "GET"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "/getssm"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-kkc-d2pf-ssmmanage.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}


# APIGatewayはインポート操作ですませる
# body          = file("openapi-definition.json")  # JSONまたはYAMLファイル
resource "aws_apigatewayv2_api" "apigateway-kkc-d2pf-01" {
  name          = "apigateway-kkc-d2pf-01"
  protocol_type = "HTTP"
}

# SSM パラメータストア（SecureString）を作成
# value       = file("param_value.txt")
resource "aws_ssm_parameter" "secure_key_param" {
  name        = "/keyparam-user-s3allow-kkctest-02"
  type        = "SecureString"
  data_type   = "text"
  overwrite   = true
  tier        = "Standard"
  value       = "foo"
}
