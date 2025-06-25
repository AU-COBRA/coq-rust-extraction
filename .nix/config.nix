{
  ## DO NOT CHANGE THIS
  format = "1.0.0";
  ## unless you made an automated or manual update
  ## to another supported format.

  attribute = "RustExtraction";

  default-bundle = "9.0";

  bundles."9.0" = {
    coqPackages.coq.override.version = "9.0";
    coqPackages.metarocq.override.version = "1.3.4-9.0";
  };

  ## Cachix caches to use in CI
  cachix.coq = {};
  cachix.coq-community = {};
  cachix.metarocq = {};

  cachix.au-cobra.authToken = "CACHIX_AUTH_TOKEN";
}
