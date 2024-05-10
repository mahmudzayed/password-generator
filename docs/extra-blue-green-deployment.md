# Blue/Green Deployment Testing on a Kubernetes Cluster

The Blue/green deployment is a software deployment approach that helps organizations deploy frequent updates while maintaining high quality and a smooth user experience. 

This model uses two similar production environments (blue and green) to release software updates. The blue environment runs the existing software version, while the green environment runs the new version. Only one environment is live at any time, receiving all production traffic. Once the new version passes the relevant tests, it is safe to transfer the traffic to the new environment. If something goes wrong, traffic is switched to the previous version.

There are many ways we can leverage blue/green deployment for this application. Some options are given below:

## Kubernetes Native Option

By default, Kubernetes 'deployment' objects are good at rolling updates (by default). But in order to obtain blue/green features, we can follow this approach:

1. Create a deployment using v1 container image of app, and having specific labels for deployment and pod labels under templates. Example label, 'version: blue'.
2. Service this deployment using a service with selector labels 'version: blue' to route traffic to v1 pods. An ingress can be used to route incoming traffic to v1 pods via the service resource.
3. Create a new deployment similar to v1, but add labels 'version: green'. This deployment uses v2 container image of the app.
4. There should be adequate testing to ensure v2 of app is good to go.
5. Once tested, update the service manifest with selector labels 'version: green'. This seamlessly routes incoming traffic from ingress to v2 pods.
6. In case of bugs with v2, selector labels can be updated to 'version: blue' to switch traffic to v1 pods instantly.
7. Once v2 is tested to be performing as expected, v1 deployment can be scaled down to 0 and eventually removed (if needed).

This is a manual approach but it can be achieved via scripts (Makefile or bash commands like sed, grep, awk, etc.) or automation tools.

## Using Other Tools

There are many tools that can also help with such blue/green deployments for Kubernetes platform. These are some custom tools that require extra configurations, but the target result can be achieved using them.

- Istio can be used to seamless migrate traffic from one version to another and rolling back in case of issues. It helps to implement service mesh to manage traffic to pods in a controlled manner. More info: https://istio.io/
- Flager is another tool that can help with various modes of deployment including blue/green manner. More info: https://flagger.app/
- ArgoCD Rollouts can also be used to implement blue/green setups. More info: https://argoproj.github.io/rollouts/
- Multiple AWS EKS clusters on same VPC (blue & green clusters) can set up quickly with Terraform or other options like [EKS Blueprints](https://aws-quickstart.github.io/cdk-eks-blueprints/). Then, using AWS LB and External DNS addons, seamless migration can be planned/configured for blue/green deployment of application with less downtime. More info: https://aws.amazon.com/blogs/containers/blue-green-or-canary-amazon-eks-clusters-migration-for-stateless-argocd-workloads/.

**Note:** with blue/green strategy, the cost will always be a factor to consider as this strategy expects parallel live environment up and running.

---
