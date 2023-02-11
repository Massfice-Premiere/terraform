terraform {
  backend "remote" {
    organization = "MassficeOnline"

    workspaces {
      name = ""
    }
  }
}
