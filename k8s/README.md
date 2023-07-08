# Codr's K8s Configuration

## Backend Services

Several services are being transferred to helm chart deployments. For these
types of domployment, please only modify the files in the `/k8s/config` folder.

### User Domain

- user/auth.yaml
- user/profile.yaml
- user/session.yaml
- user/user.yaml
- user/usergroup.yaml

### Other

- gateway.yaml

## Kafka

Kafka is being installed via custom build helm charts and con be configured in the `/k8s/config` folder.

## Web Clients

- design.yaml
- docs.yaml
- web.yaml

## Secrets

- ses.yaml
