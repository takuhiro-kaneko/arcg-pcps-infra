# Definition of lambda 02 
# ローカルにあるlambdaのソースコード
data "archive_file" "lambda-kkc-d2pf-02-clip" {
  type        = "zip"
  source_dir  = "lambda/src"
  output_path = "lambda/src/lambda-kkc-d2pf-02-clip.zip"
}

data "aws_iam_policy_document" "assume_role_02" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda_02" {
  name               = "iam_for_lambda_02"
  assume_role_policy = data.aws_iam_policy_document.assume_role_02.json
}

# AWSへ作るlambda function
resource "aws_lambda_function" "lambda-kkc-d2pf-02-clip" {
  function_name    = "lambda-kkc-d2pf-02-clip"
  filename         = data.archive_file.lambda-kkc-d2pf-02-clip.output_path
  source_code_hash = data.archive_file.lambda-kkc-d2pf-02-clip.output_base64sha256
  runtime          = "python3.12"
  role             = aws_iam_role.iam_for_lambda_02.arn
  handler          = "lambda-kkc-d2pf-02-clip.lambda_function.lambda_handler"
}

resource "aws_s3_bucket" "s3-kkc-d2pf-04-cliprequest" {
  bucket = "s3-kkc-d2pf-04-cliprequest"  
  
  tags = {
    Name        = "ArcGIS PCPS Bucket Vol 04"
  }
}

# トリガー（S3イベント）を設定
resource "aws_lambda_permission" "allow_s3_02" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-kkc-d2pf-02-clip.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3-kkc-d2pf-04-cliprequest.arn
}

resource "aws_s3_bucket_notification" "bucket_notification_02" {
  bucket = aws_s3_bucket.s3-kkc-d2pf-04-cliprequest.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda-kkc-d2pf-02-clip.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_s3_02]
}
