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