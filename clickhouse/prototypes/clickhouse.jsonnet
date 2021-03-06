// @apiVersion 0.0.1
// @name io.ksonnet.pkg.clickhouse
// @description Deploy Clickhouse database.
// @shortDescription Deploy Clickhouse database.
// @optionalParam namespace string default Namespace where to deploy Clickhouse
// @optionalParam name string clickhouse Name to give to each of the components
// @optionalParam image string kubepro/clickhouse:latest Clickhouse image
// @param zkHost string zkHost Zookeeper host
// @optionalParam zkPort string 2181 Zookeeper port




local k = import 'k.libsonnet';
local clickhouse = import 'kubepro/clickhouse/clickhouse.libsonnet';

local namespace = import 'param://namespace';
local name = import 'param://name';
local image = import 'param://image';
local zkHost = import 'param://zkHost';
local zkPort = import 'param://zkPort';

k.core.v1.list.new([
  clickhouse.parts.service(namespace, name),
  clickhouse.parts.statefulset(namespace, name, image, zkHost, zkPort),
])
