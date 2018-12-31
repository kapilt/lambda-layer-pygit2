# Lambda Layer - Python Libgit2

I was playing around with building some github apps with aws lambda & api gateway and 
wanted to use libgit2 for repo checkouts and analysis. The result was this lambda layer
for easy consumption of libgit2 from python lambda functions.


Build a docker image with the layer zip 

```shell
docker build -t layer-pygit2:latest .
```


Copy the lambda layer to the host

```shell
docker run --rm -v $PWD/layer:/output -it layer-pygit2:latest /bin/bash -c "cp /layer.zip /output"
```


Upload the lambda layer to aws. Note actual libgit/pygit license is GPLv2 with linking exception.

```shell
aws lambda publish-layer-version --layer-name pygit2 --license-info "GPLv2" \
    --compatible-runtimes "python3.7" --zip-file fileb://layer/layer.zip"
```
