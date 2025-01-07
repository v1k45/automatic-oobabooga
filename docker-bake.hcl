variable "RELEASE" {
    default = "1.0"
}

target "default" {
  dockerfile = "Dockerfile"
  tags = ["v1k45/automatic-oobabooga:${RELEASE}"]
  args = {}
  platforms= ["linux/amd64"]
}
