# v0.3.0

### Breaking Changes
* Removing custom LetsEncrypt support in favor of CertManager

### Features
* Adding RBAC support
* Additional TCP option support for Vault

### Fixes
* Fixes issue with dumb-init not running as PID 1 in the Vault deployment
* Will now automatically roll deployments when Vault config changes

# v0.2.0
* Added Pod Disruptions Budgets (PDBs) to Consul and Vault
* Added optional rolling update partitioning for Consul
* Added AntiAffinities for Consul and Vault
* Bumped Vault to 1.1.0 and Consul to 1.4.4
* Added Liveness probes to Consul and Vault
* Added more configurable Readiness probe for Vault

# v0.1.2

### Action Required (Breaking Change)

* ACTION REQUIRED: This release contains a major change that standardizes and shortens the naming/labeling conventions of resources created with this Helm chart ([see #40](https://github.com/ReadyTalk/vault-helm-chart/issues/40)). As a result, in-place upgrades from chart v0.1.0 or v0.1.1 by simply doing a `helm upgrade` will result is many breaking issues. It may be possible to upgrade with a complex set of steps but the recommendation is that you backup your Consul cluster and do a fresh `helm install` with the new chart.  Then you can restore your data with a `consul snapshot restore`.  See the [0.1.2 migration guide](docs/0.1.2-MIGRATION.md) for a full set of steps.

# v0.1.1

## Changelog since v0.1.0

### Major Updates
* Removed third party UI in favor of the build-in OSS UI
* Fixed many issues that occured in more recent Kubernetes releases

### Notable Issues Fixed
* [#14](https://github.com/ReadyTalk/vault-helm-chart/issues/14) Separated restore job so that it wouldn't run on each restart of the backup pod
* [#17](https://github.com/ReadyTalk/vault-helm-chart/issues/17) Added HostAlias value options
* [#18](https://github.com/ReadyTalk/vault-helm-chart/issues/18) Added NodePort value options
* [#20](https://github.com/ReadyTalk/vault-helm-chart/issues/20) Upgraded default Vault version to 0.9.5
* [#22](https://github.com/ReadyTalk/vault-helm-chart/issues/22) Added option to use your own custom TLS certificate
* [#38](https://github.com/ReadyTalk/vault-helm-chart/issues/38) Remove Consul UI options (in an effort to migrate to the official Consul helm chart)
* [#36](https://github.com/ReadyTalk/vault-helm-chart/issues/36) Removed third party UI in favor of the build-in OSS UI
* [#39](https://github.com/ReadyTalk/vault-helm-chart/issues/39) Removed option to enable the Consul UI
* [#43](https://github.com/ReadyTalk/vault-helm-chart/issues/43) Fixed ConfigMap read-only issue for Consul
