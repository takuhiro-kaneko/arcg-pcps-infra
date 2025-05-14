# Definition of lambda 01 
# ローカルにあるlambdaのソースコード
data "archive_file" "lambda-kkc-d2pf-01" {
  type        = "zip"
  source_dir  = "lambda/src"
  output_path = "lambda/src/lambda-kkc-d2pf-01.zip"
}

data "aws_iam_policy_document" "assume_role_01" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda_01" {
  name               = "iam_for_lambda_01"
  assume_role_policy = data.aws_iam_policy_document.assume_role_01.json
}

# lambda用Policyの作成
# ログ出力
resource "aws_iam_role_policy" "lambda_access_policy_output_log" {
  name   = "d2pf-AWSLambdaBasicExecutionRole"
  role   = aws_iam_role.iam_for_lambda_01.id
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
                "arn:aws:logs:ap-northeast-1:ID:log-group:/aws/lambda/lambda-kkc-d2pf-*"
            ]
        }
    ]
}
POLICY
}
# S3の取得
resource "aws_iam_role_policy" "lambda_access_policy_get_s2" {
  name   = "d2pf-AWSLambdaS3ExecutionRole"
  role   = aws_iam_role.iam_for_lambda_01.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "arn:aws:s3:::*"
        }
    ]
}
POLICY
}
# SNS送信
resource "aws_iam_role_policy" "lambda_access_policy_send_sns" {
  name   = "d2pf-AWSLambdaSNSPublishPolicyExecutionRole"
  role   = aws_iam_role.iam_for_lambda_01.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sns:Publish"
            ],
            "Resource": "arn:aws:sns:*:*:*"
        }
    ]
}
POLICY
}

# AWSへ作るlambda function
resource "aws_lambda_function" "lambda-kkc-d2pf-01" {
  function_name    = "lambda-kkc-d2pf-01"
  filename         = data.archive_file.lambda-kkc-d2pf-01.output_path
  source_code_hash = data.archive_file.lambda-kkc-d2pf-01.output_base64sha256
  runtime          = "python3.12"
  role   = aws_iam_role.iam_for_lambda_01.id
  handler          = "lambda-kkc-d2pf-01.lambda_function.lambda_handler"
}

resource "aws_s3_bucket" "s3-kkc-d2pf-01-lasupload" {
  bucket = "s3-kkc-d2pf-01-lasupload"  
  
  tags = {
    Name        = "ArcGIS PCPS Bucket Vol 01"
  }
}

# トリガー（S3イベント）を設定
resource "aws_lambda_permission" "allow_s3_01" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-kkc-d2pf-01.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3-kkc-d2pf-04-cliprequest.arn
}

resource "aws_s3_bucket_notification" "bucket_notification_01" {
  bucket = aws_s3_bucket.s3-kkc-d2pf-01-lasupload.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda-kkc-d2pf-01.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_s3_01]
}
