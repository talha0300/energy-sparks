eb create production
--branch_default
--database
--database.engine postgres
--database.instance db.t2.small
--database.size 5
--database.version 9.6.9
--envvars SECRET_KEY_BASE=c64da20c4e889be31a26e2cd747470e54a49be00c248a18db1b2f13ec66b07e9f26303c63c097e7f5823841141c937e52e460f81217d8354cf4be48ba0b2ffcf,SOCRATA_ELECTRICITY_DATASET=fqa5-b8ri,SOCRATA_GAS_DATASET=rd4k-3gss,SOCRATA_STORE=data.bathhacked.org,SOCRATA_LIMIT=50000
--instance_type t2.small
--platform ruby-2.5-(puma)

