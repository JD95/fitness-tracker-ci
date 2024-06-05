let imports =
      { kubernetes =
          https://raw.githubusercontent.com/dhall-lang/dhall-kubernetes/master/package.dhall
            sha256:705f7bd1c157c5544143ab5917bdc3972fe941300ce4189a8ea89e6ddd9c1875
      }

let PgClusterSpecStorage =
      { Type = { size : Optional Text }, default.size = None }

let PgClusterSpec =
      { Type =
          { instances : Natural, storage : Optional PgClusterSpecStorage.Type }
      , default = { instances = 1, storage = None }
      }

let PgClusterMeta = { Type = { name : Optional Text }, default.name = None }

let PgCluster =
      { Type =
          { apiVersion : Text
          , kind : Text
          , metadata : Optional PgClusterMeta.Type
          , spec : Optional PgClusterSpec.Type
          }
      , default =
        { apiVersion = "postgresql.cnpg.io/v1"
        , kind = "Cluster"
        , metadata = None
        , spec = { instances = 1, storage.size = 3 }
        }
      }

in  { kubernetes =
            imports.kubernetes
        //  { PgCluster, PgClusterMeta, PgClusterSpec, PgClusterSpecStorage }
    }
