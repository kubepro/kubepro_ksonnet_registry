// @apiVersion 0.0.1
// @name io.ksonnet.pkg.clickhouse
// @description Deploy Clickhouse database.
// @shortDescription Deploy Clickhouse database.
// @optionalParam namespace string 'default' Namespace where to deploy Clickhouse
// @optionalParam chImage string 'kubepro/clickhouse' Clickhouse image
// @optionalParam chImageTag string 'latest' Clickhouse image tag
// @param zkHost string zkHost Zookeeper host
// @optionalParam zkPort string '2181' Zookeeper port




local k = import 'k.libsonnet';
local clickhouse = import 'clickhouse/clickhouse.libsonnet';

local namespace = import 'param://namespace';
local chImage = import 'param://chImage';
local chImageTag = import 'param://chImageTag';
local zkHost = import 'param://zkHost';
local zkPort = import 'param://zkPort';

k.core.v1.list.new([
  clickhouse.parts.service(namespace),
  clickhouse.parts.statefulset(
      namespace,
      chImage,
      chImageTag,
      zkHost,
      zkPort,
  )
])
