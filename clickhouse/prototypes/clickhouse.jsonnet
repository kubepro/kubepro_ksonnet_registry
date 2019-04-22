// @apiVersion 0.0.1
// @name io.ksonnet.pkg.clickhouse
// @description Deploy Clickhouse database.
// @shortDescription Deploy Clickhouse database.
// @param namespace string Namespace default 'default'
// @param chImage string chImage default 'kubepro/clickhouse'
// @param chImageTag string chImageTag default 'latest'
// @param zkHost string zkHost
// @param zkPort string zkPort default '2181'




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
