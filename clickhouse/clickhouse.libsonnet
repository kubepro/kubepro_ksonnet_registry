{

  parts:: {

    service(namespace, name):: {
      apiVersion: "v1",
      kind: "Service",
      metadata: {
        namespace: namespace,
        name: name,
      }
      spec: {
        type: "ClusterIP",
        ports: [
          {
            port: 8123,
            name: "http",
          },
          {
            port: 9000,
            name: "tcp",
          },
          {
            port: 9009,
            name: "interserver",
          }
        ],

        clusterIP: "None",
        selector: {
          app: name,
        },
      },
    },

    statefulset(
        namespace,
        name,
        image,
        zkHost,
        zkPort,
    ):: {

      apiVersion: "apps/v1beta1",
      kind: "StatefulSet",
      metadata: {
        namespace: namespace,
        name: name,
      },
      spec: {
        serviceName: name,
        replicas: 2,
        updateStrategy: {
          type: "RollingUpdate",
        },
        podManagementPolicy: "Parallel",
        template: {
          metadata: {
            labels: {
              app: name,
            },
          },
          spec: {
            affinity: {
              podAntiAffinity: {
                preferredDuringSchedulingIgnoredDuringExecution: [
                  {
                    weight: 100,
                    podAffinityTerm: {
                      labelSelector: {
                        matchExpressions: [
                          {
                            key: "app",
                            operator: "In",
                            values: [
                              name,
                            ],
                          },
                        ],
                      },
                      topologyKey: "failure-domain.beta.kubernetes.io/zone",
                    },
                  },
                ],
              },
            },
            containers: [
              {
                name: "main",
                imagePullPolicy: "Always",
                image: image,
                env: [
                  {
                    name: "CH_REPLICAS",
                    value: "2",
                  },
                  {
                    name: "CH_ZOOKEEPER_SERVERS",
                    value: std.join(":" [zkHost, zkPort]),
                  },
                  {
                    name: "CH_CONFIG_XML",
                    value: "/config.xml",
                  },
                  {
                    name: "CH_USERS_XML",
                    value: "/users.xml",
                  },
                  {
                    name: "CH_USER",
                    valueFrom: {
                      secretKeyRef: {
                        name: "clickhouse-env",
                        key: "CH_USER",
                      },
                    },
                  },
                  {
                    name: "CH_PASSWORD",
                    valueFrom: {
                      secretKeyRef: {
                        name: "clickhouse-env",
                        key: "CH_PASSWORD",
                      },
                    },
                  },
                ],
                command: [
                  "sh",
                  "-c",
                  "/clickhouse_gen_config.py > ${CH_CONFIG_XML} && /clickhouse_gen_users.py > ${CH_USERS_XML} && exec /usr/bin/clickhouse-server --config=${CH_CONFIG_XML}"
                ],
                ports: [
                  {
                    containerPort: 8123,
                    name: "http",
                  },
                  {
                    containerPort: 9000,
                    name: "tcp",
                  },
                  {
                    containerPort: 9009,
                    name: "interserver",
                  },
                ],
                volumeMounts: [
                  {
                    name: "datadir",
                    mountPath: "/var/lib/clickhouse",
                  },
                ],
              },
              {
                name: "flush-dns",
                imagePullPolicy: "Always",
                image: image,
                env: [
                  {
                    name: "CH_USER",
                    valueFrom: {
                      secretKeyRef: {
                        name: "clickhouse-env",
                        key: "CH_USER",
                      },
                    },
                  },
                  {
                    name: "CH_PASSWORD",
                    valueFrom: {
                      secretKeyRef: {
                        name: "clickhouse-env",
                        key: "CH_PASSWORD",
                      },
                    },
                  },
                  {
                    name: "CH_FLUSH_DNS_INTERVAL",
                    value: "120",
                  },
                ],
                command: [
                  "sh",
                  "-c",
                  "/clickhouse_flush_dns.sh",
                ],
              },
            ],
          },
          volumeClaimTemplates: [
            {
              metadata: {
                name: "datadir",
              },
              spec: {
                accessModes: [ "ReadWriteOnce" ],
                resources: {
                  requests: {
                    storage: "50Gi",
                  },
                },
              },
            },
          ],
        },
      },
    },
  },
}
