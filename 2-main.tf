resource "aws_s3_bucket" "Jenkins_Bucket" {
  bucket_prefix = "jenkins-bucket-"
  force_destroy = true


  tags = {
    Name = "Jenkins Bucket"
  }
}

resource "aws_s3_object" "Armageddon_Approval" {
  bucket = aws_s3_bucket.Jenkins_Bucket.id
  key    = "armageddon-evidence/Armageddon-BOS-PassProof.png"
  source = "${path.module}/armageddon-evidence/Armageddon-BOS-PassProof.png"
}

resource "aws_s3_object" "Armageddon_Repo_Link" {
  bucket = aws_s3_bucket.Jenkins_Bucket.id
  key    = "armageddon-evidence/armageddon-link.txt"
  source = "${path.module}/armageddon-evidence/armageddon-link.txt"
}

resource "aws_s3_object" "screengrabs" {
  for_each = fileset("${path.module}/screengrabs", "*")
  bucket   = aws_s3_bucket.Jenkins_Bucket.id
  key      = "screengrabs/${each.value}"
  source   = "${path.module}/screengrabs/${each.value}"
}

resource "aws_s3_bucket_public_access_block" "Jenkins_Bucket_Public_Access_Block" {
  bucket = aws_s3_bucket.Jenkins_Bucket.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "Jenkins_Bucket_Policy" {
  bucket = aws_s3_bucket.Jenkins_Bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject"
        ]
        Resource = ["${aws_s3_bucket.Jenkins_Bucket.arn}/armageddon-evidence/*", "${aws_s3_bucket.Jenkins_Bucket.arn}/screengrabs/*"]
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.Jenkins_Bucket_Public_Access_Block]

}