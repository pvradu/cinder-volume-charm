# Overview

This charm provides the Cinder volume block service for OpenStack on Windows. It can be configured with either iSCSI local storage or using the SMB driver with access to an SMB share.

# Usage

Charm requires the other core OpenStack services deployed: mysql, rabbitmq-server, keystone and nova-cloud-controller. Typical deployments are:

## Local storage with iSCSI backend enabled

Deploy commands:

    juju deploy cs:~cloudbaseit/cinder
    juju config cinder enabled-backends="iscsi"

    juju add-relation cinder mysql
    juju add-relation cinder rabbitmq-server
    juju add-relation cinder glance

## Shared storage with SMB backend enabled

Besides the core OpenStack services charms, the following charms should also be deployed: active-directory, wsfc, s2d-proxy.

Deploy commands:

    juju deploy cs:~cloudbaseit/cinder
    juju config cinder enabled-backends="smb"

    juju add-relation cinder-volume mysql
    juju add-relation cinder-volume rabbitmq-server
    juju add-relation cinder-volume glance
    juju add-relation cinder-volume active-directory
    juju add-relation cinder-volume 'wsfc:wsfc'
    juju add-relation 'cinder-volume:smb-share' s2d-proxy

# Configuration

* `hostname` - This should be set if the Cinder units are using shared storage and cluster generic service role is not created through the relation `cluster-service` with wsfc charm.

* `change-hostname` - In case OpenStack provider is used, due to the hostname length limitation on Windows this configuration option should be set to `True`.

* `installer-url` - If this is not set, it defaults to one of the official Cloudbase [download links](https://cloudbase.it/openstack-windows-storage/) (this is chosen depending on the configured OpenStack version).

* `enabled-backends` - It dictates which Cinder volume driver to be used. The charm can also be configured with multiple backends enabled.
