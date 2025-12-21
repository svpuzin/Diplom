local p = import '../params.libsonnet';
local params = p.components.app;

[
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'diplom',
      namespace: 'default',
    },
    labels: {
      app: 'diplom',
      component: 'web',
    },
    spec: {
      replicas: params.replicas,
      selector: {
        matchLabels: {
          app: 'diplom',
          component: 'web',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'diplom',
            component: 'web',
          },
        },
        spec: {
          containers: [
            {
              name: 'diplom',
              image: params.image,
            },
          ],
          ports: [
            {
              name: 'diplom-cp',
              containerPort: '80',
              protocol: 'TCP',
            },
          ],
        },
      },
    },
  },
]
