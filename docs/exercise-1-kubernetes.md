# Exercise 1: Kubernetes

## Dockerize Sample Application

The sample app (file: [main.py](app/src/main.py)) is Dockerized using the [Dockerfile](app/Dockerfile) under 'app' direcetory.

### `Dockerfile` considerations

- Current stable Python release is used, v3.12. Ref.: [here](https://docs.python.org/release/3.12.3/whatsnew/changelog.html#python-3-12-3-final).
- Use v3.12 Python 'slim-bookworm' as base image.
- Use separate application user to run application instead of '`root`'.
- Restrict file permissions as necessary.
- Store application dependencies in `requirements.txt` file.

### About the `Makefile`

A [Makefile](app/Makefile) is provided to manage the container image management for convenience. Here's how to use it:

These are set as variables in `Makefile` to perform tasks:

```
CONTAINER_NAME="password-generator"
IMAGE_NAME="password-generator"
IMAGE_TAG="1.0.0"
APP_PORT=5000
EXPOSED_PORT=5000
TARGET_REPO="zayedmahmud/password-generator"
```

Available options for `Makefile` (run from `./app` directory in your terminal):

- **General**:
  - `make all`: build image and run container.
- **Build**:
  - `make build`: build container image & tag it.
- **Run**:
  - `make run`: run named container from image, deleting running container, if any.
  - `make rund`: run named container (in daemon mode) from image, deleting running container, if any.
- **Clean**:
  - `make clean`: stop & remove running container.
  - `make clean_all`: stop & remove running container and remove image from local cache.
- **Publish**:
  - `make publish`: tag & publish image to Docker Hub.
    - Note: Login required for target Docker repository before publishing (use: `docker login`).

### Run application locally using `Makefile`

1. Go to application directory: `cd app`
2. Build the image from `Dockerfile` & tag it: `make build`

   - Example image names/tags: '`password-generator:v1.0.0`' & '`zayedmahmud/password-generator:v1.0.0`'
   - Equivalent commands:

        ```sh
        docker build -t "password-generator":"v1.0.0" .
        docker tag "password-generator":"v1.0.0" "zayedmahmud/password-generator":"v1.0.0"
        ```

3. Test the app by running container off of local image: `make run`, which exposes the appliction to localhost at port `5000` (default):

    - Example output:

        ```
        $ make run
        Removing container (if any): 'password-generator'...
        Run container as (in foreground): password-generator
        * Debug mode: off
        WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
        * Running on all addresses (0.0.0.0)
        * Running on http://127.0.0.1:5000
        * Running on http://172.17.0.2:5000
        Press C
        ```

    - Equivalent command: `docker run --rm -it --name "password-generator" -p 5000:5000 password-generator:v1.0.0`

4. Test the application with `curl`:

    - Check if app is active:

        ```sh
        curl --request GET --url http://127.0.0.1:5000/
        ```

      - Expected output: `Welcome to Password Generator`
   - Generate passwords:

        ```sh
        curl -s --request POST \
            --url http://127.0.0.1:5000/generate-passwords \
            --header 'content-type: application/json' \
            --data '{
                "min_length": 12,
                "special_chars": 2,
                "numbers": 3,
                "num_passwords": 3
            }'
        ```

     - Sample output:

        ```json
        ["T*G29vf8vi^G","vM0A7H$y6ea-","7&wFuB:2E0mh"]
        ```

5. Discard the container pressing `CTRL+C` in terminal.
6. Publish the image to Docker Hub if all okay: `make publish`.

   - Equivalent command:

        ```sh
        # Tag local image for remote repository
        docker tag "password-generator":"v1.0.0" "zayedmahmud/password-generator":"v1.0.0"

        # Verify tags
        docker images | grep "password-generator"
        password-generator               v1.0.0    9dd9930bc636   16 minutes ago   145MB
        zayedmahmud/password-generator   v1.0.0    9dd9930bc636   16 minutes ago   145MB

        # Push
        docker push "zayedmahmud/password-generator":"v1.0.0"
        ```
---

## Helmchart Deployment

A Helm chart named '**password-generator**' is created for the containerized application.

- The chart is available under [helmchart/password-generator](./helmchart/password-generator/) folder.
- Customized Helm values file (local) can be found at [helmchart/custom-values.yaml](helmchart/custom-values.yaml).
- The chart contains manifests for:
  - Deployment
  - Horizontal Pod Autoscaler (HPA)
  - Ingress
  - Service
  - Service Account.

### Testing the helm chart

**Notes:**

- A local '[kind](https://kind.sigs.k8s.io/)' cluster is used with Kubernetes v1.28.7.
- Nginx ingress controller is deployed to the cluster.
  - Deploy command: `kubectl apply -f kubernetes/ingress-nginx.yaml` and c
  - Check resources: `kubectl get all -n ingress-nginx`
- Ingress flag is enabled for the chart: `.ingress.enabled==true`
- The chart is deployed to separate namespace called '`app`', which is set/created during helm chart install workflow.

**Install the chart:**

1. Navigate to [helmchart](/helmchart/) folder: `cd helmchart`
2. Update Helm chart's values, if required, in file: [custom-values.yaml](helmchart/custom-values.yaml)
3. (Optional) Dry-run to check manifests:

    ```sh
    helm upgrade --install \
      -n app --create-namespace \
      --values custom-values.yaml \
      --dry-run \
      password-generator \
      ./password-generator
    ```

4. Install the chart in '`app`' namespace, create if necessary:

    ```sh
    helm upgrade --install \
      -n app --create-namespace \
      --values custom-values.yaml \
      password-generator \
      ./password-generator
    ```

5. (Optional) Switch to '`app`' namespace:

    ```
    kubectl config set-context --current --namespace=app
    ```

6. Check the installation: `helm list -n app`
7. Check resources for the app:

   - Sample command: `kubectl get all -n app`
   - Sample outputs:

      ```sh
      $ kubectl get all -n app
      NAME                                      READY   STATUS    RESTARTS   AGE
      pod/password-generator-646977856b-52l29   1/1     Running   0          14m
      pod/password-generator-646977856b-ccccz   1/1     Running   0          13m

      NAME                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
      service/password-generator   ClusterIP   10.96.203.150   <none>        5000/TCP   14m

      NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
      deployment.apps/password-generator   2/2     2            2           14m

      NAME                                            DESIRED   CURRENT   READY   AGE
      replicaset.apps/password-generator-646977856b   2         2         2       14m

      NAME                                                     REFERENCE                       TARGETS                        MINPODS   MAXPODS   REPLICAS   AGE
      horizontalpodautoscaler.autoscaling/password-generator   Deployment/password-generator   <unknown>/70%, <unknown>/70%   2         10        2          14m
      ```

8. Forward a local port to the ingress controller: `kubectl port-forward --namespace=ingress-nginx service/ingress-nginx-controller 32080:80`
9. Test app from browser or REST API client or a new shell, at `http://localhost:32080/`.

   - Snapshots from testing with REST API client:
     - Get Application Homepage: ![App homepage](/docs/images/local-test-helm-homepage.png "Application Homepage")<br>
     - Generate passwords: ![Generate passwords](/docs/images/local-test-helm-generate-pass.png "Generate passwords")
   - Example (testing from terminal with `curl`):

      ```sh
      $ curl --request GET --url http://127.0.0.1:32080/
      Welcome to Password Generator%

      $ curl -s --request POST \
          --url http://127.0.0.1:32080/generate-passwords \
          --header 'content-type: application/json' \
          --data '{
              "min_length": 12,
              "special_chars": 2,
              "numbers": 3,
              "num_passwords": 3
          }'
      ["K99'Rx8e>Xbw","aG{gz:H1v0Y3","1wyr8m_jOY%8"]

      ## Using 'jq' tool for better output
      $ curl -s --request POST \
          --url http://127.0.0.1:32080/generate-passwords \
          --header 'content-type: application/json' \
          --data '{
              "min_length": 12,
              "special_chars": 0,
              "numbers": 3,
              "num_passwords": 3
          }' | jq
      [
        "c6TAgLTiJ64c",
        "27sAJ4ALuuOL",
        "RNRp5s4aF5tq"
      ]
      ```

10. Stop port-forwading started at Step-8 from specific terminal by pressing `CTRL+C`.
11. Uninstall the helm chart if all testings are completed:

    - `helm uninstall password-generator -n app`

12. Remove namespace, if required:

    - `kubectl delete namespace app`.

---
