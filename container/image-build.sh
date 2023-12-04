az acr login --name kuberegistryacr

docker build -t my-cool-webpage:latest .
docker tag my-cool-webpage:latest kuberegistryacr.azurecr.io/my-cool-webpage:latest
docker push kuberegistryacr.azurecr.io/my-cool-webpage:latest
