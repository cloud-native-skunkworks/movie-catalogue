
KUBECTL="kubectl"

cnpg_get_latest_version() {
 curl -SsL https://api.github.com/repos/cloudnative-pg/cloudnative-pg/releases/latest | jq -r .tag_name
}

cnpg_get_manifest_url() {
 local cnpg_version=$1; shift
 num_version=${cnpg_version#v}

 curl -SsL https://api.github.com/repos/cloudnative-pg/cloudnative-pg/releases/tags/"$cnpg_version" |
	jq -r '.assets[] | select( .name == "cnpg-'"${num_version}"'.yaml") | .browser_download_url '
}

cnpg_apply_manifest() {
 local manifest=$1; shift

 apply_wait=$($KUBECTL apply -f "$manifest" > /dev/null)

 # If the apply isn't succesful we stop and exit
 if [[ "${apply_wait}" -ne 0 ]]; then
	echo "$?"
 fi

 # We wait for the Deployment to be ready
 echo "Waiting 120 seconds for CloudNativePG Pod to be ready..."
 wait_output=$(cnpg_wait_for)

 echo "${wait_output}"
}

cnpg_wait_for() {
 $KUBECTL wait pods -n cnpg-system --for condition=Ready --timeout=120s -l app.kubernetes.io/name=cloudnative-pg

 echo "$?"
}

cnpg_show_first_cluster() {
 # Show a cluster example creation
 echo "
cat <<EOF | kubectl apply -f -
# Example of PostgreSQL cluster
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cluster-example
spec:
  instances: 3
  storage:
    size: 1Gi
EOF
"
}

cnpg_more_information() {
 local cnpg_version=$1; shift;
 version=${cnpg_version#v}
 short_version=${version%.*}

 # Show documentation URL and helper information
 echo "
For more information please visit the official documentation site:
https://cloudnative-pg.io/documentation/${short_version}/
"
}

cnpg_enable() {
 cnpg_version=$(cnpg_get_latest_version)
 cnpg_manifest_url=$(cnpg_get_manifest_url "$cnpg_version")
 cnpg_apply_manifest "$cnpg_manifest_url"
 apply_result=$?

 if [[ $apply_result -ne 0 ]]; then
	echo "CloudNativePG not installed"
	exit 1
 fi

 cnpg_more_information "$cnpg_version"

 echo "CloudNativePG installed"
}

cnpg_enable

cat <<EOF | kubectl apply -f -
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: movie-db-cluster
spec:
  instances: 3
  bootstrap:
    initdb:
      database: movie
      owner: app
  storage:
    size: 1Gi
EOF

sleep 5
kubectl get secrets movie-db-cluster-app -o jsonpath="{.data.password}" | base64 -d
