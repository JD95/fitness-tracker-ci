let kubernetes = (../prelude.dhall).kubernetes

in  kubernetes.PgCluster::{
    , apiVersion = "postgresql.cnpg.io/v1"
    , kind = "Cluster"
    , metadata = Some kubernetes.PgClusterMeta::{
      , name = Some "postgres-cluster"
      }
    , spec = Some kubernetes.PgClusterSpec::{
      , instances = 3
      , storage = Some kubernetes.PgClusterSpecStorage::{ size = Some "1Gi" }
      }
    }
