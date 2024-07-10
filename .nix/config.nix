{
  ## DO NOT CHANGE THIS
  format = "1.0.0";
  ## unless you made an automated or manual update
  ## to another supported format.

  attribute = "rust-extraction";

  default-bundle = "8.17";

  bundles."8.17" = {
    coqPackages.coq.override.version = "8.17";
    coqPackages.metacoq.override.version = "1.3.1-8.17";
  };
  bundles."8.18" = {
    coqPackages.coq.override.version = "8.18";
    coqPackages.metacoq.override.version = "1.3.1-8.18";
  };
  bundles."8.19" = {
    coqPackages.coq.override.version = "8.19";
    coqPackages.metacoq.override.version = "1.3.1-8.19";
  };

  ## Cachix caches to use in CI
  ## Below we list some standard ones
  cachix.coq = {};
  cachix.coq-community = {};
  cachix.metacoq = {};
  
  ## If you have write access to one of these caches you can
  ## provide the auth token or signing key through a secret
  ## variable on GitHub. Then, you should give the variable
  ## name here. For instance, coq-community projects can use
  ## the following line instead of the one above:
  # cachix.coq-community.authToken = "CACHIX_AUTH_TOKEN";
  
  ## Or if you have a signing key for a given Cachix cache:
  # cachix.my-cache.signingKey = "CACHIX_SIGNING_KEY"
  
  ## Note that here, CACHIX_AUTH_TOKEN and CACHIX_SIGNING_KEY
  ## are the names of secret variables. They are set in
  ## GitHub's web interface.
}
