function apply_config() {
  # Pull the name of the service/deployment from the config
  # dhall-to-bash then creates a variable with the name set
  eval $(dhall-to-bash --declare obj_name <<< "($dir/$1.dhall).metadata.name")
  kubectl delete $1 $obj_name
  kubectl apply -f $dir/$1.yaml
}

for dir in ./kubernetes/*/
do
  dir=${dir%*/}
  for config in $dir/*.dhall
  do
    echo "compiling $config"
    echo "> resolving..."
    resolved=$(dhall resolve --file "$config")
    echo "> normalizing..."
    normalized=$(echo "$resolved" | dhall normalize)
    echo "> converting to yaml..."
    echo "$normalized" | dhall-to-yaml > "${config%.*}.yaml"
    echo "> done"
    apply_config $(basename ${config%.*})
  done
done
