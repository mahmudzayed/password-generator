# Exercise 2: Terraform

As part of the Terraform exercise, resources are created in AWS and tested.

## Notes About the Setup

- A VPC is created with:
  - 4 subnets (2x private & 2x public)
  - Route tables for private/public subnets
  - Internet gateway
  - Elastic IP
  - NAT Gateway (bound to Elastic IP)
- EKS cluster
- Managed node group for EKS
- Cluster Auto Scaler
- AWS Load Balancer Controller
- The ingress use ingress group so that single LB can be used by multiple ingresses in same group (cost-effective, if same project/environment), if required. Otherwise, each ingress will have a dedicated LB (expensive).

## Deploy the Resources

Follow the steps to deploy resources to your AWS account with necessary admin privileges:

1. Ensure AWS credentials are set to communicate with your a/c

   - Use `aws configure` command, or
   - Export required environment variables:

      ```sh
      export AWS_ACCESS_KEY_ID=AKIAI********EXAMPLE
      export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/********EXAMPLEKEY
      export AWS_DEFAULT_REGION=us-east-1
      ```

2. Navigate to terraform directory: `cd terraform`
3. Initialize backend to install dependencies: `terraform init`
4. Validate configs: `terraform validate`
6. Run a plan for the config: `terraform plan -out=myplan`
7. Apply changes if all okay: --> takes 15-20 minutes

   - `terraform apply "myplan"`
   - or `terraform apply`

8. After succesful deployment, set `kubectl` context to target new cluster (here '`zhm-demo-eks-cluster`' is eks cluster name & '`us-east-1`' is target aws region):

   - `aws eks --region us-east-1 update-kubeconfig --name zhm-demo-eks-cluster`

9. Test connection: `kubectl get svc` --> it should list '`kubernetes`' ClusterIP service in '`default`' namespace.
10. Check AWS load balancer controller logs for any issues:

    - `kubectl logs -f -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller`

11. Update '`kubernetes/cluster-autoscaler.yaml`' file according to environment:
    1. Line 11: set correct Role ARN in `.metadata.annotations.eks.amazonaws.com/role-arn`. --> you can use `terraform output eks_cluster_autoscaler_arn` to get the value.
    2. Line 155: ensure '`cluster-autoscaler`' image version (tag) is supported by your EKS cluster version in `spec.template.spec.containers.image`.
    3. Line 174: ensure these accordingly:

       - `k8s.io/cluster-autoscaler/demo-eks: owned` --> 'demo-eks' is eks cluster name, for example. You can use `terraform output eks_cluster_name` to get correct value for your cluster.
       - `k8s.io/cluster-autoscaler/enabled: true`

12. Deploy cluster autoscaler manifest: `kubectl apply -f ../kubernetes/cluster-autoscaler.yaml`
    - Sample output:

      ```
      $ kubectl apply -f ../kubernetes/cluster-autoscaler.yaml
      serviceaccount/cluster-autoscaler created
      clusterrole.rbac.authorization.k8s.io/cluster-autoscaler created
      role.rbac.authorization.k8s.io/cluster-autoscaler created
      clusterrolebinding.rbac.authorization.k8s.io/cluster-autoscaler created
      rolebinding.rbac.authorization.k8s.io/cluster-autoscaler created
      deployment.apps/cluster-autoscaler created
      ```

13. Check logs to verify: `kubectl logs -f -l app=cluster-autoscaler -n kube-system`
14. Now, deploy helm chart for password-generator application:
    1. Go to proper directory: `cd ../helmchart`
    2. Update Helm chart's values for AWS, if required, in file: [helmchart/custom-values-aws.yaml](/helmchart/custom-values-aws.yaml)
    3. (Optional) Dry-run to check manifests:

        ```sh
        helm upgrade --install \
          -n app --create-namespace \
          --values custom-values-aws.yaml \
          --dry-run \
          password-generator \
          ./password-generator
        ```

    4. Install the chart in '`app`' namespace:

        ```sh
        helm upgrade --install \
          -n app --create-namespace \
          --values custom-values-aws.yaml \
          password-generator \
          ./password-generator
        ```

15. Check helm installation: `helm list -n app`
16. Check resources: `kubectl get all -n app`
17. Check AWS load balancer controller logs to check if resources are created or if there's any error:

    - `kubectl logs -f -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller`

18. Test app from browser or REST API client or a new shell, at `http://<AWS_LOAD_BALANCER_DNS_NAME>`.

   - Snapshots from testing with REST API client:
     - Get Application Homepage: ![App homepage](/docs/images/aws-test-helm-homepage.png "Application Homepage")<br>
     - Generate passwords: ![Generate passwords](/docs/images/aws-test-helm-generate-pass.png "Generate passwords")
   - Example (testing from terminal with `curl`):

      ```sh
      $ curl --request GET --url http://<AWS_LOAD_BALANCER_DNS_NAME>/
      Welcome to Password Generator%

      $ curl -s --request POST \
          --url http://<AWS_LOAD_BALANCER_DNS_NAME>/generate-passwords \
          --header 'content-type: application/json' \
          --data '{
              "min_length": 11,
              "special_chars": 1,
              "numbers": 3,
              "num_passwords": 2
          }'
      ["K99Rx8e>Xbw","aG{gzH1v0Y3","1wyr8mjOY%8"]

      ## Using 'jq' tool for better output
      $ curl -s --request POST \
          --url http://<AWS_LOAD_BALANCER_DNS_NAME>/generate-passwords \
          --header 'content-type: application/json' \
          --data '{
              "min_length": 10,
              "special_chars": 0,
              "numbers": 3,
              "num_passwords": 2
          }' | jq
      [
        "27sJ4LuuOL",
        "RNRp5s4F5t"
      ]
      ```

19. You can modify the replica count for `deployment.apps/password-generator` to check if cluster scaler trigger Node Group scaling, so that new nodes are added to cluster automatically. Once the replica count is reduced, the nodes should be removed automatically (usually takes ~10 minutes). Options:

    - You can increase replica count.
    - You can also modify resources usage for pod (requests) to enforce new node additions.

20. If full testing is done, you can remove the resources.
    1. Uninstall the helm chart if all testings are completed: `helm uninstall password-generator -n app`. Wait till LB and other resources are fully deleted.
    2. Remove namespace, if required: `kubectl delete namespace app`
    3. Cluster autoscaler: wait for it to cool down before removing it's config).
       - `kubectl delete -f ../kubernetes/cluster-autoscaler.yaml`
    4. Delete terraform configuration: `cd .. && terraform destroy`. --> takes around 15-20 minutes.

## Observations

- The security can be increased by restricting traffic from specific IP sources at Ingress and also at security groups. More info: 
  - https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#whitelist-source-range
  - https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.7/guide/ingress/annotations/#access-control.
- It's wise to use HTTPS traffic instead of HTTP, redirecting HTTP to HTTPS by default. More info:
  - https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.7/guide/ingress/annotations/#traffic-listening
  - https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#server-side-https-enforcement-through-redirect
- It's also good to use proper security policy for LB. More info:
  - https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies.
- Terraform lifecycle policies can also help ensure robust infrastructure.
  - '[prevent destroy](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#prevent_destroy)' will prevent resources being accidentally deleted, like RDS or S3 bucket or DynamoDB tables, for example.
  - '[create_before_destroy](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#create_before_destroy)' will help to ensure downtime is minimum during breaking changes. For example, replacing node group or EKS cluster, etc.
- Drift changes in infrastructure config can also be checked and deviation alerts can be triggered by running idempotent tools (like Terraform/Ansible/Chef/Puppet/CloudFormation etc) in regular intervals (for example, every 6 hours). This ensures, version-controlled configurations are always in-place. However, admin users must ensure not to make changes to infra by click-ops unless absolutely critical.
- Measures can be taken to ensure pods are running across multiple nodes (or nodes in different availability zones) to reduce disruptions due to node or availability zone failures. Some options can be found at: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/.
- Deliberate changes to services can be prevented by using  PodDisruptionBudget resource, for example, during cluster upgrade or draining nodes. The '`minAvailable`' should not be equal to target desired replicas as it will almost always prevent full eviction of pods. More info: https://kubernetes.io/docs/tasks/run-application/configure-pdb/.

---
