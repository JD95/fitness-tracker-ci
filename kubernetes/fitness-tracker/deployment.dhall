let kubernetes = (../prelude.dhall).kubernetes

let deploymentLabel = toMap { app = "fitness-tracker" }

let serverContainer =
      kubernetes.Container::{
      , name = "fitness-tracker"
      , image = Some "jdwyer95/fitness-server:e1d0d1b5ac42500ae8ce4c933a377d4fde6538c1"
      , imagePullPolicy = Some "IfNotPresent"
      , ports = Some [ kubernetes.ContainerPort::{ containerPort = 8081 } ]
      }

let deployment =
      kubernetes.Deployment::{
      , metadata = kubernetes.ObjectMeta::{ name = Some "fitness-tracker" }
      , spec = Some kubernetes.DeploymentSpec::{
        , selector = kubernetes.LabelSelector::{
          , matchLabels = Some deploymentLabel
          }
        , replicas = Some 1
        , template = kubernetes.PodTemplateSpec::{
          , metadata = Some kubernetes.ObjectMeta::{
            , name = Some "fitness-tracker"
            , labels = Some deploymentLabel
            }
          , spec = Some kubernetes.PodSpec::{ containers = [ serverContainer ] }
          }
        }
      }

in  deployment
